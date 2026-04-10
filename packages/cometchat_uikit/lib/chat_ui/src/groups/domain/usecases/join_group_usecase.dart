import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/groups_repository.dart';

/// Use case for joining a group
///
/// Handles business logic for joining public, password-protected, and private groups.
/// Validates input parameters and delegates to the repository.
///
/// Requirements: 3.3, 3.6
class JoinGroupUseCase {
  final GroupsRepository repository;

  /// Valid group types supported by CometChat
  static const String typePublic = 'public';
  static const String typePrivate = 'private';
  static const String typePassword = 'password';

  const JoinGroupUseCase(this.repository);

  /// Execute the use case to join a group
  ///
  /// [guid] - The unique identifier of the group to join
  /// [groupType] - The type of group (public, private, password)
  /// [password] - Required for password-protected groups
  ///
  /// Returns Result<Group> containing the joined group or failure
  Future<Result<Group>> call({
    required String guid,
    required String groupType,
    String? password,
  }) async {
    // Validate input parameters (Requirement 3.6)
    if (guid.isEmpty) {
      return const Failure(
        message: 'Group GUID cannot be empty',
        code: 'INVALID_GUID',
      );
    }

    if (groupType.isEmpty) {
      return const Failure(
        message: 'Group type cannot be empty',
        code: 'INVALID_GROUP_TYPE',
      );
    }

    // Validate group type is one of the supported types
    final validTypes = [typePublic, typePrivate, typePassword];
    if (!validTypes.contains(groupType.toLowerCase())) {
      return Failure(
        message: 'Invalid group type. Must be one of: ${validTypes.join(", ")}',
        code: 'INVALID_GROUP_TYPE',
      );
    }

    // Password is required for password-protected groups
    if (groupType.toLowerCase() == typePassword) {
      if (password == null || password.isEmpty) {
        return const Failure(
          message: 'Password is required for password-protected groups',
          code: 'PASSWORD_REQUIRED',
        );
      }
    }

    return await repository.joinGroup(
      guid: guid,
      groupType: groupType,
      password: password,
    );
  }
}
