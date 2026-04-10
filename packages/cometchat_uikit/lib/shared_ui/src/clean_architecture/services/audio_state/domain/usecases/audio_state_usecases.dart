import '../../../../core/result.dart';
import '../entities/audio_state_entity.dart';
import '../repositories/audio_state_repository.dart';

/// Use case to get audio state
class GetAudioStateUseCase {
  final AudioStateRepository repository;

  GetAudioStateUseCase(this.repository);

  Future<Result<AudioStateEntity>> call({
    required int id,
    String? audioUrl,
    String? localPath,
  }) async {
    return await repository.getAudioState(id, audioUrl, localPath);
  }
}

/// Use case to play audio
class PlayAudioUseCase {
  final AudioStateRepository repository;

  PlayAudioUseCase(this.repository);

  Future<Result<void>> call(int audioId) async {
    return await repository.playAudio(audioId);
  }
}

/// Use case to pause audio
class PauseAudioUseCase {
  final AudioStateRepository repository;

  PauseAudioUseCase(this.repository);

  Future<Result<void>> call(int audioId) async {
    return await repository.pauseAudio(audioId);
  }
}

/// Use case to stop audio
class StopAudioUseCase {
  final AudioStateRepository repository;

  StopAudioUseCase(this.repository);

  Future<Result<void>> call(int audioId) async {
    return await repository.stopAudio(audioId);
  }
}

/// Use case to stop all audio
class StopAllAudioUseCase {
  final AudioStateRepository repository;

  StopAllAudioUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.stopAllAudio();
  }
}

/// Use case to pause all except specified
class PauseAllExceptUseCase {
  final AudioStateRepository repository;

  PauseAllExceptUseCase(this.repository);

  Future<Result<void>> call(int excludeId) async {
    return await repository.pauseAllExcept(excludeId);
  }
}

/// Use case to remove audio state
class RemoveAudioStateUseCase {
  final AudioStateRepository repository;

  RemoveAudioStateUseCase(this.repository);

  Future<Result<void>> call(int audioId) async {
    return await repository.removeAudioState(audioId);
  }
}

/// Use case to get audio state stream
class GetAudioStateStreamUseCase {
  final AudioStateRepository repository;

  GetAudioStateStreamUseCase(this.repository);

  Stream<Result<AudioStateUpdateEntity>> call(int audioId) {
    return repository.getAudioStateStream(audioId);
  }
}

/// Use case to get current play state
class GetPlayStateUseCase {
  final AudioStateRepository repository;

  GetPlayStateUseCase(this.repository);

  Future<Result<PlayState>> call(int audioId) async {
    return await repository.getPlayState(audioId);
  }
}

/// Use case to seek audio
class SeekAudioUseCase {
  final AudioStateRepository repository;

  SeekAudioUseCase(this.repository);

  Future<Result<void>> call(int audioId, Duration position) async {
    return await repository.seekToPosition(audioId, position);
  }
}
