import 'dart:convert';
import 'package:http/http.dart' as http;

import 'sdk_user_b.dart';
import '../config/test_credentials.dart';

/// User B block/unblock actions via REST API.
///
/// Triggers real WebSocket events:
///   - blockUserA → ccUserBlocked on A's SDK listener
///   - unblockUserA → ccUserUnblocked on A's SDK listener
///
/// When B blocks A:
///   - A's message composer becomes disabled
///   - A sees a "blocked" banner
///   - A cannot see B's typing indicators or presence
class UserBBlock {
  UserBBlock._();

  /// User B blocks User A.
  ///
  /// Triggers: A's SDK fires ccUserBlocked → UI shows blocked state.
  static Future<void> blockUserA() async {
    await SdkUserB.post(
      '/users/${TestCredentials.userBUid}/blockedusers',
      body: {
        'blockedUids': [TestCredentials.userAUid],
      },
    );
  }

  /// User B unblocks User A.
  ///
  /// Triggers: A's SDK fires ccUserUnblocked → UI recovers.
  static Future<void> unblockUserA() async {
    // CometChat DELETE /users/{uid}/blockedusers requires body with UIDs
    final url = Uri.parse(
      '${TestCredentials.restBaseUrl}/users/${TestCredentials.userBUid}/blockedusers',
    );
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apiKey': TestCredentials.restApiKey,
        'appId': TestCredentials.appId,
        'onBehalfOf': TestCredentials.userBUid,
      },
      body: jsonEncode({
        'blockedUids': [TestCredentials.userAUid],
      }),
    );
    if (response.statusCode != 200) {
      throw StateError(
        '[SdkUserB] unblockUserA failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// User A blocks User B (using REST on behalf of A).
  /// This is for testing "A blocks B" scenarios without UI interaction.
  static Future<void> userABlocksB() async {
    await SdkUserB.post(
      '/users/${TestCredentials.userAUid}/blockedusers',
      asUserA: true,
      body: {
        'blockedUids': [TestCredentials.userBUid],
      },
    );
  }

  /// User A unblocks User B (cleanup).
  static Future<void> userAUnblocksB() async {
    await SdkUserB.delete(
      '/users/${TestCredentials.userAUid}/blockedusers',
      asUserA: true,
    );
  }
}
