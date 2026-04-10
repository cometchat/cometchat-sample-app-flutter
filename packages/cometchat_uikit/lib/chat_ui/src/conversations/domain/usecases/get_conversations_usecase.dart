import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/conversations_repository.dart';

/// Use case for getting conversations with pagination support
/// Handles business logic for fetching conversation lists
class GetConversationsUseCase {
  final ConversationsRepository repository;

  const GetConversationsUseCase(this.repository);

  /// Execute the use case to get conversations
  /// 
  /// [limit] - Maximum number of conversations to fetch (default: 30)
  /// [fromId] - ID to start pagination from (optional)
  /// 
  /// Returns Result<List<Conversation>> containing conversations or failure
  Future<Result<List<Conversation>>> call({
    int limit = 30,
    String? fromId,
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

    // Delegate to repository
    return await repository.getConversations(
      limit: limit,
      fromId: fromId,
    );
  }
}