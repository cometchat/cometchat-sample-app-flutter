import 'package:equatable/equatable.dart';
import '../../../../../shared_ui/cometchat_uikit_shared.dart';

/// Enum representing the status of the message header
enum MessageHeaderStatus { initial, loading, loaded, error }

/// State class for message header BLoC
/// Uses Equatable for proper state comparison
class MessageHeaderState extends Equatable {
  /// Current status of the message header
  final MessageHeaderStatus status;

  /// User object (for user conversations)
  final User? user;

  /// Group object (for group conversations)
  final Group? group;

  /// Member count for group conversations
  final int memberCount;

  /// Whether the user is currently typing
  final bool isTyping;

  /// The user who is typing (for group conversations)
  final User? typingUser;

  /// Error message if status is error
  final String? errorMessage;

  /// Logged in user
  final User? loggedInUser;

  const MessageHeaderState({
    this.status = MessageHeaderStatus.initial,
    this.user,
    this.group,
    this.memberCount = 0,
    this.isTyping = false,
    this.typingUser,
    this.errorMessage,
    this.loggedInUser,
  });

  /// Check if this is a user conversation
  bool get isUserConversation => user != null;

  /// Check if this is a group conversation
  bool get isGroupConversation => group != null;

  /// Get the display name
  String get displayName {
    if (user != null) return user!.name;
    if (group != null) return group!.name;
    return '';
  }

  /// Get the avatar URL
  String? get avatarUrl {
    if (user != null) return user!.avatar;
    if (group != null) return group!.icon;
    return null;
  }

  /// Check if user is online
  bool get isUserOnline =>
      user != null && user!.status == UserStatusConstants.online;

  /// Check if user is blocked by me
  bool get isBlockedByMe => user?.blockedByMe == true;

  /// Check if user has blocked me
  bool get hasBlockedMe => user?.hasBlockedMe == true;

  /// Check if user is not blocked (either way)
  bool get userIsNotBlocked => !isBlockedByMe && !hasBlockedMe;

  /// Check if the user is an AI agent
  bool get isUserAgentic => user?.role == 'ai';

  @override
  List<Object?> get props => [
    status,
    user,
    group,
    memberCount,
    isTyping,
    typingUser,
    errorMessage,
    loggedInUser,
  ];

  /// Create a copy of this state with updated fields
  MessageHeaderState copyWith({
    MessageHeaderStatus? status,
    User? user,
    Group? group,
    int? memberCount,
    bool? isTyping,
    User? typingUser,
    String? errorMessage,
    User? loggedInUser,
    bool clearTypingUser = false,
  }) {
    return MessageHeaderState(
      status: status ?? this.status,
      user: user ?? this.user,
      group: group ?? this.group,
      memberCount: memberCount ?? this.memberCount,
      isTyping: isTyping ?? this.isTyping,
      typingUser: clearTypingUser ? null : (typingUser ?? this.typingUser),
      errorMessage: errorMessage ?? this.errorMessage,
      loggedInUser: loggedInUser ?? this.loggedInUser,
    );
  }
}
