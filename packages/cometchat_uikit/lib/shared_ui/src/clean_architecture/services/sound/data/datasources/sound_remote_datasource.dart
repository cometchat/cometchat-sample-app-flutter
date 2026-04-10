import '../../../../core/result.dart';
import '../../../sound/domain/entities/sound_entity.dart';
import '../../../../../resources/sound_manager.dart';

/// Remote Data Source - Wraps the existing SoundManager
/// This bridges the new clean architecture with existing code
/// 
/// NOTE: SoundManager has limited capabilities - only play() and stop()
/// are available on the actual implementation. Advanced features
/// (pause, resume, seek, duration, position) are NOT supported by SoundManager
/// and would require direct channel communication or different audio library.
abstract class SoundRemoteDataSource {
  /// Play sound using existing SoundManager
  Future<Result<SoundEntity>> playSound({
    required String filePath,
    required String soundId,
    bool loop = false,
  });

  /// Stop sound
  Future<Result<void>> stopSound({
    required String soundId,
  });
}

/// Implementation using existing SoundManager
/// Only supports play() and stop() as those are the only methods available
class SoundRemoteDataSourceImpl implements SoundRemoteDataSource {
  /// Uses the existing SoundManager singleton from cometchat_uikit_shared
  /// Location: shared_uikit/lib/src/resources/sound_manager.dart
  final SoundManager _soundManager = SoundManager();

  @override
  Future<Result<SoundEntity>> playSound({
    required String filePath,
    required String soundId,
    bool loop = false,
  }) async {
    try {
      // Convert filePath to Sound enum if it's a preset sound
      Sound? sound = _filePathToSound(filePath);
      
      // Call existing SoundManager.play() method
      // Signature: play({required Sound sound, String? customSound, String? packageName, bool? isLooping})
      if (sound != null) {
        _soundManager.play(
          sound: sound,
          isLooping: loop,
        );
      } else {
        // If not a preset sound, use as custom sound
        _soundManager.play(
          sound: Sound.incomingMessage, // Default to use, but pass custom sound
          customSound: filePath,
          isLooping: loop,
        );
      }

      // Create SoundEntity to return
      final soundEntity = SoundEntity(
        id: soundId,
        name: filePath.split('/').last,
        filePath: filePath,
        duration: Duration.zero, // SoundManager doesn't provide duration
        isPlaying: true,
        createdAt: DateTime.now(),
      );

      return Success(soundEntity);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to play sound: ${e.toString()}',
        code: 'SOUND_PLAY_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> stopSound({required String soundId}) async {
    try {
      // Call existing SoundManager.stop() method - takes no parameters
      _soundManager.stop();
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to stop sound: ${e.toString()}',
        code: 'SOUND_STOP_ERROR',
        exception: e,
      );
    }
  }

  /// Convert filePath to Sound enum if it matches a preset
  Sound? _filePathToSound(String filePath) {
    final lower = filePath.toLowerCase();
    
    if (lower.contains('incoming') && lower.contains('message')) {
      return Sound.incomingMessage;
    } else if (lower.contains('outgoing') && lower.contains('message')) {
      return Sound.outgoingMessage;
    } else if (lower.contains('incoming') && lower.contains('call')) {
      return Sound.incomingCall;
    } else if (lower.contains('outgoing') && lower.contains('call')) {
      return Sound.outgoingCall;
    } else if (lower.contains('incoming') && lower.contains('other')) {
      return Sound.incomingMessageFromOther;
    }
    
    return null;
  }
}

