import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/group_members/bloc/group_members_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/bloc/group_members_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/bloc/group_members_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/repositories/group_members_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/get_group_members_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/load_more_group_members_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/kick_group_member_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/ban_group_member_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/update_member_scope_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/group_members/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupMembersRepository extends Mock
    implements GroupMembersRepository {}

class FakeGroupMember extends Fake implements GroupMember {
  final String _uid;
  final String _name;
  final String _scope;

  FakeGroupMember([
    this._uid = 'uid_1',
    this._name = 'Member 1',
    this._scope = 'participant',
  ]);

  @override
  String get uid => _uid;

  @override
  String get name => _name;

  @override
  String? get scope => _scope;

  @override
  String? get avatar => null;

  @override
  String? get status => 'offline';

  @override
  String? get role => null;

  @override
  DateTime? get joinedAt => null;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'logged_in_user';

  @override
  String get name => 'Logged In User';
}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_group';

  @override
  String get name => 'Test Group';

  @override
  int get membersCount => 5;

  @override
  set membersCount(int value) {}
}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'group_test_group';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GroupMembersBloc _makeBloc(MockGroupMembersRepository repo) {
  return GroupMembersBloc(
    group: FakeGroup(),
    getGroupMembersUseCase: GetGroupMembersUseCase(repo),
    loadMoreGroupMembersUseCase: LoadMoreGroupMembersUseCase(repo),
    kickGroupMemberUseCase: KickGroupMemberUseCase(repo),
    banGroupMemberUseCase: BanGroupMemberUseCase(repo),
    updateMemberScopeUseCase: UpdateMemberScopeUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    repository: repo,
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGroupMember());
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeGroup());
  });

  group('GroupMembersBloc', () {
    late MockGroupMembersRepository repo;

    setUp(() {
      repo = MockGroupMembersRepository();
      // Default stubs
      when(() => repo.getLoggedInUser())
          .thenAnswer((_) async => Success(FakeUser()));
      when(() => repo.getConversation(any()))
          .thenAnswer((_) async => Success(FakeConversation()));
      when(() => repo.getGroupMembers(
            guid: any(named: 'guid'),
            limit: any(named: 'limit'),
            searchKeyword: any(named: 'searchKeyword'),
          )).thenAnswer((_) async => const Success([]));
      when(() => repo.resetPagination()).thenReturn(null);
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state is GroupMembersInitial', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state, isA<GroupMembersInitial>());
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadGroupMembers
    // -----------------------------------------------------------------------

    blocTest<GroupMembersBloc, GroupMembersState>(
      'emits [Loading, Empty] when no members returned',
      build: () {
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => const Success([]));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroupMembers()),
      expect: () => [
        isA<GroupMembersLoading>(),
        isA<GroupMembersEmpty>(),
      ],
    );

    blocTest<GroupMembersBloc, GroupMembersState>(
      'emits [Loading, Loaded] when members returned',
      build: () {
        final members = [
          FakeGroupMember('uid_1', 'Alice', 'admin'),
          FakeGroupMember('uid_2', 'Bob', 'participant'),
        ];
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => Success(members));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroupMembers()),
      expect: () => [
        isA<GroupMembersLoading>(),
        isA<GroupMembersLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as GroupMembersLoaded;
        expect(state.members.length, 2);
      },
    );

    blocTest<GroupMembersBloc, GroupMembersState>(
      'emits [Loading, Error] when repository fails',
      build: () {
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async =>
                const Failure(message: 'Network error', code: 'NET_ERR'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadGroupMembers()),
      expect: () => [
        isA<GroupMembersLoading>(),
        isA<GroupMembersError>(),
      ],
    );

    // -----------------------------------------------------------------------
    // ToggleMemberSelection
    // -----------------------------------------------------------------------

    blocTest<GroupMembersBloc, GroupMembersState>(
      'toggles member selection in loaded state',
      build: () {
        final members = [FakeGroupMember('uid_1', 'Alice', 'participant')];
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => Success(members));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroupMembers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMemberSelection('uid_1'));
      },
      verify: (bloc) {
        final state = bloc.state as GroupMembersLoaded;
        expect(state.selectedMembers.contains('uid_1'), isTrue);
      },
    );

    blocTest<GroupMembersBloc, GroupMembersState>(
      'does not select owner members',
      build: () {
        final members = [FakeGroupMember('uid_1', 'Owner', 'owner')];
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => Success(members));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroupMembers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMemberSelection('uid_1'));
      },
      verify: (bloc) {
        final state = bloc.state as GroupMembersLoaded;
        expect(state.selectedMembers.contains('uid_1'), isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // ClearMemberSelection
    // -----------------------------------------------------------------------

    blocTest<GroupMembersBloc, GroupMembersState>(
      'clears all member selections',
      build: () {
        final members = [
          FakeGroupMember('uid_1', 'Alice', 'participant'),
          FakeGroupMember('uid_2', 'Bob', 'participant'),
        ];
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => Success(members));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroupMembers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMemberSelection('uid_1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMemberSelection('uid_2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearMemberSelection());
      },
      verify: (bloc) {
        final state = bloc.state as GroupMembersLoaded;
        expect(state.selectedMembers, isEmpty);
      },
    );

    // -----------------------------------------------------------------------
    // UpdateMember
    // -----------------------------------------------------------------------

    blocTest<GroupMembersBloc, GroupMembersState>(
      'updates existing member in loaded state',
      build: () {
        final members = [FakeGroupMember('uid_1', 'Alice', 'participant')];
        when(() => repo.getGroupMembers(
              guid: any(named: 'guid'),
              limit: any(named: 'limit'),
              searchKeyword: any(named: 'searchKeyword'),
            )).thenAnswer((_) async => Success(members));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadGroupMembers());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateMember(FakeGroupMember('uid_1', 'Alice', 'admin')));
      },
      verify: (bloc) {
        final state = bloc.state as GroupMembersLoaded;
        expect(state.members.first.scope, 'admin');
      },
    );
  });
}
