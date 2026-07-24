import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/group_members_repository.dart';

/// Use case for getting the currently logged-in user.
///
/// Retrieves the authenticated user from the repository.
/// No input validation is needed as this operation has no parameters.
class GetLoggedInUserUseCase {
  final GroupMembersRepository repository;

  const GetLoggedInUserUseCase(this.repository);

  /// Execute the use case to get the logged-in user.
  ///
  /// Returns [Result<User?>] containing the logged-in user or null,
  /// or a [Failure] with error details if the operation fails.
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
