import '../../../../core/result.dart';
import '../repositories/cache_repository.dart';

/// Use Case for saving to cache
class SaveCacheUseCase {
  final CacheRepository repository;

  SaveCacheUseCase({required this.repository});

  Future<Result<void>> call<T>({
    required String key,
    required T value,
    Duration? ttl,
  }) {
    return repository.save(key: key, value: value, ttl: ttl);
  }
}

/// Use Case for getting from cache
class GetCacheUseCase {
  final CacheRepository repository;

  GetCacheUseCase({required this.repository});

  Future<Result<T?>> call<T>({required String key}) {
    return repository.get(key: key);
  }
}

/// Use Case for checking cache existence
class CheckCacheUseCase {
  final CacheRepository repository;

  CheckCacheUseCase({required this.repository});

  Future<Result<bool>> call({required String key}) {
    return repository.exists(key: key);
  }
}

/// Use Case for deleting from cache
class DeleteCacheUseCase {
  final CacheRepository repository;

  DeleteCacheUseCase({required this.repository});

  Future<Result<void>> call({required String key}) {
    return repository.delete(key: key);
  }
}

/// Use Case for clearing all cache
class ClearAllCacheUseCase {
  final CacheRepository repository;

  ClearAllCacheUseCase({required this.repository});

  Future<Result<void>> call() {
    return repository.clearAll();
  }
}

/// Use Case for getting cache info
class GetCacheInfoUseCase {
  final CacheRepository repository;

  GetCacheInfoUseCase({required this.repository});

  Future<Result<Map<String, dynamic>>> call() {
    return repository.getCacheInfo();
  }
}
