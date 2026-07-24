import 'package:equatable/equatable.dart';

/// Base class for all inline audio recorder events
abstract class InlineAudioRecorderEvent extends Equatable {
  const InlineAudioRecorderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start recording
class StartRecording extends InlineAudioRecorderEvent {
  const StartRecording();
}

/// Event to pause recording
class PauseRecording extends InlineAudioRecorderEvent {
  const PauseRecording();
}

/// Event to resume recording
class ResumeRecording extends InlineAudioRecorderEvent {
  /// Whether this is a fresh restart (old recording lost) or true resume
  final bool isFreshRestart;

  const ResumeRecording({this.isFreshRestart = false});

  @override
  List<Object?> get props => [isFreshRestart];
}

/// Event to stop recording
class StopRecording extends InlineAudioRecorderEvent {
  const StopRecording();
}

/// Event to cancel/delete recording
class CancelRecording extends InlineAudioRecorderEvent {
  const CancelRecording();
}

/// Event to play the recorded audio
class PlayRecording extends InlineAudioRecorderEvent {
  const PlayRecording();
}

/// Event to pause playback
class PausePlayback extends InlineAudioRecorderEvent {
  const PausePlayback();
}

/// Event to resume playback from current position
class ResumePlayback extends InlineAudioRecorderEvent {
  const ResumePlayback();
}

/// Event to update the recording duration
class UpdateDuration extends InlineAudioRecorderEvent {
  final Duration duration;

  const UpdateDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to update the playback position
class UpdatePlaybackPosition extends InlineAudioRecorderEvent {
  final Duration position;

  const UpdatePlaybackPosition(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to update amplitude for waveform visualization
class UpdateAmplitude extends InlineAudioRecorderEvent {
  final double amplitude;

  const UpdateAmplitude(this.amplitude);

  @override
  List<Object?> get props => [amplitude];
}

/// Event when recording is completed with file path
class RecordingCompleted extends InlineAudioRecorderEvent {
  final String filePath;
  final Duration duration;

  const RecordingCompleted({required this.filePath, required this.duration});

  @override
  List<Object?> get props => [filePath, duration];
}

/// Event when playback is completed
class PlaybackCompleted extends InlineAudioRecorderEvent {
  const PlaybackCompleted();
}

/// Event when an error occurs
class RecordingError extends InlineAudioRecorderEvent {
  final String message;

  const RecordingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to reset the recorder to idle state
class ResetRecorder extends InlineAudioRecorderEvent {
  const ResetRecorder();
}

/// Event to seek to a specific position during playback
class SeekToPosition extends InlineAudioRecorderEvent {
  final double progress; // 0.0 to 1.0

  const SeekToPosition(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Event to set the extracted waveform from the audio file
class SetExtractedWaveform extends InlineAudioRecorderEvent {
  final List<double> waveform;

  const SetExtractedWaveform(this.waveform);

  @override
  List<Object?> get props => [waveform];
}
