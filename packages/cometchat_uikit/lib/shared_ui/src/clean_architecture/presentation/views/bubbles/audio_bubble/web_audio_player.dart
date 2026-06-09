// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// Web-specific audio player using HTML <audio> element.
/// Handles webm/opus playback correctly (unlike video_player which uses <video>).
class WebAudioPlayer {
  html.AudioElement? _audio;
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
    if (_audio == null) return Duration.zero;
    return Duration(milliseconds: (_audio!.currentTime * 1000).round());
  }

  /// Initialize with an audio URL
  Future<bool> initialize(String url) async {
    try {
      _audio = html.AudioElement(url);
      _audio!.preload = 'auto';

      // Wait for metadata to load (gives us duration)
      final completer = Completer<bool>();

      _audio!.onLoadedMetadata.first.then((_) {
        final dur = _audio!.duration;
        // webm files often report Infinity duration initially
        if (dur.isFinite && dur > 0) {
          _duration = Duration(milliseconds: (dur * 1000).round());
        }
        _isInitialized = true;
        if (!completer.isCompleted) completer.complete(true);
      });

      _audio!.onError.first.then((_) {
        if (!completer.isCompleted) completer.complete(false);
      });

      // Handle duration change (webm files update duration during playback)
      _audio!.onDurationChange.listen((_) {
        final dur = _audio!.duration;
        if (dur.isFinite && dur > 0) {
          _duration = Duration(milliseconds: (dur * 1000).round());
        }
      });

      _audio!.onEnded.listen((_) {
        _stopPositionTimer();
        if (!_completionController.isClosed) {
          _completionController.add(null);
        }
      });

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
    if (_audio == null) return;
    await _audio!.play();
    _startPositionTimer();
  }

  void pause() {
    _audio?.pause();
    _stopPositionTimer();
  }

  void seekTo(Duration position) {
    if (_audio == null) return;
    _audio!.currentTime = position.inMilliseconds / 1000.0;
  }

  void dispose() {
    _stopPositionTimer();
    if (_audio != null) {
      _audio!.pause();
      _audio!.src = '';
      _audio = null;
    }
    _positionController.close();
    _completionController.close();
    _isInitialized = false;
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_audio == null) return;
      final pos = Duration(milliseconds: (_audio!.currentTime * 1000).round());
      if (!_positionController.isClosed) {
        _positionController.add(pos);
      }
      // Update duration if it changed (webm progressive duration)
      final dur = _audio!.duration;
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
