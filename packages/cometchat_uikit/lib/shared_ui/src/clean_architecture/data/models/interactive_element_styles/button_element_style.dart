import 'package:flutter/material.dart';
import '../base_styles.dart';

class ButtonElementStyle extends BaseStyles {
  ButtonElementStyle({
    this.buttonTextStyle,
    this.loadingIconTint,
    super.width,
    super.height,
    super.background,
    super.gradient,
    super.border,
    super.borderRadius,
  });

  ///[buttonTextStyle] is a object of [TextStyle] which is used to set the style for the button text in the meeting bubble
  TextStyle? buttonTextStyle;

  ///[loadingIconTint] sets color for  loading icon
  final Color? loadingIconTint;

  ButtonElementStyle merge(ButtonElementStyle mergeWith) {
    return ButtonElementStyle(
      buttonTextStyle: buttonTextStyle ?? mergeWith.buttonTextStyle,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
      loadingIconTint: loadingIconTint ?? mergeWith.loadingIconTint,
    );
  }
}
