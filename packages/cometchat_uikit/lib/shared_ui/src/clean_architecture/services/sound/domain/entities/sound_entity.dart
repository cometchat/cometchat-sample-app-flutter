/// Domain Entity for Sound
/// Represents an audio sound in the domain layer
class SoundEntity {
  final String id;
  final String name;
  final String filePath;
  final Duration duration;
  final bool isPlaying;
  final DateTime createdAt;

  const SoundEntity({
    required this.id,
    required this.name,
    required this.filePath,
    required this.duration,
    this.isPlaying = false,
    required this.createdAt,
  });

  /// Copy with method for immutability
  SoundEntity copyWith({
    String? id,
    String? name,
    String? filePath,
    Duration? duration,
    bool? isPlaying,
    DateTime? createdAt,
  }) {
    return SoundEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'SoundEntity(id: $id, name: $name, isPlaying: $isPlaying)';
}

/// Sound playback status
enum SoundPlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  completed,
  error,
}
