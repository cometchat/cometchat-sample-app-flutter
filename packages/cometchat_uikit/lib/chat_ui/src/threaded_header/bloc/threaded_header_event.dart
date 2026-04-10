import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for all threaded header events
/// Uses Equatable for proper event comparison in BLoC
abstract class ThreadedHeaderEvent extends Equatable {
  const ThreadedHeaderEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the threaded header with parent message
class InitializeThreadedHeader extends ThreadedHeaderEvent {
  final BaseMessage parentMessage;
  final User loggedInUser;

  const InitializeThreadedHeader({
    required this.parentMessage,
    required this.loggedInUser,
  });

  @override
  List<Object?> get props => [parentMessage, loggedInUser];
}

/// Increment reply count when new message received
class IncrementReplyCount extends ThreadedHeaderEvent {
  const IncrementReplyCount();
}

/// Update parent message (edit/delete)
class UpdateParentMessage extends ThreadedHeaderEvent {
  final BaseMessage message;

  const UpdateParentMessage(this.message);

  @override
  List<Object?> get props => [message];
}
