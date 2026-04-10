import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/users_repository.dart';

/// Use case for getting a specific user by UID
class GetUserUseCase {
  final UsersRepository repository;

  const GetUserUseCase(this.repository);

  /// Execute the use case to get a user by UID
  ///
  /// [uid] - The UID of the user to fetch
  ///
  /// Returns Result<User> containing the user or failure
  Future<Result<User>> call(String uid) async {
    if (uid.isEmpty) {
      return const Failure(
        message: 'User ID cannot be empty',
        code: 'INVALID_UID',
      );
    }

    return await repository.getUserById(uid);
  }
}
