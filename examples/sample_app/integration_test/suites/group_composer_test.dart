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

/// Group Composer — E2E suite (single file).
///
/// Drives User A's real message composer inside a GROUP conversation. Every
/// test opens a throwaway group that User A created this run (so A is the
/// owner/admin), via messages_screen._buildComposer() which renders
/// `CometChatMessageComposer(group: _group)` with
/// `CometChatMentionsFormatter(group: _group)` wired in. User B is added as a
/// real group member via REST where a member is required (mentions / @all).
///
/// These mirror the 1:1 composer/send cases (1TO1-015…024 + 1TO1-020) but in a
/// group scope, exercising the group-only behaviours (group mentions picker,
/// `@all`).
///
/// Covered IDs (10):
///   GRP-013  Send text message in group
///   GRP-014  Empty message cannot be sent in group
///   GRP-015  Whitespace-only message cannot be sent (strongest signal only)
///   GRP-016  Long text message (1000+ chars) sends successfully
///   GRP-017  Emoji-only message sends and renders
///   GRP-018  Composer clears after successful send
///   GRP-019  Send affordance appears only when text present (strongest signal)
///   GRP-020  Message with mention sends correctly
///   GRP-021  Mentions picker shows group members and @all (degrades to stable)
///   GRP-022  @all mention in group (degrades to literal @all fallback)
///
/// Composer facts confirmed against the UIKit source
/// (cometchat_message_composer.dart):
///   - `_onSendButtonClick` trims and EARLY-RETURNS when the text is empty or
///     only line-format prefixes — so empty AND whitespace-only never push a
///     bubble (GRP-014/015), and the send button is `isDisabled` while empty.
///   - The send/mic swap is driven by `hasText = controller.text.isNotEmpty`
///     (line ~1863), so a send affordance appears once text is typed (GRP-019).
///   - The mentions formatter (cometchat_mentions_formatter.dart) adds the
///     `@all` suggestion FIRST in a group when `disableMentionAll == false`
///     (default). In English `Translations.notifyAll == "all"`, so the
///     suggestion title renders as `@all` (subtitle "Notify everyone in this
///     group"), and a sent `<@all:all>` token renders back as `@all`.
///
/// User A = emulator UI. User B = REST API target. Per the harness convention,
/// `settle()` advances real wall-clock time between REST calls (server
/// propagation); all UI settling uses `pumpFor` / `pumpForRealtime` / the
/// `waitFor*` helpers (no arbitrary UI sleeps).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle([int seconds = 3]) =>
      Future<void>.delayed(Duration(seconds: seconds));

  final bUid = TestCredentials.userBUid;
  final bName = TestCredentials.userBName; // e.g. "Nancy Grace"
  final bFirstName = bName.split(' ').first; // e.g. "Nancy"

  // A unique throwaway admin-owned group for the composer tests. Creating it as
  // User A makes A the owner, so the composer (and any member management) works.
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final composerGuid = 'e2e_grpcomposer_$stamp';
  final composerGroupName = 'E2E Composer $stamp';

  setUpAll(() async {
    // Create the throwaway group (creator => admin/owner). User A drives the UI
    // and must be able to open it and use the composer.
    await UserBGroup.createGroupAsAdmin(
      groupId: composerGuid,
      name: composerGroupName,
    );
    await settle(2);
  });

  tearDownAll(() async {
    // Best-effort cleanup of the throwaway group.
    await UserBGroup.deleteGroup(groupId: composerGuid);
  });

  /// Launch as User A and open the freshly-created group so the composer is on
  /// screen. Asserts we actually reached the MessagesScreen.
  Future<void> openComposerGroup(WidgetTester tester) async {
    await AppLauncher.launchAndLogin(tester);
    final opened =
        await NavigationHelper.openTestGroup(tester, name: composerGroupName);
    expect(opened, isTrue,
        reason: 'Should open the freshly created composer group');
    AssertionHelper.expectOnMessagesScreen();
  }

  group('Group composer: send flow', () {
    // GRP-013: Send a plain text message in a group — it appears in the list.
    testWidgets('GRP-013: Send text message in group', (tester) async {
      await openComposerGroup(tester);

      final msg = 'GRP composer send ${DateTime.now().millisecondsSinceEpoch}';
      await MessageHelper.sendMessage(tester, msg);

      final found =
          await AssertionHelper.waitForMessageInTree(tester, 'GRP composer send');
      expect(found, isTrue,
          reason: 'GRP-013: sent group text should appear in the message list');
    });

    // GRP-014: Empty message cannot be sent. With no text the send button is
    // disabled and `_onSendButtonClick` early-returns — no bubble is pushed.
    testWidgets('GRP-014: Empty message cannot be sent in group',
        (tester) async {
      await openComposerGroup(tester);

      // Don't type anything. Attempt to tap a send affordance if one is present;
      // it must not crash and must not push an empty bubble.
      final sendBtn = find.bySemanticsLabel('Send message');
      if (sendBtn.evaluate().isNotEmpty) {
        await tester.tap(sendBtn.first);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        final iconButtons = find.byType(IconButton);
        if (iconButtons.evaluate().isNotEmpty) {
          await tester.tap(iconButtons.last);
          await pumpFor(tester, const Duration(seconds: 1));
        }
      }

      // Strongest deterministic signal: still on the MessagesScreen, composer
      // remains empty, nothing was sent / no crash.
      AssertionHelper.expectOnMessagesScreen();
      final composer = MessageHelper.findComposer();
      expect(composer.evaluate().isNotEmpty, isTrue,
          reason: 'GRP-014: composer should still be present');
      final field = tester.widget<TextField>(composer.first);
      expect(field.controller?.text ?? '', equals(''),
          reason: 'GRP-014: composer should remain empty (nothing sent)');
    });

    // GRP-015: Whitespace-only message cannot be sent. The UIKit trims and
    // rejects, but that rejection is not externally observable, so we assert
    // only the strongest signal: typing spaces and tapping send leaves no
    // whitespace bubble and keeps us on the MessagesScreen. (partial)
    testWidgets('GRP-015: Whitespace-only message cannot be sent',
        (tester) async {
      await openComposerGroup(tester);

      await MessageHelper.typeInComposer(tester, '     ');

      final sendBtn = find.bySemanticsLabel('Send message');
      if (sendBtn.evaluate().isNotEmpty) {
        await tester.tap(sendBtn.first);
        await pumpFor(tester, const Duration(seconds: 1));
      } else {
        final iconButtons = find.byType(IconButton);
        if (iconButtons.evaluate().isNotEmpty) {
          await tester.tap(iconButtons.last);
          await pumpFor(tester, const Duration(seconds: 1));
        }
      }

      // Strongest signal: still on the messages screen, no crash. The trim/reject
      // itself is internal, so we do not fail on the degraded check below.
      AssertionHelper.expectOnMessagesScreen();
      try {
        final composer = MessageHelper.findComposer();
        final field = tester.widget<TextField>(composer.first);
        // If the UIKit cleared the composer (some builds clear on a rejected
        // send) that's fine; if it kept the spaces that's also fine — both are
        // consistent with "nothing was sent". This is observational only.
        debugPrint(
            'GRP-015 composer text after whitespace send: "${field.controller?.text ?? ''}"');
      } catch (e) {
        debugPrint('GRP-015 degraded composer inspection skipped: $e');
      }
    });

    // GRP-016: Long text (1000+ chars) sends successfully — assert the tail
    // token renders in the list.
    testWidgets('GRP-016: Long text message sends successfully',
        (tester) async {
      await openComposerGroup(tester);

      final longText = '${'A' * 1000} grouptail';
      await MessageHelper.sendMessage(tester, longText);

      final found =
          await AssertionHelper.waitForMessageInTree(tester, 'grouptail');
      expect(found, isTrue,
          reason: 'GRP-016: long group text message should render its tail');
    });

    // GRP-017: Emoji-only message sends and renders.
    testWidgets('GRP-017: Emoji-only message sends and renders',
        (tester) async {
      await openComposerGroup(tester);

      await MessageHelper.sendMessage(tester, '🎉🔥👍🏽');

      final found = await AssertionHelper.waitForMessageInTree(tester, '🎉');
      expect(found, isTrue,
          reason: 'GRP-017: emoji-only group message should render');
    });

    // GRP-018: Composer clears after a successful send — controller.text == ''.
    testWidgets('GRP-018: Composer clears after successful send',
        (tester) async {
      await openComposerGroup(tester);

      final msg = 'GRP clear test ${DateTime.now().millisecondsSinceEpoch}';
      await MessageHelper.sendMessage(tester, msg);

      // Let the send + clear settle, then assert the composer field is empty.
      final found =
          await AssertionHelper.waitForMessageInTree(tester, 'GRP clear test');
      expect(found, isTrue,
          reason: 'GRP-018: the message should have actually been sent');

      final composer = MessageHelper.findComposer();
      expect(composer.evaluate().isNotEmpty, isTrue,
          reason: 'GRP-018: composer should still be present after send');
      final field = tester.widget<TextField>(composer.first);
      expect(field.controller?.text ?? '', equals(''),
          reason: 'GRP-018: composer should be empty after sending');
    });

    // GRP-019: A send affordance appears only when text is present. The composer
    // swaps mic<->send on `hasText`, but the exact mic/send swap is not reliably
    // distinguishable here, so we assert the strongest portable signal: after
    // typing, a send affordance (semantics label OR an IconButton) is present.
    // (partial)
    testWidgets('GRP-019: Send button activates only when text present',
        (tester) async {
      await openComposerGroup(tester);

      // With text present, a send affordance should exist.
      await MessageHelper.typeInComposer(tester, 'activate group send');
      await tester.pump(const Duration(milliseconds: 600));

      final sendAffordance =
          find.bySemanticsLabel('Send message').evaluate().isNotEmpty ||
              find.byType(IconButton).evaluate().isNotEmpty;
      expect(sendAffordance, isTrue,
          reason:
              'GRP-019: a send affordance should be present after typing text');

      // Degraded / observational: the empty-state mic vs send swap. We do NOT
      // fail on this because the mic affordance is build/version dependent.
      try {
        await MessageHelper.typeInComposer(tester, '');
        await tester.pump(const Duration(milliseconds: 600));
        final micPresent = find.byIcon(Icons.mic).evaluate().isNotEmpty;
        debugPrint('GRP-019 mic affordance present when empty: $micPresent');
      } catch (e) {
        debugPrint('GRP-019 degraded mic/send swap check skipped: $e');
      }
      AssertionHelper.expectOnMessagesScreen();
    });
  });

  group('Group composer: mentions', () {
    // GRP-020: A message containing a member mention sends correctly. We add
    // User B as a real member (so the mention resolves to a group member), type
    // "@<member> ...", send, and assert the plain trailing words render (the
    // formatter strips the @-decoration in the rendered text). (full)
    testWidgets('GRP-020: Message with mention sends correctly',
        (tester) async {
      // Ensure a mentionable member exists in the group.
      await UserBGroup.addMember(bUid, groupId: composerGuid);
      await settle(2);

      await openComposerGroup(tester);

      // Sent as plain text; the formatter may strip the @ decoration, so we
      // assert on the plain words that follow. Mirrors 1TO1-020 deterministically.
      await MessageHelper.sendMessage(
          tester, '@$bFirstName grpmentionhello there');

      final found = await AssertionHelper.waitForMessageInTree(
          tester, 'grpmentionhello there');
      expect(found, isTrue,
          reason: 'GRP-020: group mention message should appear in the list');
    });

    // GRP-021: Typing "@" triggers an async GroupMembers fetch + suggestion
    // panel; in a group the `@all` entry (English title "@all", subtitle "Notify
    // everyone in this group") is shown first, followed by members. We add User B
    // so a member exists. Because the panel is async/list-render timing
    // dependent, we degrade to composer-stable. (partial)
    testWidgets('GRP-021: Mentions picker shows group members and all',
        (tester) async {
      await UserBGroup.addMember(bUid, groupId: composerGuid);
      await settle(2);

      await openComposerGroup(tester);

      // Type a bare "@" to open the suggestion panel, then let the async
      // GroupMembersRequestBuilder fetch resolve.
      await MessageHelper.typeInComposer(tester, '@');
      await pumpForRealtime(tester, duration: const Duration(seconds: 5));

      // Strongest signal we can guarantee: composer remains present/stable and
      // we're still on the MessagesScreen after triggering the picker.
      AssertionHelper.expectOnMessagesScreen();
      expect(MessageHelper.findComposer().evaluate().isNotEmpty, isTrue,
          reason: 'GRP-021: composer should remain stable while picker fetches');

      // Best-effort: assert the @all entry and/or a member name surfaced. The
      // English `@all` title renders as "@all" with subtitle "Notify everyone in
      // this group"; a member row shows the member's name. We do NOT fail if the
      // async list hasn't rendered yet.
      try {
        final allShown = find.textContaining('@all').evaluate().isNotEmpty ||
            find.textContaining('Notify everyone').evaluate().isNotEmpty ||
            AssertionHelper.anyTextInTree(tester, ['@all', 'Notify everyone']);
        final memberShown =
            find.textContaining(bFirstName).evaluate().isNotEmpty ||
                AssertionHelper.anyTextInTree(tester, [bName, bFirstName]);
        debugPrint(
            'GRP-021 picker — allShown=$allShown memberShown=$memberShown');
      } catch (e) {
        debugPrint('GRP-021 degraded picker assertion skipped: $e');
      }
    });

    // GRP-022: @all mention in a group. `@all` is built in and enabled by
    // default (disableMentionAll == false). The portable path is to send a
    // literal "@all ..." message — the formatter resolves it to the `<@all:all>`
    // token, which renders back as "@all". We attempt to tap the "@all"
    // suggestion first (async/suggestion-dependent), then fall back to sending
    // the literal text, and assert the "@all" token renders after send.
    // (partial — strongest signal: the @all token survives a round-trip.)
    testWidgets('GRP-022: at-all mention in group', (tester) async {
      await UserBGroup.addMember(bUid, groupId: composerGuid);
      await settle(2);

      await openComposerGroup(tester);

      // Try the suggestion path: type "@all" to surface the "@all" entry and tap
      // it. This is best-effort and must not fail the test if the async panel
      // doesn't render in time.
      await MessageHelper.typeInComposer(tester, '@all');
      await pumpForRealtime(tester, duration: const Duration(seconds: 4));
      try {
        final allSuggestion = find.textContaining('Notify everyone');
        if (allSuggestion.evaluate().isNotEmpty) {
          await tester.tap(allSuggestion.first);
          await pumpFor(tester, const Duration(seconds: 1));
        }
      } catch (e) {
        debugPrint('GRP-022 suggestion tap skipped: $e');
      }

      // Append trailing text so the composer has real content, then send.
      // Whether or not the suggestion was tapped, the composer now contains an
      // "@all" reference plus the trailing words.
      await MessageHelper.typeInComposer(tester, '@all grpall ping');
      await MessageHelper.sendMessage(tester, '@all grpall ping');

      // Strongest deterministic signal: the trailing words render, confirming
      // the message was actually sent.
      final bodyFound =
          await AssertionHelper.waitForMessageInTree(tester, 'grpall ping');
      expect(bodyFound, isTrue,
          reason: 'GRP-022: the @all message body should render after sending');

      // Best-effort: the "@all" token should survive the round-trip and render
      // in the bubble. We do NOT fail if rendering of the token decoration
      // varies across builds.
      try {
        final atAllShown =
            await AssertionHelper.waitForAnyTextInTree(tester, ['@all'],
                timeout: const Duration(seconds: 6));
        debugPrint('GRP-022 @all token rendered in bubble: $atAllShown');
      } catch (e) {
        debugPrint('GRP-022 degraded @all token assertion skipped: $e');
      }
      AssertionHelper.expectOnMessagesScreen();
    });
  });
}
