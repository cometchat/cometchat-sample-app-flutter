import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Controller for managing a segmented composer with code block support.
/// 
/// The composer maintains a list of segments that alternate between normal
/// text segments and code block segments. Each segment has its own
/// [TextEditingController] and [FocusNode].
/// 
/// Key behaviors:
/// - Code blocks are inserted/removed via [toggleCodeBlock]
/// - Triple-Enter exits a code block
/// - Backspace on empty code block removes it
/// - Backspace on empty normal segment focuses previous code block
/// - Normal segments between code blocks are hidden when empty
class SegmentedComposerController extends ChangeNotifier {
  /// Creates a new segmented composer controller.
  /// 
  /// [formatters] are applied to normal segments for mentions, etc.
  /// [richTextStyle] provides styling for rich text formatting.
  /// [initialMarkdown] is the initial markdown text (with formatting preserved).
  SegmentedComposerController({
    this.formatters,
    this.richTextStyle,
    String? initialMarkdown,
  }) {
    // Initialize with a single normal segment, loading markdown if provided
    if (initialMarkdown != null && initialMarkdown.isNotEmpty) {
      _addNormalSegmentWithMarkdown(initialMarkdown);
    } else {
      _addNormalSegment('');
    }
  }

  /// Text formatters for normal segments (mentions, etc.)
  final List<CometChatTextFormatter>? formatters;

  /// Style configuration for rich text formatting
  final CometChatRichTextFormatterStyle? richTextStyle;

  /// The list of segments in the composer.
  final List<ComposerSegment> _segments = [];

  /// Counter for generating unique segment IDs.
  int _segmentIdCounter = 0;

  /// The ID of the currently active code segment, if any.
  String? _activeCodeId;

  /// The segment that should receive focus after the next rebuild.
  ComposerSegment? _pendingFocusSegment;
  
  /// The last segment that had focus, used as fallback when focus is lost
  /// (e.g., when user taps toolbar button).
  ComposerSegment? _lastFocusedSegment;

  /// Flag to suppress code exit watch during programmatic text changes.
  bool _suppressCodeExitWatch = false;

  /// Flag to prevent re-entrancy during code exit handling.
  bool _handlingCodeExit = false;

  /// Gets the list of segments (read-only).
  List<ComposerSegment> get segments => List.unmodifiable(_segments);

  /// Gets the currently focused segment, or null if none.
  /// 
  /// If no segment currently has focus (e.g., when user taps toolbar button),
  /// returns the last segment that had focus as a fallback.
  ComposerSegment? get focusedSegment {
    for (final segment in _segments) {
      if (segment.hasFocus) {
        _lastFocusedSegment = segment;
        return segment;
      }
    }
    // Fallback to last focused segment if it still exists in segments
    if (_lastFocusedSegment != null && _segments.contains(_lastFocusedSegment)) {
      return _lastFocusedSegment;
    }
    return null;
  }

  /// Gets the active code segment ID.
  String? get activeCodeId => _activeCodeId;

  /// Gets the pending focus segment.
  ComposerSegment? get pendingFocusSegment => _pendingFocusSegment;

  /// Clears the pending focus segment after it has been handled.
  void clearPendingFocus() {
    _pendingFocusSegment = null;
  }
  
  /// Sets the last focused segment manually.
  /// 
  /// This is used when programmatically setting up a segment with a selection
  /// before focus has been processed by the framework.
  void setLastFocusedSegment(ComposerSegment segment) {
    if (_segments.contains(segment)) {
      _lastFocusedSegment = segment;
    }
  }

  /// Returns true if there are any code segments.
  bool get hasCodeBlocks => _segments.any((s) => s.type == SegmentType.code);

  /// Returns true if the composer has any content.
  /// 
  /// Returns true if any segment has non-empty text.
  /// Empty code blocks do not count as content.
  bool get hasContent {
    for (final segment in _segments) {
      if (segment.isNotEmpty) return true;
    }
    return false;
  }

  /// Alias for [hasContent] for compatibility.
  bool get hasSegmentContent => hasContent;

  /// Gets the active formats for the toolbar.
  /// 
  /// When focused on a code segment, returns {FormatType.codeBlock}.
  /// When focused on a normal segment, delegates to the RichTextEditingController.
  Set<FormatType> get activeFormats {
    final focused = focusedSegment;
    if (focused == null) return {};
    
    if (focused.type == SegmentType.code) {
      return {FormatType.codeBlock};
    }
    
    // For normal segments, get formats from the RichTextEditingController
    if (focused.controller is RichTextEditingController) {
      return (focused.controller as RichTextEditingController).activeFormats;
    }
    
    return {};
  }

  /// Gets the disabled formats for the toolbar.
  /// 
  /// When focused on a code segment, inline formats are disabled but block formats
  /// (orderedList, bulletList, blockquote) remain available.
  Set<FormatType> get disabledFormats {
    final focused = focusedSegment;
    if (focused == null) return {};
    
    if (focused.type == SegmentType.code) {
      // Only inline formats are disabled - block formats remain available
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

  // ============================================================================
  // SEGMENT MANAGEMENT
  // ============================================================================

  /// Loads markdown text that may contain fenced code blocks.
  /// 
  /// This parses the markdown and creates appropriate segments:
  /// - Normal segments for text outside code blocks (with rich text formatting)
  /// - Code segments for fenced code blocks (```...```)
  /// - Code segments inside blockquotes (> ```...```) are marked with isInsideBlockquote
  /// 
  /// The [markdownText] should have mentions already converted to display format.
  void loadFromMarkdown(String markdownText) {
    // Clear existing segments
    for (final segment in _segments) {
      segment.dispose();
    }
    _segments.clear();
    _activeCodeId = null;
    _pendingFocusSegment = null;
    
    // Parse the markdown to extract code blocks and normal text
    // This pattern matches both:
    // 1. Multi-line code blocks: ```lang\ncode\n``` or > ```lang\n> code\n> ```
    // 2. Inline code blocks: ```code``` (no newlines)
    // Pattern explanation:
    // - ((?:> )?```) - opening backticks, optionally with blockquote prefix
    // - (\w*(?=\n))? - optional language identifier (only if followed by newline)
    // - (\n)? - optional newline after opening/language
    // - ([\s\S]*?) - code content (non-greedy)
    // - ((?:> )?```) - closing backticks
    final codeBlockPattern = RegExp(r'((?:> )?```)(\w*(?=\n))?(\n)?([\s\S]*?)((?:> )?```)', multiLine: true);
    
    int lastEnd = 0;
    bool hasCodeBlocks = false;
    
    for (final match in codeBlockPattern.allMatches(markdownText)) {
      hasCodeBlocks = true;
      
      // Check if this code block is inside a blockquote
      final openingMarker = match.group(1) ?? '';
      final isInsideBlockquote = openingMarker.startsWith('> ');
      
      // Add normal segment for text before this code block
      if (match.start > lastEnd) {
        final normalText = markdownText.substring(lastEnd, match.start).trim();
        if (normalText.isNotEmpty || _segments.isEmpty) {
          _addNormalSegmentWithMarkdown(normalText);
        }
      } else if (_segments.isEmpty) {
        // Ensure there's a normal segment before the first code block
        _addNormalSegment('');
      }
      
      // Add code segment
      final language = match.group(2) ?? '';
      String codeContent = match.group(4) ?? '';
      
      // If inside blockquote, strip the "> " prefix from each line of the code content
      if (isInsideBlockquote) {
        final lines = codeContent.split('\n');
        codeContent = lines.map((line) => line.startsWith('> ') ? line.substring(2) : line).join('\n');
      }
      
      _addCodeSegment(codeContent.trimRight(), language: language, isInsideBlockquote: isInsideBlockquote);
      
      lastEnd = match.end;
    }
    
    // Add remaining text after the last code block (or all text if no code blocks)
    if (lastEnd < markdownText.length) {
      final remainingText = markdownText.substring(lastEnd).trim();
      if (hasCodeBlocks) {
        // After code blocks, add as normal segment
        _addNormalSegmentWithMarkdown(remainingText);
      } else {
        // No code blocks - just load as single normal segment with markdown
        _addNormalSegmentWithMarkdown(markdownText);
      }
    } else if (hasCodeBlocks && (_segments.isEmpty || _segments.last.type == SegmentType.code)) {
      // Ensure there's a normal segment after the last code block
      _addNormalSegment('');
    }
    
    // Ensure at least one segment exists
    if (_segments.isEmpty) {
      _addNormalSegment('');
    }
    
    notifyListeners();
  }

  /// Creates and adds a normal segment, loading markdown formatting.
  ComposerSegment _addNormalSegmentWithMarkdown(String markdownText, {int? insertAt}) {
    final controller = RichTextEditingController(
      formatters: formatters,
      richTextStyle: richTextStyle,
    );
    
    // Load the markdown (this parses formatting like **bold**, _italic_, etc.)
    if (markdownText.isNotEmpty) {
      controller.loadMarkdown(markdownText);
    }
    
    // Wire up the onInsertCodeBlock callback
    controller.onInsertCodeBlock = () {
      toggleCodeBlock();
    };
    
    final focusNode = FocusNode();
    final segment = ComposerSegment(
      id: _generateSegmentId(),
      type: SegmentType.normal,
      controller: controller,
      focusNode: focusNode,
    );
    
    // Add listeners
    controller.addListener(() => _onSegmentTextChanged(segment));
    focusNode.addListener(() => _onSegmentFocusChanged(segment));
    
    if (insertAt != null && insertAt >= 0 && insertAt <= _segments.length) {
      _segments.insert(insertAt, segment);
    } else {
      _segments.add(segment);
    }
    
    return segment;
  }

  /// Generates a unique segment ID.
  String _generateSegmentId() {
    return 'seg${_segmentIdCounter++}';
  }

  /// Creates and adds a normal segment with the given text.
  ComposerSegment _addNormalSegment(String text, {int? insertAt}) {
    final controller = RichTextEditingController(
      text: text,
      formatters: formatters,
      richTextStyle: richTextStyle,
    );
    
    // Wire up the onInsertCodeBlock callback
    controller.onInsertCodeBlock = () {
      toggleCodeBlock();
    };
    
    final focusNode = FocusNode();
    final segment = ComposerSegment(
      id: _generateSegmentId(),
      type: SegmentType.normal,
      controller: controller,
      focusNode: focusNode,
    );
    
    // Add listeners
    controller.addListener(() => _onSegmentTextChanged(segment));
    focusNode.addListener(() => _onSegmentFocusChanged(segment));
    
    if (insertAt != null && insertAt >= 0 && insertAt <= _segments.length) {
      _segments.insert(insertAt, segment);
    } else {
      _segments.add(segment);
    }
    
    return segment;
  }

  /// Creates and adds a code segment with the given text.
  /// 
  /// If [isInsideBlockquote] is true, the code segment is marked as being
  /// inside a blockquote context. This affects how the code block is rendered
  /// and how the final markdown is generated.
  ComposerSegment _addCodeSegment(String text, {int? insertAt, String language = '', bool isInsideBlockquote = false}) {
    final controller = TextEditingController(text: text);
    final focusNode = FocusNode();
    final segment = ComposerSegment(
      id: _generateSegmentId(),
      type: SegmentType.code,
      controller: controller,
      focusNode: focusNode,
      language: language,
      isInsideBlockquote: isInsideBlockquote,
    );
    
    // Add listeners
    controller.addListener(() => _onCodeSegmentTextChanged(segment));
    focusNode.addListener(() => _onSegmentFocusChanged(segment));
    
    if (insertAt != null && insertAt >= 0 && insertAt <= _segments.length) {
      _segments.insert(insertAt, segment);
    } else {
      _segments.add(segment);
    }
    
    _activeCodeId = segment.id;
    return segment;
  }

  /// Removes a segment and disposes its resources.
  void _removeSegment(ComposerSegment segment) {
    _segments.remove(segment);
    segment.dispose();
    
    if (_activeCodeId == segment.id) {
      _activeCodeId = null;
    }
    
    // Clear last focused segment if it was the removed segment
    if (_lastFocusedSegment == segment) {
      _lastFocusedSegment = null;
    }
  }

  /// Called when any segment's text changes.
  void _onSegmentTextChanged(ComposerSegment segment) {
    notifyListeners();
  }

  /// Called when a code segment's text changes.
  /// Watches for triple-Enter to exit the code block.
  void _onCodeSegmentTextChanged(ComposerSegment segment) {
    if (_suppressCodeExitWatch || _handlingCodeExit) {
      notifyListeners();
      return;
    }
    
    // Check for triple-Enter (exit code block)
    if (segment.text.endsWith('\n\n\n')) {
      _handleCodeExit(segment);
      return;
    }
    
    notifyListeners();
  }

  /// Called when any segment's focus changes.
  void _onSegmentFocusChanged(ComposerSegment segment) {
    if (segment.hasFocus) {
      _lastFocusedSegment = segment;
      if (segment.type == SegmentType.code) {
        _activeCodeId = segment.id;
      }
    }
    notifyListeners();
  }

  // ============================================================================
  // CODE BLOCK OPERATIONS
  // ============================================================================

  /// Toggles code block mode.
  /// 
  /// If currently in a normal segment, inserts a code block.
  /// If currently in a code segment, removes it.
  void toggleCodeBlock() {
    final focused = focusedSegment;
    if (focused == null) {
      // No focus - insert at end
      insertCodeBlock();
      return;
    }
    
    if (focused.type == SegmentType.code) {
      // Currently in code block - remove it
      removeCodeSegment(focused);
    } else {
      // Currently in normal segment - insert code block
      insertCodeBlock();
    }
  }

  /// Inserts a new code block based on the current selection/cursor.
  void insertCodeBlock() {
    final focused = focusedSegment;
    
    if (focused == null) {
      // No focus - check if first segment has content
      if (_segments.isNotEmpty && _segments.first.type == SegmentType.normal) {
        final firstSegment = _segments.first;
        if (firstSegment.text.isNotEmpty) {
          // Convert the first segment's content to code block
          _insertCodeBlockFromLine(firstSegment);
          return;
        }
      }
      // No content - insert empty code block at end
      _insertEmptyCodeBlock();
      return;
    }
    
    if (focused.type == SegmentType.code) {
      // Already in code - insert empty code block at end
      _insertEmptyCodeBlock();
      return;
    }
    
    final text = focused.text;
    final selection = focused.controller.selection;
    
    // Scenario A: Selected text exists
    if (!selection.isCollapsed && selection.isValid) {
      _insertCodeBlockWithSelection(focused, selection);
      return;
    }
    
    // Scenario B: Cursor on a line with text OR empty segment
    // (handles both cases - text gets included, empty stays empty)
    _insertCodeBlockFromLine(focused);
  }

  /// Inserts an empty code block at the end.
  void _insertEmptyCodeBlock() {
    // Ensure there's a normal segment before
    if (_segments.isEmpty || _segments.last.type == SegmentType.code) {
      _addNormalSegment('');
    }
    
    // Add code segment
    final codeSegment = _addCodeSegment('');
    
    // Ensure there's a normal segment after
    _addNormalSegment('');
    
    // Focus the code segment
    _requestFocus(codeSegment);
    notifyListeners();
  }

  /// Inserts a code block with the selected text.
  /// 
  /// If the selected text is inside a blockquote (starts with "> "), the code
  /// block will be inserted inside the blockquote context.
  void _insertCodeBlockWithSelection(ComposerSegment normalSegment, TextSelection selection) {
    final text = normalSegment.text;
    final selectedText = text.substring(selection.start, selection.end);
    final beforeText = text.substring(0, selection.start);
    final afterText = text.substring(selection.end);
    
    // Check if the selected text is inside a blockquote
    // We check if the line containing the selection start has a blockquote prefix
    final lineStart = text.lastIndexOf('\n', selection.start > 0 ? selection.start - 1 : 0) + 1;
    final lineText = text.substring(lineStart, selection.start);
    final isInsideBlockquote = lineText.isEmpty && text.substring(lineStart).startsWith('> ') ||
                               beforeText.endsWith('> ') ||
                               (lineStart < text.length && text.substring(lineStart).startsWith('> '));
    
    // Strip blockquote prefix from selected text if applicable
    String codeContent = selectedText;
    if (isInsideBlockquote) {
      // Remove "> " prefix from each line of the selected text
      final lines = selectedText.split('\n');
      codeContent = lines.map((line) => line.startsWith('> ') ? line.substring(2) : line).join('\n');
    }

    // Strip list prefixes (bullet "- " or ordered "N. ") from each line
    {
      final lines = codeContent.split('\n');
      codeContent = lines.map((line) {
        final bullet = RegExp(r'^- (.*)$').firstMatch(line);
        if (bullet != null) return bullet.group(1) ?? '';
        final ordered = RegExp(r'^\d+\. (.*)$').firstMatch(line);
        if (ordered != null) return ordered.group(1) ?? '';
        return line;
      }).join('\n');
    }
    
    final segmentIndex = _segments.indexOf(normalSegment);
    
    // Update the normal segment with text before selection
    // Set selection first to avoid invalid selection during text change
    final safeBeforePos = beforeText.length.clamp(0, beforeText.length);
    normalSegment.controller.selection = TextSelection.collapsed(offset: safeBeforePos);
    normalSegment.controller.text = beforeText;
    
    // Insert code segment after the normal segment
    final codeSegment = _addCodeSegment(codeContent, insertAt: segmentIndex + 1, isInsideBlockquote: isInsideBlockquote);
    
    // Insert normal segment after code segment with remaining text
    // If inside blockquote, ensure the after segment continues the blockquote
    String afterSegmentText = afterText;
    if (isInsideBlockquote && afterText.isNotEmpty && !afterText.startsWith('> ')) {
      // Add blockquote prefix to continue the blockquote context
      afterSegmentText = '> $afterText';
    } else if (isInsideBlockquote && afterText.isEmpty) {
      // Empty after text but inside blockquote - add blockquote prefix
      afterSegmentText = '> ';
    }
    
    if (afterSegmentText.isNotEmpty || segmentIndex + 2 >= _segments.length || _segments[segmentIndex + 2].type == SegmentType.code) {
      _addNormalSegment(afterSegmentText, insertAt: segmentIndex + 2);
    }
    
    // Focus the code segment
    _requestFocus(codeSegment);
    notifyListeners();
  }

  /// Inserts a code block from the current line.
  /// 
  /// If the current line is inside a blockquote (starts with "> "), the code
  /// block will be extracted from the blockquote context. The blockquote
  /// prefix is stripped from the code content, and the code block is created
  /// as a regular code block (not inside blockquote).
  void _insertCodeBlockFromLine(ComposerSegment normalSegment) {
    final text = normalSegment.text;
    final cursorPos = normalSegment.controller.selection.baseOffset.clamp(0, text.length);
    
    // Find line boundaries
    final lineStart = text.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;
    int lineEnd = text.indexOf('\n', cursorPos);
    if (lineEnd == -1) lineEnd = text.length;
    
    // Ensure lineEnd is not less than lineStart (can happen with leading newlines)
    if (lineEnd < lineStart) lineEnd = lineStart;
    
    final lineText = text.substring(lineStart, lineEnd);
    final beforeText = lineStart > 0 ? text.substring(0, lineStart - 1) : ''; // Remove trailing \n
    final afterText = lineEnd < text.length ? text.substring(lineEnd + 1) : ''; // Remove leading \n
    
    // Check if the current line is inside a blockquote
    final isInsideBlockquote = lineText.startsWith('> ');
    
    // Strip blockquote prefix from line content for code block
    String codeContent = lineText;
    if (isInsideBlockquote) {
      codeContent = lineText.substring(2); // Remove "> " prefix
    }

    // Strip list prefixes (bullet "- " or ordered "N. ") from code content
    final bulletMatch = RegExp(r'^- (.*)$').firstMatch(codeContent);
    if (bulletMatch != null) {
      codeContent = bulletMatch.group(1) ?? '';
    } else {
      final orderedMatch = RegExp(r'^\d+\. (.*)$').firstMatch(codeContent);
      if (orderedMatch != null) {
        codeContent = orderedMatch.group(1) ?? '';
      }
    }
    
    final segmentIndex = _segments.indexOf(normalSegment);
    
    // Special case: current line is empty (or just blockquote prefix) - insert empty code block
    final isEffectivelyEmpty = lineText.isEmpty || (isInsideBlockquote && codeContent.isEmpty);
    if (isEffectivelyEmpty) {
      // If there's text before or after, split the segment
      if (beforeText.isNotEmpty || afterText.isNotEmpty) {
        // Update normal segment with before text
        // Set selection first to avoid invalid selection during text change
        final safeBeforePos = beforeText.length.clamp(0, beforeText.length);
        normalSegment.controller.selection = TextSelection.collapsed(offset: safeBeforePos);
        normalSegment.controller.text = beforeText;
        
        // Insert code segment (empty) - always as regular code block, not inside blockquote
        final codeSegment = _addCodeSegment('', insertAt: segmentIndex + 1, isInsideBlockquote: false);
        
        // Insert normal segment with after text if needed
        if (afterText.isNotEmpty) {
          _addNormalSegment(afterText, insertAt: segmentIndex + 2);
        } else {
          // Ensure there's a normal segment after for cursor navigation
          _addNormalSegment('', insertAt: segmentIndex + 2);
        }
        
        _requestFocus(codeSegment);
        notifyListeners();
        return;
      }
      // Fall through to single line case if both before and after are empty
    }
    
    // Special case: single line (entire text becomes code)
    if (beforeText.isEmpty && afterText.isEmpty) {
      // Replace in-place
      _removeSegment(normalSegment);
      
      // Ensure normal segment before
      if (segmentIndex == 0 || _segments.isEmpty || _segments[segmentIndex > 0 ? segmentIndex - 1 : 0].type == SegmentType.code) {
        _addNormalSegment('', insertAt: segmentIndex > 0 ? segmentIndex : 0);
      }
      
      final insertIdx = segmentIndex > 0 ? segmentIndex : (_segments.isNotEmpty ? 1 : 0);
      // Code block is always created as regular code block, not inside blockquote
      final codeSegment = _addCodeSegment(codeContent, insertAt: insertIdx, isInsideBlockquote: false);
      
      // Ensure normal segment after
      _addNormalSegment('', insertAt: insertIdx + 1);
      
      _requestFocus(codeSegment);
      notifyListeners();
      return;
    }
    
    // Update normal segment with before text
    // Set selection first to avoid invalid selection during text change
    final safeBeforePos = beforeText.length.clamp(0, beforeText.length);
    normalSegment.controller.selection = TextSelection.collapsed(offset: safeBeforePos);
    normalSegment.controller.text = beforeText;
    
    // Insert code segment with the line text (stripped of blockquote prefix if applicable)
    // Code block is always created as regular code block, not inside blockquote
    final codeSegment = _addCodeSegment(codeContent, insertAt: segmentIndex + 1, isInsideBlockquote: false);
    
    // Insert normal segment with after text
    _addNormalSegment(afterText.isNotEmpty ? afterText : '', insertAt: segmentIndex + 2);
    
    _requestFocus(codeSegment);
    notifyListeners();
  }

  /// Removes a code segment and merges its content back into surrounding normal segments.
  /// 
  /// If the code segment was inside a blockquote, the code content is restored
  /// with the blockquote prefix.
  void removeCodeSegment(ComposerSegment codeSegment) {
    if (codeSegment.type != SegmentType.code) return;
    
    final codeIndex = _segments.indexOf(codeSegment);
    if (codeIndex == -1) return;
    
    final codeText = codeSegment.text;
    final isInsideBlockquote = codeSegment.isInsideBlockquote;
    
    // If inside blockquote, restore the blockquote prefix to the code content
    String restoredCodeText = codeText;
    if (isInsideBlockquote && codeText.isNotEmpty) {
      // Add "> " prefix to each line of the code content
      final lines = codeText.split('\n');
      restoredCodeText = lines.map((line) => '> $line').join('\n');
    }
    
    // Find surrounding normal segments
    ComposerSegment? prevNormal;
    ComposerSegment? nextNormal;
    String prevText = '';
    String nextText = '';
    
    if (codeIndex > 0 && _segments[codeIndex - 1].type == SegmentType.normal) {
      prevNormal = _segments[codeIndex - 1];
      prevText = prevNormal.text;
    }
    
    if (codeIndex < _segments.length - 1 && _segments[codeIndex + 1].type == SegmentType.normal) {
      nextNormal = _segments[codeIndex + 1];
      nextText = nextNormal.text;
    }
    
    // Remove next normal first (higher index)
    if (nextNormal != null) {
      _removeSegment(nextNormal);
    }
    
    // Remove code segment
    _removeSegment(codeSegment);
    
    // Merge text with smart separators
    final sep1 = (prevText.isNotEmpty && restoredCodeText.isNotEmpty) ? '\n' : '';
    final sep2 = (restoredCodeText.isNotEmpty && nextText.isNotEmpty) ? '\n' : '';
    final mergedText = '$prevText$sep1$restoredCodeText$sep2$nextText';
    
    // Calculate cursor position (at end of code text)
    final cursorPos = prevText.length + sep1.length + restoredCodeText.length;
    
    if (prevNormal != null) {
      // Update previous normal segment - use setPlainText for RichTextEditingController
      // to properly clear spans before setting new text
      if (prevNormal.controller is RichTextEditingController) {
        (prevNormal.controller as RichTextEditingController).setPlainText(mergedText);
      } else {
        prevNormal.controller.text = mergedText;
      }
      // Set selection after text change to ensure it's correct
      final safePos = cursorPos.clamp(0, mergedText.length);
      prevNormal.controller.selection = TextSelection.collapsed(offset: safePos);
      _requestFocus(prevNormal);
    } else {
      // Create new normal segment at index 0
      final newSegment = _addNormalSegment(mergedText, insertAt: 0);
      final safePos = cursorPos.clamp(0, mergedText.length);
      newSegment.controller.selection = TextSelection.collapsed(offset: safePos);
      _requestFocus(newSegment);
    }
    
    // Ensure at least one segment exists
    if (_segments.isEmpty) {
      _addNormalSegment('');
    }
    
    notifyListeners();
  }

  /// Converts a code segment to a normal segment in place.
  /// 
  /// Unlike [removeCodeSegment] which merges the code content with surrounding
  /// segments, this method replaces the code segment with a normal segment
  /// containing the same text. This is used when switching from code block
  /// to list/blockquote format.
  void convertCodeSegmentToNormal(ComposerSegment codeSegment) {
    if (codeSegment.type != SegmentType.code) return;
    
    final codeIndex = _segments.indexOf(codeSegment);
    if (codeIndex == -1) return;
    
    final codeText = codeSegment.text;
    final isInsideBlockquote = codeSegment.isInsideBlockquote;
    
    // If inside blockquote, restore the blockquote prefix to the code content
    String restoredText = codeText;
    if (isInsideBlockquote && codeText.isNotEmpty) {
      // Add "> " prefix to each line of the code content
      final lines = codeText.split('\n');
      restoredText = lines.map((line) => '> $line').join('\n');
    }
    
    // Find surrounding normal segments
    ComposerSegment? prevNormal;
    ComposerSegment? nextNormal;
    String prevText = '';
    String nextText = '';
    
    if (codeIndex > 0 && _segments[codeIndex - 1].type == SegmentType.normal) {
      prevNormal = _segments[codeIndex - 1];
      prevText = prevNormal.text;
    }
    
    if (codeIndex < _segments.length - 1 && _segments[codeIndex + 1].type == SegmentType.normal) {
      nextNormal = _segments[codeIndex + 1];
      nextText = nextNormal.text;
    }
    
    // Remove next normal first (higher index)
    if (nextNormal != null) {
      _removeSegment(nextNormal);
    }
    
    // Remove code segment
    _removeSegment(codeSegment);
    
    // Merge text with smart separators
    final sep1 = (prevText.isNotEmpty && restoredText.isNotEmpty) ? '\n' : '';
    final sep2 = (restoredText.isNotEmpty && nextText.isNotEmpty) ? '\n' : '';
    final mergedText = '$prevText$sep1$restoredText$sep2$nextText';
    
    // Calculate cursor position (at end of restored text)
    final cursorPos = prevText.length + sep1.length + restoredText.length;
    
    if (prevNormal != null) {
      // Update previous normal segment - use setPlainText for RichTextEditingController
      // to properly clear spans before setting new text
      if (prevNormal.controller is RichTextEditingController) {
        (prevNormal.controller as RichTextEditingController).setPlainText(mergedText);
      } else {
        prevNormal.controller.text = mergedText;
      }
      final safePos = cursorPos.clamp(0, mergedText.length);
      prevNormal.controller.selection = TextSelection.collapsed(offset: safePos);
      _requestFocus(prevNormal);
    } else {
      // Create new normal segment at index 0
      final newSegment = _addNormalSegment(mergedText, insertAt: 0);
      final safePos = cursorPos.clamp(0, mergedText.length);
      newSegment.controller.selection = TextSelection.collapsed(offset: safePos);
      _requestFocus(newSegment);
    }
    
    // Ensure at least one segment exists
    if (_segments.isEmpty) {
      _addNormalSegment('');
    }
    
    notifyListeners();
  }

  /// Extracts the current line from a code segment and converts it to a normal segment.
  /// 
  /// This splits the code block at the cursor position:
  /// - Text before the current line stays in a code block (if not empty)
  /// - The current line becomes a normal segment
  /// - Text after the current line stays in a code block (if not empty)
  /// 
  /// Returns the newly created normal segment containing the extracted line,
  /// or null if extraction failed.
  ComposerSegment? extractLineFromCodeSegment(ComposerSegment codeSegment) {
    if (codeSegment.type != SegmentType.code) return null;
    
    final codeIndex = _segments.indexOf(codeSegment);
    if (codeIndex == -1) return null;
    
    final codeText = codeSegment.text;
    final cursorPos = codeSegment.controller.selection.baseOffset.clamp(0, codeText.length);
    final isInsideBlockquote = codeSegment.isInsideBlockquote;
    
    // Find line boundaries
    final lineStart = codeText.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;
    int lineEnd = codeText.indexOf('\n', cursorPos);
    if (lineEnd == -1) lineEnd = codeText.length;
    
    // Ensure lineEnd is not less than lineStart
    if (lineEnd < lineStart) lineEnd = lineStart;
    
    // Extract the parts
    final beforeText = lineStart > 0 ? codeText.substring(0, lineStart - 1) : ''; // Remove trailing \n
    final lineText = codeText.substring(lineStart, lineEnd);
    final afterText = lineEnd < codeText.length ? codeText.substring(lineEnd + 1) : ''; // Remove leading \n
    
    // Find surrounding normal segments
    ComposerSegment? prevNormal;
    ComposerSegment? nextNormal;
    
    if (codeIndex > 0 && _segments[codeIndex - 1].type == SegmentType.normal) {
      prevNormal = _segments[codeIndex - 1];
    }
    
    if (codeIndex < _segments.length - 1 && _segments[codeIndex + 1].type == SegmentType.normal) {
      nextNormal = _segments[codeIndex + 1];
    }
    
    // Remove the original code segment
    _removeSegment(codeSegment);
    
    // Calculate insertion index (where the code segment was)
    int insertIdx = codeIndex;
    
    // Add code block for text before the line (if not empty)
    if (beforeText.isNotEmpty) {
      _addCodeSegment(beforeText, insertAt: insertIdx, isInsideBlockquote: isInsideBlockquote);
      insertIdx++;
      // Add a normal segment between code blocks if needed
      _addNormalSegment('', insertAt: insertIdx);
      insertIdx++;
    }
    
    // Add normal segment for the extracted line
    final normalSegment = _addNormalSegment(lineText, insertAt: insertIdx);
    insertIdx++;
    
    // Add code block for text after the line (if not empty)
    if (afterText.isNotEmpty) {
      // Add a normal segment between the extracted line and the after code block
      _addNormalSegment('', insertAt: insertIdx);
      insertIdx++;
      _addCodeSegment(afterText, insertAt: insertIdx, isInsideBlockquote: isInsideBlockquote);
    }
    
    // Position cursor at end of the extracted line
    normalSegment.controller.selection = TextSelection.collapsed(offset: lineText.length);
    _requestFocus(normalSegment);
    
    notifyListeners();
    return normalSegment;
  }

  /// Handles the triple-Enter exit from a code block.
  /// 
  /// If the code block was inside a blockquote, the next normal segment
  /// continues the blockquote context.
  void _handleCodeExit(ComposerSegment codeSegment) {
    if (_handlingCodeExit) return;
    _handlingCodeExit = true;
    
    // Trim the trailing newlines
    _suppressCodeExitWatch = true;
    final trimmedText = codeSegment.text.substring(0, codeSegment.text.length - 3);
    // Set selection first to avoid invalid selection during text change
    final safeTrimmedPos = trimmedText.length.clamp(0, trimmedText.length);
    codeSegment.controller.selection = TextSelection.collapsed(offset: safeTrimmedPos);
    codeSegment.controller.text = trimmedText;
    _suppressCodeExitWatch = false;
    
    // Clear active code ID
    _activeCodeId = null;
    
    // Check if the code block was inside a blockquote
    final isInsideBlockquote = codeSegment.isInsideBlockquote;
    
    // Find or create the next normal segment
    final codeIndex = _segments.indexOf(codeSegment);
    ComposerSegment? nextNormal;
    
    if (codeIndex < _segments.length - 1 && _segments[codeIndex + 1].type == SegmentType.normal) {
      nextNormal = _segments[codeIndex + 1];
      // If inside blockquote and next segment is empty, add blockquote prefix
      if (isInsideBlockquote && nextNormal.isEmpty) {
        // Set selection first to avoid invalid selection during text change
        nextNormal.controller.selection = TextSelection.collapsed(offset: 0);
        nextNormal.controller.text = '> ';
        nextNormal.controller.selection = TextSelection.collapsed(offset: 2);
      }
    } else {
      // Create a new normal segment after the code block
      // If inside blockquote, start with blockquote prefix
      nextNormal = _addNormalSegment(isInsideBlockquote ? '> ' : '', insertAt: codeIndex + 1);
      if (isInsideBlockquote) {
        nextNormal.controller.selection = TextSelection.collapsed(offset: 2);
      }
    }
    
    // Set pending focus (will be handled by widget layer)
    _pendingFocusSegment = nextNormal;
    
    notifyListeners();
    
    // Reset flag after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlingCodeExit = false;
    });
  }

  /// Handles backspace on an empty code block.
  /// Returns true if handled, false otherwise.
  bool handleBackspaceOnEmptyCodeBlock() {
    final focused = focusedSegment;
    if (focused == null || focused.type != SegmentType.code || focused.isNotEmpty) {
      return false;
    }
    
    removeCodeSegment(focused);
    return true;
  }

  /// Handles backspace on an empty normal segment.
  /// Returns true if handled, false otherwise.
  bool handleBackspaceOnEmptyNormalSegment() {
    final focused = focusedSegment;
    if (focused == null || focused.type != SegmentType.normal || focused.isNotEmpty) {
      return false;
    }
    
    // Can't remove the only normal segment
    final normalCount = _segments.where((s) => s.type == SegmentType.normal).length;
    if (normalCount <= 1) {
      return false;
    }
    
    final focusedIndex = _segments.indexOf(focused);
    
    // Search backwards for a preceding code segment
    ComposerSegment? precedingCode;
    for (int i = focusedIndex - 1; i >= 0; i--) {
      final segment = _segments[i];
      if (segment.type == SegmentType.code) {
        precedingCode = segment;
        break;
      }
      // Stop if we hit a non-empty normal segment
      if (segment.type == SegmentType.normal && segment.isNotEmpty) {
        break;
      }
    }
    
    if (precedingCode == null) {
      return false;
    }
    
    // Remove the empty normal segment
    _removeSegment(focused);
    
    // Focus the preceding code segment at end
    _activeCodeId = precedingCode.id;
    precedingCode.controller.selection = TextSelection.collapsed(
      offset: precedingCode.text.length,
    );
    _requestFocus(precedingCode);
    
    notifyListeners();
    return true;
  }

  // ============================================================================
  // FORMAT OPERATIONS
  // ============================================================================

  /// Applies a format to the focused segment.
  /// 
  /// If focused on a code segment, this is a no-op (formatting blocked).
  void applyFormat(FormatType formatType) {
    final focused = focusedSegment;
    if (focused == null || focused.type == SegmentType.code) {
      return;
    }
    
    if (focused.controller is RichTextEditingController) {
      (focused.controller as RichTextEditingController).toggleFormat(formatType);
      notifyListeners();
    }
  }

  // ============================================================================
  // SERIALIZATION
  // ============================================================================

  /// Gets the final markdown text for sending.
  /// 
  /// Code segments inside blockquotes are wrapped with the blockquote prefix
  /// on each line of the code block.
  String get finalText {
    final parts = <String>[];
    
    for (final segment in _segments) {
      final text = segment.text.trim();
      if (text.isEmpty) continue;
      
      if (segment.type == SegmentType.code) {
        final lang = segment.language.isNotEmpty ? segment.language : '';
        if (segment.isInsideBlockquote) {
          // Wrap code block with blockquote prefix on each line
          final codeLines = text.split('\n');
          final quotedCode = codeLines.map((line) => '> $line').join('\n');
          parts.add('> ```$lang\n$quotedCode\n> ```');
        } else {
          // Always use inline format without extra newlines
          // The content itself may contain newlines for multi-line code
          parts.add('```$lang$text```');
        }
      } else if (segment.controller is RichTextEditingController) {
        parts.add((segment.controller as RichTextEditingController).toMarkdown());
      } else {
        parts.add(text);
      }
    }
    
    return parts.join('\n');
  }

  /// Alias for [finalText] for compatibility.
  String get segmentFinalText => finalText;

  /// Gets the plain text without formatting.
  String get plainText {
    return _segments
        .map((s) => s.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n');
  }

  // ============================================================================
  // CLEAR & DISPOSE
  // ============================================================================

  /// Clears all content and resets to initial state.
  void clear() {
    // Dispose all segments
    for (final segment in _segments) {
      segment.dispose();
    }
    _segments.clear();
    
    // Reset state
    _activeCodeId = null;
    _pendingFocusSegment = null;
    
    // Add fresh empty normal segment
    final newSegment = _addNormalSegment('');
    
    // Request focus on new segment
    _requestFocus(newSegment);
    
    notifyListeners();
  }

  /// Alias for [clear] for compatibility.
  void clearSegments() => clear();

  @override
  void dispose() {
    for (final segment in _segments) {
      segment.dispose();
    }
    _segments.clear();
    super.dispose();
  }

  // ============================================================================
  // FOCUS MANAGEMENT
  // ============================================================================

  /// Requests focus on a segment via microtask.
  void _requestFocus(ComposerSegment segment) {
    Future.microtask(() {
      segment.focusNode.requestFocus();
    });
  }

  /// Requests focus on the first segment.
  void requestFocus() {
    if (_segments.isNotEmpty) {
      _requestFocus(_segments.first);
    }
  }
}
