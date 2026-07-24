import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all groups events
/// Uses Equatable for proper event comparison in BLoC
abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Load Events
// ============================================================================

/// Load initial groups
class LoadGroups extends GroupsEvent {
  final String? searchKeyword;
  final bool silent;

  const LoadGroups({this.searchKeyword, this.silent = false});

  @override
  List<Object?> get props => [searchKeyword, silent];
}

/// Load more groups (pagination)
class LoadMoreGroups extends GroupsEvent {
  const LoadMoreGroups();
}

/// Refresh groups list
class RefreshGroups extends GroupsEvent {
  const RefreshGroups();
}

/// Search groups by keyword
class SearchGroups extends GroupsEvent {
  final String keyword;

  const SearchGroups(this.keyword);

  @override
  List<Object> get props => [keyword];
}

// ============================================================================
// Selection Events
// ============================================================================

/// Toggle group selection
class ToggleGroupSelection extends GroupsEvent {
  final String guid;

  const ToggleGroupSelection(this.guid);

  @override
  List<Object> get props => [guid];
}

/// Clear all group selections
class ClearGroupSelection extends GroupsEvent {
  const ClearGroupSelection();
}

// ============================================================================
// CRUD Events
// ============================================================================

/// Update a specific group
class UpdateGroup extends GroupsEvent {
  final Group group;

  const UpdateGroup(this.group);

  @override
  List<Object> get props => [group];
}

/// Add a new group to the list
class AddGroup extends GroupsEvent {
  final Group group;

  const AddGroup(this.group);

  @override
  List<Object> get props => [group];
}

/// Remove a group from the list
class RemoveGroup extends GroupsEvent {
  final String guid;

  const RemoveGroup(this.guid);

  @override
  List<Object> get props => [guid];
}

// ============================================================================
// SDK Listener Events - Real-time Updates
// ============================================================================

/// Event triggered when a new group is created
/// This is an internal event dispatched by SDK listeners
class GroupCreated extends GroupsEvent {
  final Group group;

  const GroupCreated(this.group);

  @override
  List<Object> get props => [group];
}

/// Event triggered when a member joins a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberJoined extends GroupsEvent {
  final Action action;
  final User joinedUser;
  final Group group;

  const GroupMemberJoined({
    required this.action,
    required this.joinedUser,
    required this.group,
  });

  @override
  List<Object> get props => [action, joinedUser, group];
}

/// Event triggered when a member leaves a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberLeft extends GroupsEvent {
  final Action action;
  final User leftUser;
  final Group group;

  const GroupMemberLeft({
    required this.action,
    required this.leftUser,
    required this.group,
  });

  @override
  List<Object> get props => [action, leftUser, group];
}

/// Event triggered when a member is kicked from a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberKicked extends GroupsEvent {
  final Action action;
  final User kickedUser;
  final User kickedBy;
  final Group group;

  const GroupMemberKicked({
    required this.action,
    required this.kickedUser,
    required this.kickedBy,
    required this.group,
  });

  @override
  List<Object> get props => [action, kickedUser, kickedBy, group];
}

/// Event triggered when a member is banned from a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberBanned extends GroupsEvent {
  final Action action;
  final User bannedUser;
  final User bannedBy;
  final Group group;

  const GroupMemberBanned({
    required this.action,
    required this.bannedUser,
    required this.bannedBy,
    required this.group,
  });

  @override
  List<Object> get props => [action, bannedUser, bannedBy, group];
}

/// Event triggered when a member is unbanned from a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberUnbanned extends GroupsEvent {
  final Action action;
  final User unbannedUser;
  final User unbannedBy;
  final Group group;

  const GroupMemberUnbanned({
    required this.action,
    required this.unbannedUser,
    required this.unbannedBy,
    required this.group,
  });

  @override
  List<Object> get props => [action, unbannedUser, unbannedBy, group];
}

/// Event triggered when a member's scope changes in a group
/// This is an internal event dispatched by SDK listeners
class GroupMemberScopeChanged extends GroupsEvent {
  final Action action;
  final User updatedUser;
  final String scopeChangedTo;
  final String scopeChangedFrom;
  final Group group;

  const GroupMemberScopeChanged({
    required this.action,
    required this.updatedUser,
    required this.scopeChangedTo,
    required this.scopeChangedFrom,
    required this.group,
  });

  @override
  List<Object> get props => [
    action,
    updatedUser,
    scopeChangedTo,
    scopeChangedFrom,
    group,
  ];
}

/// Event triggered when group ownership is transferred
/// This is an internal event dispatched by SDK listeners
class GroupOwnershipTransferred extends GroupsEvent {
  final Group group;
  final GroupMember newOwner;

  const GroupOwnershipTransferred({
    required this.group,
    required this.newOwner,
  });

  @override
  List<Object> get props => [group, newOwner];
}

/// Event triggered when connection is restored
/// This is an internal event dispatched by connection listeners
class ConnectionRestored extends GroupsEvent {
  const ConnectionRestored();
}

/// Internal event for initializing logged-in user
/// This is used internally by the BLoC and should not be dispatched externally
class InitializeLoggedInUser extends GroupsEvent {
  final User? user;

  const InitializeLoggedInUser(this.user);

  @override
  List<Object?> get props => [user];
}
