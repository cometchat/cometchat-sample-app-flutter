import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../../../../core/result.dart';
import '../../domain/entities/stream_entity.dart';

/// Remote Data Source - Wraps video_player for audio/video streaming
/// This bridges the new clean architecture with native streaming capabilities
abstract class StreamRemoteDataSource {
  /// Play stream from URL
  Future<Result<StreamEntity>> playStream({
    required String url,
    required String streamId,
  });

  /// Stop stream
  Future<Result<void>> stopStream({
    required String streamId,
  });

  /// Pause stream
  Future<Result<void>> pauseStream({
    required String streamId,
  });

  /// Resume stream
  Future<Result<void>> resumeStream({
    required String streamId,
  });

  /// Get stream duration
  Future<Result<Duration>> getStreamDuration({
    required String url,
  });

  /// Get current position
  Future<Result<Duration>> getCurrentPosition({
    required String streamId,
  });

  /// Seek to position
  Future<Result<void>> seekToPosition({
    required String streamId,
    required Duration position,
  });

  /// Get status stream
  Stream<StreamStatusUpdate> getStreamStatusStream({
    required String streamId,
  });
}

/// Implementation using video_player (works for both audio and video)
/// Manages multiple concurrent streams with VideoPlayerController
class StreamRemoteDataSourceImpl implements StreamRemoteDataSource {
  /// Map of stream ID to controller
  final Map<String, VideoPlayerController> _controllers = {};
  
  /// Map of stream ID to status stream controller
  final Map<String, StreamController<StreamStatusUpdate>> _statusControllers = {};
  
  /// Map of stream ID to position update timer
  final Map<String, Timer> _positionTimers = {};

  /// Constructor for dependency injection
  StreamRemoteDataSourceImpl();

  @override
  Future<Result<StreamEntity>> playStream({
    required String url,
    required String streamId,
  }) async {
    try {
      // Stop existing stream if any
      await _disposeStream(streamId);

      // Create appropriate controller based on URL type
      VideoPlayerController controller;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else if (url.startsWith('file://')) {
        final filePath = url.replaceFirst('file://', '');
        controller = VideoPlayerController.file(
          File(filePath),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        // Assume local file path
        controller = VideoPlayerController.file(
          File(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      // Initialize the controller
      await controller.initialize();
      
      // Store controller
      _controllers[streamId] = controller;
      
      // Create status stream controller
      final statusController = StreamController<StreamStatusUpdate>.broadcast();
      _statusControllers[streamId] = statusController;

      // Set up listener for state changes
      controller.addListener(() {
        _onControllerUpdate(streamId, controller, statusController);
      });

      // Start playback
      await controller.play();

      // Start position update timer
      _startPositionTimer(streamId, controller, statusController);

      final stream = StreamEntity(
        id: streamId,
        name: url.split('/').last,
        url: url,
        isPlaying: true,
        duration: controller.value.duration,
        position: Duration.zero,
        createdAt: DateTime.now(),
      );

      // Emit initial status
      statusController.add(StreamStatusUpdate(
        status: StreamPlaybackStatus.playing,
        position: Duration.zero,
        duration: controller.value.duration,
        bufferedPosition: controller.value.buffered.isNotEmpty
            ? controller.value.buffered.last.end
            : Duration.zero,
      ));

      return Success(stream);
    } catch (e) {
      return Failure(
        message: 'Failed to play stream: ${e.toString()}',
        code: 'STREAM_PLAY_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<void>> stopStream({required String streamId}) async {
    try {
      final controller = _controllers[streamId];
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        await controller.seekTo(Duration.zero);
        
        // Emit stopped status
        _statusControllers[streamId]?.add(StreamStatusUpdate(
          status: StreamPlaybackStatus.stopped,
          position: Duration.zero,
          duration: controller.value.duration,
          bufferedPosition: Duration.zero,
        ));
      }
      
      // Clean up resources
      await _disposeStream(streamId);
      
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to stop stream: ${e.toString()}',
        code: 'STREAM_STOP_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<void>> pauseStream({required String streamId}) async {
    try {
      final controller = _controllers[streamId];
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        
        // Emit paused status
        _statusControllers[streamId]?.add(StreamStatusUpdate(
          status: StreamPlaybackStatus.paused,
          position: controller.value.position,
          duration: controller.value.duration,
          bufferedPosition: controller.value.buffered.isNotEmpty
              ? controller.value.buffered.last.end
              : Duration.zero,
        ));
      }
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to pause stream: ${e.toString()}',
        code: 'STREAM_PAUSE_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<void>> resumeStream({required String streamId}) async {
    try {
      final controller = _controllers[streamId];
      if (controller != null && controller.value.isInitialized) {
        await controller.play();
        
        // Restart position timer
        _startPositionTimer(streamId, controller, _statusControllers[streamId]!);
        
        // Emit playing status
        _statusControllers[streamId]?.add(StreamStatusUpdate(
          status: StreamPlaybackStatus.playing,
          position: controller.value.position,
          duration: controller.value.duration,
          bufferedPosition: controller.value.buffered.isNotEmpty
              ? controller.value.buffered.last.end
              : Duration.zero,
        ));
      }
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to resume stream: ${e.toString()}',
        code: 'STREAM_RESUME_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<Duration>> getStreamDuration({required String url}) async {
    try {
      // Create temporary controller to get duration
      VideoPlayerController tempController;
      
      if (url.startsWith('http://') || url.startsWith('https://')) {
        tempController = VideoPlayerController.networkUrl(Uri.parse(url));
      } else if (url.startsWith('file://')) {
        final filePath = url.replaceFirst('file://', '');
        tempController = VideoPlayerController.file(File(filePath));
      } else {
        tempController = VideoPlayerController.file(File(url));
      }

      await tempController.initialize();
      final duration = tempController.value.duration;
      await tempController.dispose();

      return Success(duration);
    } catch (e) {
      return Failure(
        message: 'Failed to get duration: ${e.toString()}',
        code: 'STREAM_DURATION_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<Duration>> getCurrentPosition({required String streamId}) async {
    try {
      final controller = _controllers[streamId];
      if (controller != null && controller.value.isInitialized) {
        return Success(controller.value.position);
      }
      return const Success(Duration.zero);
    } catch (e) {
      return Failure(
        message: 'Failed to get current position: ${e.toString()}',
        code: 'STREAM_POSITION_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Future<Result<void>> seekToPosition({
    required String streamId,
    required Duration position,
  }) async {
    try {
      final controller = _controllers[streamId];
      if (controller != null && controller.value.isInitialized) {
        await controller.seekTo(position);
        
        // Emit updated position
        _statusControllers[streamId]?.add(StreamStatusUpdate(
          status: controller.value.isPlaying 
              ? StreamPlaybackStatus.playing 
              : StreamPlaybackStatus.paused,
          position: position,
          duration: controller.value.duration,
          bufferedPosition: controller.value.buffered.isNotEmpty
              ? controller.value.buffered.last.end
              : Duration.zero,
        ));
      }
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to seek: ${e.toString()}',
        code: 'STREAM_SEEK_ERROR',
        exception: e as Exception?,
      );
    }
  }

  @override
  Stream<StreamStatusUpdate> getStreamStatusStream({
    required String streamId,
  }) {
    try {
      // Create status controller if it doesn't exist
      if (!_statusControllers.containsKey(streamId)) {
        _statusControllers[streamId] = StreamController<StreamStatusUpdate>.broadcast();
      }
      return _statusControllers[streamId]!.stream;
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Internal: Handle controller updates
  void _onControllerUpdate(
    String streamId,
    VideoPlayerController controller,
    StreamController<StreamStatusUpdate> statusController,
  ) {
    if (controller.value.hasError) {
      statusController.add(StreamStatusUpdate(
        status: StreamPlaybackStatus.error,
        position: controller.value.position,
        duration: controller.value.duration,
        bufferedPosition: Duration.zero,
        errorMessage: controller.value.errorDescription,
      ));
      return;
    }

    // Check if playback completed
    if (controller.value.position >= controller.value.duration &&
        controller.value.duration > Duration.zero) {
      statusController.add(StreamStatusUpdate(
        status: StreamPlaybackStatus.completed,
        position: controller.value.duration,
        duration: controller.value.duration,
        bufferedPosition: controller.value.duration,
      ));
    }
  }

  /// Internal: Start position update timer
  void _startPositionTimer(
    String streamId,
    VideoPlayerController controller,
    StreamController<StreamStatusUpdate> statusController,
  ) {
    // Cancel existing timer
    _positionTimers[streamId]?.cancel();

    // Create new timer for position updates (every 100ms)
    _positionTimers[streamId] = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        statusController.add(StreamStatusUpdate(
          status: StreamPlaybackStatus.playing,
          position: controller.value.position,
          duration: controller.value.duration,
          bufferedPosition: controller.value.buffered.isNotEmpty
              ? controller.value.buffered.last.end
              : Duration.zero,
        ));
      }
    });
  }

  /// Internal: Dispose stream resources
  Future<void> _disposeStream(String streamId) async {
    // Cancel position timer
    _positionTimers[streamId]?.cancel();
    _positionTimers.remove(streamId);

    // Close status controller
    await _statusControllers[streamId]?.close();
    _statusControllers.remove(streamId);

    // Dispose video controller
    await _controllers[streamId]?.dispose();
    _controllers.remove(streamId);
  }

  /// Dispose all resources
  Future<void> dispose() async {
    final streamIds = _controllers.keys.toList();
    for (final streamId in streamIds) {
      await _disposeStream(streamId);
    }
  }
}
