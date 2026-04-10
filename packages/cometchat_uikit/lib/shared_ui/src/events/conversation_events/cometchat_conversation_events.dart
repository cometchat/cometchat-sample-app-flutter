import '../../../cometchat_uikit_shared.dart';

///Event emitting class for [CometchatConversation]
class CometChatConversationEvents {
  static Map<String, CometChatConversationEventListener>
      conversationListListener = {};

  static addConversationListListener(
      String listenerId, CometChatConversationEventListener listenerClass) {
    conversationListListener[listenerId] = listenerClass;
  }

  static removeConversationListListener(String listenerId) {
    conversationListListener.remove(listenerId);
  }

  static ccConversationDeleted(Conversation conversation) {
    conversationListListener.forEach((key, value) {
      value.ccConversationDeleted(conversation);
    });
  }

  static ccUpdateConversation(Conversation conversation) {
    conversationListListener.forEach((key, value) {
      value.ccUpdateConversation(conversation);
    });
  }
}
