import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_logs/bloc/call_logs_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/bloc/call_logs_state.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/usecases/get_call_logs_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/usecases/load_more_call_logs_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/usecases/initiate_call_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/repositories/call_logs_repository.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ===========================================================================
// Mocks & Fakes
// ===========================================================================

class MockCallLogsRepository extends Mock implements CallLogsRepository {}

class FakeCallLog extends Fake implements CallLog {
  final String _sessionId;

  FakeCallLog({String sessionId = 'session_1'}) : _sessionId = sessionId;

  @override
  String? get sessionId => _sessionId;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'logged_in_user';

  @override
  String get name => 'Test User';
}

class FakeCall extends Fake implements Call {
  @override
  String get receiverUid => 'user_2';

  @override
  String get receiverType => 'user';

  @override
  String get type => 'audio';
}

// ===========================================================================
// Tests — Interaction: Use Cases + State + Events
// ===========================================================================

void main() {
  late MockCallLogsRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeCall());
  });

  setUp(() {
    repo = MockCallLogsRepository();
  });

  // =========================================================================
  // GetCallLogsUseCase — call initiation interaction
  // =========================================================================

  group('GetCallLogsUseCase interaction', () {
    test('returns call logs on successful fetch', () async {
      final callLogs = [FakeCallLog(), FakeCallLog(sessionId: 'session_2')];
      when(() => repo.getCallLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => Success(callLogs));

      final useCase = GetCallLogsUseCase(repo);
      final result = await useCase(limit: 30);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns empty list when no call logs exist', () async {
      when(() => repo.getCallLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Success(<CallLog>[]));

      final useCase = GetCallLogsUseCase(repo);
      final result = await useCase(limit: 30);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data, isEmpty));
    });

    test('returns failure on network error', () async {
      when(() => repo.getCallLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async =>
              const Failure(message: 'Network error', code: 'NETWORK'));

      final useCase = GetCallLogsUseCase(repo);
      final result = await useCase(limit: 30);

      expect(result.isFailure, isTrue);
    });

    test('validates limit parameter before calling repository', () async {
      final useCase = GetCallLogsUseCase(repo);
      final result = await useCase(limit: 0);

      expect(result.isFailure, isTrue);
      verifyNever(() => repo.getCallLogs(limit: any(named: 'limit')));
    });
  });

  // =========================================================================
  // LoadMoreCallLogsUseCase — pagination interaction
  // =========================================================================

  group('LoadMoreCallLogsUseCase pagination interaction', () {
    test('appends new call logs deduplicating existing', () async {
      final moreLogs = [
        FakeCallLog(sessionId: 'session_3'),
        FakeCallLog(sessionId: 'session_1'), // duplicate
      ];
      when(() => repo.getCallLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => Success(moreLogs));

      final useCase = LoadMoreCallLogsUseCase(repo);
      final currentLogs = [FakeCallLog(sessionId: 'session_1')];
      final result = await useCase(
        limit: 30,
        currentCallLogs: currentLogs,
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) {
        // Should filter out session_1 (duplicate)
        expect(data.length, 1);
        expect(data.first.sessionId, 'session_3');
      });
    });

    test('returns all items when no current logs exist', () async {
      final logs = [FakeCallLog(), FakeCallLog(sessionId: 'session_2')];
      when(() => repo.getCallLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => Success(logs));

      final useCase = LoadMoreCallLogsUseCase(repo);
      final result = await useCase(limit: 30, currentCallLogs: []);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when limit is invalid', () async {
      final useCase = LoadMoreCallLogsUseCase(repo);
      final result = await useCase(limit: -1);

      expect(result.isFailure, isTrue);
      verifyNever(() => repo.getCallLogs(limit: any(named: 'limit')));
    });

    test('returns failure when limit exceeds maximum', () async {
      final useCase = LoadMoreCallLogsUseCase(repo);
      final result = await useCase(limit: 101);

      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });
  });

  // =========================================================================
  // InitiateCallUseCase — call initiation
  // =========================================================================

  group('InitiateCallUseCase interaction', () {
    test('initiates call successfully', () async {
      when(() => repo.initiateCall(any()))
          .thenAnswer((_) async => Success(FakeCall()));

      final useCase = InitiateCallUseCase(repo);
      final result = await useCase(FakeCall());

      expect(result.isSuccess, isTrue);
      verify(() => repo.initiateCall(any())).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => repo.initiateCall(any()))
          .thenAnswer((_) async =>
              const Failure(message: 'User busy', code: 'BUSY'));

      final useCase = InitiateCallUseCase(repo);
      final result = await useCase(FakeCall());

      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.message, 'User busy'));
    });
  });

  // =========================================================================
  // CallLogsState — state transitions for interaction
  // =========================================================================

  group('CallLogsState interaction transitions', () {
    test('loading state from initial', () {
      const initial = CallLogsState();
      final loading = initial.copyWith(status: CallLogsStatus.loading);
      expect(loading.status, CallLogsStatus.loading);
    });

    test('loaded state with call logs', () {
      final logs = [FakeCallLog(), FakeCallLog(sessionId: 's2')];
      final loaded = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        hasMore: true,
        loggedInUser: FakeUser(),
      );
      expect(loaded.callLogs.length, 2);
      expect(loaded.hasMore, isTrue);
      expect(loaded.loggedInUser?.uid, 'logged_in_user');
    });

    test('pagination: isLoadingMore during load more', () {
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
        hasMore: true,
        isLoadingMore: true,
      );
      expect(state.isLoadingMore, isTrue);
      expect(state.hasMore, isTrue);
    });

    test('pagination complete: isLoadingMore false, new items appended', () {
      final logs = [
        FakeCallLog(sessionId: 's1'),
        FakeCallLog(sessionId: 's2'),
        FakeCallLog(sessionId: 's3'),
      ];
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        hasMore: false,
        isLoadingMore: false,
      );
      expect(state.callLogs.length, 3);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isFalse);
    });

    test('error state from loading', () {
      const loading = CallLogsState(status: CallLogsStatus.loading);
      final error = loading.copyWith(
        status: CallLogsStatus.error,
        errorMessage: 'Failed to fetch call logs',
      );
      expect(error.status, CallLogsStatus.error);
      expect(error.errorMessage, 'Failed to fetch call logs');
    });

    test('refresh replaces call logs without loading state', () {
      final oldState = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog(sessionId: 'old')],
      );
      final refreshed = oldState.copyWith(
        callLogs: [FakeCallLog(sessionId: 'new')],
      );
      expect(refreshed.status, CallLogsStatus.loaded);
      expect(refreshed.callLogs.first.sessionId, 'new');
    });
  });

  // =========================================================================
  // CallLogsEvent — event equality and props
  // =========================================================================

  group('CallLogsEvent equality', () {
    test('LoadCallLogs events are equal', () {
      const event1 = LoadCallLogs();
      const event2 = LoadCallLogs();
      expect(event1, equals(event2));
    });

    test('LoadMoreCallLogs events are equal', () {
      const event1 = LoadMoreCallLogs();
      const event2 = LoadMoreCallLogs();
      expect(event1, equals(event2));
    });

    test('RefreshCallLogs events are equal', () {
      const event1 = RefreshCallLogs();
      const event2 = RefreshCallLogs();
      expect(event1, equals(event2));
    });

    test('different event types are not equal', () {
      const load = LoadCallLogs();
      const refresh = RefreshCallLogs();
      const loadMore = LoadMoreCallLogs();
      expect(load, isNot(equals(refresh)));
      expect(load, isNot(equals(loadMore)));
      expect(refresh, isNot(equals(loadMore)));
    });

    test('LoadCallLogs props are empty', () {
      const event = LoadCallLogs();
      expect(event.props, isEmpty);
    });

    test('LoadMoreCallLogs props are empty', () {
      const event = LoadMoreCallLogs();
      expect(event.props, isEmpty);
    });

    test('RefreshCallLogs props are empty', () {
      const event = RefreshCallLogs();
      expect(event.props, isEmpty);
    });
  });

  // =========================================================================
  // hasMore flag logic
  // =========================================================================

  group('hasMore flag logic', () {
    test('hasMore true when result count equals limit (30)', () {
      final logs = List.generate(
          30, (i) => FakeCallLog(sessionId: 'session_$i'));
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        hasMore: true,
      );
      expect(state.hasMore, isTrue);
      expect(state.callLogs.length, 30);
    });

    test('hasMore false when result count less than limit', () {
      final logs = [FakeCallLog()];
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        hasMore: false,
      );
      expect(state.hasMore, isFalse);
    });

    test('hasMore false on empty result', () {
      const state = CallLogsState(
        status: CallLogsStatus.empty,
        hasMore: false,
      );
      expect(state.hasMore, isFalse);
    });
  });
}
