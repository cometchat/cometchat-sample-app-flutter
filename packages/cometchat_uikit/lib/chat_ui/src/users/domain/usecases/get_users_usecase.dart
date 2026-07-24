import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/users_repository.dart';

/// Use case for getting users with pagination and search support
class GetUsersUseCase {
  final UsersRepository repository;

  const GetUsersUseCase(this.repository);

  /// Reset the internal SDK pagination cursor.
  /// Call before a fresh load or when search keyword changes.
  void resetRequest() {
    repository.resetRequest();
  }

  /// Execute the use case to get users
  ///
  /// [limit] - Maximum number of users to fetch (default: 30)
  /// [searchKeyword] - Optional search keyword to filter users
  /// [usersRequestBuilder] - Optional custom request builder for filtering
  ///
  /// Returns `Result<List<User>>` containing users or failure
  Future<Result<List<User>>> call({
    int limit = 30,
    String? searchKeyword,
    UsersRequestBuilder? usersRequestBuilder,
  }) async {
    if (limit <= 0) {
      return const Failure(
        message: 'Limit must be greater than 0',
        code: 'INVALID_LIMIT',
      );
    }

    if (limit > 100) {
      return const Failure(
        message: 'Limit cannot exceed 100 users',
        code: 'LIMIT_TOO_HIGH',
      );
    }

    return await repository.getUsers(
      limit: limit,
      searchKeyword: searchKeyword,
      usersRequestBuilder: usersRequestBuilder,
    );
  }
}
