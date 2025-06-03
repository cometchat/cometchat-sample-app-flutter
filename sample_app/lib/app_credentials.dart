import 'package:sample_app/prefs/shared_preferences.dart';
import 'package:sample_app/utils/text_constants.dart';

class AppCredentials {
  static String _appId = "";
  static String _authKey = "";
  static String _region = "";

  // Getters
  static String get appId {
    if(_appId.isEmpty){
      _appId = SharedPreferencesClass.getString(TextConstants.appId);
    }
    return _appId;

  }
  static String get authKey {
    if(_authKey.isEmpty){
      _authKey = SharedPreferencesClass.getString(TextConstants.authKey);
    }
    return _authKey;

  }
  static String get region {
    if(_region.isEmpty){
      _region = SharedPreferencesClass.getString(TextConstants.region);
    }
    return _region;

  }


  // Setters
  static Future<void> setAppId(String value) async {
    await SharedPreferencesClass.setString(TextConstants.appId, value);
    _appId = value;
  }

  static Future<void> setAuthKey(String value) async {
    await SharedPreferencesClass.setString(TextConstants.authKey, value);
    _authKey = value;
  }

  static Future<void> setRegion(String value) async {
    await SharedPreferencesClass.setString(TextConstants.region, value);
    _region = value;
  }
}
