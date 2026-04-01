import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[FormatterUtils] is an utility class which is used to style the text in the message bubble and the conversation subtitle
class FormatterUtils {
  ///[buildTextSpan] is a method which is used to style the text in the message bubble and the conversation subtitle
  ///It takes [text], [formatters], [theme], [alignment] and [forConversation] as a parameter
  ///[text] is a string which needs to be styled
  ///[formatters] is a list of [CometChatTextFormatter] which is used to style the text
  ///[theme] is a object of [CometChatTheme] which is used to style the text
  ///[alignment] is a object of [BubbleAlignment] which is used to style the text
  ///[forConversation] is a boolean which is used to style the text in the conversation subtitle
  static List<InlineSpan> buildTextSpan(
      String text,
      List<CometChatTextFormatter>? formatters,
      BuildContext context,
      BubbleAlignment? alignment,
      {bool forConversation = false, TextStyle? textStyle}) {
    List<InlineSpan> textSpan = [];
    List<AttributedText> attributedTexts = [];
    for (CometChatTextFormatter formatter in formatters ?? []) {
      attributedTexts = formatter.getAttributedText(text, context, alignment,
          existingAttributes: attributedTexts,
          forConversation: forConversation);
    }
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatTypography typography =
        CometChatThemeHelper.getTypography(context);

    // Sort attributed texts by start position to ensure correct ordering
    attributedTexts.sort((a, b) => a.start.compareTo(b.start));

    int start = 0;

    for (AttributedText attributedText in attributedTexts) {
      // Validate indices before substring operations
      if (attributedText.start < 0 ||
          attributedText.start > text.length ||
          attributedText.end < 0 ||
          attributedText.end > text.length ||
          attributedText.start > attributedText.end ||
          start > text.length ||
          start > attributedText.start ||
          start < 0) {
        continue; // Skip invalid attributed text
      }

      // Additional safety check for substring operation
      String beforeText = '';
      if (start < attributedText.start && start >= 0 && attributedText.start <= text.length) {
        beforeText = text.substring(start, attributedText.start);
        // Convert bullet markers to bullet points for display
        beforeText = _convertBulletMarkersForDisplay(beforeText, isLineStart: start == 0 || (start > 0 && text[start - 1] == '\n'));
        // Convert blockquote markers for display
        beforeText = _convertBlockquoteMarkersForDisplay(beforeText, isLineStart: start == 0 || (start > 0 && text[start - 1] == '\n'));
      }

      textSpan.add(TextSpan(
        text: beforeText,
        style:textStyle?.merge(TextStyle(
          color: alignment == BubbleAlignment.right
              ? colorPalette.white
              : forConversation
                  ? colorPalette.textSecondary
                  : colorPalette.textPrimary,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
        )),
      ));

      // Get display text and convert bullet markers
      String displayText = attributedText.underlyingText ??
          (attributedText.start >= 0 && 
           attributedText.end <= text.length && 
           attributedText.start <= attributedText.end
              ? text.substring(attributedText.start, attributedText.end)
              : '');
      displayText = _convertBulletMarkersForDisplay(displayText, isLineStart: attributedText.start == 0 || (attributedText.start > 0 && text[attributedText.start - 1] == '\n'));
      // Convert blockquote markers for display
      displayText = _convertBlockquoteMarkersForDisplay(displayText, isLineStart: attributedText.start == 0 || (attributedText.start > 0 && text[attributedText.start - 1] == '\n'));

      // Build the content widget - use RichText if childSpans are provided
      Widget contentWidget;
      if (attributedText.childSpans != null && attributedText.childSpans!.isNotEmpty) {
        // Use RichText for mixed formatting within the container
        contentWidget = RichText(
          text: TextSpan(
            style: attributedText.style ??
                textStyle?.merge(TextStyle(
                  color: alignment == BubbleAlignment.right
                      ? colorPalette.white
                      : colorPalette.textPrimary,
                  fontWeight: typography.body?.regular?.fontWeight,
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                )),
            children: attributedText.childSpans,
          ),
        );
      } else {
        // Use simple Text for single-style content
        contentWidget = Text(
          displayText,
          style: attributedText.style ??
              textStyle?.merge(TextStyle(
                color: alignment == BubbleAlignment.right
                    ? colorPalette.white
                    : colorPalette.textPrimary,
                fontWeight: typography.body?.regular?.fontWeight,
                fontSize: typography.body?.regular?.fontSize,
                fontFamily: typography.body?.regular?.fontFamily,
              )),
        );
      }

      textSpan.add(WidgetSpan(
          child: Container(
        width: attributedText.isFullWidth ? double.infinity : null,
        padding: attributedText.padding,
        decoration: BoxDecoration(
          color: attributedText.backgroundColor,
          borderRadius: BorderRadius.circular(attributedText.borderRadius ?? 0),
          border: attributedText.border,
        ),
        child: InkWell(
          onTap: () async {
            if (!forConversation && attributedText.onTap != null) {
              // Add safety check for substring operation
              if (attributedText.start >= 0 && 
                  attributedText.end <= text.length && 
                  attributedText.start <= attributedText.end) {
                attributedText.onTap!(
                    text.substring(attributedText.start, attributedText.end));
              }
            }
          },
          child: contentWidget,
        ),
      )));
      start = attributedText.end;
    }

    // Validate final substring
    if (start <= text.length) {
      String remainingText = text.substring(start);
      // Convert bullet markers to bullet points for display
      remainingText = _convertBulletMarkersForDisplay(remainingText, isLineStart: start == 0 || (start > 0 && text[start - 1] == '\n'));
      // Convert blockquote markers for display
      remainingText = _convertBlockquoteMarkersForDisplay(remainingText, isLineStart: start == 0 || (start > 0 && text[start - 1] == '\n'));
      textSpan.add(TextSpan(
        text: remainingText,
        style: textStyle?.merge(TextStyle(
          color: alignment == BubbleAlignment.right
              ? colorPalette.white
              : forConversation
                  ? colorPalette.textSecondary
                  : colorPalette.textPrimary,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
        )),
      ));
    }

    return textSpan;
  }

  static List<InlineSpan> buildConversationTextSpan(
    String text,
    List<CometChatTextFormatter>? formatters,
    BuildContext context,
    TextStyle? textStyle,
  ) {
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatTypography typography =
        CometChatThemeHelper.getTypography(context);

    final defaultStyle = TextStyle(
      color: colorPalette.textSecondary,
      fontWeight: typography.body?.regular?.fontWeight,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
    ).merge(textStyle);

    List<InlineSpan> textSpan = [];
    List<AttributedText> attributedTexts = [];
    for (CometChatTextFormatter formatter in formatters ?? []) {
      attributedTexts = formatter.getAttributedText(
          text, context, BubbleAlignment.left,
          existingAttributes: attributedTexts, forConversation: true);
    }

    // If there are no attributed texts, just return the plain text
    // stripped of any markdown formatting
    if (attributedTexts.isEmpty) {
      final strippedText = _stripMarkdownFormatting(text);
      textSpan.add(TextSpan(
        text: strippedText,
        style: defaultStyle,
      ));
      return textSpan;
    }

    // Sort attributed texts by start position
    attributedTexts.sort((a, b) => a.start.compareTo(b.start));

    int start = 0;

    for (AttributedText attributedText in attributedTexts) {
      // Validate indices before substring operations
      if (attributedText.start < 0 ||
          attributedText.start > text.length ||
          attributedText.end < 0 ||
          attributedText.end > text.length ||
          attributedText.start > attributedText.end ||
          start > text.length ||
          start > attributedText.start ||
          start < 0) {
        continue; // Skip invalid attributed text
      }

      // Get the text before this attributed region and strip any markdown from it
      String beforeText = '';
      if (start < attributedText.start && start >= 0 && attributedText.start <= text.length) {
        beforeText = _stripMarkdownFormatting(text.substring(start, attributedText.start));
      }

      if (beforeText.isNotEmpty) {
        textSpan.add(TextSpan(
          text: beforeText,
          style: defaultStyle,
        ));
      }

      // Get the display text - use underlyingText if available (content without markers)
      // Strip any remaining markdown formatting from the display text
      final rawDisplayText = attributedText.underlyingText ??
          (attributedText.start >= 0 && 
           attributedText.end <= text.length && 
           attributedText.start <= attributedText.end
              ? text.substring(attributedText.start, attributedText.end)
              : '');
      final displayText = _stripMarkdownFormatting(rawDisplayText);

      if (displayText.isNotEmpty) {
        // Use TextSpan instead of WidgetSpan for conversation subtitles
        // This ensures proper text truncation with maxLines and overflow
        // Preserve formatting (bold, italic, etc.) but override color
        // with the default style color so reply previews show correct colors
        final mergedStyle = (attributedText.style ?? defaultStyle).copyWith(
          color: defaultStyle.color,
          decorationColor: defaultStyle.color,
        );
        textSpan.add(TextSpan(
          text: displayText,
          style: mergedStyle,
        ));
      }
      start = attributedText.end;
    }

    // Get remaining text after the last attributed region and strip markdown
    if (start <= text.length && start >= 0) {
      final remainingText = _stripMarkdownFormatting(text.substring(start));
      if (remainingText.isNotEmpty) {
        textSpan.add(TextSpan(
          text: remainingText,
          style: defaultStyle,
        ));
      }
    }

    return textSpan;
  }

  /// Strips markdown formatting markers from text, keeping only the content.
  /// Delegates to [FormatPatterns.stripFormatting] for centralized logic.
  static String _stripMarkdownFormatting(String text) {
    return FormatPatterns.stripFormatting(text);
  }
  
  /// Converts bullet list markers ("- ") to bullet point characters ("• ") for display.
  /// 
  /// This method replaces the markdown-style bullet markers with actual bullet
  /// point characters at the start of lines for better visual presentation.
  static String _convertBulletMarkersForDisplay(String inputText, {bool isLineStart = true}) {
    if (inputText.isEmpty) return inputText;
    
    // Replace "- " at the start of lines with "• "
    String result = inputText;
    
    // Handle the case where the text starts with "- " and it's at the start of a line
    // Add a space before bullet and 2 spaces after to align with ordered list items (e.g. "1. ")
    if (isLineStart && result.startsWith('- ')) {
      result = ' •  ${result.substring(2)}';
    }
    
    // Replace "- " after newlines with " •  " (space + bullet + 2 spaces)
    result = result.replaceAll('\n- ', '\n •  ');
    
    return result;
  }
  
  /// Removes blockquote markers ("> ") for display since styling is handled via Container with border.
  /// 
  /// This method removes the markdown-style blockquote markers as the visual
  /// quote styling is handled by a Container with left border.
  static String _convertBlockquoteMarkersForDisplay(String inputText, {bool isLineStart = true}) {
    if (inputText.isEmpty) return inputText;
    
    String result = inputText;
    
    // Handle the case where the text starts with "> " and it's at the start of a line
    if (isLineStart && result.startsWith('> ')) {
      result = result.substring(2);
    }
    
    // Remove "> " after newlines
    result = result.replaceAll('\n> ', '\n');
    
    return result;
  }
}
