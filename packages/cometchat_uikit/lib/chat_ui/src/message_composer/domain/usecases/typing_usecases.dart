import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_composer_repository.dart';

/// Use case for starting typing indicator
/// Single responsibility: notify that user started typing
class StartTypingUseCase {
  final MessageComposerRepository _repository;

  StartTypingUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result indicating success or failure
  Future<Result<void>> call({
    required String receiverUid,
    required String receiverType,
  }) {
    return _repository.startTyping(
      receiverUid: receiverUid,
      receiverType: receiverType,
    );
  }
}

/// Use case for ending typing indicator
/// Single responsibility: notify that user stopped typing
class EndTypingUseCase {
  final MessageComposerRepository _repository;

  EndTypingUseCase(this._repository);

  /// Execute the use case
  /// Returns a Result indicating success or failure
  Future<Result<void>> call({
    required String receiverUid,
    required String receiverType,
  }) {
    return _repository.endTyping(
      receiverUid: receiverUid,
      receiverType: receiverType,
    );
  }
}
