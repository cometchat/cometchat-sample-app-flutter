import 'package:flutter/services.dart';
import 'package:sample_app_push_notifications/app_credentials.dart';

const voipPlatformChannel = MethodChannel("com.cometchat.sampleapp");

Future<void> saveAppSettingsToNative() async {
  try {
    await voipPlatformChannel.invokeMethod("saveAppSettings", {
      "appID": AppCredentials.appId,
      "region": AppCredentials.region,
    });
  } on PlatformException catch (e) {
    print("Failed to save settings: ${e.message}");
  }
}
