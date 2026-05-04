import 'package:flutter/material.dart';

import '../../../cometchat_calls_uikit.dart';
import '../../../cometchat_chat_uikit.dart';

/// Launches [CometChatOngoingCall] in a completely isolated widget tree
/// (its own [MaterialApp] inside an [OverlayEntry]).
///
/// This decouples the call screen from the host app's navigation stack:
/// - Own [Navigator] — no push/pop on the app's routes
/// - Own [BuildContext] — no dependency on the app's widget tree
/// - Own theme & localization scope
///
/// Usage:
/// ```dart
/// // Show the call screen
/// CallScreenOverlay.show(
///   sessionId: 'abc123',
///   sessionSettingsBuilder: SessionSettingsBuilder()..setLayout(LayoutType.tile),
/// );
///
/// // Dismiss when the call ends
/// CallScreenOverlay.dismiss();
/// ```
class CallScreenOverlay {
  CallScreenOverlay._();

  static OverlayEntry? _entry;

  /// Whether the overlay is currently showing.
  static bool get isShowing => _entry != null;

  /// Show the ongoing call screen in an isolated overlay.
  ///
  /// If an overlay is already showing, it is dismissed first.
  static void show({
    required String sessionId,
    required SessionSettingsBuilder sessionSettingsBuilder,
    CallWorkFlow? callWorkFlow,
    OnError? onError,
  }) {
    dismiss(); // clear any existing

    _entry = OverlayEntry(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        localizationsDelegates: Translations.localizationsDelegates,
        home: CometChatOngoingCall(
          sessionSettingsBuilder: sessionSettingsBuilder,
          sessionId: sessionId,
          callWorkFlow: callWorkFlow ?? CallWorkFlow.defaultCalling,
          onError: onError,
        ),
      ),
    );

    final overlay =
        CallNavigationContext.navigatorKey.currentState?.overlay;
    if (overlay != null && _entry != null) {
      overlay.insert(_entry!);
    }
  }

  /// Dismiss the call screen overlay.
  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}
