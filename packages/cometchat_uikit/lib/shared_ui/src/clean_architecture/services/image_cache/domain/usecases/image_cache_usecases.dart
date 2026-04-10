import '../../../../core/result.dart';
import '../entities/image_cache_entity.dart';
import '../repositories/image_cache_repository.dart';

/// Use case to cache an image
class CacheImageUseCase {
  final ImageCacheRepository repository;

  CacheImageUseCase(this.repository);

  Future<Result<ImageCacheEntity>> call({
    required String key,
    required String url,
  }) async {
    return await repository.cacheImage(key: key, url: url);
  }
}

/// Use case to get cached image
class GetCachedImageUseCase {
  final ImageCacheRepository repository;

  GetCachedImageUseCase(this.repository);

  Future<Result<ImageCacheEntity>> call(String key) async {
    return await repository.getCachedImage(key);
  }
}

/// Use case to check if image is cached
class IsCachedUseCase {
  final ImageCacheRepository repository;

  IsCachedUseCase(this.repository);

  Future<Result<bool>> call(String key) async {
    return await repository.isCached(key);
  }
}

/// Use case to remove cached image
class RemoveCachedImageUseCase {
  final ImageCacheRepository repository;

  RemoveCachedImageUseCase(this.repository);

  Future<Result<void>> call(String key) async {
    return await repository.removeCachedImage(key);
  }
}

/// Use case to clear all image cache
class ClearAllImageCacheUseCase {
  final ImageCacheRepository repository;

  ClearAllImageCacheUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.clearAllCache();
  }
}

/// Use case to get cache statistics
class GetImageCacheStatsUseCase {
  final ImageCacheRepository repository;

  GetImageCacheStatsUseCase(this.repository);

  Future<Result<ImageCacheStatsEntity>> call() async {
    return await repository.getCacheStats();
  }
}

/// Use case to get all cached images
class GetAllCachedImagesUseCase {
  final ImageCacheRepository repository;

  GetAllCachedImagesUseCase(this.repository);

  Future<Result<List<ImageCacheEntity>>> call() async {
    return await repository.getAllCachedImages();
  }
}

/// Use case to update cache config
class UpdateImageCacheConfigUseCase {
  final ImageCacheRepository repository;

  UpdateImageCacheConfigUseCase(this.repository);

  Future<Result<void>> call({
    int? maxCacheObjects,
    Duration? stalePeriod,
  }) async {
    return await repository.updateConfig(
      maxCacheObjects: maxCacheObjects,
      stalePeriod: stalePeriod,
    );
  }
}

/// Use case to optimize cache
class OptimizeImageCacheUseCase {
  final ImageCacheRepository repository;

  OptimizeImageCacheUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.optimizeCache();
  }
}
