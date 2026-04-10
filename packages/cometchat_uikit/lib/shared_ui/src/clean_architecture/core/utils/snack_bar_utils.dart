import 'package:flutter/material.dart';
import '../../../../cometchat_uikit_shared.dart' show SnackBarConfiguration;

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
