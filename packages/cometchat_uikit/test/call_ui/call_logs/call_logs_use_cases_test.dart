import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/repositories/call_logs_repository.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_logs/domain/usecases/get_call_logs_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCallLogsRepository extends Mock implements CallLogsRepository {}

class FakeCallLog extends Fake implements CallLog {}

class FakeCall extends Fake implements Call {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCallLog());
    registerFallbackValue(FakeCall());
  });

  // =========================================================================
  // GetCallLogsUseCase
  // =========================================================================

  group('GetCallLogsUseCase', () {
    late MockCallLogsRepository repo;
    late GetCallLogsUseCase useCase;

    setUp(() {
      repo = MockCallLogsRepository();
      useCase = GetCallLogsUseCase(repo);
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(limit: 0);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit is negative', () async {
      final result = await useCase(limit: -1);
      expect(result.isFailure, isTrue);
    });

    test('returns failure when limit exceeds 100', () async {
      final result = await useCase(limit: 101);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });

    test('delegates to repository with default limit', () async {
      when(
        () => repo.getCallLogs(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      verify(() => repo.getCallLogs(limit: 30)).called(1);
    });

    test('passes custom limit to repository', () async {
      when(
        () => repo.getCallLogs(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Success([]));

      await useCase(limit: 50);
      verify(() => repo.getCallLogs(limit: 50)).called(1);
    });

    test('accepts limit of exactly 100', () async {
      when(
        () => repo.getCallLogs(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase(limit: 100);
      expect(result.isSuccess, isTrue);
    });

    test('propagates repository failure', () async {
      when(() => repo.getCallLogs(limit: any(named: 'limit'))).thenAnswer(
        (_) async => const Failure(message: 'Fetch failed', code: 'FETCH_ERR'),
      );

      final result = await useCase();
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.message, 'Fetch failed'));
    });
  });
}
