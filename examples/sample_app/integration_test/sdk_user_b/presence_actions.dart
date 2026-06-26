import 'sdk_user_b.dart';

/// User B presence (online/offline) actions.
///
/// Online/offline is controlled by creating or deleting auth tokens:
///   - Creating a token → user appears "online" → triggers onUserOnline
///   - Deleting tokens → user appears "offline" → triggers onUserOffline
///
/// These trigger real WebSocket events on User A's SDK listeners.
class UserBPresence {
  UserBPresence._();

  /// Make User B appear online.
  /// This creates an auth token, which the CometChat server treats as
  /// an active session → fires onUserOnline to all subscribers.
  static Future<void> goOnline() async {
    await SdkUserB.login();
  }

  /// Make User B appear offline.
  /// This deletes all auth tokens for User B → the server fires
  /// onUserOffline to all subscribers.
  static Future<void> goOffline() async {
    await SdkUserB.logout();
  }

  /// Toggle online/offline rapidly (for stress/edge case tests).
  /// Returns after all transitions complete.
  static Future<void> togglePresence({
    int times = 3,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < times; i++) {
      await goOnline();
      await Future<void>.delayed(interval);
      await goOffline();
      await Future<void>.delayed(interval);
    }
  }
}
