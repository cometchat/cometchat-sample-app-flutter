import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/ai_assistant_chat_history_repository.dart';
import '../datasources/ai_assistant_chat_history_remote_datasource.dart';

/// Implementation of [AIAssistantChatHistoryRepository].
/// Delegates to remote data source for SDK operations.
class AIAssistantChatHistoryRepositoryImpl
    implements AIAssistantChatHistoryRepository {
  final AIAssistantChatHistoryRemoteDataSource remoteDataSource;

  AIAssistantChatHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<BaseMessage>>> fetchMessages(
      MessagesRequest request) {
    return remoteDataSource.fetchMessages(request);
  }

  @override
  Future<Result<BaseMessage>> deleteMessage(int messageId) {
    return remoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<Result<User?>> getLoggedInUser() {
    return remoteDataSource.getLoggedInUser();
  }

  @override
  Future<Result<Conversation?>> getConversation(
    String conversationWith,
    String conversationType,
  ) {
    return remoteDataSource.getConversation(conversationWith, conversationType);
  }
}
