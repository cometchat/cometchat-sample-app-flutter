import '../../../cometchat_uikit_shared.dart';

///Listener class for [CometChatConversations]
mixin CometChatConversationEventListener implements UIEventHandler {
  ///[ccConversationDeleted] is used to inform the listeners
  ///when the logged-in user deletes a conversation
  void ccConversationDeleted(Conversation conversation) {}

  ///[ccUpdateConversation] is used to inform the listeners
  ///when a conversation is updated (e.g., mark as unread)
  void ccUpdateConversation(Conversation conversation) {}
}
