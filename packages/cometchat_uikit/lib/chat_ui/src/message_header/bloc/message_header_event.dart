import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for all message header events
/// Uses Equatable for proper event comparison in BLoC
abstract class MessageHeaderEvent extends Equatable {
  const MessageHeaderEvent();

  @override
  List<Object?> get props => [];
}

/// Set user for the message header
class SetUser extends MessageHeaderEvent {
  final User user;

  const SetUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// Set group for the message header
class SetGroup extends MessageHeaderEvent {
  final Group group;

  const SetGroup(this.group);

  @override
  List<Object?> get props => [group];
}

/// Refresh user data from SDK
class RefreshUser extends MessageHeaderEvent {
  const RefreshUser();
}

/// Refresh group data from SDK
class RefreshGroup extends MessageHeaderEvent {
  const RefreshGroup();
}

/// Update user status (online/offline)
class UpdateUserStatus extends MessageHeaderEvent {
  final String userId;
  final String status;
  final DateTime? lastActiveAt;

  const UpdateUserStatus({
    required this.userId,
    required this.status,
    this.lastActiveAt,
  });

  @override
  List<Object?> get props => [userId, status, lastActiveAt];
}

/// Update group member count
class UpdateGroupMemberCount extends MessageHeaderEvent {
  final String groupId;
  final int memberCount;

  const UpdateGroupMemberCount({
    required this.groupId,
    required this.memberCount,
  });

  @override
  List<Object?> get props => [groupId, memberCount];
}

/// Update group details
class UpdateGroupDetails extends MessageHeaderEvent {
  final Group group;

  const UpdateGroupDetails(this.group);

  @override
  List<Object?> get props => [group];
}

/// Typing started event
class TypingStarted extends MessageHeaderEvent {
  final TypingIndicator typingIndicator;

  const TypingStarted(this.typingIndicator);

  @override
  List<Object?> get props => [typingIndicator];
}

/// Typing ended event
class TypingEnded extends MessageHeaderEvent {
  final TypingIndicator typingIndicator;

  const TypingEnded(this.typingIndicator);

  @override
  List<Object?> get props => [typingIndicator];
}

/// User blocked event
class UserBlocked extends MessageHeaderEvent {
  final User user;

  const UserBlocked(this.user);

  @override
  List<Object?> get props => [user];
}

/// User unblocked event
class UserUnblocked extends MessageHeaderEvent {
  final User user;

  const UserUnblocked(this.user);

  @override
  List<Object?> get props => [user];
}

/// Group ownership changed event
class GroupOwnershipChanged extends MessageHeaderEvent {
  final Group group;
  final GroupMember newOwner;

  const GroupOwnershipChanged({
    required this.group,
    required this.newOwner,
  });

  @override
  List<Object?> get props => [group, newOwner];
}


/// Internal event for initializing logged-in user
/// This is used internally by the BLoC and should not be dispatched externally
class InitializeLoggedInUser extends MessageHeaderEvent {
  final User? user;

  const InitializeLoggedInUser(this.user);

  @override
  List<Object?> get props => [user];
}
