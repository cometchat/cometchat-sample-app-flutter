import 'package:flutter/material.dart';

class CometChatMessagePreviewStyle
    extends ThemeExtension<CometChatMessagePreviewStyle> {
  const CometChatMessagePreviewStyle({
    this.messagePreviewBackground,
    this.messagePreviewBorder,
    this.messagePreviewTitleStyle,
    this.messagePreviewSubtitleStyle,
    this.closeIconColor,
    this.messagePreviewSubtitleColor,
    this.messagePreviewTitleColor,
    this.messagePreviewBorderRadius,
    this.replyMessagePreviewCloseIconColor,
  });

  ///[messagePreviewBackground]
  final Color? messagePreviewBackground;

  ///[messagePreviewBorder]
  final BoxBorder? messagePreviewBorder;

  ///[messagePreviewBorderRadius]
  final BorderRadius? messagePreviewBorderRadius;

  ///[messagePreviewTitleStyle]
  final TextStyle? messagePreviewTitleStyle;

  ///[messagePreviewSubtitleStyle]
  final TextStyle? messagePreviewSubtitleStyle;

  ///[messagePreviewTitleColor]
  final Color? messagePreviewTitleColor;

  ///[messagePreviewSubtitleColor]
  final Color? messagePreviewSubtitleColor;

  ///[closeIconColor]
  final Color? closeIconColor;

  ///[replyMessagePreviewCloseIconColor]
  final Color? replyMessagePreviewCloseIconColor;

  @override
  CometChatMessagePreviewStyle copyWith({
    Color? messagePreviewBackground,
    BoxBorder? messagePreviewBorder,
    TextStyle? messagePreviewTitleStyle,
    TextStyle? messagePreviewSubtitleStyle,
    Color? closeIconColor,
    Color? messagePreviewTitleColor,
    Color? messagePreviewSubtitleColor,
    BorderRadius? messagePreviewBorderRadius,
    Color? replyMessagePreviewCloseIconColor,
  }) {
    return CometChatMessagePreviewStyle(
      messagePreviewBackground:
          messagePreviewBackground ?? this.messagePreviewBackground,
      messagePreviewBorder: messagePreviewBorder ?? this.messagePreviewBorder,
      messagePreviewTitleStyle:
          messagePreviewTitleStyle ?? this.messagePreviewTitleStyle,
      messagePreviewSubtitleStyle:
          messagePreviewSubtitleStyle ?? this.messagePreviewSubtitleStyle,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      messagePreviewTitleColor:
          messagePreviewTitleColor ?? this.messagePreviewTitleColor,
      messagePreviewSubtitleColor:
          messagePreviewSubtitleColor ?? this.messagePreviewSubtitleColor,
      messagePreviewBorderRadius:
          messagePreviewBorderRadius ?? this.messagePreviewBorderRadius,
      replyMessagePreviewCloseIconColor: replyMessagePreviewCloseIconColor ??
          this.replyMessagePreviewCloseIconColor,
    );
  }

  CometChatMessagePreviewStyle merge(CometChatMessagePreviewStyle? other) {
    if (other == null) return this;
    return copyWith(
      messagePreviewBackground: other.messagePreviewBackground,
      messagePreviewBorder: other.messagePreviewBorder,
      messagePreviewTitleStyle: other.messagePreviewTitleStyle,
      messagePreviewSubtitleStyle: other.messagePreviewSubtitleStyle,
      closeIconColor: other.closeIconColor,
      messagePreviewTitleColor: other.messagePreviewTitleColor,
      messagePreviewSubtitleColor: other.messagePreviewSubtitleColor,
      messagePreviewBorderRadius: other.messagePreviewBorderRadius,
      replyMessagePreviewCloseIconColor:
          other.replyMessagePreviewCloseIconColor,
    );
  }

  static CometChatMessagePreviewStyle of(BuildContext context) =>
      const CometChatMessagePreviewStyle();

  @override
  CometChatMessagePreviewStyle lerp(
      CometChatMessagePreviewStyle? other, double t) {
    if (other == null) return this;
    return CometChatMessagePreviewStyle(
      messagePreviewBackground: Color.lerp(
          messagePreviewBackground, other.messagePreviewBackground, t),
      messagePreviewBorder:
          BoxBorder.lerp(messagePreviewBorder, other.messagePreviewBorder, t),
      messagePreviewTitleStyle: TextStyle.lerp(
          messagePreviewTitleStyle, other.messagePreviewTitleStyle, t),
      messagePreviewSubtitleStyle: TextStyle.lerp(
          messagePreviewSubtitleStyle, other.messagePreviewSubtitleStyle, t),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      messagePreviewTitleColor: Color.lerp(
          messagePreviewTitleColor, other.messagePreviewTitleColor, t),
      messagePreviewSubtitleColor: Color.lerp(
          messagePreviewSubtitleColor, other.messagePreviewSubtitleColor, t),
      messagePreviewBorderRadius: BorderRadius.lerp(
          messagePreviewBorderRadius, other.messagePreviewBorderRadius, t),
      replyMessagePreviewCloseIconColor: Color.lerp(
          replyMessagePreviewCloseIconColor,
          other.replyMessagePreviewCloseIconColor,
          t),
    );
  }
}
