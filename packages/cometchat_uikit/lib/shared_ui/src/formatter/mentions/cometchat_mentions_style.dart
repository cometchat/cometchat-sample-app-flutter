import 'dart:ui';

import 'package:flutter/material.dart';

///[CometChatMentionsStyle] is a data class that has styling-related properties
///to customize the appearance of mentions in the message
///
/// ```dart
/// CometChatMentionsStyle(
/// mentionTextStyle: TextStyle(),
/// mentionTextColor: Colors.blue,
/// mentionTextBackgroundColor: Colors.grey,
/// mentionSelfTextStyle: TextStyle(),
/// mentionSelfTextColor: Colors.white,
/// mentionSelfTextBackgroundColor: Colors.blue,
/// )
/// ```
class CometChatMentionsStyle extends ThemeExtension<CometChatMentionsStyle>{

  CometChatMentionsStyle({
    this.mentionTextStyle,
    this.mentionTextColor,
    this.mentionTextBackgroundColor,
    this.mentionSelfTextStyle,
    this.mentionSelfTextColor,
    this.mentionSelfTextBackgroundColor,
    this.borderRadius,
});
  ///[mentionTextStyle] is a [TextStyle] which is used to style the mention text
  final TextStyle? mentionTextStyle;

  ///[mentionTextColor] is a [Color] which is used to set the color of the mention text
  final Color? mentionTextColor;

  ///[mentionTextBackgroundColor] is a [Color] which is used to set the background color of the mention text
  final Color? mentionTextBackgroundColor;

  ///[mentionSelfTextStyle] is a [TextStyle] which is used to style the mention self text
  final TextStyle? mentionSelfTextStyle;

  ///[mentionSelfTextColor] is a [Color] which is used to set the color of the mention self text
  final Color? mentionSelfTextColor;

  ///[mentionSelfTextBackgroundColor] is a [Color] which is used to set the background color of the mention self text
  final Color? mentionSelfTextBackgroundColor;

  ///[borderRadius] is used to set the border radius of the mention text
  final double? borderRadius;

  @override
  CometChatMentionsStyle copyWith({
    TextStyle? mentionTextStyle,
    Color? mentionTextColor,
    Color? mentionTextBackgroundColor,
    TextStyle? mentionSelfTextStyle,
    Color? mentionSelfTextColor,
    Color? mentionSelfTextBackgroundColor,
    double? borderRadius,
  }) {
    return CometChatMentionsStyle(
      mentionTextStyle: mentionTextStyle ?? this.mentionTextStyle,
      mentionTextColor: mentionTextColor ?? this.mentionTextColor,
      mentionTextBackgroundColor: mentionTextBackgroundColor ?? this.mentionTextBackgroundColor,
      mentionSelfTextStyle: mentionSelfTextStyle ?? this.mentionSelfTextStyle,
      mentionSelfTextColor: mentionSelfTextColor ?? this.mentionSelfTextColor,
      mentionSelfTextBackgroundColor: mentionSelfTextBackgroundColor ?? this.mentionSelfTextBackgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }


  CometChatMentionsStyle merge(CometChatMentionsStyle? style) {
    if (style == null) return this;
    return copyWith(
      mentionTextStyle: style.mentionTextStyle,
      mentionTextColor: style.mentionTextColor,
      mentionTextBackgroundColor: style.mentionTextBackgroundColor,
      mentionSelfTextStyle: style.mentionSelfTextStyle,
      mentionSelfTextColor: style.mentionSelfTextColor,
      mentionSelfTextBackgroundColor: style.mentionSelfTextBackgroundColor,
      borderRadius: style.borderRadius,
    );
  }

  @override
  CometChatMentionsStyle lerp(CometChatMentionsStyle? other, double t) {
    if (other == null) return this;
    return copyWith(
      mentionTextStyle: TextStyle.lerp(mentionTextStyle, other.mentionTextStyle, t),
      mentionTextColor: Color.lerp(mentionTextColor, other.mentionTextColor, t),
      mentionTextBackgroundColor: Color.lerp(mentionTextBackgroundColor, other.mentionTextBackgroundColor, t),
      mentionSelfTextStyle: TextStyle.lerp(mentionSelfTextStyle, other.mentionSelfTextStyle, t),
      mentionSelfTextColor: Color.lerp(mentionSelfTextColor, other.mentionSelfTextColor, t),
      mentionSelfTextBackgroundColor: Color.lerp(mentionSelfTextBackgroundColor, other.mentionSelfTextBackgroundColor, t),
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
    );
  }

  static CometChatMentionsStyle of(BuildContext context)=>CometChatMentionsStyle();

}