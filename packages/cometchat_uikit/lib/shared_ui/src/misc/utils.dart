import 'package:flutter/material.dart';

import '../../l10n/translations.dart';

class Utils {
  static const internetNotAvailable = "ERROR_INTERNET_UNAVAILABLE";

  static String getErrorTranslatedText(BuildContext context, String errorCode) {
    if (errorCode == internetNotAvailable) {
      return Translations.of(context).errorInternetUnavailable;
    } else {}

    return Translations.of(context).somethingWentWrongError;
  }

  static bool isValidString(String? str) {
    if (str == null || str.trim() == '') return false;
    return true;
  }

  static bool isValidMap(Map? map) {
    if (map == null || map.isEmpty) return false;
    return true;
  }

  static bool isValidInteger(int? integer) {
    return integer != null && integer > 0;
  }
}
