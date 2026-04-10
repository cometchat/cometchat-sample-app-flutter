import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Exception thrown when local data source operations fail
class LocalDataSourceException implements Exception {
  final String message;
  final Exception? originalException;

  const LocalDataSourceException({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => 'LocalDataSourceException(message: $message)';
}

/// Abstract interface for conversations local data source
/// Handles local caching of conversation data
abstract class ConversationsLocalDataSource {
  /// Cache a list of conversations
  Future<void> cacheConversations(List<Conversation> conversations);

  /// Get cached conversations
  Future<List<Conversation>> getCachedConversations();

  /// Cache a single conversation
  Future<void> cacheConversation(Conversation conversation);

  /// Get a cached conversation by ID
  Future<Conversation?> getCachedConversation(String conversationId);

  /// Remove a conversation from cache
  Future<void> removeCachedConversation(String conversationId);

  /// Clear all cached conversations
  Future<void> clearCache();

  /// Check if cache has data
  Future<bool> hasCachedData();
}

/// Implementation of ConversationsLocalDataSource using in-memory cache
/// In a production app, this could use SharedPreferences, Hive, or SQLite
class ConversationsLocalDataSourceImpl
    implements ConversationsLocalDataSource {
  // In-memory cache for conversations
  final Map<String, Conversation> _cache = {};

  @override
  Future<void> cacheConversations(
      List<Conversation> conversations) async {
    try {
      // Clear existing cache and add new conversations
      _cache.clear();
      for (final conversation in conversations) {
        final conversationId = conversation.conversationId;
        if (conversationId != null) {
          _cache[conversationId] = conversation;
        }
      }
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to cache conversations: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<List<Conversation>> getCachedConversations() async {
    try {
      if (_cache.isEmpty) {
        throw const LocalDataSourceException(
          message: 'No cached conversations available',
        );
      }

      // Return conversations sorted by updatedAt (most recent first)
      final conversations = _cache.values.toList();
      conversations.sort((a, b) {
        final aUpdated = a.updatedAt ?? DateTime(0);
        final bUpdated = b.updatedAt ?? DateTime(0);
        return bUpdated.compareTo(aUpdated);
      });
      return conversations;
    } catch (e) {
      if (e is LocalDataSourceException) {
        rethrow;
      }
      throw LocalDataSourceException(
        message: 'Failed to get cached conversations: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> cacheConversation(Conversation conversation) async {
    try {
      final conversationId = conversation.conversationId;
      if (conversationId != null) {
        _cache[conversationId] = conversation;
      }
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to cache conversation: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Conversation?> getCachedConversation(
      String conversationId) async {
    try {
      return _cache[conversationId];
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to get cached conversation: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> removeCachedConversation(String conversationId) async {
    try {
      _cache.remove(conversationId);
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to remove cached conversation: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _cache.clear();
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to clear cache: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<bool> hasCachedData() async {
    try {
      return _cache.isNotEmpty;
    } catch (e) {
      throw LocalDataSourceException(
        message: 'Failed to check cache status: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }
}
