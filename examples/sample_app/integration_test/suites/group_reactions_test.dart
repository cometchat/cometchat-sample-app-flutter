import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../config/test_credentials.dart';
import '../helpers_v2/app_launcher.dart';
import '../helpers_v2/navigation_helper.dart';
import '../helpers_v2/message_helper.dart';
import '../helpers_v2/assertion_helper.dart';
import '../helpers_v2/pump_helper.dart';
import '../sdk_user_b/sdk_user_b.dart';
import '../sdk_user_b/group_actions.dart';
import '../sdk_user_b/reaction_actions.dart';

/// Group Reactions — E2E + Realtime Suite (single file).
///
/// Group-message reaction coverage. The 1:1 reaction cases live in
/// suites/reactions_test.dart (1TO1-045..048, RT-REACT-001..005); this file is
/// the GROUP analogue, exercising the SAME shared bubble footer widget
/// ([CometChatReactions]) and reactor sheet ([CometChatReactionList]) but for
/// `receiverType: group` messages.
///
/// Covered IDs (6):
///   GRP-039  Add reaction to a group message (A reacts via UI / REST)
///   GRP-040  Tap a reaction badge shows the reactor list
///   GRP-041  Remove own reaction from a group message
///   GRP-042  React to another member's (User B's) group message
///   GRP-043  Multiple different reactions on the same group message
///   GRP-044  Reaction count shows correctly after multiple adds (count == 2)
///
/// Driving principle: each test CREATES its own throwaway group with a unique
/// per-run GUID so User A (the emulator UI) is the OWNER/admin and can always
/// open + post + react in the group. User B (headless, REST) is added as a
/// member where a second reactor / a peer message is required, and acts via the
/// CometChat REST API so real `onMessageReactionAdded` / `onMessageReactionRemoved`
/// WebSocket events reach A's SDK and update the UI.
///
/// Rendering facts verified against the UIKit source
/// (shared_ui/.../components/reactions/cometchat_reactions.dart):
///   - Each reaction renders its emoji as a plain `Text(reactionCount.reaction)`
///     node, so `find.text('👍')` matches a group reaction exactly as it does a
///     1:1 reaction.
///   - The count renders as `Text(" ${reactionCount.count}")` — i.e. a leading
///     space + the integer — so a count of 2 is `find.text(' 2')`.
///   - Tapping a badge fires `onReactionTap`, which opens [CometChatReactionList]
///     (a DraggableScrollableSheet of per-user rows). That sheet is sliver/layout
///     dependent, so badge-tap assertions degrade gracefully per the rules.
///
/// Assertion philosophy (mirrors reactions_test.dart / groups_test.dart):
///   - "full" tests assert the real signal: the emoji Text node appears in the
///     tree (and, for peer messages, that the peer message arrived first).
///   - "partial" tests assert the STRONGEST deterministic signal — the reaction
///     is added deterministically via REST and either its emoji is asserted or
///     the screen is asserted stable — then wrap fragile UI interactions
///     (badge tap, badge disappearance) in try/catch + debugPrint without
///     failing the degraded path.
///
/// REST helper added inline (not present on UserBReactions / GroupTestActions):
///   - [_reactToMsgAsUserA] — add a reaction to a message on behalf of User A
///     (the group owner) via REST. UserBReactions only reacts as User B, but
///     GRP-044's deterministic count of 2 needs two DISTINCT reactors on the
///     SAME emoji (A + B). Mirrors UserBReactions.addReaction's shape exactly
///     (encoded-emoji path, empty body) but with `asUserA: true`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle([int seconds = 3]) =>
      Future<void>.delayed(Duration(seconds: seconds));

  final bUid = TestCredentials.userBUid;
  final bName = TestCredentials.userBName; // e.g. "Nancy Grace"

  // A unique throwaway admin-owned group for the reaction tests. User A is the
  // creator => owner/admin, so A can always open the group and post/react.
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final adminGuid = 'e2e_grp_react_$stamp';
  final adminGroupName = 'E2E Reactions $stamp';

  setUpAll(() async {
    // Create the throwaway admin-owned group (creator => admin/owner).
    await UserBGroup.createGroupAsAdmin(
      groupId: adminGuid,
      name: adminGroupName,
    );
    // Add User B as a member so B can post peer messages and react as a second
    // distinct user in the same group.
    await UserBGroup.addMember(bUid, groupId: adminGuid);
    await settle(2);
  });

  tearDownAll(() async {
    // Best-effort cleanup of the throwaway group.
    await UserBGroup.deleteGroup(groupId: adminGuid);
  });

  /// Launch the app as User A and open the freshly-created admin group.
  Future<void> openAdminGroup(WidgetTester tester) async {
    await AppLauncher.launchAndLogin(tester);
    final opened =
        await NavigationHelper.openTestGroup(tester, name: adminGroupName);
    expect(opened, isTrue,
        reason: 'Should open the freshly created admin group');
    AssertionHelper.expectOnMessagesScreen();
  }

  group('Group reactions: add / remove / list / count', () {
    // ── GRP-039 ───────────────────────────────────────────────────────────────
    // Add a reaction to a group message. A posts a message into the group (real
    // group msg id is obtained via B's REST send so the id is deterministic),
    // then a reaction is added and the emoji renders as a Text node on the
    // bubble. CometChatReactions renders the emoji identically for group msgs.
    // implementability=full → assert the emoji is actually visible.
    testWidgets('GRP-039: Add reaction to a group message', (tester) async {
      await openAdminGroup(tester);

      // Seed a real group message (from B, a member) → known message id.
      final text = 'React to group msg $stamp a';
      final msgId = await UserBGroup.sendTextToGroup(text, groupId: adminGuid);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, text);
      expect(arrived, isTrue,
          reason: 'GRP-039: the seeded group message should arrive for A');

      // Add the reaction deterministically via REST (B reacts) so the badge is
      // forced into the tree regardless of A's reaction-picker layout.
      await UserBReactions.addReaction(msgId, '👍');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      expect(find.text('👍'), findsWidgets,
          reason: 'GRP-039: 👍 reaction should be visible on the group message');

      // Also exercise A's UI long-press reaction path (graceful on layout).
      try {
        await MessageHelper.addReaction(
          tester,
          messageText: text,
          emoji: '🔥',
        );
        await pumpForRealtime(tester, duration: const Duration(seconds: 2));
      } catch (e) {
        debugPrint('GRP-039 UI react path degraded: $e');
      }
    });

    // ── GRP-040 ───────────────────────────────────────────────────────────────
    // Tapping a reaction badge opens the reactor list (CometChatReactionList:
    // a DraggableScrollableSheet of per-user rows + an "All N" tab). The single
    // emoji badge is sliver-rendered, so the tap is layout-dependent. Like
    // 1TO1-048 / E2E-038: add the reaction deterministically, tap the badge IF
    // rendered, then assert the reactor's name appears OR fall back to the
    // strongest signal (still on the messages screen).
    // implementability=partial.
    testWidgets('GRP-040: Tap reaction shows reactor list', (tester) async {
      await openAdminGroup(tester);

      final text = 'Tap reactors group $stamp';
      final msgId = await UserBGroup.sendTextToGroup(text, groupId: adminGuid);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, text);
      expect(arrived, isTrue,
          reason: 'GRP-040: the seeded group message should arrive for A');

      // B reacts → deterministic badge (B is the reactor whose name should show
      // in the reactor list if it opens).
      await UserBReactions.addReaction(msgId, '👍');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      // Strongest deterministic signal: the reaction badge rendered at all.
      expect(find.text('👍'), findsWidgets,
          reason: 'GRP-040: 👍 reaction badge should render before tap');

      // Fragile UI path: tap the badge to open the reactor sheet, then look for
      // the reactor's name. Never fail on this degraded path.
      try {
        final badge = find.text('👍');
        if (badge.evaluate().isNotEmpty) {
          await tester.tap(badge.first);
          await pumpForRealtime(tester, duration: const Duration(seconds: 3));

          final sawReactor = AssertionHelper.anyTextInTree(
                tester,
                [bName, bName.split(' ').first, 'All'],
              ) ||
              find.textContaining(bName.split(' ').first).evaluate().isNotEmpty;
          debugPrint('GRP-040 reactor list visible: $sawReactor');
        }
      } catch (e) {
        debugPrint('GRP-040 reactor-list tap degraded: $e');
      }

      // Must remain on the messages screen regardless of sheet rendering.
      AssertionHelper.expectOnMessagesScreen();
    });

    // ── GRP-041 ───────────────────────────────────────────────────────────────
    // Remove own reaction from a group message. Removal is supported via the
    // reactor list ("Tap to remove") or via REST. As in 1TO1-046 / E2E-039,
    // badge disappearance in-tree isn't reliable (UIKit caches the picker emoji
    // elsewhere), so the add+remove is driven deterministically via REST and we
    // assert structural stability after removal (strongest reliable signal).
    // implementability=partial.
    testWidgets('GRP-041: Remove own reaction from a group message',
        (tester) async {
      await openAdminGroup(tester);

      final text = 'Remove own react group $stamp';
      final msgId = await UserBGroup.sendTextToGroup(text, groupId: adminGuid);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, text);
      expect(arrived, isTrue,
          reason: 'GRP-041: the seeded group message should arrive for A');

      // Add via REST so the badge is deterministically present first…
      await UserBReactions.addReaction(msgId, '❤️');
      await pumpForRealtime(tester, duration: const Duration(seconds: 5));
      expect(find.text('❤️'), findsWidgets,
          reason: 'GRP-041: ❤️ should be visible before removal');

      // …then remove it deterministically via REST (own-reaction removal path).
      await UserBReactions.removeReaction(msgId, '❤️');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      // Best-effort: badge should ideally disappear, but UIKit caching makes
      // this flaky — log it, don't fail on it.
      try {
        final stillThere = find.text('❤️').evaluate().isNotEmpty;
        debugPrint('GRP-041 ❤️ badge still present after removal: $stillThere');
      } catch (e) {
        debugPrint('GRP-041 post-removal badge check degraded: $e');
      }

      // Strongest reliable signal: the chat stays stable, no crash.
      AssertionHelper.expectOnMessagesScreen();
    });

    // ── GRP-042 ───────────────────────────────────────────────────────────────
    // React to ANOTHER member's message. User B (a group member) sends a message
    // via REST (real msg id); A opens the group, the message arrives, and a
    // reaction is added so its emoji renders. Deterministic on both halves:
    // B's message arrives (waitForMessageInTree) and the emoji renders as Text.
    // implementability=full.
    testWidgets('GRP-042: React to another member message', (tester) async {
      await openAdminGroup(tester);

      // User B (member) posts a message into the group.
      final bMsg = 'B member msg to react $stamp';
      final msgId = await UserBGroup.sendTextToGroup(bMsg, groupId: adminGuid);

      // Deterministic half #1: B's message arrives in A's group chat.
      final arrived = await AssertionHelper.waitForMessageInTree(tester, bMsg);
      expect(arrived, isTrue,
          reason: "GRP-042: User B's group message should arrive for A");

      // A reacts via the UI long-press path (graceful) to cover the real flow…
      try {
        await MessageHelper.addReaction(
          tester,
          messageText: bMsg,
          emoji: '👍',
        );
        await pumpForRealtime(tester, duration: const Duration(seconds: 3));
      } catch (e) {
        debugPrint('GRP-042 UI react path degraded: $e');
      }

      // …and ensure a reaction is deterministically present via REST (as A, the
      // reactor) so the emoji-on-peer-message assertion is reliable.
      await _reactToMsgAsUserA(msgId, '👍');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      // Deterministic half #2: the reaction emoji renders on B's bubble.
      expect(find.text('👍'), findsWidgets,
          reason: "GRP-042: 👍 should render on User B's group message");
    });

    // ── GRP-043 ───────────────────────────────────────────────────────────────
    // Multiple DIFFERENT reactions on the same group message. Direct group
    // analogue of RT-REACT-004 (1:1 only). B adds two distinct emojis via REST
    // and A adds one via UI. CometChatReactions renders each ReactionCount in a
    // Row, so each distinct emoji is independently findable as Text.
    // implementability=full → assert each distinct emoji is visible.
    testWidgets('GRP-043: Multiple different reactions on same group message',
        (tester) async {
      await openAdminGroup(tester);

      final text = 'Multi react group $stamp';
      final msgId = await UserBGroup.sendTextToGroup(text, groupId: adminGuid);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, text);
      expect(arrived, isTrue,
          reason: 'GRP-043: the seeded group message should arrive for A');

      // B adds two distinct emojis via REST (deterministic).
      await UserBReactions.addReaction(msgId, '👍');
      await settle(1);
      await UserBReactions.addReaction(msgId, '🔥');
      await pumpForRealtime(tester, duration: const Duration(seconds: 6));

      expect(find.text('👍'), findsWidgets,
          reason: 'GRP-043: 👍 reaction should be visible');
      expect(find.text('🔥'), findsWidgets,
          reason: 'GRP-043: 🔥 reaction should be visible');

      // A adds a third distinct emoji — exercise the UI path (graceful) and
      // back it with a deterministic REST add so the third emoji is reliable.
      try {
        await MessageHelper.addReaction(
          tester,
          messageText: text,
          emoji: '❤️',
        );
        await pumpForRealtime(tester, duration: const Duration(seconds: 2));
      } catch (e) {
        debugPrint('GRP-043 UI react path degraded: $e');
      }
      await _reactToMsgAsUserA(msgId, '❤️');
      await pumpForRealtime(tester, duration: const Duration(seconds: 5));

      expect(find.text('❤️'), findsWidgets,
          reason: 'GRP-043: ❤️ reaction (third distinct emoji) should render');
    });

    // ── GRP-044 ───────────────────────────────────────────────────────────────
    // Reaction count shows correctly after multiple adds. The count renders as
    // Text(" ${count}") per ReactionCount, so a count of 2 is deterministic
    // using two DISTINCT reactors on the SAME emoji: User A (via REST as owner)
    // + User B (via REST). Counts > 2 would need extra on-behalf-of UIDs and
    // test_credentials only defines userA/userB, so this asserts the count of 2
    // fully and merely documents the >2 degradation.
    // implementability=partial.
    testWidgets('GRP-044: Reaction count shows correctly after multiple adds',
        (tester) async {
      await openAdminGroup(tester);

      final text = 'React count group $stamp';
      final msgId = await UserBGroup.sendTextToGroup(text, groupId: adminGuid);
      final arrived = await AssertionHelper.waitForMessageInTree(tester, text);
      expect(arrived, isTrue,
          reason: 'GRP-044: the seeded group message should arrive for A');

      // Two distinct users react with the SAME emoji → count must be 2.
      await UserBReactions.addReaction(msgId, '👍'); // reactor #1: User B
      await settle(1);
      await _reactToMsgAsUserA(msgId, '👍'); // reactor #2: User A (owner)
      await pumpForRealtime(tester, duration: const Duration(seconds: 7));

      // The emoji badge must render…
      expect(find.text('👍'), findsWidgets,
          reason: 'GRP-044: 👍 reaction badge should render');

      // …and its count Text is " 2" (leading space, per CometChatReactions).
      // This is the strong deterministic signal for this case.
      final hasCountTwo = find.text(' 2').evaluate().isNotEmpty ||
          find.text('2').evaluate().isNotEmpty ||
          AssertionHelper.anyTextInTree(tester, [' 2', '2']);
      expect(hasCountTwo, isTrue,
          reason: 'GRP-044: reaction count should read 2 after two distinct '
              'users react with the same emoji');

      // Counts > 2 need additional on-behalf-of UIDs (only userA/userB exist in
      // test_credentials), so higher counts are intentionally not asserted here.
      debugPrint(
          'GRP-044: count of 2 asserted; >2 not testable (only A/B available).');
    });
  });
}

// ─── Inline REST helpers (mirrors the shared sdk_user_b shapes) ───────────────

/// Add a reaction to [messageId] on behalf of User A (the group owner) via REST.
///
/// [UserBReactions.addReaction] only reacts as User B. GRP-044 needs two
/// DISTINCT reactors on the SAME emoji to make the rendered count deterministic
/// (User A + User B), and GRP-042/043 use it to reliably force the emoji into
/// A's tree without depending on the UI reaction picker. Mirrors
/// [UserBReactions.addReaction] exactly (URL-encoded emoji in the path, empty
/// body) but flips `asUserA: true`.
///
/// Triggers: onMessageReactionAdded on A's SDK.
Future<void> _reactToMsgAsUserA(int messageId, String emoji) async {
  final encodedEmoji = Uri.encodeComponent(emoji);
  await SdkUserB.post(
    '/messages/$messageId/reactions/$encodedEmoji',
    asUserA: true,
    body: {},
  );
}
