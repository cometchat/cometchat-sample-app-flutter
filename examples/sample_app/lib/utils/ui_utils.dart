import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

void removeFocus(BuildContext context, FocusNode focusNode) {
  if (focusNode.hasFocus) {
    focusNode.unfocus();
  } else {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

void showErrorSnackBar(BuildContext context, String message,
    CometChatTypography typography, CometChatColorPalette colorPalette) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: colorPalette.white,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
      ),
      backgroundColor: colorPalette.error,
    ),
  );
}
