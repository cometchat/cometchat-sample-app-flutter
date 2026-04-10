import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';

/// Formatter for bullet lists using - item syntax
class BulletListTextFormatter extends CometChatTextFormatter {
  BulletListTextFormatter()
      : super(
          trackingCharacter: '-',
          // Match lines starting with "- " - use (?:$|\n) to match end of string OR newline
          pattern: RegExp(r'^- (.*)(?:$)', multiLine: true),
        );

  /// Insert bullet at current line
  FormatResult insertBullet(String text, TextSelection selection) {
    // Find start of current line
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    // Insert "- " at line start
    final newText =
        '${text.substring(0, lineStart)}- ${text.substring(lineStart)}';

    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(
        offset: selection.start + 2,
      ),
      formatApplied: RichTextFormatType.bulletList,
    );
  }

  /// Handle Enter key in bullet list
  FormatResult? handleEnter(String text, TextSelection selection) {
    // Check if current line is a bullet item
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final lineEnd = text.indexOf('\n', selection.start);
    final currentLine = text.substring(
      lineStart,
      lineEnd == -1 ? text.length : lineEnd,
    );

    if (currentLine.trim() == '-') {
      // Empty bullet - remove it and exit list mode
      final newText = text.substring(0, lineStart) +
          text.substring(lineEnd == -1 ? text.length : lineEnd);
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(offset: lineStart),
        formatApplied: RichTextFormatType.bulletList,
      );
    } else if (currentLine.startsWith('- ')) {
      // Continue list with new bullet
      final newText =
          '${text.substring(0, selection.start)}\n- ${text.substring(selection.start)}';
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + 3,
        ),
        formatApplied: RichTextFormatType.bulletList,
      );
    }

    return null;
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
      
      // Only transform the prefix "- " to "• " (2 characters)
      // Leave the content for other formatters to process
      final prefixEnd = start + 2; // "- " is 2 characters

      // Only add attributed text for the prefix transformation
      attributedTexts.add(AttributedText(
        start: start,
        end: prefixEnd,
        // Replace "- " with visual bullet "• "
        underlyingText: '• ',
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
