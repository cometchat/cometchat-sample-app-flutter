import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for getting the currently logged-in user.
///
/// **Validates: Requirements 3.6**
class GetLoggedInUserUseCase {
  final MessageListRepository repository;

  const GetLoggedInUserUseCase(this.repository);

  /// Execute the use case to get the currently logged-in user.
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
