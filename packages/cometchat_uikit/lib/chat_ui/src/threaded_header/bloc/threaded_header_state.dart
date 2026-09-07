import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Status enum for threaded header state
enum ThreadedHeaderStatus {
  /// Before initialization
  initial,

  /// During initialization
  loading,

  /// Ready to display
  loaded,

  /// Error occurred
  error,
}

/// Immutable state for threaded header
///
/// Uses Equatable for proper state comparison in BLoC.
/// Contains the parent message, reply count, and user/group context.
class ThreadedHeaderState extends Equatable {
  /// Current status of the threaded header
  final ThreadedHeaderStatus status;

  /// The parent message that started the thread
  final BaseMessage? parentMessage;

  /// Number of replies to the parent message
  final int replyCount;

  /// The currently logged in user
  final User? loggedInUser;

  /// The user in a 1-on-1 conversation (null for group conversations)
  final User? user;

  /// The group in a group conversation (null for 1-on-1 conversations)
  final Group? group;

  /// Error message when status is error
  final String? errorMessage;

  /// Whether the logged-in user follows this thread. Read off the parent
  /// message (stateless redesign); `false` renders as the un-followed
  /// affordance, enabled — never a spinner or a disabled control.
  final bool threadSubscribed;

  const ThreadedHeaderState({
    this.status = ThreadedHeaderStatus.initial,
    this.parentMessage,
    this.replyCount = 0,
    this.loggedInUser,
    this.user,
    this.group,
    this.errorMessage,
    this.threadSubscribed = false,
  });

  /// Returns true if the state has an error
  bool get hasError => errorMessage != null;

  /// Create a copy of this state with updated fields
  ThreadedHeaderState copyWith({
    ThreadedHeaderStatus? status,
    BaseMessage? parentMessage,
    int? replyCount,
    User? loggedInUser,
    User? user,
    Group? group,
    String? errorMessage,
    bool? threadSubscribed,
  }) {
    return ThreadedHeaderState(
      status: status ?? this.status,
      parentMessage: parentMessage ?? this.parentMessage,
      replyCount: replyCount ?? this.replyCount,
      loggedInUser: loggedInUser ?? this.loggedInUser,
      user: user ?? this.user,
      group: group ?? this.group,
      errorMessage: errorMessage ?? this.errorMessage,
      threadSubscribed: threadSubscribed ?? this.threadSubscribed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    parentMessage,
    replyCount,
    loggedInUser,
    user,
    group,
    errorMessage,
    threadSubscribed,
  ];
}
