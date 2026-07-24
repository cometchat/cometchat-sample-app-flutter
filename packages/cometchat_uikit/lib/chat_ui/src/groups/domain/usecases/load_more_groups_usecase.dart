import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/groups_repository.dart';

/// Use case for loading more groups with pagination support
///
/// Handles business logic for fetching additional group pages with
/// deduplication to prevent duplicate groups in the list.
///
/// Requirements: 3.2, 3.6
class LoadMoreGroupsUseCase {
  final GroupsRepository repository;

  const LoadMoreGroupsUseCase(this.repository);

  /// Execute the use case to load more groups
  ///
  /// [limit] - Maximum number of groups to fetch (default: 30)
  /// [searchKeyword] - Optional search keyword to filter groups by name
  /// [joinedOnly] - If true, only return groups the user has joined
  /// [currentGroups] - Currently loaded groups to prevent duplicates
  ///
  /// Returns `Result<List<Group>>` containing additional groups or failure
  Future<Result<List<Group>>> call({
    int limit = 30,
    String? searchKeyword,
    bool? joinedOnly,
    List<Group>? currentGroups,
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

    // Delegate to repository to fetch more groups
    final result = await repository.getGroups(
      limit: limit,
      searchKeyword: searchKeyword,
      joinedOnly: joinedOnly,
    );

    // Handle deduplication if current groups are provided (Requirement 3.2)
    return result.map((newGroups) {
      if (currentGroups == null || currentGroups.isEmpty) {
        return newGroups;
      }

      // Create a set of existing group GUIDs for O(1) lookup
      final existingGuids = currentGroups.map((g) => g.guid).toSet();

      // Filter out any groups that already exist (deduplication by GUID)
      final filteredGroups = newGroups
          .where((group) => !existingGuids.contains(group.guid))
          .toList();

      return filteredGroups;
    });
  }
}
