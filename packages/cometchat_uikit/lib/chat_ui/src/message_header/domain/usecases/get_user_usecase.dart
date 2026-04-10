import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_header_repository.dart';

/// Use case for getting a user by UID
class GetUserUseCase {
  final MessageHeaderRepository repository;

  const GetUserUseCase(this.repository);

  /// Execute the use case to get a user
  ///
  /// [uid] - The user ID to fetch
  ///
  /// Returns Result<User> containing user or failure
  Future<Result<User>> call(String uid) async {
    if (uid.isEmpty) {
      return const Failure(
        message: 'User ID cannot be empty',
        code: 'INVALID_UID',
      );
    }

    return await repository.getUser(uid);
  }
}
