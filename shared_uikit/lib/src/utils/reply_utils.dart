import '../../cometchat_uikit_shared.dart';

class ReplyUtils {
  static int? getQuotedMessageId(
      {BaseMessage? quotedMessage, User? user, Group? group}) {
    if (quotedMessage == null) return -1;

    // If replying in 1:1 chat
    if (user != null && quotedMessage.receiver is User) {
      final conversationId = quotedMessage.conversationId;
      if (conversationId == null) return -1;

      final ids = conversationId.split("_");
      final isCorrectConversation = ids.contains(user.uid);

      return isCorrectConversation ? quotedMessage.id : -1;
    }

    // If replying in group chat
    if (group != null && quotedMessage.receiver is Group) {
      final receiver = quotedMessage.receiver as Group;
      return receiver.guid == group.guid ? quotedMessage.id : -1;
    }

    return -1;
  }
}
