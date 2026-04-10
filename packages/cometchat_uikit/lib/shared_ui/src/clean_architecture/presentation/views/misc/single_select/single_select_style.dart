import '../../../../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

/// A class representing styling options for a single select element.
///
/// The [SingleSelectStyle] class defines various style properties that can be used to customize the appearance of a single select element.
class SingleSelectStyle extends BaseStyles {
  SingleSelectStyle({
    this.labelStyle,
    this.selectedOptionTextStyle,
    this.optionTextStyle,
    this.selectedOptionBackground,
    this.optionBackground,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  /// The text style for the label in the single select element.
  TextStyle? labelStyle;

  /// The text style for the selected option in the single select element.
  TextStyle? selectedOptionTextStyle;

  /// The text style for the non-selected options in the single select element.
  TextStyle? optionTextStyle;

  /// The background color for the selected option in the single select element.
  Color? selectedOptionBackground;

  /// The background color for the non-selected options in the single select element.
  Color? optionBackground;

  SingleSelectStyle merge(SingleSelectStyle mergeWith) {
    return SingleSelectStyle(
      labelStyle: labelStyle ?? mergeWith.labelStyle,
      selectedOptionTextStyle:
          selectedOptionTextStyle ?? mergeWith.selectedOptionTextStyle,
      optionTextStyle: optionTextStyle ?? mergeWith.optionTextStyle,
      selectedOptionBackground:
          selectedOptionBackground ?? mergeWith.selectedOptionBackground,
      optionBackground: optionBackground ?? mergeWith.optionBackground,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
    );
  }
}
