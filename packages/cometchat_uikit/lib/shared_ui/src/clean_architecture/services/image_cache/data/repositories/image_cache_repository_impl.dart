import '../../../../core/result.dart';
import '../../domain/entities/image_cache_entity.dart';
import '../../domain/repositories/image_cache_repository.dart';
import '../datasources/image_cache_remote_datasource.dart';

/// Implementation of ImageCacheRepository
class ImageCacheRepositoryImpl implements ImageCacheRepository {
  final ImageCacheRemoteDataSource remoteDataSource;

  ImageCacheRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<ImageCacheEntity>> cacheImage({
    required String key,
    required String url,
  }) async {
    try {
      final result = await remoteDataSource.cacheImage(key: key, url: url);
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to cache image: $e');
    }
  }

  @override
  Future<Result<ImageCacheEntity>> getCachedImage(String key) async {
    try {
      final result = await remoteDataSource.getCachedImage(key);
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to get cached image: $e');
    }
  }

  @override
  Future<Result<bool>> isCached(String key) async {
    try {
      final result = await remoteDataSource.isCached(key);
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to check cache: $e');
    }
  }

  @override
  Future<Result<void>> removeCachedImage(String key) async {
    try {
      await remoteDataSource.removeCachedImage(key);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to remove cached image: $e');
    }
  }

  @override
  Future<Result<void>> clearAllCache() async {
    try {
      await remoteDataSource.clearAllCache();
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<Result<ImageCacheStatsEntity>> getCacheStats() async {
    try {
      final result = await remoteDataSource.getCacheStats();
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to get cache stats: $e');
    }
  }

  @override
  Future<Result<List<ImageCacheEntity>>> getAllCachedImages() async {
    try {
      final result = await remoteDataSource.getAllCachedImages();
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to get all cached images: $e');
    }
  }

  @override
  Future<Result<void>> updateConfig({
    int? maxCacheObjects,
    Duration? stalePeriod,
  }) async {
    try {
      await remoteDataSource.updateConfig(
        maxCacheObjects: maxCacheObjects,
        stalePeriod: stalePeriod,
      );
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to update config: $e');
    }
  }

  @override
  Future<Result<void>> optimizeCache() async {
    try {
      await remoteDataSource.optimizeCache();
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to optimize cache: $e');
    }
  }
}
