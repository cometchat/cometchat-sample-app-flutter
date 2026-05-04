import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/message_list_repository.dart';
import '../datasources/message_list_remote_datasource.dart';
import '../datasources/message_list_local_datasource.dart';

/// Implementation of [MessageListRepository].
///
/// Coordinates between remote and local data sources for message operations.
class MessageListRepositoryImpl implements MessageListRepository {
  final MessageListRemoteDataSource remoteDataSource;
  final MessageListLocalDataSource? localDataSource;

  const MessageListRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  @override
  Future<Result<List<BaseMessage>>> getMessages({
    required String conversationWith,
    required String conversationType,
    int limit = 30,
    int? parentMessageId,
    List<String>? types,
    List<String>? categories,
    bool hideReplies = true,
    bool withParent = true,
  }) async {
    try {
      final result = await remoteDataSource.getMessages(
        conversationWith: conversationWith,
        conversationType: conversationType,
        limit: limit,
        parentMessageId: parentMessageId,
        types: types,
        categories: categories,
        hideReplies: hideReplies,
        withParent: withParent,
      );

      final messages = result.messages;

      if (localDataSource != null && messages.isNotEmpty) {
        final conversationId = _buildConversationId(conversationWith, conversationType);
        try {
          await localDataSource!.cacheMessages(conversationId, messages);
        } catch (_) {}
      }

      return Success(messages);
    } on MessageListRemoteDataSourceException catch (e) {
      if (localDataSource != null) {
        try {
          final conversationId = _buildConversationId(conversationWith, conversationType);
          final cachedMessages = await localDataSource!.getCachedMessages(conversationId);
          if (cachedMessages.isNotEmpty) return Success(cachedMessages);
        } catch (_) {}
      }
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while fetching messages: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<List<BaseMessage>>> fetchPreviousMessages({
    required MessagesRequest request,
  }) async {
    try {
      final messages = await remoteDataSource.fetchPreviousMessages(request: request);
      return Success(messages);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while fetching previous messages: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<List<BaseMessage>>> fetchNextMessages({
    required MessagesRequest request,
  }) async {
    try {
      final messages = await remoteDataSource.fetchNextMessages(request: request);
      return Success(messages);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while fetching next messages: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(BaseMessage message) async {
    try {
      await remoteDataSource.markAsRead(message);
      return const Success(null);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while marking message as read: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> markAsDelivered(BaseMessage message) async {
    try {
      await remoteDataSource.markAsDelivered(message);
      return const Success(null);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while marking message as delivered: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await remoteDataSource.getLoggedInUser();
      return Success(user);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting logged in user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Conversation>> getConversation({
    required String conversationWith,
    required String conversationType,
  }) async {
    try {
      final conversation = await remoteDataSource.getConversation(
        conversationWith: conversationWith,
        conversationType: conversationType,
      );
      return Success(conversation);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting conversation: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Conversation>> markMessageAsUnread(BaseMessage message) async {
    try {
      final conversation = await remoteDataSource.markMessageAsUnread(message);
      return Success(conversation);
    } on MessageListRemoteDataSourceException catch (e) {
      return Failure(message: e.message, code: e.code, exception: e.originalException);
    } catch (e) {
      return Failure(
        message: 'Unexpected error while marking message as unread: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  String _buildConversationId(String conversationWith, String conversationType) {
    return '${conversationType}_$conversationWith';
  }
}
