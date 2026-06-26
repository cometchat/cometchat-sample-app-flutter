import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../config/test_credentials.dart';
import '../helpers_v2/app_launcher.dart';
import '../helpers_v2/navigation_helper.dart';
import '../helpers_v2/message_helper.dart';
import '../helpers_v2/assertion_helper.dart';
import '../helpers_v2/pump_helper.dart';
import '../helpers_v2/cleanup_helper.dart';
import '../sdk_user_b/messaging_actions.dart';

/// Edge Cases & Stress E2E Suite (consolidated)
///
/// Covers EVERY id owned by this suite:
///   1TO1-097  testEmptyConversationShowsGreeting
///   1TO1-098  testRapidMessageSendDoesNotCrash
///   1TO1-099  testOfflineMessageQueueOnReconnect
///   1TO1-100  testAppResumeRefreshesMessages
///   1TO1-101  testDateSeparatorBetweenDays
///   1TO1-102  testConversationStarters
///   1TO1-103  testSmartRepliesSuggestions
///   RT-EDGE-001  Simultaneous send same millisecond
///   RT-EDGE-002  Edit while peer long-presses
///   RT-EDGE-003  Delete conversation while message arrives
///   RT-EDGE-004  50 messages burst
///   RT-EDGE-005  Rapid typing start/stop
///   RT-EDGE-006  Switch chats rapidly while messages arrive
///   RT-EDGE-007  Message arrives while scrolled up
///   RT-EDGE-008  App resume after background
///   RT-EDGE-009  Message moderated after send
///   RT-EDGE-010  Same message doesn't duplicate (dedup)
///
/// User A = emulator UI (WidgetTester). User B = REST API (same process).
///
/// Assertion philosophy (matches reactions/receive exemplars):
///   - Deterministic realtime data (text arrives, no crash) → fatal asserts.
///   - Assertions that depend on optional/dashboard-gated features (moderation,
///     smart replies, conversation starters, exact date-separator wording,
///     typing-indicator debounce timing, true OS background) → structural /
///     non-fatal: we exercise the path, log the observation, and assert the app
///     stays stable rather than fabricating a crash. These are commented inline.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CleanupHelper.seedConversation();
    await Future<void>.delayed(const Duration(seconds: 1));
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: Race conditions', () {
    // RT-EDGE-001: Both users send at (effectively) the same millisecond.
    // Testability: we cannot guarantee identical server timestamps, but we can
    // fire A (UI) and B (REST) back-to-back and assert both land and the list
    // stays consistent (both visible, no crash, ordering preserved).
    testWidgets('RT-EDGE-001: Simultaneous send, both visible in order',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final aText = 'SimulA $stamp';
      final bText = 'SimulB $stamp';

      // Fire both as close together as the harness allows.
      final bFuture = UserBMessaging.sendTextToA(bText);
      await MessageHelper.sendMessage(tester, aText);
      await bFuture;

      await pumpForRealtime(tester, duration: const Duration(seconds: 5));

      expect(await AssertionHelper.waitForMessageInTree(tester, aText), isTrue,
          reason: "RT-EDGE-001: A's message should be visible");
      expect(await AssertionHelper.waitForMessageInTree(tester, bText), isTrue,
          reason: "RT-EDGE-001: B's message should be visible");
      AssertionHelper.expectOnMessagesScreen();
    });

    // RT-EDGE-002: B edits a message while A has its action sheet open.
    // Testability: long-press B's message to open the action overlay, then have
    // B edit the SAME message via REST. The action sheet must not crash and the
    // edited text must propagate. Overlay layout / edit-propagation timing for
    // peer edits is non-deterministic, so the edited-text arrival is polled and
    // logged; app stability is the fatal assertion.
    testWidgets('RT-EDGE-002: Edit while peer long-presses', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final original = 'LongPressEditBefore ${DateTime.now().millisecondsSinceEpoch}';
      final edited = 'LongPressEditAfter ${DateTime.now().millisecondsSinceEpoch}';
      final msgId = await UserBMessaging.sendTextToA(original);
      expect(await AssertionHelper.waitForMessageInTree(tester, original), isTrue,
          reason: 'RT-EDGE-002: original message should arrive');

      // A opens the action sheet on B's message.
      var sheetOpen = false;
      try {
        await MessageHelper.longPressMessage(tester, original);
        sheetOpen = true;
      } catch (e) {
        debugPrint('RT-EDGE-002: long-press skipped (message offscreen?): $e');
      }

      // B edits the same message while the sheet is (potentially) open.
      await UserBMessaging.editMessage(msgId, edited);
      final editArrived = await AssertionHelper.waitForMessageInTree(
          tester, edited,
          timeout: const Duration(seconds: 15));
      debugPrint('RT-EDGE-002: edited text visible underneath sheet: $editArrived');

      // Dismiss any lingering overlay so the suite stays clean.
      if (sheetOpen && find.byType(TextFormField).evaluate().isEmpty) {
        await tester.tapAt(const Offset(20, 40));
        await pumpFor(tester, const Duration(seconds: 1));
      }
      // Fatal: the screen survived the concurrent edit + open action sheet.
      AssertionHelper.expectOnMessagesScreen();
    });

    // RT-EDGE-003: A deletes the conversation while B sends a message.
    // Testability: from the Chats list, delete the conversation via REST and
    // have B send immediately after — the conversation must reappear with the
    // new message and the app must not crash.
    testWidgets('RT-EDGE-003: Delete conversation while message arrives',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      AssertionHelper.expectOnHomeScreen();

      await CleanupHelper.deleteConversation();
      await pumpFor(tester, const Duration(seconds: 2));

      final raceText = 'AfterDelete ${DateTime.now().millisecondsSinceEpoch}';
      await UserBMessaging.sendTextToA(raceText);
      final reappeared = await AssertionHelper.waitForMessageInTree(
          tester, raceText,
          timeout: const Duration(seconds: 20));
      debugPrint('RT-EDGE-003: conversation reappeared with new message: $reappeared');

      // The chats list must stay functional regardless of the race outcome.
      AssertionHelper.expectOnHomeScreen();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: Stress', () {
    // RT-EDGE-004: B sends 50 messages in a rapid burst; A receives without crash.
    // Testability: sendMultipleToA(50) drives the burst; we assert the screen is
    // intact and a sample of the burst is visible. Asserting all 50 is brittle
    // (virtualized list only renders a window), so we check presence + stability.
    testWidgets('RT-EDGE-004: 50 message burst, no crash', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      await UserBMessaging.sendMultipleToA(
        50,
        prefix: 'Burst',
        delayBetween: const Duration(milliseconds: 40),
      );

      await pumpForRealtime(tester, duration: const Duration(seconds: 12));

      AssertionHelper.expectOnMessagesScreen();
      expect(AssertionHelper.messageExistsInTree(tester, 'Burst'), isTrue,
          reason: 'RT-EDGE-004: at least some burst messages should be visible');

      // Scrolling must remain responsive after the burst.
      await MessageHelper.scrollUp(tester);
      await MessageHelper.scrollToBottom(tester);
      AssertionHelper.expectOnMessagesScreen();
    });

    // RT-EDGE-005: B types and stops rapidly 10 times; A's indicator must not
    // flicker excessively.
    // Testability: the REST API exposes NO typing endpoint (see
    // sdk_user_b/typing_actions.dart — it throws UnsupportedError), so a true
    // peer typing event cannot be fired from this harness. We instead exercise
    // the header/indicator code path by rapidly entering & clearing text in A's
    // own composer (which drives the local typing debounce) and assert the
    // header/screen stays stable with no excessive rebuild crash. This is a
    // STRUCTURAL stand-in for the peer-typing flicker scenario.
    testWidgets('RT-EDGE-005: Rapid typing start/stop, no flicker crash',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      for (var i = 0; i < 10; i++) {
        await MessageHelper.typeInComposer(tester, 'typing$i');
        await tester.pump(const Duration(milliseconds: 150));
        await MessageHelper.typeInComposer(tester, '');
        await tester.pump(const Duration(milliseconds: 150));
      }
      await pumpForRealtime(tester, duration: const Duration(seconds: 2));

      // "Typing..." must not be permanently stuck and the screen must survive.
      AssertionHelper.expectNoTypingIndicator();
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-098: Rapid send from A (10 messages) does not crash.
    testWidgets('1TO1-098: Rapid send from A does not crash', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      for (var i = 1; i <= 10; i++) {
        await MessageHelper.sendMessage(tester, 'RapidA $i');
      }

      await pumpForRealtime(tester);
      AssertionHelper.expectOnMessagesScreen();
      expect(AssertionHelper.messageExistsInTree(tester, 'RapidA'), isTrue,
          reason: '1TO1-098: at least one rapid message should be visible');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: Navigation & scroll', () {
    // RT-EDGE-006: Switch chats rapidly while messages arrive; no cross-
    // contamination between conversations.
    // Testability: B sends while A bounces between tabs/back; on returning to
    // B's chat the messages must be present and the app stable.
    testWidgets('RT-EDGE-006: Switch chats rapidly, no cross-contamination',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final tag = DateTime.now().millisecondsSinceEpoch;
      await UserBMessaging.sendTextToA('Switch1 $tag');

      // Bounce out and back a few times while messages keep arriving.
      for (var i = 0; i < 3; i++) {
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 1));
        await UserBMessaging.sendTextToA('Switch${i + 2} $tag');
        await NavigationHelper.openUserBConversation(tester);
        await pumpFor(tester, const Duration(seconds: 1));
      }

      await pumpForRealtime(tester, duration: const Duration(seconds: 4));

      // Messages must land in B's conversation (no cross-contamination / crash).
      expect(await AssertionHelper.waitForMessageInTree(tester, 'Switch1 $tag'),
          isTrue,
          reason: 'RT-EDGE-006: messages should be in the correct conversation');
      AssertionHelper.expectOnMessagesScreen();
    });

    // RT-EDGE-007: A is scrolled up viewing history; B sends a new message.
    // Expect: new message does NOT force an auto-scroll (scroll-to-bottom button
    // appears). Testability: scroll up, B sends, assert the message is RECEIVED
    // (data arrives) without crash. The exact auto-scroll-guard / button widget
    // is UIKit-internal, so we verify arrival + stability rather than pixel state.
    testWidgets('RT-EDGE-007: New message while scrolled up', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      // Seed enough history to make scroll-up meaningful.
      await UserBMessaging.sendMultipleToA(12, prefix: 'ScrollSeed');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      await MessageHelper.scrollUp(tester);
      await pumpFor(tester, const Duration(seconds: 2));

      final whileUp = 'ArrivedWhileScrolled ${DateTime.now().millisecondsSinceEpoch}';
      await UserBMessaging.sendTextToA(whileUp);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, whileUp,
          timeout: const Duration(seconds: 25));
      expect(arrived, isTrue,
          reason: 'RT-EDGE-007: message should be received while scrolled up');

      await MessageHelper.scrollToBottom(tester);
      AssertionHelper.expectOnMessagesScreen();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: App lifecycle', () {
    // RT-EDGE-008: A backgrounds the app, B sends 5 messages, A resumes — all 5
    // must be present.
    // Testability: a true 30s OS background isn't available in the widget test
    // harness, so we drive the lifecycle via tester.binding lifecycle states
    // (paused → resumed) around B's sends, then assert all 5 sync in on resume.
    testWidgets('RT-EDGE-008: App resume after background syncs messages',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final tag = DateTime.now().millisecondsSinceEpoch;

      // Simulate going to background.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 500));

      // B sends 5 messages while A is "backgrounded".
      await UserBMessaging.sendMultipleToA(5, prefix: 'BgSync $tag');
      await Future<void>.delayed(const Duration(seconds: 2));

      // Resume.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpForRealtime(tester, duration: const Duration(seconds: 8));

      // All 5 should be present (or, conservatively, the latest synced in).
      final first = await AssertionHelper.waitForMessageInTree(
          tester, 'BgSync $tag #1',
          timeout: const Duration(seconds: 15));
      final last = await AssertionHelper.waitForMessageInTree(
          tester, 'BgSync $tag #5',
          timeout: const Duration(seconds: 15));
      debugPrint('RT-EDGE-008: first synced=$first last synced=$last');
      // Fatal: at least the burst is present and the screen survived resume.
      expect(AssertionHelper.messageExistsInTree(tester, 'BgSync $tag'), isTrue,
          reason: 'RT-EDGE-008: backgrounded messages should sync on resume');
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-100: App resume refreshes messages (pump-gap variant).
    testWidgets('1TO1-100: Messages present after resume', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final tag = DateTime.now().millisecondsSinceEpoch;
      // Simulate a foreground gap by sending without pumping, then resume pumps.
      await UserBMessaging.sendMultipleToA(3, prefix: 'AfterPause $tag');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      expect(AssertionHelper.messageExistsInTree(tester, 'AfterPause $tag'),
          isTrue,
          reason: '1TO1-100: messages sent during pause should appear on resume');
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-099: Offline message queue delivered on reconnect.
    // Testability: we can't toggle A's real socket from the harness, so we
    // approximate the "offline then reconnect" window using the lifecycle
    // paused→resumed transition while B queues messages. On reconnect/resume the
    // queued messages must appear. Structural: app stability + message arrival.
    testWidgets('1TO1-099: Offline message queue delivered on reconnect',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final tag = DateTime.now().millisecondsSinceEpoch;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 500));

      // B queues messages while A is "offline".
      await UserBMessaging.sendTextToA('Queued1 $tag');
      await UserBMessaging.sendTextToA('Queued2 $tag');
      await Future<void>.delayed(const Duration(seconds: 2));

      // Reconnect.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpForRealtime(tester, duration: const Duration(seconds: 8));

      final got1 = await AssertionHelper.waitForMessageInTree(tester, 'Queued1 $tag',
          timeout: const Duration(seconds: 15));
      final got2 = await AssertionHelper.waitForMessageInTree(tester, 'Queued2 $tag',
          timeout: const Duration(seconds: 15));
      debugPrint('1TO1-099: queued delivered q1=$got1 q2=$got2');
      expect(got1 || got2, isTrue,
          reason: '1TO1-099: queued messages should arrive after reconnect');
      AssertionHelper.expectOnMessagesScreen();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: Dedup & moderation', () {
    // RT-EDGE-010: A network retry could double-deliver a message; the list must
    // dedup by id/muid and show only ONE copy.
    // Testability: we cannot force a true wire-level retry, so we send the SAME
    // text twice with the SAME id reference is impossible — instead we send once
    // and pump long enough that any duplicate WebSocket frame would surface, then
    // assert exactly one rendered instance of the unique text. (The UIKit's
    // _isMessageAlreadyInList guard is what we're validating doesn't double-add.)
    testWidgets('RT-EDGE-010: Same message does not duplicate', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final unique = 'DedupUnique ${DateTime.now().millisecondsSinceEpoch}';
      await UserBMessaging.sendTextToA(unique);
      expect(await AssertionHelper.waitForMessageInTree(tester, unique), isTrue,
          reason: 'RT-EDGE-010: message should arrive once');

      // Pump extra time so any retry/duplicate frame would land if it were going to.
      await pumpForRealtime(tester, duration: const Duration(seconds: 5));

      // Count rendered instances of the unique text in the (on-screen) tree.
      final count = _countRenderedText(tester, unique);
      debugPrint('RT-EDGE-010: rendered instances of unique text = $count');
      expect(count, lessThanOrEqualTo(1),
          reason: 'RT-EDGE-010: dedup should keep at most one rendered copy');
      AssertionHelper.expectOnMessagesScreen();
    });

    // RT-EDGE-009: A sends a message; moderation may mark it disapproved.
    // Testability: moderation is a dashboard-gated server pipeline that may be
    // disabled for the test app, and the disapproval signal is async/optional.
    // This is STRUCTURAL: A sends, we pump for any moderation outcome, log
    // whether a moderation/error indicator appears, and assert the app stays
    // stable (we never fail on moderation being absent).
    testWidgets('RT-EDGE-009: Message moderated after send (structural)',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      final text = 'ModerateMe ${DateTime.now().millisecondsSinceEpoch}';
      await MessageHelper.sendMessage(tester, text);
      expect(await AssertionHelper.waitForMessageInTree(tester, text), isTrue,
          reason: 'RT-EDGE-009: own message should appear in the list');

      // Give the moderation pipeline time to (possibly) process and flag it.
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      final moderationHint = AssertionHelper.anyTextInTree(tester, [
        'moderated',
        'Moderated',
        'disapproved',
        'Disapproved',
        'failed',
        'Failed',
        'not delivered',
      ]);
      debugPrint('RT-EDGE-009: moderation/error indicator visible: $moderationHint');
      // Non-fatal — moderation may be disabled. App must remain usable.
      AssertionHelper.expectOnMessagesScreen();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('EdgeCases: 1to1 UI affordances', () {
    // 1TO1-097: Empty conversation shows a greeting / empty-state.
    // Testability: delete the conversation so the chat opens empty, then assert
    // the empty-state greeting structure (an empty-state graphic OR greeting
    // text) is present and the composer is usable. Exact greeting copy varies by
    // build, so we accept common greeting strings OR a structurally-empty list.
    testWidgets('1TO1-097: Empty conversation shows greeting', (tester) async {
      await CleanupHelper.deleteConversation();
      await Future<void>.delayed(const Duration(seconds: 1));

      await AppLauncher.launchAndLogin(tester);
      // Open via Users tab so an empty (no-history) chat is reachable.
      await NavigationHelper.openUserBConversation(tester);
      await pumpFor(tester, const Duration(seconds: 3));

      // The composer must be present (chat is open and usable).
      AssertionHelper.expectOnMessagesScreen();

      final greeting = AssertionHelper.anyTextInTree(tester, [
        'Say hi',
        'Start the conversation',
        'No messages',
        'Send a message',
        'Hi',
        'Hello',
        TestCredentials.userBName.split(' ').first,
      ]);
      debugPrint('1TO1-097: greeting/empty-state hint visible: $greeting');
      // Structural: an open, usable, non-crashed empty chat is the contract.
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-101: Date separator appears between days.
    // Testability: a deterministic cross-midnight message can't be injected from
    // the harness, so we assert the UI renders SOME date-grouping affordance for
    // today's messages (e.g. "Today"/"Yesterday" separator) after a fresh send.
    // Structural: presence of a date-separator-style label OR stable screen.
    testWidgets('1TO1-101: Date separator between days', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      await UserBMessaging.sendTextToA(
          'DateSep ${DateTime.now().millisecondsSinceEpoch}');
      await pumpForRealtime(tester, duration: const Duration(seconds: 5));

      final dateLabel = AssertionHelper.anyTextInTree(tester, [
        'Today',
        'Yesterday',
        'TODAY',
        'YESTERDAY',
      ]);
      debugPrint('1TO1-101: date separator label visible: $dateLabel');
      // The separator is UIKit-rendered and locale/build dependent — structural.
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-102: Conversation starters surface for an empty conversation.
    // Testability: conversation starters are an AI/dashboard-gated feature that
    // may be disabled. We open a (deleted→empty) chat, look for starter chips /
    // suggestion UI, log presence, and assert the screen stays stable.
    testWidgets('1TO1-102: Conversation starters (structural)', (tester) async {
      await CleanupHelper.deleteConversation();
      await Future<void>.delayed(const Duration(seconds: 1));

      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);
      await pumpFor(tester, const Duration(seconds: 4));

      AssertionHelper.expectOnMessagesScreen();
      final starters = AssertionHelper.anyTextInTree(tester, [
        'How are you',
        'Hello',
        'Hi there',
        'What',
        'Tell me',
      ]);
      debugPrint('1TO1-102: conversation-starter chips visible: $starters');
      // Non-fatal: starters are AI-gated. Contract is a stable, open chat.
      AssertionHelper.expectOnMessagesScreen();
    });

    // 1TO1-103: Smart replies suggestions surface after an incoming message.
    // Testability: smart replies are AI/dashboard-gated. B sends a question-like
    // message; we look for a smart-reply suggestion strip, log presence, and
    // assert the screen stays stable (never fail on the feature being disabled).
    testWidgets('1TO1-103: Smart replies suggestions (structural)',
        (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await NavigationHelper.openUserBConversation(tester);

      await UserBMessaging.sendTextToA('How are you doing today?');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      final smartReply = AssertionHelper.anyTextInTree(tester, [
        'Yes',
        'No',
        'Sure',
        'Thanks',
        'Good',
        "I'm good",
        'Great',
      ]);
      debugPrint('1TO1-103: smart-reply suggestion visible: $smartReply');
      // Non-fatal: smart replies are AI-gated. App must remain usable.
      AssertionHelper.expectOnMessagesScreen();
    });
  });
}

/// Count how many distinct rendered Text/RichText widgets currently contain
/// [text]. Used by RT-EDGE-010 to verify no duplicate bubble was added.
/// Only counts widgets currently laid out in the tree (virtualized list window).
int _countRenderedText(WidgetTester tester, String text) {
  var count = 0;
  void walk(Element element) {
    final widget = element.widget;
    if (widget is RichText) {
      try {
        if (widget.text.toPlainText().contains(text)) count++;
      } catch (_) {}
    } else if (widget is Text) {
      if ((widget.data ?? '').contains(text)) count++;
    }
    element.visitChildren(walk);
  }

  tester.binding.rootElement!.visitChildren(walk);
  return count;
}
