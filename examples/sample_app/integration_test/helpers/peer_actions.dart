import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dual_device_config.dart';

/// Performs actions as User B (the peer) via CometChat REST API.
///
/// This simulates the second device's actions from the primary test device,
/// eliminating the need for a second emulator for most scenarios.
///
/// For scenarios that REQUIRE a live second device (call accept, real-time
/// typing indicator display), use the companion app instead.
class PeerActions {
  static String get _baseUrl =>
      'https://${DualDeviceConfig.appId}.api-${DualDeviceConfig.region}.cometchat.io/v3';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apiKey': DualDeviceConfig.restApiKey,
        'appId': DualDeviceConfig.appId,
      };

  /// Send a text message from User B to User A.
  /// Returns the message ID on success.
  static Future<int> sendTextMessage(String text) async {
    final url = Uri.parse('$_baseUrl/messages');
    final body = jsonEncode({
      'receiver': DualDeviceConfig.userAUid,
      'receiverType': 'user',
      'category': 'message',
      'type': 'text',
      'data': {'text': text},
    });

    final response = await http.post(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
      body: body,
    );

    if (response.statusCode != 200) {
      throw StateError(
        'PeerActions.sendTextMessage failed: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send a text message from User B to a group.
  static Future<int> sendGroupTextMessage(
    String text, {
    String? groupId,
  }) async {
    final guid = groupId ?? DualDeviceConfig.testGroupGuid;
    final url = Uri.parse('$_baseUrl/messages');
    final body = jsonEncode({
      'receiver': guid,
      'receiverType': 'group',
      'category': 'message',
      'type': 'text',
      'data': {'text': text},
    });

    final response = await http.post(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
      body: body,
    );

    if (response.statusCode != 200) {
      throw StateError(
        'PeerActions.sendGroupTextMessage failed: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send multiple messages from User B to User A in sequence.
  /// Useful for testing pagination and scroll behavior.
  static Future<List<int>> sendMultipleMessages(
    int count, {
    String prefix = 'E2E msg',
    Duration delayBetween = const Duration(milliseconds: 200),
  }) async {
    final ids = <int>[];
    for (var i = 1; i <= count; i++) {
      final id = await sendTextMessage(
        '$prefix #$i - ${DateTime.now().toIso8601String()}',
      );
      ids.add(id);
      if (i < count) {
        await Future<void>.delayed(delayBetween);
      }
    }
    return ids;
  }

  /// Delete a specific message (as User B).
  static Future<void> deleteMessage(int messageId) async {
    final url = Uri.parse('$_baseUrl/messages/$messageId');

    final response = await http.delete(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
    );

    if (response.statusCode != 200) {
      throw StateError(
        'PeerActions.deleteMessage failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Edit a message (as User B).
  static Future<void> editMessage(int messageId, String newText) async {
    final url = Uri.parse('$_baseUrl/messages/$messageId');
    final body = jsonEncode({
      'data': {'text': newText},
    });

    final response = await http.put(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
      body: body,
    );

    if (response.statusCode != 200) {
      throw StateError(
        'PeerActions.editMessage failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Create a conversation by sending a message from B → A.
  /// Ensures a conversation exists in User A's list.
  static Future<void> ensureConversationExists() async {
    await sendTextMessage(
      'E2E seed message ${DateTime.now().toIso8601String()}',
    );
  }

  /// Delete the conversation between User A and User B (cleanup).
  static Future<void> deleteConversation() async {
    final url = Uri.parse(
      '$_baseUrl/users/${DualDeviceConfig.userAUid}/conversation/user_${DualDeviceConfig.userBUid}',
    );

    try {
      await http.delete(
        url,
        headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userAUid},
      );
    } catch (_) {
      // Best-effort cleanup
    }
  }

  /// Mark messages as read (as User B) — useful for receipt tests.
  static Future<void> markAsRead(int messageId) async {
    final url = Uri.parse('$_baseUrl/messages/$messageId/read');

    final response = await http.put(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
    );

    if (response.statusCode != 200) {
      // Non-fatal — some SDK versions handle this differently
    }
  }

  /// Mark messages as delivered (as User B) — for delivery receipt tests.
  static Future<void> markAsDelivered(int messageId) async {
    final url = Uri.parse('$_baseUrl/messages/$messageId/delivered');

    final response = await http.put(
      url,
      headers: {..._headers, 'onBehalfOf': DualDeviceConfig.userBUid},
    );

    if (response.statusCode != 200) {
      // Non-fatal
    }
  }
}
