import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all conversations events
/// Uses Equatable for proper event comparison in BLoC
abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial conversations
///
/// When [silent] is true, the existing list stays visible while refreshing
/// (no loading shimmer). Used for background→foreground and reconnect scenarios.
class LoadConversations extends ConversationsEvent {
  final bool silent;

  const LoadConversations({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

/// Load more conversations (pagination)
class LoadMoreConversations extends ConversationsEvent {
  const LoadMoreConversations();
}

/// Refresh conversations list
class RefreshConversations extends ConversationsEvent {
  const RefreshConversations();
}

/// Delete conversation action (calls SDK to delete)
class DeleteConversation extends ConversationsEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

/// Remove conversation from list without calling SDK
/// Use this for events like group left/kicked where SDK already removed the user
class RemoveConversation extends ConversationsEvent {
  final String conversationId;

  const RemoveConversation(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

/// Set active conversation (when user opens a chat)
class SetActiveConversation extends ConversationsEvent {
  final String? conversationId;

  const SetActiveConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Toggle conversation selection
class ToggleConversationSelection extends ConversationsEvent {
  final String conversationId;

  const ToggleConversationSelection(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

/// Clear all conversation selections
class ClearConversationSelection extends ConversationsEvent {
  const ClearConversationSelection();
}

/// Update a specific conversation with modified data
/// Use this when the SDK or list item callback provides an updated conversation object
/// with changed properties (including custom properties not tracked by the BLoC)
class UpdateConversation extends ConversationsEvent {
  final String conversationId;
  final Conversation updatedConversation;

  /// Set to true to force a UI rebuild even if conversation properties haven't changed
  final bool forceUpdate;

  const UpdateConversation({
    required this.conversationId,
    required this.updatedConversation,
    this.forceUpdate = true,
  });

  @override
  List<Object?> get props => [conversationId, updatedConversation, forceUpdate];
}

/// Reset unread count for a conversation
/// Use this when the user reads messages in a conversation
class ResetUnreadCount extends ConversationsEvent {
  final String conversationId;

  const ResetUnreadCount(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}
