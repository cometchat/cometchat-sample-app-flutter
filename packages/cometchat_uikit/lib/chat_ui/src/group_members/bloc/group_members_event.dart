import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for all group members events
/// Uses Equatable for proper event comparison in BLoC
abstract class GroupMembersEvent extends Equatable {
  const GroupMembersEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Load Events
// ============================================================================

/// Load initial group members
class LoadGroupMembers extends GroupMembersEvent {
  const LoadGroupMembers();
}

/// Load more group members (pagination)
class LoadMoreGroupMembers extends GroupMembersEvent {
  const LoadMoreGroupMembers();
}

/// Refresh group members list
class RefreshGroupMembers extends GroupMembersEvent {
  const RefreshGroupMembers();
}

/// Search group members by keyword
class SearchGroupMembers extends GroupMembersEvent {
  final String keyword;

  const SearchGroupMembers(this.keyword);

  @override
  List<Object> get props => [keyword];
}

// ============================================================================
// Selection Events
// ============================================================================

/// Toggle member selection
class ToggleMemberSelection extends GroupMembersEvent {
  final String uid;

  const ToggleMemberSelection(this.uid);

  @override
  List<Object> get props => [uid];
}

/// Clear all member selections
class ClearMemberSelection extends GroupMembersEvent {
  const ClearMemberSelection();
}

// ============================================================================
// Member Action Events
// ============================================================================

/// Kick a member from the group
class KickMember extends GroupMembersEvent {
  final GroupMember member;

  const KickMember(this.member);

  @override
  List<Object> get props => [member];
}

/// Ban a member from the group
class BanMember extends GroupMembersEvent {
  final GroupMember member;

  const BanMember(this.member);

  @override
  List<Object> get props => [member];
}

/// Change a member's scope (admin, moderator, participant)
class ChangeMemberScope extends GroupMembersEvent {
  final GroupMember member;
  final String newScope;

  const ChangeMemberScope({
    required this.member,
    required this.newScope,
  });

  @override
  List<Object> get props => [member, newScope];
}

/// Update a specific member
class UpdateMember extends GroupMembersEvent {
  final GroupMember member;

  const UpdateMember(this.member);

  @override
  List<Object> get props => [member];
}
