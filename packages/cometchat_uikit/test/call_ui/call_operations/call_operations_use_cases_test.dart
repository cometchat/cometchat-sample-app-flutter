import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_operations/domain/repositories/call_operations_repository.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/domain/usecases/accept_call_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/domain/usecases/reject_call_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/domain/usecases/end_call_usecase.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/domain/usecases/generate_call_token_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCallOperationsRepository extends Mock
    implements CallOperationsRepository {}

class FakeCall extends Fake implements Call {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCall());
  });

  // =========================================================================
  // AcceptCallUseCase
  // =========================================================================

  group('AcceptCallUseCase', () {
    late MockCallOperationsRepository repo;
    late AcceptCallUseCase useCase;

    setUp(() {
      repo = MockCallOperationsRepository();
      useCase = AcceptCallUseCase(repo);
    });

    test('returns failure for empty session ID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'MISSING_SESSION_ID'));
    });

    test('delegates to repository with valid session ID', () async {
      when(
        () => repo.acceptCall(any()),
      ).thenAnswer((_) async => Success(FakeCall()));

      final result = await useCase('session_123');
      expect(result.isSuccess, isTrue);
      verify(() => repo.acceptCall('session_123')).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.acceptCall(any())).thenAnswer(
        (_) async =>
            const Failure(message: 'Accept failed', code: 'ACCEPT_ERR'),
      );

      final result = await useCase('session_123');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // RejectCallUseCase
  // =========================================================================

  group('RejectCallUseCase', () {
    late MockCallOperationsRepository repo;
    late RejectCallUseCase useCase;

    setUp(() {
      repo = MockCallOperationsRepository();
      useCase = RejectCallUseCase(repo);
    });

    test('returns failure for empty session ID', () async {
      final result = await useCase('', 'rejected');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'MISSING_SESSION_ID'));
    });

    test('delegates to repository with valid params', () async {
      when(
        () => repo.rejectCall(any(), any()),
      ).thenAnswer((_) async => Success(FakeCall()));

      final result = await useCase('session_123', 'rejected');
      expect(result.isSuccess, isTrue);
      verify(() => repo.rejectCall('session_123', 'rejected')).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.rejectCall(any(), any())).thenAnswer(
        (_) async =>
            const Failure(message: 'Reject failed', code: 'REJECT_ERR'),
      );

      final result = await useCase('session_123', 'rejected');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // EndCallUseCase
  // =========================================================================

  group('EndCallUseCase', () {
    late MockCallOperationsRepository repo;
    late EndCallUseCase useCase;

    setUp(() {
      repo = MockCallOperationsRepository();
      useCase = EndCallUseCase(repo);
    });

    test('returns failure for empty session ID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'MISSING_SESSION_ID'));
    });

    test('delegates to repository with valid session ID', () async {
      when(
        () => repo.endCall(any()),
      ).thenAnswer((_) async => Success(FakeCall()));

      final result = await useCase('session_123');
      expect(result.isSuccess, isTrue);
      verify(() => repo.endCall('session_123')).called(1);
    });
  });

  // =========================================================================
  // GenerateCallTokenUseCase
  // =========================================================================

  group('GenerateCallTokenUseCase', () {
    late MockCallOperationsRepository repo;
    late GenerateCallTokenUseCase useCase;

    setUp(() {
      repo = MockCallOperationsRepository();
      useCase = GenerateCallTokenUseCase(repo);
    });

    test('returns failure for empty session ID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'MISSING_SESSION_ID'));
    });

    test('delegates to repository with valid session ID', () async {
      when(
        () => repo.generateCallToken(any()),
      ).thenAnswer((_) async => const Success('token_abc'));

      final result = await useCase('session_123');
      expect(result.isSuccess, isTrue);
      result.onSuccess((token) => expect(token, 'token_abc'));
    });

    test('propagates repository failure', () async {
      when(() => repo.generateCallToken(any())).thenAnswer(
        (_) async =>
            const Failure(message: 'Token gen failed', code: 'TOKEN_ERR'),
      );

      final result = await useCase('session_123');
      expect(result.isFailure, isTrue);
    });
  });
}
