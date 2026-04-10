import '../../../../core/result.dart';
import '../entities/stream_entity.dart';

/// Abstract repository for Stream operations
/// Defines the contract that data layer must implement
/// NO DEPENDENCIES on external packages or implementation details
///
/// CURRENT CAPABILITIES:
/// - playStream() - Start playing a stream
/// - stopStream() - Stop stream playback
/// - pauseStream() - Pause stream playback
/// - resumeStream() - Resume paused stream
/// - getStreamDuration() - Get total stream duration
/// - getCurrentPosition() - Get current playback position
/// - seekToPosition() - Seek to specific position
/// - getStreamStatusStream() - Get status updates as stream
abstract class StreamRepository {
  /// Play a stream from URL
  /// Returns the Stream entity when play starts
  Future<Result<StreamEntity>> playStream({
    required String url,
    required String streamId,
  });

  /// Stop current playing stream
  Future<Result<void>> stopStream({
    required String streamId,
  });

  /// Pause current playing stream
  Future<Result<void>> pauseStream({
    required String streamId,
  });

  /// Resume paused stream
  Future<Result<void>> resumeStream({
    required String streamId,
  });

  /// Get stream duration
  Future<Result<Duration>> getStreamDuration({
    required String url,
  });

  /// Get current playback position
  Future<Result<Duration>> getCurrentPosition({
    required String streamId,
  });

  /// Seek to position in stream
  Future<Result<void>> seekToPosition({
    required String streamId,
    required Duration position,
  });

  /// Stream of stream playback status changes
  /// Emits status updates as stream plays
  Stream<StreamStatusUpdate> getStreamStatusStream({
    required String streamId,
  });
}