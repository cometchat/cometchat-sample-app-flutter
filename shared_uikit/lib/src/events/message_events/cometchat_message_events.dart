import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///Event emitting class for [CometChatMessages]
class CometChatMessageEvents {
  static Map<String, CometChatMessageEventListener> messagesListener = {};

  static addMessagesListener(
      String listenerId, CometChatMessageEventListener listenerClass) {
    messagesListener[listenerId] = listenerClass;
  }

  static removeMessagesListener(String listenerId) {
    messagesListener.remove(listenerId);
  }

  static ccMessageSent(BaseMessage message, MessageStatus messageStatus) {
    messagesListener.forEach((key, value) {
      value.ccMessageSent(message, messageStatus);
    });
  }

  static ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    messagesListener.forEach((key, value) {
      value.ccMessageEdited(message, status);
    });
  }

  static ccMessageDeleted(BaseMessage message, EventStatus messageStatus) {
    messagesListener.forEach((key, value) {
      value.ccMessageDeleted(message, messageStatus);
    });
  }

  static ccMessageRead(BaseMessage message) {
    messagesListener.forEach((key, value) {
      value.ccMessageRead(message);
    });
  }

  static ccLiveReaction(String reaction, String receiverId) {
    messagesListener.forEach((key, value) {
      value.ccLiveReaction(reaction);
    });
  }

  static ccMessageForwarded(BaseMessage message, List<User>? usersSent,
      List<Group>? groupsSent, MessageStatus status) {
    messagesListener.forEach((key, value) {
      value.ccMessageForwarded(message, usersSent, groupsSent, status);
    });
  }

  /// Called when an outgoing call is initiated by the logged-in user.
  static void onTextMessageReceived(TextMessage textMessage) {
    messagesListener.forEach((key, value) {
      value.onTextMessageReceived(textMessage);
    });
  }

  /// Called when a media message is received.
  static void onMediaMessageReceived(MediaMessage mediaMessage) {
    messagesListener.forEach((key, value) {
      value.onMediaMessageReceived(mediaMessage);
    });
  }

  /// Called when a custom message is received.
  static void onCustomMessageReceived(CustomMessage customMessage) {
    messagesListener.forEach((key, value) {
      value.onCustomMessageReceived(customMessage);
    });
  }

  /// Called when typing is started.
  static void onTypingStarted(TypingIndicator typingIndicator) {
    messagesListener.forEach((key, value) {
      value.onTypingStarted(typingIndicator);
    });
  }

  /// Called when typing is ended.
  static void onTypingEnded(TypingIndicator typingIndicator) {
    messagesListener.forEach((key, value) {
      value.onTypingEnded(typingIndicator);
    });
  }

  /// Called when messages are delivered.
  static void onMessagesDelivered(MessageReceipt messageReceipt) {
    messagesListener.forEach((key, value) {
      value.onMessagesDelivered(messageReceipt);
    });
  }

  /// Called when messages are read.
  static void onMessagesRead(MessageReceipt messageReceipt) {
    messagesListener.forEach((key, value) {
      value.onMessagesRead(messageReceipt);
    });
  }

  /// Called when a message is edited.
  static void onMessageEdited(BaseMessage message) {
    messagesListener.forEach((key, value) {
      value.onMessageEdited(message);
    });
  }

  /// Called when a message is deleted.
  static void onMessageDeleted(BaseMessage message) {
    messagesListener.forEach((key, value) {
      value.onMessageDeleted(message);
    });
  }

  /// Called when a transient message is received.
  static void onTransientMessageReceived(TransientMessage message) {
    messagesListener.forEach((key, value) {
      value.onTransientMessageReceived(message);
    });
  }

  /// Called when a form message is received.
  static void onFormMessageReceived(FormMessage message) {
    messagesListener.forEach((key, value) {
      value.onFormMessageReceived(message);
    });
  }

  /// Called when a card message is received.
  static void onCardMessageReceived(CardMessage message) {
    messagesListener.forEach((key, value) {
      value.onCardMessageReceived(message);
    });
  }

  /// Called when a custom interactive message is received.
  static void onCustomInteractiveMessageReceived(
      CustomInteractiveMessage message) {
    messagesListener.forEach((key, value) {
      value.onCustomInteractiveMessageReceived(message);
    });
  }

  /// Called when an interaction goal is completed.
  static void onInteractionGoalCompleted(InteractionReceipt receipt) {
    messagesListener.forEach((key, value) {
      value.onInteractionGoalCompleted(receipt);
    });
  }

  ///[onSchedulerMessageReceived] Called when a meeting message is received.
  static void onSchedulerMessageReceived(SchedulerMessage schedulerMessage) {
    messagesListener.forEach((key, value) {
      value.onSchedulerMessageReceived(schedulerMessage);
    });
  }

  static void onMessageReactionAdded(ReactionEvent reactionEvent) {
    messagesListener.forEach((key, value) {
      value.onMessageReactionAdded(reactionEvent);
    });
  }

  static void onMessageReactionRemoved(ReactionEvent reactionEvent) {
    messagesListener.forEach((key, value) {
      value.onMessageReactionRemoved(reactionEvent);
    });
  }

  /// Called when messages are delivered to all.
  static void onMessagesDeliveredToAll(MessageReceipt messageReceipt) {
    messagesListener.forEach((key, value) {
      value.onMessagesDeliveredToAll(messageReceipt);
    });
  }

  /// Called when messages are read by all.
  static void onMessagesReadByAll(MessageReceipt messageReceipt) {
    messagesListener.forEach((key, value) {
      value.onMessagesReadByAll(messageReceipt);
    });
  }

  /// Called when a message is moderated.
  static void onMessageModerated(BaseMessage message) {
    messagesListener.forEach((key, value) {
      value.onMessageModerated(message);
    });
  }
}
