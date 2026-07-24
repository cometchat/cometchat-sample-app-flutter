import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
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
    this.textFormatters,
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

  ///[textFormatters] list of text formatters for rendering rich text in the subtitle
  ///_Requirements: 2.14_
  final List<CometChatTextFormatter>? textFormatters;

  @override
  Widget build(BuildContext context) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(
      context,
    );
    return Container(
      padding: EdgeInsets.all(spacing.padding ?? 0),
      decoration: BoxDecoration(
        color: colorPalette.borderDefault,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(spacing.radius2 ?? 0),
          topRight: Radius.circular(spacing.radius2 ?? 0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(spacing.radius2 ?? 0),
          topRight: Radius.circular(spacing.radius2 ?? 0),
        ),
        child: Container(
          height: 51,
          decoration: BoxDecoration(color: style.editPreviewBackground),
          child: Padding(
            padding: EdgeInsets.only(
              left: spacing.padding2 ?? 0,
              top: spacing.padding2 ?? 0,
              right: spacing.padding2 ?? 0,
            ),
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
                      style:
                          style.editPreviewTitleStyle ??
                          TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(
                              0xff141414,
                            ).withValues(alpha: 0.6),
                          ),
                    ),
                    if (hideCloseButton == false)
                      GestureDetector(
                        onTap: onCloseClick,
                        child:
                            editPreviewCloseButtonIcon ??
                            Icon(
                              Icons.close,
                              size: 20,
                              color:
                                  style.closeIconColor ??
                                  const Color(0xff000000),
                            ),
                      ),
                  ],
                ),
                Flexible(child: _buildSubtitleWidget(context, colorPalette)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the subtitle widget with rich text rendering if formatters are provided.
  /// Uses RichText widget with FormatterUtils.buildConversationTextSpan() for formatting.
  /// Applies 1-line constraint with overflow truncation.
  /// _Requirements: 2.14_
  Widget _buildSubtitleWidget(
    BuildContext context,
    CometChatColorPalette colorPalette,
  ) {
    // Default text style for the subtitle
    final defaultTextStyle =
        style.editPreviewSubtitleStyle ??
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xff141414).withValues(alpha: 0.6),
        );

    // If no text formatters provided, use plain Text widget
    if (textFormatters == null || textFormatters!.isEmpty) {
      return Text(
        editPreviewSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: defaultTextStyle,
      );
    }

    // Build rich text spans using FormatterUtils
    final textSpans = FormatterUtils.buildConversationTextSpan(
      editPreviewSubtitle,
      textFormatters,
      context,
      defaultTextStyle,
    );

    // Use RichText widget with 1-line constraint and ellipsis overflow
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: defaultTextStyle, children: textSpans),
    );
  }
}

class CometChatEditPreviewStyle {
  const CometChatEditPreviewStyle({
    this.editPreviewBackground,
    this.editPreviewBorder,
    this.editPreviewTitleStyle,
    this.editPreviewSubtitleStyle,
    this.closeIconColor,
  });

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
