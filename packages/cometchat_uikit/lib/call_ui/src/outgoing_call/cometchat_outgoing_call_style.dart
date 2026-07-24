import '../../../cometchat_chat_uikit.dart';

import 'package:flutter/material.dart';

/// [CometChatOutgoingCallStyle] is the data class that contains style configuration for [CometChatOutgoingCall]
///
/// ```dart
/// CometChatOutgoingCallStyle(
/// backgroundColor: Colors.white,
/// avatarStyle: CometChatAvatarStyle(),
/// declineButtonColor: Colors.red,
/// iconColor: Colors.white,
/// subtitleColor: Colors.black,
/// subtitleTextStyle: TextStyle(fontSize: 16, color: Colors.black),
/// titleColor: Colors.black,
/// titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
/// );
/// ```
class CometChatOutgoingCallStyle
    extends ThemeExtension<CometChatOutgoingCallStyle> {
  CometChatOutgoingCallStyle({
    this.backgroundColor,
    this.avatarStyle,
    this.declineButtonColor,
    this.declineButtonBorderRadius,
    this.iconColor,
    this.subtitleColor,
    this.subtitleTextStyle,
    this.titleColor,
    this.titleTextStyle,
    this.borderRadius,
    this.border,
  });

  ///[titleTextStyle] is used to set the text style for the title.
  final TextStyle? titleTextStyle;

  ///[titleColor] is used to set the color for the title.
  final Color? titleColor;

  ///[subtitleTextStyle] is used to set the text style for the subtitle.
  final TextStyle? subtitleTextStyle;

  ///[subtitleColor] is used to set the color for the subtitle.
  final Color? subtitleColor;

  ///[avatarStyle] is used to set the avatar style.
  final CometChatAvatarStyle? avatarStyle;

  ///[iconColor] is used to set the color for the icon.
  final Color? iconColor;

  ///[backgroundColor] is used to set the background color.
  final Color? backgroundColor;

  ///[declineButtonColor] is used to set the button color.
  final Color? declineButtonColor;

  ///[declineButtonBorderRadius] is used to set the button border radius.
  final BorderRadiusGeometry? declineButtonBorderRadius;

  ///[border] provides border for the widget
  final Border? border;

  ///[borderRadius] provides border radius for the widget
  final BorderRadiusGeometry? borderRadius;

  static CometChatOutgoingCallStyle of(BuildContext context) =>
      CometChatOutgoingCallStyle();

  @override
  CometChatOutgoingCallStyle copyWith({
    Color? backgroundColor,
    CometChatAvatarStyle? avatarStyle,
    Color? declineButtonColor,
    BorderRadiusGeometry? declineButtonBorderRadius,
    Color? iconColor,
    Color? subtitleColor,
    TextStyle? subtitleTextStyle,
    Color? titleColor,
    TextStyle? titleTextStyle,
    BorderRadiusGeometry? borderRadius,
    Border? border,
  }) {
    return CometChatOutgoingCallStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      declineButtonColor: declineButtonColor ?? this.declineButtonColor,
      declineButtonBorderRadius:
          declineButtonBorderRadius ?? this.declineButtonBorderRadius,
      iconColor: iconColor ?? this.iconColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      titleColor: titleColor ?? this.titleColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
    );
  }

  CometChatOutgoingCallStyle merge(CometChatOutgoingCallStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      avatarStyle: style.avatarStyle,
      declineButtonColor: style.declineButtonColor,
      declineButtonBorderRadius: style.declineButtonBorderRadius,
      iconColor: style.iconColor,
      subtitleColor: style.subtitleColor,
      subtitleTextStyle: style.subtitleTextStyle,
      titleColor: style.titleColor,
      titleTextStyle: style.titleTextStyle,
      borderRadius: style.borderRadius,
      border: style.border,
    );
  }

  @override
  CometChatOutgoingCallStyle lerp(
    ThemeExtension<CometChatOutgoingCallStyle>? other,
    double t,
  ) {
    if (other is! CometChatOutgoingCallStyle) {
      return this;
    }
    return CometChatOutgoingCallStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
      declineButtonColor: Color.lerp(
        declineButtonColor,
        other.declineButtonColor,
        t,
      ),
      declineButtonBorderRadius: BorderRadiusGeometry.lerp(
        declineButtonBorderRadius,
        other.declineButtonBorderRadius,
        t,
      ),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t),
      subtitleTextStyle: TextStyle.lerp(
        subtitleTextStyle,
        other.subtitleTextStyle,
        t,
      ),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
      border: Border.lerp(border, other.border, t),
    );
  }
}
