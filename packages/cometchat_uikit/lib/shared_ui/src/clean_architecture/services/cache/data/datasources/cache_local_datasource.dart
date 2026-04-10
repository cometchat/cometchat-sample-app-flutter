import '../../../../core/result.dart';

/// Local Data Source for Cache
abstract class CacheLocalDataSource {
  /// Save to cache
  Future<Result<void>> save<T>({
    required String key,
    required T value,
    Duration? ttl,
  });

  /// Get from cache
  Future<Result<T?>> get<T>({
    required String key,
  });

  /// Check if exists
  Future<Result<bool>> exists({
    required String key,
  });

  /// Delete from cache
  Future<Result<void>> delete({
    required String key,
  });

  /// Clear all cache
  Future<Result<void>> clearAll();

  /// Get cache info
  Future<Result<Map<String, dynamic>>> getCacheInfo();
}

/// Implementation using in-memory cache
class CacheLocalDataSourceImpl implements CacheLocalDataSource {
  /// In-memory cache storage
  final Map<String, dynamic> _cache = {};
  
  /// Cache metadata
  final Map<String, DateTime?> _expiryTimes = {};

  @override
  Future<Result<void>> save<T>({
    required String key,
    required T value,
    Duration? ttl,
  }) async {
    try {
      _cache[key] = value;
      
      if (ttl != null) {
        _expiryTimes[key] = DateTime.now().add(ttl);
      } else {
        _expiryTimes[key] = null;
      }

      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to save cache: ${e.toString()}',
        code: 'CACHE_SAVE_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<T?>> get<T>({
    required String key,
  }) async {
    try {
      // Check if cache exists
      if (!_cache.containsKey(key)) {
        return const Success(null);
      }

      // Check if expired
      final expiryTime = _expiryTimes[key];
      if (expiryTime != null && DateTime.now().isAfter(expiryTime)) {
        _cache.remove(key);
        _expiryTimes.remove(key);
        return const Success(null);
      }

      return Success(_cache[key] as T?);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to get cache: ${e.toString()}',
        code: 'CACHE_GET_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<bool>> exists({
    required String key,
  }) async {
    try {
      if (!_cache.containsKey(key)) {
        return const Success(false);
      }

      // Check if expired
      final expiryTime = _expiryTimes[key];
      if (expiryTime != null && DateTime.now().isAfter(expiryTime)) {
        _cache.remove(key);
        _expiryTimes.remove(key);
        return const Success(false);
      }

      return const Success(true);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to check cache: ${e.toString()}',
        code: 'CACHE_EXISTS_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> delete({
    required String key,
  }) async {
    try {
      _cache.remove(key);
      _expiryTimes.remove(key);
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to delete cache: ${e.toString()}',
        code: 'CACHE_DELETE_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      _cache.clear();
      _expiryTimes.clear();
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to clear cache: ${e.toString()}',
        code: 'CACHE_CLEAR_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCacheInfo() async {
    try {
      final info = {
        'totalKeys': _cache.length,
        'keys': _cache.keys.toList(),
        'memoryUsage': _cache.toString().length,
      };
      return Success(info);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to get cache info: ${e.toString()}',
        code: 'CACHE_INFO_ERROR',
        exception: e,
      );
    }
  }
}
