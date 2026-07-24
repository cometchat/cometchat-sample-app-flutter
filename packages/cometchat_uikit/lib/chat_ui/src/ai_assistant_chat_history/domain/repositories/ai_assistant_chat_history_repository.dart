import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for AI Assistant Chat History data operations.
/// Defines the contract for fetching and managing AI conversation history.
abstract class AIAssistantChatHistoryRepository {
  /// Fetch messages using a pre-built [MessagesRequest].
  /// Returns paginated messages for the AI assistant conversation.
  Future<Result<List<BaseMessage>>> fetchMessages(MessagesRequest request);

  /// Delete a message by its ID.
  Future<Result<BaseMessage>> deleteMessage(int messageId);

  /// Get the currently logged-in user.
  Future<Result<User?>> getLoggedInUser();

  /// Get a conversation by conversationWith ID and type.
  Future<Result<Conversation?>> getConversation(
    String conversationWith,
    String conversationType,
  );
}
