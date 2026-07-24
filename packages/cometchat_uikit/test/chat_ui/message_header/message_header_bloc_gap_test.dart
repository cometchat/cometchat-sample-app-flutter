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
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockMessageHeaderRepository extends Mock
    implements MessageHeaderRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  final String _name;
  final String _status;
  final String? _avatar;
  final bool _blockedByMe;
  final bool _hasBlockedMe;
  final String? _role;
  final DateTime? _lastActiveAt;

  FakeUser({
    String uid = 'test_user',
    String name = 'Test User',
    String status = 'online',
    String? avatar,
    bool blockedByMe = false,
    bool hasBlockedMe = false,
    String? role,
    DateTime? lastActiveAt,
  }) : _uid = uid,
       _name = name,
       _status = status,
       _avatar = avatar,
       _blockedByMe = blockedByMe,
       _hasBlockedMe = hasBlockedMe,
       _role = role,
       _lastActiveAt = lastActiveAt;

  @override
  String get uid => _uid;
  @override
  String get name => _name;
  @override
  String get status => _status;
  @override
  String? get avatar => _avatar;
  @override
  bool get blockedByMe => _blockedByMe;
  @override
  bool get hasBlockedMe => _hasBlockedMe;
  @override
  String? get role => _role;
  @override
  DateTime? get lastActiveAt => _lastActiveAt;
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
  final String _type;
  final String? _icon;

  FakeGroup({
    String guid = 'test_group',
    String name = 'Test Group',
    int membersCount = 5,
    String type = 'public',
    String? icon,
  }) : _guid = guid,
       _name = name,
       _membersCount = membersCount,
       _type = type,
       _icon = icon;

  @override
  String get guid => _guid;
  @override
  String get name => _name;
  @override
  int get membersCount => _membersCount;
  @override
  String get type => _type;
  @override
  String? get icon => _icon;
  @override
  String get owner => '';
  @override
  String? get description => null;
  @override
  DateTime? get createdAt => null;
  @override
  DateTime? get joinedAt => null;
  @override
  bool get hasJoined => true;
  @override
  String? get scope => 'admin';
  @override
  List<String>? get tags => null;
  @override
  Map<String, dynamic>? get metadata => null;
  @override
  String? get password => null;
}

class FakeTypingIndicator extends Fake implements TypingIndicator {
  final User _sender;
  final String _receiverType;
  final String _receiverId;

  FakeTypingIndicator({
    required User sender,
    required String receiverType,
    String receiverId = '',
  }) : _sender = sender,
       _receiverType = receiverType,
       _receiverId = receiverId;

  @override
  User get sender => _sender;
  @override
  String get receiverType => _receiverType;
  @override
  String get receiverId => _receiverId;
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
// Tests — Android CSV #1441-1465
// ---------------------------------------------------------------------------

void main() {
  late MockMessageHeaderRepository repo;

  setUp(() {
    repo = MockMessageHeaderRepository();
    when(
      () => repo.getLoggedInUser(),
    ).thenAnswer((_) async => Success(FakeUser()));
  });

  // =========================================================================
  // Interaction: Opening user/group sets and updates state (#1441-1446)
  // =========================================================================

  group('Interaction — SetUser / SetGroup', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1441 opening user sets user and updates state to loaded',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice'))),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.user?.uid, 'alice');
        expect(bloc.state.user?.name, 'Alice');
        expect(bloc.state.isUserConversation, isTrue);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1442 opening group sets group and updates state to loaded',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        SetGroup(FakeGroup(guid: 'team', name: 'Team Chat', membersCount: 12)),
      ),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.group?.guid, 'team');
        expect(bloc.state.group?.name, 'Team Chat');
        expect(bloc.state.memberCount, 12);
        expect(bloc.state.isGroupConversation, isTrue);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1443 switching user to group sets group and updates state',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        bloc.add(SetGroup(FakeGroup(guid: 'team', name: 'Team')));
      },
      verify: (bloc) {
        // Note: copyWith semantics mean user is preserved (null doesn't clear)
        // but group is set and isGroupConversation checks group != null
        expect(bloc.state.group, isNotNull);
        expect(bloc.state.isGroupConversation, isTrue);
        expect(bloc.state.status, MessageHeaderStatus.loaded);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1444 switching group to user sets user and resets member count',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(
          SetGroup(FakeGroup(guid: 'team', name: 'Team', membersCount: 10)),
        );
        bloc.add(SetUser(FakeUser(uid: 'bob', name: 'Bob')));
      },
      verify: (bloc) {
        expect(bloc.state.user, isNotNull);
        expect(bloc.state.user?.uid, 'bob');
        expect(bloc.state.isUserConversation, isTrue);
        expect(bloc.state.memberCount, 0);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1445 refresh user updates on success',
      build: () {
        when(() => repo.getUser('alice')).thenAnswer(
          (_) async => Success(
            FakeUser(uid: 'alice', name: 'Alice Updated', status: 'offline'),
          ),
        );
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const RefreshUser());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.user?.name, 'Alice Updated');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1446 refresh group updates member count on success',
      build: () {
        when(() => repo.getGroup('team')).thenAnswer(
          (_) async => Success(
            FakeGroup(guid: 'team', name: 'Team Chat', membersCount: 20),
          ),
        );
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(
          SetGroup(FakeGroup(guid: 'team', name: 'Team Chat', membersCount: 5)),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const RefreshGroup());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.loaded);
        expect(bloc.state.memberCount, 20);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'refresh failure emits error without changing user/group state',
      build: () {
        when(
          () => repo.getUser('alice'),
        ).thenAnswer((_) async => const Failure(message: 'Network error'));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const RefreshUser());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.status, MessageHeaderStatus.error);
        expect(bloc.state.user?.uid, 'alice');
      },
    );
  });

  // =========================================================================
  // Rendering: User online/offline, group content (#1447-1455)
  // =========================================================================

  group('Rendering — user/group content', () {
    test('#1447 user online produces correct content', () {
      final bloc = _makeBloc(repo);
      bloc.add(
        SetUser(FakeUser(uid: 'alice', name: 'Alice', status: 'online')),
      );
      // Allow event to process
      Future.delayed(const Duration(milliseconds: 20), () {
        expect(bloc.state.isUserOnline, isTrue);
        expect(bloc.state.displayName, 'Alice');
        bloc.close();
      });
    });

    test('#1448 user offline produces correct content', () {
      final bloc = _makeBloc(repo);
      bloc.add(SetUser(FakeUser(uid: 'bob', name: 'Bob', status: 'offline')));
      Future.delayed(const Duration(milliseconds: 20), () {
        expect(bloc.state.isUserOnline, isFalse);
        expect(bloc.state.displayName, 'Bob');
        bloc.close();
      });
    });

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1449 blocked user still produces content',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        SetUser(
          FakeUser(uid: 'blocked', name: 'Blocked User', blockedByMe: true),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.displayName, 'Blocked User');
        expect(bloc.state.isBlockedByMe, isTrue);
        expect(bloc.state.userIsNotBlocked, isFalse);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1450 group produces content with member count',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        SetGroup(FakeGroup(guid: 'team', name: 'Team', membersCount: 8)),
      ),
      verify: (bloc) {
        expect(bloc.state.displayName, 'Team');
        expect(bloc.state.memberCount, 8);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1451 group type preserved',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        SetGroup(
          FakeGroup(guid: 'private_grp', name: 'Private', type: 'private'),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.group?.type, 'private');
      },
    );

    test('#1452 initial state is initial status', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageHeaderStatus.initial);
      bloc.close();
    });
  });

  // =========================================================================
  // Typing indicators (#1453-1455)
  // =========================================================================

  group('Typing indicators', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1453 typingIndicator null (no typing) shows status/count',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice'))),
      verify: (bloc) {
        expect(bloc.state.isTyping, isFalse);
        expect(bloc.state.typingUser, isNull);
        expect(bloc.typingIndicators, isEmpty);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1454 typing started for user conversation updates state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          TypingStarted(
            FakeTypingIndicator(
              sender: FakeUser(uid: 'alice', name: 'Alice'),
              receiverType: 'user',
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.isTyping, isTrue);
        expect(bloc.state.typingUser?.uid, 'alice');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1455 typing ended clears typing state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          TypingStarted(
            FakeTypingIndicator(
              sender: FakeUser(uid: 'alice', name: 'Alice'),
              receiverType: 'user',
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          TypingEnded(
            FakeTypingIndicator(
              sender: FakeUser(uid: 'alice', name: 'Alice'),
              receiverType: 'user',
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.isTyping, isFalse);
        expect(bloc.state.typingUser, isNull);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'typing from irrelevant user is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        // Typing from a different user
        bloc.add(
          TypingStarted(
            FakeTypingIndicator(
              sender: FakeUser(uid: 'bob', name: 'Bob'),
              receiverType: 'user',
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.isTyping, isFalse);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'group typing shows typing user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup(guid: 'team', name: 'Team')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          TypingStarted(
            FakeTypingIndicator(
              sender: FakeUser(uid: 'alice', name: 'Alice'),
              receiverType: 'group',
              receiverId: 'team',
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.isTyping, isTrue);
        expect(bloc.state.typingUser?.name, 'Alice');
      },
    );
  });

  // =========================================================================
  // User status updates (#1456-1458)
  // =========================================================================

  group('User status updates', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1456 UpdateUserStatus changes user online/offline',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(
          SetUser(FakeUser(uid: 'alice', name: 'Alice', status: 'online')),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const UpdateUserStatus(userId: 'alice', status: 'offline'));
      },
      verify: (bloc) {
        expect(bloc.state.user?.status, 'offline');
        expect(bloc.state.isUserOnline, isFalse);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1457 UpdateUserStatus for different user is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(
          SetUser(FakeUser(uid: 'alice', name: 'Alice', status: 'online')),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const UpdateUserStatus(userId: 'bob', status: 'offline'));
      },
      verify: (bloc) {
        expect(bloc.state.user?.status, 'online');
      },
    );
  });

  // =========================================================================
  // Group member count updates (#1459-1460)
  // =========================================================================

  group('Group member count updates', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1459 UpdateGroupMemberCount updates count',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(
          SetGroup(FakeGroup(guid: 'team', name: 'Team', membersCount: 5)),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          const UpdateGroupMemberCount(groupId: 'team', memberCount: 10),
        );
      },
      verify: (bloc) {
        expect(bloc.state.memberCount, 10);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1460 UpdateGroupMemberCount for different group is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(
          SetGroup(FakeGroup(guid: 'team', name: 'Team', membersCount: 5)),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          const UpdateGroupMemberCount(groupId: 'other', memberCount: 99),
        );
      },
      verify: (bloc) {
        expect(bloc.state.memberCount, 5);
      },
    );
  });

  // =========================================================================
  // Block/Unblock (#1461-1462)
  // =========================================================================

  group('Block / Unblock', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1461 UserBlocked sets blockedByMe to true',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(UserBlocked(FakeUser(uid: 'alice', name: 'Alice')));
      },
      verify: (bloc) {
        expect(bloc.state.isBlockedByMe, isTrue);
        expect(bloc.state.userIsNotBlocked, isFalse);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      '#1462 UserUnblocked sets blockedByMe to false',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(
          SetUser(FakeUser(uid: 'alice', name: 'Alice', blockedByMe: true)),
        );
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(UserUnblocked(FakeUser(uid: 'alice', name: 'Alice')));
      },
      verify: (bloc) {
        expect(bloc.state.isBlockedByMe, isFalse);
        expect(bloc.state.userIsNotBlocked, isTrue);
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'UserBlocked for different user is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(UserBlocked(FakeUser(uid: 'bob', name: 'Bob')));
      },
      verify: (bloc) {
        expect(bloc.state.isBlockedByMe, isFalse);
      },
    );
  });

  // =========================================================================
  // Style / State (#1463-1465)
  // =========================================================================

  group('State — copyWith and computed properties', () {
    test('#1463 MessageHeaderState copyWith preserves unchanged fields', () {
      const state = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        memberCount: 5,
        isTyping: true,
      );
      final copied = state.copyWith(memberCount: 10);
      expect(copied.status, MessageHeaderStatus.loaded);
      expect(copied.memberCount, 10);
      expect(copied.isTyping, isTrue);
    });

    test('#1464 MessageHeaderState equality — same values', () {
      const state1 = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        memberCount: 5,
      );
      const state2 = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        memberCount: 5,
      );
      expect(state1, equals(state2));
    });

    test('#1465 MessageHeaderState equality — different values', () {
      const state1 = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        memberCount: 5,
      );
      const state2 = MessageHeaderState(
        status: MessageHeaderStatus.loaded,
        memberCount: 10,
      );
      expect(state1, isNot(equals(state2)));
    });

    test('displayName returns empty string when no user/group', () {
      const state = MessageHeaderState();
      expect(state.displayName, '');
    });

    test('avatarUrl returns user avatar for user conversation', () {
      final state = MessageHeaderState(
        user: FakeUser(
          uid: 'alice',
          name: 'Alice',
          avatar: 'https://img.com/alice.png',
        ),
      );
      expect(state.avatarUrl, 'https://img.com/alice.png');
    });

    test('avatarUrl returns group icon for group conversation', () {
      final state = MessageHeaderState(
        group: FakeGroup(
          guid: 'team',
          name: 'Team',
          icon: 'https://img.com/team.png',
        ),
      );
      expect(state.avatarUrl, 'https://img.com/team.png');
    });

    test('isUserAgentic returns true for AI role', () {
      final state = MessageHeaderState(
        user: FakeUser(uid: 'ai_bot', name: 'AI Bot', role: 'ai'),
      );
      expect(state.isUserAgentic, isTrue);
    });

    test('isUserAgentic returns false for regular user', () {
      final state = MessageHeaderState(
        user: FakeUser(uid: 'alice', name: 'Alice'),
      );
      expect(state.isUserAgentic, isFalse);
    });
  });

  // =========================================================================
  // Rapid updates (#1446 extension)
  // =========================================================================

  group('Rapid updates', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'rapid user/group switches settle on last set group',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(SetUser(FakeUser(uid: 'alice', name: 'Alice')));
        bloc.add(SetGroup(FakeGroup(guid: 'team1', name: 'Team 1')));
        bloc.add(SetUser(FakeUser(uid: 'bob', name: 'Bob')));
        bloc.add(SetGroup(FakeGroup(guid: 'team2', name: 'Team 2')));
      },
      verify: (bloc) {
        expect(bloc.state.isGroupConversation, isTrue);
        expect(bloc.state.group?.guid, 'team2');
        // Last event was SetGroup, so memberCount reflects team2
        expect(bloc.state.status, MessageHeaderStatus.loaded);
      },
    );
  });

  // =========================================================================
  // GroupOwnershipChanged
  // =========================================================================

  group('GroupOwnershipChanged', () {
    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'updates group on ownership change',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup(guid: 'team', name: 'Team')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          GroupOwnershipChanged(
            group: FakeGroup(guid: 'team', name: 'Team'),
            newOwner: FakeGroupMember(),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.group?.guid, 'team');
      },
    );

    blocTest<MessageHeaderBloc, MessageHeaderState>(
      'ignores ownership change for different group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetGroup(FakeGroup(guid: 'team', name: 'Team')));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(
          GroupOwnershipChanged(
            group: FakeGroup(guid: 'other', name: 'Other'),
            newOwner: FakeGroupMember(),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.group?.guid, 'team');
      },
    );
  });
}
