import 'package:flutter/material.dart';

/// Style configuration for [CometChatLinkDialog].
class CometChatLinkDialogStyle extends ThemeExtension<CometChatLinkDialogStyle> {
  const CometChatLinkDialogStyle({
    this.backgroundColor,
    this.shadow,
    this.border,
    this.borderRadius,
    this.titleTextColor,
    this.titleTextStyle,
    this.labelTextColor,
    this.labelTextStyle,
    this.inputTextColor,
    this.inputTextStyle,
    this.hintTextColor,
    this.hintTextStyle,
    this.inputBackgroundColor,
    this.cancelButtonBackground,
    this.cancelButtonTextColor,
    this.cancelButtonTextStyle,
    this.doneButtonBackground,
    this.doneButtonDisabledBackground,
    this.doneButtonTextColor,
    this.doneButtonDisabledTextColor,
    this.doneButtonTextStyle,
  });

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Shadow/barrier color behind the dialog.
  final Color? shadow;

  /// Border of the dialog.
  final BorderSide? border;

  /// Border radius of the dialog.
  final BorderRadius? borderRadius;

  /// Color of the title text.
  final Color? titleTextColor;

  /// Style of the title text.
  final TextStyle? titleTextStyle;

  /// Color of the label text.
  final Color? labelTextColor;

  /// Style of the label text.
  final TextStyle? labelTextStyle;

  /// Color of the input text.
  final Color? inputTextColor;

  /// Style of the input text.
  final TextStyle? inputTextStyle;

  /// Color of the hint text.
  final Color? hintTextColor;

  /// Style of the hint text.
  final TextStyle? hintTextStyle;

  /// Background color of the input fields.
  final Color? inputBackgroundColor;

  /// Background color of the cancel button.
  final Color? cancelButtonBackground;

  /// Text color of the cancel button.
  final Color? cancelButtonTextColor;

  /// Text style of the cancel button.
  final TextStyle? cancelButtonTextStyle;

  /// Background color of the done button.
  final Color? doneButtonBackground;

  /// Background color of the done button when disabled.
  final Color? doneButtonDisabledBackground;

  /// Text color of the done button.
  final Color? doneButtonTextColor;

  /// Text color of the done button when disabled.
  final Color? doneButtonDisabledTextColor;

  /// Text style of the done button.
  final TextStyle? doneButtonTextStyle;

  /// Returns a default [CometChatLinkDialogStyle] instance.
  static CometChatLinkDialogStyle of(BuildContext context) =>
      const CometChatLinkDialogStyle();

  @override
  CometChatLinkDialogStyle copyWith({
    Color? backgroundColor,
    Color? shadow,
    BorderSide? border,
    BorderRadius? borderRadius,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    Color? labelTextColor,
    TextStyle? labelTextStyle,
    Color? inputTextColor,
    TextStyle? inputTextStyle,
    Color? hintTextColor,
    TextStyle? hintTextStyle,
    Color? inputBackgroundColor,
    Color? cancelButtonBackground,
    Color? cancelButtonTextColor,
    TextStyle? cancelButtonTextStyle,
    Color? doneButtonBackground,
    Color? doneButtonDisabledBackground,
    Color? doneButtonTextColor,
    Color? doneButtonDisabledTextColor,
    TextStyle? doneButtonTextStyle,
  }) {
    return CometChatLinkDialogStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadow: shadow ?? this.shadow,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      labelTextColor: labelTextColor ?? this.labelTextColor,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      cancelButtonBackground: cancelButtonBackground ?? this.cancelButtonBackground,
      cancelButtonTextColor: cancelButtonTextColor ?? this.cancelButtonTextColor,
      cancelButtonTextStyle: cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      doneButtonBackground: doneButtonBackground ?? this.doneButtonBackground,
      doneButtonDisabledBackground: doneButtonDisabledBackground ?? this.doneButtonDisabledBackground,
      doneButtonTextColor: doneButtonTextColor ?? this.doneButtonTextColor,
      doneButtonDisabledTextColor: doneButtonDisabledTextColor ?? this.doneButtonDisabledTextColor,
      doneButtonTextStyle: doneButtonTextStyle ?? this.doneButtonTextStyle,
    );
  }

  /// Merges this style with another [CometChatLinkDialogStyle].
  CometChatLinkDialogStyle merge(CometChatLinkDialogStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      shadow: style.shadow,
      border: style.border,
      borderRadius: style.borderRadius,
      titleTextColor: style.titleTextColor,
      titleTextStyle: style.titleTextStyle,
      labelTextColor: style.labelTextColor,
      labelTextStyle: style.labelTextStyle,
      inputTextColor: style.inputTextColor,
      inputTextStyle: style.inputTextStyle,
      hintTextColor: style.hintTextColor,
      hintTextStyle: style.hintTextStyle,
      inputBackgroundColor: style.inputBackgroundColor,
      cancelButtonBackground: style.cancelButtonBackground,
      cancelButtonTextColor: style.cancelButtonTextColor,
      cancelButtonTextStyle: style.cancelButtonTextStyle,
      doneButtonBackground: style.doneButtonBackground,
      doneButtonDisabledBackground: style.doneButtonDisabledBackground,
      doneButtonTextColor: style.doneButtonTextColor,
      doneButtonDisabledTextColor: style.doneButtonDisabledTextColor,
      doneButtonTextStyle: style.doneButtonTextStyle,
    );
  }

  @override
  CometChatLinkDialogStyle lerp(
      ThemeExtension<CometChatLinkDialogStyle>? other, double t) {
    if (other is! CometChatLinkDialogStyle) {
      return this;
    }
    return CometChatLinkDialogStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      shadow: Color.lerp(shadow, other.shadow, t),
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t),
      labelTextColor: Color.lerp(labelTextColor, other.labelTextColor, t),
      inputTextColor: Color.lerp(inputTextColor, other.inputTextColor, t),
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t),
      inputBackgroundColor: Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t),
      cancelButtonBackground: Color.lerp(cancelButtonBackground, other.cancelButtonBackground, t),
      cancelButtonTextColor: Color.lerp(cancelButtonTextColor, other.cancelButtonTextColor, t),
      doneButtonBackground: Color.lerp(doneButtonBackground, other.doneButtonBackground, t),
      doneButtonDisabledBackground: Color.lerp(doneButtonDisabledBackground, other.doneButtonDisabledBackground, t),
      doneButtonTextColor: Color.lerp(doneButtonTextColor, other.doneButtonTextColor, t),
      doneButtonDisabledTextColor: Color.lerp(doneButtonDisabledTextColor, other.doneButtonDisabledTextColor, t),
    );
  }
}
