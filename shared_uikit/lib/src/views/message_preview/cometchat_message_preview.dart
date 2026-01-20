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
                      GestureDetector(
                        onTap: onCloseClick,
                        child: messagePreviewCloseButtonIcon ??
                            Icon(
                              Icons.close,
                              size: 16,
                              color: style.closeIconColor ??
                                  colorPalette.iconSecondary,
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
                      child: Text(
                        messagePreviewSubtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: typography.caption1?.regular?.fontSize,
                          fontWeight: typography.caption1?.regular?.fontWeight,
                          color: colorPalette.textSecondary,
                        ).merge(style.messagePreviewSubtitleStyle).copyWith(
                              color: style.messagePreviewSubtitleColor,
                            ),
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
}
