import 'package:flutter/material.dart';
import '../base_styles.dart';

class RadioButtonElementStyle extends BaseStyles {
  RadioButtonElementStyle({
    this.activeColor,
    this.labelStyle,
    this.optionTextStyle,
    this.radioColor,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  TextStyle? optionTextStyle;
  final TextStyle? labelStyle;
  final Color? activeColor;
  final Color? radioColor;

  RadioButtonElementStyle merge(RadioButtonElementStyle mergeWith) {
    return RadioButtonElementStyle(
      optionTextStyle: optionTextStyle ?? mergeWith.optionTextStyle,
      labelStyle: labelStyle ?? mergeWith.labelStyle,
      activeColor: activeColor ?? mergeWith.activeColor,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
      radioColor: radioColor ?? mergeWith.radioColor,
    );
  }
}
