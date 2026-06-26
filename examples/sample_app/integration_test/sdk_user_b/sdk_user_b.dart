import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/test_credentials.dart';

/// Core User B SDK client — a headless user that acts via REST API.
///
/// User B never renders UI. All actions are performed via CometChat REST API
/// with `onBehalfOf` header, which triggers real WebSocket events that User A's
/// app receives through the SDK's listener system.
///
/// This replaces the old dual-emulator approach. No second device needed.
///
/// Architecture:
///   - User A: Full Flutter app on device/emulator (driven by WidgetTester)
///   - User B: REST API calls from same test process (this class)
///   - Events flow: REST → CometChat server → WebSocket → User A's SDK → UI
class SdkUserB {
  SdkUserB._();

  static bool _isLoggedIn = false;

  /// Whether User B is currently "logged in" (has an active session).
  static bool get isLoggedIn => _isLoggedIn;

  // ─── HTTP helpers ──────────────────────────────────────────────────────────

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apiKey': TestCredentials.restApiKey,
        'appId': TestCredentials.appId,
      };

  static Map<String, String> get _headersAsUserB => {
        ..._headers,
        'onBehalfOf': TestCredentials.userBUid,
      };

  static Map<String, String> get _headersAsUserA => {
        ..._headers,
        'onBehalfOf': TestCredentials.userAUid,
      };

  // ─── Session management ────────────────────────────────────────────────────

  /// Create a session for User B. This makes User B "online" on the
  /// CometChat platform, triggering presence events for anyone watching.
  ///
  /// Under the hood this creates an auth token — the REST API operations
  /// with `onBehalfOf` work regardless, but this ensures User B appears
  /// as "online" for presence tests.
  static Future<void> login() async {
    final url = Uri.parse(
      '${TestCredentials.restBaseUrl}/users/${TestCredentials.userBUid}/auth_tokens',
    );

    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) {
      _isLoggedIn = true;
      debugPrint('[SdkUserB] Logged in (auth token created)');
    } else {
      debugPrint(
        '[SdkUserB] Login failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Delete User B's auth tokens, making them appear "offline".
  /// This triggers onUserOffline events for presence listeners.
  static Future<void> logout() async {
    final url = Uri.parse(
      '${TestCredentials.restBaseUrl}/users/${TestCredentials.userBUid}/auth_tokens',
    );

    final response = await http.delete(url, headers: _headers);

    if (response.statusCode == 200) {
      _isLoggedIn = false;
      debugPrint('[SdkUserB] Logged out (auth tokens deleted)');
    } else {
      debugPrint(
        '[SdkUserB] Logout failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  // ─── Generic HTTP utilities ────────────────────────────────────────────────

  /// GET request as User B (or A). Returns the decoded JSON body.
  ///
  /// [query] is appended as URL query parameters.
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool asUserA = false,
  }) async {
    final base = Uri.parse('${TestCredentials.restBaseUrl}$path');
    final url = query == null ? base : base.replace(queryParameters: query);
    final headers = asUserA ? _headersAsUserA : _headersAsUserB;

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      throw StateError(
        '[SdkUserB] GET $path failed: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// POST request as User B.
  static Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    bool asUserA = false,
  }) async {
    final url = Uri.parse('${TestCredentials.restBaseUrl}$path');
    final headers = asUserA ? _headersAsUserA : _headersAsUserB;

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw StateError(
        '[SdkUserB] POST $path failed: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// PUT request as User B.
  static Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    bool asUserA = false,
  }) async {
    final url = Uri.parse('${TestCredentials.restBaseUrl}$path');
    final headers = asUserA ? _headersAsUserA : _headersAsUserB;

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw StateError(
        '[SdkUserB] PUT $path failed: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// DELETE request as User B.
  static Future<void> delete(
    String path, {
    bool asUserA = false,
  }) async {
    final url = Uri.parse('${TestCredentials.restBaseUrl}$path');
    final headers = asUserA ? _headersAsUserA : _headersAsUserB;

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      throw StateError(
        '[SdkUserB] DELETE $path failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}
