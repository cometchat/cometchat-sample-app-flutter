import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/conversations_repository.dart';

/// Use case for deleting a conversation
/// Handles business logic for conversation deletion
class DeleteConversationUseCase {
  final ConversationsRepository repository;

  const DeleteConversationUseCase(this.repository);

  /// Execute the use case to delete a conversation
  ///
  /// [conversationId] - ID of the conversation to delete
  ///
  /// Returns `Result<void>` indicating success or failure
  Future<Result<void>> call(String conversationId) async {
    // Validate input parameters
    if (conversationId.isEmpty) {
      return const Failure(
        message: 'Conversation ID cannot be empty',
        code: 'INVALID_CONVERSATION_ID',
      );
    }

    // Delegate to repository
    return await repository.deleteConversation(conversationId);
  }
}
