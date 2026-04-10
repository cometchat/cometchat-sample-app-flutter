import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';

/// Formatter for ordered lists using 1. item syntax
class OrderedListTextFormatter extends CometChatTextFormatter {
  OrderedListTextFormatter()
      : super(
          trackingCharacter: '1',
          // Match lines starting with "N. " - use (?:$|\n) to match end of string OR newline
          pattern: RegExp(r'^(\d+)\. (.*)(?:$)', multiLine: true),
        );

  /// Insert numbered item at current line
  FormatResult insertNumber(String text, TextSelection selection, int number) {
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final prefix = '$number. ';
    final newText =
        '${text.substring(0, lineStart)}$prefix${text.substring(lineStart)}';

    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(
        offset: selection.start + prefix.length,
      ),
      formatApplied: RichTextFormatType.orderedList,
    );
  }

  /// Handle Enter key in ordered list
  FormatResult? handleEnter(String text, TextSelection selection) {
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final lineEnd = text.indexOf('\n', selection.start);
    final currentLine = text.substring(
      lineStart,
      lineEnd == -1 ? text.length : lineEnd,
    );

    final match = RegExp(r'^(\d+)\. (.*)$').firstMatch(currentLine);
    if (match != null) {
      final currentNumber = int.parse(match.group(1)!);
      final content = match.group(2)!;

      if (content.isEmpty) {
        // Empty item - remove and exit list mode
        final newText = text.substring(0, lineStart) +
            text.substring(lineEnd == -1 ? text.length : lineEnd);
        return FormatResult(
          newText: newText,
          newSelection: TextSelection.collapsed(offset: lineStart),
          formatApplied: RichTextFormatType.orderedList,
        );
      } else {
        // Continue with next number
        final nextNumber = currentNumber + 1;
        var newText =
            '${text.substring(0, selection.start)}\n$nextNumber. ${text.substring(selection.start)}';

        // Bug 1.4: Renumber all subsequent items
        newText = _renumberOrderedList(newText);

        final cursorPos = selection.start + '$nextNumber. '.length + 1;
        return FormatResult(
          newText: newText,
          newSelection: TextSelection.collapsed(
            offset: cursorPos.clamp(0, newText.length),
          ),
          formatApplied: RichTextFormatType.orderedList,
        );
      }
    }

    return null;
  }

  /// Renumber all ordered list items sequentially starting from 1 (Bug 1.4)
  static String _renumberOrderedList(String text) {
    final pattern = RegExp(r'^(\d+)\. ', multiLine: true);
    var counter = 0;
    return text.replaceAllMapped(pattern, (match) {
      counter++;
      return '$counter. ';
    });
  }

  /// Check if format is active at the given position
  bool isActiveAtPosition(String text, int position) {
    if (pattern == null) return false;

    for (final match in pattern!.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }
    return false;
  }

  @override
  void init() {
    // Initialize formatter - no-op
  }

  @override
  void handlePreMessageSend(BuildContext context, dynamic baseMessage) {
    // Markdown syntax is preserved in message text
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // Not used
  }

  @override
  void onChange(
      TextEditingController textEditingController, String previousText) {
    // Can be overridden for auto-formatting behavior
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    return const TextStyle();
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }

  @override
  List<AttributedText> getAttributedText(
      String text, BuildContext context, BubbleAlignment? alignment,
      {List<AttributedText>? existingAttributes,
      Function(String)? onTap,
      bool forConversation = false}) {
    if (pattern == null) {
      return existingAttributes ?? [];
    }

    List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    
    for (final match in matches) {
      final start = match.start;
      
      // Group 1 is the number
      final number = match.group(1) ?? '1';
      
      // Calculate the prefix length: "N. " where N is the number
      final prefix = '$number. ';
      final prefixEnd = start + prefix.length;

      // For ordered lists, the prefix stays the same (no transformation needed)
      // But we still need to mark it so it's styled correctly
      // We don't set underlyingText since the display is the same as the source
      // This allows the content after the prefix to be processed by other formatters
      attributedTexts.add(AttributedText(
        start: start,
        end: prefixEnd,
        // No underlyingText needed - display is same as source
        style: getMessageBubbleTextStyle(context, alignment,
            forConversation: forConversation),
        onTap: onTap,
      ));
    }
    
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }
    return attributedTexts;
  }
}
