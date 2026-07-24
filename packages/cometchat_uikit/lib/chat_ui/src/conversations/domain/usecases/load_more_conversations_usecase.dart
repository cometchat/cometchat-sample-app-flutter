import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/conversations_repository.dart';

/// Use case for loading more conversations with pagination support
/// Handles business logic for fetching additional conversation pages
class LoadMoreConversationsUseCase {
  final ConversationsRepository repository;

  const LoadMoreConversationsUseCase(this.repository);

  /// Execute the use case to load more conversations
  ///
  /// [limit] - Maximum number of conversations to fetch (default: 30)
  /// [fromId] - ID to start pagination from (required for load more)
  /// [currentConversations] - Currently loaded conversations to prevent duplicates
  /// [requestBuilder] - Optional caller-provided builder whose filter fields
  ///   are forwarded to the repository.
  ///
  /// Returns `Result<List<Conversation>>` containing additional conversations or failure
  Future<Result<List<Conversation>>> call({
    int limit = 30,
    required String fromId,
    List<Conversation>? currentConversations,
    ConversationsRequestBuilder? requestBuilder,
  }) async {
    // Validate input parameters
    if (limit <= 0) {
      return const Failure(
        message: 'Limit must be greater than 0',
        code: 'INVALID_LIMIT',
      );
    }

    if (limit > 100) {
      return const Failure(
        message: 'Limit cannot exceed 100 conversations',
        code: 'LIMIT_TOO_HIGH',
      );
    }

    if (fromId.isEmpty) {
      return const Failure(
        message: 'fromId is required for pagination',
        code: 'MISSING_FROM_ID',
      );
    }

    // Delegate to repository to fetch more conversations
    final result = await repository.getConversations(
      limit: limit,
      fromId: fromId,
      requestBuilder: requestBuilder,
    );

    // Handle deduplication if current conversations are provided
    return result.map((newConversations) {
      if (currentConversations == null || currentConversations.isEmpty) {
        return newConversations;
      }

      // Create a set of existing conversation IDs for efficient lookup
      final existingIds = currentConversations
          .map((c) => c.conversationId)
          .toSet();

      // Filter out any conversations that already exist
      final filteredConversations = newConversations
          .where(
            (conversation) =>
                !existingIds.contains(conversation.conversationId),
          )
          .toList();

      return filteredConversations;
    });
  }
}
