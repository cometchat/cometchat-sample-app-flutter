import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for sending text messages
/// Single responsibility: send a text message via repository
class SendTextMessageUseCase {
  final MessageComposerRepository _repository;

  SendTextMessageUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result containing the sent TextMessage or a Failure
  Future<Result<TextMessage>> call(TextMessage message) {
    return _repository.sendTextMessage(message);
  }
}
