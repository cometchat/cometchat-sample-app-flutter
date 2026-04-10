import 'service_locator.dart';
import '../../services/audio_state/domain/usecases/audio_state_usecases.dart';

/// Service Locator for Audio Bubble use cases
/// Provides convenient access to audio-related use cases
/// Wires to SharedUiServiceLocator for dependency resolution
class AudioServiceLocator {
  static final AudioServiceLocator _instance = AudioServiceLocator._internal();

  late SharedUiServiceLocator _sharedLocator;

  AudioServiceLocator._internal() {
    _sharedLocator = SharedUiServiceLocator();
  }

  static AudioServiceLocator get instance => _instance;

  /// Get use case for retrieving current audio state
  GetAudioStateUseCase getGetAudioStateUseCase() {
    return _sharedLocator.getAudioStateUseCase;
  }

  /// Get use case for playing audio
  PlayAudioUseCase getPlayAudioUseCase() {
    return _sharedLocator.playAudioUseCase;
  }

  /// Get use case for pausing audio
  PauseAudioUseCase getPauseAudioUseCase() {
    return _sharedLocator.pauseAudioUseCase;
  }

  /// Get use case for stopping audio
  StopAudioUseCase getStopAudioUseCase() {
    return _sharedLocator.stopAudioUseCase;
  }

  /// Get use case for seeking audio
  SeekAudioUseCase getSeekAudioUseCase() {
    return _sharedLocator.seekAudioUseCase;
  }

  /// Get use case for getting audio state stream
  GetAudioStateStreamUseCase getGetAudioStateStreamUseCase() {
    return _sharedLocator.getAudioStateStreamUseCase;
  }
}
