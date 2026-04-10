import 'package:flutter/material.dart';

///[CometChatTypingIndicatorStyle] is a style class that has styling-related properties for typing indicator
///to customize the appearance of [CometChatTypingIndicator]
///``` dart
///CometChatTypingIndicatorStyle(
/// textStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 12,
/// fontWeight: FontWeight.bold,
/// ),
/// );
/// ```
class CometChatTypingIndicatorStyle
    extends ThemeExtension<CometChatTypingIndicatorStyle> {
  const CometChatTypingIndicatorStyle({this.textStyle});

  ///[textStyle] gives style to the typing indicator to be displayed
  final TextStyle? textStyle;

  static CometChatTypingIndicatorStyle of(BuildContext context) =>
      const CometChatTypingIndicatorStyle();

  @override
  CometChatTypingIndicatorStyle copyWith({
    TextStyle? textStyle,
  }) {
    return CometChatTypingIndicatorStyle(
      textStyle: textStyle ?? this.textStyle,
    );
  }

  CometChatTypingIndicatorStyle merge(CometChatTypingIndicatorStyle? style) {
    if (style == null) return this;
    return copyWith(
      textStyle: style.textStyle,
    );
  }

  @override
  CometChatTypingIndicatorStyle lerp(
      ThemeExtension<CometChatTypingIndicatorStyle>? other, double t) {
    if (other is! CometChatTypingIndicatorStyle) {
      return this;
    }
    return CometChatTypingIndicatorStyle(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
