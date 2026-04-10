import '../../../../cometchat_uikit_shared.dart';

mixin CometChatConversationsControllerProtocol
    implements CometChatListProtocol<Conversation> {
  updateUserStatus(User user, String status);

  deleteConversation(Conversation conversation);

  resetUnreadCount(BaseMessage message);

  updateLastMessage(BaseMessage message);

  updateGroup(Group group);

  removeGroup(String guid);

  updateLastMessageOnEdited(BaseMessage message);

  refreshSingleConversation(BaseMessage message, bool isActionMessage,
      {bool? remove});

  ///Update the conversation with new conversation Object matched according to conversation id ,  if not matched inserted at top
  updateConversation(Conversation conversation);

  setReceipts(MessageReceipt receipt);

  setTypingIndicator(TypingIndicator typingIndicator, bool isTypingStarted);

  void deleteConversationFromIndex(int index);

  playNotificationSound(BaseMessage message);

  bool getHideThreadIndicator(Conversation conversation);

  bool getHideReceipt(Conversation conversation, bool? disableReadReceipt);
}
