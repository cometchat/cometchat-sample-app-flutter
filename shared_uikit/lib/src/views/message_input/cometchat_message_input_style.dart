import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatMessageInputStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatMessageInput]
///
/// ```dart
/// CometChatMessageInputStyle(
/// textStyle: TextStyle(),
/// textColor: Colors.black,
/// placeholderTextStyle: TextStyle(),
/// placeholderColor: Colors.grey,
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.grey),
/// borderRadius: BorderRadius.circular(10),
/// )
/// ```
class CometChatMessageInputStyle extends ThemeExtension<CometChatMessageInputStyle> {
  const CometChatMessageInputStyle({
    this.textStyle,
    this.textColor,
    this.placeholderTextStyle,
    this.placeholderColor,
    this.dividerTint,
    this.dividerHeight,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.filledColor,
  });

  ///[textStyle] provides style to the input field
  final TextStyle? textStyle;

  ///[placeholderTextStyle] hint text style
  final TextStyle? placeholderTextStyle;

  ///[dividerTint] provides color to the divider separating input field and bottom bar
  final Color? dividerTint;

  ///[dividerHeight] provides height to the divider separating input field and bottom bar
  final double? dividerHeight;

  ///[backgroundColor] background color of message input
  final Color? backgroundColor;

  ///[border] border of message input
  final BoxBorder? border;

  ///[borderRadius] border radius of message input
  final BorderRadiusGeometry? borderRadius;

  ///[textColor] color of the TextField text
  final Color? placeholderColor;

  ///[placeholderColor] color of the placeholder text
  final Color? textColor;

  ///[filledColor] specifies the color used to fill the background of the message input
  final Color? filledColor;

  @override
  CometChatMessageInputStyle copyWith({
    TextStyle? textStyle,
    Color? textColor,
    TextStyle? placeholderTextStyle,
    Color? placeholderColor,
    Color? dividerTint,
    double? dividerHeight,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? filledColor,
  }) {
    return CometChatMessageInputStyle(
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      dividerTint: dividerTint ?? this.dividerTint,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      filledColor: filledColor ?? this.filledColor,
    );
  }

  CometChatMessageInputStyle merge(CometChatMessageInputStyle? other) {
    if (other == null) return this;
    return copyWith(
      textStyle: other.textStyle,
      textColor: other.textColor,
      placeholderTextStyle: other.placeholderTextStyle,
      placeholderColor: other.placeholderColor,
      dividerTint: other.dividerTint,
      dividerHeight: other.dividerHeight,
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      filledColor: other.filledColor,
    );
  }

  static CometChatMessageInputStyle of(BuildContext context) =>
      const CometChatMessageInputStyle();

  @override
  CometChatMessageInputStyle lerp(CometChatMessageInputStyle? other, double t) {
    if (other == null) return this;
    return CometChatMessageInputStyle(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      placeholderTextStyle: TextStyle.lerp(placeholderTextStyle, other.placeholderTextStyle, t),
      placeholderColor: Color.lerp(placeholderColor, other.placeholderColor, t),
      dividerTint: Color.lerp(dividerTint, other.dividerTint, t),
      dividerHeight: lerpDouble(dividerHeight, other.dividerHeight, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      filledColor: Color.lerp(filledColor, other.filledColor, t),
    );
  }
}
