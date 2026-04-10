import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;

/// Exception thrown when local data source operations fail
class CallLogsLocalDataSourceException implements Exception {
  final String message;
  final Exception? originalException;

  const CallLogsLocalDataSourceException({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => 'CallLogsLocalDataSourceException(message: $message)';
}

/// Abstract interface for call logs local data source.
/// Handles local caching of call log data.
abstract class CallLogsLocalDataSource {
  /// Cache a list of call logs
  Future<void> cacheCallLogs(List<CallLog> callLogs);

  /// Get cached call logs
  Future<List<CallLog>> getCachedCallLogs();

  /// Cache a single call log
  Future<void> cacheCallLog(CallLog callLog);

  /// Get a cached call log by session ID
  Future<CallLog?> getCachedCallLog(String sessionId);

  /// Remove a call log from cache
  Future<void> removeCachedCallLog(String sessionId);

  /// Clear all cached call logs
  Future<void> clearCache();

  /// Check if cache has data
  Future<bool> hasCachedData();
}

/// Implementation of CallLogsLocalDataSource using in-memory cache.
/// In a production app, this could use SharedPreferences, Hive, or SQLite.
class CallLogsLocalDataSourceImpl implements CallLogsLocalDataSource {
  // In-memory cache for call logs
  final Map<String, CallLog> _cache = {};

  @override
  Future<void> cacheCallLogs(List<CallLog> callLogs) async {
    try {
      // Clear existing cache and add new call logs
      _cache.clear();
      for (final callLog in callLogs) {
        final sessionId = callLog.sessionId;
        if (sessionId != null) {
          _cache[sessionId] = callLog;
        }
      }
    } catch (e) {
      throw CallLogsLocalDataSourceException(
        message: 'Failed to cache call logs: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<List<CallLog>> getCachedCallLogs() async {
    try {
      if (_cache.isEmpty) {
        throw const CallLogsLocalDataSourceException(
          message: 'No cached call logs available',
        );
      }

      // Return call logs sorted by initiatedAt (most recent first)
      final callLogs = _cache.values.toList();
      callLogs.sort((a, b) {
        final aInitiated = a.initiatedAt ?? 0;
        final bInitiated = b.initiatedAt ?? 0;
        return bInitiated.compareTo(aInitiated);
      });
      return callLogs;
    } catch (e) {
      if (e is CallLogsLocalDataSourceException) {
        rethrow;
      }
      throw CallLogsLocalDataSourceException(
        message: 'Failed to get cached call logs: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> cacheCallLog(CallLog callLog) async {
    try {
      final sessionId = callLog.sessionId;
      if (sessionId != null) {
        _cache[sessionId] = callLog;
      }
    } catch (e) {
      throw CallLogsLocalDataSourceException(
        message: 'Failed to cache call log: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<CallLog?> getCachedCallLog(String sessionId) async {
    try {
      return _cache[sessionId];
    } catch (e) {
      throw CallLogsLocalDataSourceException(
        message: 'Failed to get cached call log: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> removeCachedCallLog(String sessionId) async {
    try {
      _cache.remove(sessionId);
    } catch (e) {
      throw CallLogsLocalDataSourceException(
        message: 'Failed to remove cached call log: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _cache.clear();
    } catch (e) {
      throw CallLogsLocalDataSourceException(
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
      throw CallLogsLocalDataSourceException(
        message: 'Failed to check cache status: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }
}
