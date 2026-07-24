import '../../../../core/result.dart';
import '../datasources/sound_remote_datasource.dart';
import '../../domain/entities/sound_entity.dart';
import '../../domain/repositories/sound_repository.dart';

/// Repository Implementation - Mediates between Use Cases and Data Sources
/// This is the Data Layer connecting to Domain Layer
///
/// Responsibilities:
/// 1. Delegate calls to appropriate data sources
/// 2. Handle any cross-datasource logic
/// 3. Provide a clean interface to use cases
class SoundRepositoryImpl implements SoundRepository {
  final SoundRemoteDataSource remoteDataSource;

  /// Constructor accepts injected data source
  /// This allows easy testing and switching implementations
  SoundRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<SoundEntity>> playSound({
    required String filePath,
    required String soundId,
    bool loop = false,
  }) async {
    // Delegate to data source
    // No business logic here - just pass through
    return remoteDataSource.playSound(
      filePath: filePath,
      soundId: soundId,
      loop: loop,
    );
  }

  @override
  Future<Result<void>> stopSound({required String soundId}) async {
    return remoteDataSource.stopSound(soundId: soundId);
  }
}
