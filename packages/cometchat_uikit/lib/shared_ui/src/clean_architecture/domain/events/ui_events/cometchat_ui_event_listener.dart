import 'package:flutter/cupertino.dart';
import "package:cometchat_sdk/cometchat_sdk.dart";
import '../../../core/utils/ui_event_handler.dart';
import '../../../core/constants/enums.dart';
import 'ui_events.dart';

///Listener class for [CometChatConversations]
mixin CometChatUIEventListener implements UIEventHandler {
  void showPanel(Map<String, dynamic>? id, CustomUIPosition uiPosition,
      WidgetBuilder child) {}
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {}

  void ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {}

  void openChat(User? user, Group? group) {}

  void ccComposeMessage(String text, MessageEditStatus status) {}

  /// Lock the bottom padding to a specific height (used when showing sticker/emoji keyboard)
  void lockBottomPadding(Map<String, dynamic>? id, double height) {}

  /// Unlock the bottom padding (return to normal keyboard-based padding)
  void unlockBottomPadding(Map<String, dynamic>? id) {}

  /// Request the composer to focus its text field (opens OS keyboard)
  void requestComposerFocus(Map<String, dynamic>? id) {}

  /// Notifies sibling components (e.g. Composer) that the MessageList has
  /// resolved the parentMessageId for an AI agent chat thread.
  ///
  /// [receiverId] is the agent UID whose thread was resolved.
  /// [parentMessageId] is the resolved thread parent message ID.
  void ccAgentChatThreadResolved(
      {required String receiverId, required int parentMessageId}) {}
}
