import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/conversations_repository.dart';

/// Use case for getting a single conversation
/// Handles business logic for fetching conversation details
class GetConversationUseCase {
  final ConversationsRepository repository;

  const GetConversationUseCase(this.repository);

  /// Execute the use case to get a conversation
  ///
  /// [conversationWith] - UID/GUID of the user/group
  /// [conversationType] - Type of conversation ('user' or 'group')
  ///
  /// Returns `Result<Conversation>` containing conversation or failure
  Future<Result<Conversation>> call({
    required String conversationWith,
    required String conversationType,
  }) async {
    // Validate input parameters
    if (conversationWith.isEmpty) {
      return const Failure(
        message: 'Conversation ID cannot be empty',
        code: 'INVALID_CONVERSATION_ID',
      );
    }

    if (conversationType != 'user' && conversationType != 'group') {
      return const Failure(
        message: 'Conversation type must be "user" or "group"',
        code: 'INVALID_CONVERSATION_TYPE',
      );
    }

    return await repository.getConversation(
      conversationWith: conversationWith,
      conversationType: conversationType,
    );
  }
}
