import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for conversations data operations
/// Defines the contract for conversation data access
abstract class ConversationsRepository {
  /// Get conversations with optional pagination.
  ///
  /// When [requestBuilder] is supplied, the caller's filter-shaping fields
  /// (tags, userTags, groupTags, withTags, withUserAndGroupTags,
  /// includeBlockedUsers, withBlockedInfo, conversationType, unread) are
  /// forwarded to the underlying data source.
  Future<Result<List<Conversation>>> getConversations({
    int limit = 30,
    String? fromId,
    ConversationsRequestBuilder? requestBuilder,
  });

  /// Get a specific conversation by ID
  Future<Result<Conversation>> getConversationById(String conversationId);

  /// Delete a conversation
  Future<Result<void>> deleteConversation(String conversationId);

  /// Update a conversation
  Future<Result<Conversation>> updateConversation(
    Conversation conversation,
  );

  /// Get the currently logged-in user
  Future<Result<User?>> getLoggedInUser();

  /// Mark a message as delivered
  Future<Result<void>> markAsDelivered(BaseMessage message);

  /// Get a conversation by conversation with ID and type
  Future<Result<Conversation>> getConversation({
    required String conversationWith,
    required String conversationType,
  });
}