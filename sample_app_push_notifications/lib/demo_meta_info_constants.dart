import 'dart:io';

class DemoMetaInfoConstants {
  static String name = "master_app";
  static String type = "sample-app";
  static String version = "5.0.0-beta.2";
  static String bundle = Platform.isAndroid
      ? "com.cometchat.sampleapp.flutter.android"
      : "com.cometchat.sampleapp.flutter.ios";
  static String platform = "Flutter";
}
