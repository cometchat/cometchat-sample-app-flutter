import 'package:cometchat_uikit_shared/src/views/ai_agent_view_builders/cometchat_code_block.dart';
import 'package:cometchat_uikit_shared/src/views/ai_agent_view_builders/cometchat_table_builder.dart';
import 'package:cometchat_uikit_shared/src/views/ai_agent_view_builders/stream_viewer_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../../cometchat_uikit_shared.dart';
import '../ai_agent_view_builders/cometchat_highlight_builder.dart';
import '../ai_agent_view_builders/cometchat_link_builder.dart';
import 'cometchat_stream_bubble_controller.dart';

class CometChatStreamBubble extends StatefulWidget {
  const CometChatStreamBubble({
    super.key,
    required this.message,
    this.text,
    this.style,
    this.width,
    this.height,
    this.alignment,
  });

  ///[text] if message object is not passed then text should be passed
  final String? text;

  ///[message] if message object is passed then text from message object will be shown
  final StreamMessage message;

  ///[style] manages the styling of this widget
  final CometChatAIAssistantBubbleStyle? style;

  ///[width] of the bubble
  final double? width;

  ///[height] of the bubble
  final double? height;

  ///[alignment] of the bubble
  final BubbleAlignment? alignment;

  @override
  State<CometChatStreamBubble> createState() => _CometChatStreamBubbleState();
}

class _CometChatStreamBubbleState extends State<CometChatStreamBubble> {
  late CometChatStreamBubbleController streamBubbleController;
  late CometChatAIAssistantBubbleStyle aiAssistantBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    aiAssistantBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatAIAssistantBubbleStyle>(
                context: context,
                defaultTheme: CometChatAIAssistantBubbleStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    streamBubbleController = CometChatStreamBubbleController(
      streamMessage: widget.message,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: streamBubbleController,
      builder: (CometChatStreamBubbleController controller) {
        return Container(
          height: widget.height,
          width: widget.width ?? MediaQuery.of(context).size.width * (70 / 100),
          decoration: BoxDecoration(
            border: aiAssistantBubbleStyle.border,
            borderRadius:
                aiAssistantBubbleStyle.borderRadius ?? BorderRadius.zero,
            color: aiAssistantBubbleStyle.backgroundColor ??
                colorPalette.transparent,
          ),
          padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.0058,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CometChatShimmerEffect(
                linearGradient:
                    (widget.message.metadata?[AIConstants.aiShimmer] == true)
                        ? LinearGradient(
                            colors: [
                              colorPalette.textTertiary ?? Colors.transparent,
                              colorPalette.textPrimary ?? Colors.transparent,
                              colorPalette.textTertiary ?? Colors.transparent,
                            ],
                          )
                        : null,
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
                      controller.text,
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
              ),
              if (controller.errorText.isNotEmpty && controller.hasError) ...[
                SizedBox(height: spacing.padding2),
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: spacing.padding ?? 0,
                      horizontal: spacing.padding2 ?? 0),
                  color: colorPalette.error100,
                  child: Text(
                    controller.errorText,
                    style: TextStyle(
                      color: colorPalette.error,
                      fontWeight: typography.caption1?.regular?.fontWeight,
                      fontSize: typography.caption1?.regular?.fontSize,
                      fontFamily: typography.caption1?.regular?.fontFamily,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
