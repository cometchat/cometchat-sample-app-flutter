import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for editing messages
/// Single responsibility: edit a message via repository
class EditMessageUseCase {
  final MessageComposerRepository _repository;

  EditMessageUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result containing the edited BaseMessage or a Failure
  Future<Result<BaseMessage>> call(BaseMessage message) {
    return _repository.editMessage(message);
  }
}
