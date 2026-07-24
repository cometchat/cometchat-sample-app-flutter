import '../../../../core/result.dart';

/// Abstract repository for Cache operations
abstract class CacheRepository {
  /// Save to cache
  Future<Result<void>> save<T>({
    required String key,
    required T value,
    Duration? ttl,
  });

  /// Get from cache
  Future<Result<T?>> get<T>({required String key});

  /// Check if cache exists and not expired
  Future<Result<bool>> exists({required String key});

  /// Delete from cache
  Future<Result<void>> delete({required String key});

  /// Clear all cache
  Future<Result<void>> clearAll();

  /// Get cache info
  Future<Result<Map<String, dynamic>>> getCacheInfo();
}
