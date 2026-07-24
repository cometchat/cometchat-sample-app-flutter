import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_header/domain/repositories/message_header_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_header/domain/usecases/get_user_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_header/domain/usecases/get_group_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_header/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageHeaderRepository extends Mock
    implements MessageHeaderRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
  @override
  String get name => 'Test User';
}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_guid';
  @override
  String get name => 'Test Group';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeGroup());
  });

  // =========================================================================
  // GetUserUseCase
  // =========================================================================

  group('GetUserUseCase', () {
    late MockMessageHeaderRepository repo;
    late GetUserUseCase useCase;

    setUp(() {
      repo = MockMessageHeaderRepository();
      useCase = GetUserUseCase(repo);
    });

    test('returns failure for empty UID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('delegates to repository with valid UID', () async {
      when(
        () => repo.getUser(any()),
      ).thenAnswer((_) async => Success(FakeUser()));

      final result = await useCase('uid_1');
      expect(result.isSuccess, isTrue);
      verify(() => repo.getUser('uid_1')).called(1);
    });

    test('does not call repository for empty UID', () async {
      await useCase('');
      verifyNever(() => repo.getUser(any()));
    });

    test('propagates repository failure', () async {
      when(() => repo.getUser(any())).thenAnswer(
        (_) async =>
            const Failure(message: 'User not found', code: 'NOT_FOUND'),
      );

      final result = await useCase('uid_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // GetGroupUseCase
  // =========================================================================

  group('GetGroupUseCase', () {
    late MockMessageHeaderRepository repo;
    late GetGroupUseCase useCase;

    setUp(() {
      repo = MockMessageHeaderRepository();
      useCase = GetGroupUseCase(repo);
    });

    test('returns failure for empty GUID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('delegates to repository with valid GUID', () async {
      when(
        () => repo.getGroup(any()),
      ).thenAnswer((_) async => Success(FakeGroup()));

      final result = await useCase('guid_1');
      expect(result.isSuccess, isTrue);
      verify(() => repo.getGroup('guid_1')).called(1);
    });

    test('does not call repository for empty GUID', () async {
      await useCase('');
      verifyNever(() => repo.getGroup(any()));
    });

    test('propagates repository failure', () async {
      when(() => repo.getGroup(any())).thenAnswer(
        (_) async =>
            const Failure(message: 'Group not found', code: 'NOT_FOUND'),
      );

      final result = await useCase('guid_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // GetMessageHeaderLoggedInUserUseCase
  // =========================================================================

  group('GetMessageHeaderLoggedInUserUseCase', () {
    late MockMessageHeaderRepository repo;
    late GetMessageHeaderLoggedInUserUseCase useCase;

    setUp(() {
      repo = MockMessageHeaderRepository();
      useCase = GetMessageHeaderLoggedInUserUseCase(repo);
    });

    test('delegates to repository', () async {
      when(
        () => repo.getLoggedInUser(),
      ).thenAnswer((_) async => Success(FakeUser()));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      verify(() => repo.getLoggedInUser()).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.getLoggedInUser()).thenAnswer(
        (_) async => const Failure(message: 'Not logged in', code: 'AUTH_ERR'),
      );

      final result = await useCase();
      expect(result.isFailure, isTrue);
    });
  });
}
