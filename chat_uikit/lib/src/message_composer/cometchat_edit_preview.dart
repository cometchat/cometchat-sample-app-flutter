import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

///[CometChatEditPreview] is a component that provides a bubble consisting of text
///that can be appended to the message composer, message bubble or any other component as desired
///the appearance is similar to quote block of markdown files
class CometChatEditPreview extends StatelessWidget {
  const CometChatEditPreview({
    super.key,
    required this.editPreviewTitle,
    required this.editPreviewSubtitle,
    this.editPreviewCloseButtonIcon,
    this.style = const CometChatEditPreviewStyle(),
    this.onCloseClick,
    this.hideCloseButton = false,
  });

  ///[editPreviewTitle]
  final String editPreviewTitle;

  ///[editPreviewSubtitle] replace message preview subtitle
  final String editPreviewSubtitle;

  ///[editPreviewCloseButtonIcon] replaces message preview close button
  final Icon? editPreviewCloseButtonIcon;

  ///[style] alters styling properties
  final CometChatEditPreviewStyle style;

  ///[onCloseClick] call function to be called on close button click
  final Function()? onCloseClick;

  ///[hideCloseButton] if true the it hides close button
  final bool hideCloseButton;

  @override
  Widget build(BuildContext context) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    return Container(
      padding: EdgeInsets.all(spacing.padding ?? 0),
      decoration: BoxDecoration(
        color: colorPalette.borderDefault,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(spacing.radius2 ?? 0),
            topRight: Radius.circular(spacing.radius2 ?? 0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(spacing.radius2 ?? 0),
            topRight: Radius.circular(spacing.radius2 ?? 0)),
        child: Container(
          height: 51,
          decoration: BoxDecoration(
            color: style.editPreviewBackground,
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: spacing.padding2 ?? 0,
                top: spacing.padding2 ?? 0,
                right: spacing.padding2 ?? 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editPreviewTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.editPreviewTitleStyle ??
                          TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff141414).withOpacity(0.6)),
                    ),
                    if (hideCloseButton == false)
                      GestureDetector(
                          onTap: onCloseClick,
                          child: editPreviewCloseButtonIcon ??
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
                    editPreviewSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.editPreviewSubtitleStyle ??
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

class CometChatEditPreviewStyle {
  const CometChatEditPreviewStyle(
      {this.editPreviewBackground,
      this.editPreviewBorder,
      this.editPreviewTitleStyle,
      this.editPreviewSubtitleStyle,
      this.closeIconColor});

  ///[editPreviewBackground]
  final Color? editPreviewBackground;

  ///[editPreviewBorder]
  final BoxBorder? editPreviewBorder;

  ///[editPreviewTitleStyle]
  final TextStyle? editPreviewTitleStyle;

  ///[editPreviewSubtitleStyle]
  final TextStyle? editPreviewSubtitleStyle;

  ///[closeIconColor]
  final Color? closeIconColor;
}