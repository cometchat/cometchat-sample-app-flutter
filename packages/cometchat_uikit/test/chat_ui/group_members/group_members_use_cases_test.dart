import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/repositories/group_members_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/get_group_members_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/kick_group_member_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/ban_group_member_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/update_member_scope_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupMembersRepository extends Mock
    implements GroupMembersRepository {}

class FakeGroupMember extends Fake implements GroupMember {
  @override
  String get uid => 'member_1';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGroupMember());
  });

  // =========================================================================
  // GetGroupMembersUseCase
  // =========================================================================

  group('GetGroupMembersUseCase', () {
    late MockGroupMembersRepository repo;
    late GetGroupMembersUseCase useCase;

    setUp(() {
      repo = MockGroupMembersRepository();
      useCase = GetGroupMembersUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(guid: 'g1', limit: 0);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('delegates to repository with valid params', () async {
      when(() => repo.getGroupMembers(
            guid: any(named: 'guid'),
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
          )).thenAnswer((_) async => const Success([]));

      final result = await useCase(guid: 'g1');
      expect(result.isSuccess, isTrue);
      verify(() => repo.getGroupMembers(guid: 'g1', limit: 30)).called(1);
    });

    test('passes searchKeyword to repository', () async {
      when(() => repo.getGroupMembers(
            guid: any(named: 'guid'),
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
          )).thenAnswer((_) async => const Success([]));

      await useCase(guid: 'g1', searchKeyword: 'john');
      verify(() => repo.getGroupMembers(
            guid: 'g1',
            limit: 30,
            searchKeyword: 'john',
          )).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.getGroupMembers(
            guid: any(named: 'guid'),
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
          )).thenAnswer((_) async =>
              const Failure(message: 'Fetch failed', code: 'FETCH_ERR'));

      final result = await useCase(guid: 'g1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // KickGroupMemberUseCase
  // =========================================================================

  group('KickGroupMemberUseCase', () {
    late MockGroupMembersRepository repo;
    late KickGroupMemberUseCase useCase;

    setUp(() {
      repo = MockGroupMembersRepository();
      useCase = KickGroupMemberUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '', uid: 'uid_1');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('returns failure for empty uid', () async {
      final result = await useCase(guid: 'g1', uid: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('delegates to repository with valid params', () async {
      when(() => repo.kickGroupMember(
            guid: any(named: 'guid'),
            uid: any(named: 'uid'),
          )).thenAnswer((_) async => const Success(null));

      final result = await useCase(guid: 'g1', uid: 'uid_1');
      expect(result.isSuccess, isTrue);
      verify(() => repo.kickGroupMember(guid: 'g1', uid: 'uid_1')).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.kickGroupMember(
            guid: any(named: 'guid'),
            uid: any(named: 'uid'),
          )).thenAnswer((_) async =>
              const Failure(message: 'Kick failed', code: 'KICK_ERR'));

      final result = await useCase(guid: 'g1', uid: 'uid_1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // BanGroupMemberUseCase
  // =========================================================================

  group('BanGroupMemberUseCase', () {
    late MockGroupMembersRepository repo;
    late BanGroupMemberUseCase useCase;

    setUp(() {
      repo = MockGroupMembersRepository();
      useCase = BanGroupMemberUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '', uid: 'uid_1');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('returns failure for empty uid', () async {
      final result = await useCase(guid: 'g1', uid: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('delegates to repository with valid params', () async {
      when(() => repo.banGroupMember(
            guid: any(named: 'guid'),
            uid: any(named: 'uid'),
          )).thenAnswer((_) async => const Success(null));

      final result = await useCase(guid: 'g1', uid: 'uid_1');
      expect(result.isSuccess, isTrue);
    });
  });

  // =========================================================================
  // UpdateMemberScopeUseCase
  // =========================================================================

  group('UpdateMemberScopeUseCase', () {
    late MockGroupMembersRepository repo;
    late UpdateMemberScopeUseCase useCase;

    setUp(() {
      repo = MockGroupMembersRepository();
      useCase = UpdateMemberScopeUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '', uid: 'uid_1', scope: 'admin');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('returns failure for empty uid', () async {
      final result = await useCase(guid: 'g1', uid: '', scope: 'admin');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_UID'));
    });

    test('returns failure for empty scope', () async {
      final result = await useCase(guid: 'g1', uid: 'uid_1', scope: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_SCOPE'));
    });

    test('delegates to repository with valid params', () async {
      when(() => repo.updateMemberScope(
            guid: any(named: 'guid'),
            uid: any(named: 'uid'),
            scope: any(named: 'scope'),
          )).thenAnswer((_) async => const Success(null));

      final result = await useCase(guid: 'g1', uid: 'uid_1', scope: 'admin');
      expect(result.isSuccess, isTrue);
      verify(() => repo.updateMemberScope(
            guid: 'g1',
            uid: 'uid_1',
            scope: 'admin',
          )).called(1);
    });
  });
}
