import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Status enum for AI Assistant Chat History.
enum AIAssistantChatHistoryStatus { initial, loading, loaded, empty, error }

/// Immutable state for the AI Assistant Chat History BLoC.
class AIAssistantChatHistoryState extends Equatable {
  final AIAssistantChatHistoryStatus status;
  final List<BaseMessage> messages;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final User? loggedInUser;

  /// Monotonically increasing version to ensure every state emission is unique.
  /// SDK's BaseMessage.== may not capture all field changes, so this counter
  /// guarantees BLoC always emits the new state to listeners.
  final int _version;

  /// Global counter shared across all instances.
  static int _nextVersion = 0;

  AIAssistantChatHistoryState({
    this.status = AIAssistantChatHistoryStatus.initial,
    this.messages = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loggedInUser,
  }) : _version = _nextVersion++;

  @override
  List<Object?> get props => [
    _version,
    status,
    messages,
    hasMore,
    isLoadingMore,
    errorMessage,
    loggedInUser,
  ];

  AIAssistantChatHistoryState copyWith({
    AIAssistantChatHistoryStatus? status,
    List<BaseMessage>? messages,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    User? loggedInUser,
  }) {
    return AIAssistantChatHistoryState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      loggedInUser: loggedInUser ?? this.loggedInUser,
    );
  }

  @override
  String toString() {
    return 'AIAssistantChatHistoryState('
        'status: $status, '
        'messageCount: ${messages.length}, '
        'hasMore: $hasMore, '
        'isLoadingMore: $isLoadingMore, '
        'errorMessage: $errorMessage'
        ')';
  }
}
