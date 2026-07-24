import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all AI Assistant Chat History events.
abstract class AIAssistantChatHistoryEvent extends Equatable {
  const AIAssistantChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial chat history messages.
class LoadChatHistory extends AIAssistantChatHistoryEvent {
  const LoadChatHistory();
}

/// Load more messages (pagination — scroll down in reversed list).
class LoadMoreChatHistory extends AIAssistantChatHistoryEvent {
  const LoadMoreChatHistory();
}

/// Delete a message from chat history.
class DeleteChatHistoryMessage extends AIAssistantChatHistoryEvent {
  final BaseMessage message;

  const DeleteChatHistoryMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Handle incoming message from SDK listener.
class ChatHistoryMessageReceived extends AIAssistantChatHistoryEvent {
  final BaseMessage message;

  const ChatHistoryMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Handle message edited from SDK listener.
class ChatHistoryMessageEdited extends AIAssistantChatHistoryEvent {
  final BaseMessage message;

  const ChatHistoryMessageEdited(this.message);

  @override
  List<Object?> get props => [message];
}

/// Handle message deleted from SDK listener.
class ChatHistoryMessageDeleted extends AIAssistantChatHistoryEvent {
  final BaseMessage message;

  const ChatHistoryMessageDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Handle reconnection — sync missed messages.
class ChatHistoryReconnected extends AIAssistantChatHistoryEvent {
  const ChatHistoryReconnected();
}
