import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/group_members_repository.dart';

/// Use case for kicking a member from a group.
///
/// Handles validation of input parameters and delegates to the repository.
/// Returns a [Failure] for invalid inputs (empty guid or uid).
class KickGroupMemberUseCase {
  final GroupMembersRepository repository;

  const KickGroupMemberUseCase(this.repository);

  /// Execute the use case to kick a member from a group.
  ///
  /// [guid] - The group ID (must not be empty).
  /// [uid] - The user ID of the member to kick (must not be empty).
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> call({required String guid, required String uid}) async {
    // Validate guid
    if (guid.isEmpty) {
      return const Failure(
        message: 'Group ID cannot be empty',
        code: 'INVALID_GUID',
      );
    }

    // Validate uid
    if (uid.isEmpty) {
      return const Failure(
        message: 'User ID cannot be empty',
        code: 'INVALID_UID',
      );
    }

    // Delegate to repository
    return await repository.kickGroupMember(guid: guid, uid: uid);
  }
}
