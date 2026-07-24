import 'package:flutter/material.dart';
import "package:cometchat_sdk/cometchat_sdk.dart" hide CardMessage;
import '../../../core/constants/enums.dart';
import 'ui_events.dart';

class CometChatUIEvents {
  static Map<String, CometChatUIEventListener> uiListener = {};

  static void addUiListener(
    String listenerId,
    CometChatUIEventListener listenerClass,
  ) {
    uiListener[listenerId] = listenerClass;
  }

  static void removeUiListener(String listenerId) {
    uiListener.remove(listenerId);
  }

  static void showPanel(
    Map<String, dynamic>? id,
    CustomUIPosition uiPosition,
    WidgetBuilder child,
  ) {
    uiListener.forEach((key, value) {
      value.showPanel(id, uiPosition, child);
    });
  }

  static void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    uiListener.forEach((key, value) {
      value.hidePanel(id, uiPosition);
    });
  }

  static void ccActiveChatChanged(
    Map<String, dynamic>? id,
    BaseMessage? lastMessage,
    User? user,
    Group? group,
    int unreadMessageCount,
  ) {
    uiListener.forEach((key, value) {
      value.ccActiveChatChanged(
        id,
        lastMessage,
        user,
        group,
        unreadMessageCount,
      );
    });
  }

  static void openChat(User? user, Group? group) {
    uiListener.forEach((key, value) {
      value.openChat(user, group);
    });
  }

  static void ccComposeMessage(String text, MessageEditStatus status) {
    uiListener.forEach((key, value) {
      value.ccComposeMessage(text, status);
    });
  }

  /// Lock the bottom padding to a specific height (used when showing sticker/emoji keyboard)
  static void lockBottomPadding(Map<String, dynamic>? id, double height) {
    uiListener.forEach((key, value) {
      value.lockBottomPadding(id, height);
    });
  }

  /// Unlock the bottom padding (return to normal keyboard-based padding)
  static void unlockBottomPadding(Map<String, dynamic>? id) {
    uiListener.forEach((key, value) {
      value.unlockBottomPadding(id);
    });
  }

  /// Request the composer to focus its text field (opens OS keyboard)
  static void requestComposerFocus(Map<String, dynamic>? id) {
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
  static void ccAgentChatThreadResolved({
    required String receiverId,
    required int parentMessageId,
  }) {
    uiListener.forEach((key, value) {
      value.ccAgentChatThreadResolved(
        receiverId: receiverId,
        parentMessageId: parentMessageId,
      );
    });
  }

  /// Emit when a card action is triggered within a CometChatCardView renderer.
  ///
  /// [message] is the owning message (CardMessage for developer cards,
  /// AIAssistantMessage for agent cards).
  /// [action] is the raw renderer action event (CometChatCardActionEvent).
  static void ccCardActionClicked(BaseMessage message, dynamic action) {
    uiListener.forEach((key, value) {
      value.ccCardActionClicked(message, action);
    });
  }
}
