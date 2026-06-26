import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common UI assertion helpers for E2E tests.
///
/// These encapsulate recurring verification patterns so test suites
/// stay concise and readable.
///
/// IMPORTANT: The CometChat UIKit renders messages as RichText inside
/// sliver-based scroll views. Standard Flutter finders (find.text,
/// find.textContaining, find.byWidgetPredicate) cannot locate these
/// because they skip widgets rendered via slivers. We use direct
/// element tree walking instead.
///
/// Also: Do NOT use underscores in test message text. The UIKit's
/// markdown formatter interprets `_text_` as italic and strips the
/// underscores from the rendered output.
class AssertionHelper {
  AssertionHelper._();

  // ─── Core Message Finder ───────────────────────────────────────────────────

  /// Check if [text] exists anywhere in the widget tree as rendered RichText.
  /// Walks the entire element tree including sliver-rendered items.
  ///
  /// This is the ONLY reliable way to find messages in CometChat UIKit's
  /// message list, which uses CustomScrollView with sliver builders.
  static bool messageExistsInTree(WidgetTester tester, String text) {
    var found = false;
    void walk(Element element) {
      if (found) return;
      final widget = element.widget;
      if (widget is RichText) {
        try {
          if (widget.text.toPlainText().contains(text)) {
            found = true;
            return;
          }
        } catch (_) {}
      } else if (widget is Text) {
        if ((widget.data ?? '').contains(text)) {
          found = true;
          return;
        }
      }
      element.visitChildren(walk);
    }

    tester.binding.rootElement!.visitChildren(walk);
    return found;
  }

  /// Check if ANY of [candidates] appears as rendered text in the tree.
  /// Useful for action messages (joined/left/kicked/banned) whose exact
  /// wording varies, and for matching either a value or a placeholder.
  static bool anyTextInTree(WidgetTester tester, List<String> candidates) {
    for (final c in candidates) {
      if (messageExistsInTree(tester, c)) return true;
    }
    return false;
  }

  /// Poll the tree until ANY of [candidates] appears, or [timeout] expires.
  static Future<bool> waitForAnyTextInTree(
    WidgetTester tester,
    List<String> candidates, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (anyTextInTree(tester, candidates)) return true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    return anyTextInTree(tester, candidates);
  }

  /// Wait for a message to appear in the tree, polling every 500ms.
  /// Returns true if found within timeout.
  static Future<bool> waitForMessageInTree(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (messageExistsInTree(tester, text)) return true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    return messageExistsInTree(tester, text);
  }

  // ─── Screen Presence ───────────────────────────────────────────────────────

  /// Assert that we're on the HomeScreen (Chats tab visible).
  static void expectOnHomeScreen() {
    expect(find.text('Chats'), findsWidgets,
        reason: 'Should be on HomeScreen (Chats tab visible)');
  }

  /// Assert that we're on the MessagesScreen (composer visible).
  static void expectOnMessagesScreen() {
    final composer = find.byType(TextFormField);
    expect(composer.evaluate().isNotEmpty, isTrue,
        reason: 'Should be on MessagesScreen (composer visible)');
  }

  // ─── Message Assertions ────────────────────────────────────────────────────

  /// Assert that a message with [text] is visible in the message list.
  static void expectMessageVisible(WidgetTester tester, String text) {
    expect(messageExistsInTree(tester, text), isTrue,
        reason: 'Message "$text" should be visible in tree');
  }

  /// Assert that a message with [text] is NOT visible.
  static void expectMessageNotVisible(WidgetTester tester, String text) {
    expect(messageExistsInTree(tester, text), isFalse,
        reason: 'Message "$text" should NOT be visible');
  }

  /// Wait for message and assert it arrives.
  static Future<void> waitForMessage(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final found = await waitForMessageInTree(tester, text, timeout: timeout);
    expect(found, isTrue,
        reason: 'Message "$text" should appear within ${timeout.inSeconds}s');
  }

  /// Wait for a message to disappear (deletion tests).
  static Future<void> waitForMessageGone(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (!messageExistsInTree(tester, text)) return;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(messageExistsInTree(tester, text), isFalse,
        reason:
            'Message "$text" should disappear within ${timeout.inSeconds}s');
  }

  // ─── Header Assertions ─────────────────────────────────────────────────────

  /// Assert that the message header shows "Typing..." indicator.
  static void expectTypingIndicator() {
    expect(find.text('Typing...'), findsOneWidget,
        reason: 'Typing indicator should be visible in header');
  }

  /// Assert that "Typing..." is NOT showing.
  static void expectNoTypingIndicator() {
    expect(find.text('Typing...'), findsNothing,
        reason: 'Typing indicator should NOT be visible');
  }

  /// Assert that the header shows "Online" status.
  static void expectOnlineStatus() {
    expect(find.text('Online'), findsOneWidget,
        reason: 'Header should show "Online" status');
  }

  /// Assert that the header shows a specific user name.
  static void expectHeaderName(String name) {
    expect(find.text(name), findsWidgets,
        reason: 'Header should show name "$name"');
  }

  // ─── Conversation List Assertions ──────────────────────────────────────────

  /// Assert that an unread badge with specific count is visible.
  static void expectUnreadBadge(String count) {
    expect(find.text(count), findsWidgets,
        reason: 'Unread badge should show "$count"');
  }
}
