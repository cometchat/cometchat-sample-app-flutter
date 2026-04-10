import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class DateTimeElementStyle extends BaseStyles {
  DateTimeElementStyle({
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

  DateTimeElementStyle merge(DateTimeElementStyle mergeWith) {
    return DateTimeElementStyle(
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
