import 'dart:io';

class DemoMetaInfoConstants {
  static String name = "master_app";
  static String type = "sample-app";
  static String version = "5.1.1";
  static String bundle = Platform.isAndroid
      ? "com.cometchat.sampleapp.flutter.android"
      : "com.cometchat.sampleapp.flutter.ios";
  static String platform = "Flutter";
}
