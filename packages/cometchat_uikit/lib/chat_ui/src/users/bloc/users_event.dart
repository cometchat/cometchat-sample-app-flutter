import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all users events
/// Uses Equatable for proper event comparison in BLoC
abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial users
class LoadUsers extends UsersEvent {
  final String? searchKeyword;
  final bool silent;

  const LoadUsers({this.searchKeyword, this.silent = false});

  @override
  List<Object?> get props => [searchKeyword, silent];
}

/// Load more users (pagination)
class LoadMoreUsers extends UsersEvent {
  const LoadMoreUsers();
}

/// Refresh users list
class RefreshUsers extends UsersEvent {
  const RefreshUsers();
}

/// Search users
class SearchUsers extends UsersEvent {
  final String keyword;

  const SearchUsers(this.keyword);

  @override
  List<Object> get props => [keyword];
}

/// Toggle user selection
class ToggleUserSelection extends UsersEvent {
  final String uid;

  const ToggleUserSelection(this.uid);

  @override
  List<Object> get props => [uid];
}

/// Clear all user selections
class ClearUserSelection extends UsersEvent {
  const ClearUserSelection();
}

/// Update a specific user
class UpdateUser extends UsersEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object> get props => [user];
}
