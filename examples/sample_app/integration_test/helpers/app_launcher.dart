import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_app/main.dart';
import 'package:sample_app/app_credentials.dart';
import 'package:sample_app/screens/home_screen.dart';

import 'dual_device_config.dart';
import 'pump_helpers.dart';

/// Launches the full sample app and handles login for E2E tests.
///
/// Instead of mounting UIKit widgets directly, this launches the actual
/// BlocSampleApp and navigates through the real app screens like a user would.
class AppLauncher {
  /// Launch the full sample app.
  /// The app will auto-init CometChat and route to HomeScreen if credentials
  /// are valid and a user is logged in.
  static Future<void> launchApp(WidgetTester tester) async {
    // Ensure credentials are set for testing via SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('cc_app_id')?.isEmpty ?? true) {
      await prefs.setString('cc_app_id', DualDeviceConfig.appId);
      await prefs.setString('cc_region', DualDeviceConfig.region);
      await prefs.setString('cc_auth_key', DualDeviceConfig.authKey);
    }

    // Load credentials into AppCredentials static state
    await AppCredentials.loadSavedCredentials();

    await tester.pumpWidget(const BlocSampleApp());
  }

  /// Launch app and wait until it's past the loading state.
  /// This waits for CometChat init to complete and the login/home screen to show.
  static Future<void> launchAndWaitForReady(WidgetTester tester) async {
    await launchApp(tester);

    // Wait for initialization (CircularProgressIndicator disappears)
    await pumpForDuration(tester, const Duration(seconds: 8));
  }

  /// Launch app, and if not logged in, perform login through the UI.
  /// After this returns, the HomeScreen should be visible.
  static Future<void> launchAndLogin(WidgetTester tester) async {
    await launchAndWaitForReady(tester);

    // Check if we're on the HomeScreen already (auto-login from cache)
    final homeScreen = find.text('Chats');
    if (homeScreen.evaluate().isNotEmpty) {
      debugPrint('AppLauncher: Already on HomeScreen (cached session)');
      return;
    }

    // Check if we're on the LoginScreen
    final loginTitle = find.text('Sign in to cometchat');
    if (loginTitle.evaluate().isNotEmpty) {
      debugPrint('AppLauncher: On LoginScreen, performing login...');
      await _performLogin(tester);
      return;
    }

    // Might be on GuardScreen still loading — wait more
    await pumpForDuration(tester, const Duration(seconds: 5));

    // Check again
    final homeAfterWait = find.text('Chats');
    if (homeAfterWait.evaluate().isNotEmpty) {
      debugPrint('AppLauncher: On HomeScreen after additional wait');
      return;
    }

    final loginAfterWait = find.text('Sign in to cometchat');
    if (loginAfterWait.evaluate().isNotEmpty) {
      await _performLogin(tester);
      return;
    }

    debugPrint('AppLauncher: Unknown state — proceeding anyway');
  }

  /// Performs login via the LoginScreen UI.
  /// Types the test UID into the text field and taps Continue.
  static Future<void> _performLogin(WidgetTester tester) async {
    // Find the UID text field (the one with hint "Enter the UID")
    final uidField = find.widgetWithText(TextFormField, 'Enter the UID');
    if (uidField.evaluate().isEmpty) {
      // Try alternate: find by type
      final allFields = find.byType(TextFormField);
      if (allFields.evaluate().isNotEmpty) {
        await tester.enterText(allFields.first, DualDeviceConfig.userAUid);
      } else {
        debugPrint('AppLauncher: Could not find UID text field');
        return;
      }
    } else {
      await tester.enterText(uidField, DualDeviceConfig.userAUid);
    }

    await tester.pump(const Duration(milliseconds: 300));

    // Tap the Continue button
    final continueButton = find.text('Continue');
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
    }

    // Wait for login to complete and HomeScreen to appear
    await pumpForDuration(tester, const Duration(seconds: 15));

    // Verify we're on HomeScreen
    final chatsTab = find.text('Chats');
    if (chatsTab.evaluate().isNotEmpty) {
      debugPrint('AppLauncher: Login successful, on HomeScreen');
    } else {
      debugPrint('AppLauncher: Login may have failed or still loading');
    }
  }

  /// Navigate to a specific bottom tab by label.
  /// Valid labels: 'Chats', 'Calls', 'Users', 'Groups', 'Notifications'
  static Future<void> navigateToTab(
    WidgetTester tester,
    String tabLabel,
  ) async {
    final tab = find.text(tabLabel);
    if (tab.evaluate().isNotEmpty) {
      await tester.tap(
          tab.last); // last because the label appears in both appbar and nav
      await pumpForDuration(tester, const Duration(seconds: 2));
    } else {
      debugPrint('AppLauncher: Tab "$tabLabel" not found');
    }
  }

  /// Tap the first conversation in the Chats list to open MessagesScreen.
  static Future<void> openFirstConversation(WidgetTester tester) async {
    final listItems = find.byType(InkWell);
    if (listItems.evaluate().isNotEmpty) {
      await tester.tap(listItems.first);
      await pumpForDuration(tester, const Duration(seconds: 3));
    } else {
      debugPrint('AppLauncher: No conversations to tap');
    }
  }

  /// Tap the first user in the Users tab to open MessagesScreen.
  static Future<void> openFirstUser(WidgetTester tester) async {
    await navigateToTab(tester, 'Users');
    await pumpForDuration(tester, const Duration(seconds: 5));

    final listItems = find.byType(InkWell);
    if (listItems.evaluate().isNotEmpty) {
      await tester.tap(listItems.first);
      await pumpForDuration(tester, const Duration(seconds: 3));
    }
  }

  /// Tap the first group in the Groups tab to open MessagesScreen.
  static Future<void> openFirstGroup(WidgetTester tester) async {
    await navigateToTab(tester, 'Groups');
    await pumpForDuration(tester, const Duration(seconds: 5));

    final listItems = find.byType(InkWell);
    if (listItems.evaluate().isNotEmpty) {
      await tester.tap(listItems.first);
      await pumpForDuration(tester, const Duration(seconds: 3));
    }
  }

  /// Go back from current screen (pop navigation).
  static Future<void> goBack(WidgetTester tester) async {
    // CometChat header uses an asset image wrapped in InkWell for back.
    // Find it via tooltip, semantics, or by finding the first tappable
    // element in the AppBar leading area.

    // Try tooltip "Back"
    final backTooltip = find.byTooltip('Back');
    if (backTooltip.evaluate().isNotEmpty) {
      await tester.tap(backTooltip.first);
      await pumpForDuration(tester, const Duration(seconds: 2));
      return;
    }

    // Try finding NavigatorPopHandler or any InkWell with back semantics
    final backSemantic = find.bySemanticsLabel('Back');
    if (backSemantic.evaluate().isNotEmpty) {
      await tester.tap(backSemantic.first);
      await pumpForDuration(tester, const Duration(seconds: 2));
      return;
    }

    // Try standard Material BackButton
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await pumpForDuration(tester, const Duration(seconds: 2));
      return;
    }

    // Try Icons.arrow_back (used in UserInfoScreen)
    final arrowBack = find.byIcon(Icons.arrow_back);
    if (arrowBack.evaluate().isNotEmpty) {
      await tester.tap(arrowBack.first);
      await pumpForDuration(tester, const Duration(seconds: 2));
      return;
    }

    // Last resort: tap coordinates of top-left area (where back button lives)
    await tester.tapAt(const Offset(30, 55));
    await pumpForDuration(tester, const Duration(seconds: 2));
  }
}
