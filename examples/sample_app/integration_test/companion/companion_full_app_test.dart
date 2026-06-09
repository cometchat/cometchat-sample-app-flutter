import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_app/main.dart';
import 'package:sample_app/app_credentials.dart';

import '../helpers/dual_device_config.dart';
import '../helpers/pump_helpers.dart';

/// Companion full-app test — runs on Device B (second device).
///
/// This test launches the actual BlocSampleApp on Device B,
/// logs in as User B, and performs actions (send messages, stay online)
/// that Device A's tests will verify in real-time.
///
/// Run on Device B (iOS simulator or second emulator):
///   flutter test integration_test/companion/companion_full_app_test.dart \
///     -d <device_b_id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Ensure credentials are saved for the app to use.
  Future<void> ensureCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('cc_app_id')?.isEmpty ?? true) {
      await prefs.setString('cc_app_id', DualDeviceConfig.appId);
      await prefs.setString('cc_region', DualDeviceConfig.region);
      await prefs.setString('cc_auth_key', DualDeviceConfig.authKey);
    }
    await AppCredentials.loadSavedCredentials();
  }

  group('Companion Device B — Full App', () {
    testWidgets('Login as User B and send message to User A', (tester) async {
      // Set credentials and launch app
      await ensureCredentials();

      await tester.pumpWidget(const BlocSampleApp());
      await pumpForDuration(tester, const Duration(seconds: 8));

      // Check if we need to login
      final loginTitle = find.text('Sign in to cometchat');
      if (loginTitle.evaluate().isNotEmpty) {
        // Enter User B's UID
        final uidField = find.byType(TextFormField);
        if (uidField.evaluate().isNotEmpty) {
          await tester.enterText(uidField.first, DualDeviceConfig.userBUid);
          await tester.pump(const Duration(milliseconds: 300));

          final continueBtn = find.text('Continue');
          if (continueBtn.evaluate().isNotEmpty) {
            await tester.tap(continueBtn);
          }
        }

        // Wait for login
        await pumpForDuration(tester, const Duration(seconds: 15));
      }

      // Now on HomeScreen — open a conversation with User A and send a message
      // Navigate to Users tab
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab.last);
        await pumpForDuration(tester, const Duration(seconds: 5));
      }

      // Find User A in the list and tap
      final userAName = find.textContaining(DualDeviceConfig.userAName);
      if (userAName.evaluate().isNotEmpty) {
        await tester.tap(userAName.first);
        await pumpForDuration(tester, const Duration(seconds: 5));
      } else {
        // Tap first user (might be User A)
        final listItems = find.byType(InkWell);
        if (listItems.evaluate().isNotEmpty) {
          await tester.tap(listItems.first);
          await pumpForDuration(tester, const Duration(seconds: 5));
        }
      }

      // Send a message
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        final msg = 'From B: ${DateTime.now().millisecondsSinceEpoch}';
        await tester.enterText(textField.last, msg);
        await tester.pump(const Duration(milliseconds: 300));

        final sendButton = find.bySemanticsLabel('Send message');
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton.first);
          await pumpForDuration(tester, const Duration(seconds: 5));
          debugPrint('Companion: Sent message "$msg"');
        }
      }

      // Keep alive for Device A to verify
      await pumpForDuration(tester, const Duration(seconds: 10));
    });

    testWidgets('Login as User B and stay online (keep-alive)', (tester) async {
      await ensureCredentials();

      await tester.pumpWidget(const BlocSampleApp());
      await pumpForDuration(tester, const Duration(seconds: 8));

      // Login if needed
      final loginTitle = find.text('Sign in to cometchat');
      if (loginTitle.evaluate().isNotEmpty) {
        final uidField = find.byType(TextFormField);
        if (uidField.evaluate().isNotEmpty) {
          await tester.enterText(uidField.first, DualDeviceConfig.userBUid);
          await tester.pump(const Duration(milliseconds: 300));

          final continueBtn = find.text('Continue');
          if (continueBtn.evaluate().isNotEmpty) {
            await tester.tap(continueBtn);
          }
        }
        await pumpForDuration(tester, const Duration(seconds: 15));
      }

      debugPrint(
          'Companion: User B is online. Staying alive for 60 seconds...');

      // Stay online for 60 seconds — Device A tests online status
      await pumpForDuration(tester, const Duration(seconds: 60));

      debugPrint('Companion: Keep-alive complete');
    });

    testWidgets('Login as User B and send batch messages', (tester) async {
      await ensureCredentials();

      await tester.pumpWidget(const BlocSampleApp());
      await pumpForDuration(tester, const Duration(seconds: 8));

      // Login if needed
      final loginTitle = find.text('Sign in to cometchat');
      if (loginTitle.evaluate().isNotEmpty) {
        final uidField = find.byType(TextFormField);
        if (uidField.evaluate().isNotEmpty) {
          await tester.enterText(uidField.first, DualDeviceConfig.userBUid);
          await tester.pump(const Duration(milliseconds: 300));

          final continueBtn = find.text('Continue');
          if (continueBtn.evaluate().isNotEmpty) {
            await tester.tap(continueBtn);
          }
        }
        await pumpForDuration(tester, const Duration(seconds: 15));
      }

      // Navigate to Users tab and open User A's chat
      final usersTab = find.text('Users');
      if (usersTab.evaluate().isNotEmpty) {
        await tester.tap(usersTab.last);
        await pumpForDuration(tester, const Duration(seconds: 5));
      }

      // Tap first user
      final listItems = find.byType(InkWell);
      if (listItems.evaluate().isNotEmpty) {
        await tester.tap(listItems.first);
        await pumpForDuration(tester, const Duration(seconds: 5));
      }

      // Send 5 messages
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        for (int i = 1; i <= 5; i++) {
          final msg =
              'Batch #$i from B: ${DateTime.now().millisecondsSinceEpoch}';
          await tester.enterText(textField.last, msg);
          await tester.pump(const Duration(milliseconds: 300));

          final sendButton = find.bySemanticsLabel('Send message');
          if (sendButton.evaluate().isNotEmpty) {
            await tester.tap(sendButton.first);
            await pumpForDuration(tester, const Duration(seconds: 2));
            debugPrint('Companion: Sent batch #$i');
          }
        }
      }

      // Keep alive
      await pumpForDuration(tester, const Duration(seconds: 10));
    });
  });
}
