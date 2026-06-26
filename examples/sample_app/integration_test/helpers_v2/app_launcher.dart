import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_app/main.dart';
import 'package:sample_app/app_credentials.dart';

import '../config/test_credentials.dart';
import 'pump_helper.dart';

/// Launches the full sample app and handles login for E2E tests.
///
/// This launches the real BlocSampleApp, waits for CometChat SDK initialization,
/// and performs login through the UI as User A.
///
/// After [launchAndLogin] returns, the app is on the HomeScreen with a fully
/// authenticated User A session, ready for test interactions.
class AppLauncher {
  AppLauncher._();

  /// Launch the app, initialize CometChat, and login as User A.
  ///
  /// After this returns:
  ///   - CometChat SDK is initialized
  ///   - User A is logged in
  ///   - HomeScreen is showing (Chats tab)
  ///   - WebSocket connection is active (events will flow)
  static Future<void> launchAndLogin(WidgetTester tester) async {
    // Clear iOS Keychain (flutter_secure_storage) to wipe stale auth tokens
    // from previous test runs. On iOS the Keychain persists across runs.
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    // Pre-seed credentials into SharedPreferences so the app
    // has valid config on first launch.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cc_app_id', TestCredentials.appId);
    await prefs.setString('cc_region', TestCredentials.region);
    await prefs.setString('cc_auth_key', TestCredentials.authKey);

    // Load into static state
    await AppCredentials.loadSavedCredentials();

    // Launch the real app
    await tester.pumpWidget(const BlocSampleApp());

    // Wait for SDK init (CircularProgressIndicator → login/home)
    await pumpFor(tester, const Duration(seconds: 8));

    // Check if already on HomeScreen (cached session)
    if (find.text('Chats').evaluate().isNotEmpty) {
      return;
    }

    // On LoginScreen — perform login
    await _performLogin(tester);
  }

  /// Launch app without login (for testing login flow itself).
  static Future<void> launchOnly(WidgetTester tester) async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cc_app_id', TestCredentials.appId);
    await prefs.setString('cc_region', TestCredentials.region);
    await prefs.setString('cc_auth_key', TestCredentials.authKey);
    await AppCredentials.loadSavedCredentials();

    await tester.pumpWidget(const BlocSampleApp());
    await pumpFor(tester, const Duration(seconds: 8));
  }

  static Future<void> _performLogin(WidgetTester tester) async {
    // Find the UID field
    final uidField = find.widgetWithText(TextFormField, 'Enter the UID');
    if (uidField.evaluate().isNotEmpty) {
      await tester.enterText(uidField, TestCredentials.userAUid);
    } else {
      // Fallback: first TextFormField on screen
      final fields = find.byType(TextFormField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, TestCredentials.userAUid);
      }
    }

    await tester.pump(const Duration(milliseconds: 300));

    // Dismiss keyboard / unfocus text field so the FocusTrap overlay is
    // removed. If it stays, Flutter's overlay AbsorbPointer blocks the tap.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Continue. After unfocusing, the overlay FocusTrap is gone so the
    // tap should land on the button normally.
    final continueBtn = find.text('Continue');
    if (continueBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(continueBtn.first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(continueBtn.first, warnIfMissed: false);
    }

    // Wait for login + HomeScreen
    final found = await pumpUntilFound(
      tester,
      find.text('Chats'),
      timeout: const Duration(seconds: 15),
    );

    if (!found) {
      // May still be loading — pump more
      await pumpFor(tester, const Duration(seconds: 5));
    }
  }
}
