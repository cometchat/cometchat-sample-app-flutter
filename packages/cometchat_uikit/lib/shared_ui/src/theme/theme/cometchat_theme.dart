import 'package:flutter/material.dart';

class CometChatTheme {
  CometChatTheme._();

  static Iterable<ThemeExtension<dynamic>>? mergeThemeExtensions(BuildContext context, List<ThemeExtension<dynamic>> newExtensions) {
    return [
      ...Theme.of(context).extensions.values,
      ...newExtensions,
    ];
  }
}
