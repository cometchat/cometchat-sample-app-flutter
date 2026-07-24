import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CometChatDateStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatDate]
///``` dart
///CometChatDateStyle(
/// textStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 12,
/// fontWeight: FontWeight.bold,
/// ),
/// textColor: Colors.white,
/// backgroundColor: Colors.red,
/// border: Border.all(color: Colors.white, width: 0),
/// );
/// ```
class CometChatDateStyle extends ThemeExtension<CometChatDateStyle> {
  const CometChatDateStyle({
    this.textStyle,
    this.border,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  ///[textStyle] gives style to the date to be displayed
  final TextStyle? textStyle;

  ///[backgroundColor] background color of the date
  final Color? backgroundColor;

  ///[border] border of the date
  final Border? border;

  ///[textColor] text Color of the date
  final Color? textColor;

  /// [borderRadius] provides border radius to the date
  final BorderRadiusGeometry? borderRadius;

  static CometChatDateStyle of(BuildContext context) =>
      const CometChatDateStyle();

  @override
  CometChatDateStyle copyWith({
    Color? backgroundColor,
    Border? border,
    TextStyle? textStyle,
    Color? textColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return CometChatDateStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  CometChatDateStyle merge(CometChatDateStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      textStyle: style.textStyle,
      textColor: style.textColor,
      borderRadius: style.borderRadius,
    );
  }

  @override
  CometChatDateStyle lerp(ThemeExtension<CometChatDateStyle>? other, double t) {
    if (other is! CometChatDateStyle) {
      return this;
    }
    return CometChatDateStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
    );
  }
}
