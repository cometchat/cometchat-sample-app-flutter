import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for groups states
/// Uses Equatable for proper state comparison in BLoC
abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

/// Loading state when fetching initial groups
class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

/// Loaded state with group data
///
/// Contains the list of groups along with pagination and selection state.
/// Implements copyWith for immutable state updates (Requirement 1.4).
class GroupsLoaded extends GroupsState {
  /// Groups list
  final List<Group> groups;

  /// Whether more groups are available for pagination
  final bool hasMore;

  /// Flag indicating if pagination is in progress (Requirement 10.5)
  final bool isLoadingMore;

  /// Set of selected group GUIDs (Requirement 8.1)
  final Set<String> selectedGroups;

  /// Current search keyword for filtering
  final String? searchKeyword;

  const GroupsLoaded({
    required this.groups,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.selectedGroups = const {},
    this.searchKeyword,
  });

  @override
  List<Object?> get props => [
    groups,
    hasMore,
    isLoadingMore,
    selectedGroups,
    searchKeyword,
  ];

  /// Create a copy of this state with updated fields (Requirement 1.4)
  ///
  /// This method enables immutable state updates by creating a new instance
  /// with only the specified fields changed.
  GroupsLoaded copyWith({
    List<Group>? groups,
    bool? hasMore,
    bool? isLoadingMore,
    Set<String>? selectedGroups,
    String? searchKeyword,
  }) {
    return GroupsLoaded(
      groups: groups ?? this.groups,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

/// Empty state when no groups exist
class GroupsEmpty extends GroupsState {
  const GroupsEmpty();
}

/// Error state with error message and optional previous data
///
/// Preserves previous groups data to allow displaying cached content
/// while showing an error message.
class GroupsError extends GroupsState {
  /// Error message describing what went wrong
  final String message;

  /// Previously loaded groups, if any, for graceful degradation
  final List<Group>? previousGroups;

  const GroupsError({required this.message, this.previousGroups});

  @override
  List<Object?> get props => [message, previousGroups];
}
