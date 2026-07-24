import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Status enum for message list
enum MessageListStatus { initial, loading, loaded, empty, error }

/// State for the animated message list BLoC (legacy compatibility)
class AnimatedMessageListState extends Equatable {
  final List<BaseMessage> messages;
  final bool isLoadingOlder;
  final bool isLoadingNewer;
  final bool hasMoreOlder;
  final bool hasMoreNewer;

  const AnimatedMessageListState({
    this.messages = const [],
    this.isLoadingOlder = false,
    this.isLoadingNewer = false,
    this.hasMoreOlder = true,
    this.hasMoreNewer = false,
  });

  bool get isEmpty => messages.isEmpty;
  bool get isNotEmpty => messages.isNotEmpty;
  int get messageCount => messages.length;

  AnimatedMessageListState copyWith({
    List<BaseMessage>? messages,
    bool? isLoadingOlder,
    bool? isLoadingNewer,
    bool? hasMoreOlder,
    bool? hasMoreNewer,
  }) {
    return AnimatedMessageListState(
      messages: messages ?? this.messages,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isLoadingNewer: isLoadingNewer ?? this.isLoadingNewer,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      hasMoreNewer: hasMoreNewer ?? this.hasMoreNewer,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isLoadingOlder,
    isLoadingNewer,
    hasMoreOlder,
    hasMoreNewer,
  ];
}

/// State for the message list BLoC (Clean Architecture)
class MessageListState extends Equatable {
  final MessageListStatus status;
  final List<BaseMessage> messages;
  final bool isLoadingOlder;
  final bool isLoadingNewer;
  final bool hasMoreOlder;
  final bool hasMoreNewer;
  final String? errorMessage;
  final String? activeConversationId;
  final User? loggedInUser;
  final Conversation? conversation;

  // Mark as Unread state
  final BaseMessage? unreadMessageAnchor;
  final int? unreadMessageAnchorId;
  final int unreadCount;
  final bool markedAsUnreadInSession;
  final int newUnreadMessageCount;
  final int? lastReadMessageId;

  const MessageListState({
    this.status = MessageListStatus.initial,
    this.messages = const [],
    this.isLoadingOlder = false,
    this.isLoadingNewer = false,
    this.hasMoreOlder = true,
    this.hasMoreNewer = false,
    this.errorMessage,
    this.activeConversationId,
    this.loggedInUser,
    this.conversation,
    this.unreadMessageAnchor,
    this.unreadMessageAnchorId,
    this.unreadCount = 0,
    this.markedAsUnreadInSession = false,
    this.newUnreadMessageCount = 0,
    this.lastReadMessageId,
  });

  bool get isEmpty => messages.isEmpty;
  bool get isNotEmpty => messages.isNotEmpty;
  int get messageCount => messages.length;

  MessageListState copyWith({
    MessageListStatus? status,
    List<BaseMessage>? messages,
    bool? isLoadingOlder,
    bool? isLoadingNewer,
    bool? hasMoreOlder,
    bool? hasMoreNewer,
    String? errorMessage,
    String? activeConversationId,
    User? loggedInUser,
    Conversation? conversation,
    BaseMessage? unreadMessageAnchor,
    int? unreadMessageAnchorId,
    int? unreadCount,
    bool? markedAsUnreadInSession,
    int? newUnreadMessageCount,
    int? lastReadMessageId,
  }) {
    return MessageListState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isLoadingNewer: isLoadingNewer ?? this.isLoadingNewer,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      hasMoreNewer: hasMoreNewer ?? this.hasMoreNewer,
      errorMessage: errorMessage ?? this.errorMessage,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      loggedInUser: loggedInUser ?? this.loggedInUser,
      conversation: conversation ?? this.conversation,
      unreadMessageAnchor: unreadMessageAnchor ?? this.unreadMessageAnchor,
      unreadMessageAnchorId:
          unreadMessageAnchorId ?? this.unreadMessageAnchorId,
      unreadCount: unreadCount ?? this.unreadCount,
      markedAsUnreadInSession:
          markedAsUnreadInSession ?? this.markedAsUnreadInSession,
      newUnreadMessageCount:
          newUnreadMessageCount ?? this.newUnreadMessageCount,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
    );
  }

  /// Creates a copy with nullable fields explicitly cleared
  MessageListState copyWithCleared({
    MessageListStatus? status,
    List<BaseMessage>? messages,
    bool? isLoadingOlder,
    bool? isLoadingNewer,
    bool? hasMoreOlder,
    bool? hasMoreNewer,
    bool clearErrorMessage = false,
    bool clearActiveConversationId = false,
    bool clearLoggedInUser = false,
    bool clearConversation = false,
    bool clearUnreadState = false,
    String? errorMessage,
    String? activeConversationId,
    User? loggedInUser,
    Conversation? conversation,
    BaseMessage? unreadMessageAnchor,
    int? unreadMessageAnchorId,
    int? unreadCount,
    bool? markedAsUnreadInSession,
    int? newUnreadMessageCount,
    int? lastReadMessageId,
  }) {
    return MessageListState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isLoadingNewer: isLoadingNewer ?? this.isLoadingNewer,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      hasMoreNewer: hasMoreNewer ?? this.hasMoreNewer,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      activeConversationId: clearActiveConversationId
          ? null
          : (activeConversationId ?? this.activeConversationId),
      loggedInUser: clearLoggedInUser
          ? null
          : (loggedInUser ?? this.loggedInUser),
      conversation: clearConversation
          ? null
          : (conversation ?? this.conversation),
      unreadMessageAnchor: clearUnreadState
          ? null
          : (unreadMessageAnchor ?? this.unreadMessageAnchor),
      unreadMessageAnchorId: clearUnreadState
          ? null
          : (unreadMessageAnchorId ?? this.unreadMessageAnchorId),
      unreadCount: clearUnreadState ? 0 : (unreadCount ?? this.unreadCount),
      markedAsUnreadInSession: clearUnreadState
          ? false
          : (markedAsUnreadInSession ?? this.markedAsUnreadInSession),
      newUnreadMessageCount: clearUnreadState
          ? 0
          : (newUnreadMessageCount ?? this.newUnreadMessageCount),
      lastReadMessageId: clearUnreadState
          ? null
          : (lastReadMessageId ?? this.lastReadMessageId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    isLoadingOlder,
    isLoadingNewer,
    hasMoreOlder,
    hasMoreNewer,
    errorMessage,
    activeConversationId,
    loggedInUser,
    conversation,
    unreadMessageAnchor,
    unreadMessageAnchorId,
    unreadCount,
    markedAsUnreadInSession,
    newUnreadMessageCount,
    lastReadMessageId,
  ];

  @override
  String toString() {
    return 'MessageListState('
        'status: $status, '
        'messageCount: $messageCount, '
        'isLoadingOlder: $isLoadingOlder, '
        'isLoadingNewer: $isLoadingNewer, '
        'hasMoreOlder: $hasMoreOlder, '
        'hasMoreNewer: $hasMoreNewer, '
        'errorMessage: $errorMessage, '
        'activeConversationId: $activeConversationId, '
        'loggedInUser: ${loggedInUser?.uid}, '
        'conversation: ${conversation?.conversationId}, '
        'unreadMessageAnchorId: $unreadMessageAnchorId, '
        'unreadCount: $unreadCount, '
        'markedAsUnreadInSession: $markedAsUnreadInSession, '
        'newUnreadMessageCount: $newUnreadMessageCount, '
        'lastReadMessageId: $lastReadMessageId'
        ')';
  }
}
