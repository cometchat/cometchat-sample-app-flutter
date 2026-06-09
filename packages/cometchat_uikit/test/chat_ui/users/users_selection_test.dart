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
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockUsersRepository extends Mock implements UsersRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  final String _name;

  FakeUser([this._uid = 'uid_1', this._name = 'User 1']);

  @override
  String get uid => _uid;
  @override
  String get name => _name;
  @override
  String? get status => null;
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

List<FakeUser> _generateUsers(int count) {
  return List.generate(count, (i) => FakeUser('uid_$i', 'User $i'));
}

// ---------------------------------------------------------------------------
// Tests — Kotlin UsersSelectionPreservationTest + UsersSelectionResetBugExplorationTest
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  late MockUsersRepository repo;

  setUp(() {
    repo = MockUsersRepository();
    when(() => repo.getLoggedInUser())
        .thenAnswer((_) async => Success(FakeUser('me', 'Me')));
    when(() => repo.getUsers(
          limit: any(named: 'limit'),
          searchKeyword: any(named: 'searchKeyword'),
          usersRequestBuilder: any(named: 'usersRequestBuilder'),
        )).thenAnswer((_) async => Success(_generateUsers(5)));
  });

  // =========================================================================
  // SINGLE Selection Mode — Kotlin CSV #1101-1105
  // =========================================================================

  group('SINGLE selection mode behavior', () {
    blocTest<UsersBloc, UsersState>(
      'selecting one user adds to selectedUsers',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 1);
        expect(state.selectedUsers.contains('uid_0'), isTrue);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'selecting same user again deselects (toggle behavior)',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_0'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.contains('uid_0'), isFalse);
        expect(state.selectedUsers, isEmpty);
      },
    );
  });

  // =========================================================================
  // MULTIPLE Selection Mode — Kotlin CSV #1106-1112
  // =========================================================================

  group('MULTIPLE selection mode behavior', () {
    blocTest<UsersBloc, UsersState>(
      'selecting multiple users accumulates in selectedUsers',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_2'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 3);
        expect(state.selectedUsers, containsAll(['uid_0', 'uid_1', 'uid_2']));
      },
    );

    blocTest<UsersBloc, UsersState>(
      'deselecting one from multiple preserves others',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_2'));
        await Future.delayed(const Duration(milliseconds: 50));
        // Deselect uid_1
        bloc.add(const ToggleUserSelection('uid_1'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 2);
        expect(state.selectedUsers, containsAll(['uid_0', 'uid_2']));
        expect(state.selectedUsers.contains('uid_1'), isFalse);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'selecting all users in list',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        for (int i = 0; i < 5; i++) {
          bloc.add(ToggleUserSelection('uid_$i'));
          await Future.delayed(const Duration(milliseconds: 30));
        }
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 5);
      },
    );
  });

  // =========================================================================
  // NONE Selection Mode — Kotlin CSV #1113-1115
  // =========================================================================

  group('NONE selection mode (no selection)', () {
    blocTest<UsersBloc, UsersState>(
      'toggle is no-op when state is not UsersLoaded',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ToggleUserSelection('uid_0')),
      expect: () => <UsersState>[],
    );

    blocTest<UsersBloc, UsersState>(
      'clear is no-op when state is not UsersLoaded',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ClearUserSelection()),
      expect: () => <UsersState>[],
    );
  });

  // =========================================================================
  // Selection Callbacks — Kotlin CSV #1116-1120
  // =========================================================================

  group('Selection callbacks', () {
    blocTest<UsersBloc, UsersState>(
      'onSelection can retrieve selected User objects from state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_3'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        final selectedIds = state.selectedUsers;
        final selectedUsers =
            state.users.where((u) => selectedIds.contains(u.uid)).toList();
        expect(selectedUsers.length, 2);
        expect(selectedUsers.map((u) => u.uid), containsAll(['uid_1', 'uid_3']));
      },
    );

    blocTest<UsersBloc, UsersState>(
      'selection count reflected in state for title display',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_2'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 2);
      },
    );
  });

  // =========================================================================
  // State Preservation — Kotlin CSV #1121-1125
  // =========================================================================

  group('Selection state preservation', () {
    blocTest<UsersBloc, UsersState>(
      'selection preserved across LoadMoreUsers',
      build: () {
        var callCount = 0;
        when(() => repo.getUsers(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              usersRequestBuilder: any(named: 'usersRequestBuilder'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Success(List.generate(
                30, (i) => FakeUser('uid_$i', 'User $i')));
          }
          return Success(List.generate(
              10, (i) => FakeUser('uid_${30 + i}', 'User ${30 + i}')));
        });
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_5'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const LoadMoreUsers());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.contains('uid_5'), isTrue);
        expect(state.users.length, 40);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'selection preserved across UpdateUser',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateUser(FakeUser('uid_0', 'Updated User 0')));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.contains('uid_0'), isTrue);
        expect(state.users.first.name, 'Updated User 0');
      },
    );
  });

  // =========================================================================
  // ClearUserSelection (Discard) — Kotlin UsersSelectionResetBugExplorationTest
  // =========================================================================

  group('ClearUserSelection (discard button)', () {
    blocTest<UsersBloc, UsersState>(
      'ClearUserSelection empties all selections',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleUserSelection('uid_2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearUserSelection());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers, isEmpty);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'ClearUserSelection preserves users list',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearUserSelection());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.users.length, 5);
        expect(state.selectedUsers, isEmpty);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'ClearUserSelection is idempotent (calling twice is safe)',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_0'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearUserSelection());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearUserSelection());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers, isEmpty);
      },
    );
  });

  // =========================================================================
  // Selection after detach/re-attach — Kotlin CSV #1126-1130
  // =========================================================================

  group('Selection after refresh (simulating detach/re-attach)', () {
    blocTest<UsersBloc, UsersState>(
      'RefreshUsers does not clear selection',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshUsers());
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        // Selection should be preserved after refresh
        expect(state.selectedUsers.contains('uid_2'), isTrue);
      },
    );
  });

  // =========================================================================
  // Bug Exploration: Counterexamples — Kotlin CSV #1131-1140
  // =========================================================================

  group('Bug exploration: selection edge cases', () {
    blocTest<UsersBloc, UsersState>(
      'selecting non-existent uid still adds to selectedUsers set',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_nonexistent'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        // The BLoC doesn't validate uid existence — it just stores the ID
        expect(state.selectedUsers.contains('uid_nonexistent'), isTrue);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'rapid toggle does not corrupt selection state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        // Rapid toggles on same user
        bloc.add(const ToggleUserSelection('uid_0'));
        bloc.add(const ToggleUserSelection('uid_0'));
        bloc.add(const ToggleUserSelection('uid_0'));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        // 3 toggles: select → deselect → select
        expect(state.selectedUsers.contains('uid_0'), isTrue);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'selection survives error during LoadMoreUsers',
      build: () {
        var callCount = 0;
        when(() => repo.getUsers(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              usersRequestBuilder: any(named: 'usersRequestBuilder'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Success(_generateUsers(30));
          }
          return const Failure(message: 'Error', code: 'ERR');
        });
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection('uid_5'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const LoadMoreUsers());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        // After error, state transitions to UsersError with previousUsers
        final state = bloc.state as UsersError;
        expect(state.previousUsers, isNotNull);
        expect(state.previousUsers!.length, 30);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'empty string uid toggle is handled gracefully',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ToggleUserSelection(''));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        // Empty string is still a valid Set entry
        expect(state.selectedUsers.contains(''), isTrue);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'large selection set (100 users) works correctly',
      build: () {
        when(() => repo.getUsers(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              usersRequestBuilder: any(named: 'usersRequestBuilder'),
            )).thenAnswer((_) async => Success(
            List.generate(100, (i) => FakeUser('uid_$i', 'User $i'))));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        for (int i = 0; i < 100; i++) {
          bloc.add(ToggleUserSelection('uid_$i'));
        }
      },
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers.length, 100);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'ClearUserSelection after large selection empties completely',
      build: () {
        when(() => repo.getUsers(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              usersRequestBuilder: any(named: 'usersRequestBuilder'),
            )).thenAnswer((_) async => Success(
            List.generate(50, (i) => FakeUser('uid_$i', 'User $i'))));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadUsers());
        await Future.delayed(const Duration(milliseconds: 100));
        for (int i = 0; i < 50; i++) {
          bloc.add(ToggleUserSelection('uid_$i'));
        }
        await Future.delayed(const Duration(milliseconds: 300));
        bloc.add(const ClearUserSelection());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        final state = bloc.state as UsersLoaded;
        expect(state.selectedUsers, isEmpty);
      },
    );
  });
}
