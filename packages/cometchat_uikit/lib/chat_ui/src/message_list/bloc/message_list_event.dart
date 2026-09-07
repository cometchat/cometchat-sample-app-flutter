import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all message list events
/// Uses Equatable for proper event comparison in BLoC
abstract class MessageListEvent extends Equatable {
  const MessageListEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Clean Architecture BLoC Events
// ============================================================================

/// Load initial messages for a conversation
class LoadMessages extends MessageListEvent {
  final String conversationWith;
  final String conversationType;
  final int? parentMessageId;
  final List<String>? types;
  final List<String>? categories;

  const LoadMessages({
    required this.conversationWith,
    required this.conversationType,
    this.parentMessageId,
    this.types,
    this.categories,
  });

  @override
  List<Object?> get props => [
    conversationWith,
    conversationType,
    parentMessageId,
    types,
    categories,
  ];
}

/// Load older messages (pagination - scroll up)
class LoadOlderMessages extends MessageListEvent {
  const LoadOlderMessages();
}

/// Load newer messages (pagination - scroll down)
class LoadNewerMessages extends MessageListEvent {
  const LoadNewerMessages();
}

/// Refresh the message list
class RefreshMessages extends MessageListEvent {
  const RefreshMessages();
}

/// Silently sync messages missed while app was in background or disconnected
class SyncMessages extends MessageListEvent {
  const SyncMessages();
}

/// Handle incoming message from SDK listener
class MessageReceived extends MessageListEvent {
  final BaseMessage message;
  const MessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

/// Handle message edit from SDK listener
class MessageEdited extends MessageListEvent {
  final BaseMessage message;
  const MessageEdited(this.message);
  @override
  List<Object?> get props => [message];
}

/// Pin & Save: a pin/unpin/save/unsave landed on a message in this list.
///
/// Kept apart from [MessageEdited] because these payloads only speak for
/// their own feature: a pin frame carries no savedAt, so replacing the row
/// wholesale would silently clear the reader's save (and vice versa). The
/// handler merges instead, preserving the flags the event does not own.
class MessagePinSaveChanged extends MessageListEvent {
  final BaseMessage message;

  /// True for pin/unpin (preserve the row's save state), false for
  /// save/unsave (preserve its pin state).
  final bool isPinScope;

  const MessagePinSaveChanged(this.message, {required this.isPinScope});

  @override
  List<Object?> get props => [message, isPinScope];
}

/// Handle message deletion from SDK listener
class MessageDeleted extends MessageListEvent {
  final BaseMessage message;
  const MessageDeleted(this.message);
  @override
  List<Object?> get props => [message];
}

/// Handle delivery receipt from SDK listener
class DeliveryReceiptReceived extends MessageListEvent {
  final MessageReceipt receipt;
  const DeliveryReceiptReceived(this.receipt);
  @override
  List<Object?> get props => [receipt];
}

/// Handle read receipt from SDK listener
class ReadReceiptReceived extends MessageListEvent {
  final MessageReceipt receipt;
  const ReadReceiptReceived(this.receipt);
  @override
  List<Object?> get props => [receipt];
}

/// Mark a message as read
class MarkMessageAsRead extends MessageListEvent {
  final BaseMessage message;
  const MarkMessageAsRead(this.message);
  @override
  List<Object?> get props => [message];
}

/// Set active conversation (for unread count management)
class SetActiveConversation extends MessageListEvent {
  final String? conversationId;
  const SetActiveConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

// ============================================================================
// Animated List Events (for AnimatedMessageListBloc)
// ============================================================================

/// Insert a single message into the list
class InsertMessage extends MessageListEvent {
  final BaseMessage message;
  final int? index;
  final bool animated;

  const InsertMessage(this.message, {this.index, this.animated = true});

  @override
  List<Object?> get props => [message, index, animated];
}

/// Insert multiple messages into the list
class InsertAllMessages extends MessageListEvent {
  final List<BaseMessage> messages;
  final int? index;
  final bool animated;

  const InsertAllMessages(this.messages, {this.index, this.animated = true});

  @override
  List<Object?> get props => [messages, index, animated];
}

/// Update an existing message in the list
class UpdateMessage extends MessageListEvent {
  final BaseMessage oldMessage;
  final BaseMessage newMessage;
  const UpdateMessage(this.oldMessage, this.newMessage);
  @override
  List<Object?> get props => [oldMessage, newMessage];
}

/// Remove a message from the list
class RemoveMessage extends MessageListEvent {
  final BaseMessage message;
  final bool animated;
  const RemoveMessage(this.message, {this.animated = true});
  @override
  List<Object?> get props => [message, animated];
}

/// Replace the entire message list
class SetMessages extends MessageListEvent {
  final List<BaseMessage> messages;
  final bool animated;
  const SetMessages(this.messages, {this.animated = true});
  @override
  List<Object?> get props => [messages, animated];
}

/// Set the loading older messages state
class SetLoadingOlder extends MessageListEvent {
  final bool isLoading;
  const SetLoadingOlder(this.isLoading);
  @override
  List<Object?> get props => [isLoading];
}

/// Set the loading newer messages state
class SetLoadingNewer extends MessageListEvent {
  final bool isLoading;
  const SetLoadingNewer(this.isLoading);
  @override
  List<Object?> get props => [isLoading];
}

/// Set whether there are more older messages to load
class SetHasMoreOlder extends MessageListEvent {
  final bool hasMore;
  const SetHasMoreOlder(this.hasMore);
  @override
  List<Object?> get props => [hasMore];
}

/// Set whether there are more newer messages to load
class SetHasMoreNewer extends MessageListEvent {
  final bool hasMore;
  const SetHasMoreNewer(this.hasMore);
  @override
  List<Object?> get props => [hasMore];
}

/// Jump to a specific message by ID
class JumpToMessage extends MessageListEvent {
  final int messageId;
  const JumpToMessage({required this.messageId});
  @override
  List<Object?> get props => [messageId];
}

/// Add a reaction to a message
class AddReaction extends MessageListEvent {
  final BaseMessage message;
  final String reaction;
  const AddReaction({required this.message, required this.reaction});
  @override
  List<Object?> get props => [message, reaction];
}

/// Remove a reaction from a message
class RemoveReaction extends MessageListEvent {
  final BaseMessage message;
  final String reaction;
  const RemoveReaction({required this.message, required this.reaction});
  @override
  List<Object?> get props => [message, reaction];
}

/// Handle reaction added from SDK listener
class ReactionAddedFromSDK extends MessageListEvent {
  final int messageId;
  final Reaction reaction;
  final String? receiverId;
  final String? receiverType;

  const ReactionAddedFromSDK({
    required this.messageId,
    required this.reaction,
    this.receiverId,
    this.receiverType,
  });

  @override
  List<Object?> get props => [messageId, reaction, receiverId, receiverType];
}

/// Handle reaction removed from SDK listener
class ReactionRemovedFromSDK extends MessageListEvent {
  final int messageId;
  final Reaction reaction;
  final String? receiverId;
  final String? receiverType;

  const ReactionRemovedFromSDK({
    required this.messageId,
    required this.reaction,
    this.receiverId,
    this.receiverType,
  });

  @override
  List<Object?> get props => [messageId, reaction, receiverId, receiverType];
}

// ============================================================================
// Mark as Unread Events
// ============================================================================

/// Mark a message as unread
class MarkMessageAsUnread extends MessageListEvent {
  final BaseMessage message;
  const MarkMessageAsUnread(this.message);
  @override
  List<Object?> get props => [message];
}

/// Load messages starting from unread position
class LoadFromUnread extends MessageListEvent {
  final String conversationWith;
  final String conversationType;

  const LoadFromUnread({
    required this.conversationWith,
    required this.conversationType,
  });

  @override
  List<Object?> get props => [conversationWith, conversationType];
}

/// Reset unread state
class ResetUnreadState extends MessageListEvent {
  const ResetUnreadState();
}

/// Handle message sent by the logged-in user (from UI events)
class MessageSentByUser extends MessageListEvent {
  final BaseMessage message;
  final String status;

  const MessageSentByUser({required this.message, required this.status});

  @override
  List<Object?> get props => [message, status];
}

/// Force the message list into empty state without loading messages.
/// Used for AI users with no active thread (fresh chat).
class ForceEmptyState extends MessageListEvent {
  const ForceEmptyState();
}

/// Load the most recent AI agent conversation thread.
///
/// Fetches messages for the agent UID (hideReplies: true) to find the latest
/// parent message, then loads the full thread with that parentMessageId.
/// Falls back to empty state if no previous conversation exists.
class LoadLastAgentConversation extends MessageListEvent {
  final String conversationWith;

  const LoadLastAgentConversation({required this.conversationWith});

  @override
  List<Object?> get props => [conversationWith];
}
