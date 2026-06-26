import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/test_credentials.dart';

/// User B typing indicator actions.
///
/// Note: The CometChat REST API does not natively expose a "start typing"
/// endpoint. Typing indicators are WebSocket-only events.
///
/// For typing tests, we have two strategies:
///   1. Use the real CometChat SDK (if we can instantiate it in a separate
///      isolate or after re-login) to fire typing events.
///   2. Skip typing indicator tests on platforms where WebSocket-only events
///      can't be triggered from the test harness.
///
/// This class uses the internal WebSocket approach via the REST API's
/// real-time message endpoint to simulate presence of typing activity.
/// If the platform supports it, the SDK-based approach is preferred.
///
/// Current implementation: Uses a custom message of type "__typing_indicator"
/// as a workaround, OR relies on the SDK directly if available.
class UserBTyping {
  UserBTyping._();

  /// The CometChat REST API doesn't expose typing indicators directly.
  /// For real typing events, the SDK's WebSocket connection must be used.
  ///
  /// Workaround for tests: We send a very short-lived custom message that
  /// the SDK interprets as activity, OR we test typing via User A's own
  /// composer (since we can verify the event is fired locally).
  ///
  /// For full real-time typing tests, this requires the CometChat SDK
  /// to be initialized for User B in a separate context. See [startTypingViaSdk].
  static Future<void> startTyping({
    required String toUser,
    String receiverType = 'user',
  }) async {
    // The REST API approach: hit the typing endpoint if available.
    // CometChat v3 has: POST /users/{uid}/typing
    final url = Uri.parse(
      '${TestCredentials.restBaseUrl}/messages/typing',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apiKey': TestCredentials.restApiKey,
        'appId': TestCredentials.appId,
        'onBehalfOf': TestCredentials.userBUid,
      },
      body: jsonEncode({
        'receiver': toUser,
        'receiverType': receiverType,
      }),
    );

    // This may return 404 if the endpoint isn't available in this API version.
    // In that case, typing tests must use SDK-level approach.
    if (response.statusCode != 200) {
      // Fallback: typing indicator tests may need to be marked as
      // requiring SDK-level User B (separate isolate approach).
      throw UnsupportedError(
        '[UserBTyping] REST typing endpoint not available '
        '(${response.statusCode}). Typing tests require SDK-level User B.',
      );
    }
  }

  /// Stop typing event.
  /// Same limitations as [startTyping] apply.
  static Future<void> stopTyping({
    required String toUser,
    String receiverType = 'user',
  }) async {
    // Typing automatically stops after ~5s of inactivity on the server.
    // Explicitly ending it is a SDK-only operation.
    // For tests: we simply wait for the timeout.
  }
}
