import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  static show(String text, BuildContext context,
      {SnackBarConfiguration? snackBarConfiguration}) {
    SnackBar snackBar = SnackBar(
      backgroundColor: snackBarConfiguration?.backgroundColor,
      elevation: snackBarConfiguration?.elevation,
      margin: snackBarConfiguration?.margin,
      padding: snackBarConfiguration?.padding,
      duration: snackBarConfiguration?.duration ?? const Duration(seconds: 2),
      content: Center(
        child: Text(
          text,
          style: snackBarConfiguration?.contentTextStyle,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
