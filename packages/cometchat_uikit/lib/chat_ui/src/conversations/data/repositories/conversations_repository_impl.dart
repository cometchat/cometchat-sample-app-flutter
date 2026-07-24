import 'dart:async';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/conversations_repository.dart';
import '../datasources/conversations_remote_datasource.dart';
import '../datasources/conversations_local_datasource.dart';

/// Implementation of ConversationsRepository
/// Coordinates between remote and local data sources
class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource remoteDataSource;
  final ConversationsLocalDataSource localDataSource;

  const ConversationsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<Conversation>>> getConversations({
    int limit = 30,
    String? fromId,
    ConversationsRequestBuilder? requestBuilder,
  }) async {
    try {
      // Try to fetch from remote data source
      final conversations = await remoteDataSource.getConversations(
        limit: limit,
        fromId: fromId,
        requestBuilder: requestBuilder,
      );

      // Cache the results locally
      await localDataSource.cacheConversations(conversations);

      return Success(conversations);
    } on RemoteDataSourceException catch (e) {
      // If remote fetch fails, try to return cached data
      try {
        final cachedConversations = await localDataSource
            .getCachedConversations();
        return Success(cachedConversations);
      } on LocalDataSourceException {
        // Both remote and cache failed
        return Failure(
          message: 'Failed to load conversations: ${e.message}',
          code: e.code,
          exception: e.originalException,
        );
      }
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while loading conversations: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Conversation>> getConversationById(
    String conversationId,
  ) async {
    try {
      // Try to get from cache first
      final cachedConversation = await localDataSource.getCachedConversation(
        conversationId,
      );

      if (cachedConversation != null) {
        return Success(cachedConversation);
      }

      // If not in cache, fetch from remote
      final conversation = await remoteDataSource.getConversation(
        conversationId,
      );

      // Cache it
      await localDataSource.cacheConversation(conversation);

      return Success(conversation);
    } on RemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to get conversation: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting conversation: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> deleteConversation(String conversationId) async {
    try {
      // Parse conversation ID to extract conversationWith and conversationType.
      //
      // The CometChat SDK formats conversationId as:
      //   "{number}_{type}_{id}"
      // Examples:
      //   "1_user_cometchat-uid-1"  → type=user, id=cometchat-uid-1
      //   "2_group_my-group-guid"   → type=group, id=my-group-guid
      //
      // Legacy/test formats without numeric prefix are also supported:
      //   "user_uid123"             → type=user, id=uid123
      //   "group_my-group"          → type=group, id=my-group
      final parts = conversationId.split('_');
      if (parts.length < 2) {
        return const Failure(
          message: 'Invalid conversation ID format',
          code: 'INVALID_CONVERSATION_ID',
        );
      }

      String conversationType;
      String conversationWith;

      // Find the type token ('user' or 'group') in the parts
      final typeIndex = parts.indexWhere((p) => p == 'user' || p == 'group');
      if (typeIndex != -1 && typeIndex < parts.length - 1) {
        // Found type token — everything after it is the UID/GUID
        conversationType = parts[typeIndex];
        conversationWith = parts.sublist(typeIndex + 1).join('_');
      } else {
        // Fallback: assume first part is type, rest is ID (legacy format)
        conversationType = parts[0];
        conversationWith = parts.sublist(1).join('_');
      }

      if (conversationWith.isEmpty) {
        return const Failure(
          message:
              'Invalid conversation ID: could not extract conversationWith',
          code: 'INVALID_CONVERSATION_ID',
        );
      }

      // Delete from remote
      await remoteDataSource.deleteConversation(
        conversationWith,
        conversationType,
      );

      // Remove from cache
      await localDataSource.removeCachedConversation(conversationId);

      return const Success(null);
    } on RemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to delete conversation: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while deleting conversation: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Conversation>> updateConversation(
    Conversation conversation,
  ) async {
    try {
      // Update in cache
      await localDataSource.cacheConversation(conversation);

      // Note: SDK doesn't have a direct update method
      // Updates typically happen through message operations
      // For now, we just update the cache

      return Success(conversation);
    } catch (e) {
      return Failure(
        message: 'Failed to update conversation: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await CometChat.getLoggedInUser();
      return Success(user);
    } on CometChatException catch (e) {
      return Failure(
        message: 'Failed to get logged-in user: ${e.message}',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while getting logged-in user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> markAsDelivered(BaseMessage message) async {
    try {
      final completer = Completer<void>();

      await CometChat.markAsDelivered(
        message,
        onSuccess: (_) {
          completer.complete();
        },
        onError: (CometChatException exception) {
          completer.completeError(exception);
        },
      );

      await completer.future;
      return const Success(null);
    } on CometChatException catch (e) {
      return Failure(
        message: 'Failed to mark message as delivered: ${e.message}',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while marking message as delivered: ${e.toString()}',
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
      final completer = Completer<Conversation>();

      await CometChat.getConversation(
        conversationWith,
        conversationType,
        onSuccess: (Conversation conversation) {
          completer.complete(conversation);
        },
        onError: (CometChatException exception) {
          completer.completeError(exception);
        },
      );

      final conversation = await completer.future;

      // Cache it
      await localDataSource.cacheConversation(conversation);

      return Success(conversation);
    } on CometChatException catch (e) {
      return Failure(
        message: 'Failed to get conversation: ${e.message}',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting conversation: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }
}
