import 'sdk_user_b.dart';
import '../config/test_credentials.dart';

/// User B group-related actions via REST API.
///
/// These trigger real WebSocket events for group members:
///   - joinGroup → onGroupMemberJoined
///   - leaveGroup → onGroupMemberLeft
///   - kickMember → onGroupMemberKicked
///   - banMember → onGroupMemberBanned
///   - changeMemberScope → onGroupMemberScopeChanged
///   - addMembers → onMemberAddedToGroup
class UserBGroup {
  UserBGroup._();

  // ─── Test setup / reset helpers ─────────────────────────────────────────────

  /// Ensure the test group exists (created on behalf of User A, who becomes the
  /// owner/admin). Best-effort: if the group already exists this is a no-op.
  static Future<void> ensureGroupExists({String? groupId, String? name}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    try {
      await SdkUserB.post(
        '/groups',
        asUserA: true,
        body: {
          'guid': guid,
          'name': name ?? TestCredentials.testGroupName,
          'type': 'public',
        },
      );
    } catch (_) {
      // Group most likely already exists — that's fine.
    }
  }

  /// Create a group with User A as the CREATOR. In CometChat the creator is
  /// automatically the group owner (scope "admin"), so this guarantees the test
  /// driver (User A on the emulator) has admin rights to perform member
  /// management actions (add / kick / ban / change scope / delete).
  ///
  /// Returns User A's scope on the new group (expected "admin"), so the test can
  /// assert the creator really is an admin before performing admin actions.
  static Future<String> createGroupAsAdmin({
    required String groupId,
    required String name,
    String type = 'public',
  }) async {
    final data = await SdkUserB.post(
      '/groups',
      asUserA: true,
      body: {'guid': groupId, 'name': name, 'type': type},
    );
    final d = data['data'] as Map<String, dynamic>? ?? const {};
    return (d['scope'] ?? '').toString();
  }

  /// Fetch a member's scope in a group (e.g. to verify the creator is "admin",
  /// or that a scope change to "moderator" took effect). Returns null if the
  /// member can't be read.
  static Future<String?> getMemberScope(String uid, {String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    try {
      final data = await SdkUserB.get(
        '/groups/$guid/members',
        asUserA: true,
      );
      final list = (data['data'] as List?) ?? const [];
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        if (m['uid'] == uid) return (m['scope'] ?? '').toString();
      }
    } catch (_) {}
    return null;
  }

  /// Ensure User A is a member of the group (A drives the UI and must be able
  /// to open the group conversation). Best-effort.
  static Future<void> ensureUserAIsMember({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    try {
      await SdkUserB.post(
        '/groups/$guid/members',
        asUserA: true,
        body: {},
      );
    } catch (_) {
      // Already a member.
    }
  }

  /// Remove User B from the group so join/leave tests start from a known state.
  /// Best-effort — ignores "not a member" / "banned" errors.
  static Future<void> resetUserBMembership({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    try {
      await SdkUserB.delete(
        '/groups/$guid/bannedusers/${TestCredentials.userBUid}',
        asUserA: true,
      );
    } catch (_) {}
    try {
      await SdkUserB.delete(
        '/groups/$guid/members/${TestCredentials.userBUid}',
        asUserA: true,
      );
    } catch (_) {}
  }

  /// User B joins a group.
  ///
  /// Triggers: onGroupMemberJoined for all group members.
  static Future<void> joinGroup({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.post(
      '/groups/$guid/members',
      body: {},
    );
  }

  /// User B leaves a group.
  ///
  /// Triggers: onGroupMemberLeft for all group members.
  static Future<void> leaveGroup({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.delete('/groups/$guid/members');
  }

  /// Kick User B from a group (as admin/User A).
  ///
  /// Triggers: onGroupMemberKicked for all group members.
  static Future<void> kickUserB({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.delete(
      '/groups/$guid/members/${TestCredentials.userBUid}',
      asUserA: true,
    );
  }

  /// Ban User B from a group (as admin/User A).
  ///
  /// REST shape (verified): `POST /groups/{guid}/bannedusers/{uid}` with the
  /// UID in the path and an empty body. User B must currently be a member.
  ///
  /// Triggers: onGroupMemberBanned for all group members → action "banned".
  static Future<void> banUserB({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.post(
      '/groups/$guid/bannedusers/${TestCredentials.userBUid}',
      asUserA: true,
      body: {},
    );
  }

  /// Delete the group entirely (as owner/User A). Used for test cleanup so
  /// per-run throwaway groups don't accumulate. Best-effort.
  static Future<void> deleteGroup({String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    try {
      await SdkUserB.delete('/groups/$guid', asUserA: true);
    } catch (_) {}
  }

  /// Change User B's scope/role in a group (as admin/User A).
  ///
  /// [scope] — one of: 'admin', 'moderator', 'participant'
  ///
  /// Triggers: onGroupMemberScopeChanged for all group members.
  static Future<void> changeMemberScope({
    required String scope,
    String? groupId,
  }) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.put(
      '/groups/$guid/members/${TestCredentials.userBUid}',
      asUserA: true,
      body: {'scope': scope},
    );
  }

  /// Add a member to the group (as admin/User A).
  ///
  /// Triggers: onMemberAddedToGroup for all group members.
  static Future<void> addMember(String uid, {String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.post(
      '/groups/$guid/members',
      asUserA: true,
      body: {
        'participants': [uid],
      },
    );
  }

  /// Send a text message from User B to a group.
  /// Returns message ID.
  static Future<int> sendTextToGroup(String text, {String? groupId}) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    final data = await SdkUserB.post(
      '/messages',
      body: {
        'receiver': guid,
        'receiverType': 'group',
        'category': 'message',
        'type': 'text',
        'data': {'text': text},
      },
    );

    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }
}
