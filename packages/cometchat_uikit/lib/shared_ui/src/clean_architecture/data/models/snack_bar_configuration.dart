import 'package:flutter/material.dart';

class SnackBarConfiguration {
  SnackBarConfiguration(
      {this.backgroundColor,
      this.elevation,
      this.margin,
      this.padding,
      this.duration,
      this.contentTextStyle});

  ///[backgroundColor] set background color for the snackBar
  final Color? backgroundColor;

  ///[elevation] sets the elevation for snackBar
  final double? elevation;

  ///[margin] sets the margin for snackBar
  final EdgeInsetsGeometry? margin;

  ///[padding] sets the padding for snackBar
  final EdgeInsetsGeometry? padding;

  ///[duration] set the duration for which snackBar will be visible
  final Duration? duration;

  final TextStyle? contentTextStyle;
}
