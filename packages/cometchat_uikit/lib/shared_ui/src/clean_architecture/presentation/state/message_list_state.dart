import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';
import '../../core/result.dart';

/// Base state class for all message list states
abstract class MessageListState extends Equatable {
  const MessageListState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any operation
class MessageListInitial extends MessageListState {
  const MessageListInitial();
}

/// Loading state - while fetching data
class MessageListLoading extends MessageListState {
  final List<MessageEntity>? cachedMessages;

  const MessageListLoading({this.cachedMessages});

  @override
  List<Object?> get props => [cachedMessages];
}

/// Success state - data loaded successfully
class MessageListSuccess extends MessageListState {
  final List<MessageEntity> messages;
  final bool hasMoreData;
  final int totalCount;

  const MessageListSuccess({
    required this.messages,
    this.hasMoreData = true,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [messages, hasMoreData, totalCount];

  /// Create a copy with updated messages
  MessageListSuccess copyWith({
    List<MessageEntity>? messages,
    bool? hasMoreData,
    int? totalCount,
  }) {
    return MessageListSuccess(
      messages: messages ?? this.messages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Error state - operation failed
class MessageListError extends MessageListState {
  final Failure failure;
  final List<MessageEntity>? cachedMessages;

  const MessageListError({required this.failure, this.cachedMessages});

  @override
  List<Object?> get props => [failure, cachedMessages];

  /// Get error message for display
  String get errorMessage => failure.message;

  /// Check if error is recoverable
  bool get isRecoverable => !['INVALID_PARAMS'].contains(failure.code);
}

/// Empty state - no messages found
class MessageListEmpty extends MessageListState {
  const MessageListEmpty();
}

/// Pagination state - loading more messages
class MessageListLoadingMore extends MessageListState {
  final List<MessageEntity> currentMessages;

  const MessageListLoadingMore({required this.currentMessages});

  @override
  List<Object?> get props => [currentMessages];
}

/// Search state - searching for messages
class MessageListSearching extends MessageListState {
  final String query;
  final List<MessageEntity>? previousMessages;

  const MessageListSearching({required this.query, this.previousMessages});

  @override
  List<Object?> get props => [query, previousMessages];
}

/// Search results state
class MessageListSearchResults extends MessageListState {
  final List<MessageEntity> searchResults;
  final String query;
  final bool isEmpty;

  const MessageListSearchResults({
    required this.searchResults,
    required this.query,
    required this.isEmpty,
  });

  @override
  List<Object?> get props => [searchResults, query, isEmpty];
}

/// Message sending state
class MessageListSending extends MessageListState {
  final List<MessageEntity> currentMessages;
  final String tempMessageText;

  const MessageListSending({
    required this.currentMessages,
    required this.tempMessageText,
  });

  @override
  List<Object?> get props => [currentMessages, tempMessageText];
}

/// Message sent state
class MessageListMessageSent extends MessageListState {
  final List<MessageEntity> messages;
  final MessageEntity newMessage;

  const MessageListMessageSent({
    required this.messages,
    required this.newMessage,
  });

  @override
  List<Object?> get props => [messages, newMessage];
}

/// Message deleted state
class MessageListMessageDeleted extends MessageListState {
  final List<MessageEntity> messages;
  final String deletedMessageId;

  const MessageListMessageDeleted({
    required this.messages,
    required this.deletedMessageId,
  });

  @override
  List<Object?> get props => [messages, deletedMessageId];
}

/// State for unread count
abstract class UnreadCountState extends Equatable {
  const UnreadCountState();

  @override
  List<Object?> get props => [];
}

class UnreadCountInitial extends UnreadCountState {
  const UnreadCountInitial();
}

class UnreadCountLoading extends UnreadCountState {
  const UnreadCountLoading();
}

class UnreadCountSuccess extends UnreadCountState {
  final int count;

  const UnreadCountSuccess(this.count);

  @override
  List<Object?> get props => [count];
}

class UnreadCountError extends UnreadCountState {
  final String message;

  const UnreadCountError(this.message);

  @override
  List<Object?> get props => [message];
}
