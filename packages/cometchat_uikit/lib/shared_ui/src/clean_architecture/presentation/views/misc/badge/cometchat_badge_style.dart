
import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CometChatBadgeStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatBadge]
///``` dart
///CometChatBadgeStyle(
/// textStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 12,
/// fontWeight: FontWeight.bold,
/// ),
/// textColor: Colors.white,
/// backgroundColor: Colors.red,
/// border: Border.all(color: Colors.white, width: 0),
/// );
///```
class CometChatBadgeStyle extends ThemeExtension<CometChatBadgeStyle> {
  const CometChatBadgeStyle({
    this.textStyle,
    this.textColor,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.boxShape,
  });

  ///[textStyle] gives style to count
  final TextStyle? textStyle;

  ///[textColor] text Color of the count
  final Color? textColor;

  ///[backgroundColor] background color of the badge
  final Color? backgroundColor;

  ///[border] border of the badge
  final Border? border;

  ///[borderRadius] border radius of the badge
  final BorderRadiusGeometry? borderRadius;

  ///[boxShape] shape of the badge
  final BoxShape? boxShape;

  static CometChatBadgeStyle of(BuildContext context) =>
      const CometChatBadgeStyle();

  @override
  CometChatBadgeStyle copyWith({
    Color? backgroundColor,
    Border? border,
    TextStyle? textStyle,
    Color? textColor,
    BorderRadiusGeometry? borderRadius,
    BoxShape? boxShape,
  }) {
    return CometChatBadgeStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShape: boxShape ?? this.boxShape,
    );
  }

  CometChatBadgeStyle merge(CometChatBadgeStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      textStyle: style.textStyle,
      textColor: style.textColor,
      borderRadius: style.borderRadius,
      boxShape: style.boxShape,
    );
  }

  @override
  CometChatBadgeStyle lerp(
      ThemeExtension<CometChatBadgeStyle>? other, double t) {
    if (other is! CometChatBadgeStyle) {
      return this;
    }
    return CometChatBadgeStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      boxShape: t < 0.5 ? boxShape : other.boxShape,
    );
  }
}
