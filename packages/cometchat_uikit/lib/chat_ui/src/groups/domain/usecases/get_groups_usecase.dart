import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/groups_repository.dart';

/// Use case for getting groups with pagination and search support
///
/// Encapsulates the business logic for fetching groups with configurable
/// limit and search keyword parameters.
///
/// Requirements: 3.1, 3.6
class GetGroupsUseCase {
  final GroupsRepository repository;

  const GetGroupsUseCase(this.repository);

  /// Reset the internal SDK pagination cursor.
  /// Call before a fresh load or when search keyword changes.
  void resetRequest() {
    repository.resetRequest();
  }

  /// Execute the use case to get groups
  ///
  /// [limit] - Maximum number of groups to fetch (default: 30)
  /// [searchKeyword] - Optional search keyword to filter groups by name
  /// [joinedOnly] - If true, only return groups the user has joined
  ///
  /// Returns `Result<List<Group>>` containing groups or failure
  Future<Result<List<Group>>> call({
    int limit = 30,
    String? searchKeyword,
    bool? joinedOnly,
  }) async {
    // Validate input parameters (Requirement 3.6)
    if (limit <= 0) {
      return const Failure(
        message: 'Limit must be greater than 0',
        code: 'INVALID_LIMIT',
      );
    }

    if (limit > 100) {
      return const Failure(
        message: 'Limit cannot exceed 100 groups',
        code: 'LIMIT_TOO_HIGH',
      );
    }

    return await repository.getGroups(
      limit: limit,
      searchKeyword: searchKeyword,
      joinedOnly: joinedOnly,
    );
  }
}
