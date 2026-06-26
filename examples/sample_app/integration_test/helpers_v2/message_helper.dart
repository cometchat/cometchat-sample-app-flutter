import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_helper.dart';

/// Helpers for interacting with the message composer and message list.
///
/// These operate on the MessagesScreen's UI elements:
///   - CometChatMessageComposer: text input + send button
///   - CometChatMessageList: message bubbles
///   - Action sheet: long-press options (edit, delete, react, thread)
class MessageHelper {
  MessageHelper._();

  // ─── Composer ──────────────────────────────────────────────────────────────

  /// Find the message composer text field.
  ///
  /// The CometChat UIKit uses a TextFormField (internally creates TextField)
  /// with hintText "Type your message..." (English default).
  /// We search by EditableText ancestor under a TextField that matches.
  static Finder findComposer() {
    // Primary: find TextFormField by hint text pattern
    final byHint = find.byWidgetPredicate((widget) {
      if (widget is TextField && widget.decoration?.hintText != null) {
        final hint = widget.decoration!.hintText!.toLowerCase();
        return hint.contains('type') ||
            hint.contains('message') ||
            hint.contains('ask');
      }
      return false;
    });
    if (byHint.evaluate().isNotEmpty) return byHint;

    // Fallback: find any TextFormField that's likely the composer
    // (not a search field, not a login field)
    return find.byType(TextFormField).last;
  }

  /// Type text into the composer without sending.
  static Future<void> typeInComposer(
    WidgetTester tester,
    String text,
  ) async {
    final composer = findComposer();
    expect(composer.evaluate().isNotEmpty, isTrue,
        reason: 'Composer must be visible');
    await tester.enterText(composer.first, text);
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Type text and tap the send button.
  /// Returns immediately after tapping send.
  static Future<void> sendMessage(
    WidgetTester tester,
    String text,
  ) async {
    await typeInComposer(tester, text);

    // After entering text, pump to let the send button enable
    await tester.pump(const Duration(milliseconds: 500));

    // Strategy 1: Semantics label (correct when button is enabled)
    final sendBtn = find.bySemanticsLabel('Send message');
    if (sendBtn.evaluate().isNotEmpty) {
      await tester.tap(sendBtn.first);
    } else {
      // Strategy 2: Find the MessageComposerSendButton by type name
      // It's a 32x32 Container with an IconButton inside
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        // The send button is typically the last IconButton on screen
        await tester.tap(iconButtons.last);
      } else {
        // Strategy 3: Find by the send icon asset (Image.asset with "send")
        final images = find.byWidgetPredicate((widget) {
          if (widget is Image && widget.image is AssetImage) {
            final asset = widget.image as AssetImage;
            return asset.assetName.contains('send');
          }
          return false;
        });
        if (images.evaluate().isNotEmpty) {
          await tester.tap(images.first);
        }
      }
    }

    // Wait for message to appear in list
    await pumpForRealtime(tester, duration: const Duration(seconds: 2));
  }

  // ─── Message List ──────────────────────────────────────────────────────────

  /// Check if a specific text message is visible in the message list.
  /// Checks both Text and RichText widgets (messages may render as RichText
  /// when markdown/formatting is applied by the UIKit).
  static bool isMessageVisible(String text) {
    // Check plain Text widgets
    if (find.textContaining(text).evaluate().isNotEmpty) return true;

    // Check RichText widgets (used for formatted messages)
    final richTexts = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        return widget.text.toPlainText().contains(text);
      }
      return false;
    });
    return richTexts.evaluate().isNotEmpty;
  }

  /// Find a message bubble containing specific text.
  /// Searches both Text and RichText widgets.
  static Finder findMessageByText(String text) {
    final textFinder = find.textContaining(text);
    if (textFinder.evaluate().isNotEmpty) return textFinder;

    // Fallback to RichText
    return find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        return widget.text.toPlainText().contains(text);
      }
      return false;
    });
  }

  /// Find a message containing partial text.
  static Finder findMessageContaining(String partial) {
    return findMessageByText(partial);
  }

  // ─── Message Actions (Long-press) ─────────────────────────────────────────

  /// A finder that locates an on-screen message bubble by its text, working for
  /// BOTH plain `Text` and sliver-rendered `RichText` (which the CometChat UIKit
  /// uses for formatted messages — `find.text` cannot match those).
  static Finder findRenderedMessage(String text) {
    final plain = find.text(text);
    if (plain.evaluate().isNotEmpty) return plain;
    return find.byWidgetPredicate((w) {
      if (w is RichText) {
        try {
          return w.text.toPlainText().contains(text);
        } catch (_) {
          return false;
        }
      }
      return false;
    });
  }

  /// Compute the on-screen center of a message bubble by walking the element
  /// tree (the only way to reach sliver-rendered RichText). Returns null if the
  /// message isn't currently laid out on screen.
  static Offset? centerOfMessage(WidgetTester tester, String text) {
    Element? target;
    void walk(Element el) {
      if (target != null) return;
      final w = el.widget;
      if (w is RichText) {
        try {
          if (w.text.toPlainText().contains(text)) {
            target = el;
            return;
          }
        } catch (_) {}
      } else if (w is Text && (w.data ?? '').contains(text)) {
        target = el;
        return;
      }
      el.visitChildren(walk);
    }

    tester.binding.rootElement!.visitChildren(walk);
    final ro = target?.renderObject;
    if (ro is! RenderBox || !ro.hasSize) return null;
    return ro.localToGlobal(ro.size.center(Offset.zero));
  }

  /// Long-press a message to open the action overlay/sheet.
  ///
  /// Standard finders (`find.text`, `find.byWidgetPredicate`) cannot reach
  /// sliver-rendered RichText bubbles, so this falls back to an element-tree
  /// walk + `longPressAt(center)`. Throws if the message isn't on screen.
  static Future<void> longPressMessage(
    WidgetTester tester,
    String messageText,
  ) async {
    final msg = findRenderedMessage(messageText);
    if (msg.evaluate().isNotEmpty) {
      await tester.longPress(msg.first);
      await pumpFor(tester, const Duration(seconds: 1));
      return;
    }
    final center = centerOfMessage(tester, messageText);
    expect(center, isNotNull,
        reason: 'Message "$messageText" must be on screen to long-press');
    await tester.longPressAt(center!);
    await pumpFor(tester, const Duration(seconds: 1));
  }

  /// After long-press, tap a specific action option.
  /// Common options: 'Edit', 'Delete', 'Reply in Thread', 'Copy', 'React'
  static Future<bool> tapAction(
    WidgetTester tester,
    String actionLabel,
  ) async {
    final action = find.text(actionLabel);
    if (action.evaluate().isNotEmpty) {
      await tester.tap(action.first);
      await pumpFor(tester, const Duration(seconds: 1));
      return true;
    }
    return false;
  }

  /// Long-press and then edit a message.
  /// Assumes the message was sent by User A (own message).
  static Future<void> editMessage(
    WidgetTester tester, {
    required String originalText,
    required String newText,
  }) async {
    await longPressMessage(tester, originalText);
    await tapAction(tester, 'Edit');

    // Composer should now show the edit preview. Clear and type new text.
    final composer = findComposer();
    await tester.enterText(composer.first, newText);
    await tester.pump(const Duration(milliseconds: 500));

    // Tap send/save — same strategy as sendMessage
    final sendBtn = find.bySemanticsLabel('Send message');
    if (sendBtn.evaluate().isNotEmpty) {
      await tester.tap(sendBtn.first);
    } else {
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.last);
      }
    }
    await pumpForRealtime(tester, duration: const Duration(seconds: 2));
  }

  /// Long-press and delete a message.
  /// Handles the confirmation dialog.
  static Future<void> deleteMessage(
    WidgetTester tester,
    String messageText,
  ) async {
    await longPressMessage(tester, messageText);
    await tapAction(tester, 'Delete');

    // Confirm in the dialog
    await pumpFor(tester, const Duration(milliseconds: 500));
    final confirm = find.text('Delete');
    if (confirm.evaluate().length > 1) {
      await tester.tap(confirm.last); // Last one is the dialog's confirm button
    } else if (confirm.evaluate().isNotEmpty) {
      await tester.tap(confirm.first);
    }
    await pumpForRealtime(tester, duration: const Duration(seconds: 2));
  }

  // ─── Reactions ─────────────────────────────────────────────────────────────

  /// Long-press a message and add a reaction.
  static Future<void> addReaction(
    WidgetTester tester, {
    required String messageText,
    required String emoji,
  }) async {
    await longPressMessage(tester, messageText);

    // Look for the reaction bar/picker in the action overlay
    final emojiWidget = find.text(emoji);
    if (emojiWidget.evaluate().isNotEmpty) {
      await tester.tap(emojiWidget.first);
      await pumpForRealtime(tester, duration: const Duration(seconds: 2));
    }
  }

  // ─── Scroll ────────────────────────────────────────────────────────────────

  /// Scroll up in the message list (to load older messages).
  static Future<void> scrollUp(WidgetTester tester) async {
    final list = find.byType(ListView);
    if (list.evaluate().isNotEmpty) {
      await tester.drag(list.first, const Offset(0, 300));
      await pumpFor(tester, const Duration(seconds: 2));
    }
  }

  /// Scroll down to the bottom of the message list.
  static Future<void> scrollToBottom(WidgetTester tester) async {
    final list = find.byType(ListView);
    if (list.evaluate().isNotEmpty) {
      await tester.drag(list.first, const Offset(0, -500));
      await pumpFor(tester, const Duration(seconds: 2));
    }
  }
}
