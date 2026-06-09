import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web implementation of the CometChat Chat UIKit plugin.
///
/// This is a no-op plugin class — all native functionality (file picking,
/// audio recording, sound playback) is handled via web-safe alternatives
/// in the Dart layer using kIsWeb guards and conditional imports.
class CometchatChatUikitPluginWeb {
  static void registerWith(Registrar registrar) {
    // No-op: web functionality is handled in Dart via kIsWeb guards
  }
}
