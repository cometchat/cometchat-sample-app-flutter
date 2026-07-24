import 'package:equatable/equatable.dart';

/// Enum representing the different states of the inline audio recorder
enum InlineAudioRecorderStatus {
  /// Initial state - not recording
  idle,

  /// Currently recording audio
  recording,

  /// Recording is paused
  paused,

  /// Recording is complete and ready to send/preview
  completed,

  /// Playing back the recorded audio
  playing,

  /// Error state
  error,
}

/// State class for the inline audio recorder
class InlineAudioRecorderState extends Equatable {
  final InlineAudioRecorderStatus status;
  final Duration duration;
  final Duration currentPosition;
  final String? filePath;
  final String? errorMessage;
  final List<double> amplitudes;

  /// Waveform amplitudes extracted from the recorded audio file
  /// Used for accurate playback visualization
  final List<double> extractedWaveform;

  const InlineAudioRecorderState({
    this.status = InlineAudioRecorderStatus.idle,
    this.duration = Duration.zero,
    this.currentPosition = Duration.zero,
    this.filePath,
    this.errorMessage,
    this.amplitudes = const [],
    this.extractedWaveform = const [],
  });

  /// Whether the recorder is currently recording
  bool get isRecording => status == InlineAudioRecorderStatus.recording;

  /// Whether the recorder is paused
  bool get isPaused => status == InlineAudioRecorderStatus.paused;

  /// Whether the recording is complete
  bool get isCompleted => status == InlineAudioRecorderStatus.completed;

  /// Whether the recorder is playing back
  bool get isPlaying => status == InlineAudioRecorderStatus.playing;

  /// Whether the recorder is in an error state
  bool get hasError => status == InlineAudioRecorderStatus.error;

  /// Whether the recorder is idle
  bool get isIdle => status == InlineAudioRecorderStatus.idle;

  /// Whether there is a recording available (completed or paused with duration)
  bool get hasRecording =>
      (isCompleted || isPaused || isPlaying) && duration > Duration.zero;

  /// Whether the recorder is actively recording or paused mid-recording
  bool get isInRecordingSession =>
      isRecording || (isPaused && duration > Duration.zero && !isCompleted);

  InlineAudioRecorderState copyWith({
    InlineAudioRecorderStatus? status,
    Duration? duration,
    Duration? currentPosition,
    String? filePath,
    String? errorMessage,
    List<double>? amplitudes,
    List<double>? extractedWaveform,
  }) {
    return InlineAudioRecorderState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      currentPosition: currentPosition ?? this.currentPosition,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
      amplitudes: amplitudes ?? this.amplitudes,
      extractedWaveform: extractedWaveform ?? this.extractedWaveform,
    );
  }

  @override
  List<Object?> get props => [
    status,
    duration,
    currentPosition,
    filePath,
    errorMessage,
    amplitudes,
    extractedWaveform,
  ];
}
