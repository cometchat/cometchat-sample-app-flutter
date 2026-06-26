import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/test_credentials.dart';

/// Test cleanup utilities.
///
/// Called in setUp/tearDown to ensure test isolation:
///   - Delete conversations created during tests
///   - Unblock users
///   - Remove test messages
///
/// All operations are best-effort (don't fail the test if cleanup fails).
class CleanupHelper {
  CleanupHelper._();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apiKey': TestCredentials.restApiKey,
        'appId': TestCredentials.appId,
      };

  /// Delete the conversation between User A and User B.
  /// Call this in setUp to start with a clean slate.
  static Future<void> deleteConversation() async {
    try {
      final url = Uri.parse(
        '${TestCredentials.restBaseUrl}/users/${TestCredentials.userAUid}'
        '/conversation/user_${TestCredentials.userBUid}',
      );
      await http.delete(
        url,
        headers: {..._headers, 'onBehalfOf': TestCredentials.userAUid},
      );
    } catch (e) {
      debugPrint('[Cleanup] deleteConversation: $e');
    }
  }

  /// Unblock User B from User A's block list.
  /// Ensures the block state doesn't carry over between tests.
  static Future<void> unblockAll() async {
    try {
      // A unblocks B
      final url = Uri.parse(
        '${TestCredentials.restBaseUrl}/users/blockedusers',
      );
      await http.delete(
        url,
        headers: {..._headers, 'onBehalfOf': TestCredentials.userAUid},
        body: jsonEncode({
          'blockedUids': [TestCredentials.userBUid],
        }),
      );
    } catch (e) {
      debugPrint('[Cleanup] unblockAll (A→B): $e');
    }

    try {
      // B unblocks A
      final url = Uri.parse(
        '${TestCredentials.restBaseUrl}/users/blockedusers',
      );
      await http.delete(
        url,
        headers: {..._headers, 'onBehalfOf': TestCredentials.userBUid},
        body: jsonEncode({
          'blockedUids': [TestCredentials.userAUid],
        }),
      );
    } catch (e) {
      debugPrint('[Cleanup] unblockAll (B→A): $e');
    }
  }

  /// Seed a conversation (send a message from B→A) so the Chats list
  /// has User B's conversation at the top (most recent message).
  /// Returns the message ID.
  static Future<int?> seedConversation({String? text}) async {
    try {
      final url = Uri.parse('${TestCredentials.restBaseUrl}/messages');
      final response = await http.post(
        url,
        headers: {..._headers, 'onBehalfOf': TestCredentials.userBUid},
        body: jsonEncode({
          'receiver': TestCredentials.userAUid,
          'receiverType': 'user',
          'category': 'message',
          'type': 'text',
          'data': {
            'text':
                text ?? 'Seed message ${DateTime.now().millisecondsSinceEpoch}',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final id = data['data']['id'];
        return id is int ? id : int.parse(id.toString());
      }
    } catch (e) {
      debugPrint('[Cleanup] seedConversation: $e');
    }
    return null;
  }

  /// Full cleanup: unblock, delete conversation.
  /// Use in setUp for maximum test isolation.
  static Future<void> fullReset() async {
    await unblockAll();
    await deleteConversation();
    // Small delay for server to process
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
