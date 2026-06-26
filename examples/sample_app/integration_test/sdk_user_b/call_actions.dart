import 'sdk_user_b.dart';
import '../config/test_credentials.dart';

/// User B call actions via REST API.
///
/// Triggers real WebSocket events:
///   - initiateCall → onIncomingCallReceived on A's SDK
///   - rejectCall → onOutgoingCallRejected on A's SDK
///   - cancelCall → onIncomingCallCancelled on A's SDK
///
/// Note: Actual WebRTC media connections cannot be tested via REST.
/// These tests verify the call signaling flow (initiate/reject/cancel)
/// and the resulting UI states (incoming call screen, call log messages).
class UserBCalls {
  UserBCalls._();

  /// User B initiates a voice call to User A.
  /// Returns the call session ID.
  ///
  /// Triggers: onIncomingCallReceived on A's SDK → incoming call UI.
  static Future<String> initiateVoiceCall() async {
    final data = await SdkUserB.post(
      '/calls',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'type': 'audio',
      },
    );

    return data['data']['sessionId'] as String;
  }

  /// User B initiates a video call to User A.
  /// Returns the call session ID.
  ///
  /// Triggers: onIncomingCallReceived on A's SDK → incoming video call UI.
  static Future<String> initiateVideoCall() async {
    final data = await SdkUserB.post(
      '/calls',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'type': 'video',
      },
    );

    return data['data']['sessionId'] as String;
  }

  /// User B rejects an incoming call (that User A initiated).
  ///
  /// Triggers: onOutgoingCallRejected on A's SDK → A returns to chat.
  static Future<void> rejectCall(String sessionId) async {
    await SdkUserB.post(
      '/calls/$sessionId/status',
      body: {'status': 'rejected'},
    );
  }

  /// User B cancels an outgoing call (that B initiated).
  ///
  /// Triggers: onIncomingCallCancelled on A's SDK → A's incoming UI disappears.
  static Future<void> cancelCall(String sessionId) async {
    await SdkUserB.post(
      '/calls/$sessionId/status',
      body: {'status': 'cancelled'},
    );
  }

  /// User B accepts a call (that User A initiated).
  ///
  /// Triggers: onOutgoingCallAccepted on A's SDK.
  /// Note: No actual WebRTC connection is established in tests.
  static Future<void> acceptCall(String sessionId) async {
    await SdkUserB.post(
      '/calls/$sessionId/status',
      body: {'status': 'accepted'},
    );
  }
}
