import '../../../../core/result.dart';
import '../../domain/entities/audio_state_entity.dart';
import '../../domain/repositories/audio_state_repository.dart';
import '../datasources/audio_state_remote_datasource.dart';

/// Implementation of AudioStateRepository
class AudioStateRepositoryImpl implements AudioStateRepository {
  final AudioStateRemoteDataSource remoteDataSource;

  AudioStateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<AudioStateEntity>> getAudioState(
    int id,
    String? audioUrl,
    String? localPath,
  ) async {
    try {
      final result = await remoteDataSource.getAudioState(
        id,
        audioUrl,
        localPath,
      );
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to get audio state: $e');
    }
  }

  @override
  Future<Result<AudioStateEntity>> updateAudioState(
    AudioStateEntity state,
  ) async {
    try {
      final result = await remoteDataSource.updateAudioState(state);
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to update audio state: $e');
    }
  }

  @override
  Stream<Result<AudioStateUpdateEntity>> getAudioStateStream(
    int audioId,
  ) async* {
    try {
      await for (final update in remoteDataSource.getAudioStateStream(
        audioId,
      )) {
        yield Success(update);
      }
    } catch (e) {
      yield Failure(message: 'Failed to get audio state stream: $e');
    }
  }

  @override
  Future<Result<void>> playAudio(int audioId) async {
    try {
      await remoteDataSource.playAudio(audioId);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to play audio: $e');
    }
  }

  @override
  Future<Result<void>> pauseAudio(int audioId) async {
    try {
      await remoteDataSource.pauseAudio(audioId);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to pause audio: $e');
    }
  }

  @override
  Future<Result<void>> stopAudio(int audioId) async {
    try {
      await remoteDataSource.stopAudio(audioId);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to stop audio: $e');
    }
  }

  @override
  Future<Result<void>> stopAllAudio() async {
    try {
      await remoteDataSource.stopAllAudio();
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to stop all audio: $e');
    }
  }

  @override
  Future<Result<void>> pauseAllExcept(int excludeId) async {
    try {
      await remoteDataSource.pauseAllExcept(excludeId);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to pause all audio: $e');
    }
  }

  @override
  Future<Result<void>> removeAudioState(int audioId) async {
    try {
      await remoteDataSource.removeAudioState(audioId);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to remove audio state: $e');
    }
  }

  @override
  Future<Result<PlayState>> getPlayState(int audioId) async {
    try {
      final result = await remoteDataSource.getPlayState(audioId);
      return Success(result);
    } catch (e) {
      return Failure(message: 'Failed to get play state: $e');
    }
  }

  @override
  Future<Result<void>> seekToPosition(int audioId, Duration position) async {
    try {
      await remoteDataSource.seekToPosition(audioId, position);
      return const Success(null);
    } catch (e) {
      return Failure(message: 'Failed to seek audio: $e');
    }
  }
}
