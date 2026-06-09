import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/platform_utils/platform_file_utils.dart' as platform;

// Conditional import for web audio player
import 'web_audio_player_stub.dart'
    if (dart.library.html) 'web_audio_player.dart' as web_player;

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
  web_player.WebAudioPlayer? _webPlayer;
  StreamSubscription<Duration>? _webPositionSub;
  StreamSubscription<void>? _webCompletionSub;
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

  /// Completer to prevent concurrent initialization calls
  Completer<void>? _initCompleter;

  Future<void> initializeController() async {
    debugPrint("initializeController: $id");

    // If already initialized, return immediately
    if (kIsWeb && _webPlayer != null && _webPlayer!.isInitialized) return;
    if (!kIsWeb && _controller != null && _controller!.value.isInitialized) return;

    // If initialization is already in progress, wait for it
    if (_isInitializing && _initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    try {
      _initCompleter = Completer<void>();
      _isInitializing = true;
      _notifyStateUpdate();

      if (kIsWeb) {
        // Web: use HTML <audio> element for proper webm/opus support
        if (audioUrl == null || audioUrl!.isEmpty) {
          debugPrint("No valid audio URL for web playback, id: $id");
          _isInitializing = false;
          _notifyStateUpdate();
          return;
        }

        debugPrint("Using WEB audio player for: $audioUrl");
        _webPlayer = web_player.createWebAudioPlayer();
        final success = await _webPlayer!.initialize(audioUrl!);

        if (!success) {
          debugPrint('[AudioBubbleState] Web audio player failed to initialize for id: $id');
          _webPlayer?.dispose();
          _webPlayer = null;
          _isInitializing = false;
          _notifyStateUpdate();
          return;
        }

        _totalDuration = _webPlayer!.duration;
        debugPrint('[AudioBubbleState] Web audio initialized for id: $id, duration: $_totalDuration');

        // Listen for position updates
        _webPositionSub = _webPlayer!.positionStream.listen((pos) {
          _currentPosition = pos;
          // Update duration if it changed (webm progressive duration)
          if (_webPlayer!.duration > Duration.zero) {
            _totalDuration = _webPlayer!.duration;
          }
          _notifyStateUpdate();
        });

        // Listen for completion
        _webCompletionSub = _webPlayer!.completionStream.listen((_) {
          stopAudio();
        });

      } else {
        // Native: use VideoPlayerController
        final bool hasValidLocalFile =
            localPath != null &&
                localPath!.isNotEmpty &&
                platform.fileExistsSync(localPath!);

        if (hasValidLocalFile) {
          debugPrint("Using LOCAL audio file: $localPath");

          if (platform.platformIsIOS()) {
            await _setAudioSessionToSpeaker();
          }

          _controller = VideoPlayerController.networkUrl(
            Uri.parse('file://$localPath'),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
            ),
          );
        } else if (audioUrl != null && audioUrl!.isNotEmpty) {
          debugPrint("Using NETWORK audio url: $audioUrl");

          if (platform.platformIsIOS()) {
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

        await _controller!.initialize();

        if (!_controller!.value.isInitialized) {
          debugPrint('[AudioBubbleState] Controller failed to initialize for id: $id');
          _disposeController();
          _isInitializing = false;
          _notifyStateUpdate();
          return;
        }

        _totalDuration = _controller!.value.duration;
        debugPrint('[AudioBubbleState] Initialized successfully for id: $id, duration: $_totalDuration');

        _controller!.addListener(_onControllerUpdate);
      }

    } catch (e, stack) {
      debugPrint("Error initializing audio controller for id: $id — $e");
      debugPrintStack(stackTrace: stack);
      _disposeController();
      _webPlayer?.dispose();
      _webPlayer = null;
    } finally {
      _isInitializing = false;
      _initCompleter?.complete();
      _initCompleter = null;
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
    if (kIsWeb) {
      if (_webPlayer == null || !_webPlayer!.isInitialized) {
        await initializeController();
      }
      if (_webPlayer == null || !_webPlayer!.isInitialized) {
        debugPrint('[AudioBubbleState] Cannot play — web player not initialized for id: $id');
        _playState = PlayStates.stopped;
        _notifyStateUpdate();
        return;
      }
      try {
        AudioStateManager().pauseAllExcept(id);
        _playState = PlayStates.playing;
        await _webPlayer!.play();
        _notifyStateUpdate();
      } catch (e, stack) {
        debugPrint('[AudioBubbleState] Error playing web audio for id: $id — $e');
        debugPrintStack(stackTrace: stack);
        _playState = PlayStates.stopped;
        _notifyStateUpdate();
      }
    } else {
      if (_controller == null || !_controller!.value.isInitialized) {
        await initializeController();
      }
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) {
        debugPrint('[AudioBubbleState] Cannot play — controller not initialized for id: $id');
        _playState = PlayStates.stopped;
        _notifyStateUpdate();
        return;
      }
      try {
        AudioStateManager().pauseAllExcept(id);
        _playState = PlayStates.playing;
        await controller.play();
        _notifyStateUpdate();
      } catch (e, stack) {
        debugPrint('[AudioBubbleState] Error playing audio for id: $id — $e');
        debugPrintStack(stackTrace: stack);
        _playState = PlayStates.stopped;
        _notifyStateUpdate();
      }
    }
  }

  Future<void> pauseAudio() async {
    if (kIsWeb) {
      _webPlayer?.pause();
      _playState = PlayStates.paused;
      _notifyStateUpdate();
    } else {
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        _playState = PlayStates.paused;
        _notifyStateUpdate();
      }
    }
  }

  Future<void> stopAudio() async {
    if (kIsWeb) {
      _webPlayer?.pause();
      _webPlayer?.seekTo(Duration.zero);
      _playState = PlayStates.stopped;
      _currentPosition = Duration.zero;
      _notifyStateUpdate();
    } else {
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        await controller.seekTo(Duration.zero);
        _playState = PlayStates.stopped;
        _currentPosition = Duration.zero;
        _notifyStateUpdate();
      }
    }
  }

  /// Seek to a specific duration
  Future<void> seekTo(Duration position) async {
    if (kIsWeb) {
      _webPlayer?.seekTo(position);
      _currentPosition = position;
      _notifyStateUpdate();
    } else {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.seekTo(position);
        _currentPosition = position;
        _notifyStateUpdate();
      }
    }
  }

  /// Seek to a progress value (0.0 - 1.0)
  Future<void> seekToProgress(double progress) async {
    if (kIsWeb) {
      if (_webPlayer != null && _totalDuration != null) {
        final position = Duration(
          milliseconds: (_totalDuration!.inMilliseconds * progress.clamp(0.0, 1.0)).round(),
        );
        await seekTo(position);
      }
    } else {
      if (_controller != null && _controller!.value.isInitialized && _totalDuration != null) {
        final position = Duration(
          milliseconds: (_totalDuration!.inMilliseconds * progress.clamp(0.0, 1.0)).round(),
        );
        await seekTo(position);
      }
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
    if (kIsWeb) return;
    MethodChannel channel = const MethodChannel('cometchat_uikit_shared');
    try {
      await channel.invokeMethod('setAudioSessionToSpeaker');
    } catch (e) {
      debugPrint('Error setting audio session to speaker: $e');
    }
  }

  Future<void> _resetAudioSession() async {
    if (kIsWeb) return;
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
    _disposeWebPlayer();
    _notifyStateUpdate();
  }


  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
  }

  void _disposeWebPlayer() {
    _webPositionSub?.cancel();
    _webPositionSub = null;
    _webCompletionSub?.cancel();
    _webCompletionSub = null;
    _webPlayer?.dispose();
    _webPlayer = null;
  }


  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    _disposeWebPlayer();
    _stateController.close();

    if (!kIsWeb && localPath != null && platform.platformIsIOS()) {
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
