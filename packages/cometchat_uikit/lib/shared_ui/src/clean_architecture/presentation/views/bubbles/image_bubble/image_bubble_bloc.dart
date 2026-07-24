import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ImageBubbleEvent {}

class InitializeImageEvent extends ImageBubbleEvent {
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  InitializeImageEvent({this.imageUrl, this.metadata});
}

class LoadImageEvent extends ImageBubbleEvent {}

class ImageLoadedEvent extends ImageBubbleEvent {
  final Uint8List? imageBytes;
  final ui.Image? decodedImage;

  ImageLoadedEvent({this.imageBytes, this.decodedImage});
}

class ImageLoadFailedEvent extends ImageBubbleEvent {
  final String error;

  ImageLoadFailedEvent(this.error);
}

class CacheImageEvent extends ImageBubbleEvent {}

class CheckCacheEvent extends ImageBubbleEvent {}

class ImageClickEvent extends ImageBubbleEvent {}

// States
abstract class ImageBubbleBlocState {
  final String? imageUrl;
  final bool isLoading;
  final bool isLoaded;
  final bool isCached;
  final bool isHeicHeif;
  final Uint8List? imageBytes;
  final ui.Image? decodedImage;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ImageBubbleBlocState({
    this.imageUrl,
    this.isLoading = false,
    this.isLoaded = false,
    this.isCached = false,
    this.isHeicHeif = false,
    this.imageBytes,
    this.decodedImage,
    this.error,
    this.metadata,
  });

  // Computed properties
  bool get shouldShowPlaceholder => !isLoaded && !isLoading;
  bool get shouldShowLoader => isLoading;
  bool get hasError => error != null;
}

class ImageBubbleInitial extends ImageBubbleBlocState {
  const ImageBubbleInitial()
    : super(imageUrl: null, isLoading: false, isLoaded: false, isCached: false);
}

class ImageBubbleLoaded extends ImageBubbleBlocState {
  const ImageBubbleLoaded({
    super.imageUrl,
    super.isLoading,
    super.isLoaded,
    super.isCached,
    super.isHeicHeif,
    super.imageBytes,
    super.decodedImage,
    super.error,
    super.metadata,
  });

  ImageBubbleLoaded copyWith({
    String? imageUrl,
    bool? isLoading,
    bool? isLoaded,
    bool? isCached,
    bool? isHeicHeif,
    Uint8List? imageBytes,
    ui.Image? decodedImage,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return ImageBubbleLoaded(
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      isCached: isCached ?? this.isCached,
      isHeicHeif: isHeicHeif ?? this.isHeicHeif,
      imageBytes: imageBytes ?? this.imageBytes,
      decodedImage: decodedImage ?? this.decodedImage,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}

// BLoC
class ImageBubbleBloc extends Bloc<ImageBubbleEvent, ImageBubbleBlocState> {
  ImageBubbleBloc() : super(const ImageBubbleInitial()) {
    on<InitializeImageEvent>(_onInitialize);
    on<LoadImageEvent>(_onLoadImage);
    on<ImageLoadedEvent>(_onImageLoaded);
    on<ImageLoadFailedEvent>(_onImageLoadFailed);
    on<CacheImageEvent>(_onCacheImage);
    on<CheckCacheEvent>(_onCheckCache);
    on<ImageClickEvent>(_onImageClick);
  }

  void _onInitialize(
    InitializeImageEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    // Check if it's HEIC/HEIF format
    final isHeicHeif =
        event.imageUrl != null &&
        (event.imageUrl!.toLowerCase().endsWith('.heic') ||
            event.imageUrl!.toLowerCase().endsWith('.heif'));

    emit(
      ImageBubbleLoaded(
        imageUrl: event.imageUrl,
        metadata: event.metadata,
        isHeicHeif: isHeicHeif,
      ),
    );

    // Check if image is already cached
    add(CheckCacheEvent());

    // Start loading the image
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      add(LoadImageEvent());
    }
  }

  void _onLoadImage(LoadImageEvent event, Emitter<ImageBubbleBlocState> emit) {
    if (state is ImageBubbleLoaded) {
      final currentState = state as ImageBubbleLoaded;
      emit(currentState.copyWith(isLoading: true, error: null));

      // Actual image loading would be done in the view layer
      // using CachedNetworkImage or similar
      // This event marks the start of loading
    }
  }

  void _onImageLoaded(
    ImageLoadedEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    if (state is ImageBubbleLoaded) {
      final currentState = state as ImageBubbleLoaded;
      emit(
        currentState.copyWith(
          isLoading: false,
          isLoaded: true,
          imageBytes: event.imageBytes,
          decodedImage: event.decodedImage,
        ),
      );
    }
  }

  void _onImageLoadFailed(
    ImageLoadFailedEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    if (state is ImageBubbleLoaded) {
      final currentState = state as ImageBubbleLoaded;
      emit(
        currentState.copyWith(
          isLoading: false,
          isLoaded: false,
          error: event.error,
        ),
      );
    }
  }

  void _onCacheImage(
    CacheImageEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    if (state is ImageBubbleLoaded) {
      final currentState = state as ImageBubbleLoaded;
      emit(currentState.copyWith(isCached: true));
    }
  }

  void _onCheckCache(
    CheckCacheEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    // In real implementation, check if image is in cache
    // This would interact with CometChatCacheManager
    if (state is ImageBubbleLoaded) {
      // final isCached = await checkIfImageIsCached(currentState.imageUrl);
      // emit(currentState.copyWith(isCached: isCached));
    }
  }

  void _onImageClick(
    ImageClickEvent event,
    Emitter<ImageBubbleBlocState> emit,
  ) {
    // Image click handling - would trigger navigation to full screen
    // This event is mainly for tracking/logging purposes
    // The actual navigation is handled by the view
  }
}
