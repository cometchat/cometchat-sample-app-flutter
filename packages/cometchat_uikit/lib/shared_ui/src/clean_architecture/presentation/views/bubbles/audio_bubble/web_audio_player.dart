import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web-specific audio player using HTML <audio> element.
/// Handles webm/opus playback correctly (unlike video_player which uses <video>).
class WebAudioPlayer {
  web.HTMLAudioElement? _audio;
  Timer? _positionTimer;
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  bool _isInitialized = false;
  Duration _duration = Duration.zero;

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<void> get completionStream => _completionController.stream;
  bool get isInitialized => _isInitialized;
  Duration get duration => _duration;
  Duration get position {
    final audio = _audio;
    if (audio == null) return Duration.zero;
    return Duration(milliseconds: (audio.currentTime * 1000).round());
  }

  /// Initialize with an audio URL
  Future<bool> initialize(String url) async {
    try {
      final audio = web.document.createElement('audio') as web.HTMLAudioElement;
      audio
        ..preload = 'auto'
        ..src = url;
      _audio = audio;

      // Wait for metadata to load (gives us duration)
      final completer = Completer<bool>();

      audio.addEventListener(
        'loadedmetadata',
        (web.Event _) {
          final dur = audio.duration;
          // webm files often report Infinity duration initially
          if (dur.isFinite && dur > 0) {
            _duration = Duration(milliseconds: (dur * 1000).round());
          }
          _isInitialized = true;
          if (!completer.isCompleted) completer.complete(true);
        }.toJS,
      );

      audio.addEventListener(
        'error',
        (web.Event _) {
          if (!completer.isCompleted) completer.complete(false);
        }.toJS,
      );

      // Handle duration change (webm files update duration during playback)
      audio.addEventListener(
        'durationchange',
        (web.Event _) {
          final dur = audio.duration;
          if (dur.isFinite && dur > 0) {
            _duration = Duration(milliseconds: (dur * 1000).round());
          }
        }.toJS,
      );

      audio.addEventListener(
        'ended',
        (web.Event _) {
          _stopPositionTimer();
          if (!_completionController.isClosed) {
            _completionController.add(null);
          }
        }.toJS,
      );

      // Timeout after 5 seconds if metadata doesn't load
      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Even without metadata, we can try to play
          _isInitialized = true;
          return true;
        },
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> play() async {
    final audio = _audio;
    if (audio == null) return;
    await audio.play().toDart;
    _startPositionTimer();
  }

  void pause() {
    _audio?.pause();
    _stopPositionTimer();
  }

  void seekTo(Duration position) {
    final audio = _audio;
    if (audio == null) return;
    audio.currentTime = position.inMilliseconds / 1000.0;
  }

  void dispose() {
    _stopPositionTimer();
    final audio = _audio;
    if (audio != null) {
      audio.pause();
      audio.src = '';
      _audio = null;
    }
    _positionController.close();
    _completionController.close();
    _isInitialized = false;
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final audio = _audio;
      if (audio == null) return;
      final pos = Duration(milliseconds: (audio.currentTime * 1000).round());
      if (!_positionController.isClosed) {
        _positionController.add(pos);
      }
      // Update duration if it changed (webm progressive duration)
      final dur = audio.duration;
      if (dur.isFinite && dur > 0) {
        _duration = Duration(milliseconds: (dur * 1000).round());
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }
}

/// Factory function for conditional import
WebAudioPlayer createWebAudioPlayer() => WebAudioPlayer();
