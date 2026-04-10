import '../../../../core/result.dart';
import '../datasources/cache_local_datasource.dart';
import '../../domain/repositories/cache_repository.dart';

/// Repository Implementation for Cache
class CacheRepositoryImpl implements CacheRepository {
  final CacheLocalDataSource localDataSource;

  CacheRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<void>> save<T>({
    required String key,
    required T value,
    Duration? ttl,
  }) async {
    return localDataSource.save(key: key, value: value, ttl: ttl);
  }

  @override
  Future<Result<T?>> get<T>({
    required String key,
  }) async {
    return localDataSource.get(key: key);
  }

  @override
  Future<Result<bool>> exists({
    required String key,
  }) async {
    return localDataSource.exists(key: key);
  }

  @override
  Future<Result<void>> delete({
    required String key,
  }) async {
    return localDataSource.delete(key: key);
  }

  @override
  Future<Result<void>> clearAll() async {
    return localDataSource.clearAll();
  }

  @override
  Future<Result<Map<String, dynamic>>> getCacheInfo() async {
    return localDataSource.getCacheInfo();
  }
}
