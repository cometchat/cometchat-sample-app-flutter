/// Domain Layer - Audio State Entity
/// Represents the state of an audio bubble playback
enum PlayState { init, loading, playing, paused, stopped, error }

class AudioStateEntity {
  final int id;
  final String? audioUrl;
  final String? localPath;
  final PlayState playState;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isInitializing;
  final String? errorMessage;

  AudioStateEntity({
    required this.id,
    required this.audioUrl,
    required this.localPath,
    required this.playState,
    required this.currentPosition,
    required this.totalDuration,
    required this.isInitializing,
    this.errorMessage,
  });

  /// Create a copy with modified fields
  AudioStateEntity copyWith({
    int? id,
    String? audioUrl,
    String? localPath,
    PlayState? playState,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isInitializing,
    String? errorMessage,
  }) {
    return AudioStateEntity(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      playState: playState ?? this.playState,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isInitializing: isInitializing ?? this.isInitializing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AudioStateEntity(id: $id, playState: $playState, position: $currentPosition, duration: $totalDuration)';
  }
}

/// Event emitted when audio state changes
class AudioStateUpdateEntity {
  final int audioId;
  final PlayState state;
  final Duration? currentPosition;
  final Duration? totalDuration;
  final String? errorMessage;

  AudioStateUpdateEntity({
    required this.audioId,
    required this.state,
    this.currentPosition,
    this.totalDuration,
    this.errorMessage,
  });

  @override
  String toString() =>
      'AudioStateUpdateEntity(id: $audioId, state: $state, position: $currentPosition)';
}
