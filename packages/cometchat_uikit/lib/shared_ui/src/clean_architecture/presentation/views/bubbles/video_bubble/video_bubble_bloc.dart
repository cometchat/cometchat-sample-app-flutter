import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class VideoBubbleEvent {}

class InitializeVideoEvent extends VideoBubbleEvent {
  final String? videoUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  InitializeVideoEvent({
    this.videoUrl,
    this.thumbnailUrl,
    this.metadata,
  });
}

class LoadThumbnailEvent extends VideoBubbleEvent {}

class ThumbnailLoadedEvent extends VideoBubbleEvent {}

class ThumbnailLoadFailedEvent extends VideoBubbleEvent {
  final String error;

  ThumbnailLoadFailedEvent(this.error);
}

class VideoClickEvent extends VideoBubbleEvent {}

class PlayVideoEvent extends VideoBubbleEvent {}

class PauseVideoEvent extends VideoBubbleEvent {}

// States
abstract class VideoBubbleBlocState {
  final String? videoUrl;
  final String? thumbnailUrl;
  final bool isThumbnailLoading;
  final bool isThumbnailLoaded;
  final bool isPlaying;
  final String? error;
  final Map<String, dynamic>? metadata;

  const VideoBubbleBlocState({
    this.videoUrl,
    this.thumbnailUrl,
    this.isThumbnailLoading = false,
    this.isThumbnailLoaded = false,
    this.isPlaying = false,
    this.error,
    this.metadata,
  });

  // Computed properties
  bool get shouldShowPlayButton => !isPlaying;
  bool get shouldShowLoader => isThumbnailLoading;
  bool get hasError => error != null;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}

class VideoBubbleInitial extends VideoBubbleBlocState {
  const VideoBubbleInitial()
      : super(
          videoUrl: null,
          thumbnailUrl: null,
          isThumbnailLoading: false,
          isThumbnailLoaded: false,
          isPlaying: false,
        );
}

class VideoBubbleLoaded extends VideoBubbleBlocState {
  const VideoBubbleLoaded({
    super.videoUrl,
    super.thumbnailUrl,
    super.isThumbnailLoading,
    super.isThumbnailLoaded,
    super.isPlaying,
    super.error,
    super.metadata,
  });

  VideoBubbleLoaded copyWith({
    String? videoUrl,
    String? thumbnailUrl,
    bool? isThumbnailLoading,
    bool? isThumbnailLoaded,
    bool? isPlaying,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return VideoBubbleLoaded(
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isThumbnailLoading: isThumbnailLoading ?? this.isThumbnailLoading,
      isThumbnailLoaded: isThumbnailLoaded ?? this.isThumbnailLoaded,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}

// BLoC
class VideoBubbleBloc extends Bloc<VideoBubbleEvent, VideoBubbleBlocState> {
  VideoBubbleBloc() : super(const VideoBubbleInitial()) {
    on<InitializeVideoEvent>(_onInitialize);
    on<LoadThumbnailEvent>(_onLoadThumbnail);
    on<ThumbnailLoadedEvent>(_onThumbnailLoaded);
    on<ThumbnailLoadFailedEvent>(_onThumbnailLoadFailed);
    on<VideoClickEvent>(_onVideoClick);
    on<PlayVideoEvent>(_onPlayVideo);
    on<PauseVideoEvent>(_onPauseVideo);
  }

  void _onInitialize(
    InitializeVideoEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    emit(VideoBubbleLoaded(
      videoUrl: event.videoUrl,
      thumbnailUrl: event.thumbnailUrl,
      metadata: event.metadata,
    ));

    // Start loading thumbnail if available
    if (event.thumbnailUrl != null && event.thumbnailUrl!.isNotEmpty) {
      add(LoadThumbnailEvent());
    }
  }

  void _onLoadThumbnail(
    LoadThumbnailEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    if (state is VideoBubbleLoaded) {
      final currentState = state as VideoBubbleLoaded;
      emit(currentState.copyWith(
        isThumbnailLoading: true,
        error: null,
      ));
    }
  }

  void _onThumbnailLoaded(
    ThumbnailLoadedEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    if (state is VideoBubbleLoaded) {
      final currentState = state as VideoBubbleLoaded;
      emit(currentState.copyWith(
        isThumbnailLoading: false,
        isThumbnailLoaded: true,
      ));
    }
  }

  void _onThumbnailLoadFailed(
    ThumbnailLoadFailedEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    if (state is VideoBubbleLoaded) {
      final currentState = state as VideoBubbleLoaded;
      emit(currentState.copyWith(
        isThumbnailLoading: false,
        isThumbnailLoaded: false,
        error: event.error,
      ));
    }
  }

  void _onVideoClick(
    VideoClickEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    // Video click handling - would trigger video player
    // This event is mainly for tracking/logging purposes
    // The actual player navigation is handled by the view
  }

  void _onPlayVideo(
    PlayVideoEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    if (state is VideoBubbleLoaded) {
      final currentState = state as VideoBubbleLoaded;
      emit(currentState.copyWith(isPlaying: true));
    }
  }

  void _onPauseVideo(
    PauseVideoEvent event,
    Emitter<VideoBubbleBlocState> emit,
  ) {
    if (state is VideoBubbleLoaded) {
      final currentState = state as VideoBubbleLoaded;
      emit(currentState.copyWith(isPlaying: false));
    }
  }
}
