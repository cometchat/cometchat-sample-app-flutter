import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';
import 'package:sample_app_push_notifications/utils/text_constants.dart';

class AppCredentials {
  static String _appId = "YOUR_APP_ID";
  static String _authKey = "YOUR_AUTH_KEY";
  static String _region = "REGION";
  static String _fcmProviderId = "FCM_PROVIDER_ID";
  static String _apnProviderId = "APN_PROVIDER_ID";

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
  static String get fcmProviderId {
    if(_fcmProviderId.isEmpty){
      _fcmProviderId = SharedPreferencesClass.getString(TextConstants.fcmProviderId);
    }
    return _fcmProviderId;
  }
  static String get apnProviderId {
    if(_apnProviderId.isEmpty){
      _apnProviderId = SharedPreferencesClass.getString(TextConstants.apnsProviderId);
    }
    return _apnProviderId;
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

  static Future<void> setFcmProviderId(String value) async{
    await SharedPreferencesClass.setString(TextConstants.fcmProviderId, value);
    _fcmProviderId = value;
  }

  static Future<void> setApnProviderId(String value) async{
    await SharedPreferencesClass.setString(TextConstants.apnsProviderId, value);
    _apnProviderId = value;
  }
}