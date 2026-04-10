import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/group_members_repository.dart';

/// Use case for loading more group members with pagination support.
/// Handles business logic for fetching additional group member pages
/// with deduplication against currently loaded members.
class LoadMoreGroupMembersUseCase {
  final GroupMembersRepository repository;

  const LoadMoreGroupMembersUseCase(this.repository);

  /// Execute the use case to load more group members.
  ///
  /// [guid] - The group ID to fetch members for (required, non-empty).
  /// [limit] - Maximum number of members to fetch (default: 30, must be positive).
  /// [searchKeyword] - Optional keyword to filter members by name.
  /// [currentMembers] - Currently loaded members to prevent duplicates.
  ///
  /// Returns [Result<List<GroupMember>>] containing additional members or failure.
  Future<Result<List<GroupMember>>> call({
    required String guid,
    int limit = 30,
    String? searchKeyword,
    List<GroupMember>? currentMembers,
  }) async {
    // Validate guid is not empty
    if (guid.isEmpty) {
      return const Failure(
        message: 'Group ID cannot be empty',
        code: 'INVALID_GUID',
      );
    }

    // Validate limit is positive
    if (limit <= 0) {
      return const Failure(
        message: 'Limit must be greater than 0',
        code: 'INVALID_LIMIT',
      );
    }

    // Delegate to repository to fetch more members
    final result = await repository.getGroupMembers(
      guid: guid,
      limit: limit,
      searchKeyword: searchKeyword,
    );

    // Handle deduplication if current members are provided
    return result.map((newMembers) {
      if (currentMembers == null || currentMembers.isEmpty) {
        return newMembers;
      }

      // Create a set of existing member UIDs for O(1) lookup
      final existingUids = currentMembers.map((m) => m.uid).toSet();

      // Filter out any members that already exist
      final filteredMembers = newMembers
          .where((member) => !existingUids.contains(member.uid))
          .toList();

      return filteredMembers;
    });
  }
}
