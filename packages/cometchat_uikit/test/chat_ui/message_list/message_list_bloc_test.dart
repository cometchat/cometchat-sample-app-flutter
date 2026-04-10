import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
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

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageListRepository extends Mock implements MessageListRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';
  @override
  String get name => 'Test User';
}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  final String _muid;
  FakeBaseMessage({int id = 1, String muid = 'muid_1'})
      : _id = id,
        _muid = muid;

  @override
  int get id => _id;

  @override
  String get muid => _muid;

  @override
  String get receiverUid => 'test_user';

  @override
  String get receiverType => 'user';

  @override
  int get parentMessageId => 0;

  @override
  int get replyCount => 0;
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_test_user';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageListBloc _makeBloc(MockMessageListRepository repo) {
  return MessageListBloc(
    getMessagesUseCase: GetMessagesUseCase(repo),
    loadOlderMessagesUseCase: LoadOlderMessagesUseCase(repo),
    loadNewerMessagesUseCase: LoadNewerMessagesUseCase(repo),
    markAsReadUseCase: MarkAsReadUseCase(repo),
    markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
    markAsUnreadUseCase: MarkAsUnreadUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    user: FakeUser(),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseMessage());
    registerFallbackValue(FakeMessagesRequest());
    registerFallbackValue(FakeConversation());
    registerFallbackValue(FakeUser());
  });

  group('MessageListBloc', () {
    late MockMessageListRepository repo;

    setUp(() {
      repo = MockMessageListRepository();
      when(() => repo.getLoggedInUser())
          .thenAnswer((_) async => Success(FakeUser()));
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => const Success([]));
      when(() => repo.getConversation(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
          )).thenAnswer((_) async => Success(FakeConversation()));
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state has status initial and empty messages', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageListStatus.initial);
      expect(bloc.state.messages, isEmpty);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadMessages
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'emits loading then empty when no messages returned',
      build: () {
        when(() => repo.getMessages(
              conversationWith: any(named: 'conversationWith'),
              conversationType: any(named: 'conversationType'),
              limit: any(named: 'limit'),
              hideReplies: any(named: 'hideReplies'),
            )).thenAnswer((_) async => const Success([]));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      )),
      expect: () => [
        predicate<MessageListState>((s) => s.status == MessageListStatus.loading),
        predicate<MessageListState>((s) => s.status == MessageListStatus.empty),
      ],
    );

    blocTest<MessageListBloc, MessageListState>(
      'emits error status when repository fails',
      build: () {
        when(() => repo.getMessages(
              conversationWith: any(named: 'conversationWith'),
              conversationType: any(named: 'conversationType'),
              limit: any(named: 'limit'),
              hideReplies: any(named: 'hideReplies'),
            )).thenAnswer((_) async =>
            const Failure(message: 'Network error', code: 'NET_ERR'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      )),
      expect: () => [
        predicate<MessageListState>((s) => s.status == MessageListStatus.loading),
        predicate<MessageListState>(
            (s) => s.status == MessageListStatus.error && s.errorMessage != null),
      ],
    );

    // -----------------------------------------------------------------------
    // SetActiveConversation
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'updates activeConversationId',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const SetActiveConversation('conv_123')),
      verify: (bloc) {
        expect(bloc.state.activeConversationId, 'conv_123');
      },
    );

    // -----------------------------------------------------------------------
    // MarkMessageAsRead
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'MarkMessageAsRead calls repository',
      build: () {
        when(() => repo.markAsRead(any()))
            .thenAnswer((_) async => const Success(null));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(MarkMessageAsRead(FakeBaseMessage(id: 5))),
      verify: (bloc) {
        verify(() => repo.markAsRead(any())).called(1);
      },
    );

    // -----------------------------------------------------------------------
    // ResetUnreadState
    // -----------------------------------------------------------------------

    blocTest<MessageListBloc, MessageListState>(
      'ResetUnreadState clears unread fields',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ResetUnreadState()),
      verify: (bloc) {
        expect(bloc.state.unreadCount, 0);
        expect(bloc.state.markedAsUnreadInSession, isFalse);
      },
    );

    // -----------------------------------------------------------------------
    // ValueNotifier: receipt notifiers
    // -----------------------------------------------------------------------

    test('getReceiptNotifier returns a ValueNotifier for a message id', () {
      final bloc = _makeBloc(repo);
      final notifier = bloc.getReceiptNotifier(42);
      expect(notifier, isA<ValueNotifier<MessageReceiptStatus>>());
      bloc.close();
    });

    test('getReceiptNotifier returns same notifier for same id', () {
      final bloc = _makeBloc(repo);
      final n1 = bloc.getReceiptNotifier(42);
      final n2 = bloc.getReceiptNotifier(42);
      expect(identical(n1, n2), isTrue);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // findMessageIndex (O(1) lookup)
    // -----------------------------------------------------------------------

    test('findMessageIndex returns null for unknown id', () {
      final bloc = _makeBloc(repo);
      expect(bloc.findMessageIndex(9999), isNull);
      bloc.close();
    });
  });
}
