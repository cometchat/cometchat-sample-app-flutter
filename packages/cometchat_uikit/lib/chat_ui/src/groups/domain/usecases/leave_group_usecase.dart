import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/groups_repository.dart';

/// Use case for leaving a group
///
/// Handles business logic for leaving a group and updating local state.
/// Validates input parameters and delegates to the repository.
///
/// Requirements: 3.4, 3.6
class LeaveGroupUseCase {
  final GroupsRepository repository;

  const LeaveGroupUseCase(this.repository);

  /// Execute the use case to leave a group
  ///
  /// [guid] - The unique identifier of the group to leave
  ///
  /// Returns `Result<void>` indicating success or failure
  Future<Result<void>> call({required String guid}) async {
    // Validate input parameters (Requirement 3.6)
    if (guid.isEmpty) {
      return const Failure(
        message: 'Group GUID cannot be empty',
        code: 'INVALID_GUID',
      );
    }

    return await repository.leaveGroup(guid);
  }
}
