import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// A TextEditingController that supports WYSIWYG rich text formatting.
///
/// This controller tracks formatting spans and active formats, allowing users
/// to type formatted text without seeing the markdown markers. The formatting
/// is visually applied in real-time, and can be converted to markdown when
/// the message is sent.
///
/// Example usage:
/// ```dart
/// final controller = RichTextEditingController();
/// controller.toggleFormat(FormatType.bold);
/// // Now any text typed will be bold
/// controller.toggleFormat(FormatType.italic);
/// // Now any text typed will be bold AND italic
/// controller.toggleFormat(FormatType.bold);
/// // Now any text typed will be only italic
/// ```
class RichTextEditingController extends TextEditingController {
  RichTextEditingController({
    String? text,
    this.formatters,
    this.richTextStyle,
    bool parseMarkdown = false,
  }) : super(text: text) {
    // Only parse markdown if explicitly requested (e.g., when editing a message)
    if (parseMarkdown && text != null && text.isNotEmpty) {
      _parseMarkdownToSpans(text);
    }
  }

  /// List of text formatters for additional formatting (mentions, etc.)
  List<CometChatTextFormatter>? formatters;

  /// Style configuration for rich text formatting
  CometChatRichTextFormatterStyle? richTextStyle;

  /// The set of currently active formats that will be applied to new text.
  final Set<FormatType> _activeFormats = {};

  /// List of formatting spans tracking which ranges have which formats.
  final List<RichTextSpan> _spans = [];

  /// Guard flag to prevent _handleTextChange from firing during internal updates
  /// where spans have already been manually adjusted.
  bool _isInternalUpdate = false;
  
  /// Guard flag to prevent updateActiveFormatsFromCursor from clearing formats
  /// during list/blockquote continuation operations.
  bool _preserveFormatsOnUpdate = false;

  /// Counter for tracking consecutive enters on empty lines.
  /// 
  /// Used by [exitOnDoubleEnter] and [exitOnTripleEnter] to detect when the user
  /// wants to exit a list or block format by pressing Enter multiple times.
  /// 
  /// _Requirements: 2.22, 2.23, 2.24, 2.25_
  int _consecutiveEmptyEnterCount = 0;

  /// Callback invoked when a link span is long-pressed.
  ///
  /// This allows the parent widget to show a context menu for editing or
  /// removing the link.
  ///
  /// _Requirements: 4.1_
  void Function(RichTextSpan)? onLinkLongPress;

  /// Callback invoked when a link span is tapped.
  ///
  /// This allows the parent widget to show a context menu for editing or
  /// removing the link when the user taps on a link in the composer.
  void Function(RichTextSpan)? onLinkTap;

  /// Callback invoked when a code block should be inserted.
  ///
  /// This is called when the user toggles code block format in a segmented
  /// composer. The parent controller handles the actual segment creation.
  void Function()? onInsertCodeBlock;

  /// Gets the currently active formats.
  /// 
  /// This includes both inline formats (bold, italic, etc.) from `_activeFormats`
  /// and line-level formats (bulletList, orderedList, blockquote) detected from
  /// the current line's prefix. Supports nested formats like "> - item".
  Set<FormatType> get activeFormats {
    final result = Set<FormatType>.from(_activeFormats);
    
    // Detect line-level formats from the current line's prefix
    // This supports nested formats (e.g., blockquote + bullet list)
    final lineLevelFormats = _detectLineLevelFormats();
    result.addAll(lineLevelFormats);

    // Detect link format at cursor for toolbar display.
    // Link is excluded from _activeFormats so typing doesn't extend links,
    // but the toolbar should still show it as active when cursor is on a link.
    if (selection.isCollapsed) {
      final pos = selection.baseOffset;
      if (getLinkSpanAtPosition(pos) != null) {
        result.add(FormatType.link);
      }
    }
    
    return Set.unmodifiable(result);
  }
  
  /// Detects if the current line has a line-level format prefix.
  /// 
  /// Returns a set of detected [FormatType]s (bulletList, orderedList, blockquote)
  /// based on the current line's prefix. Supports nested formats like "> - item".
  Set<FormatType> _detectLineLevelFormats() {
    final currentText = text;
    final result = <FormatType>{};
    if (currentText.isEmpty) return result;
    
    // Get cursor position, clamped to valid range
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    
    // Find the start of the current line
    final lineStart = currentText.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;
    
    // Find the end of the current line
    int lineEnd = currentText.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = currentText.length;
    
    // Safety check: ensure lineEnd >= lineStart
    if (lineEnd < lineStart) return result;
    
    // Get the current line text
    final currentLine = currentText.substring(lineStart, lineEnd);
    
    // Check for blockquote prefix: "> "
    if (currentLine.startsWith('> ')) {
      result.add(FormatType.blockquote);
      
      // Check for nested list inside blockquote: "> - " or "> N. "
      final quoteContent = currentLine.substring(2);
      if (quoteContent.startsWith('- ')) {
        result.add(FormatType.bulletList);
      } else if (RegExp(r'^\d+\. ').hasMatch(quoteContent)) {
        result.add(FormatType.orderedList);
      }
    } else {
      // Check for bullet list prefix: "- "
      if (currentLine.startsWith('- ')) {
        result.add(FormatType.bulletList);
      }
      
      // Check for ordered list prefix: "N. " where N is a number
      if (RegExp(r'^\d+\. ').hasMatch(currentLine)) {
        result.add(FormatType.orderedList);
      }
    }
    
    return result;
  }
  
  /// Detects if the current line has a line-level format prefix.
  /// 
  /// Returns the detected [FormatType] (bulletList, orderedList, or blockquote)
  /// if the current line starts with the corresponding prefix, or null if no
  /// line-level format is detected.
  /// 
  /// Note: For nested formats (e.g., "> - item"), this returns the outermost format.
  /// Use [_detectLineLevelFormats] to get all active line-level formats.
  FormatType? _detectLineLevelFormat() {
    final formats = _detectLineLevelFormats();
    if (formats.isEmpty) return null;
    
    // Return the outermost format (blockquote takes precedence)
    if (formats.contains(FormatType.blockquote)) {
      return FormatType.blockquote;
    }
    return formats.first;
  }

  /// Gets the formatting spans.
  List<RichTextSpan> get spans => List.unmodifiable(_spans);

  /// Set of exclusive format types that are mutually exclusive.
  /// Only one of these can be active at a time.
  static const Set<FormatType> _exclusiveFormats = {
    FormatType.blockquote,
    FormatType.inlineCode,
    FormatType.codeBlock,
    FormatType.orderedList,
    FormatType.bulletList,
  };

  /// Checks if a format type is exclusive (mutually exclusive with other exclusive formats).
  bool _isExclusiveFormat(FormatType formatType) {
    return _exclusiveFormats.contains(formatType);
  }

  /// Removes all exclusive formats from active formats.
  /// Returns the set of formats that were removed.
  Set<FormatType> _removeExclusiveFormats() {
    final removed = <FormatType>{};
    for (final format in _exclusiveFormats) {
      if (_activeFormats.remove(format)) {
        removed.add(format);
      }
    }
    return removed;
  }

  /// Toggles a format on/off for subsequent typing.
  ///
  /// If the format is currently active, it will be deactivated.
  /// If the format is not active, it will be activated.
  ///
  /// When text is selected, the format is applied/removed from the selection.
  ///
  /// Line-level formats (bulletList, orderedList, blockquote) insert or remove
  /// the prefix at the beginning of the current line(s) rather than toggling
  /// an inline style.
  ///
  /// **Mutual Exclusivity Rules:**
  /// - Inline formats (bold, italic, underline, strikethrough, link) can be
  ///   combined with each other.
  /// - Exclusive formats (blockquote, inlineCode, codeBlock, orderedList,
  ///   bulletList) are mutually exclusive - only one can be active at a time.
  /// - When an exclusive format is activated, any other active exclusive
  ///   format is automatically deactivated.
  /// - When code block is active, inline formatting (bold, italic, underline,
  ///   strikethrough, link, inlineCode) is ignored.
  void toggleFormat(FormatType formatType) {
    // Check if code block is active - if so, ignore inline formatting
    if (_isCodeBlockActive() && _isInlineFormat(formatType)) {
      // Code block is active - ignore inline formatting commands
      return;
    }
    
    // Line-level formats need special handling — they modify the text by
    // inserting / removing a prefix at the start of the affected line(s).
    if (formatType == FormatType.bulletList ||
        formatType == FormatType.orderedList ||
        formatType == FormatType.blockquote) {
      _toggleLineLevelFormat(formatType);
      notifyListeners();
      return;
    }

    if (selection.isCollapsed) {
      // No selection - toggle format for subsequent typing
      if (_activeFormats.contains(formatType)) {
        _activeFormats.remove(formatType);
      } else {
        // If this is an exclusive format, remove other exclusive formats first
        if (_isExclusiveFormat(formatType)) {
          _removeExclusiveFormats();
        }
        // If activating code block, strip all inline formatting from existing spans
        // _Requirements: 2.4_
        if (formatType == FormatType.codeBlock) {
          _stripAllInlineFormatsFromSpans();
        }
        _activeFormats.add(formatType);
      }
    } else {
      // Has selection - apply/remove format to selected text
      // If applying code block, first strip all inline formatting from the selection
      // _Requirements: 2.4_
      if (formatType == FormatType.codeBlock && !_selectionHasFormat(selection.start, selection.end, FormatType.codeBlock)) {
        _stripInlineFormatsFromRange(selection.start, selection.end);
      }
      _toggleFormatOnSelection(formatType);
      // Update active formats to reflect the new state of the selection
      updateActiveFormatsFromCursor();
    }
    
    notifyListeners();
  }
  
  /// Checks if code block is currently active.
  /// 
  /// Returns true if the current line is inside a code block (starts with ```)
  /// or if codeBlock format is in the active formats.
  bool _isCodeBlockActive() {
    // Check if codeBlock is in active formats
    if (_activeFormats.contains(FormatType.codeBlock)) {
      return true;
    }
    
    // Check if current line is inside a code block
    final currentText = text;
    if (currentText.isEmpty) return false;
    
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    
    // Count ``` markers before cursor position to determine if we're inside a code block
    int codeBlockCount = 0;
    int searchPos = 0;
    while (searchPos < cursorPos) {
      final markerPos = currentText.indexOf('```', searchPos);
      if (markerPos == -1 || markerPos >= cursorPos) break;
      codeBlockCount++;
      searchPos = markerPos + 3;
    }
    
    // If odd number of ``` markers before cursor, we're inside a code block
    return codeBlockCount % 2 == 1;
  }
  
  /// Checks if a format type is an inline format.
  /// 
  /// Inline formats are: bold, italic, underline, strikethrough, link, inlineCode.
  /// These should be disabled when code block is active.
  bool _isInlineFormat(FormatType formatType) {
    return formatType == FormatType.bold ||
           formatType == FormatType.italic ||
           formatType == FormatType.underline ||
           formatType == FormatType.strikethrough ||
           formatType == FormatType.link ||
           formatType == FormatType.inlineCode;
  }

  /// Deactivates code block format by removing it from active formats,
  /// removing ``` markers from the text, and clearing code block formatting from spans.
  /// 
  /// This is called when user clicks on bullet list or ordered list
  /// while code block is active, to switch from code block to list format.
  void _deactivateCodeBlock() {
    // Remove codeBlock from active formats
    _activeFormats.remove(FormatType.codeBlock);
    
    // Remove codeBlock format from all spans
    _removeCodeBlockFromSpans();
    
    // Remove ``` markers from text
    final currentText = text;
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    
    // Find and remove ``` markers
    String newText = currentText;
    int cursorOffset = 0;
    
    // Find opening ``` marker before cursor
    int openingMarkerPos = -1;
    int searchPos = 0;
    int markerCount = 0;
    while (searchPos < cursorPos) {
      final markerPos = newText.indexOf('```', searchPos);
      if (markerPos == -1 || markerPos >= cursorPos) break;
      markerCount++;
      if (markerCount % 2 == 1) {
        openingMarkerPos = markerPos;
      }
      searchPos = markerPos + 3;
    }
    
    // Find closing ``` marker after cursor (or at cursor)
    int closingMarkerPos = newText.indexOf('```', cursorPos);
    if (closingMarkerPos == -1) {
      // No closing marker found, check if cursor is at the marker
      closingMarkerPos = newText.indexOf('```', cursorPos > 3 ? cursorPos - 3 : 0);
    }
    
    // Remove markers if found
    if (openingMarkerPos != -1) {
      // Check if there's a newline after opening marker
      int removeEnd = openingMarkerPos + 3;
      if (removeEnd < newText.length && newText[removeEnd] == '\n') {
        removeEnd++;
      }
      newText = newText.substring(0, openingMarkerPos) + newText.substring(removeEnd);
      
      // Adjust cursor offset
      if (cursorPos > openingMarkerPos) {
        cursorOffset -= (removeEnd - openingMarkerPos);
      }
      
      // Adjust closing marker position
      if (closingMarkerPos != -1 && closingMarkerPos > openingMarkerPos) {
        closingMarkerPos -= (removeEnd - openingMarkerPos);
      }
    }
    
    if (closingMarkerPos != -1 && closingMarkerPos >= 0 && closingMarkerPos < newText.length) {
      // Check if there's a newline before closing marker
      int removeStart = closingMarkerPos;
      if (removeStart > 0 && newText[removeStart - 1] == '\n') {
        removeStart--;
      }
      int removeEnd = closingMarkerPos + 3;
      if (removeEnd <= newText.length) {
        newText = newText.substring(0, removeStart) + newText.substring(removeEnd);
        
        // Adjust cursor offset if cursor is after the closing marker
        if (cursorPos + cursorOffset > removeStart) {
          cursorOffset -= (removeEnd - removeStart);
        }
      }
    }
    
    // Update text if changed
    if (newText != currentText) {
      final newCursorPos = (cursorPos + cursorOffset).clamp(0, newText.length);
      _setTextDirectly(newText, newCursorPos);
    }
  }
  
  /// Removes codeBlock format from all spans.
  /// 
  /// This is called when deactivating code block to ensure the existing text
  /// no longer has code block formatting applied.
  void _removeCodeBlockFromSpans() {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      if (span.formats.contains(FormatType.codeBlock)) {
        toRemove.add(span);
        // Create a new span without codeBlock format
        final newFormats = Set<FormatType>.from(span.formats)..remove(FormatType.codeBlock);
        if (newFormats.isNotEmpty) {
          toAdd.add(RichTextSpan(
            start: span.start,
            end: span.end,
            formats: newFormats,
            url: span.url,
          ));
        }
      }
    }
    
    // Apply changes
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
    
    _mergeAdjacentSpans();
  }

  /// Strips all inline formatting from all spans.
  /// 
  /// This is called when code block is activated to ensure no inline formatting
  /// (bold, italic, underline, strikethrough, link, inlineCode) remains.
  /// 
  /// _Requirements: 2.4_
  void _stripAllInlineFormatsFromSpans() {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      // Check if span has any inline formats
      final hasInlineFormats = span.formats.any((f) => _isInlineFormat(f));
      if (hasInlineFormats) {
        toRemove.add(span);
        // Create a new span without inline formats
        final newFormats = Set<FormatType>.from(span.formats)
          ..removeWhere((f) => _isInlineFormat(f));
        if (newFormats.isNotEmpty) {
          toAdd.add(RichTextSpan(
            start: span.start,
            end: span.end,
            formats: newFormats,
            url: null, // Remove URL since link is an inline format
          ));
        }
      }
    }
    
    // Apply changes
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
    
    _mergeAdjacentSpans();
  }

  /// Strips all inline formatting from a specific range.
  /// 
  /// This is called when code block is applied to selected text to ensure
  /// no inline formatting (bold, italic, underline, strikethrough, link, inlineCode)
  /// remains in the selection.
  /// 
  /// _Requirements: 2.4_
  void _stripInlineFormatsFromRange(int start, int end) {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      // Check if span overlaps with the range
      if (!span.overlaps(start, end)) continue;
      
      // Check if span has any inline formats
      final hasInlineFormats = span.formats.any((f) => _isInlineFormat(f));
      if (!hasInlineFormats) continue;
      
      toRemove.add(span);
      
      // Calculate the overlap region
      final overlapStart = span.start < start ? start : span.start;
      final overlapEnd = span.end > end ? end : span.end;
      
      // Create new span without inline formats for the overlap region
      final newFormats = Set<FormatType>.from(span.formats)
        ..removeWhere((f) => _isInlineFormat(f));
      
      // Keep the part before the range (if any) with original formats
      if (span.start < start) {
        toAdd.add(RichTextSpan(
          start: span.start,
          end: start,
          formats: span.formats,
          url: span.url,
        ));
      }
      
      // Add the overlap region without inline formats (if any non-inline formats remain)
      if (newFormats.isNotEmpty) {
        toAdd.add(RichTextSpan(
          start: overlapStart,
          end: overlapEnd,
          formats: newFormats,
          url: null, // Remove URL since link is an inline format
        ));
      }
      
      // Keep the part after the range (if any) with original formats
      if (span.end > end) {
        toAdd.add(RichTextSpan(
          start: end,
          end: span.end,
          formats: span.formats,
          url: span.url,
        ));
      }
    }
    
    // Apply changes
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
    
    _mergeAdjacentSpans();
  }

  /// Toggles a line-level format (bulletList, orderedList, blockquote) by
  /// inserting or removing the prefix at the beginning of each affected line.
  ///
  /// Works for both collapsed selections (current line) and range selections
  /// (all lines that overlap the selection).
  ///
  /// **Mutual Exclusivity Rules:**
  /// - Bullet list and ordered list are mutually exclusive with each other and code block
  /// - Quote block can combine with bullet list or ordered list (nested inside quote)
  /// - Code block is exclusive with all other block formats
  void _toggleLineLevelFormat(FormatType formatType) {
    // Check if code block is active - if so, deactivate it first before applying any block format
    // This includes bullet list, ordered list, AND blockquote
    // _Requirements: 2.3_
    if (_isCodeBlockActive() && (formatType == FormatType.bulletList || 
        formatType == FormatType.orderedList || 
        formatType == FormatType.blockquote)) {
      _deactivateCodeBlock();
    }
    
    final currentText = text;
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    final selEnd = selection.extentOffset.clamp(0, currentText.length);

    final effectiveStart = cursorPos <= selEnd ? cursorPos : selEnd;
    final effectiveEnd = cursorPos <= selEnd ? selEnd : cursorPos;

    // Find the start of the first affected line
    final firstLineStart =
        currentText.lastIndexOf('\n', effectiveStart > 0 ? effectiveStart - 1 : 0) + 1;

    // Find the end of the last affected line
    int lastLineEnd = currentText.indexOf('\n', effectiveEnd);
    if (lastLineEnd == -1) lastLineEnd = currentText.length;

    // Extract the affected block and split into lines
    final block = currentText.substring(firstLineStart, lastLineEnd);
    final lines = block.split('\n');

    // Determine the prefix for this format
    final prefix = formatType.prefix; // e.g. "- ", "1. ", "> "

    // Check whether the first line already has THIS format's prefix (toggle off)
    final bool removing = _lineHasPrefix(lines.first, formatType);

    final buffer = StringBuffer();
    // For ordered lists, determine the starting number based on previous lines
    int orderNumber = 1;
    if (formatType == FormatType.orderedList && !removing) {
      orderNumber = _getNextOrderNumber(currentText, firstLineStart);
    }
    for (int i = 0; i < lines.length; i++) {
      if (i > 0) buffer.write('\n');
      if (removing) {
        // Removing this format - just remove its prefix
        buffer.write(_removeLinePrefix(lines[i], formatType));
      } else {
        // Applying this format
        String processedLine;
        
        if (formatType == FormatType.blockquote) {
          // Quote block: Add "> " prefix, preserving any existing list prefix
          // This allows nesting like "> - item" or "> 1. item"
          processedLine = '$prefix${lines[i]}';
        } else if (formatType == FormatType.bulletList || formatType == FormatType.orderedList) {
          // List formats: Check if inside a quote block
          final isInsideQuote = lines[i].startsWith('> ');
          
          if (isInsideQuote) {
            // Inside quote block - add list prefix after "> "
            final quoteContent = lines[i].substring(2);
            // Remove any existing list prefix from quote content
            final cleanContent = _removeListPrefix(quoteContent);
            final linePrefix = formatType == FormatType.orderedList
                ? '$orderNumber. '
                : prefix;
            processedLine = '> $linePrefix$cleanContent';
          } else {
            // Not inside quote - remove any existing list prefix and apply new one
            final cleanLine = _removeListPrefix(lines[i]);
            final linePrefix = formatType == FormatType.orderedList
                ? '$orderNumber. '
                : prefix;
            processedLine = '$linePrefix$cleanLine';
          }
          orderNumber++;
        } else {
          // Other formats - remove any existing line-level format prefix
          final cleanLine = _removeAnyLineLevelPrefix(lines[i]);
          final linePrefix = formatType == FormatType.orderedList
              ? '$orderNumber. '
              : prefix;
          processedLine = '$linePrefix$cleanLine';
          orderNumber++;
        }
        
        buffer.write(processedLine);
      }
    }

    final newBlock = buffer.toString();
    final newText = currentText.substring(0, firstLineStart) +
        newBlock +
        currentText.substring(lastLineEnd);

    // Compute new cursor position
    final lengthDiff = newBlock.length - block.length;
    final newCursorPos = (cursorPos + lengthDiff).clamp(0, newText.length);

    // Shift spans that fall after the modified region
    if (lengthDiff != 0) {
      _shiftSpansAfter(firstLineStart, lengthDiff);
      _mergeAdjacentSpans();
    }

    // Renumber subsequent ordered list items if we changed a line that was/is an ordered list
    // This ensures proper numbering continuity when converting between list types
    final needsRenumbering = formatType == FormatType.bulletList || 
                             formatType == FormatType.orderedList ||
                             (removing && _lineHasPrefix(lines.first, FormatType.orderedList));
    
    if (needsRenumbering) {
      final renumberedText = _renumberOrderedListsAfter(newText, lastLineEnd + lengthDiff);
      final renumberLengthDiff = renumberedText.length - newText.length;
      _setTextDirectly(renumberedText, newCursorPos);
      
      // Adjust spans if renumbering changed text length
      if (renumberLengthDiff != 0) {
        _shiftSpansAfter(lastLineEnd + lengthDiff, renumberLengthDiff);
        _mergeAdjacentSpans();
      }
    } else {
      _setTextDirectly(newText, newCursorPos);
    }
  }
  
  /// Removes bullet list or ordered list prefix from a line.
  String _removeListPrefix(String line) {
    // Check and remove bullet list prefix
    if (line.startsWith('- ')) {
      return line.substring(2);
    }
    
    // Check and remove ordered list prefix
    final orderedMatch = RegExp(r'^\d+\. ').firstMatch(line);
    if (orderedMatch != null) {
      return line.substring(orderedMatch.end);
    }
    
    return line;
  }

  /// Gets the next order number for an ordered list by looking at previous lines.
  /// 
  /// Scans backwards from [lineStart] to find the most recent ordered list item
  /// and returns its number + 1. If no previous ordered list item is found,
  /// returns 1.
  /// 
  /// This ensures that when converting a line to an ordered list, it continues
  /// the numbering from any preceding ordered list items, even if there are
  /// non-list lines (like bullet points) in between.
  int _getNextOrderNumber(String text, int lineStart) {
    if (lineStart <= 0 || text.isEmpty) return 1;
    
    // Scan backwards through previous lines
    int searchPos = lineStart - 1; // Start before the newline
    
    while (searchPos >= 0) {
      // Find the start of the previous line
      final prevLineStart = text.lastIndexOf('\n', searchPos > 0 ? searchPos - 1 : 0);
      final actualLineStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
      
      // Find the end of this line (should be at or before lineStart)
      int lineEnd = text.indexOf('\n', actualLineStart);
      if (lineEnd == -1) lineEnd = text.length;
      if (lineEnd > lineStart) lineEnd = lineStart;
      
      // Safety check: ensure valid range
      if (lineEnd <= actualLineStart) {
        if (actualLineStart == 0) break;
        searchPos = actualLineStart - 2;
        continue;
      }
      
      // Get the line content
      final line = text.substring(actualLineStart, lineEnd);
      
      // Check if this line has an ordered list prefix (with optional blockquote)
      final orderedMatch = RegExp(r'^(> )?(\d+)\. ').firstMatch(line);
      if (orderedMatch != null) {
        final number = int.tryParse(orderedMatch.group(2) ?? '1') ?? 1;
        return number + 1;
      }
      
      // Check if this line has a bullet list prefix - continue searching
      // (bullet lists don't break the ordered list sequence)
      final hasBullet = line.startsWith('- ') || line.startsWith('> - ');
      
      // Empty lines also don't break the sequence - continue searching
      final isEmpty = line.trim().isEmpty;
      
      // If the line has content but no list prefix, stop searching
      // (regular text breaks the sequence)
      if (!hasBullet && !isEmpty) {
        break;
      }
      
      // Move to the previous line
      if (actualLineStart == 0) break;
      searchPos = actualLineStart - 2; // Move before the newline of the previous line
    }
    
    return 1;
  }

  /// Renumbers ordered list items after a given position.
  /// 
  /// This is called after converting a line to/from ordered list to ensure
  /// subsequent ordered list items have correct numbering.
  /// 
  /// The algorithm:
  /// 1. Scan forward from [afterPosition] through all lines
  /// 2. Track the expected next number based on previous ordered list items
  /// 3. When encountering an ordered list item with wrong number, fix it
  /// 4. Bullet lists and empty lines don't reset the counter
  /// 5. Regular text (non-list) resets the counter to 1
  String _renumberOrderedListsAfter(String text, int afterPosition) {
    if (afterPosition >= text.length) return text;
    
    // Find the start of the next line after afterPosition
    int lineStart = text.indexOf('\n', afterPosition);
    if (lineStart == -1) return text; // No more lines
    lineStart++; // Move past the newline
    
    // Determine the expected next number by looking at what comes before
    int expectedNumber = _getNextOrderNumber(text, lineStart);
    
    final buffer = StringBuffer();
    buffer.write(text.substring(0, lineStart));
    
    while (lineStart < text.length) {
      // Find the end of this line
      int lineEnd = text.indexOf('\n', lineStart);
      final hasNewline = lineEnd != -1;
      if (lineEnd == -1) lineEnd = text.length;
      
      final line = text.substring(lineStart, lineEnd);
      
      // Check if this line has an ordered list prefix (with optional blockquote)
      final orderedMatch = RegExp(r'^(> )?(\d+)\. (.*)$').firstMatch(line);
      if (orderedMatch != null) {
        final quotePrefix = orderedMatch.group(1) ?? '';
        final currentNumber = int.tryParse(orderedMatch.group(2) ?? '1') ?? 1;
        final content = orderedMatch.group(3) ?? '';
        
        // If the number is wrong, fix it
        if (currentNumber != expectedNumber) {
          buffer.write('$quotePrefix$expectedNumber. $content');
        } else {
          buffer.write(line);
        }
        expectedNumber++;
      } else {
        // Not an ordered list - write as-is
        buffer.write(line);
        
        // Check if this is a bullet list (doesn't reset counter)
        final isBullet = line.startsWith('- ') || line.startsWith('> - ');
        final isEmpty = line.trim().isEmpty;
        
        // Regular text resets the expected number
        if (!isBullet && !isEmpty) {
          expectedNumber = 1;
        }
      }
      
      // Add newline if there was one
      if (hasNewline) {
        buffer.write('\n');
        lineStart = lineEnd + 1;
      } else {
        break;
      }
    }
    
    return buffer.toString();
  }

  /// Removes any line-level format prefix from a line.
  /// This handles bullet list (- ), ordered list (N. ), and blockquote (> ) prefixes.
  String _removeAnyLineLevelPrefix(String line) {
    // Check and remove bullet list prefix
    if (line.startsWith('- ')) {
      return line.substring(2);
    }
    
    // Check and remove ordered list prefix
    final orderedMatch = RegExp(r'^\d+\. ').firstMatch(line);
    if (orderedMatch != null) {
      return line.substring(orderedMatch.end);
    }
    
    // Check and remove blockquote prefix
    if (line.startsWith('> ')) {
      return line.substring(2);
    }
    
    return line;
  }

  /// Returns true if [line] starts with the prefix for [formatType].
  /// 
  /// For bullet list and ordered list, this also checks for nested formats
  /// inside blockquotes (e.g., `> - item` or `> 1. item`).
  bool _lineHasPrefix(String line, FormatType formatType) {
    switch (formatType) {
      case FormatType.bulletList:
        // Check for direct bullet list or nested inside blockquote
        return line.startsWith('- ') || line.startsWith('> - ');
      case FormatType.orderedList:
        // Check for direct ordered list or nested inside blockquote
        return RegExp(r'^\d+\. ').hasMatch(line) || RegExp(r'^> \d+\. ').hasMatch(line);
      case FormatType.blockquote:
        return line.startsWith('> ');
      default:
        return false;
    }
  }

  /// Removes the line-level prefix from [line] for [formatType].
  /// 
  /// For bullet list and ordered list inside blockquotes, this removes only
  /// the list prefix while preserving the blockquote prefix.
  /// For example: `> - item` → `> item` when removing bullet list.
  String _removeLinePrefix(String line, FormatType formatType) {
    switch (formatType) {
      case FormatType.bulletList:
        // Check for nested bullet list inside blockquote first
        if (line.startsWith('> - ')) {
          return '> ${line.substring(4)}';
        }
        return line.startsWith('- ') ? line.substring(2) : line;
      case FormatType.orderedList:
        // Check for nested ordered list inside blockquote first
        final nestedMatch = RegExp(r'^> \d+\. ').firstMatch(line);
        if (nestedMatch != null) {
          return '> ${line.substring(nestedMatch.end)}';
        }
        final match = RegExp(r'^\d+\. ').firstMatch(line);
        return match != null ? line.substring(match.end) : line;
      case FormatType.blockquote:
        return line.startsWith('> ') ? line.substring(2) : line;
      default:
        return line;
    }
  }

  /// Activates a format for subsequent typing.
  void activateFormat(FormatType formatType) {
    _activeFormats.add(formatType);
    notifyListeners();
  }

  /// Deactivates a format for subsequent typing.
  void deactivateFormat(FormatType formatType) {
    _activeFormats.remove(formatType);
    notifyListeners();
  }

  /// Clears all active formats.
  void clearActiveFormats() {
    _activeFormats.clear();
    notifyListeners();
  }

  /// Checks if a format is currently active.
  bool isFormatActive(FormatType formatType) {
    return _activeFormats.contains(formatType);
  }
  
  /// Returns the set of inline formats that should be disabled.
  /// 
  /// When code block is active, all inline formats (bold, italic, underline,
  /// strikethrough, link, inlineCode) should be disabled.
  /// 
  /// This is used by the toolbar to visually disable inline buttons.
  Set<FormatType> get disabledFormats {
    if (_isCodeBlockActive()) {
      return {
        FormatType.bold,
        FormatType.italic,
        FormatType.underline,
        FormatType.strikethrough,
        FormatType.link,
        FormatType.inlineCode,
      };
    }
    return {};
  }

  /// Returns whether mentions should be enabled based on the active format.
  /// 
  /// Mentions are disabled when code block or inline code is active, as these
  /// formats should display mentions as plain text (@username/@all) without
  /// formatting or styling.
  /// 
  /// Mentions are enabled for all other formats including:
  /// - No block format active (normal text)
  /// - Ordered list
  /// - Bullet list
  /// - Quote block (blockquote)
  /// 
  /// _Bug_Condition: isBugCondition(input) where activeFormat IN ["codeBlock", "inlineCode"] AND mentionSuggestionShown_
  /// _Expected_Behavior: mentionsEnabled = false when code block or inline code is active_
  /// _Preservation: mentionsEnabled = true for all other formats_
  /// _Requirements: 2.5, 2.6, 2.7_
  bool get mentionsEnabled {
    // Check if code block is active
    if (_isCodeBlockActive()) {
      return false;
    }
    
    // Check if inline code is active
    if (_activeFormats.contains(FormatType.inlineCode)) {
      return false;
    }
    
    // For all other formats (ordered list, bullet list, blockquote, or no format),
    // mentions should be enabled
    return true;
  }

  // ============================================================================
  // CONVENIENCE METHODS FOR INLINE FORMATS (Combinable)
  // ============================================================================

  /// Toggles bold formatting.
  /// Bold can be combined with other inline formats (italic, underline, etc.).
  void toggleBold() => toggleFormat(FormatType.bold);

  /// Toggles italic formatting.
  /// Italic can be combined with other inline formats (bold, underline, etc.).
  void toggleItalic() => toggleFormat(FormatType.italic);

  /// Toggles underline formatting.
  /// Underline can be combined with other inline formats (bold, italic, etc.).
  void toggleUnderline() => toggleFormat(FormatType.underline);

  /// Toggles strikethrough formatting.
  /// Strikethrough can be combined with other inline formats (bold, italic, etc.).
  void toggleStrikethrough() => toggleFormat(FormatType.strikethrough);

  /// Toggles link formatting.
  /// Link can be combined with other inline formats (bold, italic, etc.).
  void toggleLink() => toggleFormat(FormatType.link);

  // ============================================================================
  // CONVENIENCE METHODS FOR EXCLUSIVE FORMATS (Mutually Exclusive)
  // ============================================================================

  /// Toggles blockquote formatting.
  /// Blockquote is mutually exclusive with other exclusive formats
  /// (inlineCode, codeBlock, orderedList, bulletList).
  void toggleBlockquote() => toggleFormat(FormatType.blockquote);

  /// Toggles inline code formatting.
  /// Inline code is mutually exclusive with other exclusive formats
  /// (blockquote, codeBlock, orderedList, bulletList).
  void toggleInlineCode() => toggleFormat(FormatType.inlineCode);

  /// Toggles code block formatting.
  /// Code block is mutually exclusive with other exclusive formats
  /// (blockquote, inlineCode, orderedList, bulletList).
  void toggleCodeBlock() => toggleFormat(FormatType.codeBlock);

  /// Toggles ordered list formatting.
  /// Ordered list is mutually exclusive with other exclusive formats
  /// (blockquote, inlineCode, codeBlock, bulletList).
  void toggleOrderedList() => toggleFormat(FormatType.orderedList);

  /// Toggles bullet list formatting.
  /// Bullet list is mutually exclusive with other exclusive formats
  /// (blockquote, inlineCode, codeBlock, orderedList).
  void toggleBulletList() => toggleFormat(FormatType.bulletList);

  /// Updates active formats based on cursor position or selection.
  ///
  /// When the cursor moves into a formatted region, the active formats
  /// are updated to match that region's formats.
  /// 
  /// When text is selected, detects formats that are common to ALL spans
  /// within the selection range. This ensures the toolbar accurately reflects
  /// which formats are applied to the entire selection.
  /// 
  /// Note: Link format is excluded from active formats because links should
  /// only be created explicitly (via paste or link dialog), not by typing.
  void updateActiveFormatsFromCursor() {
    // If we're in the middle of a list/blockquote continuation, don't clear formats
    if (_preserveFormatsOnUpdate) {
      return;
    }
    
    // Preserve inline formats before clearing - these should persist across line changes
    // in lists/blockquotes unless explicitly toggled off
    final preservedInlineFormats = Set<FormatType>.from(_activeFormats.where(
      (f) => f == FormatType.bold || 
             f == FormatType.italic || 
             f == FormatType.underline || 
             f == FormatType.strikethrough ||
             f == FormatType.inlineCode
    ));
    
    _activeFormats.clear();
    
    if (selection.isCollapsed) {
      // No selection - detect formats at cursor position
      final position = selection.baseOffset;
      
      // Find all spans that contain the cursor position
      bool foundSpansAtPosition = false;
      for (final span in _spans) {
        if (span.contains(position) || 
            (position > 0 && span.contains(position - 1))) {
          foundSpansAtPosition = true;
          // Add all formats except link - links should not be extended by typing
          final formatsToAdd = Set<FormatType>.from(span.formats)
            ..remove(FormatType.link);
          _activeFormats.addAll(formatsToAdd);
        }
      }
      
      // If no spans found at cursor position and we're in a list/blockquote,
      // restore preserved inline formats to allow continued formatting on new lines
      if (!foundSpansAtPosition && preservedInlineFormats.isNotEmpty) {
        // Check if we're at the start of a line with a list/blockquote prefix
        final currentText = text;
        if (currentText.isNotEmpty && position <= currentText.length) {
          final lineStart = currentText.lastIndexOf('\n', position > 0 ? position - 1 : 0) + 1;
          final lineContent = currentText.substring(lineStart);
          
          // Check if line starts with a list or blockquote prefix
          final hasListPrefix = lineContent.startsWith('- ') || 
                                lineContent.startsWith('> ') ||
                                RegExp(r'^\d+\. ').hasMatch(lineContent);
          
          if (hasListPrefix) {
            // Calculate the marker length
            int markerLength = 0;
            if (lineContent.startsWith('> ')) {
              markerLength = 2;
              final afterQuote = lineContent.substring(2);
              if (afterQuote.startsWith('- ')) {
                markerLength += 2;
              } else {
                final orderedMatch = RegExp(r'^\d+\. ').firstMatch(afterQuote);
                if (orderedMatch != null) {
                  markerLength += orderedMatch.end;
                }
              }
            } else if (lineContent.startsWith('- ')) {
              markerLength = 2;
            } else {
              final orderedMatch = RegExp(r'^\d+\. ').firstMatch(lineContent);
              if (orderedMatch != null) {
                markerLength = orderedMatch.end;
              }
            }
            
            // If cursor is right after the marker (at content start), restore formats
            final markerEnd = lineStart + markerLength;
            if (position == markerEnd) {
              _activeFormats.addAll(preservedInlineFormats);
            }
          }
        }
      }
    } else {
      // Has selection - detect formats common to the entire selection
      final selectionStart = selection.start;
      final selectionEnd = selection.end;
      
      // Find all spans that overlap with the selection
      final overlappingSpans = _spans.where(
        (span) => span.overlaps(selectionStart, selectionEnd)
      ).toList();
      
      if (overlappingSpans.isEmpty) {
        // No formatted spans in selection
        return;
      }
      
      // Check if the selection is fully covered by formatted spans
      // and find formats that are common to ALL parts of the selection
      final Set<FormatType> commonFormats = {};
      
      // Start with all possible formats from the first overlapping span
      bool isFirstSpan = true;
      
      for (final span in overlappingSpans) {
        final spanFormats = Set<FormatType>.from(span.formats)
          ..remove(FormatType.link);
        
        if (isFirstSpan) {
          commonFormats.addAll(spanFormats);
          isFirstSpan = false;
        } else {
          // Keep only formats that exist in both sets
          commonFormats.retainAll(spanFormats);
        }
      }
      
      // Verify that the entire selection is covered by spans with these formats
      // by checking if there are any gaps in coverage
      if (commonFormats.isNotEmpty) {
        final coveredRanges = <({int start, int end})>[];
        for (final span in overlappingSpans) {
          // Only consider spans that have all the common formats
          if (commonFormats.every((f) => span.formats.contains(f))) {
            coveredRanges.add((
              start: span.start.clamp(selectionStart, selectionEnd),
              end: span.end.clamp(selectionStart, selectionEnd),
            ));
          }
        }
        
        // Sort and merge overlapping ranges
        coveredRanges.sort((a, b) => a.start.compareTo(b.start));
        
        // Check if ranges fully cover the selection
        int coveredUntil = selectionStart;
        bool fullyCovered = true;
        
        for (final range in coveredRanges) {
          if (range.start > coveredUntil) {
            // Gap found - selection is not fully covered
            fullyCovered = false;
            break;
          }
          coveredUntil = coveredUntil > range.end ? coveredUntil : range.end;
        }
        
        if (coveredUntil < selectionEnd) {
          fullyCovered = false;
        }
        
        if (fullyCovered) {
          _activeFormats.addAll(commonFormats);
        }
      }
    }
  }

  @override
  set value(TextEditingValue newValue) {
    if (_isInternalUpdate) {
      super.value = newValue;
      return;
    }

    final oldText = text;
    final oldSelection = selection;
    
    super.value = newValue;
    
    // Handle text changes
    if (newValue.text != oldText) {
      _handleTextChange(oldText, newValue.text, oldSelection, newValue.selection);
    } else if (newValue.selection != oldSelection) {
      // Selection changed without text change - update active formats
      updateActiveFormatsFromCursor();
      notifyListeners();
    }
  }

  /// Handles text changes and updates spans accordingly.
  void _handleTextChange(
    String oldText,
    String newText,
    TextSelection oldSelection,
    TextSelection newSelection,
  ) {
    final lengthDiff = newText.length - oldText.length;
    
    // Check for paste-to-link: if text was selected and replaced with a URL,
    // restore the original text and create a link instead
    // _Requirements: 2.11_
    if (!oldSelection.isCollapsed && oldSelection.isValid) {
      final selStart = oldSelection.start.clamp(0, oldText.length);
      final selEnd = oldSelection.end.clamp(0, oldText.length);
      final selectedText = oldText.substring(selStart, selEnd);
      
      // Calculate what was inserted (the replacement text)
      final replacementEnd = (selStart + (newText.length - oldText.length + (selEnd - selStart))).clamp(0, newText.length);
      if (selStart <= replacementEnd && replacementEnd <= newText.length) {
        final replacementText = newText.substring(selStart, replacementEnd);
        
        // Check if the replacement text is a URL
        if (replacementText.isNotEmpty && _isUrl(replacementText.trim())) {
          // This is a paste-to-link scenario!
          // Restore the original text and create a link span
          _handlePasteToLink(oldText, selectedText, replacementText.trim(), selStart, selEnd);
          return;
        }
      }
    }
    
    if (lengthDiff > 0) {
      // Text was added
      // Safety check: ensure insertPosition is valid
      final insertPosition = oldSelection.baseOffset.clamp(0, oldText.length);
      final insertedLength = lengthDiff;
      
      // Safety check: ensure we don't go out of bounds
      final insertEnd = (insertPosition + insertedLength).clamp(0, newText.length);
      if (insertPosition > insertEnd) return;
      
      final insertedText = newText.substring(insertPosition, insertEnd);
      
      // Shift existing spans that come after the insertion point
      _shiftSpansAfter(insertPosition, insertedLength);
      
      // If we have active formats, create spans for the inserted text (excluding emojis and list markers)
      if (_activeFormats.isNotEmpty) {
        // Get content ranges excluding list markers
        final contentRanges = _adjustRangeForListMarkers(insertPosition, insertEnd);
        
        // Apply formatting only to content ranges (excluding list markers)
        for (final range in contentRanges) {
          // Get non-emoji ranges within this content range
          final nonEmojiRanges = FormatPatterns.getNonEmojiRanges(
            newText, 
            range.start, 
            range.end,
          );
          
          // Apply formatting only to non-emoji ranges
          for (final emojiRange in nonEmojiRanges) {
            _addSpan(RichTextSpan(
              start: emojiRange.start,
              end: emojiRange.end,
              formats: Set.from(_activeFormats),
            ));
          }
        }
      }
      
      // Check if a list marker was just completed and remove any formatting from it
      _removeFormattingFromCompletedListMarker(newText, insertEnd);
      
      // Check for URLs in pasted/inserted text (more than 1 character suggests paste)
      if (insertedLength > 1) {
        _autoDetectAndFormatUrls(insertedText, insertPosition);
      }
      
      // Check if a newline was inserted and continue list/blockquote formatting
      if (insertedText == '\n') {
        _handleNewlineContinuation(newText, insertPosition);
      }
      
      // Check if an inline markdown pattern was just completed (e.g., *text* for bold)
      // and convert it to a span-based format
      _checkAndConvertInlineMarkdown(newText, insertEnd);
    } else if (lengthDiff < 0) {
      // Text was deleted
      // Safety check: ensure deleteStart is valid
      final deleteStart = newSelection.baseOffset.clamp(0, newText.length);
      final deleteEnd = (deleteStart - lengthDiff).clamp(0, oldText.length);
      
      // Check if backspace was pressed at the beginning of a list item content
      // (right after the prefix like "- " or "1. ")
      if (_handleBackspaceOnListPrefix(oldText, newText, oldSelection, newSelection)) {
        return; // Backspace handling took care of everything
      }
      
      // Remove or adjust spans in the deleted range
      _removeSpansInRange(deleteStart, deleteEnd);
      
      // Shift spans after the deletion
      _shiftSpansAfter(deleteEnd, lengthDiff);
    }
    
    // Merge adjacent spans with the same formats
    _mergeAdjacentSpans();
  }
  
  /// Removes formatting from a list marker that was just completed.
  /// 
  /// This is called after text insertion to check if a list marker (like "- " or "1. ")
  /// was just completed. If so, any formatting spans covering the marker are removed
  /// to ensure list markers remain unformatted.
  void _removeFormattingFromCompletedListMarker(String currentText, int cursorPosition) {
    if (currentText.isEmpty || cursorPosition <= 0) return;
    
    // Find the start of the current line
    final lineStart = currentText.lastIndexOf('\n', cursorPosition > 0 ? cursorPosition - 1 : 0) + 1;
    final lineContent = currentText.substring(lineStart);
    
    // Check for list markers at the start of the line
    int markerLength = 0;
    String remainingContent = lineContent;
    
    // Check for blockquote prefix "> "
    if (remainingContent.startsWith('> ')) {
      markerLength += 2;
      remainingContent = remainingContent.substring(2);
    }
    
    // Check for bullet list marker "- "
    if (remainingContent.startsWith('- ')) {
      markerLength += 2;
    } else {
      // Check for ordered list marker "N. "
      final orderedMatch = RegExp(r'^\d+\. ').firstMatch(remainingContent);
      if (orderedMatch != null) {
        markerLength += orderedMatch.end;
      }
    }
    
    // If a marker was found and the cursor is at or just after the marker end
    if (markerLength > 0) {
      final markerEnd = lineStart + markerLength;
      
      // Only process if cursor is at or near the marker end (just completed typing the marker)
      if (cursorPosition >= markerEnd - 1 && cursorPosition <= markerEnd + 1) {
        // Remove all formatting from the marker range
        _removeAllFormatsFromRange(lineStart, markerEnd);
      }
    }
  }
  
  /// Removes all formatting from a range of text.
  /// 
  /// This is used to strip formatting from list markers.
  void _removeAllFormatsFromRange(int start, int end) {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      if (span.overlaps(start, end)) {
        toRemove.add(span);
        
        // Keep parts of the span that are outside the range
        if (span.start < start) {
          toAdd.add(RichTextSpan(
            start: span.start,
            end: start,
            formats: span.formats,
            url: span.url,
          ));
        }
        if (span.end > end) {
          toAdd.add(RichTextSpan(
            start: end,
            end: span.end,
            formats: span.formats,
            url: span.url,
          ));
        }
      }
    }
    
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
  }
  
  /// Handles backspace at the beginning of a list item content.
  /// 
  /// When the user presses backspace right after a list prefix (e.g., "- " or "1. "),
  /// this method removes the entire prefix instead of just one character.
  /// 
  /// Returns true if the backspace was handled (prefix was removed), false otherwise.
  bool _handleBackspaceOnListPrefix(
    String oldText,
    String newText,
    TextSelection oldSelection,
    TextSelection newSelection,
  ) {
    // Only handle single character deletion (backspace)
    if (oldText.length - newText.length != 1) return false;
    
    final deletePos = newSelection.baseOffset;
    
    // Find the start of the current line in the NEW text
    final lineStart = newText.lastIndexOf('\n', deletePos > 0 ? deletePos - 1 : 0) + 1;
    
    // Get the current line content after deletion
    int lineEnd = newText.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = newText.length;
    final currentLine = newText.substring(lineStart, lineEnd);
    
    // Check if the line now shows a partial/broken list prefix
    // This happens when user backspaces and reveals the raw "-" or "N."
    
    // Check for bullet list: line is just "-" or starts with "- " but cursor is right after "-"
    if (currentLine == '-' || (currentLine.startsWith('-') && !currentLine.startsWith('- '))) {
      // User backspaced and revealed the raw "-", remove it entirely
      _removeLinePrefixAfterBackspace(newText, lineStart, '-');
      return true;
    }
    
    // Check for ordered list: line is just "N." or "N" where N is a number
    final orderedPartialMatch = RegExp(r'^(\d+)\.?$').firstMatch(currentLine);
    if (orderedPartialMatch != null) {
      // User backspaced and revealed the raw "N." or "N", remove it entirely
      _removeLinePrefixAfterBackspace(newText, lineStart, currentLine);
      return true;
    }
    
    // Check for blockquote: line is just ">" 
    if (currentLine == '>') {
      // User backspaced and revealed the raw ">", remove it entirely
      _removeLinePrefixAfterBackspace(newText, lineStart, '>');
      return true;
    }
    
    return false;
  }
  
  /// Removes a line prefix after backspace revealed it.
  /// 
  /// This is called when the user backspaces and reveals a raw list/quote prefix
  /// that should be removed entirely.
  void _removeLinePrefixAfterBackspace(String currentText, int lineStart, String prefix) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textNow = text;
      
      // Verify the prefix is still there
      if (lineStart > textNow.length) return;
      
      int lineEnd = textNow.indexOf('\n', lineStart);
      if (lineEnd == -1) lineEnd = textNow.length;
      final currentLine = textNow.substring(lineStart, lineEnd);
      
      // Check if the line still has the prefix we want to remove
      if (!currentLine.startsWith(prefix)) return;
      
      // Calculate how much to remove
      final removeLength = prefix.length;
      
      // Build new text without the prefix
      final newText = textNow.substring(0, lineStart) + 
          currentLine.substring(removeLength) +
          textNow.substring(lineEnd);
      
      // Adjust spans
      _shiftSpansAfter(lineStart + removeLength, -removeLength);
      _mergeAdjacentSpans();
      
      // Set the new text with cursor at the line start
      _setTextDirectly(newText, lineStart);
      
      // Notify listeners so the UI updates (toolbar shows format as inactive)
      notifyListeners();
    });
  }

  // Regex patterns for detecting line-level formats
  static final RegExp _bulletLinePattern = RegExp(r'^- (.*)$');
  static final RegExp _orderedLinePattern = RegExp(r'^(\d+)\. (.*)$');
  static final RegExp _blockquoteLinePattern = RegExp(r'^> (.*)$');
  // Pattern for ordered list inside blockquote: "> N. content"
  static final RegExp _blockquoteOrderedLinePattern = RegExp(r'^> (\d+)\. (.*)$');
  // Pattern for bullet list inside blockquote: "> - content"
  static final RegExp _blockquoteBulletLinePattern = RegExp(r'^> - (.*)$');

  /// Handles newline continuation for bullet lists, ordered lists, and blockquotes.
  ///
  /// When the user presses Enter at the end of a list item or blockquote line,
  /// the next line automatically gets the same prefix. If the current line's
  /// content is empty (just the prefix), the prefix is removed instead, exiting
  /// the list/blockquote mode.
  /// 
  /// For code blocks (```), triple-enter on empty lines inside the code block
  /// will close the code block by adding the closing ``` marker.
  /// 
  /// For lists (ordered/bullet), double-enter on an empty list item will
  /// remove the marker and exit the list.
  /// 
  /// _Requirements: 2.22, 2.23, 2.24, 2.25_
  void _handleNewlineContinuation(String currentText, int newlinePosition) {
    // Guard against invalid position
    if (newlinePosition <= 0 || newlinePosition > currentText.length) return;
    
    // Find the line before the newline
    final searchPos = newlinePosition - 1;
    final lineStart = searchPos > 0 ? currentText.lastIndexOf('\n', searchPos) + 1 : 0;
    final previousLine = currentText.substring(lineStart, newlinePosition);

    String? continuationPrefix;
    
    // Check if we're inside a code block and the line is empty
    // Use triple-enter exit pattern for code blocks
    if (_isInsideCodeBlock(currentText, newlinePosition) && previousLine.isEmpty) {
      // Increment consecutive empty enter count
      _consecutiveEmptyEnterCount++;
      
      if (_consecutiveEmptyEnterCount >= 2) {
        // Triple-enter detected (2 previous empty lines + current) - close the code block
        _closeCodeBlock(currentText, newlinePosition);
        _consecutiveEmptyEnterCount = 0;
        return;
      }
      // Not enough consecutive enters yet - continue normally (add newline)
      return;
    }

    // Check ordered list inside blockquote: "> N. content" (must check before plain blockquote)
    final blockquoteOrderedMatch = _blockquoteOrderedLinePattern.firstMatch(previousLine);
    if (blockquoteOrderedMatch != null) {
      final content = blockquoteOrderedMatch.group(2) ?? '';
      final currentNumber = int.tryParse(blockquoteOrderedMatch.group(1) ?? '1') ?? 1;
      if (content.isEmpty) {
        // Empty ordered item inside blockquote - use double-enter exit pattern
        _consecutiveEmptyEnterCount++;
        
        if (_consecutiveEmptyEnterCount >= 2) {
          // Double-enter detected — replace with just blockquote prefix
          _replaceLinePrefixAndContinue(
            currentText, 
            lineStart, 
            newlinePosition, 
            '> $currentNumber. ', 
            '> ',
          );
          _consecutiveEmptyEnterCount = 0;
          return;
        }
        // First enter on empty item - continue with same prefix
        continuationPrefix = '> $currentNumber. ';
      } else {
        // Non-empty content - reset counter and continue
        _consecutiveEmptyEnterCount = 0;
        continuationPrefix = '> ${currentNumber + 1}. ';
      }
    }

    // Check bullet list inside blockquote: "> - content" (must check before plain blockquote)
    if (continuationPrefix == null) {
      final blockquoteBulletMatch = _blockquoteBulletLinePattern.firstMatch(previousLine);
      if (blockquoteBulletMatch != null) {
        final content = blockquoteBulletMatch.group(1) ?? '';
        if (content.isEmpty) {
          // Empty bullet item inside blockquote - use double-enter exit pattern
          _consecutiveEmptyEnterCount++;
          
          if (_consecutiveEmptyEnterCount >= 2) {
            // Double-enter detected — replace with just blockquote prefix
            _replaceLinePrefixAndContinue(
              currentText, 
              lineStart, 
              newlinePosition, 
              '> - ', 
              '> ',
            );
            _consecutiveEmptyEnterCount = 0;
            return;
          }
          // First enter on empty item - continue with same prefix
          continuationPrefix = '> - ';
        } else {
          // Non-empty content - reset counter and continue
          _consecutiveEmptyEnterCount = 0;
          continuationPrefix = '> - ';
        }
      }
    }

    // Check bullet list: "- content"
    if (continuationPrefix == null) {
      final bulletMatch = _bulletLinePattern.firstMatch(previousLine);
      if (bulletMatch != null) {
        final content = bulletMatch.group(1) ?? '';
        if (content.isEmpty) {
          // Empty bullet item - single enter exits the list
          _removeLinePrefixAndNewline(currentText, lineStart, newlinePosition, '- ');
          _consecutiveEmptyEnterCount = 0;
          return;
        } else {
          // Non-empty content - reset counter and continue
          _consecutiveEmptyEnterCount = 0;
          continuationPrefix = '- ';
        }
      }
    }

    // Check ordered list: "N. content"
    if (continuationPrefix == null) {
      final orderedMatch = _orderedLinePattern.firstMatch(previousLine);
      if (orderedMatch != null) {
        final content = orderedMatch.group(2) ?? '';
        final currentNumber = int.tryParse(orderedMatch.group(1) ?? '1') ?? 1;
        if (content.isEmpty) {
          // Empty ordered item - single enter exits the list
          _removeLinePrefixAndNewline(currentText, lineStart, newlinePosition, '$currentNumber. ');
          _consecutiveEmptyEnterCount = 0;
          return;
        } else {
          // Non-empty content - reset counter and continue with next number
          _consecutiveEmptyEnterCount = 0;
          continuationPrefix = '${currentNumber + 1}. ';
        }
      }
    }

    // Check blockquote: "> content"
    if (continuationPrefix == null) {
      final blockquoteMatch = _blockquoteLinePattern.firstMatch(previousLine);
      if (blockquoteMatch != null) {
        final content = blockquoteMatch.group(1) ?? '';
        if (content.isEmpty) {
          // Empty blockquote line - use triple-enter exit pattern
          _consecutiveEmptyEnterCount++;
          
          if (_consecutiveEmptyEnterCount >= 2) {
            // Triple-enter detected (2 previous empty lines + current)
            // Check for consecutive empty blockquote lines and remove them
            final consecutiveEmptyLines = _countConsecutiveEmptyBlockquoteLines(currentText, lineStart);
            if (consecutiveEmptyLines >= 1) {
              // Remove all empty blockquote lines and exit
              _removeConsecutiveEmptyBlockquoteLines(currentText, lineStart, newlinePosition, consecutiveEmptyLines);
              _consecutiveEmptyEnterCount = 0;
              return;
            }
          }
          // Not enough consecutive enters yet — continue with blockquote prefix
          continuationPrefix = '> ';
        } else {
          // Non-empty content - reset counter and continue
          _consecutiveEmptyEnterCount = 0;
          continuationPrefix = '> ';
        }
      }
    }

    // Capture current inline formats to preserve them on the new line
    // Only preserve inline formats (bold, italic, underline, strikethrough, inlineCode)
    // Exclude line-level formats and link format
    Set<FormatType> inlineFormatsToPreserve = Set<FormatType>.from(_activeFormats.where(
      (f) => f == FormatType.bold || 
             f == FormatType.italic || 
             f == FormatType.underline || 
             f == FormatType.strikethrough ||
             f == FormatType.inlineCode
    ));
    
    // If no active inline formats, check if the previous line's content has formatting
    // This handles the case where the user was typing formatted text and pressed Enter
    if (inlineFormatsToPreserve.isEmpty) {
      // Check spans at the end of the previous line (just before the newline)
      final checkPosition = newlinePosition > 0 ? newlinePosition - 1 : 0;
      for (final span in _spans) {
        if (span.contains(checkPosition)) {
          // Add inline formats from this span
          for (final format in span.formats) {
            if (format == FormatType.bold || 
                format == FormatType.italic || 
                format == FormatType.underline || 
                format == FormatType.strikethrough ||
                format == FormatType.inlineCode) {
              inlineFormatsToPreserve.add(format);
            }
          }
        }
      }
    }
    
    // If no list/blockquote prefix but we have inline formats to preserve,
    // just preserve them without inserting any prefix
    if (continuationPrefix == null) {
      // Reset counter when not in a block format
      _consecutiveEmptyEnterCount = 0;
      
      if (inlineFormatsToPreserve.isNotEmpty) {
        // Set flag to preserve formats during any subsequent updateActiveFormatsFromCursor calls
        _preserveFormatsOnUpdate = true;
        
        // Schedule restoration of formats after the current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Restore preserved inline formats
          _activeFormats.addAll(inlineFormatsToPreserve);
          
          // Notify listeners so the UI updates
          notifyListeners();
          
          // Clear the preserve flag after the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preserveFormatsOnUpdate = false;
          });
        });
      }
      return;
    }

    // Set flag to preserve formats during the continuation operation
    // This prevents updateActiveFormatsFromCursor from clearing formats
    _preserveFormatsOnUpdate = true;

    // Defer the text mutation to after the current frame to avoid RangeError
    // from EditableTextState holding a stale selection during the value setter.
    final prefix = continuationPrefix;
    final insertPos = newlinePosition + 1;
    final expectedNewlinePos = newlinePosition;
    final preservedFormats = inlineFormatsToPreserve;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentText = text;
      // Verify the text hasn't changed since we scheduled this
      if (insertPos > currentText.length) {
        _preserveFormatsOnUpdate = false;
        return;
      }
      if (expectedNewlinePos >= currentText.length) {
        _preserveFormatsOnUpdate = false;
        return;
      }
      if (currentText[expectedNewlinePos] != '\n') {
        _preserveFormatsOnUpdate = false;
        return;
      }
      
      // Check if the prefix was already inserted (avoid double insertion)
      if (insertPos + prefix.length <= currentText.length) {
        final existingContent = currentText.substring(insertPos, insertPos + prefix.length);
        if (existingContent == prefix) {
          _preserveFormatsOnUpdate = false;
          return; // Already inserted
        }
      }

      final newText = currentText.substring(0, insertPos) +
          prefix +
          currentText.substring(insertPos);

      _shiftSpansAfter(insertPos, prefix.length);
      _mergeAdjacentSpans();

      final newCursorPos = insertPos + prefix.length;
      _setTextDirectly(newText, newCursorPos);
      
      // Restore preserved inline formats so they continue on the new line
      // This ensures bold/italic/etc. remain active after pressing Enter
      if (preservedFormats.isNotEmpty) {
        _activeFormats.addAll(preservedFormats);
      }
      
      // Notify listeners so the UI updates with the new line-level format
      // This ensures the toolbar shows the list/blockquote as active
      notifyListeners();
      
      // Clear the preserve flag after the current frame to allow any pending
      // updateActiveFormatsFromCursor calls to be skipped
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preserveFormatsOnUpdate = false;
      });
    });
  }
  
  /// Checks if the cursor position is inside a code block.
  /// 
  /// A code block is delimited by ``` markers. This method counts the number
  /// of ``` markers before the position to determine if we're inside a code block.
  bool _isInsideCodeBlock(String text, int position) {
    int codeBlockCount = 0;
    int searchPos = 0;
    while (searchPos < position) {
      final markerPos = text.indexOf('```', searchPos);
      if (markerPos == -1 || markerPos >= position) break;
      codeBlockCount++;
      searchPos = markerPos + 3;
    }
    return codeBlockCount % 2 == 1;
  }
  
  /// Checks if an inline markdown pattern was just completed and converts it to a span.
  /// 
  /// This is called after text insertion to detect patterns like *text*, _text_, etc.
  /// When a closing marker is typed, the pattern is converted to a span-based format
  /// (removing the markers and creating a formatting span), which allows proper
  /// editing behavior (backspace removes characters, not markers).
  /// 
  /// Supported patterns:
  /// - *text* → bold
  /// - _text_ → italic
  /// - ~~text~~ → strikethrough
  /// - `text` → inline code
  /// - <u>text</u> → underline
  void _checkAndConvertInlineMarkdown(String currentText, int cursorPosition) {
    if (currentText.isEmpty || cursorPosition <= 0) return;
    
    // First, check for code block pattern: ```text```
    // This must be checked before inline patterns to avoid conflicts
    final codeBlockPattern = RegExp(r'```([^`]+)```');
    for (final match in codeBlockPattern.allMatches(currentText)) {
      if (match.end == cursorPosition) {
        // Found a completed code block pattern - convert it
        _convertMarkdownPatternToSpan(
          currentText,
          match.start,
          match.end,
          match.group(1) ?? '',
          FormatType.codeBlock,
          3, // prefix length: ```
          3, // suffix length: ```
        );
        return;
      }
    }
    
    // Define inline format patterns with their markers and opening markers for nesting check
    final inlinePatterns = <({RegExp pattern, FormatType format, int prefixLen, int suffixLen, String openMarker})>[
      (pattern: RegExp(r'\*\*([^*]+)\*\*'), format: FormatType.bold, prefixLen: 2, suffixLen: 2, openMarker: '**'),
      (pattern: RegExp(r'(?<!_)_([^_]+)_(?!_)'), format: FormatType.italic, prefixLen: 1, suffixLen: 1, openMarker: '_'),
      (pattern: RegExp(r'~~([^~]+)~~'), format: FormatType.strikethrough, prefixLen: 2, suffixLen: 2, openMarker: '~~'),
      (pattern: RegExp(r'(?<!`)`([^`]+)`(?!`)'), format: FormatType.inlineCode, prefixLen: 1, suffixLen: 1, openMarker: '`'),
      (pattern: RegExp(r'<u>(.+?)</u>'), format: FormatType.underline, prefixLen: 3, suffixLen: 4, openMarker: '<u>'),
    ];
    
    // Check each pattern
    for (final patternInfo in inlinePatterns) {
      // Look for matches that end at or near the cursor position
      for (final match in patternInfo.pattern.allMatches(currentText)) {
        // Check if the cursor is right after the closing marker
        if (match.end == cursorPosition) {
          // Check if this pattern is inside an incomplete outer pattern
          // by looking for unmatched opening markers before the match
          if (_isInsideIncompletePattern(currentText, match.start, patternInfo.openMarker)) {
            continue; // Skip this match - it's inside an incomplete outer pattern
          }
          
          // Found a completed pattern - convert it to a span
          _convertMarkdownPatternToSpan(
            currentText,
            match.start,
            match.end,
            match.group(1) ?? '',
            patternInfo.format,
            patternInfo.prefixLen,
            patternInfo.suffixLen,
          );
          return; // Only convert one pattern at a time
        }
      }
    }
  }
  
  /// Checks if a position is inside an incomplete outer markdown pattern.
  /// 
  /// This prevents converting inner patterns like _text_ when they're inside
  /// an incomplete outer pattern like *_text_ (missing closing *).
  /// 
  /// The logic: count markers of each type BEFORE the match start position.
  /// If the count is odd, there's an unmatched opening marker, meaning we're
  /// inside an incomplete pattern of that type.
  bool _isInsideIncompletePattern(String text, int matchStart, String currentMarker) {
    // Only check the text BEFORE the match start
    final textBeforeMatch = text.substring(0, matchStart);
    
    // Check for each type of marker
    final markerTypes = [
      (marker: '*', closing: '*'),
      (marker: '_', closing: '_'),
      (marker: '~~', closing: '~~'),
      (marker: '`', closing: '`'),
      (marker: '<u>', closing: '</u>'),
    ];
    
    for (final markerType in markerTypes) {
      // Skip checking for the same marker type as the current pattern
      if (markerType.marker == currentMarker) continue;
      
      // Count occurrences of this marker in text before the match
      int count = 0;
      int searchPos = 0;
      
      while (searchPos < textBeforeMatch.length) {
        final markerPos = textBeforeMatch.indexOf(markerType.marker, searchPos);
        if (markerPos == -1) break;
        
        // For single char markers (* and _), make sure it's not part of a double marker
        // and not inside the content of another pattern
        bool shouldCount = true;
        
        if (markerType.marker == '*') {
          // Check it's not part of ** (which we don't use anymore, but be safe)
          if (markerPos > 0 && textBeforeMatch[markerPos - 1] == '*') {
            shouldCount = false;
          }
          if (markerPos + 1 < textBeforeMatch.length && textBeforeMatch[markerPos + 1] == '*') {
            shouldCount = false;
          }
        }
        
        if (markerType.marker == '_') {
          // Check it's not part of __ 
          if (markerPos > 0 && textBeforeMatch[markerPos - 1] == '_') {
            shouldCount = false;
          }
          if (markerPos + 1 < textBeforeMatch.length && textBeforeMatch[markerPos + 1] == '_') {
            shouldCount = false;
          }
        }
        
        if (shouldCount) {
          count++;
        }
        
        searchPos = markerPos + markerType.marker.length;
      }
      
      // If count is odd, there's an unmatched opening marker before our match
      // This means we're inside an incomplete pattern
      if (count % 2 == 1) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Converts a markdown pattern to a span-based format.
  /// 
  /// This removes the markdown markers from the text and creates a formatting span
  /// for the content. For example, *hello* becomes "hello" with a bold span.
  /// 
  /// For nested formats like *_hello_*, this recursively parses the inner content
  /// and combines the formats. The result would be "hello" with both bold and italic.
  void _convertMarkdownPatternToSpan(
    String currentText,
    int matchStart,
    int matchEnd,
    String content,
    FormatType formatType,
    int prefixLen,
    int suffixLen,
  ) {
    // Defer the conversion to avoid issues with text change handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textNow = text;
      
      // Verify the pattern is still there (text might have changed)
      if (matchEnd > textNow.length) return;
      
      // Parse nested formats in the content and get the stripped content + formats
      final nestedResult = _parseNestedMarkdownContent(content);
      final strippedContent = nestedResult.text;
      final nestedFormats = nestedResult.formats;
      
      // Combine the outer format with any nested formats
      final combinedFormats = <FormatType>{formatType, ...nestedFormats};
      
      // Calculate the new text without markers
      final beforePattern = textNow.substring(0, matchStart);
      final afterPattern = textNow.substring(matchEnd);
      final newText = beforePattern + strippedContent + afterPattern;
      
      // Calculate the new cursor position (at the end of the content)
      final newCursorPos = matchStart + strippedContent.length;
      
      // Collect existing spans that overlap with the pattern area
      // and preserve their formats (for cases where user applied format via toolbar)
      final existingFormats = <FormatType>{};
      for (final span in _spans) {
        if (span.overlaps(matchStart + prefixLen, matchEnd - suffixLen)) {
          existingFormats.addAll(span.formats);
        }
      }
      
      // Combine all formats
      combinedFormats.addAll(existingFormats);
      
      // Adjust existing spans
      // 1. Remove any spans that overlap with the pattern
      _removeSpansInRange(matchStart, matchEnd);
      
      // 2. Shift spans after the pattern by the difference in length
      final lengthDiff = newText.length - textNow.length;
      _shiftSpansAfter(matchEnd, lengthDiff);
      
      // 3. Add a new span for the formatted content with all combined formats
      if (strippedContent.isNotEmpty) {
        _addSpan(RichTextSpan(
          start: matchStart,
          end: matchStart + strippedContent.length,
          formats: combinedFormats,
        ));
      }
      
      _mergeAdjacentSpans();
      
      // Update the text
      _setTextDirectly(newText, newCursorPos);
      
      // Update active formats to reflect the new state
      updateActiveFormatsFromCursor();
      notifyListeners();
    });
  }
  
  /// Parses nested markdown content and returns the stripped text with collected formats.
  /// 
  /// For example, "_hello_" returns ("hello", {italic})
  /// And "*_hello_*" would first strip outer *, then this parses "_hello_" to get ("hello", {italic})
  ({String text, Set<FormatType> formats}) _parseNestedMarkdownContent(String content) {
    String currentContent = content;
    final collectedFormats = <FormatType>{};
    
    // Define inline format patterns
    final inlinePatterns = <({RegExp pattern, FormatType format})>[
      (pattern: RegExp(r'^(?<!\*)\*([^*]+)\*(?!\*)$'), format: FormatType.bold),
      (pattern: RegExp(r'^(?<!_)_([^_]+)_(?!_)$'), format: FormatType.italic),
      (pattern: RegExp(r'^~~([^~]+)~~$'), format: FormatType.strikethrough),
      (pattern: RegExp(r'^`([^`]+)`$'), format: FormatType.inlineCode),
      (pattern: RegExp(r'^<u>(.+?)</u>$'), format: FormatType.underline),
    ];
    
    // Keep stripping outer formats until no more matches
    bool foundMatch = true;
    while (foundMatch) {
      foundMatch = false;
      for (final patternInfo in inlinePatterns) {
        final match = patternInfo.pattern.firstMatch(currentContent);
        if (match != null) {
          collectedFormats.add(patternInfo.format);
          currentContent = match.group(1) ?? currentContent;
          foundMatch = true;
          break; // Start over with the new content
        }
      }
    }
    
    return (text: currentContent, formats: collectedFormats);
  }
  
  /// Closes a code block by adding the closing ``` marker.
  /// 
  /// This is called when the user presses Enter on an empty line inside a code block,
  /// which triggers the double-enter exit behavior.
  void _closeCodeBlock(String currentText, int newlinePosition) {
    // Defer the text mutation to after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentText = text;
      final insertPos = newlinePosition + 1;
      
      // Verify bounds are still valid
      if (insertPos > currentText.length) return;
      
      // Add closing ``` marker
      final newText = currentText.substring(0, insertPos) +
          '```\n' +
          currentText.substring(insertPos);
      
      _shiftSpansAfter(insertPos, 4); // "```\n" is 4 characters
      _mergeAdjacentSpans();
      
      // Position cursor after the closing marker
      final newCursorPos = insertPos + 4;
      _setTextDirectly(newText, newCursorPos);
      
      // Remove codeBlock from active formats
      _activeFormats.remove(FormatType.codeBlock);
      notifyListeners();
    });
  }

  /// Removes the line prefix and the trailing newline when the user presses
  /// Enter on an empty list item or blockquote, effectively exiting the mode.
  void _removeLinePrefixAndNewline(
    String currentText,
    int lineStart,
    int newlinePosition,
    String prefix,
  ) {
    final removeStart = lineStart;
    final removeEnd = newlinePosition + 1;
    final expectedContent = prefix; // The content we expect to remove (e.g., "1. ")

    // Defer the text mutation to after the current frame to avoid RangeError.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentText = text;
      
      // Verify bounds are still valid
      if (removeStart >= currentText.length) return;
      if (removeEnd > currentText.length) return;
      if (removeStart >= removeEnd) return;
      
      // Verify the content we're about to remove is what we expect
      // This prevents removing wrong content if text changed between scheduling and execution
      final contentToRemove = currentText.substring(removeStart, removeEnd);
      if (!contentToRemove.startsWith(expectedContent)) return;

      final newText = currentText.substring(0, removeStart) +
          currentText.substring(removeEnd);

      final removedLength = removeEnd - removeStart;

      _removeSpansInRange(removeStart, removeEnd);
      _shiftSpansAfter(removeEnd, -removedLength);
      _mergeAdjacentSpans();

      _setTextDirectly(newText, removeStart);
      
      // Notify listeners so the UI updates (toolbar shows format as inactive)
      notifyListeners();
    });
  }

  /// Replaces a line prefix with a new prefix in a single atomic operation.
  /// Used when exiting a nested list inside a blockquote to keep the blockquote.
  /// This combines remove and add into one callback to avoid selection sync issues.
  void _replaceLinePrefixAndContinue(
    String currentText,
    int lineStart,
    int newlinePosition,
    String oldPrefix,
    String newPrefix,
  ) {
    final removeStart = lineStart;
    final removeEnd = newlinePosition + 1;

    // Defer the text mutation to after the current frame to avoid RangeError.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentText = text;
      
      // Verify bounds are still valid
      if (removeStart >= currentText.length) return;
      if (removeEnd > currentText.length) return;
      if (removeStart >= removeEnd) return;
      
      // Verify the content we're about to remove is what we expect
      final contentToRemove = currentText.substring(removeStart, removeEnd);
      if (!contentToRemove.startsWith(oldPrefix)) return;

      // Remove the old prefix line and add the new prefix
      final newText = currentText.substring(0, removeStart) +
          newPrefix +
          currentText.substring(removeEnd);

      final lengthDiff = newPrefix.length - (removeEnd - removeStart);

      _removeSpansInRange(removeStart, removeEnd);
      _shiftSpansAfter(removeEnd, lengthDiff);
      _mergeAdjacentSpans();

      final newCursorPos = removeStart + newPrefix.length;
      _setTextDirectly(newText, newCursorPos);
      
      // Notify listeners so the UI updates
      notifyListeners();
    });
  }

  /// Counts the number of consecutive empty blockquote lines before [lineStart].
  /// 
  /// An empty blockquote line is a line that contains only "> " (blockquote prefix
  /// with no content). This is used to implement triple-enter exit behavior.
  int _countConsecutiveEmptyBlockquoteLines(String text, int lineStart) {
    int count = 0;
    int searchPos = lineStart;
    
    // The current line (at lineStart) is already known to be empty blockquote
    // So we start counting from 0 and look backwards
    
    while (searchPos > 0) {
      // Find the start of the previous line
      final prevLineEnd = searchPos - 1; // Position of the newline before current line
      if (prevLineEnd < 0) break;
      
      final prevLineStart = text.lastIndexOf('\n', prevLineEnd > 0 ? prevLineEnd - 1 : 0);
      final actualPrevLineStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
      
      // Get the previous line content
      final prevLine = text.substring(actualPrevLineStart, searchPos - 1);
      
      // Check if it's an empty blockquote line (just "> " with no content)
      if (prevLine == '> ' || prevLine == '>') {
        count++;
        searchPos = actualPrevLineStart;
      } else {
        break;
      }
    }
    
    return count;
  }

  /// Removes consecutive empty blockquote lines when triple-enter is detected.
  /// 
  /// This removes all the empty blockquote lines (including the current one)
  /// and exits blockquote mode.
  void _removeConsecutiveEmptyBlockquoteLines(
    String currentText,
    int lineStart,
    int newlinePosition,
    int emptyLineCount,
  ) {
    // Find the start of the first empty blockquote line
    int removeStart = lineStart;
    int searchPos = lineStart;
    
    for (int i = 0; i < emptyLineCount; i++) {
      if (searchPos <= 0) break;
      final prevLineEnd = searchPos - 1;
      if (prevLineEnd < 0) break;
      
      final prevLineStart = currentText.lastIndexOf('\n', prevLineEnd > 0 ? prevLineEnd - 1 : 0);
      removeStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
      searchPos = removeStart;
    }
    
    final removeEnd = newlinePosition + 1;
    
    // Capture the expected content to verify in the callback
    final expectedRemoveLength = removeEnd - removeStart;
    final capturedRemoveStart = removeStart;
    final capturedRemoveEnd = removeEnd;

    // Defer the text mutation to after the current frame to avoid RangeError.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentText = text;
      
      // Verify bounds are still valid
      if (capturedRemoveStart >= currentText.length) return;
      if (capturedRemoveEnd > currentText.length) return;
      if (capturedRemoveStart >= capturedRemoveEnd) return;
      
      // Verify the length hasn't changed unexpectedly
      final actualRemoveLength = capturedRemoveEnd - capturedRemoveStart;
      if (actualRemoveLength != expectedRemoveLength) return;

      final newText = currentText.substring(0, capturedRemoveStart) +
          currentText.substring(capturedRemoveEnd);

      final removedLength = capturedRemoveEnd - capturedRemoveStart;

      _removeSpansInRange(capturedRemoveStart, capturedRemoveEnd);
      _shiftSpansAfter(capturedRemoveEnd, -removedLength);
      _mergeAdjacentSpans();

      _setTextDirectly(newText, capturedRemoveStart);
      
      // Notify listeners so the UI updates (toolbar shows format as inactive)
      notifyListeners();
    });
  }

  // ============================================================================
  // REUSABLE EXIT METHODS FOR BLOCK FORMATS
  // ============================================================================

  /// Exits ordered/bullet list on second consecutive enter when current line is empty.
  /// 
  /// This method implements the "double-enter exit" pattern for lists:
  /// - First enter creates the next list point
  /// - If enter is pressed again on an empty point, remove the marker and end the list
  /// 
  /// The method tracks consecutive enters on empty lines using [_consecutiveEmptyEnterCount].
  /// When the count reaches 2, it removes the list marker and exits the list.
  /// The counter is reset when non-empty content is typed.
  /// 
  /// Returns true if the list was exited, false otherwise.
  /// 
  /// _Requirements: 2.22, 2.25_
  bool exitOnDoubleEnter() {
    final currentText = text;
    if (currentText.isEmpty) {
      _consecutiveEmptyEnterCount = 0;
      return false;
    }
    
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    
    // Find the start of the current line
    final lineStart = currentText.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;
    
    // Find the end of the current line
    int lineEnd = currentText.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = currentText.length;
    
    // Get the current line
    final currentLine = currentText.substring(lineStart, lineEnd);
    
    // Check if current line is an empty list item (just the marker)
    final bulletMatch = _bulletLinePattern.firstMatch(currentLine);
    final orderedMatch = _orderedLinePattern.firstMatch(currentLine);
    
    bool isEmptyListItem = false;
    String? prefix;
    
    if (bulletMatch != null) {
      final content = bulletMatch.group(1) ?? '';
      if (content.isEmpty) {
        isEmptyListItem = true;
        prefix = '- ';
      }
    } else if (orderedMatch != null) {
      final content = orderedMatch.group(2) ?? '';
      if (content.isEmpty) {
        isEmptyListItem = true;
        final number = orderedMatch.group(1) ?? '1';
        prefix = '$number. ';
      }
    }
    
    // Also check for nested lists inside blockquotes
    if (!isEmptyListItem) {
      final blockquoteBulletMatch = _blockquoteBulletLinePattern.firstMatch(currentLine);
      final blockquoteOrderedMatch = _blockquoteOrderedLinePattern.firstMatch(currentLine);
      
      if (blockquoteBulletMatch != null) {
        final content = blockquoteBulletMatch.group(1) ?? '';
        if (content.isEmpty) {
          isEmptyListItem = true;
          prefix = '> - ';
        }
      } else if (blockquoteOrderedMatch != null) {
        final content = blockquoteOrderedMatch.group(2) ?? '';
        if (content.isEmpty) {
          isEmptyListItem = true;
          final number = blockquoteOrderedMatch.group(1) ?? '1';
          prefix = '> $number. ';
        }
      }
    }
    
    if (!isEmptyListItem) {
      // Not on an empty list item - reset counter
      _consecutiveEmptyEnterCount = 0;
      return false;
    }
    
    // Increment counter for empty list item
    _consecutiveEmptyEnterCount++;
    
    // Check if we've reached the threshold for double-enter exit
    if (_consecutiveEmptyEnterCount >= 2 && prefix != null) {
      // Exit the list - remove the marker
      _removeListMarkerAndExit(lineStart, lineEnd, prefix);
      _consecutiveEmptyEnterCount = 0;
      return true;
    }
    
    return false;
  }
  
  /// Removes the list marker from the current line and exits list mode.
  /// 
  /// For nested lists inside blockquotes, this removes only the list marker
  /// while preserving the blockquote prefix.
  void _removeListMarkerAndExit(int lineStart, int lineEnd, String prefix) {
    final currentText = text;
    
    // Determine what to replace with (empty for regular lists, "> " for nested lists in blockquotes)
    String replacement = '';
    if (prefix.startsWith('> ')) {
      // Nested list inside blockquote - keep the blockquote prefix
      replacement = '> ';
    }
    
    // Calculate the new text
    final newText = currentText.substring(0, lineStart) +
        replacement +
        currentText.substring(lineStart + prefix.length);
    
    final lengthDiff = replacement.length - prefix.length;
    
    // Update spans
    _removeSpansInRange(lineStart, lineStart + prefix.length);
    _shiftSpansAfter(lineStart + prefix.length, lengthDiff);
    _mergeAdjacentSpans();
    
    // Set the new text with cursor at the end of the replacement
    final newCursorPos = lineStart + replacement.length;
    _setTextDirectly(newText, newCursorPos);
    
    notifyListeners();
  }

  /// Exits code/quote block on third consecutive enter when last 2 lines are empty.
  /// 
  /// This method implements the "triple-enter exit" pattern for code and quote blocks:
  /// - First enter goes to next line within the block
  /// - Second enter on empty line goes to next line
  /// - Third enter on empty line ends the block and removes the last 2 empty lines
  /// 
  /// The method tracks consecutive enters on empty lines using [_consecutiveEmptyEnterCount].
  /// When the count reaches 3, it removes the empty lines and exits the block.
  /// The counter is reset when non-empty content is typed.
  /// 
  /// Returns true if the block was exited, false otherwise.
  /// 
  /// _Requirements: 2.23, 2.24, 2.25_
  bool exitOnTripleEnter() {
    final currentText = text;
    if (currentText.isEmpty) {
      _consecutiveEmptyEnterCount = 0;
      return false;
    }
    
    final cursorPos = selection.baseOffset.clamp(0, currentText.length);
    
    // Find the start of the current line
    final lineStart = currentText.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;
    
    // Find the end of the current line
    int lineEnd = currentText.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = currentText.length;
    
    // Get the current line
    final currentLine = currentText.substring(lineStart, lineEnd);
    
    // Check if we're in a code block
    final isInCodeBlock = _isInsideCodeBlock(currentText, cursorPos);
    
    // Check if we're in a blockquote
    final isInBlockquote = currentLine.startsWith('> ') || 
                           (lineStart > 0 && _isLineBlockquote(currentText, lineStart - 1));
    
    if (!isInCodeBlock && !isInBlockquote) {
      _consecutiveEmptyEnterCount = 0;
      return false;
    }
    
    // Check if current line is empty (or just has blockquote prefix)
    bool isEmptyLine = false;
    if (isInCodeBlock) {
      isEmptyLine = currentLine.isEmpty;
    } else if (isInBlockquote) {
      // For blockquote, empty means just "> " or ">"
      isEmptyLine = currentLine == '> ' || currentLine == '>';
    }
    
    if (!isEmptyLine) {
      // Not on an empty line - reset counter
      _consecutiveEmptyEnterCount = 0;
      return false;
    }
    
    // Increment counter for empty line
    _consecutiveEmptyEnterCount++;
    
    // Check if we've reached the threshold for triple-enter exit
    if (_consecutiveEmptyEnterCount >= 3) {
      if (isInCodeBlock) {
        _exitCodeBlockAndRemoveEmptyLines(lineStart);
      } else if (isInBlockquote) {
        _exitBlockquoteAndRemoveEmptyLines(lineStart);
      }
      _consecutiveEmptyEnterCount = 0;
      return true;
    }
    
    return false;
  }
  
  /// Checks if a line at the given position is a blockquote line.
  bool _isLineBlockquote(String text, int position) {
    if (position < 0 || position >= text.length) return false;
    
    // Find the start of the line containing position
    final lineStart = text.lastIndexOf('\n', position > 0 ? position - 1 : 0) + 1;
    
    // Find the end of the line
    int lineEnd = text.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = text.length;
    
    // Get the line content
    final line = text.substring(lineStart, lineEnd);
    
    return line.startsWith('> ') || line.startsWith('>');
  }
  
  /// Exits code block and removes the last 2 empty lines.
  void _exitCodeBlockAndRemoveEmptyLines(int currentLineStart) {
    final currentText = text;
    
    // Find the start of the line 2 lines back (to remove 2 empty lines)
    int removeStart = currentLineStart;
    int linesBack = 0;
    int searchPos = currentLineStart;
    
    while (linesBack < 2 && searchPos > 0) {
      // Move to the previous line
      searchPos--;
      if (searchPos < 0) break;
      
      final prevLineStart = currentText.lastIndexOf('\n', searchPos > 0 ? searchPos - 1 : 0);
      removeStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
      
      // Check if this line is empty
      final lineEnd = currentText.indexOf('\n', removeStart);
      final actualLineEnd = lineEnd == -1 ? currentText.length : lineEnd;
      final line = currentText.substring(removeStart, actualLineEnd);
      
      if (line.isEmpty) {
        linesBack++;
        searchPos = removeStart - 1;
      } else {
        break;
      }
    }
    
    // Find the end of the current line (including newline if present)
    int removeEnd = currentText.indexOf('\n', currentLineStart);
    if (removeEnd == -1) {
      removeEnd = currentText.length;
    } else {
      removeEnd++; // Include the newline
    }
    
    // Ensure we're removing at least the current empty line
    if (removeStart >= removeEnd) {
      removeStart = currentLineStart;
    }
    
    // Add closing ``` marker and remove empty lines
    final newText = currentText.substring(0, removeStart) +
        '```\n' +
        currentText.substring(removeEnd);
    
    final lengthDiff = 4 - (removeEnd - removeStart); // "```\n" is 4 chars
    
    // Update spans
    _removeSpansInRange(removeStart, removeEnd);
    _shiftSpansAfter(removeEnd, lengthDiff);
    _mergeAdjacentSpans();
    
    // Position cursor after the closing marker
    final newCursorPos = removeStart + 4;
    _setTextDirectly(newText, newCursorPos);
    
    // Remove codeBlock from active formats
    _activeFormats.remove(FormatType.codeBlock);
    notifyListeners();
  }
  
  /// Exits blockquote and removes the last 2 empty blockquote lines.
  void _exitBlockquoteAndRemoveEmptyLines(int currentLineStart) {
    final currentText = text;
    
    // Find the start of the line 2 lines back (to remove 2 empty blockquote lines)
    int removeStart = currentLineStart;
    int linesBack = 0;
    int searchPos = currentLineStart;
    
    while (linesBack < 2 && searchPos > 0) {
      // Move to the previous line
      searchPos--;
      if (searchPos < 0) break;
      
      final prevLineStart = currentText.lastIndexOf('\n', searchPos > 0 ? searchPos - 1 : 0);
      final candidateStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
      
      // Check if this line is an empty blockquote
      final lineEnd = currentText.indexOf('\n', candidateStart);
      final actualLineEnd = lineEnd == -1 ? currentText.length : lineEnd;
      final line = currentText.substring(candidateStart, actualLineEnd);
      
      if (line == '> ' || line == '>') {
        removeStart = candidateStart;
        linesBack++;
        searchPos = candidateStart - 1;
      } else {
        break;
      }
    }
    
    // Find the end of the current line (including newline if present)
    int removeEnd = currentText.indexOf('\n', currentLineStart);
    if (removeEnd == -1) {
      removeEnd = currentText.length;
    } else {
      removeEnd++; // Include the newline
    }
    
    // Ensure we're removing at least the current empty line
    if (removeStart >= removeEnd) {
      removeStart = currentLineStart;
    }
    
    // Remove the empty blockquote lines
    final newText = currentText.substring(0, removeStart) +
        currentText.substring(removeEnd);
    
    final removedLength = removeEnd - removeStart;
    
    // Update spans
    _removeSpansInRange(removeStart, removeEnd);
    _shiftSpansAfter(removeEnd, -removedLength);
    _mergeAdjacentSpans();
    
    // Position cursor at the removal point
    _setTextDirectly(newText, removeStart);
    
    notifyListeners();
  }
  
  /// Resets the consecutive empty enter counter.
  /// 
  /// This should be called when non-empty content is typed to reset the
  /// double-enter and triple-enter exit tracking.
  /// 
  /// _Requirements: 2.25_
  void resetConsecutiveEnterCount() {
    _consecutiveEmptyEnterCount = 0;
  }

  /// Toggles a format on the selected text.
  ///
  /// **Mutual Exclusivity:** If the format is an exclusive format and is being
  /// added (not removed), any other exclusive formats in the selection range
  /// are first removed.
  /// 
  /// **List Marker Protection:** When applying inline formatting to text in a
  /// list, the list markers ("- " for bullet lists, "N. " for ordered lists)
  /// are excluded from formatting. Only the content after the marker is formatted.
  void _toggleFormatOnSelection(FormatType formatType) {
    int start = selection.start;
    int end = selection.end;
    
    // Protect list markers from inline formatting - get content ranges excluding markers
    final contentRanges = _adjustRangeForListMarkers(start, end);
    
    // If no valid content ranges, do nothing
    if (contentRanges.isEmpty) return;
    
    // Check if all content ranges already have this format
    bool allHaveFormat = true;
    for (final range in contentRanges) {
      if (!_selectionHasFormat(range.start, range.end, formatType)) {
        allHaveFormat = false;
        break;
      }
    }
    
    if (allHaveFormat) {
      // Remove format from all content ranges
      for (final range in contentRanges) {
        _removeFormatFromRange(range.start, range.end, formatType);
      }
    } else {
      // If this is an exclusive format, remove other exclusive formats first
      if (_isExclusiveFormat(formatType)) {
        for (final exclusiveFormat in _exclusiveFormats) {
          if (exclusiveFormat != formatType) {
            for (final range in contentRanges) {
              _removeFormatFromRange(range.start, range.end, exclusiveFormat);
            }
          }
        }
      }
      // Add format to all content ranges
      for (final range in contentRanges) {
        _addFormatToRange(range.start, range.end, formatType);
      }
    }
  }
  
  /// Adjusts a text range to exclude line-level format markers.
  /// 
  /// If the selection includes any line-level format markers ("- ", "N. ", or "> "),
  /// those markers are excluded from the returned ranges. This ensures inline formatting
  /// is only applied to the content, not the markers themselves.
  /// 
  /// Returns a list of ranges that exclude all list markers within the selection.
  /// For multi-line selections, this may return multiple ranges (one per line's content).
  List<({int start, int end})> _adjustRangeForListMarkers(int start, int end) {
    final currentText = text;
    if (currentText.isEmpty || start >= end) {
      return [];
    }
    
    final List<({int start, int end})> contentRanges = [];
    
    // Process each line in the selection
    int currentPos = start;
    while (currentPos < end) {
      // Find the start of the current line
      final lineStart = currentText.lastIndexOf('\n', currentPos > 0 ? currentPos - 1 : 0) + 1;
      
      // Find the end of the current line
      int lineEnd = currentText.indexOf('\n', currentPos);
      if (lineEnd == -1) lineEnd = currentText.length;
      
      // Get the line content from the line start
      final lineContent = currentText.substring(lineStart, lineEnd);
      
      // Calculate marker length for this line
      int markerLength = 0;
      String remainingContent = lineContent;
      
      // Check for blockquote prefix "> "
      if (remainingContent.startsWith('> ')) {
        markerLength += 2;
        remainingContent = remainingContent.substring(2);
      }
      
      // Check for bullet list marker "- "
      if (remainingContent.startsWith('- ')) {
        markerLength += 2;
      } else {
        // Check for ordered list marker "N. "
        final orderedMatch = RegExp(r'^\d+\. ').firstMatch(remainingContent);
        if (orderedMatch != null) {
          markerLength += orderedMatch.end;
        }
      }
      
      // Calculate the content start (after any marker)
      final contentStart = lineStart + markerLength;
      
      // Determine the actual range for this line's content
      final rangeStart = currentPos < contentStart ? contentStart : currentPos;
      final rangeEnd = end < lineEnd ? end : lineEnd;
      
      // Only add the range if it's valid (content exists after marker)
      if (rangeStart < rangeEnd) {
        contentRanges.add((start: rangeStart, end: rangeEnd));
      }
      
      // Move to the next line
      currentPos = lineEnd + 1;
    }
    
    return contentRanges;
  }

  /// Public method to check if the entire selection range has a specific format.
  bool hasFormatInRange(int start, int end, FormatType formatType) {
    return _selectionHasFormat(start, end, formatType);
  }

  /// Checks if the entire selection has a specific format.
  bool _selectionHasFormat(int start, int end, FormatType formatType) {
    // Check if every position in the range is covered by a span with this format
    for (int i = start; i < end; i++) {
      bool hasFormatAtPosition = false;
      for (final span in _spans) {
        if (span.contains(i) && span.formats.contains(formatType)) {
          hasFormatAtPosition = true;
          break;
        }
      }
      if (!hasFormatAtPosition) return false;
    }
    return true;
  }

  /// Adds a format to a range of text.
  /// 
  /// Emojis within the range are automatically excluded from formatting.
  void _addFormatToRange(int start, int end, FormatType formatType) {
    // Get non-emoji ranges to apply formatting only to text, not emojis
    final nonEmojiRanges = FormatPatterns.getNonEmojiRanges(text, start, end);
    
    // If no non-emoji ranges, nothing to format
    if (nonEmojiRanges.isEmpty) return;
    
    // Apply formatting to each non-emoji range
    for (final range in nonEmojiRanges) {
      _addFormatToRangeInternal(range.start, range.end, formatType);
    }
    
    _mergeAdjacentSpans();
  }
  
  /// Internal method to add format to a range without emoji filtering.
  /// 
  /// This is called by [_addFormatToRange] for each non-emoji segment.
  void _addFormatToRangeInternal(int start, int end, FormatType formatType) {
    // Find existing spans that overlap with this range
    final overlappingSpans = _spans.where((s) => s.overlaps(start, end)).toList();
    
    if (overlappingSpans.isEmpty) {
      // No overlapping spans - create a new one
      _addSpan(RichTextSpan(
        start: start,
        end: end,
        formats: {formatType},
      ));
    } else {
      // Handle overlapping spans
      for (final span in overlappingSpans) {
        _spans.remove(span);
        
        // Split and merge as needed
        if (span.start < start) {
          // Part before the range keeps original formats and url
          _addSpan(RichTextSpan(
            start: span.start,
            end: start,
            formats: span.formats,
            url: span.url,
          ));
        }
        
        // Overlapping part gets the new format added, preserving url
        final overlapStart = start > span.start ? start : span.start;
        final overlapEnd = end < span.end ? end : span.end;
        _addSpan(RichTextSpan(
          start: overlapStart,
          end: overlapEnd,
          formats: {...span.formats, formatType},
          url: span.url,
        ));
        
        if (span.end > end) {
          // Part after the range keeps original formats and url
          _addSpan(RichTextSpan(
            start: end,
            end: span.end,
            formats: span.formats,
            url: span.url,
          ));
        }
      }
      
      // Fill any gaps in the range with just the new format
      _fillGapsInRange(start, end, {formatType});
    }
  }

  /// Removes a format from a range of text.
  void _removeFormatFromRange(int start, int end, FormatType formatType) {
    final overlappingSpans = _spans.where((s) => s.overlaps(start, end)).toList();
    
    for (final span in overlappingSpans) {
      _spans.remove(span);
      
      // Determine if url should be preserved (only clear it when removing link format)
      final preserveUrl = formatType != FormatType.link ? span.url : null;
      
      if (span.start < start) {
        // Part before the range keeps all formats and url
        _addSpan(RichTextSpan(
          start: span.start,
          end: start,
          formats: span.formats,
          url: span.url,
        ));
      }
      
      // Overlapping part has the format removed
      final overlapStart = start > span.start ? start : span.start;
      final overlapEnd = end < span.end ? end : span.end;
      final newFormats = Set<FormatType>.from(span.formats)..remove(formatType);
      if (newFormats.isNotEmpty) {
        _addSpan(RichTextSpan(
          start: overlapStart,
          end: overlapEnd,
          formats: newFormats,
          url: preserveUrl,
        ));
      }
      
      if (span.end > end) {
        // Part after the range keeps all formats and url
        _addSpan(RichTextSpan(
          start: end,
          end: span.end,
          formats: span.formats,
          url: span.url,
        ));
      }
    }
    
    _mergeAdjacentSpans();
  }

  /// Fills gaps in a range with the specified formats.
  void _fillGapsInRange(int start, int end, Set<FormatType> formats) {
    // Sort spans by start position
    final sortedSpans = _spans.where((s) => s.overlaps(start, end)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    
    int currentPos = start;
    for (final span in sortedSpans) {
      if (span.start > currentPos) {
        // There's a gap - fill it
        _addSpan(RichTextSpan(
          start: currentPos,
          end: span.start,
          formats: formats,
        ));
      }
      currentPos = span.end > currentPos ? span.end : currentPos;
    }
    
    // Fill any remaining gap at the end
    if (currentPos < end) {
      _addSpan(RichTextSpan(
        start: currentPos,
        end: end,
        formats: formats,
      ));
    }
  }

  /// Adds a span to the list.
  void _addSpan(RichTextSpan span) {
    if (span.start < span.end && span.formats.isNotEmpty) {
      _spans.add(span);
    }
  }

  /// Shifts spans after a position by a delta.
  void _shiftSpansAfter(int position, int delta) {
    for (int i = 0; i < _spans.length; i++) {
      final span = _spans[i];
      if (span.start >= position) {
        // Span starts at or after insertion point - shift entire span
        _spans[i] = span.copyWith(
          start: span.start + delta,
          end: span.end + delta,
        );
      } else if (span.end > position) {
        // Span contains the insertion point - extend the span
        _spans[i] = span.copyWith(
          end: span.end + delta,
        );
      }
    }
    
    // Remove invalid spans
    _spans.removeWhere((s) => s.start >= s.end || s.start < 0 || s.end < 0);
  }

  /// Removes spans in a range.
  void _removeSpansInRange(int start, int end) {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      if (span.start >= start && span.end <= end) {
        // Span is entirely within the deleted range
        toRemove.add(span);
      } else if (span.overlaps(start, end)) {
        // Span partially overlaps
        toRemove.add(span);
        
        if (span.start < start) {
          toAdd.add(span.copyWith(end: start));
        }
        if (span.end > end) {
          toAdd.add(span.copyWith(start: end));
        }
      }
    }
    
    _spans.removeWhere((s) => toRemove.contains(s));
    _spans.addAll(toAdd);
  }

  /// Removes rich text spans that overlap with formatter attributions (mentions).
  /// 
  /// This ensures that mentions don't have rich text formatting applied to them.
  /// When a span overlaps with a mention, the overlapping portion is removed
  /// and the non-overlapping portions are preserved.
  void _removeSpansOverlappingWithAttributions(List<AttributedText> attributions) {
    if (attributions.isEmpty || _spans.isEmpty) return;
    
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      bool hasOverlap = false;
      int currentStart = span.start;
      int currentEnd = span.end;
      
      // Check each attribution for overlap with this span
      for (final attr in attributions) {
        if (attr.end <= currentStart || attr.start >= currentEnd) {
          // No overlap
          continue;
        }
        
        hasOverlap = true;
        
        // Attribution overlaps with span - split the span around the attribution
        if (attr.start > currentStart) {
          // There's a portion before the attribution
          toAdd.add(span.copyWith(start: currentStart, end: attr.start));
        }
        
        // Update currentStart to after the attribution
        currentStart = attr.end;
        
        if (currentStart >= currentEnd) {
          // The entire remaining span is covered by attributions
          break;
        }
      }
      
      if (hasOverlap) {
        toRemove.add(span);
        
        // Add any remaining portion after all attributions
        if (currentStart < currentEnd) {
          toAdd.add(span.copyWith(start: currentStart, end: currentEnd));
        }
      }
    }
    
    // Apply changes
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
    
    // Merge adjacent spans after modification
    _mergeAdjacentSpans();
  }

  /// Merges adjacent spans with the same formats.
  void _mergeAdjacentSpans() {
    if (_spans.length < 2) return;
    
    // Sort by start position
    _spans.sort((a, b) => a.start.compareTo(b.start));
    
    final merged = <RichTextSpan>[];
    RichTextSpan? current;
    
    for (final span in _spans) {
      if (current == null) {
        current = span;
      } else if (current.end == span.start && _setsEqual(current.formats, span.formats) && current.url == span.url) {
        // Merge adjacent spans with same formats and same url
        current = current.copyWith(end: span.end);
      } else {
        merged.add(current);
        current = span;
      }
    }
    
    if (current != null) {
      merged.add(current);
    }
    
    _spans.clear();
    _spans.addAll(merged);
  }

  /// Checks if two sets are equal.
  bool _setsEqual(Set<FormatType> a, Set<FormatType> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  /// Parses markdown text and creates spans from it, stripping the markers.
  ///
  /// This converts markdown text like "**bold**" to plain text "bold" with
  /// a span indicating it should be displayed as bold.
  void _parseMarkdownToSpans(String markdownText) {
    // Use recursive parsing to handle nested formats properly
    final result = _parseNestedMarkdown(markdownText, 0);
    
    // Add all parsed spans
    for (final span in result.spans) {
      _addSpan(span);
    }
    
    // Update the text to the plain version
    super.value = TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.text.length),
    );
  }
  
  /// Recursively parses markdown text and returns plain text with spans.
  /// 
  /// This handles nested formats like `<u>~~_**Hi**_~~</u>` by parsing
  /// from the outermost format inward.
  _MarkdownParseResult _parseNestedMarkdown(String text, int baseOffset) {
    if (text.isEmpty) {
      return _MarkdownParseResult(text: '', spans: []);
    }
    
    // Define format patterns in order of precedence (outermost first)
    // Code block (```) must come before inline code (`) to avoid partial matches
    final formatPatterns = <({RegExp pattern, FormatType format, int prefixLen, int suffixLen})>[
      (pattern: RegExp(r'<u>(.+?)</u>', dotAll: true), format: FormatType.underline, prefixLen: 3, suffixLen: 4),
      (pattern: RegExp(r'~~(.+?)~~', dotAll: true), format: FormatType.strikethrough, prefixLen: 2, suffixLen: 2),
      (pattern: RegExp(r'_(.+?)_', dotAll: true), format: FormatType.italic, prefixLen: 1, suffixLen: 1),
      (pattern: RegExp(r'\*\*([^*]+)\*\*', dotAll: true), format: FormatType.bold, prefixLen: 2, suffixLen: 2),
      (pattern: RegExp(r'```([\s\S]*?)```', dotAll: true), format: FormatType.codeBlock, prefixLen: 3, suffixLen: 3),
      (pattern: RegExp(r'(?<!`)`([^`]+)`(?!`)', dotAll: true), format: FormatType.inlineCode, prefixLen: 1, suffixLen: 1),
      (pattern: RegExp(r'\[([^\]]+)\]\(([^)]+)\)', dotAll: true), format: FormatType.link, prefixLen: 1, suffixLen: 0), // Special handling for links
    ];
    
    // Try to find the first (leftmost) format match
    Match? earliestMatch;
    ({RegExp pattern, FormatType format, int prefixLen, int suffixLen})? matchedFormat;
    
    for (final fp in formatPatterns) {
      final match = fp.pattern.firstMatch(text);
      if (match != null) {
        if (earliestMatch == null || match.start < earliestMatch.start) {
          earliestMatch = match;
          matchedFormat = fp;
        }
      }
    }
    
    // No format found - return plain text
    if (earliestMatch == null || matchedFormat == null) {
      return _MarkdownParseResult(text: text, spans: []);
    }
    
    final match = earliestMatch;
    final format = matchedFormat;
    
    // Parse text before the match
    final beforeText = text.substring(0, match.start);
    final beforeResult = _parseNestedMarkdown(beforeText, baseOffset);
    
    // Get the inner content and parse it recursively
    String innerContent;
    String? linkUrl;
    
    if (format.format == FormatType.link) {
      innerContent = match.group(1) ?? '';
      linkUrl = match.group(2);
    } else {
      innerContent = match.group(1) ?? '';
    }
    
    final innerOffset = baseOffset + beforeResult.text.length;
    
    // Code block content should NOT be recursively parsed — treat as literal text
    final _MarkdownParseResult innerResult;
    if (format.format == FormatType.codeBlock) {
      innerResult = _MarkdownParseResult(text: innerContent, spans: []);
    } else {
      innerResult = _parseNestedMarkdown(innerContent, innerOffset);
    }
    
    // Parse text after the match
    final afterText = text.substring(match.end);
    final afterOffset = innerOffset + innerResult.text.length;
    final afterResult = _parseNestedMarkdown(afterText, afterOffset);
    
    // Combine results
    final combinedText = beforeResult.text + innerResult.text + afterResult.text;
    final combinedSpans = <RichTextSpan>[];
    
    // Add spans from before
    combinedSpans.addAll(beforeResult.spans);
    
    // Add spans from inner content (these already have correct offsets)
    combinedSpans.addAll(innerResult.spans);
    
    // Create span for the current format covering the inner content
    if (innerResult.text.isNotEmpty) {
      combinedSpans.add(RichTextSpan(
        start: innerOffset,
        end: innerOffset + innerResult.text.length,
        formats: {format.format},
        url: linkUrl,
      ));
    }
    
    // Add spans from after, adjusting their offsets
    combinedSpans.addAll(afterResult.spans);
    
    return _MarkdownParseResult(text: combinedText, spans: combinedSpans);
  }
  
  /// Parses markdown links [text](url) and creates spans with URL metadata.
  /// 
  /// This is separate from _parseAndStripPattern because links need to store
  /// the URL in the span's metadata.
  String _parseAndStripLinks(String text) {
    final linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    String result = text;
    int offset = 0;
    
    for (final match in linkPattern.allMatches(text)) {
      final displayText = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      final adjustedStart = match.start - offset;
      
      // Create span for the display text with the URL stored
      _addSpan(RichTextSpan(
        start: adjustedStart,
        end: adjustedStart + displayText.length,
        formats: {FormatType.link},
        url: url,
      ));
      
      // Update offset: we're removing "[", "](", url, and ")"
      // Original: [displayText](url)
      // Result: displayText
      // Removed: 1 + 2 + url.length + 1 = 4 + url.length
      offset += 4 + url.length;
    }
    
    // Strip the link markers, keeping only the display text
    result = text.replaceAllMapped(linkPattern, (match) => match.group(1) ?? '');
    
    return result;
  }

  /// Parses a pattern, creates spans, and returns text with markers stripped.
  String _parseAndStripPattern(
    String text,
    RegExp pattern,
    FormatType formatType,
    int prefixLength,
    int suffixLength,
  ) {
    String result = text;
    int offset = 0;
    
    for (final match in pattern.allMatches(text)) {
      final adjustedStart = match.start - offset;
      final contentLength = match.group(1)?.length ?? 0;
      
      // Create span for the content (without markers)
      _addSpan(RichTextSpan(
        start: adjustedStart,
        end: adjustedStart + contentLength,
        formats: {formatType},
      ));
      
      // Update offset for removed markers
      offset += prefixLength + suffixLength;
    }
    
    // Strip the markers from the text
    result = text.replaceAllMapped(pattern, (match) => match.group(1) ?? '');
    
    return result;
  }

  /// Converts the current text and spans to markdown format.
  ///
  /// This is called when sending a message to convert the WYSIWYG
  /// formatted text back to markdown syntax.
  String toMarkdown() {
    if (_spans.isEmpty) return _cleanupTrailingEmptyBlockquotes(text);
    
    final textLength = text.length;
    
    // First, merge overlapping spans that cover the same range
    // This handles nested formats like bold+italic+underline on the same text
    final mergedSpans = _mergeOverlappingSpans();
    
    // Sort spans by start position
    mergedSpans.sort((a, b) => a.start.compareTo(b.start));
    
    final buffer = StringBuffer();
    int currentPos = 0;
    
    for (final span in mergedSpans) {
      // Clamp span boundaries to valid text range
      final clampedStart = span.start.clamp(0, textLength);
      final clampedEnd = span.end.clamp(clampedStart, textLength);
      
      // Skip spans that are completely out of range or empty after clamping
      if (clampedStart >= textLength || clampedStart >= clampedEnd) continue;
      
      // Skip if we've already processed this range
      if (clampedStart < currentPos) continue;
      
      // Add unformatted text before this span
      if (clampedStart > currentPos) {
        buffer.write(text.substring(currentPos, clampedStart));
      }
      
      // Add formatted text
      final spanText = text.substring(clampedStart, clampedEnd);
      final wrappedText = _wrapWithFormats(spanText, span.formats, span.url);
      buffer.write(wrappedText);
      
      currentPos = clampedEnd;
    }
    
    // Add remaining unformatted text
    if (currentPos < textLength) {
      buffer.write(text.substring(currentPos));
    }
    
    // Clean up trailing empty blockquote lines before returning
    return _cleanupTrailingEmptyBlockquotes(buffer.toString());
  }
  
  /// Removes trailing empty blockquote lines from the text.
  /// 
  /// An empty blockquote line is a line that contains only "> " with no content.
  /// This is called before sending to clean up any trailing empty formatting
  /// that the user may have left.
  /// 
  /// Note: Empty list items (except the first) are preserved as-is per requirement 2.15.
  /// Only removes empty list items if they are the only item in the list.
  String _cleanupTrailingEmptyBlockquotes(String text) {
    if (text.isEmpty) return text;
    
    // Split into lines and process from the end
    final lines = text.split('\n');
    
    // Remove trailing empty blockquote lines only (not list items)
    // Per requirement 2.15: empty list points (except first) should be preserved
    while (lines.isNotEmpty) {
      final lastLine = lines.last;
      // Check if the last line is an empty blockquote (just "> " or ">")
      if (lastLine == '> ' || lastLine == '>') {
        lines.removeLast();
      }
      // Check if the last line is an empty bullet list item (just "- ")
      // Only remove if it's the first/only item in the list
      else if (lastLine == '- ') {
        if (!_hasNonEmptyListItemBefore(lines, isBullet: true)) {
          lines.removeLast();
        } else {
          break; // Preserve empty list item if there are non-empty items before
        }
      }
      // Check if the last line is an empty ordered list item (just "N. ")
      // Only remove if it's the first/only item in the list
      else if (RegExp(r'^\d+\. $').hasMatch(lastLine)) {
        if (!_hasNonEmptyListItemBefore(lines, isBullet: false)) {
          lines.removeLast();
        } else {
          break; // Preserve empty list item if there are non-empty items before
        }
      }
      // Check if the last line is an empty nested list in blockquote ("> - " or "> N. ")
      else if (lastLine == '> - ' || RegExp(r'^> \d+\. $').hasMatch(lastLine)) {
        if (!_hasNonEmptyNestedListItemBefore(lines)) {
          lines.removeLast();
        } else {
          break; // Preserve empty nested list item if there are non-empty items before
        }
      }
      else {
        break;
      }
    }
    
    return lines.join('\n');
  }
  
  /// Checks if there are any non-empty list items before the last line.
  /// 
  /// [lines] is the list of lines including the last empty item.
  /// [isBullet] indicates whether to check for bullet list items (true) or ordered list items (false).
  /// 
  /// Returns true if there's at least one non-empty list item before the last line.
  bool _hasNonEmptyListItemBefore(List<String> lines, {required bool isBullet}) {
    if (lines.length < 2) return false;
    
    // Check lines before the last one (excluding the last empty item)
    for (int i = lines.length - 2; i >= 0; i--) {
      final line = lines[i];
      if (isBullet) {
        // Check for non-empty bullet list item (starts with "- " and has content after)
        if (line.startsWith('- ') && line.length > 2) {
          return true;
        }
        // If we hit a non-list line, stop checking
        if (!line.startsWith('- ')) {
          break;
        }
      } else {
        // Check for non-empty ordered list item (starts with "N. " and has content after)
        final orderedMatch = RegExp(r'^(\d+)\. (.*)$').firstMatch(line);
        if (orderedMatch != null && orderedMatch.group(2)!.isNotEmpty) {
          return true;
        }
        // If we hit a non-list line, stop checking
        if (!RegExp(r'^\d+\. ').hasMatch(line)) {
          break;
        }
      }
    }
    
    return false;
  }
  
  /// Checks if there are any non-empty nested list items (in blockquote) before the last line.
  /// 
  /// [lines] is the list of lines including the last empty nested item.
  /// 
  /// Returns true if there's at least one non-empty nested list item before the last line.
  bool _hasNonEmptyNestedListItemBefore(List<String> lines) {
    if (lines.length < 2) return false;
    
    // Check lines before the last one (excluding the last empty item)
    for (int i = lines.length - 2; i >= 0; i--) {
      final line = lines[i];
      // Check for non-empty nested bullet list item ("> - " with content)
      if (line.startsWith('> - ') && line.length > 4) {
        return true;
      }
      // Check for non-empty nested ordered list item ("> N. " with content)
      final nestedOrderedMatch = RegExp(r'^> (\d+)\. (.*)$').firstMatch(line);
      if (nestedOrderedMatch != null && nestedOrderedMatch.group(2)!.isNotEmpty) {
        return true;
      }
      // If we hit a non-nested-list line, stop checking
      if (!line.startsWith('> - ') && !RegExp(r'^> \d+\. ').hasMatch(line)) {
        break;
      }
    }
    
    return false;
  }

  /// Merges overlapping spans that cover the same or similar ranges.
  /// 
  /// When parsing nested markdown like `<u>~~_**Hi**_~~</u>`, we create
  /// separate spans for each format. This method merges them into a single
  /// span with all formats combined.
  List<RichTextSpan> _mergeOverlappingSpans() {
    if (_spans.isEmpty) return [];
    
    // Group spans by their exact range
    final spansByRange = <String, List<RichTextSpan>>{};
    
    for (final span in _spans) {
      final key = '${span.start}-${span.end}';
      spansByRange.putIfAbsent(key, () => []).add(span);
    }
    
    // Merge spans with the same range
    final mergedSpans = <RichTextSpan>[];
    
    for (final entry in spansByRange.entries) {
      final spansInRange = entry.value;
      if (spansInRange.length == 1) {
        mergedSpans.add(spansInRange.first);
      } else {
        // Merge all formats into one span
        final combinedFormats = <FormatType>{};
        String? url;
        
        for (final span in spansInRange) {
          combinedFormats.addAll(span.formats);
          if (span.url != null) url = span.url;
        }
        
        mergedSpans.add(RichTextSpan(
          start: spansInRange.first.start,
          end: spansInRange.first.end,
          formats: combinedFormats,
          url: url,
        ));
      }
    }
    
    return mergedSpans;
  }

  /// Wraps text with markdown format markers.
  /// 
  /// If the text contains newlines, each line segment is wrapped separately
  /// to ensure valid markdown (inline format markers must be on the same line).
  String _wrapWithFormats(String text, Set<FormatType> formats, [String? url]) {
    // Handle code block specially - it can span multiple lines
    if (formats.contains(FormatType.codeBlock)) {
      String result = text;
      // Apply non-code-block formats first, then wrap in code block
      final otherFormats = Set<FormatType>.from(formats)..remove(FormatType.codeBlock);
      if (otherFormats.isNotEmpty) {
        result = _wrapSingleSegment(result, otherFormats, url);
      }
      // Always use inline format without extra newlines
      // The content itself may contain newlines for multi-line code
      return '```$result```';
    }
    
    // For inline formats, handle newlines by wrapping each line segment separately
    if (text.contains('\n')) {
      final lines = text.split('\n');
      final wrappedLines = <String>[];
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.isNotEmpty) {
          wrappedLines.add(_wrapSingleSegment(line, formats, url));
        } else {
          wrappedLines.add(line);
        }
      }
      
      return wrappedLines.join('\n');
    }
    
    return _wrapSingleSegment(text, formats, url);
  }
  
  /// Wraps a single text segment (no newlines) with markdown format markers.
  String _wrapSingleSegment(String text, Set<FormatType> formats, [String? url]) {
    String result = text;
    
    // Handle link format specially - it needs the URL
    if (formats.contains(FormatType.link) && url != null) {
      result = '[$result]($url)';
      // Remove link from formats to avoid double processing
      formats = Set.from(formats)..remove(FormatType.link);
    }
    
    // Apply other formats in a consistent order
    if (formats.contains(FormatType.bold)) {
      result = '**$result**';
    }
    if (formats.contains(FormatType.italic)) {
      result = '_${result}_';
    }
    if (formats.contains(FormatType.strikethrough)) {
      result = '~~$result~~';
    }
    if (formats.contains(FormatType.inlineCode)) {
      result = '`$result`';
    }
    if (formats.contains(FormatType.underline)) {
      result = '<u>$result</u>';
    }
    
    return result;
  }

  /// Converts the current text and spans to an HTML string.
  ///
  /// This is used for clipboard operations to preserve formatting when
  /// copying text from the composer.
  ///
  /// _Requirements: 6.1, 6.4_
  String toHtml() {
    if (_spans.isEmpty) return text;
    
    final textLength = text.length;
    
    // Sort spans by start position
    final sortedSpans = List<RichTextSpan>.from(_spans)
      ..sort((a, b) => a.start.compareTo(b.start));
    
    final buffer = StringBuffer();
    int currentPos = 0;
    
    for (final span in sortedSpans) {
      // Clamp span boundaries to valid text range
      final clampedStart = span.start.clamp(0, textLength);
      final clampedEnd = span.end.clamp(clampedStart, textLength);
      
      // Skip spans that are completely out of range or empty after clamping
      if (clampedStart >= textLength || clampedStart >= clampedEnd) continue;
      
      // Add unformatted text before this span
      if (clampedStart > currentPos) {
        buffer.write(_escapeHtml(text.substring(currentPos, clampedStart)));
      }
      
      // Add formatted text
      final spanText = text.substring(clampedStart, clampedEnd);
      buffer.write(_wrapWithHtmlTags(spanText, span.formats, span.url));
      
      currentPos = clampedEnd;
    }
    
    // Add remaining unformatted text
    if (currentPos < textLength) {
      buffer.write(_escapeHtml(text.substring(currentPos)));
    }
    
    return buffer.toString();
  }

  /// Wraps text with HTML tags based on formats.
  String _wrapWithHtmlTags(String text, Set<FormatType> formats, [String? url]) {
    String result = _escapeHtml(text);
    
    // Apply formats in a consistent order (innermost first)
    if (formats.contains(FormatType.inlineCode)) {
      result = '<code>$result</code>';
    }
    if (formats.contains(FormatType.strikethrough)) {
      result = '<s>$result</s>';
    }
    if (formats.contains(FormatType.underline)) {
      result = '<u>$result</u>';
    }
    if (formats.contains(FormatType.italic)) {
      result = '<i>$result</i>';
    }
    if (formats.contains(FormatType.bold)) {
      result = '<b>$result</b>';
    }
    
    // Handle link format - wrap everything in anchor tag
    if (formats.contains(FormatType.link) && url != null) {
      final escapedUrl = _escapeHtml(url);
      result = '<a href="$escapedUrl">$result</a>';
    }
    
    return result;
  }

  /// Escapes HTML special characters.
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Parses HTML string and inserts it at the specified position with formatting.
  ///
  /// Supported HTML tags:
  /// - `<b>`, `<strong>` → bold
  /// - `<i>`, `<em>` → italic
  /// - `<u>` → underline
  /// - `<s>`, `<del>` → strikethrough
  /// - `<code>` → inline code
  /// - `<a href="...">` → link
  ///
  /// Malformed HTML is handled gracefully by falling back to plain text insertion.
  ///
  /// _Requirements: 6.2_
  void pasteHtml(String html, int insertPosition) {
    try {
      final result = _parseHtml(html);
      final plainText = result.text;
      final parsedSpans = result.spans;
      
      if (plainText.isEmpty) return;
      
      // Shift existing spans after the insert position
      _shiftSpansAfter(insertPosition, plainText.length);
      
      // Adjust parsed spans to the insert position and add them
      for (final span in parsedSpans) {
        _addSpan(RichTextSpan(
          start: span.start + insertPosition,
          end: span.end + insertPosition,
          formats: span.formats,
          url: span.url,
        ));
      }
      
      _mergeAdjacentSpans();
      
      // Build the new text
      final currentText = text;
      final newText = currentText.substring(0, insertPosition) +
          plainText +
          currentText.substring(insertPosition);
      
      _setTextDirectly(newText, insertPosition + plainText.length);
      notifyListeners();
    } catch (e) {
      // Fallback to plain text insertion on parse error
      _insertPlainText(html, insertPosition);
    }
  }

  /// Parses HTML and returns plain text with formatting spans.
  _HtmlParseResult _parseHtml(String html) {
    final buffer = StringBuffer();
    final spans = <RichTextSpan>[];
    final formatStack = <_FormatStackEntry>[];
    
    int i = 0;
    while (i < html.length) {
      if (html[i] == '<') {
        // Find the end of the tag
        final tagEnd = html.indexOf('>', i);
        if (tagEnd == -1) {
          // Malformed HTML - treat rest as text
          buffer.write(html.substring(i));
          break;
        }
        
        final tagContent = html.substring(i + 1, tagEnd);
        final isClosingTag = tagContent.startsWith('/');
        final tagName = isClosingTag
            ? tagContent.substring(1).toLowerCase().trim()
            : tagContent.split(RegExp(r'[\s>]'))[0].toLowerCase();
        
        if (isClosingTag) {
          // Closing tag - pop from stack and create span
          final matchingEntry = _popMatchingFormat(formatStack, tagName);
          if (matchingEntry != null && buffer.length > matchingEntry.startPos) {
            spans.add(RichTextSpan(
              start: matchingEntry.startPos,
              end: buffer.length,
              formats: {matchingEntry.format},
              url: matchingEntry.url,
            ));
          }
        } else {
          // Opening tag - push to stack
          final format = _tagToFormat(tagName);
          if (format != null) {
            String? url;
            if (format == FormatType.link) {
              url = _extractHref(tagContent);
            }
            formatStack.add(_FormatStackEntry(
              tagName: tagName,
              format: format,
              startPos: buffer.length,
              url: url,
            ));
          }
        }
        
        i = tagEnd + 1;
      } else if (html[i] == '&') {
        // HTML entity
        final entityEnd = html.indexOf(';', i);
        if (entityEnd != -1 && entityEnd - i < 10) {
          final entity = html.substring(i, entityEnd + 1);
          buffer.write(_decodeHtmlEntity(entity));
          i = entityEnd + 1;
        } else {
          buffer.write(html[i]);
          i++;
        }
      } else {
        buffer.write(html[i]);
        i++;
      }
    }
    
    return _HtmlParseResult(text: buffer.toString(), spans: spans);
  }

  /// Maps HTML tag names to FormatType.
  FormatType? _tagToFormat(String tagName) {
    switch (tagName) {
      case 'b':
      case 'strong':
        return FormatType.bold;
      case 'i':
      case 'em':
        return FormatType.italic;
      case 'u':
        return FormatType.underline;
      case 's':
      case 'del':
        return FormatType.strikethrough;
      case 'code':
        return FormatType.inlineCode;
      case 'a':
        return FormatType.link;
      default:
        return null;
    }
  }

  /// Extracts href attribute from anchor tag content.
  String? _extractHref(String tagContent) {
    final hrefMatch = RegExp(r"href\s*=\s*[" "\"']([^\"']*)[\"']").firstMatch(tagContent);
    return hrefMatch?.group(1);
  }

  /// Pops matching format entry from stack.
  _FormatStackEntry? _popMatchingFormat(List<_FormatStackEntry> stack, String tagName) {
    for (int i = stack.length - 1; i >= 0; i--) {
      if (stack[i].tagName == tagName ||
          (tagName == 'strong' && stack[i].tagName == 'b') ||
          (tagName == 'b' && stack[i].tagName == 'strong') ||
          (tagName == 'em' && stack[i].tagName == 'i') ||
          (tagName == 'i' && stack[i].tagName == 'em') ||
          (tagName == 'del' && stack[i].tagName == 's') ||
          (tagName == 's' && stack[i].tagName == 'del')) {
        return stack.removeAt(i);
      }
    }
    return null;
  }

  /// Decodes common HTML entities.
  String _decodeHtmlEntity(String entity) {
    switch (entity) {
      case '&amp;':
        return '&';
      case '&lt;':
        return '<';
      case '&gt;':
        return '>';
      case '&quot;':
        return '"';
      case '&#39;':
      case '&apos;':
        return "'";
      case '&nbsp;':
        return ' ';
      default:
        // Try to decode numeric entities
        if (entity.startsWith('&#x')) {
          final hex = entity.substring(3, entity.length - 1);
          final code = int.tryParse(hex, radix: 16);
          if (code != null) return String.fromCharCode(code);
        } else if (entity.startsWith('&#')) {
          final dec = entity.substring(2, entity.length - 1);
          final code = int.tryParse(dec);
          if (code != null) return String.fromCharCode(code);
        }
        return entity; // Return as-is if unknown
    }
  }

  /// Inserts plain text at the specified position, auto-detecting and formatting URLs as links.
  void _insertPlainText(String plainText, int insertPosition) {
    if (plainText.isEmpty) return;
    
    // Check if the pasted text contains URLs that should be auto-formatted
    final urlMatches = _detectUrls(plainText);
    
    if (urlMatches.isEmpty) {
      // No URLs found - insert as plain text
      _shiftSpansAfter(insertPosition, plainText.length);
      
      final currentText = text;
      final newText = currentText.substring(0, insertPosition) +
          plainText +
          currentText.substring(insertPosition);
      
      _setTextDirectly(newText, insertPosition + plainText.length);
    } else {
      // URLs found - insert text and create link spans for URLs
      _insertTextWithUrls(plainText, insertPosition, urlMatches);
    }
    
    notifyListeners();
  }
  
  /// URL regex pattern for detecting URLs in text.
  static final RegExp _urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    caseSensitive: false,
  );
  
  /// Detects URLs in the given text and returns their positions.
  List<_UrlMatch> _detectUrls(String text) {
    final matches = <_UrlMatch>[];
    
    for (final match in _urlRegex.allMatches(text)) {
      var url = match.group(0) ?? '';
      if (url.isNotEmpty) {
        // Ensure URL has a protocol for the link
        String fullUrl = url;
        if (!RegExp(r'^(https?|ftp):\/\/', caseSensitive: false).hasMatch(url)) {
          fullUrl = 'https://$url';
        }
        
        matches.add(_UrlMatch(
          start: match.start,
          end: match.end,
          displayText: url,
          url: fullUrl,
        ));
      }
    }
    
    return matches;
  }
  
  /// Inserts text with URLs formatted as links.
  void _insertTextWithUrls(String plainText, int insertPosition, List<_UrlMatch> urlMatches) {
    // Shift existing spans to make room for the new text
    _shiftSpansAfter(insertPosition, plainText.length);
    
    // Create link spans for each URL
    for (final urlMatch in urlMatches) {
      _addSpan(RichTextSpan(
        start: insertPosition + urlMatch.start,
        end: insertPosition + urlMatch.end,
        formats: {FormatType.link},
        url: urlMatch.url,
      ));
    }
    
    _mergeAdjacentSpans();
    
    // Insert the text
    final currentText = text;
    final newText = currentText.substring(0, insertPosition) +
        plainText +
        currentText.substring(insertPosition);
    
    _setTextDirectly(newText, insertPosition + plainText.length);
  }
  
  /// Auto-detects URLs in inserted text and creates link spans for them.
  /// 
  /// This is called when text is pasted or inserted (more than 1 character at a time)
  /// to automatically format any URLs as clickable links.
  void _autoDetectAndFormatUrls(String insertedText, int insertPosition) {
    final urlMatches = _detectUrls(insertedText);
    
    if (urlMatches.isEmpty) return;
    
    // Check if the pasted text is just a URL (or URLs) without trailing space
    // If so, we'll add a space after to help the user continue typing
    bool shouldAddSpace = false;
    int lastUrlEnd = 0;
    
    // Create link spans for each detected URL
    for (final urlMatch in urlMatches) {
      final spanStart = insertPosition + urlMatch.start;
      final spanEnd = insertPosition + urlMatch.end;
      
      // Track the last URL end position
      if (urlMatch.end > lastUrlEnd) {
        lastUrlEnd = urlMatch.end;
      }
      
      // Check if this range already has a link span (avoid duplicates)
      final hasExistingLink = _spans.any((span) => 
        span.formats.contains(FormatType.link) &&
        span.start <= spanStart &&
        span.end >= spanEnd
      );
      
      if (!hasExistingLink) {
        _addSpan(RichTextSpan(
          start: spanStart,
          end: spanEnd,
          formats: {FormatType.link},
          url: urlMatch.url,
        ));
      }
    }
    
    _mergeAdjacentSpans();
    
    // If the pasted text ends with a URL (no trailing space), add a space
    // This helps the user continue typing without the text being part of the link
    if (lastUrlEnd == insertedText.length && !insertedText.endsWith(' ')) {
      shouldAddSpace = true;
    }
    
    if (shouldAddSpace) {
      // Add a space after the URL using post-frame callback to avoid conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentText = text;
        final cursorPos = selection.baseOffset;
        
        // Only add space if cursor is at the end of the pasted content
        if (cursorPos == insertPosition + insertedText.length) {
          final newText = currentText.substring(0, cursorPos) + ' ' + currentText.substring(cursorPos);
          _setTextDirectly(newText, cursorPos + 1);
        }
      });
    }
  }

  /// Reads clipboard data and inserts it with formatting preserved.
  ///
  /// Checks for HTML format first (`text/html`), falls back to plain text
  /// (`text/plain`). If HTML is found, parses it and creates corresponding
  /// formatting spans. Plain text is inserted without formatting.
  ///
  /// **Paste-to-Link Feature**: If text is selected AND the clipboard contains
  /// a URL, the selected text is converted to a link with the pasted URL as
  /// the href. The display text remains the selected text.
  ///
  /// _Requirements: 2.11, 6.3, 6.5_
  Future<void> pasteFromClipboard() async {
    final cursorPosition = selection.baseOffset.clamp(0, text.length);
    
    try {
      // Try to get HTML content first
      // Note: Flutter's Clipboard API doesn't directly support HTML format
      // on all platforms. We check for plain text and attempt to detect
      // if it contains HTML markup.
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      
      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        return;
      }
      
      final pastedText = clipboardData.text!;
      
      // Check for paste-to-link: if text is selected AND clipboard contains a URL,
      // convert the selected text to a link with the pasted URL
      // _Requirements: 2.11_
      if (!selection.isCollapsed && _isUrl(pastedText.trim())) {
        _convertSelectedTextToLink(pastedText.trim());
        return;
      }
      
      // Check if the text appears to be HTML (contains HTML tags)
      if (_looksLikeHtml(pastedText)) {
        pasteHtml(pastedText, cursorPosition);
      } else {
        // Plain text - insert without formatting
        _insertPlainText(pastedText, cursorPosition);
      }
    } catch (e) {
      // Clipboard access failed - silently ignore
      debugPrint('Clipboard access failed: $e');
    }
  }
  
  /// Checks if the given text is a URL.
  ///
  /// Returns true if the text matches a URL pattern (with or without protocol).
  /// This is used for paste-to-link detection.
  ///
  /// _Requirements: 2.11_
  bool _isUrl(String text) {
    if (text.isEmpty) return false;
    
    // Check if the entire text is a single URL
    // The text should match the URL pattern and be the entire string
    final match = _urlRegex.firstMatch(text);
    if (match == null) return false;
    
    // Ensure the match covers the entire text (not just a substring)
    return match.start == 0 && match.end == text.length;
  }
  
  /// Handles paste-to-link: when a URL is pasted over selected text,
  /// restore the original text and create a link span.
  ///
  /// This is called from _handleTextChange when it detects that selected text
  /// was replaced with a URL. We need to undo the replacement and create a link.
  ///
  /// _Requirements: 2.11_
  void _handlePasteToLink(String oldText, String selectedText, String url, int selStart, int selEnd) {
    // Ensure URL has a protocol
    String fullUrl = url;
    if (!RegExp(r'^(https?|ftp):\/\/', caseSensitive: false).hasMatch(url)) {
      fullUrl = 'https://$url';
    }
    
    // Remove any existing spans in the selection range
    _removeSpansInRange(selStart, selEnd);
    
    // Create a link span for the selected text
    _addSpan(RichTextSpan(
      start: selStart,
      end: selEnd,
      formats: {FormatType.link},
      url: fullUrl,
    ));
    
    _mergeAdjacentSpans();
    
    // Restore the original text and position cursor at end of selection
    _setTextDirectly(oldText, selEnd);
    
    notifyListeners();
  }

  /// Converts the currently selected text to a link with the given URL.
  ///
  /// The selected text becomes the display text of the link, and the URL
  /// becomes the href. This is called when pasting a URL on selected text.
  ///
  /// _Requirements: 2.11_
  void _convertSelectedTextToLink(String url) {
    if (selection.isCollapsed) return;
    
    final start = selection.start;
    final end = selection.end;
    
    // Validate selection bounds
    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      return;
    }
    
    // Ensure URL has a protocol
    String fullUrl = url;
    if (!RegExp(r'^(https?|ftp):\/\/', caseSensitive: false).hasMatch(url)) {
      fullUrl = 'https://$url';
    }
    
    // Remove any existing link spans in the selected range
    _removeSpansInRange(start, end);
    
    // Create a link span for the selected text
    _addSpan(RichTextSpan(
      start: start,
      end: end,
      formats: {FormatType.link},
      url: fullUrl,
    ));
    
    _mergeAdjacentSpans();
    
    // Move cursor to end of selection
    _setTextDirectly(text, end);
    
    notifyListeners();
  }

  /// Checks if text appears to contain HTML markup.
  bool _looksLikeHtml(String text) {
    // Check for common HTML tags
    return RegExp(r'<(b|strong|i|em|u|s|del|code|a)\b[^>]*>').hasMatch(text);
  }

  /// Inserts a link at the current cursor position or replaces selected text.
  ///
  /// If [displayText] is provided, the link will be displayed as the text.
  /// If [displayText] is null, the URL itself will be displayed.
  ///
  /// The link is stored as a span with FormatType.link and the URL is stored
  /// in the span's metadata for later conversion to markdown.
  void insertLink({String? displayText, required String url}) {
    final textToInsert = displayText ?? url;
    final currentSelection = selection;
    
    // Handle invalid selection (e.g., when text field lost focus)
    // Default to inserting at the end of the text
    int insertPosition = currentSelection.baseOffset;
    if (insertPosition < 0 || insertPosition > text.length) {
      insertPosition = text.length;
    }
    
    final isCollapsed = currentSelection.isCollapsed || 
                        currentSelection.start < 0 || 
                        currentSelection.end < 0 ||
                        currentSelection.start > text.length ||
                        currentSelection.end > text.length;
    
    if (isCollapsed) {
      // No selection or invalid selection - insert at cursor position (or end)
      
      // Shift existing spans BEFORE adding the new span
      _shiftSpansAfter(insertPosition, textToInsert.length);
      
      // Create a link span for the inserted text
      _addSpan(RichTextSpan(
        start: insertPosition,
        end: insertPosition + textToInsert.length,
        formats: {FormatType.link},
        url: url,
      ));
      
      _mergeAdjacentSpans();
      
      // Build the new text
      final newText = text.substring(0, insertPosition) + 
                      textToInsert + 
                      text.substring(insertPosition);
      
      // Update text directly without triggering _handleTextChange
      // by using the parent's setter
      _setTextDirectly(newText, insertPosition + textToInsert.length);
    } else {
      // Has valid selection - replace selected text with link
      final start = currentSelection.start;
      final end = currentSelection.end;
      
      // Collect existing inline formats from spans in the selected range
      // so they can be preserved when converting to a link
      final existingFormats = <FormatType>{};
      for (final span in _spans) {
        if (span.overlaps(start, end)) {
          for (final fmt in span.formats) {
            if (fmt != FormatType.link) {
              existingFormats.add(fmt);
            }
          }
        }
      }
      
      // Remove spans in the selected range
      _removeSpansInRange(start, end);
      
      // Shift spans after the selection
      final lengthDiff = textToInsert.length - (end - start);
      _shiftSpansAfter(end, lengthDiff);
      
      // Create a link span for the inserted text, preserving existing formats
      _addSpan(RichTextSpan(
        start: start,
        end: start + textToInsert.length,
        formats: {FormatType.link, ...existingFormats},
        url: url,
      ));
      
      _mergeAdjacentSpans();
      
      // Build the new text
      final newText = text.substring(0, start) + 
                      textToInsert + 
                      text.substring(end);
      
      // Update text directly without triggering _handleTextChange
      _setTextDirectly(newText, start + textToInsert.length);
    }
    
    notifyListeners();
  }

  /// Removes link formatting from spans in the specified range.
  ///
  /// This method removes [FormatType.link] and the associated URL from any
  /// spans that overlap with the [start, end) range, while preserving the
  /// display text and any other formatting (e.g., bold, italic).
  ///
  /// If a span has only link formatting, it will be removed entirely.
  /// If a span has link formatting combined with other formats, only the
  /// link format and URL will be removed.
  ///
  /// _Requirements: 5.1, 5.2_
  void removeLink(int start, int end) {
    if (start >= end) return;
    
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];
    
    for (final span in _spans) {
      // Check if span overlaps with the range and has link format
      if (!span.overlaps(start, end) || !span.formats.contains(FormatType.link)) {
        continue;
      }
      
      toRemove.add(span);
      
      // Create new span without link format
      final newFormats = Set<FormatType>.from(span.formats)..remove(FormatType.link);
      
      // Only add the span back if it has remaining formats
      if (newFormats.isNotEmpty) {
        toAdd.add(RichTextSpan(
          start: span.start,
          end: span.end,
          formats: newFormats,
          // Clear the URL since link is removed
          url: null,
        ));
      }
    }
    
    // Apply changes
    for (final span in toRemove) {
      _spans.remove(span);
    }
    _spans.addAll(toAdd);
    
    _mergeAdjacentSpans();
    notifyListeners();
  }

  /// Gets the link span at the specified cursor position.
  ///
  /// Returns the [RichTextSpan] that contains a link format at the given
  /// position, or null if no link span exists at that position.
  RichTextSpan? getLinkSpanAtPosition(int position) {
    for (final span in _spans) {
      if (span.formats.contains(FormatType.link) &&
          position >= span.start &&
          position <= span.end) {
        return span;
      }
    }
    return null;
  }

  /// Checks if the cursor is currently on a link and triggers the onLinkTap callback.
  ///
  /// This should be called when the user taps in the text field to check if
  /// they tapped on a link.
  void checkLinkTapAtCursor() {
    if (onLinkTap == null) return;
    
    final cursorPos = selection.baseOffset;
    if (cursorPos < 0) return;
    
    final linkSpan = getLinkSpanAtPosition(cursorPos);
    if (linkSpan != null) {
      onLinkTap!(linkSpan);
    }
  }

  /// Sets text directly without triggering the _handleTextChange logic.
  /// This is used when we've already manually updated the spans.
  ///
  /// Uses the normal [value] setter (instead of `super.value`) so that
  /// [EditableTextState] and [TextInputConnection] are properly notified of
  /// the new text. The [_isInternalUpdate] guard flag tells the [value] setter
  /// override to skip [_handleTextChange], avoiding double-processing of spans
  /// that have already been adjusted by the caller.
  void _setTextDirectly(String newText, int cursorPosition) {
    _isInternalUpdate = true;
    try {
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: cursorPosition.clamp(0, newText.length)),
      );
    } finally {
      _isInternalUpdate = false;
    }
  }

  /// Clears all formatting spans and active formats.
  void clearFormatting() {
    _spans.clear();
    _activeFormats.clear();
    notifyListeners();
  }

  @override
  void clear() {
    super.clear();
    clearFormatting();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Build text spans with formatting applied
    return TextSpan(
      style: style,
      children: _buildFormattedSpans(context, style),
    );
  }

  /// Builds formatted text spans for display.
  List<InlineSpan> _buildFormattedSpans(BuildContext context, TextStyle? baseStyle) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    
    final defaultStyle = baseStyle ?? TextStyle(
      color: colorPalette.textPrimary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
    );
    
    // Check if text contains blockquote lines - if so, use line-by-line processing
    if (text.contains('> ') && (text.startsWith('> ') || text.contains('\n> '))) {
      return _buildSpansWithBlockquoteBoxes(context, defaultStyle, colorPalette, spacing);
    }
    
    if (_spans.isEmpty && (formatters == null || formatters!.isEmpty)) {
      // Convert bullet list markers to bullet points for display
      var displayText = _convertBulletMarkersForDisplay(text);
      return [TextSpan(text: displayText, style: defaultStyle)];
    }
    
    // Collect all attributed text from formatters (mentions, etc.)
    final formatterAttributions = <AttributedText>[];
    for (final formatter in formatters ?? []) {
      formatterAttributions.addAll(formatter.buildInputFieldText(
        text: text,
        style: baseStyle,
        context: context,
        withComposing: false,
      ));
    }

    // Sort and merge overlapping formatter attributions
    if (formatterAttributions.isNotEmpty) {
      formatterAttributions.sort((a, b) => a.start.compareTo(b.start));
      
      // Remove rich text spans that overlap with formatter attributions (mentions)
      // This ensures mentions don't have rich text formatting applied to them
      _removeSpansOverlappingWithAttributions(formatterAttributions);
    }
    
    // Merge overlapping spans to combine their formats
    final mergedSpans = _mergeOverlappingSpans();
    
    // Sort rich text spans by start position
    mergedSpans.sort((a, b) => a.start.compareTo(b.start));
    
    final spans = <InlineSpan>[];
    int currentPos = 0;

    // Build a combined list of styled regions from both rich text spans
    // and formatter attributions (mentions, links, etc.)
    int richIdx = 0;
    int fmtIdx = 0;

    while (currentPos < text.length) {
      // Find the next rich text span and formatter attribution starting at or after currentPos
      RichTextSpan? nextRich;
      while (richIdx < mergedSpans.length) {
        final s = mergedSpans[richIdx];
        if (s.end <= currentPos || s.start >= text.length) {
          richIdx++;
          continue;
        }
        nextRich = s;
        break;
      }

      AttributedText? nextFmt;
      while (fmtIdx < formatterAttributions.length) {
        final a = formatterAttributions[fmtIdx];
        if (a.end <= currentPos || a.start >= text.length) {
          fmtIdx++;
          continue;
        }
        nextFmt = a;
        break;
      }

      // Determine the effective start of the next styled region
      final nextRichStart = nextRich != null ? (nextRich.start > currentPos ? nextRich.start : currentPos) : text.length;
      final nextFmtStart = nextFmt != null ? (nextFmt.start > currentPos ? nextFmt.start : currentPos) : text.length;
      final nextStart = nextRichStart < nextFmtStart ? nextRichStart : nextFmtStart;

      // Add unstyled text before the next styled region
      if (nextStart > currentPos) {
        final rawText = text.substring(currentPos, nextStart);
        var displayText = _convertBulletMarkersForDisplay(rawText, isLineStart: currentPos == 0 || (currentPos > 0 && text[currentPos - 1] == '\n'));
        spans.add(TextSpan(text: displayText, style: defaultStyle));
        currentPos = nextStart;
        continue;
      }

      // Formatter attributions take priority (mentions should render with their styling)
      if (nextFmt != null && nextFmt.start <= currentPos && nextFmt.end > currentPos) {
        final fmt = nextFmt;
        final fmtEnd = fmt.end.clamp(0, text.length);
        final attrStyle = (fmt.style ?? defaultStyle).copyWith(
          backgroundColor: fmt.backgroundColor,
        );
        // Note: We don't add gesture recognizers here because Flutter's RenderEditable
        // doesn't support gesture recognizers in TextSpans for editable text fields.
        // The assertion 'readOnly && !obscureText' would fail if we added recognizers.
        final rawText = fmt.underlyingText ?? text.substring(currentPos, fmtEnd);
        var displayText = _convertBulletMarkersForDisplay(rawText, isLineStart: currentPos == 0 || (currentPos > 0 && text[currentPos - 1] == '\n'));
        spans.add(TextSpan(
          text: displayText,
          style: attrStyle,
        ));
        currentPos = fmtEnd;
        if (fmt.end <= currentPos) fmtIdx++;
        continue;
      }

      // Rich text span styling
      if (nextRich != null && nextRich.start <= currentPos && nextRich.end > currentPos) {
        final richEnd = nextRich.end.clamp(0, text.length);
        // Check if a formatter attribution starts before this rich span ends
        final fmtCutoff = (nextFmt != null && nextFmt.start > currentPos && nextFmt.start < richEnd)
            ? nextFmt.start
            : richEnd;
        final rawText = text.substring(currentPos, fmtCutoff);
        var displayText = _convertBulletMarkersForDisplay(rawText, isLineStart: currentPos == 0 || (currentPos > 0 && text[currentPos - 1] == '\n'));
        final spanStyle = _getStyleForFormats(nextRich.formats, defaultStyle, context);
        
        // Note: We don't add gesture recognizers here because Flutter's RenderEditable
        // doesn't support gesture recognizers in TextSpans for editable text fields.
        // Link long-press handling should be done at a higher level (e.g., via the
        // TextField's onTap or through a separate overlay).
        
        spans.add(TextSpan(text: displayText, style: spanStyle));
        currentPos = fmtCutoff;
        if (nextRich.end <= currentPos) richIdx++;
        continue;
      }

      // Safety: advance past current position to avoid infinite loop
      if (currentPos < text.length) {
        final rawText = text.substring(currentPos, currentPos + 1);
        var displayText = _convertBulletMarkersForDisplay(rawText, isLineStart: currentPos == 0 || (currentPos > 0 && text[currentPos - 1] == '\n'));
        spans.add(TextSpan(text: displayText, style: defaultStyle));
        currentPos++;
      }
    }
    
    // If no spans were added, add the full text
    if (spans.isEmpty) {
      var displayText = _convertBulletMarkersForDisplay(text);
      spans.add(TextSpan(text: displayText, style: defaultStyle));
    }
    
    return spans;
  }
  
  /// Builds spans with blockquote lines styled with a visual indicator.
  /// 
  /// Uses TextSpan instead of WidgetSpan to ensure cursor visibility and
  /// accurate positioning within blockquote content. The blockquote prefix
  /// "> " is replaced with a visual indicator "│ " for display.
  /// 
  /// This method also applies formatting spans (bold, italic, etc.) to the
  /// blockquote content, ensuring WYSIWYG formatting works inside blockquotes.
  List<InlineSpan> _buildSpansWithBlockquoteBoxes(
    BuildContext context,
    TextStyle defaultStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    
    // Style for blockquote indicator (the "│" character)
    final blockquoteIndicatorStyle = defaultStyle.copyWith(
      color: colorPalette.primary ?? colorPalette.borderDefault,
      fontWeight: FontWeight.bold,
    );
    
    // Base style for blockquote content - use default style (same as normal text)
    // so that the text color doesn't change when blockquote is selected
    final blockquoteBaseStyle = defaultStyle;
    
    // Track current position in the original text for span mapping
    int currentTextPos = 0;
    
    // Merge overlapping spans for efficient lookup
    final mergedSpans = _mergeOverlappingSpans();
    mergedSpans.sort((a, b) => a.start.compareTo(b.start));
    
    // Collect all attributed text from formatters (mentions, etc.)
    final formatterAttributions = <AttributedText>[];
    for (final formatter in formatters ?? []) {
      formatterAttributions.addAll(formatter.buildInputFieldText(
        text: text,
        style: defaultStyle,
        context: context,
        withComposing: false,
      ));
    }
    // Sort formatter attributions by start position
    if (formatterAttributions.isNotEmpty) {
      formatterAttributions.sort((a, b) => a.start.compareTo(b.start));
    }
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isBlockquote = line.startsWith('> ');
      final lineStartPos = currentTextPos;
      
      if (isBlockquote) {
        // Replace "> " prefix with "│ " visual indicator for cursor-friendly display
        spans.add(TextSpan(text: '│ ', style: blockquoteIndicatorStyle));
        
        // Add the blockquote content (without the "> " prefix) with formatting
        final content = line.substring(2);
        final contentStartPos = lineStartPos + 2; // Skip "> "
        
        // Build formatted spans for the blockquote content
        _buildFormattedContentSpans(
          spans,
          content,
          contentStartPos,
          blockquoteBaseStyle,
          mergedSpans,
          context,
          isLineStart: true,
          formatterAttributions: formatterAttributions,
        );
      } else {
        // Regular line - build formatted spans
        _buildFormattedContentSpans(
          spans,
          line,
          lineStartPos,
          defaultStyle,
          mergedSpans,
          context,
          isLineStart: true,
          formatterAttributions: formatterAttributions,
        );
      }
      
      // Update current position (line length + newline)
      currentTextPos += line.length;
      
      // Add newline between lines (except for the last line)
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: defaultStyle));
        currentTextPos += 1; // Account for newline character
      }
    }
    
    return spans;
  }
  
  /// Builds formatted content spans for a segment of text.
  /// 
  /// This helper method applies formatting spans to a piece of content,
  /// used by both regular lines and blockquote content.
  /// 
  /// [formatterAttributions] contains attributions from formatters like mentions.
  void _buildFormattedContentSpans(
    List<InlineSpan> spans,
    String content,
    int contentStartPos,
    TextStyle baseStyle,
    List<RichTextSpan> mergedSpans,
    BuildContext context, {
    bool isLineStart = false,
    List<AttributedText>? formatterAttributions,
  }) {
    if (content.isEmpty) return;
    
    final contentEndPos = contentStartPos + content.length;
    
    // Find rich text spans that overlap with this content
    final relevantSpans = mergedSpans.where((s) => 
      s.start < contentEndPos && s.end > contentStartPos
    ).toList();
    
    // Find formatter attributions (mentions) that overlap with this content
    final relevantAttributions = formatterAttributions?.where((a) =>
      a.start < contentEndPos && a.end > contentStartPos
    ).toList() ?? [];
    
    // If no formatting at all, just add the content
    if (relevantSpans.isEmpty && relevantAttributions.isEmpty) {
      var displayContent = _convertBulletMarkersForDisplay(content, isLineStart: isLineStart);
      spans.add(TextSpan(text: displayContent, style: baseStyle));
      return;
    }
    
    // Build a list of all styled regions (both rich text spans and formatter attributions)
    // Each region has: start, end, richTextFormats, attribution
    final regions = <_StyledRegion>[];
    
    // Add rich text span regions
    for (final span in relevantSpans) {
      final regionStart = (span.start - contentStartPos).clamp(0, content.length);
      final regionEnd = (span.end - contentStartPos).clamp(0, content.length);
      if (regionEnd > regionStart) {
        regions.add(_StyledRegion(
          start: regionStart,
          end: regionEnd,
          formats: span.formats,
          url: span.url,
        ));
      }
    }
    
    // Add formatter attribution regions (mentions)
    for (final attr in relevantAttributions) {
      final regionStart = (attr.start - contentStartPos).clamp(0, content.length);
      final regionEnd = (attr.end - contentStartPos).clamp(0, content.length);
      if (regionEnd > regionStart) {
        regions.add(_StyledRegion(
          start: regionStart,
          end: regionEnd,
          attribution: attr,
        ));
      }
    }
    
    // Sort regions by start position
    regions.sort((a, b) => a.start.compareTo(b.start));
    
    // Process content character by character, applying appropriate styles
    int currentPos = 0;
    
    while (currentPos < content.length) {
      // Find all regions that contain the current position
      final activeRegions = regions.where((r) => 
        r.start <= currentPos && r.end > currentPos
      ).toList();
      
      // Find the end of the current styled segment
      int segmentEnd = content.length;
      for (final region in regions) {
        if (region.start > currentPos && region.start < segmentEnd) {
          segmentEnd = region.start;
        }
        if (region.end > currentPos && region.end < segmentEnd) {
          segmentEnd = region.end;
        }
      }
      
      // Extract the segment text
      final segmentText = content.substring(currentPos, segmentEnd);
      var displayText = _convertBulletMarkersForDisplay(
        segmentText,
        isLineStart: isLineStart && currentPos == 0,
      );
      
      if (activeRegions.isEmpty) {
        // No styling - add plain text
        spans.add(TextSpan(text: displayText, style: baseStyle));
      } else {
        // Check if there's a VALID mention attribution in active regions
        // A valid mention must have:
        // 1. Non-empty underlyingText
        // 2. backgroundColor set (mentions have pill/chip styling with background)
        // This distinguishes mentions from rich text format attributions
        final mentionRegion = activeRegions.firstWhere(
          (r) => r.attribution != null && 
                 r.attribution!.underlyingText != null && 
                 r.attribution!.underlyingText!.isNotEmpty &&
                 r.attribution!.backgroundColor != null,
          orElse: () => _StyledRegion(start: 0, end: 0),
        );
        
        // Collect any rich text formats from active regions
        final combinedFormats = <FormatType>{};
        for (final region in activeRegions) {
          if (region.formats != null) {
            combinedFormats.addAll(region.formats!);
          }
        }
        
        if (mentionRegion.attribution != null) {
          // This is a valid mention - use the attribution's style
          // Also apply any rich text formatting on top of the mention style
          final attr = mentionRegion.attribution!;
          
          // Start with the mention's style and apply rich text formats on top
          TextStyle mentionStyle = attr.style ?? baseStyle;
          if (combinedFormats.isNotEmpty) {
            mentionStyle = _getStyleForFormats(combinedFormats, mentionStyle, context);
          }
          
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: attr.padding,
              decoration: BoxDecoration(
                color: attr.backgroundColor,
                borderRadius: BorderRadius.circular(attr.borderRadius ?? 0),
              ),
              child: Text(
                displayText,
                style: mentionStyle,
              ),
            ),
          ));
        } else {
          // Apply rich text formatting only
          final spanStyle = _getStyleForFormats(combinedFormats, baseStyle, context);
          spans.add(TextSpan(text: displayText, style: spanStyle));
        }
      }
      
      currentPos = segmentEnd;
    }
  }
  
  /// Converts bullet list markers ("- ") to bullet point characters ("• ") for display.
  /// 
  /// This method replaces the markdown-style bullet markers with actual bullet
  /// point characters at the start of lines for better visual presentation.
  /// 
  /// IMPORTANT: In the composer (editable TextField), the display text length
  /// must match the model text length exactly, otherwise cursor positioning
  /// breaks. So we use "• " (2 chars) to replace "- " (2 chars).
  String _convertBulletMarkersForDisplay(String inputText, {bool isLineStart = true}) {
    if (inputText.isEmpty) return inputText;
    
    // Replace "- " at the start of lines with "• " (same length to preserve cursor mapping)
    String result = inputText;
    
    // Handle the case where the text starts with "- " and it's at the start of a line
    if (isLineStart && result.startsWith('- ')) {
      result = '• ${result.substring(2)}';
    }
    
    // Replace "- " after newlines with "• "
    result = result.replaceAll('\n- ', '\n• ');
    
    return result;
  }

  /// Gets the combined style for a set of formats.
  TextStyle _getStyleForFormats(
    Set<FormatType> formats,
    TextStyle baseStyle,
    BuildContext context,
  ) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    TextStyle result = baseStyle;
    
    // Collect decorations to combine them properly
    List<TextDecoration> decorations = [];
    
    for (final format in formats) {
      switch (format) {
        case FormatType.bold:
          result = result.copyWith(fontWeight: FontWeight.bold);
          break;
        case FormatType.italic:
          result = result.copyWith(fontStyle: FontStyle.italic);
          break;
        case FormatType.underline:
          decorations.add(TextDecoration.underline);
          break;
        case FormatType.strikethrough:
          decorations.add(TextDecoration.lineThrough);
          break;
        case FormatType.inlineCode:
          result = result.copyWith(
            fontFamily: 'monospace',
            color: richTextStyle?.inlineCodeTextStyle?.color ?? colorPalette.primary,
            backgroundColor: richTextStyle?.inlineCodeBackgroundColor ?? 
                colorPalette.background3,
          );
          break;
        case FormatType.codeBlock:
          result = result.copyWith(
            fontFamily: 'monospace',
            backgroundColor: richTextStyle?.codeBlockBackgroundColor ?? 
                colorPalette.background3,
          );
          break;
        case FormatType.link:
          decorations.add(TextDecoration.underline);
          result = result.copyWith(
            color: richTextStyle?.linkColor ?? colorPalette.primary,
          );
          break;
        case FormatType.bulletList:
        case FormatType.orderedList:
          // These are line-level formats, handled differently
          break;
        case FormatType.blockquote:
          // Blockquote text keeps normal style - visual indicator is the │ prefix
          break;
      }
    }
    
    // Apply combined decorations with matching decoration color
    if (decorations.isNotEmpty) {
      result = result.copyWith(
        decoration: TextDecoration.combine(decorations),
        decorationColor: result.color,
      );
    }
    
    return result;
  }

  /// Loads markdown text for editing, converting it to WYSIWYG format.
  ///
  /// This method strips the markdown markers and creates spans for the
  /// formatted regions, allowing the user to edit the text in WYSIWYG mode.
  void loadMarkdown(String markdownText) {
    // Clear existing state
    _spans.clear();
    _activeFormats.clear();
    
    // Parse the markdown and create spans
    _parseMarkdownToSpans(markdownText);
  }

  /// Sets the text without parsing markdown.
  ///
  /// Use this when you want to set plain text without any formatting.
  void setPlainText(String plainText) {
    _spans.clear();
    _activeFormats.clear();
    text = plainText;
  }
}

/// Helper class for HTML parsing result.
class _HtmlParseResult {
  final String text;
  final List<RichTextSpan> spans;
  
  _HtmlParseResult({required this.text, required this.spans});
}

/// Helper class for markdown parsing result.
class _MarkdownParseResult {
  final String text;
  final List<RichTextSpan> spans;
  
  _MarkdownParseResult({required this.text, required this.spans});
}

/// Helper class for tracking format stack during HTML parsing.
class _FormatStackEntry {
  final String tagName;
  final FormatType format;
  final int startPos;
  final String? url;
  
  _FormatStackEntry({
    required this.tagName,
    required this.format,
    required this.startPos,
    this.url,
  });
}

/// Helper class for URL detection results.
class _UrlMatch {
  final int start;
  final int end;
  final String displayText;
  final String url;
  
  _UrlMatch({
    required this.start,
    required this.end,
    required this.displayText,
    required this.url,
  });
}

/// Helper class for tracking styled regions during content building.
/// Used to combine rich text formatting with formatter attributions (mentions).
class _StyledRegion {
  final int start;
  final int end;
  final Set<FormatType>? formats;
  final String? url;
  final AttributedText? attribution;
  
  _StyledRegion({
    required this.start,
    required this.end,
    this.formats,
    this.url,
    this.attribution,
  });
}
