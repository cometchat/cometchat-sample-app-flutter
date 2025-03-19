import 'package:flutter/material.dart';


///[CometChatActionBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of group action message bubble
///
/// ```dart
/// CometChatActionBubbleStyle(
/// textStyle: TextStyle(),
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.red),
/// borderRadius: BorderRadius.circular(10),
/// );
/// ```
class CometChatActionBubbleStyle extends ThemeExtension<CometChatActionBubbleStyle> {
  const CometChatActionBubbleStyle({
    this.textStyle,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  ///[textStyle] text style of group action message
  final TextStyle? textStyle;

  ///[backgroundColor] background color of group action message
  final Color? backgroundColor;

  ///[border] border of group action message
  final BoxBorder? border;

  ///[borderRadius] border radius of group action message
  final BorderRadiusGeometry? borderRadius;

  @override
  CometChatActionBubbleStyle copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
  }) {
    return CometChatActionBubbleStyle(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  CometChatActionBubbleStyle merge(covariant CometChatActionBubbleStyle? other) {
    if (other == null) return this;
    return copyWith(
      textStyle: other.textStyle,
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
    );
  }

  static CometChatActionBubbleStyle of(BuildContext context) =>
      const CometChatActionBubbleStyle();

  @override
  CometChatActionBubbleStyle lerp(CometChatActionBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatActionBubbleStyle(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
    );
  }
}
