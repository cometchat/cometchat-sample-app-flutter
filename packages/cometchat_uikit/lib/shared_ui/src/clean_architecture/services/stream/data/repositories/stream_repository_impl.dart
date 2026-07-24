import '../../../../core/result.dart';
import '../datasources/stream_remote_datasource.dart';
import '../../domain/entities/stream_entity.dart';
import '../../domain/repositories/stream_repository.dart';

/// Repository Implementation - Mediates between Use Cases and Data Sources
/// This is the Data Layer connecting to Domain Layer
///
/// Responsibilities:
/// 1. Delegate calls to appropriate data sources
/// 2. Handle any cross-datasource logic
/// 3. Provide a clean interface to use cases
class StreamRepositoryImpl implements StreamRepository {
  final StreamRemoteDataSource remoteDataSource;

  /// Constructor accepts injected data source
  /// This allows easy testing and switching implementations
  StreamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<StreamEntity>> playStream({
    required String url,
    required String streamId,
  }) async {
    return remoteDataSource.playStream(url: url, streamId: streamId);
  }

  @override
  Future<Result<void>> stopStream({required String streamId}) async {
    return remoteDataSource.stopStream(streamId: streamId);
  }

  @override
  Future<Result<void>> pauseStream({required String streamId}) async {
    return remoteDataSource.pauseStream(streamId: streamId);
  }

  @override
  Future<Result<void>> resumeStream({required String streamId}) async {
    return remoteDataSource.resumeStream(streamId: streamId);
  }

  @override
  Future<Result<Duration>> getStreamDuration({required String url}) async {
    return remoteDataSource.getStreamDuration(url: url);
  }

  @override
  Future<Result<Duration>> getCurrentPosition({
    required String streamId,
  }) async {
    return remoteDataSource.getCurrentPosition(streamId: streamId);
  }

  @override
  Future<Result<void>> seekToPosition({
    required String streamId,
    required Duration position,
  }) async {
    return remoteDataSource.seekToPosition(
      streamId: streamId,
      position: position,
    );
  }

  @override
  Stream<StreamStatusUpdate> getStreamStatusStream({required String streamId}) {
    return remoteDataSource.getStreamStatusStream(streamId: streamId);
  }
}
