import 'package:flutter/material.dart';
import '../../../cometchat_uikit_shared.dart';

class CometChatUIEvents {
  static Map<String, CometChatUIEventListener> uiListener = {};

  static addUiListener(
      String listenerId, CometChatUIEventListener listenerClass) {
    uiListener[listenerId] = listenerClass;
  }

  static removeUiListener(String listenerId) {
    uiListener.remove(listenerId);
  }

  static showPanel(Map<String, dynamic>? id, CustomUIPosition uiPosition,
      WidgetBuilder child) {
    uiListener.forEach((key, value) {
      value.showPanel(id, uiPosition, child);
    });
  }

  static hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    uiListener.forEach((key, value) {
      value.hidePanel(id, uiPosition);
    });
  }

  static ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {
    uiListener.forEach((key, value) {
      value.ccActiveChatChanged(
          id, lastMessage, user, group, unreadMessageCount);
    });
  }

  static openChat(User? user, Group? group) {
    uiListener.forEach((key, value) {
      value.openChat(user, group);
    });
  }

  static ccComposeMessage(String text, MessageEditStatus status) {
    uiListener.forEach((key, value) {
      value.ccComposeMessage(text, status);
    });
  }

  /// Lock the bottom padding to a specific height (used when showing sticker/emoji keyboard)
  static lockBottomPadding(Map<String, dynamic>? id, double height) {
    uiListener.forEach((key, value) {
      value.lockBottomPadding(id, height);
    });
  }

  /// Unlock the bottom padding (return to normal keyboard-based padding)
  static unlockBottomPadding(Map<String, dynamic>? id) {
    uiListener.forEach((key, value) {
      value.unlockBottomPadding(id);
    });
  }

  /// Request the composer to focus its text field (opens OS keyboard)
  static requestComposerFocus(Map<String, dynamic>? id) {
    uiListener.forEach((key, value) {
      value.requestComposerFocus(id);
    });
  }

  /// Notify sibling components that the MessageList has resolved the
  /// parentMessageId for an AI agent chat thread.
  ///
  /// Emitted by the MessageList BLoC after [LoadLastAgentConversation] resolves
  /// the thread. The Composer listens for this to update its own parentMessageId
  /// so sent messages have the correct thread context.
  static ccAgentChatThreadResolved(
      {required String receiverId, required int parentMessageId}) {
    uiListener.forEach((key, value) {
      value.ccAgentChatThreadResolved(
          receiverId: receiverId, parentMessageId: parentMessageId);
    });
  }
}
