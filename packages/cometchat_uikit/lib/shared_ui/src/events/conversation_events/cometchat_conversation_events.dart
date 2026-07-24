import '../../../cometchat_uikit_shared.dart';

///Event emitting class for `CometchatConversation`
class CometChatConversationEvents {
  static Map<String, CometChatConversationEventListener>
  conversationListListener = {};

  static void addConversationListListener(
    String listenerId,
    CometChatConversationEventListener listenerClass,
  ) {
    conversationListListener[listenerId] = listenerClass;
  }

  static void removeConversationListListener(String listenerId) {
    conversationListListener.remove(listenerId);
  }

  static void ccConversationDeleted(Conversation conversation) {
    conversationListListener.forEach((key, value) {
      value.ccConversationDeleted(conversation);
    });
  }

  static void ccUpdateConversation(Conversation conversation) {
    conversationListListener.forEach((key, value) {
      value.ccUpdateConversation(conversation);
    });
  }
}
