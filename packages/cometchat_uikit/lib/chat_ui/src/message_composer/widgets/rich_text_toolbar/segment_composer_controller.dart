import 'package:flutter/material.dart';
import '../../../../../../shared_ui/cometchat_uikit_shared.dart';
import '../../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_type.dart';
import 'rich_text_editing_controller.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SEGMENT MODEL
// ════════════════════════════════════════════════════════════════════════════════

/// Type of segment in the composer
enum SegmentType { normal, code }

/// Represents a single segment in the composer (either normal text or code block)
class ComposerSegment {
  final String id;
  final SegmentType type;
  final TextEditingController controller;
  final FocusNode focusNode;
  String language;

  /// Tracks the previous text for this segment so formatters (mentions, etc.)
  /// receive the correct previous text when [onChange] is called — not the
  /// previous text from a different segment.
  String previousText;

  ComposerSegment({
    required this.id,
    required this.type,
    String text = '',
    this.language = '',
    List<CometChatTextFormatter>? formatters,
  })  : controller = (type == SegmentType.normal)
            ? RichTextEditingController(text: text, formatters: formatters)
            : TextEditingController(text: text),
        focusNode = FocusNode(),
        previousText = text;

  bool get isEmpty => controller.text.trim().isEmpty;
  String get text => controller.text;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SEGMENT COMPOSER CONTROLLER
// ════════════════════════════════════════════════════════════════════════════════

/// Controller for segment-based rich text composition.
/// 
/// Manages multiple segments (normal text and code blocks) with independent
/// TextEditingControllers and FocusNodes for each segment.
/// 
/// Key features:
/// - Insert code blocks at cursor position, splitting normal text
/// - Double-Enter exits code block and moves to next normal segment
/// - Remove code block merges text back into surrounding normal segments
/// - Serializes to markdown with ``` fences for code blocks
class SegmentComposerController extends ChangeNotifier {
  final List<ComposerSegment> _segments = [];
  int _idCounter = 0;

  /// Text formatters (mentions, etc.) to pass to normal segments
  /// so they use CustomTextEditingController for styled text display.
  List<CometChatTextFormatter>? _formatters;

  /// Set the formatters for normal segments.
  /// If the controller only has the initial empty segment, recreates it
  /// with the formatters so it uses CustomTextEditingController.
  set formatters(List<CometChatTextFormatter>? value) {
    _formatters = value;
    // Recreate the initial segment if it's the only one and empty
    if (_segments.length == 1 &&
        _segments.first.type == SegmentType.normal &&
        _segments.first.controller.text.isEmpty) {
      _segments.first.dispose();
      _segments.clear();
      _addSegment(SegmentType.normal);
      notifyListeners();
    }
  }

  /// Which segment currently has a code block active (being typed into)
  String? _activeCodeId;

  /// Callback propagated to each normal segment's [RichTextEditingController]
  /// so link taps in any segment trigger the composer's Edit / Remove popup.
  void Function(LinkTapDetails details)? _onLinkTap;
  set onLinkTap(void Function(LinkTapDetails details)? value) {
    _onLinkTap = value;
    // Propagate to all existing normal segments
    for (final seg in _segments) {
      if (seg.type == SegmentType.normal && seg.controller is RichTextEditingController) {
        (seg.controller as RichTextEditingController).onLinkTap = value;
      }
    }
  }

  /// Callback propagated to each normal segment's [RichTextEditingController]
  /// so programmatic text changes (edit/remove link) notify formatters.
  void Function(String previousText)? _onFormatterTextChanged;
  set onFormatterTextChanged(void Function(String previousText)? value) {
    _onFormatterTextChanged = value;
    for (final seg in _segments) {
      if (seg.type == SegmentType.normal && seg.controller is RichTextEditingController) {
        (seg.controller as RichTextEditingController).onFormatterTextChanged = value;
      }
    }
  }

  /// True when the focused segment is a code block being actively edited
  bool get isTypingInCode =>
      _activeCodeId != null &&
      _segments.any((s) => s.id == _activeCodeId && s.type == SegmentType.code);

  /// Get all segments (read-only)
  List<ComposerSegment> get segments => List.unmodifiable(_segments);

  /// Check if there's any content (text or code blocks)
  bool get hasContent {
    final hasText = _segments.any((s) => s.controller.text.isNotEmpty);
    final hasCodeBlock = _segments.any((s) => s.type == SegmentType.code);
    return hasText || hasCodeBlock;
  }

  /// Get the currently focused segment
  ComposerSegment? get focusedSegment {
    try {
      return _segments.firstWhere((s) => s.focusNode.hasFocus);
    } catch (_) {
      return null;
    }
  }

  SegmentComposerController() {
    _addSegment(SegmentType.normal);
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  String _newId() => 'seg${_idCounter++}';

  int _indexOf(ComposerSegment segment) => _segments.indexOf(segment);

  ComposerSegment _addSegment(
    SegmentType type, {
    String text = '',
    String language = '',
    int? at,
  }) {
    final segment = ComposerSegment(
      id: _newId(),
      type: type,
      text: text,
      language: language,
      formatters: type == SegmentType.normal ? _formatters : null,
    );
    
    segment.controller.addListener(notifyListeners);
    segment.focusNode.addListener(() {
      if (segment.focusNode.hasFocus) notifyListeners();
    });
    
    // Wire up code block delegation for normal segments
    if (type == SegmentType.normal && segment.controller is RichTextEditingController) {
      (segment.controller as RichTextEditingController).onInsertCodeBlock = toggleCodeBlock;
      (segment.controller as RichTextEditingController).onLinkTap = _onLinkTap;
      (segment.controller as RichTextEditingController).onFormatterTextChanged = _onFormatterTextChanged;
    }
    
    // For code segments, add exit detection listener
    if (type == SegmentType.code) {
      segment.controller.addListener(() {
        _watchCodeExit(segment);
      });
    }
    
    if (at != null) {
      _segments.insert(at, segment);
    } else {
      _segments.add(segment);
    }
    
    return segment;
  }

  // ── Public: insert code block ───────────────────────────────────────────────

  /// Toggle code block - if in a code block, remove it; otherwise insert one.
  /// This is called when the code block button is clicked.
  /// 
  /// Always creates a new code block when in a normal segment.
  /// The current line text (if any) is extracted into the new code block
  /// by [insertCodeBlock].
  void toggleCodeBlock() {
    var focused = focusedSegment;
    if (focused != null && focused.type == SegmentType.code) {
      // Already in a code block - remove it
      removeCodeSegment(focused);
      return;
    }

    // If no segment is focused, focus the first normal segment so
    // insertCodeBlock knows where to insert.
    if (focused == null) {
      final firstNormal = _segments.cast<ComposerSegment?>().firstWhere(
        (s) => s!.type == SegmentType.normal,
        orElse: () => null,
      );
      if (firstNormal != null) {
        firstNormal.focusNode.requestFocus();
      }
    }

    // In a normal segment (or no focus) — insert a new code block
    insertCodeBlock();
  }

  /// Insert a code block at the current cursor position.
  /// 
  /// If there's selected text in a normal segment, moves that text into the code block.
  /// If the cursor is on a line with text (no selection), extracts that entire line
  /// into the code block.
  /// If the segment is empty, inserts an empty code block.
  /// 
  /// When the focused normal segment becomes empty after extraction (single-line),
  /// it is replaced in-place to avoid a visual glitch where both segments are
  /// briefly visible.
  /// 
  /// All inline formatting (bold, italic, etc.) and line-based prefixes are
  /// stripped from the extracted text — code blocks contain plain text only.
  void insertCodeBlock() {
    final focused = focusedSegment;
    int insertAt;
    String codeContent = '';

    if (focused == null || focused.type == SegmentType.code) {
      // No focus or already in code - insert at end
      insertAt = _segments.length;
    } else {
      final controller = focused.controller;
      final selection = controller.selection;
      final text = controller.text;
      
      if (selection.isValid && !selection.isCollapsed) {
        // There's selected text - move it to the code block
        final start = selection.start.clamp(0, text.length);
        final end = selection.end.clamp(0, text.length);
        
        codeContent = text.substring(start, end);
        final before = text.substring(0, start);
        final after = text.substring(end);
        
        // Strip formatting from extracted content
        if (controller is RichTextEditingController) {
          codeContent = _stripFormattingFromText(codeContent, controller);
          // Clear spans that covered the extracted range
          controller.spanManager.onTextDeleted(start, end);
          controller.clearPendingFormats();
        }
        
        focused.controller.text = before;
        
        final idx = _indexOf(focused);
        
        // Insert trailing normal segment for text after selection
        if (after.isNotEmpty) {
          _addSegment(SegmentType.normal, text: after, at: idx + 1);
        } else if (idx + 1 >= _segments.length ||
            _segments[idx + 1].type == SegmentType.code) {
          _addSegment(SegmentType.normal, at: idx + 1);
        }
        insertAt = idx + 1;
      } else {
        // No selection — extract the current line and move it into the code block.
        // Find the line boundaries around the cursor.
        final cursor = selection.baseOffset.clamp(0, text.length);
        
        int lineStart = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0);
        lineStart = lineStart == -1 ? 0 : lineStart + 1;
        
        int lineEnd = text.indexOf('\n', cursor);
        if (lineEnd == -1) lineEnd = text.length;
        
        codeContent = text.substring(lineStart, lineEnd);
        
        // Strip formatting from extracted content
        if (controller is RichTextEditingController) {
          codeContent = _stripFormattingFromText(codeContent, controller);
          // Clear spans/pending formats since content is moving to code block
          controller.clearPendingFormats();
        }
        
        final before = text.substring(0, lineStart);
        // Skip the newline after the extracted line if present
        final after = lineEnd < text.length ? text.substring(lineEnd + 1) : '';
        
        // Remove trailing newline from before text
        final trimmedBefore = before.endsWith('\n')
            ? before.substring(0, before.length - 1)
            : before;

        final idx = _indexOf(focused);

        // If the normal segment will be empty after extraction (single-line case),
        // replace it in-place with the code segment to avoid a frame where both
        // the empty normal and new code segment are visible (height glitch).
        if (trimmedBefore.isEmpty && after.isEmpty) {
          // Replace the focused normal segment in-place
          focused.dispose();
          _segments.removeAt(idx);

          final codeSegment = _addSegment(SegmentType.code, text: codeContent, at: idx);
          _activeCodeId = codeSegment.id;

          // Ensure a normal segment follows
          if (idx + 1 >= _segments.length ||
              _segments[idx + 1].type == SegmentType.code) {
            _addSegment(SegmentType.normal, at: idx + 1);
          }
          // Ensure a normal segment precedes (for backspace-to-delete flow)
          if (idx == 0 || _segments[idx - 1].type == SegmentType.code) {
            _addSegment(SegmentType.normal, at: idx);
          }

          notifyListeners();
          Future.microtask(() => codeSegment.focusNode.requestFocus());
          return;
        }

        focused.controller.text = trimmedBefore;

        // Insert trailing normal segment for text after the extracted line
        if (after.isNotEmpty) {
          _addSegment(SegmentType.normal, text: after, at: idx + 1);
        } else if (idx + 1 >= _segments.length ||
            _segments[idx + 1].type == SegmentType.code) {
          _addSegment(SegmentType.normal, at: idx + 1);
        }
        insertAt = idx + 1;
      }
    }

    final codeSegment = _addSegment(SegmentType.code, text: codeContent, at: insertAt);
    _activeCodeId = codeSegment.id;

    // Ensure normal segment follows
    if (insertAt + 1 >= _segments.length ||
        _segments[insertAt + 1].type == SegmentType.code) {
      _addSegment(SegmentType.normal, at: insertAt + 1);
    }

    notifyListeners();
    Future.microtask(() => codeSegment.focusNode.requestFocus());
  }
  
  /// Called when backspace is pressed on an empty code block
  /// Returns true if the code block was removed
  bool handleBackspaceOnEmptyCodeBlock() {
    // Find the focused code segment
    final focused = focusedSegment;
    if (focused == null || focused.type != SegmentType.code) return false;
    
    // Check if it's empty
    if (focused.controller.text.isNotEmpty) return false;
    
    // Remove the code block
    removeCodeSegment(focused);
    return true;
  }

  /// Called when backspace is pressed on an empty normal segment.
  /// Removes the empty normal segment and moves cursor to the end of the
  /// preceding code block (if any).
  /// Returns true if the segment was removed.
  bool handleBackspaceOnEmptyNormalSegment() {
    final focused = focusedSegment;
    if (focused == null || focused.type != SegmentType.normal) return false;
    if (focused.controller.text.isNotEmpty) return false;

    final idx = _indexOf(focused);

    // Find the preceding code block
    ComposerSegment? prevCode;
    for (int i = idx - 1; i >= 0; i--) {
      if (_segments[i].type == SegmentType.code) {
        prevCode = _segments[i];
        break;
      }
      // Stop if we hit another non-empty normal segment
      if (_segments[i].type == SegmentType.normal &&
          _segments[i].controller.text.isNotEmpty) {
        break;
      }
    }

    if (prevCode == null) return false;

    // Don't remove if this is the only normal segment
    final normalCount = _segments.where((s) => s.type == SegmentType.normal).length;
    if (normalCount <= 1) return false;

    // Remove the empty normal segment
    focused.dispose();
    _segments.remove(focused);

    // Focus the preceding code block at the end
    _activeCodeId = prevCode.id;
    final endOffset = prevCode.controller.text.length;
    prevCode.controller.selection = TextSelection.collapsed(offset: endOffset);
    notifyListeners();
    Future.microtask(() => prevCode!.focusNode.requestFocus());
    return true;
  }

  /// Flag to prevent re-entrant code exit handling
  bool _handlingCodeExit = false;

  /// Flag to suppress the code-exit watcher during programmatic text changes.
  /// Using a flag instead of remove/add listener because anonymous closures
  /// create new function objects that won't match for removeListener.
  bool _suppressCodeExitWatch = false;

  /// Segment that should receive focus after the next rebuild.
  /// Set by _watchCodeExit so the widget layer can call requestFocus
  /// after the target segment is guaranteed to be in the tree.
  ComposerSegment? _pendingFocusSegment;

  /// Get and clear the pending focus segment (called by widget after rebuild)
  ComposerSegment? consumePendingFocus() {
    final seg = _pendingFocusSegment;
    _pendingFocusSegment = null;
    return seg;
  }

  /// Whether there's a segment waiting for focus (used by widget to keep it visible)
  String? get pendingFocusSegmentId => _pendingFocusSegment?.id;

  void _watchCodeExit(ComposerSegment codeSegment) {
    // Skip when suppressed (programmatic text change) or already handling
    if (_suppressCodeExitWatch || _handlingCodeExit) return;
    
    final text = codeSegment.controller.text;
    
    // Exit code block when user presses Enter on two consecutive empty lines.
    // This means the text ends with \n\n\n (content + blank line + blank line + newline).
    // Three newlines = user pressed Enter 3 times after their last line of code.
    if (text.endsWith('\n\n\n')) {
      _handlingCodeExit = true;
      
      // Suppress watcher while we trim the exit newlines
      _suppressCodeExitWatch = true;
      codeSegment.controller.text = text.substring(0, text.length - 3);
      _suppressCodeExitWatch = false;
      
      _activeCodeId = null;

      final idx = _indexOf(codeSegment);
      
      // Find or create the next normal segment
      ComposerSegment? next;
      for (int i = idx + 1; i < _segments.length; i++) {
        if (_segments[i].type == SegmentType.normal) {
          next = _segments[i];
          break;
        }
      }
      next ??= _addSegment(SegmentType.normal, at: idx + 1);
      
      // Store pending focus — widget will request focus after rebuild
      // so the target segment is in the tree (not hidden by SizedBox.shrink)
      _pendingFocusSegment = next;

      notifyListeners();
      
      // Reset after the frame so rebuild completes first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlingCodeExit = false;
      });
    }
  }

  // ── Remove code segment ───────────────────────────────────────────────────

  /// Remove a code segment and merge its content back into surrounding normal segments.
  void removeCodeSegment(ComposerSegment segment) {
    final idx = _indexOf(segment);
    final codeText = segment.controller.text;

    // Capture surrounding normal text
    final hasPrev = idx > 0 && _segments[idx - 1].type == SegmentType.normal;
    final hasNext = idx + 1 < _segments.length &&
        _segments[idx + 1].type == SegmentType.normal;
    final prevText = hasPrev ? _segments[idx - 1].controller.text : null;
    final nextText = hasNext ? _segments[idx + 1].controller.text : null;

    // Remove next normal segment first (higher index so removal doesn't shift idx)
    if (hasNext) {
      _segments[idx + 1].dispose();
      _segments.removeAt(idx + 1);
    }

    // Remove the code segment
    segment.dispose();
    _segments.remove(segment);

    if (hasPrev) {
      // Merge everything into the previous normal segment
      final prevSeg = _segments[idx - 1];
      final sep1 =
          (prevText!.isNotEmpty && codeText.isNotEmpty) ? '\n' : '';
      final sep2 =
          (codeText.isNotEmpty && (nextText?.isNotEmpty ?? false)) ? '\n' : '';
      prevSeg.controller.text = '$prevText$sep1$codeText$sep2${nextText ?? ''}';

      // Cursor lands right after the pasted code text
      final cursor = prevText.length + sep1.length + codeText.length;
      prevSeg.controller.selection = TextSelection.collapsed(offset: cursor);
      Future.microtask(() => prevSeg.focusNode.requestFocus());
    } else {
      // No preceding normal segment — create one at front carrying all the text
      final sep =
          (codeText.isNotEmpty && (nextText?.isNotEmpty ?? false)) ? '\n' : '';
      final merged = '$codeText$sep${nextText ?? ''}';
      final newSeg = _addSegment(SegmentType.normal, text: merged, at: 0);
      newSeg.controller.selection =
          TextSelection.collapsed(offset: codeText.length);
      Future.microtask(() => newSeg.focusNode.requestFocus());
    }

    if (_segments.isEmpty) _addSegment(SegmentType.normal);
    if (_activeCodeId == segment.id) _activeCodeId = null;
    notifyListeners();
  }

  // ── Formatting stripping helper ──────────────────────────────────────────

  /// Strip all inline formatting (markdown markers, line-based prefixes) from
  /// [text] using the controller's stripping logic. Falls back to a simple
  /// regex-based strip if the controller doesn't support it.
  String _stripFormattingFromText(String text, RichTextEditingController controller) {
    if (text.isEmpty) return text;
    // Use the controller's comprehensive stripping method
    // which handles nested markdown, span-based formats, and line prefixes.
    // We temporarily set the controller text, call getStrippedPlainText, then restore.
    // But that's heavy — instead, just use a standalone regex strip.
    return _stripMarkdownAndPrefixes(text);
  }

  /// Strip inline markdown markers and line-based prefixes from a string.
  /// Handles: **bold**, __bold__, *italic*, _italic_, ~~strike~~, `code`,
  /// [text](url), bullet (- ), ordered (N. ), blockquote (> ).
  static String _stripMarkdownAndPrefixes(String text) {
    String result = text;

    // Strip inline markdown iteratively (handles nesting)
    final inlineRegex = RegExp(
      r'(\*\*(.+?)\*\*)'       // **bold**
      r'|(__(.+?)__)'           // __bold__
      r'|(~~(.+?)~~)'           // ~~strikethrough~~
      r'|(\*(.+?)\*)'           // *italic*
      r'|(_(.+?)_)'             // _italic_
      r'|(`([^`]+)`)'           // `code`
      r'|(\[([^\]]+)\]\([^)]+\))',  // [text](url)
    );

    for (int i = 0; i < 5; i++) {
      final matches = inlineRegex.allMatches(result).toList();
      if (matches.isEmpty) break;

      // Process right-to-left to preserve positions
      for (int j = matches.length - 1; j >= 0; j--) {
        final m = matches[j];
        String content;
        if (m.group(2) != null) {
          content = m.group(2)!; // **bold**
        } else if (m.group(4) != null) {
          content = m.group(4)!; // __bold__
        } else if (m.group(6) != null) {
          content = m.group(6)!; // ~~strike~~
        } else if (m.group(8) != null) {
          content = m.group(8)!; // *italic*
        } else if (m.group(10) != null) {
          content = m.group(10)!; // _italic_
        } else if (m.group(12) != null) {
          content = m.group(12)!; // `code`
        } else if (m.group(14) != null) {
          content = m.group(14)!; // [text](url) → text
        } else {
          continue;
        }
        result = result.substring(0, m.start) + content + result.substring(m.end);
      }
    }

    // Strip line-based prefixes
    final lines = result.split('\n');
    final stripped = <String>[];
    for (final line in lines) {
      if (line.startsWith('- ')) {
        stripped.add(line.substring(2));
      } else if (line.startsWith('> ')) {
        stripped.add(line.substring(2));
      } else {
        final orderedMatch = RegExp(r'^\d+\. ').firstMatch(line);
        if (orderedMatch != null) {
          stripped.add(line.substring(orderedMatch.end));
        } else {
          stripped.add(line);
        }
      }
    }

    return stripped.join('\n');
  }

  // ── Toolbar toggle ──────────────────────────────────────────────────────────

  /// Toggle a formatting option.
  /// For code blocks, inserts/removes a code segment.
  /// For all other formats, delegates to the focused segment's controller.
  void toggle(String fmt) {
    if (fmt == 'codeBlock') {
      toggleCodeBlock();
      return;
    }

    // Map string format names to FormatType and delegate to applyFormat
    final formatMap = <String, FormatType>{
      'bold': FormatType.bold,
      'italic': FormatType.italic,
      'underline': FormatType.underline,
      'strikethrough': FormatType.strikethrough,
      'link': FormatType.link,
      'orderedList': FormatType.orderedList,
      'bulletList': FormatType.bulletList,
      'blockquote': FormatType.blockquote,
      'inlineCode': FormatType.inlineCode,
    };

    final formatType = formatMap[fmt];
    if (formatType != null) {
      applyFormat(formatType);
    }
    notifyListeners();
    focusedSegment?.focusNode.requestFocus();
  }

  // ── Apply format to selection ───────────────────────────────────────────────

  /// Apply a format type (for toolbar integration)
  /// Delegates to the focused segment's RichTextEditingController which handles
  /// span tracking, pending formats, and WYSIWYG rendering.
  ///
  /// If no segment currently has focus, falls back to the first normal segment
  /// so that toolbar buttons work even when the keyboard is not open.
  /// Line-based formats that can replace a code block when clicked.
  static const _lineBasedFormats = {
    FormatType.bulletList,
    FormatType.orderedList,
    FormatType.blockquote,
  };

  void applyFormat(FormatType format, {ComposerSegment? targetSegment}) {
    if (format == FormatType.codeBlock) {
      insertCodeBlock();
      return;
    }

    // Use explicit target, or focused segment, or fall back to first normal segment
    var segment = targetSegment ?? focusedSegment;
    segment ??= _segments.cast<ComposerSegment?>().firstWhere(
      (s) => s!.type == SegmentType.normal,
      orElse: () => null,
    );
    if (segment == null) return;

    // When a line-based format is clicked while in a code block,
    // remove the code block first, then apply the format to the
    // resulting normal segment.
    if (segment.type == SegmentType.code) {
      if (!_lineBasedFormats.contains(format)) return;

      // removeCodeSegment merges code text into a normal segment and
      // schedules focus via Future.microtask. We need to find that
      // target normal segment and apply the format to it.
      removeCodeSegment(segment);

      // After removal, the focused segment should now be a normal segment
      // containing the merged text. Find it.
      final normalSeg = focusedSegment ??
          _segments.cast<ComposerSegment?>().firstWhere(
            (s) => s!.type == SegmentType.normal,
            orElse: () => null,
          );
      if (normalSeg == null) return;

      final controller = normalSeg.controller;
      if (controller is RichTextEditingController) {
        controller.applyFormat(format);
      }
      notifyListeners();
      return;
    }

    // Ensure the segment has focus so the cursor is visible
    if (!segment.focusNode.hasFocus) {
      segment.focusNode.requestFocus();
    }

    // Delegate to the segment's RichTextEditingController
    final controller = segment.controller;
    if (controller is RichTextEditingController) {
      controller.applyFormat(format);
    }
    notifyListeners();
  }

  /// Get active formats at current cursor position.
  /// Delegates to the focused segment's RichTextEditingController.
  Set<FormatType> getActiveFormats() {
    var segment = focusedSegment;
    // Fall back to first normal segment when nothing is focused
    segment ??= _segments.cast<ComposerSegment?>().firstWhere(
      (s) => s!.type == SegmentType.normal,
      orElse: () => null,
    );
    if (segment == null) {
      return {};
    }
    if (segment.type == SegmentType.code) {
      return {FormatType.codeBlock};
    }

    // Delegate to the segment's RichTextEditingController
    final controller = segment.controller;
    if (controller is RichTextEditingController) {
      return controller.getActiveFormats();
    }

    return {};
  }

  // ── Serialization ───────────────────────────────────────────────────────────

  /// Serialize all segments to final sendable markdown string
  String get finalText {
    final parts = <String>[];
    for (final s in _segments) {
      final t = s.controller.text.trim();
      if (t.isEmpty) continue;
      
      if (s.type == SegmentType.code) {
        final lang = s.language.trim();
        parts.add('```$lang\n$t\n```');
      } else {
        // For normal segments, use RichTextEditingController's toMarkdown()
        // which converts span-based formatting to markdown syntax
        final controller = s.controller;
        if (controller is RichTextEditingController) {
          parts.add(controller.toMarkdown());
        } else {
          parts.add(t);
        }
      }
    }
    return parts.join('\n');
  }

  /// Get plain text without markdown markers
  String get plainText => _segments
      .map((s) => s.controller.text.trim())
      .where((t) => t.isNotEmpty)
      .join('\n');

  // ── Clear and dispose ───────────────────────────────────────────────────────

  /// Clear all content and reset to initial state.
  /// Requests focus on the new empty segment to keep the keyboard open.
  void clear() {
    for (final s in _segments) {
      s.dispose();
    }
    _segments.clear();
    _activeCodeId = null;
    final newSegment = _addSegment(SegmentType.normal);
    notifyListeners();
    // Request focus on the fresh segment so the keyboard stays open
    Future.microtask(() => newSegment.focusNode.requestFocus());
  }

  @override
  void dispose() {
    for (final s in _segments) {
      s.dispose();
    }
    super.dispose();
  }
}
