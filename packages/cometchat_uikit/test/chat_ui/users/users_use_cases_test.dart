import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/repositories/users_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/usecases/get_users_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/usecases/block_user_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/usecases/unblock_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockUsersRepository extends Mock implements UsersRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  // =========================================================================
  // GetUsersUseCase
  // =========================================================================

  group('GetUsersUseCase', () {
    late MockUsersRepository repo;
    late GetUsersUseCase useCase;

    setUp(() {
      repo = MockUsersRepository();
      useCase = GetUsersUseCase(repo);
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(limit: 0);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit is negative', () async {
      final result = await useCase(limit: -5);
      expect(result.isFailure, isTrue);
    });

    test('returns failure when limit exceeds 100', () async {
      final result = await useCase(limit: 101);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });

    test('delegates to repository with default limit', () async {
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      verify(() => repo.getUsers(limit: 30)).called(1);
    });

    test('passes custom limit to repository', () async {
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await useCase(limit: 50);
      verify(() => repo.getUsers(limit: 50)).called(1);
    });

    test('passes searchKeyword to repository', () async {
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await useCase(searchKeyword: 'john');
      verify(() => repo.getUsers(limit: 30, searchKeyword: 'john')).called(1);
    });

    test('accepts limit of exactly 100', () async {
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase(limit: 100);
      expect(result.isSuccess, isTrue);
    });

    test('propagates repository failure', () async {
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(message: 'Network error', code: 'NET_ERR'),
      );

      final result = await useCase();
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.message, 'Network error'));
    });
  });

  // =========================================================================
  // BlockUserUseCase
  // =========================================================================

  group('BlockUserUseCase', () {
    late MockUsersRepository repo;
    late BlockUserUseCase useCase;

    setUp(() {
      repo = MockUsersRepository();
      useCase = BlockUserUseCase(repo);
    });

    test('returns failure for empty UID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('delegates to repository with valid UID', () async {
      when(
        () => repo.blockUser(any()),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase('uid123');
      expect(result.isSuccess, isTrue);
      verify(() => repo.blockUser('uid123')).called(1);
    });

    test('does not call repository for empty UID', () async {
      await useCase('');
      verifyNever(() => repo.blockUser(any()));
    });

    test('propagates repository failure', () async {
      when(() => repo.blockUser(any())).thenAnswer(
        (_) async => const Failure(message: 'Block failed', code: 'BLOCK_ERR'),
      );

      final result = await useCase('uid123');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // UnblockUserUseCase
  // =========================================================================

  group('UnblockUserUseCase', () {
    late MockUsersRepository repo;
    late UnblockUserUseCase useCase;

    setUp(() {
      repo = MockUsersRepository();
      useCase = UnblockUserUseCase(repo);
    });

    test('returns failure for empty UID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('delegates to repository with valid UID', () async {
      when(
        () => repo.unblockUser(any()),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase('uid123');
      expect(result.isSuccess, isTrue);
      verify(() => repo.unblockUser('uid123')).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.unblockUser(any())).thenAnswer(
        (_) async =>
            const Failure(message: 'Unblock failed', code: 'UNBLOCK_ERR'),
      );

      final result = await useCase('uid123');
      expect(result.isFailure, isTrue);
    });
  });
}
