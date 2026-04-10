import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/group_members_repository.dart';

/// Use case for banning a member from a group.
///
/// Handles validation of input parameters and delegates to the repository.
/// Returns a [Failure] for invalid inputs (empty guid or uid).
class BanGroupMemberUseCase {
  final GroupMembersRepository repository;

  const BanGroupMemberUseCase(this.repository);

  /// Execute the use case to ban a member from a group.
  ///
  /// [guid] - The group ID (must not be empty).
  /// [uid] - The user ID of the member to ban (must not be empty).
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> call({
    required String guid,
    required String uid,
  }) async {
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
    return await repository.banGroupMember(guid: guid, uid: uid);
  }
}
