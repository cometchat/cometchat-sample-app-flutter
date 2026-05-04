import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/ai_assistant_chat_history_repository.dart';

/// Use case for deleting a message from AI assistant chat history.
class DeleteChatHistoryMessageUseCase {
  final AIAssistantChatHistoryRepository _repository;

  DeleteChatHistoryMessageUseCase(this._repository);

  Future<Result<BaseMessage>> call(int messageId) {
    return _repository.deleteMessage(messageId);
  }
}
