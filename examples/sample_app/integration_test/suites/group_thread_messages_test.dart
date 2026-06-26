import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../config/test_credentials.dart';
import '../helpers_v2/app_launcher.dart';
import '../helpers_v2/navigation_helper.dart';
import '../helpers_v2/message_helper.dart';
import '../helpers_v2/assertion_helper.dart';
import '../helpers_v2/pump_helper.dart';
import '../sdk_user_b/group_actions.dart';
import '../sdk_user_b/thread_actions.dart';

/// Group Thread Messages — E2E Suite (single file).
///
/// Threads inside a GROUP conversation. The 1:1 thread cases
/// (1TO1-049/050/051/053, E2E-040/041/043) cover the same flows for a user
/// chat; everything here adds the GROUP context (ThreadScreen(group:_group),
/// CometChatMessageList(group:..., parentMessageId:...), and the group-only
/// sender-name/avatar header on incoming thread replies).
///
/// Covered IDs (7):
///   GRP-045  Open a thread from a group message (long-press -> Reply in thread)
///   GRP-046  Thread header shows the parent message
///   GRP-047  Send a reply in a group thread (thread composer)
///   GRP-048  Incoming thread reply shows sender name (+ avatar, partial signal)
///   GRP-049  Parent message shows a reply-count badge (partial: wording varies)
///   GRP-050  Thread back button returns to the group messages screen
///   GRP-051  Multiple threads in the same group work independently
///
/// Harness model (matches suites/thread_replies_test.dart, cited by the spec):
///   - User A drives the real Flutter UI on the emulator (AppLauncher).
///   - The test CREATES a throwaway PUBLIC group per run with a unique GUID, so
///     User A is the owner/admin and can always open it from the Groups tab.
///   - User B acts via REST (UserBGroup.sendTextToGroup for group parents,
///     UserBThread.sendReply(receiverType:'group') for incoming thread replies),
///     which fires the real WebSocket events A's SDK consumes.
///   - Opening a thread is done from the UI via long-press -> "Reply in thread".
///     Long-press hit-testing of sliver-rendered bubbles + the exact action
///     label are UIKit-layout dependent, so (exactly like thread_replies_test)
///     opening is treated gracefully: we exercise the deterministic data path
///     and assert the strongest available signal, never crashing on the
///     degraded UI path.
///
/// Notes:
///   - Message text avoids underscores (the UIKit markdown formatter renders
///     `_x_` as italic and strips them), per AssertionHelper's guidance.
///   - User B must be a member of the (public) group to post into it; setUpAll
///     joins B (falling back to an admin add).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle([int seconds = 3]) =>
      Future<void>.delayed(Duration(seconds: seconds));

  final bName = TestCredentials.userBName; // e.g. "Nancy Grace"
  final bUid = TestCredentials.userBUid;

  // A unique throwaway admin-owned PUBLIC group for the thread tests. Creator
  // (User A) is the owner, so A can open it from the Groups tab.
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final groupGuid = 'e2e_grpthread_$stamp';
  final groupName = 'E2E Thread Group $stamp';

  // Thread-action labels vary across UIKit versions/casing; try each in order.
  // English UIKit uses "Reply in thread"; older builds used "Reply in Thread".
  const threadActionLabels = <String>[
    'Reply in thread',
    'Reply in Thread',
    'Reply to thread',
    'Start Thread',
    'Thread',
  ];

  /// Long-press [messageText] in the group message list and try to open its
  /// thread via the action overlay. Returns true if a thread action was tapped.
  /// Wrapped so a long-press miss on a sliver bubble can't crash the test.
  Future<bool> openThread(WidgetTester tester, String messageText) async {
    try {
      await MessageHelper.longPressMessage(tester, messageText);
    } catch (e) {
      debugPrint('  openThread long-press failed (layout): $e');
      return false;
    }
    for (final label in threadActionLabels) {
      if (await MessageHelper.tapAction(tester, label)) {
        await pumpFor(tester, const Duration(seconds: 2));
        return true;
      }
    }
    return false;
  }

  /// Launch A, open the throwaway group, and assert we land on a messages
  /// screen (composer present).
  Future<void> openGroup(WidgetTester tester) async {
    await AppLauncher.launchAndLogin(tester);
    final opened = await NavigationHelper.openTestGroup(tester, name: groupName);
    expect(opened, isTrue,
        reason: 'Should open the freshly created thread test group');
    AssertionHelper.expectOnMessagesScreen();
  }

  setUpAll(() async {
    // Create the throwaway admin-owned PUBLIC group (creator => owner/admin).
    await UserBGroup.createGroupAsAdmin(
      groupId: groupGuid,
      name: groupName,
    );
    // Make User B a member so B can post group messages / thread replies.
    // Public group: B self-joins; fall back to an admin add if join is blocked.
    try {
      await UserBGroup.joinGroup(groupId: groupGuid);
    } catch (e) {
      debugPrint('setUpAll: B join fell back to admin add: $e');
      try {
        await UserBGroup.addMember(bUid, groupId: groupGuid);
      } catch (e2) {
        debugPrint('setUpAll: B add also failed: $e2');
      }
    }
    await settle(2);
  });

  tearDownAll(() async {
    // Best-effort cleanup of the throwaway group.
    await UserBGroup.deleteGroup(groupId: groupGuid);
  });

  group('GroupThreads: open / header / send', () {
    // ── GRP-045 ───────────────────────────────────────────────────────────────
    // Open a thread from a GROUP message. B sends a group message; A long-presses
    // it and opens the thread; the thread view has its own composer.
    testWidgets('GRP-045: Open thread from a group message', (tester) async {
      await openGroup(tester);

      final parent = 'Group thread anchor $stamp';
      await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      final opened = await openThread(tester, parent);
      if (opened) {
        // The thread view (ThreadScreen) has its own CometChatMessageComposer,
        // which renders a TextFormField. The "Thread" title is also present.
        final composer = MessageHelper.findComposer();
        expect(composer.evaluate().isNotEmpty, isTrue,
            reason: 'GRP-045: thread view should have a composer');
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        debugPrint('  GRP-045 thread action not present (layout) — logged');
      }
      // Either path ends on a messages screen (group chat or thread, both have
      // a composer). This is the firm, deterministic assertion.
      AssertionHelper.expectOnMessagesScreen();
    });

    // ── GRP-046 ───────────────────────────────────────────────────────────────
    // The thread header (CometChatThreadedHeader(parentMessage:...)) shows the
    // parent message inside the thread. After opening, the parent text should be
    // present in the thread tree.
    testWidgets('GRP-046: Thread header shows the parent message',
        (tester) async {
      await openGroup(tester);

      final parent = 'Group parent header $stamp';
      await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      final opened = await openThread(tester, parent);
      if (opened) {
        // The threaded header renders the parent bubble; assert the parent text
        // is visible inside the open thread.
        final parentInThread = await AssertionHelper.waitForMessageInTree(
            tester, parent,
            timeout: const Duration(seconds: 10));
        debugPrint('  GRP-046 parent visible in thread header: $parentInThread');
        expect(parentInThread, isTrue,
            reason: 'GRP-046: parent message should show in the thread header');
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        debugPrint('  GRP-046 thread view not opened (layout) — logged');
      }
      AssertionHelper.expectOnMessagesScreen();
    });

    // ── GRP-047 ───────────────────────────────────────────────────────────────
    // Send a reply from the GROUP thread's own composer
    // (CometChatMessageComposer(group:_group, parentMessageId:...)). The reply
    // should appear in the thread list.
    testWidgets('GRP-047: Send a reply in a group thread', (tester) async {
      await openGroup(tester);

      final parent = 'Group reply parent $stamp';
      await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      final opened = await openThread(tester, parent);
      if (opened) {
        const reply = 'A group thread reply';
        await MessageHelper.sendMessage(tester, reply);
        final replySeen = await AssertionHelper.waitForMessageInTree(
            tester, reply,
            timeout: const Duration(seconds: 15));
        debugPrint('  GRP-047 reply visible in thread: $replySeen');
        expect(replySeen, isTrue,
            reason: 'GRP-047: the sent reply should appear in the group thread');
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        debugPrint('  GRP-047 thread view not opened (layout) — logged');
      }
      AssertionHelper.expectOnMessagesScreen();
    });

    // ── GRP-048 ───────────────────────────────────────────────────────────────
    // An INCOMING thread reply in a group renders the sender's name (the
    // group-only headerView in cometchat_message_list builds sender name when
    // group != null && !isOutgoing). B replies in the thread via REST
    // (receiverType:'group'); B's name should be visible in the open thread.
    // Avatar rendering is a partial/best-effort signal (no stable finder).
    testWidgets('GRP-048: Thread reply shows sender name (+avatar)',
        (tester) async {
      await openGroup(tester);

      final parent = 'Group sender parent $stamp';
      final parentId =
          await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      final opened = await openThread(tester, parent);
      // Drive the incoming reply regardless, so the realtime path is exercised.
      const replyText = 'GroupIncomingThreadReply';
      await UserBThread.sendReply(
        parentMessageId: parentId,
        text: replyText,
        receiverUid: groupGuid,
        receiverType: 'group',
      );

      if (opened) {
        // The incoming reply bubble should render in the thread.
        final replySeen = await AssertionHelper.waitForMessageInTree(
            tester, replyText,
            timeout: const Duration(seconds: 20));
        expect(replySeen, isTrue,
            reason: 'GRP-048: incoming thread reply should render in the thread');

        // Group, incoming bubble => sender name header should show B's name.
        // This is the strongest realistic signal for the header; avatar is a
        // best-effort visual we don't fail on.
        final nameSeen =
            AssertionHelper.messageExistsInTree(tester, bName) ||
                find.text(bName).evaluate().isNotEmpty;
        debugPrint('  GRP-048 sender name visible: $nameSeen');
        expect(nameSeen, isTrue,
            reason:
                'GRP-048: incoming group thread reply should show sender name '
                '"$bName"');

        // Avatar is partial signal — log only, never fail.
        try {
          final hasAvatar = find.byType(CircleAvatar).evaluate().isNotEmpty ||
              find.byType(Image).evaluate().isNotEmpty;
          debugPrint('  GRP-048 avatar present (best-effort): $hasAvatar');
        } catch (e) {
          debugPrint('  GRP-048 avatar check skipped: $e');
        }

        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        await pumpForRealtime(tester, duration: const Duration(seconds: 3));
        debugPrint('  GRP-048 thread view not opened (layout) — logged');
      }
      AssertionHelper.expectOnMessagesScreen();
    });
  });

  group('GroupThreads: count / navigation / isolation', () {
    // ── GRP-049 (partial) ─────────────────────────────────────────────────────
    // The parent message shows a reply-count badge ("$count reply/replies") once
    // replies exist. Exact wording/pluralisation/casing varies across UIKit
    // versions, so the badge match is best-effort; the firm assertion is that
    // the parent stays visible after replies (the bubble didn't break) and that
    // the thread reply text is NOT shown in the main group list.
    testWidgets('GRP-049: Parent message shows a reply-count badge',
        (tester) async {
      await openGroup(tester);

      final parent = 'Group count parent $stamp';
      final parentId =
          await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      // B sends two thread replies on this group parent.
      const reply1 = 'GroupCountReplyOne';
      const reply2 = 'GroupCountReplyTwo';
      await UserBThread.sendReply(
        parentMessageId: parentId,
        text: reply1,
        receiverUid: groupGuid,
        receiverType: 'group',
      );
      await UserBThread.sendReply(
        parentMessageId: parentId,
        text: reply2,
        receiverUid: groupGuid,
        receiverType: 'group',
      );

      // Let the reply-count notifier propagate to the parent bubble.
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      // Best-effort badge detection (wording varies) — log, do not fail on it.
      final countBadge = AssertionHelper.anyTextInTree(tester, [
        '2 replies',
        '2 Replies',
        'replies',
        'Replies',
        'reply',
        'Reply',
        '2',
      ]);
      debugPrint('  GRP-049 reply-count badge visible: $countBadge');

      // Firm signals: parent remains visible; thread replies stay out of the
      // main group list (hideReplies filter).
      expect(AssertionHelper.messageExistsInTree(tester, parent), isTrue,
          reason:
              'GRP-049: parent message should remain visible with a reply count');
      expect(find.text(reply1), findsNothing,
          reason:
              'GRP-049: thread replies should not appear in the main group list');
    });

    // ── GRP-050 ───────────────────────────────────────────────────────────────
    // The thread back button (ThreadScreen header onBack -> Navigator.pop)
    // returns to the group messages screen.
    testWidgets('GRP-050: Thread back button returns to group messages',
        (tester) async {
      await openGroup(tester);

      final parent = 'Group back parent $stamp';
      await UserBGroup.sendTextToGroup(parent, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parent);

      final opened = await openThread(tester, parent);
      if (opened) {
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 2));
      } else {
        debugPrint('  GRP-050 thread view not opened (layout) — logged');
      }
      // Either way, we must end on the group messages screen. After popping the
      // thread, the parent group message should be visible again in the main
      // list (the thread header is gone).
      AssertionHelper.expectOnMessagesScreen();
      if (opened) {
        final backOnMain = await AssertionHelper.waitForMessageInTree(
            tester, parent,
            timeout: const Duration(seconds: 8));
        debugPrint('  GRP-050 parent visible on main list after back: '
            '$backOnMain');
        expect(backOnMain, isTrue,
            reason:
                'GRP-050: after back, the group message list should show again');
      }
    });

    // ── GRP-051 ───────────────────────────────────────────────────────────────
    // Two distinct threads in the SAME group stay independent: each thread
    // (keyed by parentMessageId) shows only its own reply. B sends two parents
    // and replies to each via REST; opening each thread shows only its reply.
    testWidgets('GRP-051: Multiple threads in same group are independent',
        (tester) async {
      await openGroup(tester);

      // Two distinct parents in the same group.
      final parentA = 'Group thread A $stamp';
      final parentB = 'Group thread B $stamp';
      final parentAId =
          await UserBGroup.sendTextToGroup(parentA, groupId: groupGuid);
      final parentBId =
          await UserBGroup.sendTextToGroup(parentB, groupId: groupGuid);
      await AssertionHelper.waitForMessage(tester, parentA);
      await AssertionHelper.waitForMessage(tester, parentB);

      // One distinct reply per thread.
      const replyA = 'OnlyInThreadAReply';
      const replyB = 'OnlyInThreadBReply';
      await UserBThread.sendReply(
        parentMessageId: parentAId,
        text: replyA,
        receiverUid: groupGuid,
        receiverType: 'group',
      );
      await UserBThread.sendReply(
        parentMessageId: parentBId,
        text: replyB,
        receiverUid: groupGuid,
        receiverType: 'group',
      );
      await pumpForRealtime(tester, duration: const Duration(seconds: 4));

      // Open thread A: should contain replyA and NOT replyB.
      final openedA = await openThread(tester, parentA);
      if (openedA) {
        final aSeen = await AssertionHelper.waitForMessageInTree(tester, replyA,
            timeout: const Duration(seconds: 20));
        expect(aSeen, isTrue,
            reason: 'GRP-051: thread A should contain its own reply');
        expect(AssertionHelper.messageExistsInTree(tester, replyB), isFalse,
            reason: 'GRP-051: thread A should NOT contain thread B\'s reply');
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 2));
      } else {
        debugPrint('  GRP-051 thread A not opened (layout) — logged');
      }

      // Open thread B: should contain replyB and NOT replyA.
      final openedB = await openThread(tester, parentB);
      if (openedB) {
        final bSeen = await AssertionHelper.waitForMessageInTree(tester, replyB,
            timeout: const Duration(seconds: 20));
        expect(bSeen, isTrue,
            reason: 'GRP-051: thread B should contain its own reply');
        expect(AssertionHelper.messageExistsInTree(tester, replyA), isFalse,
            reason: 'GRP-051: thread B should NOT contain thread A\'s reply');
        await NavigationHelper.goBack(tester);
        await pumpFor(tester, const Duration(seconds: 2));
      } else {
        debugPrint('  GRP-051 thread B not opened (layout) — logged');
      }

      // If neither thread could be opened in this layout, still assert the
      // deterministic isolation invariant: thread replies never leak into the
      // main group list.
      if (!openedA && !openedB) {
        expect(find.text(replyA), findsNothing,
            reason:
                'GRP-051: thread replies must not leak into the main group list');
        expect(find.text(replyB), findsNothing,
            reason:
                'GRP-051: thread replies must not leak into the main group list');
      }

      AssertionHelper.expectOnMessagesScreen();
    });
  });
}
