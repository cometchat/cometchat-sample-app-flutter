import 'package:flutter/material.dart';
import '../../domain/entities/image_cache_entity.dart';

/// Remote data source for image cache (in-memory implementation)
abstract class ImageCacheRemoteDataSource {
  /// Cache an image
  Future<ImageCacheEntity> cacheImage({
    required String key,
    required String url,
  });

  /// Get cached image
  Future<ImageCacheEntity> getCachedImage(String key);

  /// Check if cached
  Future<bool> isCached(String key);

  /// Remove cached image
  Future<void> removeCachedImage(String key);

  /// Clear all cache
  Future<void> clearAllCache();

  /// Get statistics
  Future<ImageCacheStatsEntity> getCacheStats();

  /// Get all cached images
  Future<List<ImageCacheEntity>> getAllCachedImages();

  /// Update config
  Future<void> updateConfig({
    int? maxCacheObjects,
    Duration? stalePeriod,
  });

  /// Optimize cache
  Future<void> optimizeCache();
}

/// Implementation of image cache data source
class ImageCacheRemoteDataSourceImpl implements ImageCacheRemoteDataSource {
  final Map<String, ImageCacheEntity> _cache = {};
  int _maxCacheObjects = 100;
  Duration _stalePeriod = const Duration(days: 7);

  @override
  Future<ImageCacheEntity> cacheImage({
    required String key,
    required String url,
  }) async {
    try {
      final entity = ImageCacheEntity(
        key: key,
        url: url,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        isPersistent: true,
      );

      _cache[key] = entity;

      // Check if we need to optimize
      if (_cache.length >= _maxCacheObjects) {
        await optimizeCache();
      }

      return entity;
    } catch (e) {
      debugPrint('[ImageCache] Error caching image: $e');
      rethrow;
    }
  }

  @override
  Future<ImageCacheEntity> getCachedImage(String key) async {
    try {
      if (_cache.containsKey(key)) {
        final entity = _cache[key]!;

        // Check if stale
        if (entity.lastModified != null) {
          final age = DateTime.now().difference(entity.lastModified!);
          if (age > _stalePeriod) {
            await removeCachedImage(key);
            throw Exception('Cached image is stale');
          }
        }

        return entity;
      }
      throw Exception('Image not found in cache');
    } catch (e) {
      debugPrint('[ImageCache] Error getting cached image: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isCached(String key) async {
    try {
      if (!_cache.containsKey(key)) {
        return false;
      }

      final entity = _cache[key]!;
      if (entity.lastModified != null) {
        final age = DateTime.now().difference(entity.lastModified!);
        if (age > _stalePeriod) {
          await removeCachedImage(key);
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('[ImageCache] Error checking cache: $e');
      return false;
    }
  }

  @override
  Future<void> removeCachedImage(String key) async {
    try {
      _cache.remove(key);
    } catch (e) {
      debugPrint('[ImageCache] Error removing cached image: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      _cache.clear();
    } catch (e) {
      debugPrint('[ImageCache] Error clearing cache: $e');
    }
  }

  @override
  Future<ImageCacheStatsEntity> getCacheStats() async {
    try {
      int totalSize = 0;
      for (final entity in _cache.values) {
        totalSize += entity.sizeInBytes ?? 0;
      }

      return ImageCacheStatsEntity(
        totalItems: _cache.length,
        totalSizeInBytes: totalSize,
        lastCleaned: DateTime.now(),
        maxCacheObjects: _maxCacheObjects,
      );
    } catch (e) {
      debugPrint('[ImageCache] Error getting cache stats: $e');
      rethrow;
    }
  }

  @override
  Future<List<ImageCacheEntity>> getAllCachedImages() async {
    try {
      return _cache.values.toList();
    } catch (e) {
      debugPrint('[ImageCache] Error getting all cached images: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateConfig({
    int? maxCacheObjects,
    Duration? stalePeriod,
  }) async {
    try {
      if (maxCacheObjects != null) {
        _maxCacheObjects = maxCacheObjects.clamp(10, 1000);
      }
      if (stalePeriod != null) {
        _stalePeriod = stalePeriod;
      }
    } catch (e) {
      debugPrint('[ImageCache] Error updating config: $e');
    }
  }

  @override
  Future<void> optimizeCache() async {
    try {
      if (_cache.length >= _maxCacheObjects) {
        // Remove oldest entries
        final sortedEntries = _cache.entries.toList()
          ..sort((a, b) =>
              (a.value.createdAt ?? DateTime.now())
                  .compareTo(b.value.createdAt ?? DateTime.now()));

        final toRemove = sortedEntries.length - (_maxCacheObjects ~/ 2);
        for (int i = 0; i < toRemove; i++) {
          _cache.remove(sortedEntries[i].key);
        }
      }
    } catch (e) {
      debugPrint('[ImageCache] Error optimizing cache: $e');
    }
  }

  void dispose() {
    _cache.clear();
  }
}
