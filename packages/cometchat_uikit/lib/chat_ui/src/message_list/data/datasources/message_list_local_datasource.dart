import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Exception thrown when local data source operations fail.
class MessageListLocalDataSourceException implements Exception {
  final String message;
  final Exception? originalException;

  const MessageListLocalDataSourceException({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => 'MessageListLocalDataSourceException(message: $message)';
}

/// Abstract interface for message list local data source.
abstract class MessageListLocalDataSource {
  Future<void> cacheMessages(String conversationId, List<BaseMessage> messages);
  Future<List<BaseMessage>> getCachedMessages(String conversationId);
  Future<void> cacheMessage(String conversationId, BaseMessage message);
  Future<BaseMessage?> getCachedMessage(String conversationId, int messageId);
  Future<void> removeCachedMessage(String conversationId, int messageId);
  Future<void> clearCache(String conversationId);
  Future<void> clearAllCache();
  Future<bool> hasCachedData(String conversationId);
}

/// Implementation of [MessageListLocalDataSource] using in-memory cache.
class MessageListLocalDataSourceImpl implements MessageListLocalDataSource {
  final Map<String, Map<int, BaseMessage>> _cache = {};

  @override
  Future<void> cacheMessages(String conversationId, List<BaseMessage> messages) async {
    try {
      _cache[conversationId] ??= {};
      for (final message in messages) {
        _cache[conversationId]![message.id] = message;
      }
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to cache messages: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<List<BaseMessage>> getCachedMessages(String conversationId) async {
    try {
      final conversationCache = _cache[conversationId];
      if (conversationCache == null || conversationCache.isEmpty) return [];
      final messages = conversationCache.values.toList();
      messages.sort((a, b) {
        final aSent = a.sentAt ?? DateTime(0);
        final bSent = b.sentAt ?? DateTime(0);
        return aSent.compareTo(bSent);
      });
      return messages;
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to get cached messages: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> cacheMessage(String conversationId, BaseMessage message) async {
    try {
      _cache[conversationId] ??= {};
      _cache[conversationId]![message.id] = message;
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to cache message: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<BaseMessage?> getCachedMessage(String conversationId, int messageId) async {
    try {
      return _cache[conversationId]?[messageId];
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to get cached message: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> removeCachedMessage(String conversationId, int messageId) async {
    try {
      _cache[conversationId]?.remove(messageId);
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to remove cached message: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> clearCache(String conversationId) async {
    try {
      _cache.remove(conversationId);
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to clear cache: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      _cache.clear();
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to clear all cache: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<bool> hasCachedData(String conversationId) async {
    try {
      final conversationCache = _cache[conversationId];
      return conversationCache != null && conversationCache.isNotEmpty;
    } catch (e) {
      throw MessageListLocalDataSourceException(
        message: 'Failed to check cache status: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }
}
