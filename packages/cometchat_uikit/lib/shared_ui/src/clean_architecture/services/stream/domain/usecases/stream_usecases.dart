import '../../../../core/result.dart';
import '../../domain/entities/stream_entity.dart';
import '../../domain/repositories/stream_repository.dart';

/// Use Case for playing a stream
/// Single Responsibility: Handle playing stream logic
class PlayStreamUseCase {
  final StreamRepository repository;

  PlayStreamUseCase({required this.repository});

  /// Execute the use case
  /// Takes URL and stream ID, returns the Stream entity
  Future<Result<StreamEntity>> call({
    required String url,
    required String streamId,
  }) {
    return repository.playStream(url: url, streamId: streamId);
  }
}

/// Use Case for stopping stream
class StopStreamUseCase {
  final StreamRepository repository;

  StopStreamUseCase({required this.repository});

  Future<Result<void>> call({required String streamId}) {
    return repository.stopStream(streamId: streamId);
  }
}

/// Use Case for pausing stream
class PauseStreamUseCase {
  final StreamRepository repository;

  PauseStreamUseCase({required this.repository});

  Future<Result<void>> call({required String streamId}) {
    return repository.pauseStream(streamId: streamId);
  }
}

/// Use Case for resuming stream
class ResumeStreamUseCase {
  final StreamRepository repository;

  ResumeStreamUseCase({required this.repository});

  Future<Result<void>> call({required String streamId}) {
    return repository.resumeStream(streamId: streamId);
  }
}

/// Use Case for getting stream duration
class GetStreamDurationUseCase {
  final StreamRepository repository;

  GetStreamDurationUseCase({required this.repository});

  Future<Result<Duration>> call({required String url}) {
    return repository.getStreamDuration(url: url);
  }
}

/// Use Case for getting current position
class GetStreamCurrentPositionUseCase {
  final StreamRepository repository;

  GetStreamCurrentPositionUseCase({required this.repository});

  Future<Result<Duration>> call({required String streamId}) {
    return repository.getCurrentPosition(streamId: streamId);
  }
}

/// Use Case for seeking to position
class SeekStreamToPositionUseCase {
  final StreamRepository repository;

  SeekStreamToPositionUseCase({required this.repository});

  Future<Result<void>> call({
    required String streamId,
    required Duration position,
  }) {
    return repository.seekToPosition(streamId: streamId, position: position);
  }
}

/// Use Case for getting stream status stream
class GetStreamStatusStreamUseCase {
  final StreamRepository repository;

  GetStreamStatusStreamUseCase({required this.repository});

  Result<Stream<StreamStatusUpdate>> call({required String streamId}) {
    try {
      return Success(repository.getStreamStatusStream(streamId: streamId));
    } catch (e) {
      return Failure(
        message: 'Failed to get status stream: ${e.toString()}',
        code: 'STREAM_STATUS_ERROR',
        exception: e as Exception?,
      );
    }
  }
}
