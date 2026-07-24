import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for conversations states
/// Uses Equatable for proper state comparison in BLoC
abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

/// Loading state when fetching initial conversations
class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

/// Loaded state with conversation data
///
/// Note: Typing indicators are managed separately via ValueNotifier per conversation
/// for optimized rebuilds. Use [ConversationsBloc.getTypingNotifier] to access them.
class ConversationsLoaded extends ConversationsState {
  /// Conversations list - SDK Conversation extends Equatable for property comparison
  final List<Conversation> conversations;

  final bool hasMore;
  final Set<String> selectedConversations;
  final String? activeConversationId;
  final bool isLoadingMore;

  /// Monotonically increasing version to ensure every state emission is unique.
  ///
  /// SDK's [Conversation.==] only compares [conversationId], so Equatable
  /// considers two lists with the same conversation IDs as equal even when
  /// [lastMessage], [unreadMessageCount], etc. have changed. This counter
  /// guarantees BLoC always emits the new state to listeners.
  final int _version;

  /// Global counter shared across all [ConversationsLoaded] instances.
  static int _nextVersion = 0;

  ConversationsLoaded({
    required this.conversations,
    this.hasMore = false,
    this.selectedConversations = const {},
    this.activeConversationId,
    this.isLoadingMore = false,
  }) : _version = _nextVersion++;

  @override
  List<Object?> get props => [
    _version,
    conversations,
    hasMore,
    selectedConversations,
    activeConversationId,
    isLoadingMore,
  ];

  /// Create a copy of this state with updated fields
  ConversationsLoaded copyWith({
    List<Conversation>? conversations,
    bool? hasMore,
    Set<String>? selectedConversations,
    String? activeConversationId,
    bool? isLoadingMore,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      hasMore: hasMore ?? this.hasMore,
      selectedConversations:
          selectedConversations ?? this.selectedConversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Empty state when no conversations exist
class ConversationsEmpty extends ConversationsState {
  const ConversationsEmpty();
}

/// Error state with error message and optional previous data
class ConversationsError extends ConversationsState {
  final String message;
  final List<Conversation>? previousConversations;

  const ConversationsError({required this.message, this.previousConversations});

  @override
  List<Object?> get props => [message, previousConversations];
}
