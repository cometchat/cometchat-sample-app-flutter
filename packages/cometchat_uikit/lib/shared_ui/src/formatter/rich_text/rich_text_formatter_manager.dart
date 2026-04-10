import 'package:flutter/material.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import 'blockquote_text_formatter.dart';
import 'bold_text_formatter.dart';
import 'bullet_list_text_formatter.dart';
import 'code_block_text_formatter.dart';
import 'format_result.dart';
import 'inline_code_text_formatter.dart';
import 'italic_text_formatter.dart';
import 'link_text_formatter.dart';
import 'ordered_list_text_formatter.dart';
import 'rich_text_configuration.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';
import 'strikethrough_text_formatter.dart';
import 'underline_text_formatter.dart';

/// Manager for coordinating rich text formatting operations
///
/// @Deprecated: Use [RichTextFormatterBloc] from the rich_text_formatting module instead.
///
/// Migration guide:
/// ```dart
/// // Old way:
/// final manager = RichTextFormatterManager(configuration: config);
/// manager.applyFormat(formatType: RichTextFormatType.bold, controller: controller);
///
/// // New way:
/// RichTextServiceLocator.instance.setup(config);
/// final bloc = RichTextFormatterBloc();
/// bloc.add(FormatApplied(
///   formatType: FormatType.bold,
///   text: controller.text,
///   selection: controller.selection,
/// ));
/// ```
@Deprecated(
  'Use RichTextFormatterBloc from rich_text_formatting module instead. '
  'See RichTextFormatterManagerAdapter for backward compatibility during migration.',
)
class RichTextFormatterManager {
  RichTextFormatterManager({
    required RichTextConfiguration configuration,
  }) : _configuration = configuration {
    _initializeFormatters();
  }

  final RichTextConfiguration _configuration;
  final Map<RichTextFormatType, CometChatTextFormatter> _formatters = {};

  /// Callback when formatting is applied
  void Function(RichTextFormatType, String)? onFormatApplied;

  void _initializeFormatters() {
    if (_configuration.enableBold) {
      _formatters[RichTextFormatType.bold] = BoldTextFormatter();
    }
    if (_configuration.enableItalic) {
      _formatters[RichTextFormatType.italic] = ItalicTextFormatter();
    }
    if (_configuration.enableUnderline) {
      _formatters[RichTextFormatType.underline] = UnderlineTextFormatter();
    }
    if (_configuration.enableStrikethrough) {
      _formatters[RichTextFormatType.strikethrough] =
          StrikethroughTextFormatter();
    }
    if (_configuration.enableInlineCode) {
      _formatters[RichTextFormatType.inlineCode] = InlineCodeTextFormatter();
    }
    if (_configuration.enableCodeBlock) {
      _formatters[RichTextFormatType.codeBlock] = CodeBlockTextFormatter();
    }
    if (_configuration.enableLinks) {
      _formatters[RichTextFormatType.link] = LinkTextFormatter();
    }
    if (_configuration.isBulletListEnabled) {
      _formatters[RichTextFormatType.bulletList] = BulletListTextFormatter();
    }
    if (_configuration.isOrderedListEnabled) {
      _formatters[RichTextFormatType.orderedList] = OrderedListTextFormatter();
    }
    if (_configuration.isBlockquoteEnabled) {
      _formatters[RichTextFormatType.blockquote] = BlockquoteTextFormatter();
    }
  }

  /// Get all active formatters as a list
  List<CometChatTextFormatter> get activeFormatters =>
      _formatters.values.toList();

  /// Get the configuration
  RichTextConfiguration get configuration => _configuration;

  /// Get enabled format types
  List<RichTextFormatType> get enabledFormatTypes => _formatters.keys.toList();

  /// Inline format types that are blocked inside code blocks
  static const _inlineFormats = {
    RichTextFormatType.bold,
    RichTextFormatType.italic,
    RichTextFormatType.underline,
    RichTextFormatType.strikethrough,
    RichTextFormatType.inlineCode,
  };

  /// Apply formatting to the current selection
  ///
  /// Enforces format compatibility:
  /// - Code block blocks all inline formatting (Bug 1.5)
  /// - Code block and blockquote are mutually exclusive (Bug 1.12)
  /// - List replaces code block (Bug 1.13)
  /// - Blockquote allows inline formatting (Bug 1.14)
  FormatResult? applyFormat({
    required RichTextFormatType formatType,
    required TextEditingController controller,
    String? linkUrl,
    String? linkDisplayText,
    List<Map<String, dynamic>>? mentionPositions,
  }) {
    final formatter = _formatters[formatType];
    if (formatter == null) return null;

    var text = controller.text;
    var selection = controller.selection;

    // --- Format compatibility enforcement ---
    final activeFormats = getActiveFormats(text, selection.start);

    // Bug 1.5: Block inline formatting inside code blocks
    if (activeFormats.contains(RichTextFormatType.codeBlock) &&
        _inlineFormats.contains(formatType)) {
      return null; // Blocked
    }

    // Bug 1.12: Code block and blockquote mutual exclusivity
    if (formatType == RichTextFormatType.codeBlock &&
        activeFormats.contains(RichTextFormatType.blockquote)) {
      final stripped = _stripBlockquoteMarkers(text, selection);
      text = stripped.newText;
      selection = stripped.newSelection;
    } else if (formatType == RichTextFormatType.blockquote &&
        activeFormats.contains(RichTextFormatType.codeBlock)) {
      final stripped = _stripCodeBlockMarkers(text, selection);
      text = stripped.newText;
      selection = stripped.newSelection;
    }

    // Bug 1.13: List replaces code block
    if ((formatType == RichTextFormatType.bulletList ||
            formatType == RichTextFormatType.orderedList) &&
        activeFormats.contains(RichTextFormatType.codeBlock)) {
      final stripped = _stripCodeBlockMarkers(text, selection);
      text = stripped.newText;
      selection = stripped.newSelection;
    }

    // Bug 1.14: Blockquote allows inline formatting — no blocking needed

    FormatResult? result;

    // Handle different formatter types
    if (formatter is RichTextFormatterBase) {
      // Bug 1.6/1.11: Mention-aware inline formatting
      if (_inlineFormats.contains(formatType) &&
          mentionPositions != null &&
          mentionPositions.isNotEmpty &&
          !selection.isCollapsed) {
        result = _applyMentionAwareFormat(
            formatter, text, selection, mentionPositions);
      } else {
        result = formatter.applyToSelection(text, selection);
      }
    } else if (formatter is LinkTextFormatter && linkUrl != null) {
      final displayText = linkDisplayText ??
          (selection.isCollapsed
              ? linkUrl
              : text.substring(selection.start, selection.end));
      result = formatter.applyLink(text, selection, displayText, linkUrl);
    } else if (formatter is BulletListTextFormatter) {
      result = formatter.insertBullet(text, selection);
    } else if (formatter is OrderedListTextFormatter) {
      result = formatter.insertNumber(text, selection, 1);
    } else if (formatter is BlockquoteTextFormatter) {
      result = formatter.insertBlockquote(text, selection);
    }

    if (result != null) {
      onFormatApplied?.call(formatType, result.newText);
    }

    return result;
  }

  /// Apply inline formatting while skipping mention spans (Bug 1.6/1.11)
  ///
  /// [mentionPositions] is a list of maps with 'start' and 'end' keys
  /// indicating the character ranges of mentions in the text.
  FormatResult _applyMentionAwareFormat(
    RichTextFormatterBase formatter,
    String text,
    TextSelection selection,
    List<Map<String, dynamic>> mentionPositions,
  ) {
    // Find mentions that overlap with the selection
    final overlapping = mentionPositions.where((m) {
      final mStart = m['start'] as int;
      final mEnd = m['end'] as int;
      return mStart < selection.end && mEnd > selection.start;
    }).toList()
      ..sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

    if (overlapping.isEmpty) {
      return formatter.applyToSelection(text, selection);
    }

    // Build segments: non-mention text gets formatted, mention text is skipped
    final buffer = StringBuffer();
    var cursor = selection.start;

    // Text before selection
    buffer.write(text.substring(0, selection.start));

    for (final mention in overlapping) {
      final mStart = (mention['start'] as int).clamp(selection.start, selection.end);
      final mEnd = (mention['end'] as int).clamp(selection.start, selection.end);

      // Format text before this mention
      if (cursor < mStart) {
        final segment = text.substring(cursor, mStart);
        buffer.write('${formatter.openingMarker}$segment${formatter.closingMarker}');
      }

      // Keep mention text as-is
      buffer.write(text.substring(mStart, mEnd));
      cursor = mEnd;
    }

    // Format remaining text after last mention
    if (cursor < selection.end) {
      final segment = text.substring(cursor, selection.end);
      buffer.write('${formatter.openingMarker}$segment${formatter.closingMarker}');
    }

    // Text after selection
    buffer.write(text.substring(selection.end));

    final newText = buffer.toString();
    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(offset: newText.length - (text.length - selection.end)),
      formatApplied: formatter.formatType,
    );
  }

  /// Strip code block markers (```) from text around the selection
  _StrippedText _stripCodeBlockMarkers(String text, TextSelection selection) {
    // Find ``` pairs
    final pattern = RegExp(r'```[\s\S]*?(?:```|$)');
    for (final match in pattern.allMatches(text)) {
      if (selection.start >= match.start && selection.start <= match.end) {
        // Extract content between ``` markers
        var content = match.group(0) ?? '';
        if (content.startsWith('```')) content = content.substring(3);
        if (content.endsWith('```')) {
          content = content.substring(0, content.length - 3);
        }
        // Trim leading/trailing newlines from content
        if (content.startsWith('\n')) content = content.substring(1);
        if (content.endsWith('\n')) {
          content = content.substring(0, content.length - 1);
        }

        final newText =
            text.substring(0, match.start) + content + text.substring(match.end);
        final offset = selection.start - match.start;
        final adjustedOffset = (match.start + (offset - 3).clamp(0, content.length))
            .clamp(0, newText.length);

        return _StrippedText(
          newText: newText,
          newSelection: TextSelection.collapsed(offset: adjustedOffset),
        );
      }
    }
    return _StrippedText(newText: text, newSelection: selection);
  }

  /// Strip blockquote markers (> ) from lines in the selection range
  _StrippedText _stripBlockquoteMarkers(String text, TextSelection selection) {
    final lines = text.split('\n');
    var charCount = 0;
    var removedBeforeStart = 0;
    var removedTotal = 0;

    for (int i = 0; i < lines.length; i++) {
      final lineStart = charCount;
      final lineEnd = charCount + lines[i].length;

      if (lineEnd >= selection.start && lineStart <= selection.end) {
        if (lines[i].startsWith('> ')) {
          lines[i] = lines[i].substring(2);
          if (lineStart < selection.start) {
            removedBeforeStart += 2;
          }
          removedTotal += 2;
        } else if (lines[i].startsWith('>')) {
          lines[i] = lines[i].substring(1);
          if (lineStart < selection.start) {
            removedBeforeStart += 1;
          }
          removedTotal += 1;
        }
      }

      charCount = lineEnd + 1;
    }

    final newText = lines.join('\n');
    final newStart =
        (selection.start - removedBeforeStart).clamp(0, newText.length);
    final newEnd =
        (selection.end - removedTotal).clamp(newStart, newText.length);

    return _StrippedText(
      newText: newText,
      newSelection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
    );
  }

  /// Check if a message is structurally empty (Bug 1.8)
  ///
  /// Returns true if the text contains only list markers with no actual content.
  /// e.g., "- \n- \n" or "1. \n2. \n" are considered empty.
  bool isMessageEmpty(String text) {
    if (text.trim().isEmpty) return true;

    // Strip bullet list markers (- )
    var stripped = text.replaceAll(RegExp(r'^- ', multiLine: true), '');
    // Strip ordered list markers (N. )
    stripped = stripped.replaceAll(RegExp(r'^\d+\. ', multiLine: true), '');
    // Strip blockquote markers (> )
    stripped = stripped.replaceAll(RegExp(r'^> ?', multiLine: true), '');

    return stripped.trim().isEmpty;
  }

  /// Detect active formats at cursor position
  Set<RichTextFormatType> getActiveFormats(String text, int cursorPosition) {
    final activeFormats = <RichTextFormatType>{};

    for (final entry in _formatters.entries) {
      if (_isFormatActiveAtPosition(entry.value, text, cursorPosition)) {
        activeFormats.add(entry.key);
      }
    }

    return activeFormats;
  }

  /// Check if a specific format is active at position
  bool _isFormatActiveAtPosition(
    CometChatTextFormatter formatter,
    String text,
    int position,
  ) {
    final pattern = formatter.pattern;
    if (pattern == null) return false;

    for (final match in pattern.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }
    return false;
  }

  /// Get formatter for a specific format type
  CometChatTextFormatter? getFormatter(RichTextFormatType formatType) {
    return _formatters[formatType];
  }

  /// Check if a format type is enabled
  bool isFormatEnabled(RichTextFormatType formatType) {
    return _formatters.containsKey(formatType);
  }

  /// Handle Enter key press for list continuation and code blocks
  /// Returns FormatResult if a formatter handled the Enter, null otherwise
  FormatResult? handleEnter(String text, TextSelection selection) {
    // Check code block formatter first (highest priority - stay inside code block)
    final codeBlockFormatter = _formatters[RichTextFormatType.codeBlock];
    if (codeBlockFormatter is CodeBlockTextFormatter) {
      final result = codeBlockFormatter.handleEnter(text, selection);
      if (result != null) {
        onFormatApplied?.call(RichTextFormatType.codeBlock, result.newText);
        return result;
      }
    }

    // Check bullet list formatter
    final bulletFormatter = _formatters[RichTextFormatType.bulletList];
    if (bulletFormatter is BulletListTextFormatter) {
      final result = bulletFormatter.handleEnter(text, selection);
      if (result != null) {
        onFormatApplied?.call(RichTextFormatType.bulletList, result.newText);
        return result;
      }
    }

    // Check ordered list formatter
    final orderedFormatter = _formatters[RichTextFormatType.orderedList];
    if (orderedFormatter is OrderedListTextFormatter) {
      final result = orderedFormatter.handleEnter(text, selection);
      if (result != null) {
        onFormatApplied?.call(RichTextFormatType.orderedList, result.newText);
        return result;
      }
    }

    // Check blockquote formatter
    final blockquoteFormatter = _formatters[RichTextFormatType.blockquote];
    if (blockquoteFormatter is BlockquoteTextFormatter) {
      final result = blockquoteFormatter.handleEnter(text, selection);
      if (result != null) {
        onFormatApplied?.call(RichTextFormatType.blockquote, result.newText);
        return result;
      }
    }

    return null;
  }

  /// Get disabled format types based on currently active formats
  ///
  /// Used by the toolbar to gray out incompatible format buttons.
  Set<RichTextFormatType> getDisabledFormats(String text, int cursorPosition) {
    final activeFormats = getActiveFormats(text, cursorPosition);
    final disabled = <RichTextFormatType>{};

    // Code block disables all inline formats
    if (activeFormats.contains(RichTextFormatType.codeBlock)) {
      disabled.addAll(_inlineFormats);
      disabled.add(RichTextFormatType.link);
    }

    return disabled;
  }

  /// Detect and auto-convert markdown shortcuts in text (Bug 1.19)
  ///
  /// Detects completed patterns like **text**, _text_, ~~text~~, `code`
  /// and converts them to formatted text. Returns a FormatResult if a
  /// conversion was made, null otherwise.
  ///
  /// Only active when [RichTextConfiguration.enableAutoFormatting] is true.
  FormatResult? detectMarkdownShortcuts(String text, TextSelection selection) {
    if (!_configuration.enableAutoFormatting) return null;
    if (selection.baseOffset != selection.extentOffset) return null;

    final cursor = selection.start;

    // Patterns to detect (order matters - check longer markers first)
    final patterns = <_ShortcutPattern>[
      _ShortcutPattern(RegExp(r'\*\*(.+?)\*\*'), '**', '**', RichTextFormatType.bold),
      _ShortcutPattern(RegExp(r'~~(.+?)~~'), '~~', '~~', RichTextFormatType.strikethrough),
      _ShortcutPattern(RegExp(r'_(.+?)_'), '_', '_', RichTextFormatType.italic),
      _ShortcutPattern(RegExp(r'`([^`]+)`'), '`', '`', RichTextFormatType.inlineCode),
    ];

    for (final p in patterns) {
      if (!_formatters.containsKey(p.formatType)) continue;

      for (final match in p.regex.allMatches(text)) {
        // Only convert if cursor is right after the closing marker
        if (match.end == cursor) {
          final content = match.group(1) ?? '';
          if (content.isEmpty) continue;

          // Replace the markdown syntax with just the content
          // The formatter's buildInputFieldText will style it
          final newText = text.substring(0, match.start) +
              '${p.open}$content${p.close}' +
              text.substring(match.end);

          // Text is already in the right format, just notify
          return FormatResult(
            newText: newText,
            newSelection: TextSelection.collapsed(offset: match.end),
            formatApplied: p.formatType,
          );
        }
      }
    }

    return null;
  }
}


/// Helper class for text after stripping block-level format markers.
class _StrippedText {
  final String newText;
  final TextSelection newSelection;

  const _StrippedText({
    required this.newText,
    required this.newSelection,
  });
}

/// Helper class for markdown shortcut pattern detection.
class _ShortcutPattern {
  final RegExp regex;
  final String open;
  final String close;
  final RichTextFormatType formatType;

  const _ShortcutPattern(this.regex, this.open, this.close, this.formatType);
}
