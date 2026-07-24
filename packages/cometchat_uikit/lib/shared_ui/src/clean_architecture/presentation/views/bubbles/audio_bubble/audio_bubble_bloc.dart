import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cometchat_audio_bubble_controller.dart';

/// Events for AudioBubbleBloc
abstract class AudioBubbleEvent {}

class InitializeAudioEvent extends AudioBubbleEvent {
  final int id;
  final String? audioUrl;
  final String? localPath;

  InitializeAudioEvent({required this.id, this.audioUrl, this.localPath});
}

class PlayAudioEvent extends AudioBubbleEvent {}

class PauseAudioEvent extends AudioBubbleEvent {}

class StopAudioEvent extends AudioBubbleEvent {}

class AudioStateChangedEvent extends AudioBubbleEvent {
  final AudioStateUpdate update;

  AudioStateChangedEvent(this.update);
}

/// States for AudioBubbleBloc
abstract class AudioBubbleBlocState {
  final PlayStates playState;
  final bool isInitializing;
  final Duration currentPosition;
  final Duration totalDuration;

  const AudioBubbleBlocState({
    required this.playState,
    required this.isInitializing,
    required this.currentPosition,
    required this.totalDuration,
  });

  bool get isPlaying => playState == PlayStates.playing;
  bool get isPaused => playState == PlayStates.paused;
  bool get isStopped => playState == PlayStates.stopped;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String get currentTime => formatDuration(currentPosition);
  String get totalTime => formatDuration(totalDuration);
}

class AudioBubbleInitial extends AudioBubbleBlocState {
  const AudioBubbleInitial()
    : super(
        playState: PlayStates.init,
        isInitializing: false,
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
      );
}

class AudioBubbleLoaded extends AudioBubbleBlocState {
  const AudioBubbleLoaded({
    required super.playState,
    required super.isInitializing,
    required super.currentPosition,
    required super.totalDuration,
  });

  AudioBubbleLoaded copyWith({
    PlayStates? playState,
    bool? isInitializing,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return AudioBubbleLoaded(
      playState: playState ?? this.playState,
      isInitializing: isInitializing ?? this.isInitializing,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

/// BLoC for Audio Bubble
class AudioBubbleBloc extends Bloc<AudioBubbleEvent, AudioBubbleBlocState> {
  AudioBubbleState? _audioState;
  StreamSubscription? _stateSubscription;

  AudioBubbleBloc() : super(const AudioBubbleInitial()) {
    on<InitializeAudioEvent>(_onInitialize);
    on<PlayAudioEvent>(_onPlay);
    on<PauseAudioEvent>(_onPause);
    on<StopAudioEvent>(_onStop);
    on<AudioStateChangedEvent>(_onStateChanged);
  }

  Future<void> _onInitialize(
    InitializeAudioEvent event,
    Emitter<AudioBubbleBlocState> emit,
  ) async {
    // Get audio state from AudioStateManager
    _audioState = AudioStateManager().getAudioState(
      event.id,
      event.audioUrl,
      event.localPath,
    );
    _audioState!.initializeController();

    // Subscribe to state changes
    _stateSubscription = _audioState!.stateStream.listen((update) {
      add(AudioStateChangedEvent(update));
    });

    // Emit initial state
    emit(
      AudioBubbleLoaded(
        playState: _audioState!.playState,
        isInitializing: _audioState!.isInitializing,
        currentPosition: _audioState!.currentPosition,
        totalDuration: _audioState!.totalDuration ?? Duration.zero,
      ),
    );
  }

  Future<void> _onPlay(
    PlayAudioEvent event,
    Emitter<AudioBubbleBlocState> emit,
  ) async {
    await _audioState?.playAudio();
  }

  Future<void> _onPause(
    PauseAudioEvent event,
    Emitter<AudioBubbleBlocState> emit,
  ) async {
    await _audioState?.pauseAudio();
  }

  Future<void> _onStop(
    StopAudioEvent event,
    Emitter<AudioBubbleBlocState> emit,
  ) async {
    await _audioState?.stopAudio();
  }

  void _onStateChanged(
    AudioStateChangedEvent event,
    Emitter<AudioBubbleBlocState> emit,
  ) {
    if (state is AudioBubbleLoaded) {
      emit(
        (state as AudioBubbleLoaded).copyWith(
          playState: event.update.playState,
          isInitializing: event.update.isInitializing,
          currentPosition: event.update.currentPosition,
          totalDuration:
              event.update.totalDuration ??
              (state as AudioBubbleLoaded).totalDuration,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
  }
}
