import 'package:flutter/material.dart';

/// [CometChatNewMessageIndicatorStyle] is a data class that has styling-related properties
/// to customize the appearance of [CometChatNewMessageIndicator]
///
/// ```dart
/// CometChatNewMessageIndicatorStyle(
///   textColor: Colors.blue,
///   dividerColor: Colors.grey,
///   textStyle: TextStyle(fontSize: 12),
///   backgroundColor: Colors.white,
/// )
/// ```
class CometChatNewMessageIndicatorStyle
    extends ThemeExtension<CometChatNewMessageIndicatorStyle> {
  const CometChatNewMessageIndicatorStyle({
    this.textColor,
    this.dividerColor,
    this.textStyle,
    this.backgroundColor,
  });

  /// [textColor] defines the color of the indicator text
  final Color? textColor;

  /// [dividerColor] defines the color of the divider lines
  final Color? dividerColor;

  /// [textStyle] defines the style of the indicator text
  final TextStyle? textStyle;

  /// [backgroundColor] defines the background color of the indicator
  final Color? backgroundColor;

  /// Copy with some properties replaced
  @override
  CometChatNewMessageIndicatorStyle copyWith({
    Color? textColor,
    Color? dividerColor,
    TextStyle? textStyle,
    Color? backgroundColor,
  }) {
    return CometChatNewMessageIndicatorStyle(
      textColor: textColor ?? this.textColor,
      dividerColor: dividerColor ?? this.dividerColor,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Merge with another CometChatNewMessageIndicatorStyle
  CometChatNewMessageIndicatorStyle merge(
    CometChatNewMessageIndicatorStyle? other,
  ) {
    if (other == null) return this;
    return copyWith(
      textColor: other.textColor,
      dividerColor: other.dividerColor,
      textStyle: other.textStyle,
      backgroundColor: other.backgroundColor,
    );
  }

  @override
  CometChatNewMessageIndicatorStyle lerp(
    CometChatNewMessageIndicatorStyle? other,
    double t,
  ) {
    if (other is! CometChatNewMessageIndicatorStyle) {
      return this;
    }
    return CometChatNewMessageIndicatorStyle(
      textColor: Color.lerp(textColor, other.textColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
    );
  }
}
