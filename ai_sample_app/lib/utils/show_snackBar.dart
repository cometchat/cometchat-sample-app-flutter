import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

void showSnackBar(context, String message, CometChatTypography typography,
    CometChatColorPalette colorPalette) {
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
