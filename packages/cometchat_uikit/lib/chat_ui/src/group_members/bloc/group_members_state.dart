import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for group members states
/// Uses Equatable for proper state comparison in BLoC
abstract class GroupMembersState extends Equatable {
  const GroupMembersState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class GroupMembersInitial extends GroupMembersState {
  const GroupMembersInitial();
}

/// Loading state when fetching initial group members
class GroupMembersLoading extends GroupMembersState {
  const GroupMembersLoading();
}

/// Loaded state with group member data
///
/// Note: User status (online/offline) is managed separately via ValueNotifier per member
/// for optimized rebuilds. Use [GroupMembersBloc.getStatusNotifier] to access them.
class GroupMembersLoaded extends GroupMembersState {
  /// Group members list - SDK GroupMember extends User which extends Equatable
  final List<GroupMember> members;

  /// Whether more members can be loaded (pagination)
  final bool hasMore;

  /// Set of selected member UIDs for selection mode
  final Set<String> selectedMembers;

  /// Whether pagination is currently loading more members
  final bool isLoadingMore;

  /// Current search keyword filter
  final String? searchKeyword;

  const GroupMembersLoaded({
    required this.members,
    this.hasMore = true,
    this.selectedMembers = const {},
    this.isLoadingMore = false,
    this.searchKeyword,
  });

  @override
  List<Object?> get props => [
        members,
        hasMore,
        selectedMembers,
        isLoadingMore,
        searchKeyword,
      ];

  /// Create a copy of this state with updated fields
  GroupMembersLoaded copyWith({
    List<GroupMember>? members,
    bool? hasMore,
    Set<String>? selectedMembers,
    bool? isLoadingMore,
    String? searchKeyword,
  }) {
    return GroupMembersLoaded(
      members: members ?? this.members,
      hasMore: hasMore ?? this.hasMore,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

/// Empty state when no group members exist
class GroupMembersEmpty extends GroupMembersState {
  const GroupMembersEmpty();
}

/// Error state with error message and optional previous data
class GroupMembersError extends GroupMembersState {
  /// Error message describing what went wrong
  final String message;

  /// Previous members list for recovery/retry scenarios
  final List<GroupMember>? previousMembers;

  const GroupMembersError({
    required this.message,
    this.previousMembers,
  });

  @override
  List<Object?> get props => [message, previousMembers];
}
