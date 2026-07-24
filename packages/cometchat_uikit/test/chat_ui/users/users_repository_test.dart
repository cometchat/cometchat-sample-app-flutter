import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/users/data/datasources/users_remote_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/data/datasources/users_local_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/data/repositories/users_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock implements UsersRemoteDataSource {}

class MockLocalDataSource extends Mock implements UsersLocalDataSource {}

class FakeUser extends Fake implements User {
  final String _uid;
  FakeUser([this._uid = 'uid_1']);

  @override
  String get uid => _uid;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late UsersRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(<User>[]);
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repo = UsersRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
  });

  // =========================================================================
  // getUsers
  // =========================================================================

  group('getUsers', () {
    test('returns success with users from remote', () async {
      final users = [FakeUser('uid_1'), FakeUser('uid_2')];
      when(
        () => remote.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => users);
      when(() => local.cacheUsers(any())).thenAnswer((_) async {});

      final result = await repo.getUsers();

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('caches users after successful remote fetch', () async {
      final users = [FakeUser('uid_1')];
      when(
        () => remote.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => users);
      when(() => local.cacheUsers(any())).thenAnswer((_) async {});

      await repo.getUsers();

      verify(() => local.cacheUsers(users)).called(1);
    });

    test('falls back to cache when remote fails', () async {
      final cached = [FakeUser('cached_uid')];
      when(
        () => remote.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenThrow(
        const UsersRemoteDataSourceException(message: 'Network error'),
      );
      when(() => local.getCachedUsers()).thenAnswer((_) async => cached);

      final result = await repo.getUsers();

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 1));
    });

    test('returns failure when both remote and cache fail', () async {
      when(
        () => remote.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenThrow(
        const UsersRemoteDataSourceException(message: 'Network error'),
      );
      when(
        () => local.getCachedUsers(),
      ).thenThrow(const UsersLocalDataSourceException(message: 'Cache miss'));

      final result = await repo.getUsers();

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getUserById
  // =========================================================================

  group('getUserById', () {
    test('returns cached user if available', () async {
      final user = FakeUser('uid_1');
      when(() => local.getCachedUser(any())).thenAnswer((_) async => user);

      final result = await repo.getUserById('uid_1');

      expect(result.isSuccess, isTrue);
      verifyNever(() => remote.getUser(any()));
    });

    test('fetches from remote when not cached', () async {
      final user = FakeUser('uid_1');
      when(() => local.getCachedUser(any())).thenAnswer((_) async => null);
      when(() => remote.getUser(any())).thenAnswer((_) async => user);
      when(() => local.cacheUser(any())).thenAnswer((_) async {});

      final result = await repo.getUserById('uid_1');

      expect(result.isSuccess, isTrue);
      verify(() => remote.getUser('uid_1')).called(1);
    });

    test('caches user after remote fetch', () async {
      final user = FakeUser('uid_1');
      when(() => local.getCachedUser(any())).thenAnswer((_) async => null);
      when(() => remote.getUser(any())).thenAnswer((_) async => user);
      when(() => local.cacheUser(any())).thenAnswer((_) async {});

      await repo.getUserById('uid_1');

      verify(() => local.cacheUser(user)).called(1);
    });

    test('returns failure when remote throws', () async {
      when(() => local.getCachedUser(any())).thenAnswer((_) async => null);
      when(() => remote.getUser(any())).thenThrow(
        const UsersRemoteDataSourceException(
          message: 'Not found',
          code: 'NOT_FOUND',
        ),
      );

      final result = await repo.getUserById('uid_1');

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // blockUser / unblockUser
  // =========================================================================

  group('blockUser', () {
    test('returns success when remote succeeds', () async {
      when(() => remote.blockUser(any())).thenAnswer((_) async {});

      final result = await repo.blockUser('uid_1');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.blockUser(any())).thenThrow(
        const UsersRemoteDataSourceException(message: 'Block failed'),
      );

      final result = await repo.blockUser('uid_1');
      expect(result.isFailure, isTrue);
    });
  });

  group('unblockUser', () {
    test('returns success when remote succeeds', () async {
      when(() => remote.unblockUser(any())).thenAnswer((_) async {});

      final result = await repo.unblockUser('uid_1');
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.unblockUser(any())).thenThrow(
        const UsersRemoteDataSourceException(message: 'Unblock failed'),
      );

      final result = await repo.unblockUser('uid_1');
      expect(result.isFailure, isTrue);
    });
  });
}
