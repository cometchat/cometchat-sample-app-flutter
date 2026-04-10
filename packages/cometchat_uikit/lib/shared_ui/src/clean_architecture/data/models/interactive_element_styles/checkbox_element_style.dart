import 'package:flutter/material.dart';
import '../base_styles.dart';

class CheckBoxElementStyle extends BaseStyles {
  CheckBoxElementStyle({
    this.labelStyle,
    this.activeColor,
    this.checkColor,
    this.optionTextStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  final TextStyle? labelStyle;
  final Color? activeColor;
  final Color? checkColor;
  final TextStyle? optionTextStyle;

  CheckBoxElementStyle merge(CheckBoxElementStyle mergeWith) {
    return CheckBoxElementStyle(
      labelStyle: labelStyle ?? mergeWith.labelStyle,
      activeColor: activeColor ?? mergeWith.activeColor,
      checkColor: checkColor ?? mergeWith.checkColor,
      optionTextStyle: optionTextStyle ?? mergeWith.optionTextStyle,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
    );
  }
}
