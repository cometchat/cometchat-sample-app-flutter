import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Utility for validating that a quoted message belongs to the current conversation.
///
/// Prevents replying to a message from a different conversation when the user
/// switches chats while a reply preview is still showing.
class ReplyUtils {
  /// Returns the quoted message's ID if it belongs to the current conversation,
  /// or `-1` if invalid (wrong conversation or null).
  ///
  /// - [quotedMessage]: The message being replied to.
  /// - [user]: The current 1:1 chat user (null for group chats).
  /// - [group]: The current group (null for 1:1 chats).
  static int getQuotedMessageId({
    BaseMessage? quotedMessage,
    User? user,
    Group? group,
  }) {
    if (quotedMessage == null || quotedMessage.id <= 0) return -1;

    // 1:1 chat — check if quotedMessage's conversationId contains the user's uid
    if (user != null && quotedMessage.receiver is User) {
      final conversationId = quotedMessage.conversationId;
      if (conversationId == null || conversationId.isEmpty) return -1;
      final ids = conversationId.split('_');
      return ids.contains(user.uid) ? quotedMessage.id : -1;
    }

    // Group chat — check if quotedMessage's receiver group guid matches
    if (group != null && quotedMessage.receiver is Group) {
      final receiver = quotedMessage.receiver as Group;
      return receiver.guid == group.guid ? quotedMessage.id : -1;
    }

    return -1;
  }
}
