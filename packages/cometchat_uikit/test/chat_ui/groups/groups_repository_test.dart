import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/groups/data/datasources/groups_remote_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/data/repositories/groups_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock implements GroupsRemoteDataSource {}

class FakeGroup extends Fake implements Group {
  final String _guid;
  FakeGroup([this._guid = 'guid_1']);

  @override
  String get guid => _guid;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late GroupsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeGroup());
  });

  setUp(() {
    remote = MockRemoteDataSource();
    repo = GroupsRepositoryImpl(remoteDataSource: remote);
  });

  // =========================================================================
  // getGroups
  // =========================================================================

  group('getGroups', () {
    test('returns success with groups from remote', () async {
      final groups = [FakeGroup('g1'), FakeGroup('g2')];
      when(() => remote.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => groups);

      final result = await repo.getGroups();

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenThrow(const GroupsRemoteDataSourceException(
        message: 'Network error',
        code: 'NET_ERR',
      ));

      final result = await repo.getGroups();

      expect(result.isFailure, isTrue);
    });

    test('passes all params to remote data source', () async {
      when(() => remote.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => []);

      await repo.getGroups(limit: 20, searchKeyword: 'dev', joinedOnly: true);

      verify(() => remote.getGroups(
            limit: 20,
            searchKeyword: 'dev',
            joinedOnly: true,
          )).called(1);
    });
  });

  // =========================================================================
  // joinGroup
  // =========================================================================

  group('joinGroup', () {
    test('returns success with joined group', () async {
      final group = FakeGroup('g1');
      when(() => remote.joinGroup(
            guid: any(named: 'guid'),
            groupType: any(named: 'groupType'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => group);

      final result = await repo.joinGroup(guid: 'g1', groupType: 'public');

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.joinGroup(
            guid: any(named: 'guid'),
            groupType: any(named: 'groupType'),
            password: any(named: 'password'),
          )).thenThrow(const GroupsRemoteDataSourceException(
        message: 'Join failed',
        code: 'JOIN_ERR',
      ));

      final result = await repo.joinGroup(guid: 'g1', groupType: 'public');

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // leaveGroup
  // =========================================================================

  group('leaveGroup', () {
    test('returns success when remote succeeds', () async {
      when(() => remote.leaveGroup(any())).thenAnswer((_) async {});

      final result = await repo.leaveGroup('g1');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.leaveGroup(any())).thenThrow(
          const GroupsRemoteDataSourceException(message: 'Leave failed'));

      final result = await repo.leaveGroup('g1');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns success with user', () async {
      when(() => remote.getLoggedInUser()).thenAnswer((_) async => null);

      final result = await repo.getLoggedInUser();
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getLoggedInUser()).thenThrow(
          const GroupsRemoteDataSourceException(message: 'Not logged in'));

      final result = await repo.getLoggedInUser();
      expect(result.isFailure, isTrue);
    });
  });
}
