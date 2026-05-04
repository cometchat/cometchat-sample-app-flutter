import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/ai_assistant_chat_history_repository.dart';

/// Use case for getting the currently logged-in user.
class GetLoggedInUserUseCase {
  final AIAssistantChatHistoryRepository _repository;

  GetLoggedInUserUseCase(this._repository);

  Future<Result<User?>> call() {
    return _repository.getLoggedInUser();
  }
}
