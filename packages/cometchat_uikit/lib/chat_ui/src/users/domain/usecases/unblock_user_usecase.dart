import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/users_repository.dart';

/// Use case for unblocking a user
class UnblockUserUseCase {
  final UsersRepository repository;

  const UnblockUserUseCase(this.repository);

  /// Execute the use case to unblock a user
  ///
  /// [uid] - The UID of the user to unblock
  ///
  /// Returns `Result<void>` indicating success or failure
  Future<Result<void>> call(String uid) async {
    if (uid.isEmpty) {
      return const Failure(
        message: 'User ID cannot be empty',
        code: 'INVALID_UID',
      );
    }

    return await repository.unblockUser(uid);
  }
}
