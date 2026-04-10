import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/users_repository.dart';

/// Use case for blocking a user
class BlockUserUseCase {
  final UsersRepository repository;

  const BlockUserUseCase(this.repository);

  /// Execute the use case to block a user
  ///
  /// [uid] - The UID of the user to block
  ///
  /// Returns Result<void> indicating success or failure
  Future<Result<void>> call(String uid) async {
    if (uid.isEmpty) {
      return const Failure(
        message: 'User ID cannot be empty',
        code: 'INVALID_UID',
      );
    }

    return await repository.blockUser(uid);
  }
}
