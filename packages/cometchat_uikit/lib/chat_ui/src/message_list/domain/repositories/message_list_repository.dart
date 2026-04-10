import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for message list data operations.
///
/// This interface defines the contract for message data access,
/// abstracting the CometChat SDK operations behind a clean interface.
/// All methods return [Result<T>] types for consistent error handling.
///
/// Example usage:
/// ```dart
/// final result = await repository.getMessages(
///   conversationWith: 'user123',
///   conversationType: 'user',
///   limit: 30,
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (messages) => print('Loaded ${messages.length} messages'),
/// );
/// ```
abstract class MessageListRepository {
  /// Fetch messages for a conversation.
  ///
  /// [conversationWith] - The ID of the user or group to fetch messages for.
  /// [conversationType] - Either 'user' or 'group'.
  /// [limit] - Maximum number of messages to fetch (default: 30).
  /// [parentMessageId] - If provided, fetches thread replies for this message.
  /// [types] - Optional list of message types to include.
  /// [categories] - Optional list of message categories to include.
  /// [hideReplies] - Whether to hide thread replies in main list (default: true).
  ///
  /// Returns [Result<List<BaseMessage>>] containing the messages or a failure.
  Future<Result<List<BaseMessage>>> getMessages({
    required String conversationWith,
    required String conversationType,
    int limit = 30,
    int? parentMessageId,
    List<String>? types,
    List<String>? categories,
    bool hideReplies = true,
  });

  /// Fetch older messages for pagination (scroll up).
  Future<Result<List<BaseMessage>>> fetchPreviousMessages({
    required MessagesRequest request,
  });

  /// Fetch newer messages for pagination (scroll down).
  Future<Result<List<BaseMessage>>> fetchNextMessages({
    required MessagesRequest request,
  });

  /// Mark a message as read.
  Future<Result<void>> markAsRead(BaseMessage message);

  /// Mark a message as delivered.
  Future<Result<void>> markAsDelivered(BaseMessage message);

  /// Get the currently logged-in user.
  Future<Result<User?>> getLoggedInUser();

  /// Get conversation by ID and type.
  Future<Result<Conversation>> getConversation({
    required String conversationWith,
    required String conversationType,
  });

  /// Mark a message as unread.
  Future<Result<Conversation>> markMessageAsUnread(BaseMessage message);
}
