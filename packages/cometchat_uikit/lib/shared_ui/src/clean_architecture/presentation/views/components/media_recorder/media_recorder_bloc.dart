import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class MediaRecorderEvent extends Equatable {
  const MediaRecorderEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRecorderEvent extends MediaRecorderEvent {
  const InitializeRecorderEvent();
}

class StartRecordingEvent extends MediaRecorderEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends MediaRecorderEvent {
  const StopRecordingEvent();
}

class PauseRecordingEvent extends MediaRecorderEvent {
  const PauseRecordingEvent();
}

class ResumeRecordingEvent extends MediaRecorderEvent {
  const ResumeRecordingEvent();
}

class CancelRecordingEvent extends MediaRecorderEvent {
  const CancelRecordingEvent();
}

class UpdateTimerEvent extends MediaRecorderEvent {
  final Duration duration;

  const UpdateTimerEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class UpdateVisualizerEvent extends MediaRecorderEvent {
  final List<double> amplitudes;

  const UpdateVisualizerEvent(this.amplitudes);

  @override
  List<Object?> get props => [amplitudes];
}

class RecordingErrorEvent extends MediaRecorderEvent {
  final String error;

  const RecordingErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

// States
abstract class MediaRecorderState extends Equatable {
  final Duration duration;
  final List<double> amplitudes;
  final String? filePath;
  final String? error;

  const MediaRecorderState({
    this.duration = Duration.zero,
    this.amplitudes = const [],
    this.filePath,
    this.error,
  });

  // Computed properties
  bool get isRecording => this is MediaRecorderRecording;
  bool get isPaused => this is MediaRecorderPaused;
  bool get isCompleted => this is MediaRecorderCompleted;
  bool get hasError => this is MediaRecorderError;
  bool get canRecord =>
      this is MediaRecorderReady || this is MediaRecorderCompleted;

  @override
  List<Object?> get props => [duration, amplitudes, filePath, error];
}

class MediaRecorderInitial extends MediaRecorderState {
  const MediaRecorderInitial();
}

class MediaRecorderReady extends MediaRecorderState {
  const MediaRecorderReady();
}

class MediaRecorderRecording extends MediaRecorderState {
  const MediaRecorderRecording({
    required super.duration,
    required super.amplitudes,
  });

  MediaRecorderRecording copyWith({
    Duration? duration,
    List<double>? amplitudes,
  }) {
    return MediaRecorderRecording(
      duration: duration ?? this.duration,
      amplitudes: amplitudes ?? this.amplitudes,
    );
  }
}

class MediaRecorderPaused extends MediaRecorderState {
  const MediaRecorderPaused({
    required super.duration,
    required super.amplitudes,
  });
}

class MediaRecorderCompleted extends MediaRecorderState {
  const MediaRecorderCompleted({
    required super.duration,
    required super.filePath,
  });
}

class MediaRecorderError extends MediaRecorderState {
  const MediaRecorderError({required super.error});
}

// BLoC
class MediaRecorderBloc extends Bloc<MediaRecorderEvent, MediaRecorderState> {
  Timer? _timer;
  StreamSubscription? _amplitudeSubscription;

  MediaRecorderBloc() : super(const MediaRecorderInitial()) {
    on<InitializeRecorderEvent>(_onInitialize);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
    on<UpdateTimerEvent>(_onUpdateTimer);
    on<UpdateVisualizerEvent>(_onUpdateVisualizer);
    on<RecordingErrorEvent>(_onRecordingError);
  }

  void _onInitialize(
    InitializeRecorderEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    emit(const MediaRecorderReady());
  }

  void _onStartRecording(
    StartRecordingEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    emit(const MediaRecorderRecording(duration: Duration.zero, amplitudes: []));

    // Start timer
    _startTimer();
  }

  void _onStopRecording(
    StopRecordingEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    _stopTimer();
    _amplitudeSubscription?.cancel();

    // Emit completed state with file path
    // File path should be provided by the actual recording service
    emit(
      MediaRecorderCompleted(
        duration: state.duration,
        filePath: null, // Will be set by the recording service
      ),
    );
  }

  void _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    _stopTimer();

    if (state is MediaRecorderRecording) {
      emit(
        MediaRecorderPaused(
          duration: state.duration,
          amplitudes: state.amplitudes,
        ),
      );
    }
  }

  void _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    if (state is MediaRecorderPaused) {
      emit(
        MediaRecorderRecording(
          duration: state.duration,
          amplitudes: state.amplitudes,
        ),
      );
      _startTimer();
    }
  }

  void _onCancelRecording(
    CancelRecordingEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    _stopTimer();
    _amplitudeSubscription?.cancel();
    emit(const MediaRecorderReady());
  }

  void _onUpdateTimer(
    UpdateTimerEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    if (state is MediaRecorderRecording) {
      final currentState = state as MediaRecorderRecording;
      emit(currentState.copyWith(duration: event.duration));
    }
  }

  void _onUpdateVisualizer(
    UpdateVisualizerEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    if (state is MediaRecorderRecording) {
      final currentState = state as MediaRecorderRecording;
      emit(currentState.copyWith(amplitudes: event.amplitudes));
    }
  }

  void _onRecordingError(
    RecordingErrorEvent event,
    Emitter<MediaRecorderState> emit,
  ) {
    _stopTimer();
    _amplitudeSubscription?.cancel();
    emit(MediaRecorderError(error: event.error));
  }

  void _startTimer() {
    _timer?.cancel();
    final startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      add(UpdateTimerEvent(state.duration + elapsed));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    _amplitudeSubscription?.cancel();
    return super.close();
  }
}
