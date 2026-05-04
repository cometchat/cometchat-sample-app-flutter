import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../cometchat_uikit_shared.dart';

/// Renders a completed AI assistant message with full markdown support.
///
/// Supports code blocks, tables, links, and highlighted text via [GptMarkdown].
class CometChatAIAssistantBubble extends StatelessWidget {
  const CometChatAIAssistantBubble({
    super.key,
    this.text,
    this.message,
    this.style,
    this.width,
    this.height,
    this.alignment,
  });

  final String? text;
  final AIAssistantMessage? message;
  final CometChatAIAssistantBubbleStyle? style;
  final double? width;
  final double? height;
  final BubbleAlignment? alignment;

  @override
  Widget build(BuildContext context) {
    final aiAssistantBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatAIAssistantBubbleStyle>(
      context: context,
      defaultTheme: CometChatAIAssistantBubbleStyle.of,
    ).merge(style);

    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    final String contentText = message?.text ?? text ?? '';

    return Container(
      height: height,
      width: width ?? MediaQuery.sizeOf(context).width * 0.7,
      decoration: BoxDecoration(
        border: aiAssistantBubbleStyle.border,
        borderRadius: aiAssistantBubbleStyle.borderRadius ?? BorderRadius.zero,
        color: aiAssistantBubbleStyle.backgroundColor ??
            colorPalette.transparent,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.sizeOf(context).height * 0.0058,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          NoIntrinsicScroll(
            child: GptMarkdownTheme(
              gptThemeData: GptMarkdownThemeData(
                brightness: Theme.of(context).brightness,
                highlightColor: colorPalette.background4,
                h3: TextStyle(
                  color: colorPalette.textPrimary,
                  fontWeight: typography.body?.bold?.fontWeight,
                  fontSize: typography.body?.bold?.fontSize,
                  fontFamily: typography.body?.bold?.fontFamily,
                ),
              ),
              child: GptMarkdown(
                contentText,
                style: TextStyle(
                  color: colorPalette.textPrimary,
                  fontWeight: typography.body?.regular?.fontWeight,
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                )
                    .merge(aiAssistantBubbleStyle.textStyle)
                    .copyWith(color: aiAssistantBubbleStyle.textColor),
                codeBuilder: (context, name, code, closed) {
                  return NoIntrinsicScroll(
                    child: CometChatAiAssistantCodeBlock(
                      language: name,
                      codes: code,
                      colorPalette: colorPalette,
                      spacing: spacing,
                      typography: typography,
                    ),
                  );
                },
                tableBuilder: (context, tableRows, textStyle, config) {
                  return NoIntrinsicScroll(
                    child: CometChatAiAssistantTableBuilder(
                      tableRows: tableRows,
                      colorPalette: colorPalette,
                      spacing: spacing,
                      typography: typography,
                      config: config,
                    ),
                  );
                },
                highlightBuilder: (context, text, style) {
                  return CometchatHighlightBuilder(
                    text: text,
                    style: style,
                    typography: typography,
                    spacing: spacing,
                    colorPalette: colorPalette,
                  );
                },
                linkBuilder: (context, text, url, style) {
                  return CometchatLinkBuilder(
                    text: text,
                    url: url,
                    style: style,
                    typography: typography,
                    spacing: spacing,
                    colorPalette: colorPalette,
                  );
                },
              ),
            ),
          ),
          // Copy button at bottom-left
          if (contentText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: spacing.padding2 ?? 8),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: contentText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: colorPalette.background3,
                      content: Text(
                        'Copied to clipboard',
                        style: TextStyle(color: colorPalette.textPrimary),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(
                  Icons.content_copy_rounded,
                  size: 18,
                  color: colorPalette.iconSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
