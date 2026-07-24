import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for getting messages for a conversation.
///
/// **Validates: Requirements 3.1, 3.7**
class GetMessagesUseCase {
  final MessageListRepository repository;

  const GetMessagesUseCase(this.repository);

  /// Execute the use case to get messages for a conversation.
  Future<Result<List<BaseMessage>>> call({
    required String conversationWith,
    required String conversationType,
    int limit = 30,
    int? parentMessageId,
    List<String>? types,
    List<String>? categories,
    bool hideReplies = true,
    bool withParent = true,
  }) async {
    if (conversationWith.isEmpty) {
      return const Failure(
        message: 'Conversation ID cannot be empty',
        code: 'INVALID_CONVERSATION_ID',
      );
    }

    if (conversationType != 'user' && conversationType != 'group') {
      return const Failure(
        message: 'Conversation type must be either "user" or "group"',
        code: 'INVALID_CONVERSATION_TYPE',
      );
    }

    if (limit < 1) {
      return const Failure(
        message: 'Limit must be at least 1',
        code: 'INVALID_LIMIT',
      );
    }

    if (limit > 100) {
      return const Failure(
        message: 'Limit cannot exceed 100 messages',
        code: 'LIMIT_TOO_HIGH',
      );
    }

    return await repository.getMessages(
      conversationWith: conversationWith,
      conversationType: conversationType,
      limit: limit,
      parentMessageId: parentMessageId,
      types: types,
      categories: categories,
      hideReplies: hideReplies,
      withParent: withParent,
    );
  }
}
