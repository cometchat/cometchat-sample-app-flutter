import 'package:flutter/material.dart';

///[CometChatExceptionStyle] is a data class that has styling-related properties for exception view
class CometChatExceptionStyle extends ThemeExtension<CometChatExceptionStyle> {
  const CometChatExceptionStyle({
    this.exceptionBackgroundColor,
    this.exceptionTextStyle,
    this.exceptionIconTint,
  });

  ///[exceptionBackgroundColor] provides background color to the exception view
  final Color? exceptionBackgroundColor;

  ///[exceptionTextStyle] provides text style to the exception view warning text
  final TextStyle? exceptionTextStyle;

  ///[exceptionIconTint] provides icon color for the exception view warning icon
  final Color? exceptionIconTint;

  static CometChatExceptionStyle of(BuildContext context) =>
      const CometChatExceptionStyle();

  @override
  CometChatExceptionStyle copyWith({
    Color? exceptionBackgroundColor,
    TextStyle? exceptionTextStyle,
    Color? exceptionIconTint,
  }) {
    return CometChatExceptionStyle(
      exceptionBackgroundColor:
          exceptionBackgroundColor ?? this.exceptionBackgroundColor,
      exceptionTextStyle: exceptionTextStyle ?? this.exceptionTextStyle,
      exceptionIconTint: exceptionIconTint ?? this.exceptionIconTint,
    );
  }

  CometChatExceptionStyle merge(CometChatExceptionStyle? style) {
    if (style == null) return this;
    return copyWith(
      exceptionBackgroundColor: style.exceptionBackgroundColor,
      exceptionTextStyle: style.exceptionTextStyle,
      exceptionIconTint: style.exceptionIconTint,
    );
  }

  @override
  CometChatExceptionStyle lerp(
    covariant CometChatExceptionStyle? other,
    double t,
  ) {
    return CometChatExceptionStyle(
      exceptionBackgroundColor: Color.lerp(
        exceptionBackgroundColor,
        other?.exceptionBackgroundColor,
        t,
      ),
      exceptionTextStyle: TextStyle.lerp(
        exceptionTextStyle,
        other?.exceptionTextStyle,
        t,
      ),
      exceptionIconTint: Color.lerp(
        exceptionIconTint,
        other?.exceptionIconTint,
        t,
      ),
    );
  }
}
