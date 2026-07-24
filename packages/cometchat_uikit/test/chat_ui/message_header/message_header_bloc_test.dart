import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_header/bloc/message_header_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_header/bloc/message_header_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_header/bloc/message_header_state.dart';
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
  final String _uid;
  final String _name;
  final String? _status;
  final bool? _blockedByMe;
  final bool? _hasBlockedMe;

  FakeUser([
    this._uid = 'uid_1',
    this._name = 'Test User',
    this._status,
    this._blockedByMe,
    this._hasBlockedMe,
  ]);

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
  bool? get blockedByMe => _blockedByMe ?? false;

  @override
  bool? get hasBlockedMe => _hasBlockedMe ?? false;

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

class FakeGroup extends Fake implements Group {
  final String _guid;
  final String _name;
  final int _membersCount;

  FakeGroup([
    this._guid = 'guid_1',
    this._name = 'Test Group',
    this._membersCount = 5,
  ]);

  @override
  String get guid => _guid;

  @override
  String get name => _name;

  @override
  int get membersCount => _membersCount;

  @override
  String? get icon => null;

  @override
  String get type => 'public';

  @override
  set type(String value) {}
}

class FakeGroupMember extends Fake implements GroupMember {
  @override
  String get uid => 'new_owner';

  @override
  String get name => 'New Owner';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageHeaderBloc _makeBloc(MockMessageHeaderRepository repo) {
  return MessageHeaderBloc(
    getUserUseCase: GetUserUseCase(repo),
    getGroupUseCase: GetGroupUseCase(repo),
    getLoggedInUserUseCase: GetMessageHeaderLoggedInUserUseCase(repo),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeGroup());
  });

  group('MessageHeaderBloc', () {
    late MockMessageHeaderRepository repo;

    setUp(() {
      repo = MockMessageHeaderRepository();
      // Default stubs
      when(
        () => repo.getLoggedInUser(),
      ).thenAnswer((_) async => Success(FakeUser('me', 'Me')));
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state has initial status', () async {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageHeaderStatus.initial);
      // Wait for async init to complete before closing
      await Future.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });

    // -----------------------------------------------------------------------
    // SetUser
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'SetUser updates state with user and loaded status',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(SetUser(FakeUser('uid_1', 'Alice'))),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.user?.uid, 'uid_1');
        expect(bloc.state.user?.name, 'Alice');
        expect(bloc.state.group, isNull);
        expect(bloc.state.isTyping, isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // SetGroup
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'SetGroup updates state with group and loaded status',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(SetGroup(FakeGroup('guid_1', 'Dev Team', 10))),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.group?.guid, 'guid_1');
        expect(bloc.state.group?.name, 'Dev Team');
        expect(bloc.state.memberCount, 10);
        expect(bloc.state.user, isNull);
        expect(bloc.state.isTyping, isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // RefreshUser — uses act to set user first, then refresh
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'RefreshUser fetches updated user from repository',
      build: () {
        when(
          () => repo.getUser(any()),
        ).thenAnswer((_) async => Success(FakeUser('uid_1', 'Alice Updated')));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshUser());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.user?.name, 'Alice Updated');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'RefreshUser emits error when repository fails',
      build: () {
        when(() => repo.getUser(any())).thenAnswer(
          (_) async => const Failure(message: 'Not found', code: 'NOT_FOUND'),
        );
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshUser());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.error);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'RefreshUser does nothing when no user is set',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        // Wait for async init to complete
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshUser());
      },
      verify: (bloc) {
        // State should still be initial or have loggedInUser set, but no user
        expect(bloc.state.user, isNull);
      },
    );

    // -----------------------------------------------------------------------
    // RefreshGroup — uses act to set group first, then refresh
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'RefreshGroup fetches updated group from repository',
      build: () {
        when(() => repo.getGroup(any())).thenAnswer(
          (_) async => Success(FakeGroup('guid_1', 'Dev Updated', 12)),
        );
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup('guid_1', 'Dev', 10)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshGroup());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.group?.name, 'Dev Updated');
        expect(bloc.state.memberCount, 12);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'RefreshGroup does nothing when no group is set',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RefreshGroup());
      },
      verify: (bloc) {
        expect(bloc.state.group, isNull);
      },
    );

    // -----------------------------------------------------------------------
    // UpdateUserStatus — uses act to set user first
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UpdateUserStatus updates user status for matching user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice', 'offline')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateUserStatus(userId: 'uid_1', status: 'online'));
      },
      verify: (bloc) {
        expect(bloc.state.user?.status, 'online');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UpdateUserStatus ignores non-matching user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice', 'offline')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateUserStatus(userId: 'uid_other', status: 'online'));
      },
      verify: (bloc) {
        // Status should remain unchanged
        expect(bloc.state.user?.uid, 'uid_1');
        expect(bloc.state.user?.status, isNot('online'));
      },
    );

    // -----------------------------------------------------------------------
    // UpdateGroupMemberCount — uses act to set group first
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UpdateGroupMemberCount updates count for matching group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup('guid_1', 'Dev', 5)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const UpdateGroupMemberCount(groupId: 'guid_1', memberCount: 10),
        );
      },
      verify: (bloc) {
        expect(bloc.state.memberCount, 10);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UpdateGroupMemberCount ignores non-matching group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup('guid_1', 'Dev', 5)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const UpdateGroupMemberCount(groupId: 'guid_other', memberCount: 10),
        );
      },
      verify: (bloc) {
        expect(bloc.state.memberCount, 5);
      },
    );

    // -----------------------------------------------------------------------
    // UserBlocked / UserUnblocked — uses act to set user first
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UserBlocked sets blockedByMe to true for matching user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UserBlocked(FakeUser('uid_1', 'Alice')));
      },
      verify: (bloc) {
        expect(bloc.state.user?.blockedByMe, isTrue);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UserUnblocked sets blockedByMe to false for matching user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice', null, true)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UserUnblocked(FakeUser('uid_1', 'Alice')));
      },
      verify: (bloc) {
        expect(bloc.state.user?.blockedByMe, isFalse);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UserBlocked ignores non-matching user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser('uid_1', 'Alice')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UserBlocked(FakeUser('uid_other', 'Other')));
      },
      verify: (bloc) {
        expect(bloc.state.user?.uid, 'uid_1');
        expect(bloc.state.user?.blockedByMe, isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // GroupOwnershipChanged — uses act to set group first
    // -----------------------------------------------------------------------

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'GroupOwnershipChanged updates group for matching group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup('guid_1', 'Dev', 5)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          GroupOwnershipChanged(
            group: FakeGroup('guid_1', 'Dev Renamed', 5),
            newOwner: FakeGroupMember(),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.group?.name, 'Dev Renamed');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'GroupOwnershipChanged ignores non-matching group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup('guid_1', 'Dev', 5)));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          GroupOwnershipChanged(
            group: FakeGroup('guid_other', 'Other', 3),
            newOwner: FakeGroupMember(),
          ),
        );
      },
      verify: (bloc) {
        // Group should remain unchanged
        expect(bloc.state.group?.guid, 'guid_1');
        expect(bloc.state.group?.name, 'Dev');
      },
    );

    // -----------------------------------------------------------------------
    // State helper getters
    // -----------------------------------------------------------------------

    test('isUserConversation returns true when user is set', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        user: FakeUser(),
      );
      expect(state.isUserConversation, isTrue);
      expect(state.isGroupConversation, isFalse);
    });

    test('isGroupConversation returns true when group is set', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        group: FakeGroup(),
      );
      expect(state.isGroupConversation, isTrue);
      expect(state.isUserConversation, isFalse);
    });

    test('displayName returns user name for user conversation', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        user: FakeUser('uid_1', 'Alice'),
      );
      expect(state.displayName, 'Alice');
    });

    test('displayName returns group name for group conversation', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        group: FakeGroup('guid_1', 'Dev Team'),
      );
      expect(state.displayName, 'Dev Team');
    });

    test('userIsNotBlocked returns true when user is not blocked', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        user: FakeUser('uid_1', 'Alice', null, false, false),
      );
      expect(state.userIsNotBlocked, isTrue);
    });

    test('isBlockedByMe returns true when user is blocked by me', () {
      final state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        user: FakeUser('uid_1', 'Alice', null, true, false),
      );
      expect(state.isBlockedByMe, isTrue);
      expect(state.userIsNotBlocked, isFalse);
    });
  });
}
