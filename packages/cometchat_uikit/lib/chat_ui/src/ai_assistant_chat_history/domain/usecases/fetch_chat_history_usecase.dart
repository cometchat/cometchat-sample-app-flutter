import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/ai_assistant_chat_history_repository.dart';

/// Use case for fetching AI assistant chat history messages.
class FetchChatHistoryUseCase {
  final AIAssistantChatHistoryRepository _repository;

  FetchChatHistoryUseCase(this._repository);

  Future<Result<List<BaseMessage>>> call(MessagesRequest request) {
    return _repository.fetchMessages(request);
  }
}
