import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'inline_audio_recorder_event.dart';
import 'inline_audio_recorder_state.dart';

/// BLoC for managing inline audio recorder state
///
/// Handles recording state, duration tracking, and playback.
/// Note: Amplitude visualization is handled directly by AudioWaveformVisualizer
/// which listens to the native audio intensity event channel.
class InlineAudioRecorderBloc
    extends Bloc<InlineAudioRecorderEvent, InlineAudioRecorderState> {
  Timer? _durationTimer;
  Timer? _playbackTimer;

  /// Method channel for native audio operations
  static const MethodChannel _channel = MethodChannel('cometchat_chat_uikit');

  InlineAudioRecorderBloc() : super(const InlineAudioRecorderState()) {
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<CancelRecording>(_onCancelRecording);
    on<PlayRecording>(_onPlayRecording);
    on<PausePlayback>(_onPausePlayback);
    on<ResumePlayback>(_onResumePlayback);
    on<UpdateDuration>(_onUpdateDuration);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<UpdateAmplitude>(_onUpdateAmplitude);
    on<RecordingCompleted>(_onRecordingCompleted);
    on<PlaybackCompleted>(_onPlaybackCompleted);
    on<RecordingError>(_onRecordingError);
    on<ResetRecorder>(_onResetRecorder);
    on<SeekToPosition>(_onSeekToPosition);
    on<SetExtractedWaveform>(_onSetExtractedWaveform);
  }

  void _onStartRecording(
    StartRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.recording,
        duration: Duration.zero,
        amplitudes: [],
        filePath: null,
        errorMessage: null,
      ),
    );

    _startDurationTimer();
  }

  void _onPauseRecording(
    PauseRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();

    emit(state.copyWith(status: InlineAudioRecorderStatus.paused));
  }

  void _onResumeRecording(
    ResumeRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    if (event.isFreshRestart) {
      // Fresh restart - reset duration and amplitudes
      emit(
        state.copyWith(
          status: InlineAudioRecorderStatus.recording,
          duration: Duration.zero,
          amplitudes: [],
          currentPosition: Duration.zero,
        ),
      );
    } else {
      // True resume - keep existing duration and amplitudes
      emit(state.copyWith(status: InlineAudioRecorderStatus.recording));
    }

    _startDurationTimer();
  }

  void _onStopRecording(
    StopRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();

    emit(state.copyWith(status: InlineAudioRecorderStatus.completed));
  }

  void _onCancelRecording(
    CancelRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();
    _stopPlaybackTimer();

    emit(const InlineAudioRecorderState());
  }

  void _onPlayRecording(
    PlayRecording event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.playing,
        currentPosition: Duration.zero,
      ),
    );

    _startPlaybackTimer();
  }

  void _onPausePlayback(
    PausePlayback event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopPlaybackTimer();

    emit(state.copyWith(status: InlineAudioRecorderStatus.paused));
  }

  void _onResumePlayback(
    ResumePlayback event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    // Resume playing from current position
    emit(state.copyWith(status: InlineAudioRecorderStatus.playing));

    _startPlaybackTimer();
  }

  void _onUpdateDuration(
    UpdateDuration event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onUpdatePlaybackPosition(
    UpdatePlaybackPosition event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    emit(state.copyWith(currentPosition: event.position));
  }

  void _onUpdateAmplitude(
    UpdateAmplitude event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    // Store all amplitudes for playback visualization
    final newAmplitudes = [
      ...state.amplitudes,
      event.amplitude.clamp(0.0, 1.0),
    ];
    emit(state.copyWith(amplitudes: newAmplitudes));
  }

  void _onRecordingCompleted(
    RecordingCompleted event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();

    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.completed,
        filePath: event.filePath,
        duration: event.duration,
      ),
    );
  }

  void _onPlaybackCompleted(
    PlaybackCompleted event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopPlaybackTimer();

    // Reset to completed state (not paused) so user can play again
    // Set currentPosition to duration to show full progress
    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.completed,
        currentPosition: Duration.zero,
      ),
    );
  }

  void _onRecordingError(
    RecordingError event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();
    _stopPlaybackTimer();

    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  void _onResetRecorder(
    ResetRecorder event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    _stopDurationTimer();
    _stopPlaybackTimer();

    emit(const InlineAudioRecorderState());
  }

  void _onSeekToPosition(
    SeekToPosition event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    // Calculate the new position based on progress (0.0 to 1.0)
    final newPosition = Duration(
      milliseconds: (state.duration.inMilliseconds * event.progress).round(),
    );

    // Stop any existing playback timer
    _stopPlaybackTimer();

    // Update the current position and set to playing
    emit(
      state.copyWith(
        status: InlineAudioRecorderStatus.playing,
        currentPosition: newPosition,
      ),
    );

    // Start the playback timer from the new position
    _startPlaybackTimerFromPosition(newPosition);
  }

  void _onSetExtractedWaveform(
    SetExtractedWaveform event,
    Emitter<InlineAudioRecorderState> emit,
  ) {
    emit(state.copyWith(extractedWaveform: event.waveform));
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    final startDuration = state.duration;
    final startTime = DateTime.now();

    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      add(UpdateDuration(startDuration + elapsed));
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();

    // Poll native player status every 100ms for accurate position tracking
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      try {
        final status = await _channel.invokeMethod('getPlaybackStatus', {});

        if (status is Map) {
          final isPlaying = status['isPlaying'] as bool? ?? false;
          final currentPosition = status['currentPosition'] as int? ?? 0;

          if (!isPlaying) {
            // Native player stopped - playback completed
            add(const PlaybackCompleted());
          } else {
            // Update position from native player
            add(
              UpdatePlaybackPosition(Duration(milliseconds: currentPosition)),
            );
          }
        }
      } catch (e) {
        // If we can't get status, fall back to timer-based tracking
        // This shouldn't happen normally
      }
    });
  }

  void _startPlaybackTimerFromPosition(Duration startPosition) {
    // Just use the same polling mechanism
    _startPlaybackTimer();
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  @override
  Future<void> close() {
    _stopDurationTimer();
    _stopPlaybackTimer();
    return super.close();
  }
}
