import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_operations/data/datasources/call_operations_datasource.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/data/repositories/call_operations_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCallOperationsDataSource extends Mock
    implements CallOperationsDataSource {}

class FakeCall extends Fake implements Call {}

class FakeCustomMessage extends Fake implements CustomMessage {}

class FakeSessionSettings extends Fake implements SessionSettings {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockCallOperationsDataSource dataSource;
  late CallOperationsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeCall());
    registerFallbackValue(FakeCustomMessage());
    registerFallbackValue(FakeSessionSettings());
  });

  setUp(() {
    dataSource = MockCallOperationsDataSource();
    repo = CallOperationsRepositoryImpl(dataSource: dataSource);
  });

  // =========================================================================
  // initiateCall
  // =========================================================================

  group('initiateCall', () {
    test('returns success with call', () async {
      when(
        () => dataSource.initiateCall(any()),
      ).thenAnswer((_) async => FakeCall());

      final result = await repo.initiateCall(FakeCall());
      expect(result.isSuccess, isTrue);
    });

    test(
      'returns failure when datasource throws CallOperationsException',
      () async {
        when(() => dataSource.initiateCall(any())).thenThrow(
          const CallOperationsException(
            message: 'Call failed',
            code: 'CALL_ERR',
          ),
        );

        final result = await repo.initiateCall(FakeCall());
        expect(result.isFailure, isTrue);
        result.onFailure((f) => expect(f.code, 'CALL_ERR'));
      },
    );

    test('returns failure on unexpected error', () async {
      when(
        () => dataSource.initiateCall(any()),
      ).thenThrow(Exception('Unexpected'));

      final result = await repo.initiateCall(FakeCall());
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // acceptCall
  // =========================================================================

  group('acceptCall', () {
    test('returns success with call', () async {
      when(
        () => dataSource.acceptCall(any()),
      ).thenAnswer((_) async => FakeCall());

      final result = await repo.acceptCall('session_1');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.acceptCall(any()),
      ).thenThrow(const CallOperationsException(message: 'Accept failed'));

      final result = await repo.acceptCall('session_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // rejectCall
  // =========================================================================

  group('rejectCall', () {
    test('returns success with call', () async {
      when(
        () => dataSource.rejectCall(any(), any()),
      ).thenAnswer((_) async => FakeCall());

      final result = await repo.rejectCall('session_1', 'rejected');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.rejectCall(any(), any()),
      ).thenThrow(const CallOperationsException(message: 'Reject failed'));

      final result = await repo.rejectCall('session_1', 'rejected');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // endCall
  // =========================================================================

  group('endCall', () {
    test('returns success with call', () async {
      when(() => dataSource.endCall(any())).thenAnswer((_) async => FakeCall());

      final result = await repo.endCall('session_1');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.endCall(any()),
      ).thenThrow(const CallOperationsException(message: 'End failed'));

      final result = await repo.endCall('session_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // generateCallToken
  // =========================================================================

  group('generateCallToken', () {
    test('returns success with token', () async {
      when(
        () => dataSource.generateCallToken(any()),
      ).thenAnswer((_) async => 'token_abc');

      final result = await repo.generateCallToken('session_1');
      expect(result.isSuccess, isTrue);
      result.onSuccess((token) => expect(token, 'token_abc'));
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.generateCallToken(any()),
      ).thenThrow(const CallOperationsException(message: 'Token failed'));

      final result = await repo.generateCallToken('session_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // endSession
  // =========================================================================

  group('endSession', () {
    test('returns success when datasource succeeds', () async {
      when(() => dataSource.endSession()).thenAnswer((_) async {});

      final result = await repo.endSession();
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.endSession(),
      ).thenThrow(const CallOperationsException(message: 'End session failed'));

      final result = await repo.endSession();
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // sendCustomMessage
  // =========================================================================

  group('sendCustomMessage', () {
    test('returns success with message', () async {
      when(
        () => dataSource.sendCustomMessage(any()),
      ).thenAnswer((_) async => FakeCustomMessage());

      final result = await repo.sendCustomMessage(FakeCustomMessage());
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when datasource throws', () async {
      when(
        () => dataSource.sendCustomMessage(any()),
      ).thenThrow(const CallOperationsException(message: 'Send failed'));

      final result = await repo.sendCustomMessage(FakeCustomMessage());
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser / getUserAuthToken
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns success with user', () async {
      when(() => dataSource.getLoggedInUser()).thenAnswer((_) async => null);

      final result = await repo.getLoggedInUser();
      expect(result.isSuccess, isTrue);
    });
  });

  group('getUserAuthToken', () {
    test('returns success with token', () async {
      when(
        () => dataSource.getUserAuthToken(),
      ).thenAnswer((_) async => 'auth_token');

      final result = await repo.getUserAuthToken();
      expect(result.isSuccess, isTrue);
    });
  });
}
