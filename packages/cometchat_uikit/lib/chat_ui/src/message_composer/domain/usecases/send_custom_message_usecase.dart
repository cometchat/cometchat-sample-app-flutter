import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for sending custom messages
/// Single responsibility: send a custom message via repository
class SendCustomMessageUseCase {
  final MessageComposerRepository _repository;

  SendCustomMessageUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result containing the sent CustomMessage or a Failure
  Future<Result<CustomMessage>> call(CustomMessage message) {
    return _repository.sendCustomMessage(message);
  }
}
