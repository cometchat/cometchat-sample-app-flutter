import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/users_repository.dart';

/// Use case for getting the currently logged-in user
class GetLoggedInUserUseCase {
  final UsersRepository repository;

  const GetLoggedInUserUseCase(this.repository);

  /// Execute the use case to get the logged-in user
  ///
  /// Returns Result<User?> containing the user or failure
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
