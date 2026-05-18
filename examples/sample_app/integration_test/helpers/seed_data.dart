import 'dart:convert';
import 'package:http/http.dart' as http;

/// Creates and cleans up test data via CometChat REST API.
///
/// Credentials are compiled in via --dart-define or use hardcoded defaults
/// for the internal test app. Platform.environment is NOT available on device.
class SeedData {
  static const String _appId = String.fromEnvironment(
    'COMETCHAT_APP_ID',
    defaultValue: '26580020f03ff346',
  );
  static const String _region = String.fromEnvironment(
    'COMETCHAT_REGION',
    defaultValue: 'in',
  );
  static const String _restApiKey = String.fromEnvironment(
    'COMETCHAT_REST_API_KEY',
    defaultValue: '783d3494689f233993c6c1916da3f888684df358',
  );
  static const String _testUserUid = String.fromEnvironment(
    'TEST_USER_UID',
    defaultValue: 'cometchat-uid-2',
  );
  static const String _testPeerUid = String.fromEnvironment(
    'TEST_PEER_UID',
    defaultValue: 'cometchat-uid-3',
  );

  static String get _baseUrl =>
      'https://$_appId.api-$_region.cometchat.io/v3';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apiKey': _restApiKey,
        'appId': _appId,
      };

  /// Send a text message from TEST_PEER_UID to TEST_USER_UID so that
  /// a conversation exists when the test starts.
  static Future<void> createTestConversation() async {
    final url = Uri.parse('$_baseUrl/messages');
    final body = jsonEncode({
      'receiver': _testUserUid,
      'receiverType': 'user',
      'category': 'message',
      'type': 'text',
      'data': {'text': 'E2E seed message ${DateTime.now().toIso8601String()}'},
    });

    final response = await http.post(
      url,
      headers: {
        ..._headers,
        'onBehalfOf': _testPeerUid,
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Failed to seed conversation: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Delete the conversation between test user and peer to clean up.
  /// Non-fatal if it fails (conversation may already be deleted by the test).
  static Future<void> cleanup() async {
    final url = Uri.parse(
      '$_baseUrl/users/$_testUserUid/conversation/user_$_testPeerUid',
    );

    // Best-effort cleanup — don't throw on failure.
    try {
      await http.delete(url, headers: {
        ..._headers,
        'onBehalfOf': _testUserUid,
      });
    } catch (_) {
      // Ignore cleanup failures.
    }
  }
}
