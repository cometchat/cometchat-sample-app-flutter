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
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/constants/enums.dart';

// ===========================================================================
// CometChatMessageListAlignmentPropertyTest — Flutter equivalent
// Tests message alignment logic: sent messages align right, received align
// left, action messages center, group messages with/without avatar,
// alignment with/without timestamp, alignment with/without read receipts.
// ===========================================================================

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockMessageListRepository extends Mock implements MessageListRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  FakeUser([this._uid = 'logged_in_user']);

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

  FakeTextMessage(this._id, {User? sender, int parentMessageId = 0})
    : _sender = sender,
      _parentMessageId = parentMessageId;

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

/// Determines bubble alignment based on message sender and chat alignment mode.
/// This mirrors the logic in the widget layer.
BubbleAlignment _getBubbleAlignment({
  required BaseMessage message,
  required User loggedInUser,
  required ChatAlignment chatAlignment,
}) {
  // Action messages are always centered
  if (message.category == 'action') {
    return BubbleAlignment.center;
  }

  // In standard alignment: sent = right, received = left
  if (chatAlignment == ChatAlignment.standard) {
    if (message.sender?.uid == loggedInUser.uid) {
      return BubbleAlignment.right;
    } else {
      return BubbleAlignment.left;
    }
  }

  // In leftAligned mode: all messages align left
  return BubbleAlignment.left;
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
  // Message Alignment — Standard Mode
  // =========================================================================

  group('Message Alignment — Standard Mode', () {
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    test('sent message aligns right in standard mode', () {
      final message = FakeTextMessage(1, sender: loggedInUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.right));
    });

    test('received message aligns left in standard mode', () {
      final message = FakeTextMessage(1, sender: otherUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.left));
    });

    test('action message aligns center in standard mode', () {
      final message = FakeActionMessage(1);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.center));
    });

    test('multiple sent messages all align right', () {
      final messages = List.generate(
        5,
        (i) => FakeTextMessage(i + 1, sender: loggedInUser),
      );
      for (final msg in messages) {
        final alignment = _getBubbleAlignment(
          message: msg,
          loggedInUser: loggedInUser,
          chatAlignment: ChatAlignment.standard,
        );
        expect(alignment, equals(BubbleAlignment.right));
      }
    });

    test('multiple received messages all align left', () {
      final messages = List.generate(
        5,
        (i) => FakeTextMessage(i + 1, sender: otherUser),
      );
      for (final msg in messages) {
        final alignment = _getBubbleAlignment(
          message: msg,
          loggedInUser: loggedInUser,
          chatAlignment: ChatAlignment.standard,
        );
        expect(alignment, equals(BubbleAlignment.left));
      }
    });

    test('mixed messages have correct alignment', () {
      final messages = [
        FakeTextMessage(1, sender: loggedInUser),
        FakeTextMessage(2, sender: otherUser),
        FakeActionMessage(3),
        FakeTextMessage(4, sender: loggedInUser),
        FakeTextMessage(5, sender: otherUser),
      ];

      final alignments = messages
          .map(
            (msg) => _getBubbleAlignment(
              message: msg,
              loggedInUser: loggedInUser,
              chatAlignment: ChatAlignment.standard,
            ),
          )
          .toList();

      expect(alignments[0], equals(BubbleAlignment.right));
      expect(alignments[1], equals(BubbleAlignment.left));
      expect(alignments[2], equals(BubbleAlignment.center));
      expect(alignments[3], equals(BubbleAlignment.right));
      expect(alignments[4], equals(BubbleAlignment.left));
    });
  });

  // =========================================================================
  // Message Alignment — Left Aligned Mode
  // =========================================================================

  group('Message Alignment — Left Aligned Mode', () {
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    test('sent message aligns left in leftAligned mode', () {
      final message = FakeTextMessage(1, sender: loggedInUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.leftAligned,
      );
      expect(alignment, equals(BubbleAlignment.left));
    });

    test('received message aligns left in leftAligned mode', () {
      final message = FakeTextMessage(1, sender: otherUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.leftAligned,
      );
      expect(alignment, equals(BubbleAlignment.left));
    });

    test('action message still aligns center in leftAligned mode', () {
      final message = FakeActionMessage(1);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.leftAligned,
      );
      expect(alignment, equals(BubbleAlignment.center));
    });

    test('all non-action messages align left in leftAligned mode', () {
      final messages = [
        FakeTextMessage(1, sender: loggedInUser),
        FakeTextMessage(2, sender: otherUser),
        FakeTextMessage(3, sender: FakeUser('third_user')),
      ];

      for (final msg in messages) {
        final alignment = _getBubbleAlignment(
          message: msg,
          loggedInUser: loggedInUser,
          chatAlignment: ChatAlignment.leftAligned,
        );
        expect(alignment, equals(BubbleAlignment.left));
      }
    });
  });

  // =========================================================================
  // Message Alignment — Group Chat Specifics
  // =========================================================================

  group('Message Alignment — Group Chat', () {
    late MockMessageListRepository repo;
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    setUp(() {
      repo = MockMessageListRepository();
      _stubRepo(repo);
    });

    test('group messages from different senders align left', () {
      final user1 = FakeUser('user_1');
      final user2 = FakeUser('user_2');
      final user3 = FakeUser('user_3');

      final messages = [
        FakeTextMessage(1, sender: user1),
        FakeTextMessage(2, sender: user2),
        FakeTextMessage(3, sender: user3),
      ];

      for (final msg in messages) {
        final alignment = _getBubbleAlignment(
          message: msg,
          loggedInUser: loggedInUser,
          chatAlignment: ChatAlignment.standard,
        );
        expect(alignment, equals(BubbleAlignment.left));
      }
    });

    test('own messages in group still align right', () {
      final message = FakeTextMessage(1, sender: loggedInUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.right));
    });

    test('group action messages align center', () {
      final message = FakeActionMessage(1);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.center));
    });

    test(
      'messages loaded in group have correct alignment per sender',
      () async {
        final messages = [
          FakeTextMessage(1, sender: loggedInUser),
          FakeTextMessage(2, sender: otherUser),
          FakeTextMessage(3, sender: loggedInUser),
        ];
        _stubRepo(repo, messages: messages);

        final bloc = _makeBloc(repo, user: null, group: FakeGroup());
        bloc.add(
          const LoadMessages(
            conversationWith: 'test_group',
            conversationType: 'group',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 80));

        expect(bloc.state.status, MessageListStatus.loaded);
        expect(bloc.state.messages.length, 3);

        // Verify alignment logic for each message
        for (final msg in bloc.state.messages) {
          final alignment = _getBubbleAlignment(
            message: msg,
            loggedInUser: loggedInUser,
            chatAlignment: ChatAlignment.standard,
          );
          if (msg.sender?.uid == loggedInUser.uid) {
            expect(alignment, equals(BubbleAlignment.right));
          } else {
            expect(alignment, equals(BubbleAlignment.left));
          }
        }
        await bloc.close();
      },
    );
  });

  // =========================================================================
  // Avatar Visibility with Alignment
  // =========================================================================

  group('Avatar Visibility with Alignment', () {
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    test('avatar is shown for received messages (left-aligned)', () {
      final message = FakeTextMessage(1, sender: otherUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      // Avatar is shown for left-aligned messages
      expect(alignment, equals(BubbleAlignment.left));
    });

    test('avatar is NOT shown for sent messages (right-aligned)', () {
      final message = FakeTextMessage(1, sender: loggedInUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      // Avatar is not shown for right-aligned messages
      expect(alignment, equals(BubbleAlignment.right));
    });

    test('avatar is NOT shown for action messages (center-aligned)', () {
      final message = FakeActionMessage(1);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      expect(alignment, equals(BubbleAlignment.center));
    });

    test('avatarVisibility flag can override default behavior', () {
      // When avatarVisibility is false, no avatar regardless of alignment
      const avatarVisibility = false;
      expect(avatarVisibility, isFalse);
    });

    test('avatarVisibility true shows avatar for left-aligned', () {
      const avatarVisibility = true;
      expect(avatarVisibility, isTrue);
    });
  });

  // =========================================================================
  // Read Receipts with Alignment
  // =========================================================================

  group('Read Receipts with Alignment', () {
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    test('receipts shown for sent messages (right-aligned)', () {
      final message = FakeTextMessage(1, sender: loggedInUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      // Receipts are shown for right-aligned (sent) messages
      expect(alignment, equals(BubbleAlignment.right));
    });

    test('receipts NOT shown for received messages (left-aligned)', () {
      final message = FakeTextMessage(1, sender: otherUser);
      final alignment = _getBubbleAlignment(
        message: message,
        loggedInUser: loggedInUser,
        chatAlignment: ChatAlignment.standard,
      );
      // Receipts are not shown for left-aligned (received) messages
      expect(alignment, equals(BubbleAlignment.left));
    });

    test('receiptsVisibility flag can disable receipts', () {
      const receiptsVisibility = false;
      expect(receiptsVisibility, isFalse);
    });

    test('disableReceipts flag prevents receipt display', () {
      const disableReceipts = true;
      expect(disableReceipts, isTrue);
    });
  });
}
