import 'package:flutter/material.dart';

import '../../../cometchat_uikit_shared.dart';

///[CometChatMessagePreview] is a component that provides a bubble consisting of text
///that can be appended to the message composer, message bubble or any other component as desired
///the appearance is similar to quote block of markdown files
class CometChatMessagePreview extends StatelessWidget {
  const CometChatMessagePreview({
    super.key,
    required this.messagePreviewTitle,
    required this.messagePreviewSubtitle,
    this.messagePreviewCloseButtonIcon,
    this.messagePreviewStyle,
    this.onCloseClick,
    this.hideCloseButton = false,
    this.message,
    this.textFormatters,
  });

  ///[messagePreviewTitle]
  final String messagePreviewTitle;

  ///[messagePreviewSubtitle] replace message preview subtitle
  final String messagePreviewSubtitle;

  ///[messagePreviewCloseButtonIcon] replaces message preview close button
  final Icon? messagePreviewCloseButtonIcon;

  ///[style] alters styling properties
  final CometChatMessagePreviewStyle? messagePreviewStyle;

  ///[onCloseClick] call function to be called on close button click
  final Function()? onCloseClick;

  ///[hideCloseButton] if true the it hides close button
  final bool hideCloseButton;

  ///[message] message object to get message details
  final BaseMessage? message;

  ///[textFormatters] list of text formatters for rendering rich text in the subtitle
  ///_Requirements: 2.14_
  final List<CometChatTextFormatter>? textFormatters;

  @override
  Widget build(BuildContext context) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatTypography typography =
        CometChatThemeHelper.getTypography(context);
    CometChatMessagePreviewStyle style =
        CometChatThemeHelper.getTheme<CometChatMessagePreviewStyle>(
                context: context, defaultTheme: CometChatMessagePreviewStyle.of)
            .merge(messagePreviewStyle);
    return ClipRRect(
      borderRadius: style.messagePreviewBorderRadius ??
          BorderRadius.all(
            Radius.circular(spacing.radius2 ?? 0),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: style.messagePreviewBackground,
          border: style.messagePreviewBorder ??
              Border(
                top: BorderSide.none,
                bottom: BorderSide.none,
                left: BorderSide(
                  color: colorPalette.borderHighlight ?? Colors.transparent,
                  width: 2,
                ),
                right: BorderSide.none,
              ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            spacing.padding2 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding1 ?? 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      messagePreviewTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: typography.caption1?.medium?.fontSize,
                        fontWeight: typography.caption1?.medium?.fontWeight,
                        color: colorPalette.textHighlight,
                      ).merge(style.messagePreviewTitleStyle).copyWith(
                            color: style.messagePreviewTitleColor,
                          ),
                    ),
                    if (hideCloseButton == false)
                      Semantics(
                        label: 'Close preview',
                        button: true,
                        child: GestureDetector(
                          onTap: onCloseClick,
                          child: messagePreviewCloseButtonIcon ??
                              Icon(
                                Icons.close,
                                size: 16,
                                color: style.closeIconColor ??
                                    colorPalette.iconSecondary,
                              ),
                        ),
                      )
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message != null)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
                      child: ComposerUtils.getReplyIcon(
                        message!,
                        context,
                        style.replyMessagePreviewCloseIconColor ??
                            colorPalette.iconSecondary,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.4,
                      ),
                      child: _buildSubtitleWidget(
                        context,
                        typography,
                        colorPalette,
                        style,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the subtitle widget with rich text rendering if formatters are provided.
  /// Uses RichText widget with CometChatRichTextFormatter for formatting.
  /// Applies 1-line constraint with overflow truncation.
  /// _Requirements: 2.14_
  Widget _buildSubtitleWidget(
    BuildContext context,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
    CometChatMessagePreviewStyle style,
  ) {
    // Default text style for the subtitle
    final defaultTextStyle = TextStyle(
      fontSize: typography.caption1?.regular?.fontSize,
      fontWeight: typography.caption1?.regular?.fontWeight,
      color: colorPalette.textSecondary,
    ).merge(style.messagePreviewSubtitleStyle).copyWith(
          color: style.messagePreviewSubtitleColor,
        );

    // If no text formatters provided, use plain Text widget
    if (textFormatters == null || textFormatters!.isEmpty) {
      return Text(
        messagePreviewSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: defaultTextStyle,
      );
    }

    // Build rich text spans using FormatterUtils
    final textSpans = FormatterUtils.buildConversationTextSpan(
      messagePreviewSubtitle,
      textFormatters,
      context,
      defaultTextStyle,
    );

    // Use RichText widget with 1-line constraint and ellipsis overflow
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: defaultTextStyle,
        children: textSpans,
      ),
    );
  }
}
