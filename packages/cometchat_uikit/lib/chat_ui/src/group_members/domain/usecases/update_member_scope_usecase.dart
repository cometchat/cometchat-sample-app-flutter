import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/group_members_repository.dart';

/// Valid scope values for group members.
class GroupMemberScopes {
  static const String admin = 'admin';
  static const String moderator = 'moderator';
  static const String participant = 'participant';

  static const List<String> validScopes = [admin, moderator, participant];

  /// Check if a scope value is valid.
  static bool isValid(String scope) => validScopes.contains(scope);
}

/// Use case for updating a member's scope (role) within a group.
///
/// Handles validation of input parameters and delegates to the repository.
/// Returns a [Failure] for invalid inputs (empty guid, uid, or invalid scope).
class UpdateMemberScopeUseCase {
  final GroupMembersRepository repository;

  const UpdateMemberScopeUseCase(this.repository);

  /// Execute the use case to update a member's scope.
  ///
  /// [guid] - The group ID (must not be empty).
  /// [uid] - The user ID of the member (must not be empty).
  /// [scope] - The new scope ('admin', 'moderator', 'participant').
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> call({
    required String guid,
    required String uid,
    required String scope,
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

    // Validate scope
    if (scope.isEmpty) {
      return const Failure(
        message: 'Scope cannot be empty',
        code: 'INVALID_SCOPE',
      );
    }

    if (!GroupMemberScopes.isValid(scope)) {
      return Failure(
        message:
            'Invalid scope: $scope. Must be one of: ${GroupMemberScopes.validScopes.join(', ')}',
        code: 'INVALID_SCOPE',
      );
    }

    // Delegate to repository
    return await repository.updateMemberScope(
      guid: guid,
      uid: uid,
      scope: scope,
    );
  }
}
