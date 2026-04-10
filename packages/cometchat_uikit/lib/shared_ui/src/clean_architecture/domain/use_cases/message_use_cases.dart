import '../entities/message_entity.dart';
import '../repositories/repositories.dart';
import '../../core/result.dart';

/// Base use case class
/// All use cases should extend this class
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Get messages use case
/// Retrieves messages from a conversation with caching and filtering
class GetMessagesUseCase implements UseCase<List<MessageEntity>, GetMessagesParams> {
  final MessageRepository repository;

  GetMessagesUseCase({required this.repository});

  @override
  Future<Result<List<MessageEntity>>> call(GetMessagesParams params) async {
    // Validate parameters
    if (params.conversationId.isEmpty) {
      return const Failure(
        message: 'Conversation ID is required',
        code: 'INVALID_PARAMS',
      );
    }

    // Fetch from repository
    final result = await repository.getMessages(
      conversationId: params.conversationId,
      limit: params.limit,
      offset: params.offset,
    );

    // Apply business logic: filter deleted messages, sort by timestamp
    return result.map((messages) {
      return messages
          .where((msg) => !msg.isDeleted)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }
}

class GetMessagesParams {
  final String conversationId;
  final int limit;
  final int offset;

  GetMessagesParams({
    required this.conversationId,
    this.limit = 50,
    this.offset = 0,
  });
}

/// Send message use case
/// Handles message sending with validation and error handling
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final MessageRepository repository;

  SendMessageUseCase({required this.repository});

  @override
  Future<Result<MessageEntity>> call(SendMessageParams params) async {
    // Validate message
    if (params.text.isEmpty) {
      return const Failure(
        message: 'Message text cannot be empty',
        code: 'EMPTY_MESSAGE',
      );
    }

    if (params.conversationId.isEmpty) {
      return const Failure(
        message: 'Conversation ID is required',
        code: 'INVALID_PARAMS',
      );
    }

    // Trim whitespace
    final trimmedText = params.text.trim();

    // Send message
    return await repository.sendMessage(
      conversationId: params.conversationId,
      text: trimmedText,
      metadata: params.metadata,
    );
  }
}

class SendMessageParams {
  final String conversationId;
  final String text;
  final Map<String, dynamic>? metadata;

  SendMessageParams({
    required this.conversationId,
    required this.text,
    this.metadata,
  });
}

/// Search messages use case
/// Searches messages with query validation
class SearchMessagesUseCase implements UseCase<List<MessageEntity>, SearchMessagesParams> {
  final MessageRepository repository;

  SearchMessagesUseCase({required this.repository});

  @override
  Future<Result<List<MessageEntity>>> call(SearchMessagesParams params) async {
    // Validate search query
    if (params.query.isEmpty) {
      return const Failure(
        message: 'Search query cannot be empty',
        code: 'EMPTY_QUERY',
      );
    }

    if (params.conversationId.isEmpty) {
      return const Failure(
        message: 'Conversation ID is required',
        code: 'INVALID_PARAMS',
      );
    }

    // Perform search
    return await repository.searchMessages(
      conversationId: params.conversationId,
      query: params.query.trim(),
    );
  }
}

class SearchMessagesParams {
  final String conversationId;
  final String query;

  SearchMessagesParams({
    required this.conversationId,
    required this.query,
  });
}

/// Delete message use case
/// Handles message deletion with validation
class DeleteMessageUseCase implements UseCase<void, String> {
  final MessageRepository repository;

  DeleteMessageUseCase({required this.repository});

  @override
  Future<Result<void>> call(String messageId) async {
    if (messageId.isEmpty) {
      return const Failure(
        message: 'Message ID is required',
        code: 'INVALID_PARAMS',
      );
    }

    return await repository.deleteMessage(messageId);
  }
}

/// Mark messages as read use case
class MarkMessagesAsReadUseCase implements UseCase<void, List<String>> {
  final MessageRepository repository;

  MarkMessagesAsReadUseCase({required this.repository});

  @override
  Future<Result<void>> call(List<String> messageIds) async {
    if (messageIds.isEmpty) {
      return const Failure(
        message: 'At least one message ID is required',
        code: 'EMPTY_LIST',
      );
    }

    return await repository.markAsRead(messageIds: messageIds);
  }
}

/// Get unread count use case
class GetUnreadCountUseCase implements UseCase<int, void> {
  final MessageRepository repository;

  GetUnreadCountUseCase({required this.repository});

  @override
  Future<Result<int>> call(void params) async {
    return await repository.getUnreadCount();
  }
}
