import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class DropDownElementStyle extends BaseStyles {
  DropDownElementStyle({
    this.optionTextStyle,
    this.labelStyle,
    this.hintTextStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  final TextStyle? labelStyle;
  final TextStyle? optionTextStyle;
  final TextStyle? hintTextStyle;

  DropDownElementStyle merge(DropDownElementStyle mergeWith) {
    return DropDownElementStyle(
      optionTextStyle: optionTextStyle ?? mergeWith.optionTextStyle,
      labelStyle: labelStyle ?? mergeWith.labelStyle,
      hintTextStyle: hintTextStyle ?? mergeWith.hintTextStyle,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
    );
  }
}
