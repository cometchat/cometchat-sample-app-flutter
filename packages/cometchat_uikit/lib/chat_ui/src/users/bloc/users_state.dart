import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for users states
/// Uses Equatable for proper state comparison in BLoC
abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class UsersInitial extends UsersState {
  const UsersInitial();
}

/// Loading state when fetching initial users
class UsersLoading extends UsersState {
  const UsersLoading();
}

/// Loaded state with user data
class UsersLoaded extends UsersState {
  /// Users list
  final List<User> users;

  final bool hasMore;
  final Set<String> selectedUsers;
  final bool isLoadingMore;
  final String? searchKeyword;

  const UsersLoaded({
    required this.users,
    this.hasMore = true,
    this.selectedUsers = const {},
    this.isLoadingMore = false,
    this.searchKeyword,
  });

  @override
  List<Object?> get props => [
    users,
    hasMore,
    selectedUsers,
    isLoadingMore,
    searchKeyword,
  ];

  /// Create a copy of this state with updated fields
  UsersLoaded copyWith({
    List<User>? users,
    bool? hasMore,
    Set<String>? selectedUsers,
    bool? isLoadingMore,
    String? searchKeyword,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

/// Empty state when no users exist
class UsersEmpty extends UsersState {
  const UsersEmpty();
}

/// Error state with error message and optional previous data
class UsersError extends UsersState {
  final String message;
  final List<User>? previousUsers;

  const UsersError({required this.message, this.previousUsers});

  @override
  List<Object?> get props => [message, previousUsers];
}
