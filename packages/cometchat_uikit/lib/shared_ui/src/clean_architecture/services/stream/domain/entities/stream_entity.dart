/// Stream Entity - Domain Model
/// Represents a stream in the domain layer
/// Pure data class with no external dependencies
class StreamEntity {
  /// Unique identifier for the stream
  final String id;

  /// Stream name or title
  final String name;

  /// Stream URL or source
  final String url;

  /// Whether stream is currently playing
  final bool isPlaying;

  /// Stream duration (if applicable)
  final Duration duration;

  /// Current playback position
  final Duration position;

  /// When stream was created
  final DateTime createdAt;

  /// Constructor
  const StreamEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.createdAt,
  });

  /// Copy with method for immutability
  StreamEntity copyWith({
    String? id,
    String? name,
    String? url,
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    DateTime? createdAt,
  }) {
    return StreamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'StreamEntity{id: $id, name: $name, url: $url, isPlaying: $isPlaying, duration: $duration, position: $position, createdAt: $createdAt}';
  }
}

/// Enum for stream playback status
enum StreamPlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  completed,
  error,
}

/// Detailed stream status update entity
class StreamStatusUpdate {
  final StreamPlaybackStatus status;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final String? errorMessage;

  const StreamStatusUpdate({
    required this.status,
    required this.position,
    required this.duration,
    required this.bufferedPosition,
    this.errorMessage,
  });

  bool get isPlaying => status == StreamPlaybackStatus.playing;
  bool get isPaused => status == StreamPlaybackStatus.paused;
  bool get isCompleted => status == StreamPlaybackStatus.completed;
  bool get hasError => status == StreamPlaybackStatus.error;

  @override
  String toString() {
    return 'StreamStatusUpdate(status: $status, position: $position, '
        'duration: $duration, buffered: $bufferedPosition)';
  }
}
