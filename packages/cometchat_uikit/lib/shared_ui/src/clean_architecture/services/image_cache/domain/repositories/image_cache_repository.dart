import '../../../../core/result.dart';
import '../entities/image_cache_entity.dart';

/// Abstract repository for Image Cache management
abstract class ImageCacheRepository {
  /// Cache an image from URL
  Future<Result<ImageCacheEntity>> cacheImage({
    required String key,
    required String url,
  });

  /// Get cached image
  Future<Result<ImageCacheEntity>> getCachedImage(String key);

  /// Check if image is cached
  Future<Result<bool>> isCached(String key);

  /// Remove cached image
  Future<Result<void>> removeCachedImage(String key);

  /// Clear all cache
  Future<Result<void>> clearAllCache();

  /// Get cache statistics
  Future<Result<ImageCacheStatsEntity>> getCacheStats();

  /// Get all cached images
  Future<Result<List<ImageCacheEntity>>> getAllCachedImages();

  /// Update cache configuration
  Future<Result<void>> updateConfig({
    int? maxCacheObjects,
    Duration? stalePeriod,
  });

  /// Optimize cache (remove old files if exceeding max size)
  Future<Result<void>> optimizeCache();
}
