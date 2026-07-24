import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CometChatAvatarStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAvatar]
///``` dart
///CometChatAvatarStyle(
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.white, width: 0),
/// placeHolderTextStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 20,
/// fontWeight: FontWeight.bold,
/// ),
/// );
/// ```
class CometChatAvatarStyle extends ThemeExtension<CometChatAvatarStyle> {
  const CometChatAvatarStyle({
    this.backgroundColor,
    this.border,
    this.placeHolderTextStyle,
    this.placeHolderTextColor,
    this.borderRadius,
  });

  ///[backgroundColor] background color of the avatar
  final Color? backgroundColor;

  ///[border] border of the avatar
  final Border? border;

  ///[placeHolderTextStyle] place holder text style
  final TextStyle? placeHolderTextStyle;

  ///[placeHolderTextColor] place holder text color
  final Color? placeHolderTextColor;

  ///[borderRadius] border radius of the avatar
  final BorderRadiusGeometry? borderRadius;

  static CometChatAvatarStyle of(BuildContext context) =>
      const CometChatAvatarStyle();

  @override
  CometChatAvatarStyle copyWith({
    Color? backgroundColor,
    Border? border,
    TextStyle? placeHolderTextStyle,
    Color? placeHolderTextColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return CometChatAvatarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      placeHolderTextStyle: placeHolderTextStyle ?? this.placeHolderTextStyle,
      placeHolderTextColor: placeHolderTextColor ?? this.placeHolderTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  CometChatAvatarStyle merge(CometChatAvatarStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      placeHolderTextStyle: style.placeHolderTextStyle,
      placeHolderTextColor: style.placeHolderTextColor,
      borderRadius: style.borderRadius,
    );
  }

  @override
  CometChatAvatarStyle lerp(
    ThemeExtension<CometChatAvatarStyle>? other,
    double t,
  ) {
    if (other is! CometChatAvatarStyle) {
      return this;
    }
    return CometChatAvatarStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      placeHolderTextStyle: TextStyle.lerp(
        placeHolderTextStyle,
        other.placeHolderTextStyle,
        t,
      ),
      placeHolderTextColor: Color.lerp(
        placeHolderTextColor,
        other.placeHolderTextColor,
        t,
      ),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
    );
  }
}
