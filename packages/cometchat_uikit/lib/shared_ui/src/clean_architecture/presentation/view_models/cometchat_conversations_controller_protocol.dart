import '../../../../cometchat_uikit_shared.dart';

mixin CometChatConversationsControllerProtocol
    implements CometChatListProtocol<Conversation> {
  void updateUserStatus(User user, String status);

  void deleteConversation(Conversation conversation);

  void resetUnreadCount(BaseMessage message);

  void updateLastMessage(BaseMessage message);

  void updateGroup(Group group);

  void removeGroup(String guid);

  void updateLastMessageOnEdited(BaseMessage message);

  void refreshSingleConversation(
    BaseMessage message,
    bool isActionMessage, {
    bool? remove,
  });

  ///Update the conversation with new conversation Object matched according to conversation id ,  if not matched inserted at top
  void updateConversation(Conversation conversation);

  void setReceipts(MessageReceipt receipt);

  void setTypingIndicator(
    TypingIndicator typingIndicator,
    bool isTypingStarted,
  );

  void deleteConversationFromIndex(int index);

  void playNotificationSound(BaseMessage message);

  bool getHideThreadIndicator(Conversation conversation);

  bool getHideReceipt(Conversation conversation, bool? disableReadReceipt);
}
