import '../../../../core/result.dart';
import '../entities/sound_entity.dart';

/// Abstract repository for Sound operations
/// Defines the contract that data layer must implement
/// NO DEPENDENCIES on external packages or implementation details
///
/// CURRENT CAPABILITIES (based on actual SoundManager API):
/// - play() - Play a sound
/// - stop() - Stop current sound
///
/// NOTE: Advanced features like pause, resume, seek, getDuration are NOT
/// supported by the underlying SoundManager. To add these features would
/// require either:
/// 1. Implementing a different audio library wrapper
/// 2. Direct channel communication with native code
/// 3. Contributing to cometchat_uikit_shared to add these methods
abstract class SoundRepository {
  /// Play a sound from file path
  /// Returns the Sound entity when play starts
  Future<Result<SoundEntity>> playSound({
    required String filePath,
    required String soundId,
    bool loop = false,
  });

  /// Stop current playing sound
  Future<Result<void>> stopSound({
    required String soundId,
  });
}
