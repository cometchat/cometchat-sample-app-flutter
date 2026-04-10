import '../../../../core/result.dart';
import '../entities/audio_state_entity.dart';

/// Abstract repository for Audio State management
abstract class AudioStateRepository {
  /// Get or create audio state for a specific audio bubble
  Future<Result<AudioStateEntity>> getAudioState(
    int id,
    String? audioUrl,
    String? localPath,
  );

  /// Update audio state
  Future<Result<AudioStateEntity>> updateAudioState(AudioStateEntity state);

  /// Get stream of audio state updates
  Stream<Result<AudioStateUpdateEntity>> getAudioStateStream(int audioId);

  /// Play audio
  Future<Result<void>> playAudio(int audioId);

  /// Pause audio
  Future<Result<void>> pauseAudio(int audioId);

  /// Stop audio
  Future<Result<void>> stopAudio(int audioId);

  /// Stop all audio playback
  Future<Result<void>> stopAllAudio();

  /// Pause all audio except specified ID
  Future<Result<void>> pauseAllExcept(int excludeId);

  /// Remove audio state
  Future<Result<void>> removeAudioState(int audioId);

  /// Get current playback state
  Future<Result<PlayState>> getPlayState(int audioId);

  /// Seek to position
  Future<Result<void>> seekToPosition(int audioId, Duration position);
}
