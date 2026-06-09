import 'dart:async';

/// Stub for non-web platforms — never instantiated on native.
class WebAudioPlayer {
  Stream<Duration> get positionStream => const Stream.empty();
  Stream<void> get completionStream => const Stream.empty();
  bool get isInitialized => false;
  Duration get duration => Duration.zero;
  Duration get position => Duration.zero;

  Future<bool> initialize(String url) async => false;
  Future<void> play() async {}
  void pause() {}
  void seekTo(Duration position) {}
  void dispose() {}
}

/// Factory function for conditional import
WebAudioPlayer createWebAudioPlayer() => WebAudioPlayer();
