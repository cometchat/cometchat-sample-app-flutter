import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/users/bloc/users_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/bloc/users_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/bloc/users_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/repositories/users_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/usecases/get_users_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/users/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockUsersRepository extends Mock implements UsersRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  final String _name;
  final String? _status;

  FakeUser([this._uid = 'uid_1', this._name = 'User 1', this._status])
    : super();

  @override
  String get uid => _uid;

  @override
  String get name => _name;

  @override
  String? get status => _status;

  @override
  String? get avatar => null;

  @override
  String? get role => null;

  @override
  bool? get blockedByMe => false;

  @override
  bool? get hasBlockedMe => false;

  @override
  DateTime? get lastActiveAt => null;

  @override
  String? get link => null;

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  String? get statusMessage => null;

  @override
  List<String>? get tags => null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UsersBloc _makeBloc(MockUsersRepository repo) {
  return UsersBloc(
    getUsersUseCase: GetUsersUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  group('UsersBloc', () {
    late MockUsersRepository repo;

    setUp(() {
      repo = MockUsersRepository();
      // Default stubs
      when(
        () => repo.getLoggedInUser(),
      ).thenAnswer((_) async => Success(FakeUser('me', 'Me')));
      when(
        () => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        ),
      ).thenAnswer((_) async => const Success([]));
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state is UsersInitial', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state, isA<UsersInitial>());
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadUsers
    // -----------------------------------------------------------------------

    blocTest<UsersBloc, UsersState>(
      'emits [Loading, Empty] when no users returned',
      build: () {
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => const Success([]));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [isA<UsersLoading>(), isA<UsersEmpty>()],
    );

    blocTest<UsersBloc, UsersState>(
      'emits [Loading, Loaded] when users returned',
      build: () {
        final users = [FakeUser('uid_1', 'Alice'), FakeUser('uid_2', 'Bob')];
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => Success(users));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [isA<UsersLoading>(), isA<UsersLoaded>()],
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.users.length, 2);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'emits [Loading, Error] when repository fails',
      build: () {
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer(
          (_) async => const Failure(message: 'Network error', code: 'NET_ERR'),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [isA<UsersLoading>(), isA<UsersError>()],
    );

    // -----------------------------------------------------------------------
    // ToggleUserSelection
    // -----------------------------------------------------------------------

    blocTest<UsersBloc, UsersState>(
      'toggles user selection in loaded state',
      build: () {
        final users = [FakeUser('uid_1', 'Alice')];
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => Success(users));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
      },
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.contains('uid_1'), isTrue);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'deselects user when toggled again',
      build: () {
        final users = [FakeUser('uid_1', 'Alice')];
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => Success(users));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
      },
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.contains('uid_1'), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // ClearUserSelection
    // -----------------------------------------------------------------------

    blocTest<UsersBloc, UsersState>(
      'clears all selections',
      build: () {
        final users = [FakeUser('uid_1'), FakeUser('uid_2')];
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => Success(users));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearUserSelection());
      },
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers, isEmpty);
      },
    );

    // -----------------------------------------------------------------------
    // UpdateUser
    // -----------------------------------------------------------------------

    blocTest<UsersBloc, UsersState>(
      'updates existing user in loaded state',
      build: () {
        final users = [FakeUser('uid_1', 'Alice')];
        when(
          () => repo.getUsers(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            usersRequestBuilder: any(named: 'usersRequestBuilder'),
          ),
        ).thenAnswer((_) async => Success(users));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateUser(FakeUser('uid_1', 'Alice Updated')));
      },
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.users.first.name, 'Alice Updated');
      },
    );
  });
}
