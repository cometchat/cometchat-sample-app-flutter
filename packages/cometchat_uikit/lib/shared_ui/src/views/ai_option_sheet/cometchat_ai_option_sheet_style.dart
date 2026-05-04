import 'package:flutter/material.dart';

/// Styling properties for the AI option sheet bottom modal.
class CometChatAiOptionSheetStyle
    extends ThemeExtension<CometChatAiOptionSheetStyle> {
  const CometChatAiOptionSheetStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.iconColor,
    this.textStyle,
  });

  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? border;
  final Color? iconColor;
  final TextStyle? textStyle;

  static CometChatAiOptionSheetStyle of(BuildContext context) =>
      const CometChatAiOptionSheetStyle();

  @override
  CometChatAiOptionSheetStyle copyWith({
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    BorderSide? border,
    Color? iconColor,
    TextStyle? textStyle,
  }) {
    return CometChatAiOptionSheetStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  CometChatAiOptionSheetStyle merge(CometChatAiOptionSheetStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      borderRadius: other.borderRadius,
      border: other.border,
      iconColor: other.iconColor,
      textStyle: other.textStyle,
    );
  }

  @override
  CometChatAiOptionSheetStyle lerp(
      ThemeExtension<CometChatAiOptionSheetStyle>? other, double t) {
    if (other is! CometChatAiOptionSheetStyle) return this;
    return CometChatAiOptionSheetStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      border: BorderSide.lerp(
          border ?? BorderSide.none, other.border ?? BorderSide.none, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
