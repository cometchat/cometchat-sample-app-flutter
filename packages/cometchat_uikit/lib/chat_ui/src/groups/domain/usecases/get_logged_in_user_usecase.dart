import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/groups_repository.dart';

/// Use case for getting the currently logged-in user
///
/// Retrieves the currently authenticated user from the repository.
///
/// Requirements: 3.5
class GetLoggedInUserUseCase {
  final GroupsRepository repository;

  const GetLoggedInUserUseCase(this.repository);

  /// Execute the use case to get the logged-in user
  ///
  /// Returns Result<User?> containing the user or failure
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
