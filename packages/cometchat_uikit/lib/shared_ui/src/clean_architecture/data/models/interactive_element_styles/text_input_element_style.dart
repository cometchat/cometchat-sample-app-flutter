import 'package:flutter/material.dart';
import '../base_styles.dart';

class TextInputElementStyle extends BaseStyles {
  TextInputElementStyle({
    this.textStyle,
    this.hintTextStyle,
    this.labelStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  TextStyle? textStyle;
  TextStyle? labelStyle;
  TextStyle? hintTextStyle;

  TextInputElementStyle merge(TextInputElementStyle mergeWith) {
    return TextInputElementStyle(
      textStyle: textStyle ?? mergeWith.textStyle,
      hintTextStyle: hintTextStyle ?? mergeWith.hintTextStyle,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
      labelStyle: labelStyle ?? mergeWith.labelStyle,
    );
  }
}
