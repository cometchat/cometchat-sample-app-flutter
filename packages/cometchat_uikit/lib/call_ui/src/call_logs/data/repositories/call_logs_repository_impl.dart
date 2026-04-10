import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/call_logs_repository.dart';
import '../datasources/call_logs_remote_datasource.dart';
import '../datasources/call_logs_local_datasource.dart';

/// Implementation of CallLogsRepository.
/// Coordinates between remote and local data sources.
class CallLogsRepositoryImpl implements CallLogsRepository {
  final CallLogsRemoteDataSource remoteDataSource;
  final CallLogsLocalDataSource localDataSource;

  /// The current request for pagination support
  CallLogRequest? _currentRequest;

  CallLogsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Sets the request to use for fetching call logs.
  /// This allows the BLoC to configure pagination parameters.
  void setRequest(CallLogRequest request) {
    _currentRequest = request;
  }

  /// Resets the current request so the next [getCallLogs] call
  /// builds a fresh [CallLogRequest]. Used for retries after SDK
  /// initialization completes.
  void resetRequest() {
    _currentRequest = null;
  }

  @override
  Future<Result<List<CallLog>>> getCallLogs({
    int limit = 30,
  }) async {
    try {
      // Build a new request if none is set
      if (_currentRequest == null) {
        final builder = CallLogRequestBuilder()..limit = limit;
        _currentRequest = builder.build();
      }

      // Fetch from remote data source
      final callLogs = await remoteDataSource.getCallLogs(_currentRequest!);

      // Cache the results locally
      await localDataSource.cacheCallLogs(callLogs);

      return Success(callLogs);
    } on CallLogsRemoteDataSourceException catch (e) {
      // Reset request so retry builds a fresh one (auth token may now be available)
      _currentRequest = null;
      // Remote failed (datasource already tried SDK + REST fallback).
      // Try cached data only if it's non-empty; otherwise propagate error.
      try {
        final cachedCallLogs = await localDataSource.getCachedCallLogs();
        if (cachedCallLogs.isNotEmpty) {
          return Success(cachedCallLogs);
        }
      } on CallLogsLocalDataSourceException {
        // Cache also failed, fall through to Failure
      }
      return Failure(
        message: 'Failed to load call logs: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      // Reset request so retry builds a fresh one (auth token may now be available)
      _currentRequest = null;
      return Failure(
        message: 'Unexpected error while loading call logs: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await remoteDataSource.getLoggedInUser();
      return Success(user);
    } on CallLogsRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to get logged-in user: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting logged-in user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Call>> initiateCall(Call call) async {
    try {
      final returnedCall = await remoteDataSource.initiateCall(call);
      return Success(returnedCall);
    } on CallLogsRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to initiate call: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while initiating call: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<String?>> getUserAuthToken() async {
    try {
      final token = await remoteDataSource.getUserAuthToken();
      return Success(token);
    } on CallLogsRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to get user auth token: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting user auth token: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }
}
