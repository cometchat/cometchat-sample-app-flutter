import 'package:flutter/material.dart';

import '../../../../cometchat_uikit_shared.dart';

/// Styling options for the form bubble widget.
class FormBubbleStyle extends BaseStyles {
  /// Creates a new instance of [FormBubbleStyle].
  ///
  /// All parameters are optional.
  const FormBubbleStyle({
    this.dropDownStyle,
    this.radioButtonStyle,
    this.checkBoxStyle,
    this.textInputStyle,
    this.labelStyle,
    this.buttonStyle,
    this.submitButtonStyle,
    this.titleStyle,
    this.goalCompletionTextStyle,
    this.singleSelectStyle,
    super.width,
    super.height,
    super.background,
    super.gradient,
    super.border,
    super.borderRadius,
  });

  /// Style options for the radio button element within the form bubble.
  final RadioButtonElementStyle? radioButtonStyle;

  /// Style options for the drop-down element within the form bubble.
  final DropDownElementStyle? dropDownStyle;

  /// Style options for the check box element within the form bubble.
  final CheckBoxElementStyle? checkBoxStyle;

  /// Style options for the text input element within the form bubble.
  final TextInputElementStyle? textInputStyle;

  /// Style options for the label text within the form bubble.
  final TextStyle? labelStyle;

  /// Style options for the button element within the form bubble.
  final ButtonElementStyle? buttonStyle;

  /// Style options for the submit button element within the form bubble.
  final ButtonElementStyle? submitButtonStyle;

  /// Style options for the title text within the form bubble.
  final TextStyle? titleStyle;

  /// Style options for the goal completion text within the form bubble.
  final TextStyle? goalCompletionTextStyle;

  /// Style options for the single-select element within the form bubble.
  final SingleSelectStyle? singleSelectStyle;

  FormBubbleStyle merge(FormBubbleStyle mergeWith) {
    return FormBubbleStyle(
      radioButtonStyle: radioButtonStyle ?? mergeWith.radioButtonStyle,
      dropDownStyle: dropDownStyle ?? mergeWith.dropDownStyle,
      checkBoxStyle: checkBoxStyle ?? mergeWith.checkBoxStyle,
      textInputStyle: textInputStyle ?? mergeWith.textInputStyle,
      labelStyle: labelStyle ?? mergeWith.labelStyle,
      buttonStyle: buttonStyle ?? mergeWith.buttonStyle,
      submitButtonStyle: submitButtonStyle ?? mergeWith.submitButtonStyle,
      goalCompletionTextStyle:
          goalCompletionTextStyle ?? mergeWith.goalCompletionTextStyle,
      titleStyle: titleStyle ?? mergeWith.titleStyle,
      singleSelectStyle: singleSelectStyle ?? mergeWith.singleSelectStyle,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
    );
  }
}
