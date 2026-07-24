import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Status enum for message information state
enum MessageInformationStatus {
  /// Before initialization
  initial,

  /// During loading receipts
  loading,

  /// Ready to display
  loaded,

  /// Error occurred
  error,
}

/// Immutable state for message information
///
/// Uses Equatable for proper state comparison in BLoC.
/// Contains the parent message, receipts, and user/group context.
class MessageInformationState extends Equatable {
  /// Current status of the message information
  final MessageInformationStatus status;

  /// The parent message for which receipt information is displayed
  final BaseMessage? parentMessage;

  /// List of message receipts (read/delivered status per user)
  final List<MessageReceipt> receipts;

  /// The user in a 1-on-1 conversation (null for group conversations)
  final User? user;

  /// The group in a group conversation (null for 1-on-1 conversations)
  final Group? group;

  /// Error message when status is error
  final String? errorMessage;

  const MessageInformationState({
    this.status = MessageInformationStatus.initial,
    this.parentMessage,
    this.receipts = const [],
    this.user,
    this.group,
    this.errorMessage,
  });

  /// Returns true if this is a user (1-on-1) conversation
  bool get isUserConversation => user != null;

  /// Returns true if this is a group conversation
  bool get isGroupConversation => group != null;

  /// Returns true if the state has an error
  bool get hasError => status == MessageInformationStatus.error;

  /// Create a copy of this state with updated fields
  MessageInformationState copyWith({
    MessageInformationStatus? status,
    BaseMessage? parentMessage,
    List<MessageReceipt>? receipts,
    User? user,
    Group? group,
    String? errorMessage,
  }) {
    return MessageInformationState(
      status: status ?? this.status,
      parentMessage: parentMessage ?? this.parentMessage,
      receipts: receipts ?? this.receipts,
      user: user ?? this.user,
      group: group ?? this.group,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    parentMessage,
    receipts,
    user,
    group,
    errorMessage,
  ];
}
