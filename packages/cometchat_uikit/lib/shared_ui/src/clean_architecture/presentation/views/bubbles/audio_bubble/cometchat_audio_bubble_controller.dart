import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

/// Global state manager for audio bubbles to preserve playback state across widget rebuilds
class AudioStateManager {
  static final AudioStateManager _singleton = AudioStateManager._internal();

  factory AudioStateManager() {
    return _singleton;
  }

  AudioStateManager._internal();

  final Map<int, AudioBubbleState> _audioStates = {};

  /// Get or create audio state for a specific audio bubble
  AudioBubbleState getAudioState(int id, String? audioUrl, String? localPath) {
    if (!_audioStates.containsKey(id)) {
      _audioStates[id] = AudioBubbleState(
        id: id,
        audioUrl: audioUrl,
        localPath: localPath,
      );
    } else {
      final state = _audioStates[id]!;
      if (localPath != null && localPath.isNotEmpty) {
        state.updateLocalPath(localPath);
      }
    }
    return _audioStates[id]!;
  }


  /// Remove audio state when bubble is permanently disposed
  void removeAudioState(int id) {
    final state = _audioStates[id];
    if (state != null) {
      state.dispose();
      _audioStates.remove(id);
    }
  }

  /// Stop all audio playback
  void stopAllAudio() {
    for (final state in _audioStates.values) {
      state.stopAudio();
    }
  }

  /// Pause all audio except the specified one
  void pauseAllExcept(int excludeId) {
    for (final state in _audioStates.values) {
      if (state.id != excludeId) {
        state.pauseAudio();
      }
    }
  }

  /// Clear all audio states and release all memory
  /// Call this when message list is disposed
  void clearAll() {
    for (final state in _audioStates.values) {
      state.dispose();
    }
    _audioStates.clear();
  }
}

/// Individual audio state for each audio bubble
class AudioBubbleState {
  final int id;
  final String? audioUrl;
  String? localPath;

  VideoPlayerController? _controller;
  PlayStates _playState = PlayStates.init;
  bool _isInitializing = false;
  Duration? _totalDuration;
  Duration _currentPosition = Duration.zero;

  final StreamController<AudioStateUpdate> _stateController = StreamController<AudioStateUpdate>.broadcast();

  AudioBubbleState({
    required this.id,
    required this.audioUrl,
    required this.localPath,
  });

  Stream<AudioStateUpdate> get stateStream => _stateController.stream;

  PlayStates get playState => _playState;
  VideoPlayerController? get controller => _controller;
  bool get isInitializing => _isInitializing;
  Duration? get totalDuration => _totalDuration;
  Duration get currentPosition => _currentPosition;

  Future<void> initializeController() async {
    debugPrint("initializeController: $id");

    // Do not re-initialize if already initialized
    if (_controller != null) return;

    try {
      _isInitializing = true;
      _notifyStateUpdate();

      /// ✅ Check if local file REALLY exists
      final bool hasValidLocalFile =
          localPath != null &&
              localPath!.isNotEmpty &&
              File(localPath!).existsSync();

      if (hasValidLocalFile) {
        debugPrint("Using LOCAL audio file: $localPath");

        if (Platform.isIOS) {
          await _setAudioSessionToSpeaker();
        }

        _controller = VideoPlayerController.file(
          File(localPath!),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        );
      } else if (audioUrl != null && audioUrl!.isNotEmpty) {
        debugPrint("Using NETWORK audio url: $audioUrl");

        if (Platform.isIOS) {
          await _resetAudioSession();
        }

        _controller = VideoPlayerController.networkUrl(
          Uri.parse(audioUrl!),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        );
      } else {
        debugPrint("No valid audio source found for id: $id");
        _isInitializing = false;
        _notifyStateUpdate();
        return;
      }

      /// ✅ Initialize controller
      await _controller!.initialize();

      _totalDuration = _controller!.value.duration;

      /// ✅ Listen for progress & completion
      _controller!.addListener(_onControllerUpdate);

    } catch (e, stack) {
      debugPrint("Error initializing audio controller: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      _isInitializing = false;
      _notifyStateUpdate();
    }
  }

  void _onControllerUpdate() {
    if (_controller != null) {
      _currentPosition = _controller!.value.position;
      _notifyStateUpdate();

      if (_controller!.value.isCompleted) {
        stopAudio();
      }
    }
  }

  Future<void> playAudio() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initializeController();
    }

    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      // Pause all other audio bubbles
      AudioStateManager().pauseAllExcept(id);

      _playState = PlayStates.playing;
      await controller.play();
      _notifyStateUpdate();
    }
  }

  Future<void> pauseAudio() async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
      _playState = PlayStates.paused;
      _notifyStateUpdate();
    }
  }

  Future<void> stopAudio() async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
      await controller.seekTo(Duration.zero);
      _playState = PlayStates.stopped;
      _currentPosition = Duration.zero;
      _notifyStateUpdate();
    }
  }

  /// Seek to a specific duration
  Future<void> seekTo(Duration position) async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.seekTo(position);
      _currentPosition = position;
      _notifyStateUpdate();
    }
  }

  /// Seek to a progress value (0.0 - 1.0)
  Future<void> seekToProgress(double progress) async {
    if (_controller != null && _controller!.value.isInitialized && _totalDuration != null) {
      final position = Duration(
        milliseconds: (_totalDuration!.inMilliseconds * progress.clamp(0.0, 1.0)).round(),
      );
      await seekTo(position);
    }
  }

  /// Get current playback progress (0.0 - 1.0)
  double get playbackProgress {
    if (_totalDuration == null || _totalDuration!.inMilliseconds == 0) {
      return 0.0;
    }
    return (_currentPosition.inMilliseconds / _totalDuration!.inMilliseconds).clamp(0.0, 1.0);
  }

  void _notifyStateUpdate() {
    if (!_stateController.isClosed) {
      _stateController.add(AudioStateUpdate(
        id: id,
        playState: _playState,
        isInitializing: _isInitializing,
        totalDuration: _totalDuration,
        currentPosition: _currentPosition,
      ));
    }
  }

  Future<void> _setAudioSessionToSpeaker() async {
    MethodChannel channel = const MethodChannel('cometchat_uikit_shared');
    try {
      await channel.invokeMethod('setAudioSessionToSpeaker');
    } catch (e) {
      debugPrint('Error setting audio session to speaker: $e');
    }
  }

  Future<void> _resetAudioSession() async {
    MethodChannel channel = const MethodChannel('cometchat_uikit_shared');
    try {
      await channel.invokeMethod('resetAudioSession');
    } catch (e) {
      debugPrint('Error resetting audio session: $e');
    }
  }

  void updateLocalPath(String path) {
    localPath = path;
    _playState = PlayStates.init;
    _disposeController();
    _notifyStateUpdate();
  }


  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
  }


  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    _stateController.close();

    if (localPath != null && Platform.isIOS) {
      _resetAudioSession();
    }
  }
}

enum PlayStates { playing, paused, stopped, init }

class AudioStateUpdate {
  final int id;
  final PlayStates playState;
  final bool isInitializing;
  final Duration? totalDuration;
  final Duration currentPosition;

  AudioStateUpdate({
    required this.id,
    required this.playState,
    required this.isInitializing,
    required this.totalDuration,
    required this.currentPosition,
  });
}
