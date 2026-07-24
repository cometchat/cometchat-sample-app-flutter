import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/get_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/load_older_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/load_newer_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_read_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_delivered_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_unread_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/repositories/message_list_repository.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageListRepository extends Mock implements MessageListRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';
}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_group';
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _muid;
  final int _parentMessageId;

  FakeTextMessage(this._id, {String? muid, int parentMessageId = 0})
    : _muid = muid ?? 'muid_$_id',
      _parentMessageId = parentMessageId;

  @override
  int get id => _id;

  @override
  String get muid => _muid;

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  User? get sender => FakeUser();

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}

  @override
  String get receiverUid => 'test_user';

  @override
  String get receiverType => 'user';

  @override
  String? get conversationId => 'user_test_user';

  @override
  BaseMessage? get quotedMessage => null;

  @override
  String get text => 'hello';

  @override
  List<ReactionCount> get reactions => [];

  @override
  Map<String, dynamic>? get metadata => null;
}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  FakeBaseMessage(this._id);

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  int get parentMessageId => 0;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  User? get sender => FakeUser();

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_test_user';

  @override
  int get unreadMessageCount => 0;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageListBloc _makeBloc(MockMessageListRepository repo, {User? user}) {
  return MessageListBloc(
    getMessagesUseCase: GetMessagesUseCase(repo),
    loadOlderMessagesUseCase: LoadOlderMessagesUseCase(repo),
    loadNewerMessagesUseCase: LoadNewerMessagesUseCase(repo),
    markAsReadUseCase: MarkAsReadUseCase(repo),
    markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
    markAsUnreadUseCase: MarkAsUnreadUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    user: user ?? FakeUser(),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseMessage(0));
    registerFallbackValue(FakeMessagesRequest());
    registerFallbackValue(FakeConversation());
  });

  group('MessageListBloc', () {
    late MockMessageListRepository repo;

    setUp(() {
      repo = MockMessageListRepository();
      // Default stubs
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
      ).thenAnswer((_) async => const Success([]));
      when(
        () => repo.getConversation(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
        ),
      ).thenAnswer((_) async => Success(FakeConversation()));
      when(
        () => repo.markAsRead(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repo.markAsDelivered(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    test('initial state has status initial', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageListStatus.initial);
      expect(bloc.state.messages, isEmpty);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadMessages
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'emits [loading, empty] when no messages returned',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      ),
      expect: () => [
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.loading,
        ),
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.empty,
        ),
      ],
    );

    blocTest<MessageListBloc, MessageListState>(
      'emits [loading, loaded] when messages returned',
      build: () {
        final msgs = [FakeTextMessage(1), FakeTextMessage(2)];
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
        ).thenAnswer((_) async => Success(msgs));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      ),
      expect: () => [
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.loading,
        ),
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.loaded,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.messages.length, 2);
      },
    );

    blocTest<MessageListBloc, MessageListState>(
      'emits [loading, error] when repository fails',
      build: () {
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
        ).thenAnswer(
          (_) async => const Failure(message: 'Network error', code: 'NET_ERR'),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      ),
      expect: () => [
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.loading,
        ),
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.error,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.errorMessage, 'Network error');
      },
    );

    // -----------------------------------------------------------------------
    // MessageReceived
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'adds incoming message to loaded state',
      build: () {
        final msgs = [FakeTextMessage(1)];
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
        ).thenAnswer((_) async => Success(msgs));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(
          const LoadMessages(
            conversationWith: 'test_user',
            conversationType: 'user',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(MessageReceived(FakeTextMessage(2)));
      },
      verify: (bloc) {
        expect(bloc.state.messages.length, 2);
      },
    );

    // -----------------------------------------------------------------------
    // MessageDeleted
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'removes message from list when hideDeletedMessages is true',
      build: () {
        final msgs = [FakeTextMessage(1), FakeTextMessage(2)];
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
        ).thenAnswer((_) async => Success(msgs));
        return MessageListBloc(
          getMessagesUseCase: GetMessagesUseCase(repo),
          loadOlderMessagesUseCase: LoadOlderMessagesUseCase(repo),
          loadNewerMessagesUseCase: LoadNewerMessagesUseCase(repo),
          markAsReadUseCase: MarkAsReadUseCase(repo),
          markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
          markAsUnreadUseCase: MarkAsUnreadUseCase(repo),
          getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
          user: FakeUser(),
          hideDeletedMessages: true,
          disableSDKListeners: true,
        );
      },
      act: (bloc) async {
        bloc.add(
          const LoadMessages(
            conversationWith: 'test_user',
            conversationType: 'user',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(MessageDeleted(FakeTextMessage(1)));
      },
      verify: (bloc) {
        expect(bloc.state.messages.length, 1);
        expect(bloc.state.messages.first.id, 2);
      },
    );

    // -----------------------------------------------------------------------
    // SetActiveConversation
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'updates activeConversationId in state',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const SetActiveConversation('user_test_user')),
      verify: (bloc) {
        expect(bloc.state.activeConversationId, 'user_test_user');
      },
    );

    // -----------------------------------------------------------------------
    // ForceEmptyState
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'ForceEmptyState transitions to empty without loading',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ForceEmptyState()),
      expect: () => [
        isA<MessageListState>().having(
          (s) => s.status,
          'status',
          MessageListStatus.empty,
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // ResetUnreadState
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'ResetUnreadState clears unread anchor and count',
      build: () {
        final msgs = [FakeTextMessage(1)];
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
        ).thenAnswer((_) async => Success(msgs));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(
          const LoadMessages(
            conversationWith: 'test_user',
            conversationType: 'user',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ResetUnreadState());
      },
      verify: (bloc) {
        expect(bloc.state.unreadMessageAnchor, isNull);
        expect(bloc.state.unreadCount, 0);
      },
    );

    // -----------------------------------------------------------------------
    // ValueNotifier accessors
    // -----------------------------------------------------------------------

    test('getReceiptNotifier returns same notifier for same id', () {
      final bloc = _makeBloc(repo);
      final a = bloc.getReceiptNotifier(1);
      final b = bloc.getReceiptNotifier(1);
      expect(identical(a, b), isTrue);
      bloc.close();
    });

    test('getTypingNotifier returns same notifier for same id', () {
      final bloc = _makeBloc(repo);
      final a = bloc.getTypingNotifier('user_test');
      final b = bloc.getTypingNotifier('user_test');
      expect(identical(a, b), isTrue);
      expect(a.value, isEmpty);
      bloc.close();
    });

    test('getThreadReplyCountNotifier returns same notifier for same id', () {
      final bloc = _makeBloc(repo);
      final a = bloc.getThreadReplyCountNotifier(1);
      final b = bloc.getThreadReplyCountNotifier(1);
      expect(identical(a, b), isTrue);
      expect(a.value, 0);
      bloc.close();
    });

    test('initializeThreadReplyCount sets value on notifier', () {
      final bloc = _makeBloc(repo);
      bloc.initializeThreadReplyCount(42, 5);
      expect(bloc.getThreadReplyCount(42), 5);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // O(1) lookup methods
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'findMessageIndex returns correct index after load',
      build: () {
        final msgs = [
          FakeTextMessage(10),
          FakeTextMessage(20),
          FakeTextMessage(30),
        ];
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
        ).thenAnswer((_) async => Success(msgs));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const LoadMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        ),
      ),
      verify: (bloc) {
        expect(bloc.findMessageIndex(20), 1);
        expect(bloc.findMessageIndex(999), isNull);
      },
    );

    // -----------------------------------------------------------------------
    // Computed properties
    // -----------------------------------------------------------------------

    test('conversationId returns user_uid for user conversations', () {
      final bloc = _makeBloc(repo, user: FakeUser());
      expect(bloc.conversationId, 'user_test_user');
      bloc.close();
    });

    test('conversationType returns user for user conversations', () {
      final bloc = _makeBloc(repo, user: FakeUser());
      expect(bloc.conversationType, 'user');
      bloc.close();
    });

    test('conversationWith returns uid for user conversations', () {
      final bloc = _makeBloc(repo, user: FakeUser());
      expect(bloc.conversationWith, 'test_user');
      bloc.close();
    });
  });
}
