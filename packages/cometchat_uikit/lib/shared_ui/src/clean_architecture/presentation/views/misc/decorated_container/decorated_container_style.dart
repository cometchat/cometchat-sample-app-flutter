import 'package:flutter/material.dart';


class DecoratedContainerStyle {
  const DecoratedContainerStyle({
    this.titleStyle,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.closeIconColor
  });

  ///[titleStyle] title text style
  final TextStyle? titleStyle;

  ///[backgroundColor] changes background color of the widget
  final Color? backgroundColor;

  ///[border] changes border of widget
  final BoxBorder? border;

  ///[borderRadius] changes border radius of the widget
  final BorderRadiusGeometry? borderRadius;

  ///[closeIconColor] is a Color parameter which takes the color of the close icon.
  final Color? closeIconColor;

  /// Merges current `AIConversationSummaryStyle` with [other]
  DecoratedContainerStyle merge(DecoratedContainerStyle? other) {
    if (other == null) return this;
    return copyWith(
      titleStyle: other.titleStyle,
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      closeIconColor: other.closeIconColor,
    );
  }

  DecoratedContainerStyle copyWith(
  {
    TextStyle? titleStyle,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? closeIconColor
}
      ) {
   return DecoratedContainerStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      closeIconColor: closeIconColor ?? this.closeIconColor,
    );
  }
}
