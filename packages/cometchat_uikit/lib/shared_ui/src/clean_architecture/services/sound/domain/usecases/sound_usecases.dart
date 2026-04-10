import '../../../../core/result.dart';
import '../../domain/entities/sound_entity.dart';
import '../../domain/repositories/sound_repository.dart';

/// Use Case for playing a sound
/// Single Responsibility: Handle playing sound logic
class PlaySoundUseCase {
  final SoundRepository repository;

  PlaySoundUseCase({required this.repository});

  /// Execute the use case
  /// Takes file path and sound ID, returns the Sound entity
  Future<Result<SoundEntity>> call({
    required String filePath,
    required String soundId,
    bool loop = false,
  }) {
    return repository.playSound(
      filePath: filePath,
      soundId: soundId,
      loop: loop,
    );
  }
}

/// Use Case for stopping sound
class StopSoundUseCase {
  final SoundRepository repository;

  StopSoundUseCase({required this.repository});

  Future<Result<void>> call({required String soundId}) {
    return repository.stopSound(soundId: soundId);
  }
}
