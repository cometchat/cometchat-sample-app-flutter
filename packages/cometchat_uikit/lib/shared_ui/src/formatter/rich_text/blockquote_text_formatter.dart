import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for blockquotes using > text syntax
/// Renders in Slack-style with left border bar
/// Consecutive lines starting with > are joined into one block
/// NO formatting in composer - only in preview and message bubbles
class BlockquoteTextFormatter extends RichTextFormatterBase {
  BlockquoteTextFormatter()
      : super(
          // Empty tracking character - blockquote doesn't trigger suggestions
          trackingCharacter: '',
          // Pattern matches one or more consecutive lines starting with >
          // Each line: > followed by optional space and content
          pattern: RegExp(r'(^>[ ]?.*(?:\n>[ ]?.*)*)', multiLine: true),
          openingMarker: '>',
          closingMarker: '',
          placeholderText: 'quote',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.blockquote;

  /// Insert blockquote at current line
  FormatResult insertBlockquote(String text, TextSelection selection) {
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final newText =
        '${text.substring(0, lineStart)}> ${text.substring(lineStart)}';

    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(
        offset: selection.start + 2,
      ),
      formatApplied: RichTextFormatType.blockquote,
    );
  }

  /// Handle Enter key in blockquote
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

    if (currentLine.trim() == '>') {
      // Empty quote - remove and exit
      final newText = text.substring(0, lineStart) +
          text.substring(lineEnd == -1 ? text.length : lineEnd);
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(offset: lineStart),
        formatApplied: RichTextFormatType.blockquote,
      );
    } else if (currentLine.startsWith('> ') || currentLine.startsWith('>')) {
      // Continue blockquote on next line
      final newText =
          '${text.substring(0, selection.start)}\n> ${text.substring(selection.start)}';
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + 3,
        ),
        formatApplied: RichTextFormatType.blockquote,
      );
    }

    return null;
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    return TextStyle(
      fontSize: typography.body?.regular?.fontSize,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      backgroundColor: colorPalette.background2,
      color: colorPalette.textPrimary,
    );
  }

  /// Build styled text for the input field (composer)
  /// Don't apply blockquote formatting in composer - show raw text with > marker
  @override
  List<AttributedText> buildInputFieldText({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
    required String text,
    List<AttributedText>? existingAttributes,
  }) {
    // Don't apply blockquote formatting in the composer input field
    // Just return existing attributes - the raw text with > marker will be shown
    return existingAttributes ?? [];
  }

  /// Extract content from blockquote lines, stripping > markers
  /// Joins multiple lines into one block content
  String _extractBlockquoteContent(String matchedText) {
    final lines = matchedText.split('\n');
    final contentLines = <String>[];
    
    for (final line in lines) {
      // Remove > and optional space from start of line
      String content = line;
      if (content.startsWith('> ')) {
        content = content.substring(2);
      } else if (content.startsWith('>')) {
        content = content.substring(1);
      }
      contentLines.add(content);
    }
    
    return contentLines.join('\n');
  }

  /// Override getAttributedText to render Slack-style blockquotes
  /// - Strips the > marker from display
  /// - Joins consecutive > lines into one block
  /// - Just left border bar, no background (Slack style)
  /// - Inline formatting (bold, italic, etc.) is applied by FormatterUtils
  @override
  List<AttributedText> getAttributedText(
    String text,
    BuildContext context,
    BubbleAlignment? alignment, {
    List<AttributedText>? existingAttributes,
    Function(String)? onTap,
    bool forConversation = false,
  }) {
    if (pattern == null) {
      return existingAttributes ?? [];
    }

    final List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = match.group(0) ?? '';
      
      // Extract content from all lines, stripping > markers
      // Keep the markdown syntax intact - inline formatters will process it
      final quoteContent = _extractBlockquoteContent(matchedText);

      // Slack-style: just left border bar, no background
      // Text color adapts to bubble alignment
      attributedTexts.add(
        AttributedText(
          start: start,
          end: end,
          underlyingText: quoteContent,
          style: TextStyle(
            fontSize: 14,
            color: alignment == BubbleAlignment.right
                ? colorPalette.white
                : colorPalette.textPrimary,
          ),
          // No background - let message bubble color show through
          padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
          // Left border bar only
          border: Border(
            left: BorderSide(
              color: alignment == BubbleAlignment.right
                  ? (colorPalette.white?.withValues(alpha: 0.6) ?? Colors.white70)
                  : (colorPalette.textSecondary ?? Colors.grey),
              width: 3,
            ),
          ),
          isBlockElement: true,
          onTap: onTap,
        ),
      );
    }

    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }

    return attributedTexts;
  }
}
