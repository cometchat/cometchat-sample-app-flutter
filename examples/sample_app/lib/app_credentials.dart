import 'package:shared_preferences/shared_preferences.dart';

/// CometChat App Credentials.
///
/// By default these are empty — the app shows a credentials screen on
/// first launch. Once the user enters values they are persisted to
/// SharedPreferences and reused on subsequent launches.
///
/// To skip the credentials screen, hardcode your values below.
class AppCredentials {
  static String appId = '';
  static String region = '';
  static String authKey = '';

  /// Whether valid credentials are available.
  static bool get hasValidCredentials =>
      appId.isNotEmpty && region.isNotEmpty && authKey.isNotEmpty;

  // ── SharedPreferences keys ──
  static const String _keyAppId = 'cc_app_id';
  static const String _keyRegion = 'cc_region';
  static const String _keyAuthKey = 'cc_auth_key';

  /// Load saved credentials from SharedPreferences.
  /// Returns true if credentials were found and loaded.
  static Future<bool> loadSavedCredentials() async {
    if (hasValidCredentials) return true; // already hardcoded
    final prefs = await SharedPreferences.getInstance();
    final savedAppId = prefs.getString(_keyAppId) ?? '';
    final savedRegion = prefs.getString(_keyRegion) ?? '';
    final savedAuthKey = prefs.getString(_keyAuthKey) ?? '';
    if (savedAppId.isNotEmpty &&
        savedRegion.isNotEmpty &&
        savedAuthKey.isNotEmpty) {
      appId = savedAppId;
      region = savedRegion;
      authKey = savedAuthKey;
      return true;
    }
    return false;
  }

  /// Save credentials to SharedPreferences.
  static Future<void> saveCredentials(
      String newAppId, String newRegion, String newAuthKey) async {
    appId = newAppId;
    region = newRegion;
    authKey = newAuthKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppId, newAppId);
    await prefs.setString(_keyRegion, newRegion);
    await prefs.setString(_keyAuthKey, newAuthKey);
  }

  /// Clear saved credentials.
  static Future<void> clearCredentials() async {
    appId = '';
    region = '';
    authKey = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppId);
    await prefs.remove(_keyRegion);
    await prefs.remove(_keyAuthKey);
  }
}
