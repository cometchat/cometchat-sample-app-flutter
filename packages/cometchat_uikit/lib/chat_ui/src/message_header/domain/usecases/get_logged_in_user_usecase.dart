import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_header_repository.dart';

/// Use case for getting the logged-in user
class GetMessageHeaderLoggedInUserUseCase {
  final MessageHeaderRepository repository;

  const GetMessageHeaderLoggedInUserUseCase(this.repository);

  /// Execute the use case to get the logged-in user
  ///
  /// Returns `Result<User?>` containing user or failure
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
