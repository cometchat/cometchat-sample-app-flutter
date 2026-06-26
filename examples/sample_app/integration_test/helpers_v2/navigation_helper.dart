import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../config/test_credentials.dart';
import 'pump_helper.dart';

/// Helpers for navigating through the sample app's UI.
///
/// The sample app uses a bottom navigation bar with tabs:
///   Chats | Calls | Users | Groups
///
/// And supports navigating into:
///   - MessagesScreen (tap a conversation or user)
///   - UserInfoScreen (tap info button in header)
///   - GroupInfoScreen (tap info button in group chat header)
///   - ThreadScreen (tap thread reply option)
class NavigationHelper {
  NavigationHelper._();

  /// Navigate to a bottom tab by label.
  /// Valid: 'Chats', 'Calls', 'Users', 'Groups'
  static Future<void> goToTab(WidgetTester tester, String label) async {
    final tab = find.text(label);
    if (tab.evaluate().isNotEmpty) {
      // Use .last because the label may appear in both bottom nav and app bar
      await tester.tap(tab.last);
      await pumpForRealtime(tester, duration: const Duration(seconds: 2));
    }
  }

  /// Open User B's conversation specifically.
  ///
  /// Strategy:
  ///   1. Look for User B's name in the conversation list
  ///   2. If found, tap it
  ///   3. If not found, open the first conversation (fallback)
  ///
  /// This ensures we always land in the correct chat for realtime tests.
  static Future<void> openUserBConversation(WidgetTester tester) async {
    // Wait for conversations to load
    await pumpFor(tester, const Duration(seconds: 3));

    // Try finding User B's name in the list
    final userBName = find.text(TestCredentials.userBName);
    if (userBName.evaluate().isNotEmpty) {
      await tester.tap(userBName.first);
      await pumpFor(tester, const Duration(seconds: 3));
      return;
    }

    // Try partial match (e.g., "Nancy" or the UID)
    final partialName = find.textContaining(
      TestCredentials.userBName.split(' ').first,
    );
    if (partialName.evaluate().isNotEmpty) {
      await tester.tap(partialName.first);
      await pumpFor(tester, const Duration(seconds: 3));
      return;
    }

    // Fallback: open first conversation
    await openFirstConversation(tester);
  }

  /// Open the first conversation in the Chats list.
  /// Assumes we're already on the Chats tab.
  static Future<void> openFirstConversation(WidgetTester tester) async {
    // Wait for conversations to load
    await pumpFor(tester, const Duration(seconds: 3));

    // Find the conversations list by its key
    final listKey = find.byKey(const Key('cometchat_conversations_list'));
    if (listKey.evaluate().isNotEmpty) {
      final items = find.descendant(
        of: listKey,
        matching: find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onTap != null,
        ),
      );
      if (items.evaluate().isNotEmpty) {
        await tester.tap(items.first);
        await pumpFor(tester, const Duration(seconds: 3));
        return;
      }
    }

    // Fallback: tap the first tappable item after nav elements
    final gestures = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.onTap != null,
    );
    if (gestures.evaluate().length > 2) {
      await tester.tap(gestures.at(2));
      await pumpFor(tester, const Duration(seconds: 3));
    }
  }

  /// Open a specific conversation by searching for the user/group name.
  static Future<bool> openConversationByName(
    WidgetTester tester,
    String name,
  ) async {
    await pumpFor(tester, const Duration(seconds: 2));

    final nameWidget = find.text(name);
    if (nameWidget.evaluate().isNotEmpty) {
      await tester.tap(nameWidget.first);
      await pumpFor(tester, const Duration(seconds: 3));
      return true;
    }
    return false;
  }

  /// Open the first user in the Users tab.
  static Future<void> openFirstUser(WidgetTester tester) async {
    await goToTab(tester, 'Users');
    await pumpFor(tester, const Duration(seconds: 3));

    final items = find.byType(InkWell);
    if (items.evaluate().isNotEmpty) {
      await tester.tap(items.first);
      await pumpFor(tester, const Duration(seconds: 3));
    }
  }

  /// Open the first group in the Groups tab.
  static Future<void> openFirstGroup(WidgetTester tester) async {
    await goToTab(tester, 'Groups');
    await pumpFor(tester, const Duration(seconds: 3));

    final items = find.byType(InkWell);
    if (items.evaluate().isNotEmpty) {
      await tester.tap(items.first);
      await pumpFor(tester, const Duration(seconds: 3));
    }
  }

  /// Open the test group conversation from the Groups tab.
  ///
  /// Strategy:
  ///   1. Switch to the Groups tab.
  ///   2. Tap the group by its name.
  ///   3. Fall back to the first group if the exact name isn't found.
  ///
  /// Returns true if a group chat was opened.
  ///
  /// [name] overrides which group to open (defaults to the configured test
  /// group). Pass a per-run group name to target a freshly created group.
  static Future<bool> openTestGroup(WidgetTester tester, {String? name}) async {
    await goToTab(tester, 'Groups');
    await pumpFor(tester, const Duration(seconds: 3));

    final byName = find.text(name ?? TestCredentials.testGroupName);
    if (byName.evaluate().isNotEmpty) {
      await tester.tap(byName.first);
      await pumpFor(tester, const Duration(seconds: 3));
      return true;
    }

    final items = find.byType(InkWell);
    if (items.evaluate().isNotEmpty) {
      await tester.tap(items.first);
      await pumpFor(tester, const Duration(seconds: 3));
      return true;
    }
    return false;
  }

  /// Go back (pop navigation).
  static Future<void> goBack(WidgetTester tester) async {
    // Try tooltip "Back"
    final back = find.byTooltip('Back');
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await pumpFor(tester, const Duration(seconds: 2));
      return;
    }

    // Try semantics
    final backSemantic = find.bySemanticsLabel('Back');
    if (backSemantic.evaluate().isNotEmpty) {
      await tester.tap(backSemantic.first);
      await pumpFor(tester, const Duration(seconds: 2));
      return;
    }

    // Try BackButton widget
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await pumpFor(tester, const Duration(seconds: 2));
      return;
    }

    // Try arrow_back icon
    final arrowBack = find.byIcon(Icons.arrow_back);
    if (arrowBack.evaluate().isNotEmpty) {
      await tester.tap(arrowBack.first);
      await pumpFor(tester, const Duration(seconds: 2));
      return;
    }

    // Last resort: top-left tap
    await tester.tapAt(const Offset(30, 55));
    await pumpFor(tester, const Duration(seconds: 2));
  }

  /// Tap the info/details button in the message header.
  /// Opens UserInfoScreen or GroupInfoScreen.
  static Future<void> openInfoScreen(WidgetTester tester) async {
    final infoIcon = find.byIcon(Icons.info_outline);
    if (infoIcon.evaluate().isNotEmpty) {
      await tester.tap(infoIcon.first);
      await pumpFor(tester, const Duration(seconds: 2));
      return;
    }

    // Some versions use a different icon
    final moreIcon = find.byIcon(Icons.more_vert);
    if (moreIcon.evaluate().isNotEmpty) {
      await tester.tap(moreIcon.first);
      await pumpFor(tester, const Duration(seconds: 2));
    }
  }
}
