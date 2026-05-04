import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/groups/bloc/groups_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/bloc/groups_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/bloc/groups_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/repositories/groups_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/get_groups_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/load_more_groups_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/groups/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupsRepository extends Mock implements GroupsRepository {}

class FakeGroup extends Fake implements Group {
  final String _guid;
  final String _name;
  final String _type;

  FakeGroup([this._guid = 'guid_1', this._name = 'Group 1', this._type = 'public'])
      : super();

  @override
  String get guid => _guid;

  @override
  String get name => _name;

  @override
  String get type => _type;

  @override
  set type(String value) {}

  @override
  int get membersCount => 5;

  @override
  set membersCount(int value) {}

  @override
  bool get hasJoined => true;

  @override
  set hasJoined(bool value) {}

  @override
  String? get scope => 'participant';

  @override
  set scope(String? value) {}
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';

  @override
  String get name => 'Test User';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GroupsBloc _makeBloc(MockGroupsRepository repo) {
  return GroupsBloc(
    getGroupsUseCase: GetGroupsUseCase(repo),
    loadMoreGroupsUseCase: LoadMoreGroupsUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGroup());
    registerFallbackValue(FakeUser());
  });

  group('GroupsBloc', () {
    late MockGroupsRepository repo;

    setUp(() {
      repo = MockGroupsRepository();
      // Default stubs
      when(() => repo.getLoggedInUser())
          .thenAnswer((_) async => Success(FakeUser()));
      when(() => repo.getGroups(
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
            joinedOnly: any(named: 'joinedOnly'),
          )).thenAnswer((_) async => const Success([]));
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state is GroupsInitial', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state, isA<GroupsInitial>());
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadGroups
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Empty] when no groups returned',
      build: () {
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => const Success([]));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsEmpty>(),
      ],
    );

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Loaded] when groups returned',
      build: () {
        final groups = [FakeGroup('g1', 'Dev'), FakeGroup('g2', 'Design')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.groups.length, 2);
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Error] when repository fails',
      build: () {
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async =>
                const Failure(message: 'Network error', code: 'NET_ERR'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsError>(),
      ],
    );

    // -----------------------------------------------------------------------
    // ToggleGroupSelection
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'toggles group selection in loaded state',
      build: () {
        final groups = [FakeGroup('g1', 'Dev')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleGroupSelection('g1'));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.selectedGroups.contains('g1'), isTrue);
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'deselects group when toggled again',
      build: () {
        final groups = [FakeGroup('g1', 'Dev')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleGroupSelection('g1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleGroupSelection('g1'));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.selectedGroups.contains('g1'), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // ClearGroupSelection
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'clears all group selections',
      build: () {
        final groups = [FakeGroup('g1'), FakeGroup('g2')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleGroupSelection('g1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleGroupSelection('g2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearGroupSelection());
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.selectedGroups, isEmpty);
      },
    );

    // -----------------------------------------------------------------------
    // AddGroup
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'adds new group to loaded list',
      build: () {
        final groups = [FakeGroup('g1', 'Dev')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(AddGroup(FakeGroup('g2', 'Design')));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.groups.length, 2);
      },
    );

    // -----------------------------------------------------------------------
    // RemoveGroup
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'removes group from loaded list',
      build: () {
        final groups = [FakeGroup('g1', 'Dev'), FakeGroup('g2', 'Design')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RemoveGroup('g1'));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.groups.length, 1);
        expect(state.groups.first.guid, 'g2');
      },
    );

    // -----------------------------------------------------------------------
    // UpdateGroup
    // -----------------------------------------------------------------------

    blocTest<GroupsBloc, GroupsState>(
      'updates existing group in loaded state',
      build: () {
        final groups = [FakeGroup('g1', 'Dev')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateGroup(FakeGroup('g1', 'Dev Updated')));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.groups.first.name, 'Dev Updated');
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'adds group if UpdateGroup targets non-existent guid',
      build: () {
        final groups = [FakeGroup('g1', 'Dev')];
        when(() => repo.getGroups(
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
              joinedOnly: any(named: 'joinedOnly'),
            )).thenAnswer((_) async => Success(groups));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroups());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateGroup(FakeGroup('g_new', 'New Group')));
      },
      verify: (bloc) {
        final state = bloc.state as GroupsLoaded;
        expect(state.groups.length, 2);
      },
    );
  });
}
