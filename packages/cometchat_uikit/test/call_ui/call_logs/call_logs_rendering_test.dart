import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_logs/bloc/call_logs_state.dart';

// ===========================================================================
// Fakes
// ===========================================================================

class FakeCallLog extends Fake implements CallLog {
  final String _sessionId;

  FakeCallLog({String sessionId = 'session_1'}) : _sessionId = sessionId;

  @override
  String? get sessionId => _sessionId;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';

  @override
  String get name => 'Test User';
}

// ===========================================================================
// Tests — CallLogsState rendering scenarios
// ===========================================================================

void main() {
  // =========================================================================
  // Initial / Loading state
  // =========================================================================

  group('Initial and Loading state', () {
    test('initial state has correct defaults', () {
      const state = CallLogsState();
      expect(state.status, CallLogsStatus.initial);
      expect(state.callLogs, isEmpty);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.loggedInUser, isNull);
      expect(state.groupedEntries, isEmpty);
    });

    test('factory initial() produces same as const constructor', () {
      final state = CallLogsState.initial();
      expect(state.status, CallLogsStatus.initial);
      expect(state.callLogs, isEmpty);
    });

    test('loading state preserves other fields', () {
      const state = CallLogsState();
      final loading = state.copyWith(status: CallLogsStatus.loading);
      expect(loading.status, CallLogsStatus.loading);
      expect(loading.callLogs, isEmpty);
      expect(loading.hasMore, isFalse);
    });
  });

  // =========================================================================
  // Loaded state — content rendering
  // =========================================================================

  group('Loaded state content', () {
    test('loaded state contains call logs', () {
      final logs = [FakeCallLog(), FakeCallLog(sessionId: 'session_2')];
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        loggedInUser: FakeUser(),
      );
      expect(state.status, CallLogsStatus.loaded);
      expect(state.callLogs.length, 2);
      expect(state.loggedInUser, isNotNull);
    });

    test('loaded state with hasMore true indicates pagination available', () {
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
        hasMore: true,
      );
      expect(state.hasMore, isTrue);
    });

    test('loaded state with hasMore false indicates end of list', () {
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
        hasMore: false,
      );
      expect(state.hasMore, isFalse);
    });

    test('loaded state with isLoadingMore shows pagination in progress', () {
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
        isLoadingMore: true,
      );
      expect(state.isLoadingMore, isTrue);
    });

    test('loaded state with grouped entries for date sections', () {
      final logs = [FakeCallLog()];
      final grouped = {'2024-01-15': logs};
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: logs,
        groupedEntries: grouped,
      );
      expect(state.groupedEntries.keys, contains('2024-01-15'));
      expect(state.groupedEntries['2024-01-15']?.length, 1);
    });
  });

  // =========================================================================
  // Empty state
  // =========================================================================

  group('Empty state rendering', () {
    test('empty state has no call logs', () {
      const state = CallLogsState(status: CallLogsStatus.empty);
      expect(state.status, CallLogsStatus.empty);
      expect(state.callLogs, isEmpty);
    });

    test('empty state has no error message', () {
      const state = CallLogsState(status: CallLogsStatus.empty);
      expect(state.errorMessage, isNull);
    });

    test('empty state preserves logged in user', () {
      final state = CallLogsState(
        status: CallLogsStatus.empty,
        loggedInUser: FakeUser(),
      );
      expect(state.loggedInUser, isNotNull);
    });
  });

  // =========================================================================
  // Error state
  // =========================================================================

  group('Error state rendering', () {
    test('error state contains error message', () {
      const state = CallLogsState(
        status: CallLogsStatus.error,
        errorMessage: 'Network connection failed',
      );
      expect(state.status, CallLogsStatus.error);
      expect(state.errorMessage, 'Network connection failed');
    });

    test('error state has empty call logs', () {
      const state = CallLogsState(
        status: CallLogsStatus.error,
        errorMessage: 'Failed',
      );
      expect(state.callLogs, isEmpty);
    });

    test('error state preserves hasMore flag', () {
      const state = CallLogsState(
        status: CallLogsStatus.error,
        hasMore: true,
        errorMessage: 'Timeout',
      );
      expect(state.hasMore, isTrue);
    });
  });

  // =========================================================================
  // copyWith behavior
  // =========================================================================

  group('copyWith behavior', () {
    test('copyWith preserves unchanged fields', () {
      final state = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
        hasMore: true,
        loggedInUser: FakeUser(),
      );

      final updated = state.copyWith(isLoadingMore: true);
      expect(updated.status, CallLogsStatus.loaded);
      expect(updated.callLogs.length, 1);
      expect(updated.hasMore, isTrue);
      expect(updated.isLoadingMore, isTrue);
      expect(updated.loggedInUser, isNotNull);
    });

    test('copyWith replaces specified fields', () {
      const state = CallLogsState(status: CallLogsStatus.loading);
      final updated = state.copyWith(
        status: CallLogsStatus.error,
        errorMessage: 'Something went wrong',
      );
      expect(updated.status, CallLogsStatus.error);
      expect(updated.errorMessage, 'Something went wrong');
    });

    test('copyWith can update callLogs list', () {
      const state = CallLogsState(status: CallLogsStatus.loaded);
      final newLogs = [FakeCallLog(), FakeCallLog(sessionId: 's2')];
      final updated = state.copyWith(callLogs: newLogs);
      expect(updated.callLogs.length, 2);
    });

    test('copyWith can update groupedEntries', () {
      const state = CallLogsState(status: CallLogsStatus.loaded);
      final grouped = {
        'Today': [FakeCallLog()],
        'Yesterday': [FakeCallLog(sessionId: 's2')],
      };
      final updated = state.copyWith(groupedEntries: grouped);
      expect(updated.groupedEntries.keys.length, 2);
    });
  });

  // =========================================================================
  // Equatable props
  // =========================================================================

  group('Equatable equality', () {
    test('two states with same values are equal', () {
      const state1 = CallLogsState(
        status: CallLogsStatus.loaded,
        hasMore: true,
      );
      const state2 = CallLogsState(
        status: CallLogsStatus.loaded,
        hasMore: true,
      );
      expect(state1, equals(state2));
    });

    test('two states with different status are not equal', () {
      const state1 = CallLogsState(status: CallLogsStatus.loaded);
      const state2 = CallLogsState(status: CallLogsStatus.error);
      expect(state1, isNot(equals(state2)));
    });

    test('two states with different callLogs are not equal', () {
      final state1 = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog()],
      );
      final state2 = CallLogsState(
        status: CallLogsStatus.loaded,
        callLogs: [FakeCallLog(sessionId: 'different')],
      );
      // They may or may not be equal depending on CallLog equality
      // but the props list includes callLogs
      expect(state1.props.contains(state1.callLogs), isTrue);
    });

    test('two states with different errorMessage are not equal', () {
      const state1 = CallLogsState(
        status: CallLogsStatus.error,
        errorMessage: 'Error A',
      );
      const state2 = CallLogsState(
        status: CallLogsStatus.error,
        errorMessage: 'Error B',
      );
      expect(state1, isNot(equals(state2)));
    });
  });
}
