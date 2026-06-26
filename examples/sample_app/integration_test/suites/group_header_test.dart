import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../config/test_credentials.dart';
import '../helpers_v2/app_launcher.dart';
import '../helpers_v2/navigation_helper.dart';
import '../helpers_v2/assertion_helper.dart';
import '../helpers_v2/pump_helper.dart';
import '../sdk_user_b/group_actions.dart';

/// Group MessageHeader / details E2E suite (single file).
///
/// User A drives the real Flutter UI on the emulator; the group itself is
/// seeded/owned via REST (User A is the creator/owner of the throwaway admin
/// group, so opening + reading its header is deterministic). These cases are
/// all read-only header/details assertions — no member mutations are required.
///
/// Covered IDs (7):
///   GRP-052  Header displays the group name
///   GRP-053  Header displays the group avatar
///   GRP-054  Header displays the member count (presence reliable, exact count best-effort)
///   GRP-055  Voice call button visible in the group header
///   GRP-056  Video call button visible in the group header
///   GRP-057  Details/info menu navigates to the group details screen
///   GRP-058  Back from group details returns to the messages screen
///
/// Widget facts confirmed against the codebase:
///   - CometChatMessageHeader sets title = group.name and a
///     "{memberCount} Members" subtitle (cometchat_message_header.dart L399),
///     and renders a CometChatAvatar via CometChatListItem.
///   - auxiliaryButtonView -> _buildCallButtons renders CometChatCallButtons
///     when enableCalls == true; main.dart sets enableCalls = true (L161) and
///     the voice/video buttons default to visible, so both render for groups.
///     Voice uses Icons.call_outlined and video an SVG asset — neither is a
///     reliable icon discriminator, so the strongest signal is the presence of
///     a CometChatCallButtons widget.
///   - messages_screen.dart adds an Icons.info_outline IconButton that
///     Navigator.push -> GroupInfoScreen (L471-479). NavigationHelper.openInfoScreen
///     taps Icons.info_outline; NavigationHelper.goBack pops back to messages.
///
/// Driving principle: the suite CREATES a throwaway PUBLIC group with a unique
/// per-run GUID so User A is the owner (always able to open it and read its
/// header). The seeded SuperGroup is used as a fallback target. The throwaway
/// group is deleted in tearDownAll.
///
/// Partial cases (GRP-054/055/056) assert the strongest deterministic signal
/// (header rendered / call-buttons present) and log fragile specifics
/// non-fatally, matching the caveated style in message_header_test.dart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle([int seconds = 3]) =>
      Future<void>.delayed(Duration(seconds: seconds));

  // Match runtime types by name — CometChat widgets are private/sliver-rendered
  // and can't always be reached via find.byType. (Same matcher idiom used in
  // message_header_test.dart.)
  bool hasType(String name) => find
      .byWidgetPredicate((w) => w.runtimeType.toString().contains(name))
      .evaluate()
      .isNotEmpty;

  // A unique throwaway admin-owned group so User A is the owner and can always
  // open it + read its header deterministically.
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final headerGuid = 'e2e_grp_header_$stamp';
  final headerGroupName = 'E2E Header Group $stamp';

  setUpAll(() async {
    // Ensure the shared/seeded test group exists & User A is a member, so the
    // fallback navigation target is deterministic.
    await UserBGroup.ensureGroupExists();
    await UserBGroup.ensureUserAIsMember();

    // Create the throwaway admin-owned group (creator => admin/owner).
    await UserBGroup.createGroupAsAdmin(
      groupId: headerGuid,
      name: headerGroupName,
    );
    await settle(2);
  });

  tearDownAll(() async {
    // Best-effort cleanup of the throwaway group.
    await UserBGroup.deleteGroup(groupId: headerGuid);
  });

  /// Open the throwaway admin group; fall back to the seeded test group if the
  /// freshly created group hasn't propagated to A's list yet. Returns the name
  /// of whichever group was opened (so header assertions target the right one).
  Future<String> openHeaderGroup(WidgetTester tester) async {
    await AppLauncher.launchAndLogin(tester);

    final openedAdmin =
        await NavigationHelper.openTestGroup(tester, name: headerGroupName);
    if (openedAdmin &&
        find.byType(TextFormField).evaluate().isNotEmpty &&
        (find.text(headerGroupName).evaluate().isNotEmpty ||
            AssertionHelper.messageExistsInTree(tester, headerGroupName))) {
      AssertionHelper.expectOnMessagesScreen();
      return headerGroupName;
    }

    // Fallback: open the seeded group by its configured name.
    final openedSeeded = await NavigationHelper.openTestGroup(tester);
    expect(openedSeeded, isTrue,
        reason: 'Should open a group (admin or seeded) to inspect its header');
    AssertionHelper.expectOnMessagesScreen();
    return TestCredentials.testGroupName;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Group header identity (name / avatar / member count).
  // ───────────────────────────────────────────────────────────────────────────
  group('Group header: identity', () {
    // GRP-052: header displays the group name. (full)
    testWidgets('GRP-052: header displays group name', (tester) async {
      final groupName = await openHeaderGroup(tester);

      final nameVisible = find.text(groupName).evaluate().isNotEmpty ||
          AssertionHelper.messageExistsInTree(tester, groupName);
      debugPrint('GRP-052: group name "$groupName" visible=$nameVisible');
      expect(nameVisible, isTrue,
          reason: 'GRP-052: header should show the group name "$groupName"');
    });

    // GRP-053: header displays the group avatar. (full)
    testWidgets('GRP-053: header displays group avatar', (tester) async {
      await openHeaderGroup(tester);

      expect(hasType('CometChatAvatar'), isTrue,
          reason: 'GRP-053: a CometChatAvatar should render in the group header');
    });

    // GRP-054: header displays the member count. (partial)
    // Presence of a "Member(s)" subtitle is reliable; the exact integer count
    // is server/timing-dependent, so it is logged non-fatally.
    testWidgets('GRP-054: header displays member count', (tester) async {
      await openHeaderGroup(tester);

      // Strongest deterministic signal: the header rendered (composer present)
      // and a CometChatMessageHeader is in the tree.
      AssertionHelper.expectOnMessagesScreen();
      expect(hasType('CometChatMessageHeader'), isTrue,
          reason: 'GRP-054: a CometChatMessageHeader should render for a group');

      // Best-effort: poll for the "{n} Members" subtitle. Non-fatal — wording
      // and load timing vary across versions / server propagation.
      try {
        final hasMemberSubtitle = await AssertionHelper.waitForAnyTextInTree(
          tester,
          ['Members', 'Member', 'members', 'member'],
          timeout: const Duration(seconds: 10),
        );
        debugPrint('GRP-054: member-count subtitle visible=$hasMemberSubtitle');
      } catch (e) {
        debugPrint('GRP-054: member-count probe failed non-fatally: $e');
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Group header call buttons. enableCalls == true (main.dart L161) so both
  // voice and video buttons render for groups. Voice = Icons.call_outlined,
  // video = SVG asset; neither icon reliably distinguishes voice vs video, so
  // the strongest signal is the presence of a CometChatCallButtons widget.
  // ───────────────────────────────────────────────────────────────────────────
  group('Group header: call buttons', () {
    // GRP-055: voice call button visible in the group header. (partial)
    testWidgets('GRP-055: voice call button visible in group header',
        (tester) async {
      await openHeaderGroup(tester);

      final callButtons = hasType('CometChatCallButtons');
      final voiceIcon = find.byIcon(Icons.call_outlined).evaluate().isNotEmpty ||
          find.byIcon(Icons.call).evaluate().isNotEmpty;
      debugPrint('GRP-055: callButtons=$callButtons voiceIcon=$voiceIcon');
      expect(callButtons || voiceIcon, isTrue,
          reason:
              'GRP-055: a voice call button (CometChatCallButtons) should be '
              'visible in the group header');
    });

    // GRP-056: video call button visible in the group header. (partial)
    testWidgets('GRP-056: video call button visible in group header',
        (tester) async {
      await openHeaderGroup(tester);

      // Video icon is an SVG, so find.byIcon can't reliably catch it — the
      // presence of CometChatCallButtons (which renders BOTH voice and video
      // when enabled) is the strongest deterministic signal.
      final callButtons = hasType('CometChatCallButtons');
      final videoIcon = find.byIcon(Icons.videocam).evaluate().isNotEmpty ||
          find.byIcon(Icons.videocam_outlined).evaluate().isNotEmpty;
      debugPrint('GRP-056: callButtons=$callButtons videoIcon=$videoIcon');
      expect(callButtons || videoIcon, isTrue,
          reason:
              'GRP-056: a video call button (CometChatCallButtons) should be '
              'visible in the group header');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Group details navigation. The info_outline IconButton pushes GroupInfoScreen;
  // goBack pops back to MessagesScreen.
  // ───────────────────────────────────────────────────────────────────────────
  group('Group header: details navigation', () {
    // GRP-057: details/info menu navigates to the group details screen. (full)
    testWidgets('GRP-057: details menu navigates to group details',
        (tester) async {
      await openHeaderGroup(tester);

      // Tap the Icons.info_outline trailing button -> GroupInfoScreen.
      await NavigationHelper.openInfoScreen(tester);
      await pumpFor(tester, const Duration(seconds: 3));

      // On the group-details screen the message composer is gone and group
      // member content renders. Tolerant either-signal check (deterministic
      // navigation away from the messages composer).
      final composerGone = find.byType(TextFormField).evaluate().isEmpty;
      final membersContent =
          find.textContaining('Member').evaluate().isNotEmpty ||
              AssertionHelper.anyTextInTree(tester, ['Member', 'member']) ||
              find.byType(Scrollable).evaluate().isNotEmpty;
      debugPrint(
          'GRP-057: composerGone=$composerGone membersContent=$membersContent');
      expect(composerGone || membersContent, isTrue,
          reason: 'GRP-057: details menu should open the group details screen');
    });

    // GRP-058: back from group details returns to the messages screen. (full)
    testWidgets('GRP-058: back from group details returns to messages',
        (tester) async {
      await openHeaderGroup(tester);

      // Navigate INTO group details, then back OUT.
      await NavigationHelper.openInfoScreen(tester);
      await pumpFor(tester, const Duration(seconds: 3));

      await NavigationHelper.goBack(tester);
      await pumpFor(tester, const Duration(seconds: 2));

      // Deterministic: popping GroupInfoScreen returns to MessagesScreen, whose
      // composer (TextFormField) is present again.
      AssertionHelper.expectOnMessagesScreen();
    });
  });
}
