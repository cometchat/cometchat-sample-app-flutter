import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as ui_kit;

///[CometChatUIKitHelper] contains static methods for triggering local events
class CometChatUIKitHelper {
  //---------- Message Events ----------
  ///[onMessageSent] is used to inform the listeners
  ///when the logged-in user is sending a message
  static onMessageSent(BaseMessage message, MessageStatus messageStatus) {
    CometChatMessageEvents.ccMessageSent(message, messageStatus);
  }

  ///[onMessageEdited] is used to inform the listeners
  ///when the logged-in user is editing a message
  static onMessageEdited(BaseMessage message, MessageEditStatus status) {
    CometChatMessageEvents.ccMessageEdited(message, status);
  }

  ///[onMessageDeleted] is used to inform the listeners
  ///when the logged-in user has deleted a message
  static onMessageDeleted(BaseMessage message, EventStatus status) {
    CometChatMessageEvents.ccMessageDeleted(message, status);
  }

  ///[onMessageRead] is used to inform the listeners
  ///when the logged-in user has read a message
  static onMessageRead(BaseMessage message) {
    CometChatMessageEvents.ccMessageRead(message);
  }

  ///[onLiveReaction] is used to inform the listeners
  ///when the logged-in user sends a transient message (live reaction)
  static onLiveReaction(String reaction, String receiverId) {
    CometChatMessageEvents.ccLiveReaction(reaction, receiverId);
  }

  //---------- User Events ----------
  ///[onUserBlocked] is used to inform the listeners
  ///when the logged-in user blocks another user
  static onUserBlocked(User user) {
    CometChatUserEvents.ccUserBlocked(user);
  }

  ///[onUserUnblocked] is used to inform the listeners
  ///when the logged-in user unblocks a blocked user
  static onUserUnblocked(User user) {
    CometChatUserEvents.ccUserUnblocked(user);
  }

  ///[onMessageModerated] is used to inform the listeners
  ///when the logged-in user has moderated a message
  static onMessageModerated(BaseMessage message) {
    CometChatMessageEvents.onMessageModerated(message);
  }

  ///[onAIAssistantMessageReceived] is used to inform the listeners
  ///when the logged-in user has aiAssistantMessage received
  static onAIAssistantMessageReceived(AIAssistantMessage aiAssistantMessage) {
    CometChatMessageEvents.onAIAssistantMessageReceived(aiAssistantMessage);
  }

  ///[onAIToolResultReceived] is used to inform the listeners
  ///when the logged-in user has aiToolResultMessage received
  static onAIToolResultReceived(AIToolResultMessage aiToolResultMessage) {
    CometChatMessageEvents.onAIToolResultReceived(aiToolResultMessage);
  }

  ///[onAIToolArgumentsReceived] is used to inform the listeners
  ///  when the logged-in user has aiToolArgumentMessage received
  static onAIToolArgumentsReceived(AIToolArgumentMessage aiToolArgumentMessage) {
    CometChatMessageEvents.onAIToolArgumentsReceived(aiToolArgumentMessage);
  }

  //---------- Group Events ----------
  ///[onGroupCreated] is used to inform the listeners
  ///when the logged-in user creates a Group
  static onGroupCreated(Group group) {
    CometChatGroupEvents.ccGroupCreated(group);
  }

  ///[onGroupDeleted] is used to inform the listeners
  ///when the logged-in user deletes a Group
  static onGroupDeleted(Group group) {
    CometChatGroupEvents.ccGroupDeleted(group);
  }

  ///[onGroupLeft] is used to inform the listeners
  ///when the logged-in user leaves a Group
  static onGroupLeft(ui_kit.Action message, User leftUser, Group leftGroup) {
    CometChatGroupEvents.ccGroupLeft(message, leftUser, leftGroup);
  }

  ///[onGroupMemberScopeChanged] is used to inform the listeners
  ///when the logged-in user changes the scope of a group member
  ///in a group
  static onGroupMemberScopeChanged(ui_kit.Action message, User updatedUser,
      String scopeChangedTo, String scopeChangedFrom, Group group) {
    CometChatGroupEvents.ccGroupMemberScopeChanged(
        message, updatedUser, scopeChangedTo, scopeChangedFrom, group);
  }

  ///[onGroupMemberBanned] is used to inform the listeners
  ///when the logged-in user bans a group member
  static onGroupMemberBanned(
      ui_kit.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    CometChatGroupEvents.ccGroupMemberBanned(
        message, bannedUser, bannedBy, bannedFrom);
  }

  ///[onGroupMemberKicked] is used to inform the listeners
  ///when the logged-in user kicks a group member from a group
  static onGroupMemberKicked(
      ui_kit.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    CometChatGroupEvents.ccGroupMemberKicked(
        message, kickedUser, kickedBy, kickedFrom);
  }

  ///[onGroupMemberUnbanned] is used to inform the listeners
  ///when the logged-in user unbans a banned user of a group
  static onGroupMemberUnbanned(ui_kit.Action message, User unbannedUser,
      User unbannedBy, Group unbannedFrom) {
    CometChatGroupEvents.ccGroupMemberUnbanned(
        message, unbannedUser, unbannedBy, unbannedFrom);
  }

  ///[onGroupMemberJoined] is used to inform the listeners
  ///when the logged-in user joins a group
  static onGroupMemberJoined(User joinedUser, Group joinedGroup) {
    CometChatGroupEvents.ccGroupMemberJoined(joinedUser, joinedGroup);
  }

  ///[onGroupMemberAdded] is used to inform the listeners
  ///when the logged-in user adds users to a group
  static onGroupMemberAdded(
    List<ui_kit.Action> messages,
    List<User> usersAdded,
    Group groupAddedIn,
    User addedBy,
  ) {
    CometChatGroupEvents.ccGroupMemberAdded(
        messages, usersAdded, groupAddedIn, addedBy);
  }

  ///[onOwnershipChanged] is used to inform the listeners
  ///when the logged-in user transfers their ownership to some other group member
  static onOwnershipChanged(Group group, GroupMember newOwner) {
    CometChatGroupEvents.ccOwnershipChanged(group, newOwner);
  }

  //---------- Conversation Events ----------
  ///[onConversationDeleted] is used to inform the listeners
  ///when the logged-in user deletes a conversation
  static onConversationDeleted(Conversation conversation) {
    CometChatConversationEvents.ccConversationDeleted(conversation);
  }

  //---------- CometChat UI Events ----------
  ///[showPanel] used to reveal a panel above message composer
  static showPanel(Map<String, dynamic>? id, CustomUIPosition uiPosition,
      WidgetBuilder child) {
    CometChatUIEvents.showPanel(id, uiPosition, child);
  }

  ///[hidePanel] used to hide the panel above message composer
  static hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    CometChatUIEvents.hidePanel(id, uiPosition);
  }

  ///[ccActiveChatChanged] used to notify if the logged-in user
  ///has moved on to a different conversation
  static ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {
    CometChatUIEvents.ccActiveChatChanged(
        id, lastMessage, user, group, unreadMessageCount);
  }

  ///[onOpenChat] used to open the chat conversation
  ///of a user or a group
  static onOpenChat(User? user, Group? group) {
    CometChatUIEvents.openChat(user, group);
  }

  ///[ccComposeMessage] used to add replies to message composer
  ///when the logged-in user is adding a message to composer
  static ccComposeMessage(String text, MessageEditStatus status) {
    CometChatUIEvents.ccComposeMessage(text, status);
  }

  ///[onAiFeatureTapped] used to open the ai features
  ///of a user or a group
  static onAiFeatureTapped(User? user, Group? group) {
    CometChatUIEvents.onAiFeatureTapped(user, group);
  }

//---------- AI Assistant Events ----------

  ///[onAIAssistantEventReceived] is used to inform the listeners
  ///when the logged-in user has aiAssistantEvent received
  static onAIAssistantEventReceived(AIAssistantBaseEvent aiAssistantBaseEvent) {
    CometChatAIAssistantEvents.onAIAssistantEventReceived(aiAssistantBaseEvent);
  }
}
