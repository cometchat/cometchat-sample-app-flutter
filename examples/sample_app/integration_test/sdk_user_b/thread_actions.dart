import 'sdk_user_b.dart';
import '../config/test_credentials.dart';

/// User B thread reply actions via REST API.
///
/// Thread replies are messages with a `parentMessageId` set.
/// They trigger:
///   - onTextMessageReceived with parentMessageId on A's SDK
///   - Thread reply count update on the parent message
///   - Thread replies do NOT appear in the main message list (hideReplies filter)
class UserBThread {
  UserBThread._();

  /// Send a thread reply from User B to a specific parent message.
  /// Returns the reply message ID.
  ///
  /// Triggers:
  ///   - Reply count badge increments on parent message
  ///   - If A has the thread open, reply appears live
  ///   - Main message list does NOT show this reply
  static Future<int> sendReply({
    required int parentMessageId,
    required String text,
    String? receiverUid,
    String receiverType = 'user',
  }) async {
    final receiver = receiverUid ?? TestCredentials.userAUid;
    final data = await SdkUserB.post(
      '/messages/$parentMessageId/thread',
      body: {
        'receiver': receiver,
        'receiverType': receiverType,
        'category': 'message',
        'type': 'text',
        'data': {'text': text},
      },
    );

    final id = data['data']['id'];
    return id is int ? id : int.parse(id.toString());
  }

  /// Send multiple thread replies (for count tests).
  static Future<List<int>> sendMultipleReplies({
    required int parentMessageId,
    required int count,
    String prefix = 'Thread reply',
    String? receiverUid,
  }) async {
    final ids = <int>[];
    for (var i = 1; i <= count; i++) {
      final id = await sendReply(
        parentMessageId: parentMessageId,
        text: '$prefix #$i',
        receiverUid: receiverUid,
      );
      ids.add(id);
      if (i < count) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
    return ids;
  }
}
