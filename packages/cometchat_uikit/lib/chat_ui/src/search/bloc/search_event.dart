import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for all search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// User typed in the search bar
class SearchTextChanged extends SearchEvent {
  final String text;
  const SearchTextChanged(this.text);

  @override
  List<Object?> get props => [text];
}

/// User tapped a filter chip
class SearchFilterToggled extends SearchEvent {
  final String label;
  const SearchFilterToggled(this.label);

  @override
  List<Object?> get props => [label];
}

/// Load more conversations (pagination)
class LoadMoreConversationResults extends SearchEvent {
  const LoadMoreConversationResults();
}

/// Load more messages (pagination)
class LoadMoreMessageResults extends SearchEvent {
  const LoadMoreMessageResults();
}

/// Clear all search state
class ClearSearch extends SearchEvent {
  const ClearSearch();
}

// ============================================================
// Internal events — dispatched by async fetch methods.
// Public because Dart private is per-file; only used by SearchBloc.
// ============================================================

class ConversationsResultReceived extends SearchEvent {
  final List<Conversation> conversations;
  final bool hasMore;
  final bool append;

  const ConversationsResultReceived({
    required this.conversations,
    required this.hasMore,
    this.append = false,
  });

  @override
  List<Object?> get props => [conversations, hasMore, append];
}

class ConversationsErrorReceived extends SearchEvent {
  final String message;
  const ConversationsErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class MessagesResultReceived extends SearchEvent {
  final List<BaseMessage> messages;
  final bool hasMore;
  final bool append;

  const MessagesResultReceived({
    required this.messages,
    required this.hasMore,
    this.append = false,
  });

  @override
  List<Object?> get props => [messages, hasMore, append];
}

class MessagesErrorReceived extends SearchEvent {
  final String message;
  const MessagesErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}
