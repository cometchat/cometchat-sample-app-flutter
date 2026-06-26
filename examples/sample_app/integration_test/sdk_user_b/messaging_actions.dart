import '../config/test_credentials.dart';
import 'sdk_user_b.dart';

/// User B messaging actions via CometChat REST API.
///
/// All methods trigger real WebSocket events that User A's app receives:
///   - sendTextToA → onTextMessageReceived on A
///   - editMessage → onMessageEdited on A
///   - deleteMessage → onMessageDeleted on A
///   - sendMediaMessage → onMediaMessageReceived on A
class UserBMessaging {
  UserBMessaging._();

  /// Send a text message from User B → User A.
  /// Returns the message ID.
  ///
  /// Triggers: onTextMessageReceived on A's SDK listener.
  static Future<int> sendTextToA(String text) async {
    final data = await SdkUserB.post(
      '/messages',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'category': 'message',
        'type': 'text',
        'data': {'text': text},
      },
    );

    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send a text message from User B → a group.
  /// Returns the message ID.
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

  /// Send multiple messages from B → A in quick succession.
  /// Returns list of message IDs in order.
  ///
  /// Useful for: RT-MSG-003 (ordering), RT-MSG-013 (unread count),
  /// RT-EDGE-004 (burst), pagination tests.
  static Future<List<int>> sendMultipleToA(
    int count, {
    String prefix = 'E2E msg',
    Duration delayBetween = const Duration(milliseconds: 200),
  }) async {
    final ids = <int>[];
    for (var i = 1; i <= count; i++) {
      final id = await sendTextToA('$prefix #$i');
      ids.add(id);
      if (i < count) {
        await Future<void>.delayed(delayBetween);
      }
    }
    return ids;
  }

  /// Edit a previously sent message.
  /// Returns updated message data.
  ///
  /// Triggers: onMessageEdited on A's SDK listener.
  static Future<void> editMessage(int messageId, String newText) async {
    await SdkUserB.put(
      '/messages/$messageId',
      body: {
        'data': {'text': newText},
      },
    );
  }

  /// Delete a message sent by User B.
  ///
  /// Triggers: onMessageDeleted on A's SDK listener.
  static Future<void> deleteMessage(int messageId) async {
    await SdkUserB.delete('/messages/$messageId');
  }

  /// Send an image (media) message from B → A.
  /// [imageUrl] should be a publicly accessible URL.
  /// Returns the message ID.
  ///
  /// Triggers: onMediaMessageReceived on A's SDK listener.
  static Future<int> sendImageToA(String imageUrl) async {
    final data = await SdkUserB.post(
      '/messages',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'category': 'message',
        'type': 'image',
        'data': {
          'url': imageUrl,
          'attachments': [
            {
              'url': imageUrl,
              'mimeType': 'image/png',
              'name': 'test_image.png',
              'extension': 'png',
            }
          ],
        },
      },
    );

    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send a custom message from B → A.
  /// Returns the message ID.
  ///
  /// Triggers: onCustomMessageReceived on A's SDK listener.
  static Future<int> sendCustomMessageToA({
    required String subType,
    required Map<String, dynamic> customData,
  }) async {
    final data = await SdkUserB.post(
      '/messages',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'category': 'custom',
        'type': subType,
        'data': {'customData': customData},
      },
    );

    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send a message AS User A (to User B) via REST — simulates User A sending
  /// from a *different device*. User A's app on the emulator should sync and
  /// display this as its own outgoing message (RT-MSG-009).
  /// Returns the message ID.
  static Future<int> sendTextAsAFromOtherDevice(String text) async {
    final data = await SdkUserB.post(
      '/messages',
      asUserA: true,
      body: {
        'receiver': TestCredentials.userBUid,
        'receiverType': 'user',
        'category': 'message',
        'type': 'text',
        'data': {'text': text},
      },
    );
    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Fetch the latest message that User A SENT to User B, as seen by B.
  ///
  /// This is needed for read-receipt tests: User A sends via the UI (so the
  /// test has no message ID), then B marks that message delivered/read. We
  /// query the B↔A conversation and return the highest-id message whose sender
  /// is User A.
  ///
  /// Returns null if the conversation can't be read or has no message from A
  /// (callers treat this as non-fatal, consistent with receipt test style).
  static Future<int?> fetchLatestMessageIdFromA() async {
    try {
      final data = await SdkUserB.get(
        '/messages',
        query: {
          'uid': TestCredentials.userAUid,
          'per_page': '50',
          'category': 'message',
          'type': 'text',
        },
      );

      final list = (data['data'] as List?) ?? const [];
      int? best;
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        if (m['sender'] != TestCredentials.userAUid) continue;
        final idVal = m['id'];
        final id = idVal is int ? idVal : int.tryParse(idVal.toString());
        if (id == null) continue;
        if (best == null || id > best) best = id;
      }
      return best;
    } catch (_) {
      // Non-fatal — receipt tests fall back to UI-stability assertions.
      return null;
    }
  }

  /// Ensure a conversation exists between B and A by sending a seed message.
  /// Returns the message ID.
  static Future<int> ensureConversationExists() async {
    return await sendTextToA(
      'E2E seed ${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Send a generic media message (video / audio / file / image) from B → A.
  ///
  /// [type] — CometChat media type: 'image', 'video', 'audio', or 'file'.
  /// [url] — a publicly accessible URL to the media.
  /// [mimeType] / [name] / [extension] — attachment metadata.
  /// Returns the message ID.
  ///
  /// Triggers: onMediaMessageReceived on A's SDK listener → media bubble in UI.
  static Future<int> sendMediaToA({
    required String type,
    required String url,
    required String mimeType,
    required String name,
    required String extension,
  }) async {
    final data = await SdkUserB.post(
      '/messages',
      body: {
        'receiver': TestCredentials.userAUid,
        'receiverType': 'user',
        'category': 'message',
        'type': type,
        'data': {
          'url': url,
          'attachments': [
            {
              'url': url,
              'mimeType': mimeType,
              'name': name,
              'extension': extension,
            }
          ],
        },
      },
    );
    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send a video message from B → A. Returns the message ID.
  static Future<int> sendVideoToA([
    String url =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  ]) =>
      sendMediaToA(
        type: 'video',
        url: url,
        mimeType: 'video/mp4',
        name: 'test_video.mp4',
        extension: 'mp4',
      );

  /// Send an audio message from B → A. Returns the message ID.
  static Future<int> sendAudioToA([
    String url =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  ]) =>
      sendMediaToA(
        type: 'audio',
        url: url,
        mimeType: 'audio/mpeg',
        name: 'test_audio.mp3',
        extension: 'mp3',
      );

  /// Send a file/document (PDF) message from B → A. Returns the message ID.
  static Future<int> sendFileToA({
    String url =
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    String name = 'test_document.pdf',
    String mimeType = 'application/pdf',
    String extension = 'pdf',
  }) =>
      sendMediaToA(
        type: 'file',
        url: url,
        mimeType: mimeType,
        name: name,
        extension: extension,
      );
}
