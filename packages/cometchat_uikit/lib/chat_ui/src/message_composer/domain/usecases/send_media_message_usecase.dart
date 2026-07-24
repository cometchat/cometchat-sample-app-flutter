import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for sending media messages
/// Single responsibility: send a media message via repository
class SendMediaMessageUseCase {
  final MessageComposerRepository _repository;

  SendMediaMessageUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result containing the sent MediaMessage or a Failure
  Future<Result<MediaMessage>> call(MediaMessage message) {
    return _repository.sendMediaMessage(message);
  }
}
