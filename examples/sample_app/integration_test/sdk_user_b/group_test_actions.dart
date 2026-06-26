import 'sdk_user_b.dart';
import '../config/test_credentials.dart';

/// Extra REST helpers shared by the GROUP E2E suites (GRP-*, RT-GRP-*).
///
/// Kept in one place so each per-suite test file doesn't re-implement REST
/// plumbing. All calls go through [SdkUserB]'s generic get/post/put/delete,
/// which attach the `onBehalfOf` header (User A when `asUserA: true`, else
/// User B). Mirrors the existing [UserBGroup] / messaging media-sender shapes.
///
/// Capability note: [SdkUserB] only supports acting on behalf of User A or
/// User B (no arbitrary third UID), so multi-sender / high-count scenarios
/// degrade to the strongest deterministic signal, as documented per test.
class GroupTestActions {
  GroupTestActions._();

  // Reachable sample asset URLs. The message bubble renders from the message
  // metadata (filename/url), so assertions on bubble presence + filename do
  // not require the asset to actually download.
  static const String sampleImageUrl =
      'https://assets.cometchat.io/sampleapp/v2/users/cometchat-uid-2.webp';
  static const String sampleVideoUrl =
      'https://assets.cometchat.io/sampleapp/sampledata/sample-video.mp4';
  static const String sampleAudioUrl =
      'https://assets.cometchat.io/sampleapp/sampledata/sample-audio.mp3';
  static const String samplePdfUrl =
      'https://assets.cometchat.io/sampleapp/sampledata/test_document.pdf';

  // ─── Group seeding with explicit ownership ──────────────────────────────────

  /// Create a group OWNED by User B (B is the `onBehalfOf` creator → owner).
  /// Use for tests where User A must be a NON-owner (participant/admin) or a
  /// banned/non-member, which A-created groups can't express (A is always
  /// owner there). Returns User B's scope on the new group ("admin").
  static Future<String> createGroupOwnedByB({
    required String groupId,
    required String name,
    String type = 'public',
    String? password,
  }) async {
    final body = <String, dynamic>{'guid': groupId, 'name': name, 'type': type};
    if (password != null) body['password'] = password;
    final data = await SdkUserB.post('/groups', body: body); // onBehalfOf B
    final d = data['data'] as Map<String, dynamic>? ?? const {};
    return (d['scope'] ?? '').toString();
  }

  /// Create a password-protected group OWNED by User B where User A is NOT a
  /// member — for the "join password group" tests (A opens it and must enter a
  /// password). Returns the group's scope for B.
  static Future<String> createPasswordGroupOwnedByB({
    required String groupId,
    required String name,
    required String password,
  }) =>
      createGroupOwnedByB(
          groupId: groupId, name: name, type: 'password', password: password);

  /// Add User A to a group on behalf of User B (B must be owner/admin), then
  /// optionally set A's scope (e.g. 'admin', 'moderator'). Default participant.
  static Future<void> addUserAToGroupAsB({
    required String groupId,
    String scope = 'participant',
  }) async {
    try {
      await SdkUserB.post('/groups/$groupId/members',
          body: {
            'participants': [TestCredentials.userAUid]
          });
    } catch (_) {/* maybe already a member */}
    if (scope != 'participant') {
      await SdkUserB.put('/groups/$groupId/members/${TestCredentials.userAUid}',
          body: {'scope': scope});
    }
  }

  /// Change any member's scope. Acts as User A (owner) by default; pass
  /// asUserA:false to act as User B (e.g. on a B-owned group).
  static Future<void> changeScopeOf({
    required String uid,
    required String scope,
    String? groupId,
    bool asUserA = true,
  }) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    await SdkUserB.put('/groups/$guid/members/$uid',
        asUserA: asUserA, body: {'scope': scope});
  }

  /// Ban User A from a B-owned group (acts as User B / owner). For the
  /// "A opens group after being banned → non-member banner" test.
  static Future<void> banUserAAsB({required String groupId}) async {
    await SdkUserB.post('/groups/$groupId/bannedusers/${TestCredentials.userAUid}',
        body: {});
  }

  /// Kick User A from a B-owned group (acts as User B / owner).
  static Future<void> kickUserAAsB({required String groupId}) async {
    await SdkUserB.delete('/groups/$groupId/members/${TestCredentials.userAUid}');
  }

  /// Delete any group as User B (owner of B-owned groups). Best-effort cleanup.
  static Future<void> deleteGroupAsB({required String groupId}) async {
    try {
      await SdkUserB.delete('/groups/$groupId');
    } catch (_) {}
  }

  // ─── Group media senders (User B → group) ───────────────────────────────────

  /// Send a media message from User B into a group. [type] is one of
  /// 'image' | 'video' | 'audio' | 'file'. Returns the new message id.
  static Future<int> sendMediaToGroup({
    required String type,
    required String url,
    required String mimeType,
    required String name,
    required String extension,
    String? groupId,
  }) async {
    final guid = groupId ?? TestCredentials.testGroupGuid;
    final data = await SdkUserB.post('/messages', body: {
      'receiver': guid,
      'receiverType': 'group',
      'category': 'message',
      'type': type,
      'data': {
        'url': url,
        'attachments': [
          {'url': url, 'mimeType': mimeType, 'name': name, 'extension': extension}
        ],
      },
    });
    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  static Future<int> sendImageToGroup({String? groupId}) => sendMediaToGroup(
        type: 'image',
        url: sampleImageUrl,
        mimeType: 'image/webp',
        name: 'test_image.webp',
        extension: 'webp',
        groupId: groupId,
      );

  static Future<int> sendVideoToGroup({String? groupId}) => sendMediaToGroup(
        type: 'video',
        url: sampleVideoUrl,
        mimeType: 'video/mp4',
        name: 'test_video.mp4',
        extension: 'mp4',
        groupId: groupId,
      );

  static Future<int> sendAudioToGroup({String? groupId}) => sendMediaToGroup(
        type: 'audio',
        url: sampleAudioUrl,
        mimeType: 'audio/mpeg',
        name: 'test_audio.mp3',
        extension: 'mp3',
        groupId: groupId,
      );

  static Future<int> sendPdfToGroup({String? groupId}) => sendMediaToGroup(
        type: 'file',
        url: samplePdfUrl,
        mimeType: 'application/pdf',
        name: 'test_document.pdf',
        extension: 'pdf',
        groupId: groupId,
      );
}
