import 'package:cometchat_uikit_shared/src/views/ai_agent_view_builders/cometchat_code_block.dart';
import 'package:cometchat_uikit_shared/src/views/ai_agent_view_builders/stream_viewer_helper.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../../cometchat_uikit_shared.dart';
import '../ai_agent_view_builders/cometchat_highlight_builder.dart';
import '../ai_agent_view_builders/cometchat_link_builder.dart';
import '../ai_agent_view_builders/cometchat_table_builder.dart'
    show CometChatAiAssistantTableBuilder;

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
                defaultTheme: CometChatAIAssistantBubbleStyle.of)
            .merge(style);

    CometChatTypography typography =
        CometChatThemeHelper.getTypography(context);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);

    return Container(
      height: height,
      width: width ?? MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        border: aiAssistantBubbleStyle.border,
        borderRadius: aiAssistantBubbleStyle.borderRadius ?? BorderRadius.zero,
        color:
            aiAssistantBubbleStyle.backgroundColor ?? colorPalette.transparent,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.0058,
      ),
      child: NoIntrinsicScroll(
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
            (message)?.text ?? text ?? '',
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
              // Wrap the table builder in a NoIntrinsicScroll to prevent computeDryBaseline
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
    );
  }
}
