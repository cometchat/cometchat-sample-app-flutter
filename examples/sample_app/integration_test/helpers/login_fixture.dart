import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Reads CometChat credentials. For device-based integration tests,
/// Platform.environment is not available — credentials are compiled in
/// via --dart-define or hardcoded for internal test apps.
///
/// For CI, pass via --dart-define:
///   flutter test integration_test/ \
///     --dart-define=COMETCHAT_APP_ID=xxx \
///     --dart-define=TEST_USER_UID=yyy
class LoginFixture {
  // Hardcoded for internal test app (26580020f03ff346).
  // For CI, override via --dart-define.
  static const String appId = String.fromEnvironment(
    'COMETCHAT_APP_ID',
    defaultValue: '26580020f03ff346',
  );
  static const String region = String.fromEnvironment(
    'COMETCHAT_REGION',
    defaultValue: 'in',
  );
  static const String authKey = String.fromEnvironment(
    'COMETCHAT_AUTH_KEY',
    defaultValue: '4152b0366478871f0fa8d19a287dd6f5ed5f8eff',
  );
  static const String testUserUid = String.fromEnvironment(
    'TEST_USER_UID',
    defaultValue: 'cometchat-uid-2',
  );

  /// Initialize CometChat SDK and login with the test user.
  /// Returns the logged-in [User].
  static Future<User> initAndLogin() async {
    final settingsBuilder = UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..region = region
      ..autoEstablishSocketConnection = true
      ..appId = appId
      ..authKey = authKey;

    // Build settings (skip enableCalls to avoid Calls SDK init which
    // requires permissions we can't grant in integration_test)
    final uiKitSettings = settingsBuilder.build();

    // Init — CometChatUIKit.init is NOT a true Future; it uses callbacks.
    // We use a Completer to bridge.
    final initCompleter = Completer<void>();
    CometChatUIKit.init(
      uiKitSettings: uiKitSettings,
      onSuccess: (_) {
        initCompleter.complete();
      },
      onError: (e) {
        initCompleter.completeError(
          StateError('CometChatUIKit.init failed: ${e.message ?? e.code ?? "unknown"}'),
        );
      },
    );

    await initCompleter.future;

    // Login — same pattern, callback-based
    final loginCompleter = Completer<User>();
    CometChatUIKit.login(
      testUserUid,
      onSuccess: (user) {
        loginCompleter.complete(user);
      },
      onError: (e) {
        loginCompleter.completeError(
          StateError('CometChatUIKit.login failed: ${e.message ?? e.code ?? "unknown"}'),
        );
      },
    );

    return await loginCompleter.future;
  }

  /// Logout the current user. Call in `tearDownAll`.
  static Future<void> logout() async {
    await CometChatUIKit.logout(
      onSuccess: (_) {},
      onError: (_) {},
    );
  }
}
