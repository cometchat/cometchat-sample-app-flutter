import 'package:shared_preferences/shared_preferences.dart';

class AppCredentials {
  static const String _defaultAppId = '';
  static const String _defaultRegion = '';
  static const String _defaultAuthKey = '';

  static String _appId = _defaultAppId;
  static String _region = _defaultRegion;
  static String _authKey = _defaultAuthKey;

  static String get appId => _appId;
  static String get region => _region;
  static String get authKey => _authKey;

  static bool get hasValidCredentials =>
      _appId.isNotEmpty && _region.isNotEmpty && _authKey.isNotEmpty;

  static Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _appId = prefs.getString('cc_app_id') ?? _defaultAppId;
    _region = prefs.getString('cc_region') ?? _defaultRegion;
    _authKey = prefs.getString('cc_auth_key') ?? _defaultAuthKey;
  }
}
