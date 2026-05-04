import 'package:flutter/material.dart';

/// Style for individual AI option items in the option sheet.
class AIOptionsStyle extends ThemeExtension<AIOptionsStyle> {
  final Color? backgroundColor;
  final Border? border;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? titleTextStyle;
  final Color? titleColor;
  final Color? iconColor;

  const AIOptionsStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.titleTextStyle,
    this.titleColor,
    this.iconColor,
  });

  static AIOptionsStyle of(BuildContext context) => const AIOptionsStyle();

  @override
  AIOptionsStyle copyWith({
    Color? backgroundColor,
    Border? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? titleTextStyle,
    Color? titleColor,
    Color? iconColor,
  }) {
    return AIOptionsStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleColor: titleColor ?? this.titleColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  AIOptionsStyle merge(AIOptionsStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      titleTextStyle: other.titleTextStyle,
      titleColor: other.titleColor,
      iconColor: other.iconColor,
    );
  }

  @override
  AIOptionsStyle lerp(ThemeExtension<AIOptionsStyle>? other, double t) {
    if (other is! AIOptionsStyle) return this;
    return AIOptionsStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
    );
  }
}
