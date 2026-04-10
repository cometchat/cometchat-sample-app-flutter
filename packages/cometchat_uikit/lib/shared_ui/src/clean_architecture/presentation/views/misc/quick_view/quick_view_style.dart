import '../../../../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

/// A class representing styling options for a Quick View widget.
///
/// The [QuickViewStyle] class defines various style properties that can be used to customize the appearance of a Quick View widget.
class QuickViewStyle extends BaseStyles {
  const QuickViewStyle({
    this.titleStyle,
    this.closeIconTint,
    this.leadingBarTint,
    this.leadingBarWidth,
    this.subtitleStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  /// The text style for the title in the Quick View.
  final TextStyle? titleStyle;

  /// The text style for the subtitle in the Quick View.
  final TextStyle? subtitleStyle;

  /// The color of the close icon in the Quick View.
  final Color? closeIconTint;

  /// The width of the leading bar in the Quick View.
  final double? leadingBarWidth;

  /// The color of the leading bar in the Quick View.
  final Color? leadingBarTint;

  QuickViewStyle merge(QuickViewStyle mergeWith) {
    return QuickViewStyle(
      titleStyle: titleStyle ?? mergeWith.titleStyle,
      closeIconTint: closeIconTint ?? mergeWith.closeIconTint,
      subtitleStyle: subtitleStyle ?? mergeWith.subtitleStyle,
      leadingBarWidth: leadingBarWidth ?? mergeWith.leadingBarWidth,
      leadingBarTint: leadingBarTint ?? mergeWith.leadingBarTint,
      width: width ?? mergeWith.width,
      height: height ?? mergeWith.height,
      background: background ?? mergeWith.background,
      border: border ?? mergeWith.border,
      borderRadius: borderRadius ?? mergeWith.borderRadius,
      gradient: gradient ?? mergeWith.gradient,
    );
  }
}
