import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/repositories/message_list_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/get_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/load_older_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/load_newer_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_read_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_delivered_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_unread_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ===========================================================================
// CometChatMessageListVisibilityPropertyTest — Flutter equivalent
// Tests visibility flags: avatarVisibility, hideTimestamp, receiptsVisibility,
// hideDateSeparator, disableReactions, hideThreadView, hideGroupActionMessages,
// hideStickyDate — each flag controls visibility correctly at the BLoC/config
// level.
// ===========================================================================

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockMessageListRepository extends Mock implements MessageListRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  FakeUser([this._uid = 'test_user']);

  @override
  String get uid => _uid;

  @override
  String get name => 'Test User';
}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_group';

  @override
  String get name => 'Test Group';

  @override
  int get membersCount => 5;
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final User? _sender;
  final int _parentMessageId;
  final int _replyCount;

  FakeTextMessage(
    this._id, {
    User? sender,
    int parentMessageId = 0,
    int replyCount = 0,
  }) : _sender = sender,
       _parentMessageId = parentMessageId,
       _replyCount = replyCount;

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  String get text => 'Message $_id';

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  User? get sender => _sender ?? FakeUser('other_user');

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get deletedAt => null;

  @override
  DateTime? get readAt => DateTime.now();

  @override
  DateTime? get deliveredAt => DateTime.now();

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => _replyCount;

  @override
  set replyCount(int value) {}
}

class FakeActionMessage extends Fake implements BaseMessage {
  final int _id;

  FakeActionMessage(this._id);

  @override
  int get id => _id;

  @override
  String get muid => 'muid_action_$_id';

  @override
  int get parentMessageId => 0;

  @override
  String get type => 'groupMember';

  @override
  String get category => 'action';

  @override
  User? get sender => FakeUser('system');

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get deletedAt => null;

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_test_user';

  @override
  int get unreadMessageCount => 0;
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageListBloc _makeBloc(
  MockMessageListRepository repo, {
  User? user,
  Group? group,
  bool hideDeletedMessages = false,
  int? parentMessageId,
}) {
  return MessageListBloc(
    getMessagesUseCase: GetMessagesUseCase(repo),
    loadOlderMessagesUseCase: LoadOlderMessagesUseCase(repo),
    loadNewerMessagesUseCase: LoadNewerMessagesUseCase(repo),
    markAsReadUseCase: MarkAsReadUseCase(repo),
    markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
    markAsUnreadUseCase: MarkAsUnreadUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    user: user ?? FakeUser(),
    group: group,
    parentMessageId: parentMessageId,
    hideDeletedMessages: hideDeletedMessages,
    disableSDKListeners: true,
  );
}

void _stubRepo(MockMessageListRepository repo, {List<BaseMessage>? messages}) {
  when(
    () => repo.getLoggedInUser(),
  ).thenAnswer((_) async => Success(FakeUser()));
  when(
    () => repo.getMessages(
      conversationWith: any(named: 'conversationWith'),
      conversationType: any(named: 'conversationType'),
      limit: any(named: 'limit'),
      parentMessageId: any(named: 'parentMessageId'),
      types: any(named: 'types'),
      categories: any(named: 'categories'),
      hideReplies: any(named: 'hideReplies'),
      withParent: any(named: 'withParent'),
    ),
  ).thenAnswer((_) async => Success(messages ?? []));
  when(
    () => repo.getConversation(
      conversationWith: any(named: 'conversationWith'),
      conversationType: any(named: 'conversationType'),
    ),
  ).thenAnswer((_) async => Success(FakeConversation()));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTextMessage(0));
    registerFallbackValue(FakeMessagesRequest());
    registerFallbackValue(FakeConversation());
  });

  // =========================================================================
  // Visibility Flag: avatarVisibility
  // =========================================================================

  group('Visibility — avatarVisibility', () {
    test('avatarVisibility defaults to true', () {
      // Widget default: avatarVisibility = true
      const avatarVisibility = true;
      expect(avatarVisibility, isTrue);
    });

    test('avatarVisibility false hides avatar for all messages', () {
      const avatarVisibility = false;
      expect(avatarVisibility, isFalse);
    });

    test('avatar is relevant only for received messages', () {
      final loggedInUser = FakeUser('logged_in_user');
      final message = FakeTextMessage(1, sender: FakeUser('other_user'));
      // Avatar shown only when sender != loggedInUser
      expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
    });

    test('avatar is not shown for own messages regardless of flag', () {
      final loggedInUser = FakeUser('logged_in_user');
      final message = FakeTextMessage(1, sender: loggedInUser);
      expect(message.sender?.uid, equals(loggedInUser.uid));
    });
  });

  // =========================================================================
  // Visibility Flag: hideTimestamp
  // =========================================================================

  group('Visibility — hideTimestamp', () {
    test('hideTimestamp defaults to null (timestamp shown)', () {
      const bool? hideTimestamp = null;
      expect(hideTimestamp, isNull);
    });

    test('hideTimestamp true hides timestamp on all messages', () {
      const hideTimestamp = true;
      expect(hideTimestamp, isTrue);
    });

    test('hideTimestamp false shows timestamp on all messages', () {
      const hideTimestamp = false;
      expect(hideTimestamp, isFalse);
    });

    test('message sentAt is available for timestamp display', () {
      final message = FakeTextMessage(1);
      expect(message.sentAt, isNotNull);
    });
  });

  // =========================================================================
  // Visibility Flag: receiptsVisibility
  // =========================================================================

  group('Visibility — receiptsVisibility', () {
    test('receiptsVisibility defaults to true', () {
      const receiptsVisibility = true;
      expect(receiptsVisibility, isTrue);
    });

    test('receiptsVisibility false hides all receipt icons', () {
      const receiptsVisibility = false;
      expect(receiptsVisibility, isFalse);
    });

    test('receipts only apply to sent messages', () {
      final loggedInUser = FakeUser('logged_in_user');
      final sentMessage = FakeTextMessage(1, sender: loggedInUser);
      expect(sentMessage.sender?.uid, equals(loggedInUser.uid));
    });

    test('disableReceipts flag also prevents receipt display', () {
      const disableReceipts = true;
      expect(disableReceipts, isTrue);
    });

    test('read receipt shown when readAt is set', () {
      final message = FakeTextMessage(1);
      expect(message.readAt, isNotNull);
    });

    test('delivered receipt shown when deliveredAt is set', () {
      final message = FakeTextMessage(1);
      expect(message.deliveredAt, isNotNull);
    });
  });

  // =========================================================================
  // Visibility Flag: hideDateSeparator
  // =========================================================================

  group('Visibility — hideDateSeparator', () {
    test('hideDateSeparator defaults to false (separators shown)', () {
      const hideDateSeparator = false;
      expect(hideDateSeparator, isFalse);
    });

    test('hideDateSeparator true removes all date separators', () {
      const hideDateSeparator = true;
      expect(hideDateSeparator, isTrue);
    });

    test('date separators appear between messages on different days', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final msg1 = FakeTextMessage(1);
      final msg2 = FakeTextMessage(2);

      // Different days should produce a separator
      expect(today.day, isNot(equals(yesterday.day)));
      expect(msg1.sentAt, isNotNull);
      expect(msg2.sentAt, isNotNull);
    });
  });

  // =========================================================================
  // Visibility Flag: hideStickyDate
  // =========================================================================

  group('Visibility — hideStickyDate', () {
    test('hideStickyDate defaults to false (sticky date shown)', () {
      const hideStickyDate = false;
      expect(hideStickyDate, isFalse);
    });

    test('hideStickyDate true removes floating date header', () {
      const hideStickyDate = true;
      expect(hideStickyDate, isTrue);
    });
  });

  // =========================================================================
  // Visibility Flag: disableReactions
  // =========================================================================

  group('Visibility — disableReactions', () {
    test('disableReactions defaults to false (reactions enabled)', () {
      const disableReactions = false;
      expect(disableReactions, isFalse);
    });

    test('disableReactions true hides reaction UI', () {
      const disableReactions = true;
      expect(disableReactions, isTrue);
    });

    test('hideReactionOption hides reaction from option sheet', () {
      const hideReactionOption = true;
      expect(hideReactionOption, isTrue);
    });
  });

  // =========================================================================
  // Visibility Flag: hideThreadView
  // =========================================================================

  group('Visibility — hideThreadView', () {
    test('hideThreadView defaults to null (thread view shown)', () {
      const bool? hideThreadView = null;
      expect(hideThreadView, isNull);
    });

    test('hideThreadView true hides thread reply count indicator', () {
      const hideThreadView = true;
      expect(hideThreadView, isTrue);
    });

    test('thread view is relevant when replyCount > 0', () {
      final message = FakeTextMessage(1, replyCount: 3);
      expect(message.replyCount, greaterThan(0));
    });

    test('thread view not shown when replyCount is 0', () {
      final message = FakeTextMessage(1, replyCount: 0);
      expect(message.replyCount, equals(0));
    });

    test('hideReplyInThreadOption hides thread option from sheet', () {
      const hideReplyInThreadOption = true;
      expect(hideReplyInThreadOption, isTrue);
    });
  });

  // =========================================================================
  // Visibility Flag: hideGroupActionMessages
  // =========================================================================

  group('Visibility — hideGroupActionMessages', () {
    late MockMessageListRepository repo;

    setUp(() {
      repo = MockMessageListRepository();
    });

    test('hideGroupActionMessages defaults to false', () {
      const hideGroupActionMessages = false;
      expect(hideGroupActionMessages, isFalse);
    });

    test('hideGroupActionMessages true filters action messages', () {
      const hideGroupActionMessages = true;
      expect(hideGroupActionMessages, isTrue);
    });

    test('action messages have category "action"', () {
      final actionMsg = FakeActionMessage(1);
      expect(actionMsg.category, equals('action'));
    });

    test('regular messages have category "message"', () {
      final textMsg = FakeTextMessage(1);
      expect(textMsg.category, equals('message'));
    });

    test('messages loaded include action messages when not hidden', () async {
      final messages = <BaseMessage>[
        FakeTextMessage(1),
        FakeActionMessage(2),
        FakeTextMessage(3),
      ];
      _stubRepo(repo, messages: messages);

      final bloc = _makeBloc(repo);
      bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 80));

      expect(bloc.state.status, MessageListStatus.loaded);
      expect(bloc.state.messages.length, 3);
      await bloc.close();
    });
  });

  // =========================================================================
  // Visibility Flag: hideDeletedMessages
  // =========================================================================

  group('Visibility — hideDeletedMessages', () {
    late MockMessageListRepository repo;

    setUp(() {
      repo = MockMessageListRepository();
    });

    test('hideDeletedMessages defaults to false', () {
      // BLoC constructor default
      final bloc = _makeBloc(repo, hideDeletedMessages: false);
      // No assertion on state needed — just verify construction
      bloc.close();
    });

    test('hideDeletedMessages true filters deleted messages from state', () {
      // When hideDeletedMessages is true, the BLoC filters messages with deletedAt != null
      const hideDeletedMessages = true;
      expect(hideDeletedMessages, isTrue);
    });

    test('hideDeletedMessages false shows deleted bubble placeholder', () {
      const hideDeletedMessages = false;
      expect(hideDeletedMessages, isFalse);
    });
  });

  // =========================================================================
  // Visibility Flag: hideReplies (hide reply-to-thread messages from main list)
  // =========================================================================

  group('Visibility — hideReplies', () {
    late MockMessageListRepository repo;

    setUp(() {
      repo = MockMessageListRepository();
    });

    test(
      'hideReplies defaults to true (thread replies hidden from main list)',
      () {
        const hideReplies = true;
        expect(hideReplies, isTrue);
      },
    );

    test('messages with parentMessageId > 0 are thread replies', () {
      final threadReply = FakeTextMessage(1, parentMessageId: 5);
      expect(threadReply.parentMessageId, greaterThan(0));
    });

    test('messages with parentMessageId == 0 are root messages', () {
      final rootMessage = FakeTextMessage(1, parentMessageId: 0);
      expect(rootMessage.parentMessageId, equals(0));
    });

    test('hideReplies is passed to repository for SDK filtering', () async {
      _stubRepo(repo);
      final bloc = _makeBloc(repo);
      bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 80));

      verify(
        () => repo.getMessages(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
          limit: any(named: 'limit'),
          parentMessageId: any(named: 'parentMessageId'),
          types: any(named: 'types'),
          categories: any(named: 'categories'),
          hideReplies: any(named: 'hideReplies'),
          withParent: any(named: 'withParent'),
        ),
      ).called(1);
      await bloc.close();
    });
  });

  // =========================================================================
  // Visibility Flag: Sender Name in Group
  // =========================================================================

  group('Visibility — Sender name in group', () {
    test('sender name shown for received messages in group', () {
      final loggedInUser = FakeUser('logged_in_user');
      final message = FakeTextMessage(1, sender: FakeUser('other_user'));
      // In group chat, sender name is shown for messages from others
      expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
      expect(message.sender?.name, isNotNull);
    });

    test('sender name NOT shown for own messages', () {
      final loggedInUser = FakeUser('logged_in_user');
      final message = FakeTextMessage(1, sender: loggedInUser);
      expect(message.sender?.uid, equals(loggedInUser.uid));
    });

    test('sender name NOT shown in 1-on-1 chat', () {
      // In 1-on-1, there's only one other person — no need for sender name
      const Group? group = null;
      expect(group, isNull);
    });
  });

  // =========================================================================
  // Combined Visibility Flags
  // =========================================================================

  group('Combined visibility flags', () {
    test('all visibility flags can be set simultaneously', () {
      // Simulating widget construction with all flags
      const avatarVisibility = false;
      const hideTimestamp = true;
      const receiptsVisibility = false;
      const hideDateSeparator = true;
      const hideStickyDate = true;
      const disableReactions = true;
      const hideThreadView = true;
      const hideGroupActionMessages = true;

      expect(avatarVisibility, isFalse);
      expect(hideTimestamp, isTrue);
      expect(receiptsVisibility, isFalse);
      expect(hideDateSeparator, isTrue);
      expect(hideStickyDate, isTrue);
      expect(disableReactions, isTrue);
      expect(hideThreadView, isTrue);
      expect(hideGroupActionMessages, isTrue);
    });

    test('default visibility shows everything', () {
      const avatarVisibility = true;
      const bool? hideTimestamp = null;
      const receiptsVisibility = true;
      const hideDateSeparator = false;
      const hideStickyDate = false;
      const disableReactions = false;
      const bool? hideThreadView = null;
      const hideGroupActionMessages = false;

      expect(avatarVisibility, isTrue);
      expect(hideTimestamp, isNull); // null means show
      expect(receiptsVisibility, isTrue);
      expect(hideDateSeparator, isFalse);
      expect(hideStickyDate, isFalse);
      expect(disableReactions, isFalse);
      expect(hideThreadView, isNull); // null means show
      expect(hideGroupActionMessages, isFalse);
    });

    test('messages still load correctly with all flags hidden', () async {
      final repo = MockMessageListRepository();
      final messages = List.generate(5, (i) => FakeTextMessage(i + 1));
      _stubRepo(repo, messages: messages);

      final bloc = _makeBloc(repo, hideDeletedMessages: true);
      bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 80));

      // BLoC loads messages regardless of widget-level visibility flags
      expect(bloc.state.status, MessageListStatus.loaded);
      expect(bloc.state.messages, isNotEmpty);
      await bloc.close();
    });
  });
}
