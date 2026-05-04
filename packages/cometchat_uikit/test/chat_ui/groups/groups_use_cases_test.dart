import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/repositories/groups_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/get_groups_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/join_group_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/leave_group_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupsRepository extends Mock implements GroupsRepository {}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_guid';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGroup());
  });

  // =========================================================================
  // GetGroupsUseCase
  // =========================================================================

  group('GetGroupsUseCase', () {
    late MockGroupsRepository repo;
    late GetGroupsUseCase useCase;

    setUp(() {
      repo = MockGroupsRepository();
      useCase = GetGroupsUseCase(repo);
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
      when(() => repo.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => const Success([]));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      verify(() => repo.getGroups(limit: 30)).called(1);
    });

    test('passes searchKeyword to repository', () async {
      when(() => repo.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => const Success([]));

      await useCase(searchKeyword: 'dev');
      verify(() => repo.getGroups(limit: 30, searchKeyword: 'dev')).called(1);
    });

    test('accepts limit of exactly 100', () async {
      when(() => repo.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => const Success([]));

      final result = await useCase(limit: 100);
      expect(result.isSuccess, isTrue);
    });

    test('propagates repository failure', () async {
      when(() => repo.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer(
              (_) async => const Failure(message: 'Network error', code: 'NET_ERR'));

      final result = await useCase();
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // JoinGroupUseCase
  // =========================================================================

  group('JoinGroupUseCase', () {
    late MockGroupsRepository repo;
    late JoinGroupUseCase useCase;

    setUp(() {
      repo = MockGroupsRepository();
      useCase = JoinGroupUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '', groupType: 'public');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('returns failure for empty groupType', () async {
      final result = await useCase(guid: 'guid_1', groupType: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GROUP_TYPE'));
    });

    test('returns failure for invalid groupType', () async {
      final result = await useCase(guid: 'guid_1', groupType: 'channel');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GROUP_TYPE'));
    });

    test('returns failure when password group has no password', () async {
      final result = await useCase(guid: 'guid_1', groupType: 'password');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'PASSWORD_REQUIRED'));
    });

    test('delegates to repository for valid public group', () async {
      when(() => repo.joinGroup(
            guid: any(named: 'guid'),
            groupType: any(named: 'groupType'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Success(FakeGroup()));

      final result = await useCase(guid: 'guid_1', groupType: 'public');
      expect(result.isSuccess, isTrue);
    });

    test('delegates to repository for valid password group', () async {
      when(() => repo.joinGroup(
            guid: any(named: 'guid'),
            groupType: any(named: 'groupType'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Success(FakeGroup()));

      final result = await useCase(
        guid: 'guid_1',
        groupType: 'password',
        password: 'secret',
      );
      expect(result.isSuccess, isTrue);
      verify(() => repo.joinGroup(
            guid: 'guid_1',
            groupType: 'password',
            password: 'secret',
          )).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.joinGroup(
            guid: any(named: 'guid'),
            groupType: any(named: 'groupType'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Failure(message: 'Join failed', code: 'JOIN_ERR'));

      final result = await useCase(guid: 'guid_1', groupType: 'public');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // LeaveGroupUseCase
  // =========================================================================

  group('LeaveGroupUseCase', () {
    late MockGroupsRepository repo;
    late LeaveGroupUseCase useCase;

    setUp(() {
      repo = MockGroupsRepository();
      useCase = LeaveGroupUseCase(repo);
    });

    test('returns failure for empty guid', () async {
      final result = await useCase(guid: '');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_GUID'));
    });

    test('delegates to repository with valid guid', () async {
      when(() => repo.leaveGroup(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(guid: 'guid_1');
      expect(result.isSuccess, isTrue);
      verify(() => repo.leaveGroup('guid_1')).called(1);
    });

    test('does not call repository for empty guid', () async {
      await useCase(guid: '');
      verifyNever(() => repo.leaveGroup(any()));
    });

    test('propagates repository failure', () async {
      when(() => repo.leaveGroup(any()))
          .thenAnswer((_) async =>
              const Failure(message: 'Leave failed', code: 'LEAVE_ERR'));

      final result = await useCase(guid: 'guid_1');
      expect(result.isFailure, isTrue);
    });
  });
}
