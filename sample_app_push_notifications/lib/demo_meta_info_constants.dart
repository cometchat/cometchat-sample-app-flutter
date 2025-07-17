import 'dart:io';

class DemoMetaInfoConstants {
  static String name = "sample_app_push_notifications";
  static String type = "sample-app";
  static String version = "5.0.4";
  static String bundle = Platform.isAndroid
      ? "com.cometchat.sampleapp.flutter.android"
      : "com.cometchat.sampleapp.flutter.ios";
  static String platform = "Flutter";
}
