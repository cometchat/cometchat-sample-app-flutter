import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class provides functionality to interact with shared preferences to store and retrieve string values using specific keys.

class SharedPreferencesClass {
  static SharedPreferences? preferences;

  // Initializing shared preferences
  static void init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // This method saves a string value to shared preferences with a specific key.
  static Future<void> setString(String key, String value) async {
    await preferences?.setString(key, value);
    if (kDebugMode) {
      debugPrint("Saved string for key : $key and value : $value");
    }
  }

  // This method retrieves a string value from shared preferences using a specific key; if no value is found, an empty string is returned.
  static String getString(String key) {
    if (kDebugMode) {
      debugPrint("Returning string for key : $key");
    }
    return preferences?.getString(key) ?? "";
  }
}