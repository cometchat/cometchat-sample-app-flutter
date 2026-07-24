import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/group_members/data/datasources/group_members_remote_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/data/repositories/group_members_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock
    implements GroupMembersRemoteDataSource {}

class FakeGroupMember extends Fake implements GroupMember {
  final String _uid;
  FakeGroupMember([this._uid = 'uid_1']);

  @override
  String get uid => _uid;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'logged_in_user';
}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'group_test_group';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late GroupMembersRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeGroupMember());
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    remote = MockRemoteDataSource();
    repo = GroupMembersRepositoryImpl(remoteDataSource: remote);
  });

  // =========================================================================
  // getGroupMembers
  // =========================================================================

  group('getGroupMembers', () {
    test('returns success with members from remote', () async {
      final members = [FakeGroupMember('uid_1'), FakeGroupMember('uid_2')];
      when(
        () => remote.getGroupMembers(
          guid: any(named: 'guid'),
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
        ),
      ).thenAnswer((_) async => members);

      final result = await repo.getGroupMembers(guid: 'test_group');

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.getGroupMembers(
          guid: any(named: 'guid'),
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
        ),
      ).thenThrow(
        const GroupMembersRemoteDataSourceException(
          message: 'Network error',
          code: 'NET_ERR',
        ),
      );

      final result = await repo.getGroupMembers(guid: 'test_group');

      expect(result.isFailure, isTrue);
    });

    test('passes all params to remote data source', () async {
      when(
        () => remote.getGroupMembers(
          guid: any(named: 'guid'),
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
        ),
      ).thenAnswer((_) async => []);

      await repo.getGroupMembers(
        guid: 'test_group',
        limit: 20,
        searchKeyword: 'alice',
      );

      verify(
        () => remote.getGroupMembers(
          guid: 'test_group',
          limit: 20,
          searchKeyword: 'alice',
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // kickGroupMember
  // =========================================================================

  group('kickGroupMember', () {
    test('returns success when remote succeeds', () async {
      when(
        () => remote.kickGroupMember(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.kickGroupMember(
        guid: 'test_group',
        uid: 'uid_1',
      );
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.kickGroupMember(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
        ),
      ).thenThrow(
        const GroupMembersRemoteDataSourceException(
          message: 'Kick failed',
          code: 'KICK_ERR',
        ),
      );

      final result = await repo.kickGroupMember(
        guid: 'test_group',
        uid: 'uid_1',
      );
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // banGroupMember
  // =========================================================================

  group('banGroupMember', () {
    test('returns success when remote succeeds', () async {
      when(
        () => remote.banGroupMember(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.banGroupMember(
        guid: 'test_group',
        uid: 'uid_1',
      );
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.banGroupMember(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
        ),
      ).thenThrow(
        const GroupMembersRemoteDataSourceException(message: 'Ban failed'),
      );

      final result = await repo.banGroupMember(
        guid: 'test_group',
        uid: 'uid_1',
      );
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // updateMemberScope
  // =========================================================================

  group('updateMemberScope', () {
    test('returns success when remote succeeds', () async {
      when(
        () => remote.updateMemberScope(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
          scope: any(named: 'scope'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.updateMemberScope(
        guid: 'test_group',
        uid: 'uid_1',
        scope: 'admin',
      );
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.updateMemberScope(
          guid: any(named: 'guid'),
          uid: any(named: 'uid'),
          scope: any(named: 'scope'),
        ),
      ).thenThrow(
        const GroupMembersRemoteDataSourceException(
          message: 'Scope update failed',
        ),
      );

      final result = await repo.updateMemberScope(
        guid: 'test_group',
        uid: 'uid_1',
        scope: 'admin',
      );
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns success with user', () async {
      when(() => remote.getLoggedInUser()).thenAnswer((_) async => FakeUser());

      final result = await repo.getLoggedInUser();
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getLoggedInUser()).thenThrow(
        const GroupMembersRemoteDataSourceException(message: 'Not logged in'),
      );

      final result = await repo.getLoggedInUser();
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getConversation
  // =========================================================================

  group('getConversation', () {
    test('returns success with conversation', () async {
      when(
        () => remote.getConversation(any()),
      ).thenAnswer((_) async => FakeConversation());

      final result = await repo.getConversation('test_group');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getConversation(any())).thenThrow(
        const GroupMembersRemoteDataSourceException(
          message: 'Conversation not found',
        ),
      );

      final result = await repo.getConversation('test_group');
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // resetPagination
  // =========================================================================

  group('resetPagination', () {
    test('delegates to remote data source reset', () {
      when(() => remote.reset()).thenReturn(null);

      repo.resetPagination();

      verify(() => remote.reset()).called(1);
    });
  });
}
