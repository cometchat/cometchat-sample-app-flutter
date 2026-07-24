import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for getting the logged-in user
/// Single responsibility: retrieve the currently logged-in user
class GetMessageComposerLoggedInUserUseCase {
  final MessageComposerRepository _repository;

  GetMessageComposerLoggedInUserUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result containing the logged-in User or null, or a Failure
  Future<Result<User?>> call() {
    return _repository.getLoggedInUser();
  }
}
