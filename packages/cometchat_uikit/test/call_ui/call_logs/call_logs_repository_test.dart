import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_logs/data/datasources/call_logs_remote_datasource.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/data/datasources/call_logs_local_datasource.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/data/repositories/call_logs_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock implements CallLogsRemoteDataSource {}

class MockLocalDataSource extends Mock implements CallLogsLocalDataSource {}

class FakeCallLog extends Fake implements CallLog {
  @override
  String? get sessionId => 'session_1';
}

class FakeCallLogRequest extends Fake implements CallLogRequest {}

class FakeCall extends Fake implements Call {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late CallLogsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeCallLog());
    registerFallbackValue(FakeCallLogRequest());
    registerFallbackValue(FakeCall());
    registerFallbackValue(<CallLog>[]);
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repo = CallLogsRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
  });

  // =========================================================================
  // getCallLogs
  // =========================================================================

  group('getCallLogs', () {
    test('returns success with call logs from remote', () async {
      final callLogs = [FakeCallLog(), FakeCallLog()];
      when(() => remote.getCallLogs(any())).thenAnswer((_) async => callLogs);
      when(() => local.cacheCallLogs(any())).thenAnswer((_) async {});

      final result = await repo.getCallLogs();

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('caches call logs after successful remote fetch', () async {
      final callLogs = [FakeCallLog()];
      when(() => remote.getCallLogs(any())).thenAnswer((_) async => callLogs);
      when(() => local.cacheCallLogs(any())).thenAnswer((_) async {});

      await repo.getCallLogs();

      verify(() => local.cacheCallLogs(callLogs)).called(1);
    });

    test('falls back to cache when remote fails', () async {
      final cached = [FakeCallLog()];
      when(() => remote.getCallLogs(any())).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Network error'),
      );
      when(() => local.getCachedCallLogs()).thenAnswer((_) async => cached);

      final result = await repo.getCallLogs();

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when both remote and cache fail', () async {
      when(() => remote.getCallLogs(any())).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Network error'),
      );
      when(() => local.getCachedCallLogs()).thenThrow(
        const CallLogsLocalDataSourceException(message: 'Cache miss'),
      );

      final result = await repo.getCallLogs();

      expect(result.isFailure, isTrue);
    });

    test('returns failure when remote fails and cache is empty', () async {
      when(() => remote.getCallLogs(any())).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Network error'),
      );
      when(() => local.getCachedCallLogs()).thenAnswer((_) async => []);

      final result = await repo.getCallLogs();

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns success with user', () async {
      when(() => remote.getLoggedInUser()).thenAnswer((_) async => FakeUser());

      final result = await repo.getLoggedInUser();
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getLoggedInUser()).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Not logged in'),
      );

      final result = await repo.getLoggedInUser();
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // initiateCall
  // =========================================================================

  group('initiateCall', () {
    test('returns success with call', () async {
      when(
        () => remote.initiateCall(any()),
      ).thenAnswer((_) async => FakeCall());

      final result = await repo.initiateCall(FakeCall());
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.initiateCall(any())).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Call failed'),
      );

      final result = await repo.initiateCall(FakeCall());
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getUserAuthToken
  // =========================================================================

  group('getUserAuthToken', () {
    test('returns success with token', () async {
      when(
        () => remote.getUserAuthToken(),
      ).thenAnswer((_) async => 'auth_token_123');

      final result = await repo.getUserAuthToken();
      expect(result.isSuccess, isTrue);
      result.onSuccess((token) => expect(token, 'auth_token_123'));
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getUserAuthToken()).thenThrow(
        const CallLogsRemoteDataSourceException(message: 'Token failed'),
      );

      final result = await repo.getUserAuthToken();
      expect(result.isFailure, isTrue);
    });
  });
}
