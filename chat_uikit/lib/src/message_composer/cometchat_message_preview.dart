import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

///[CometChatMessagePreview] is a component that provides a bubble consisting of text
///that can be appended to the message composer, message bubble or any other component as desired
///the appearance is similar to quote block of markdown files
class CometChatMessagePreview extends StatelessWidget {
  const CometChatMessagePreview(
      {super.key,
      required this.messagePreviewTitle,
      required this.messagePreviewSubtitle,
      this.messagePreviewCloseButtonIcon,
      this.style = const CometChatMessagePreviewStyle(),
      this.onCloseClick,
      this.hideCloseButton = false});

  ///[messagePreviewTitle]
  final String messagePreviewTitle;

  ///[messagePreviewSubtitle] replace message preview subtitle
  final String messagePreviewSubtitle;

  ///[messagePreviewCloseButtonIcon] replaces message preview close button
  final Icon? messagePreviewCloseButtonIcon;

  ///[style] alters styling properties
  final CometChatMessagePreviewStyle style;

  ///[onCloseClick] call function to be called on close button click
  final Function()? onCloseClick;

  ///[hideCloseButton] if true the it hides close button
  final bool hideCloseButton;

  @override
  Widget build(BuildContext context) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Container(
      padding: EdgeInsets.all(spacing.padding ?? 0),
      decoration: BoxDecoration(
        color: colorPalette.borderDefault,
        borderRadius:BorderRadius.only(topLeft: Radius.circular(spacing.radius2 ?? 0),topRight: Radius.circular(spacing.radius2 ?? 0)),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(spacing.radius2 ?? 0),topRight: Radius.circular(spacing.radius2 ?? 0)),
        child: Container(
          height: 51,
          decoration: BoxDecoration(
            color: style.messagePreviewBackground,
          ),
          child: Padding(
            padding:  EdgeInsets.only(left: spacing.padding2 ?? 0, top: spacing.padding2 ?? 0,right: spacing.padding2 ?? 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      messagePreviewTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.messagePreviewTitleStyle ??
                          TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff141414).withOpacity(0.6)),
                    ),
                    if (hideCloseButton == false)
                      GestureDetector(
                          onTap: onCloseClick,
                          child: messagePreviewCloseButtonIcon ??
                              Icon(
                                Icons.close,
                                size: 20,
                                color: style.closeIconColor ??
                                    const Color(0xff000000),
                              ))
                  ],
                ),
                Flexible(
                  child: Text(
                    messagePreviewSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.messagePreviewSubtitleStyle ??
                        TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff141414).withOpacity(0.6)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CometChatMessagePreviewStyle {
  const CometChatMessagePreviewStyle(
      {this.messagePreviewBackground,
      this.messagePreviewBorder,
      this.messagePreviewTitleStyle,
      this.messagePreviewSubtitleStyle,
      this.closeIconColor});

  ///[messagePreviewBackground]
  final Color? messagePreviewBackground;

  ///[messagePreviewBorder]
  final BoxBorder? messagePreviewBorder;

  ///[messagePreviewTitleStyle]
  final TextStyle? messagePreviewTitleStyle;

  ///[messagePreviewSubtitleStyle]
  final TextStyle? messagePreviewSubtitleStyle;

  ///[closeIconColor]
  final Color? closeIconColor;
}
