import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, setUpAll, tearDown, tearDownAll;
import 'package:mocktail/mocktail.dart' hide any;
import 'package:mocktail/mocktail.dart' as mt;

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
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/datasources/message_list_local_datasource.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

import 'generators/message_list_generators.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _MockMessageListRepository extends Mock
    implements MessageListRepository {}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'pbt_user';
}

class _FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_pbt_user';

  @override
  int get unreadMessageCount => 0;
}

MessageListBloc _makeBloc(
  _MockMessageListRepository repo, {
  List<BaseMessage> initial = const [],
}) {
  when(() => repo.getLoggedInUser())
      .thenAnswer((_) async => Success(_FakeUser()));
  when(() => repo.getMessages(
        conversationWith: mt.any(named: 'conversationWith'),
        conversationType: mt.any(named: 'conversationType'),
        limit: mt.any(named: 'limit'),
        parentMessageId: mt.any(named: 'parentMessageId'),
        types: mt.any(named: 'types'),
        categories: mt.any(named: 'categories'),
        hideReplies: mt.any(named: 'hideReplies'),
        withParent: mt.any(named: 'withParent'),
      )).thenAnswer((_) async => Success(initial));
  when(() => repo.getConversation(
        conversationWith: mt.any(named: 'conversationWith'),
        conversationType: mt.any(named: 'conversationType'),
      )).thenAnswer((_) async => Success(_FakeConversation()));

  return MessageListBloc(
    getMessagesUseCase: GetMessagesUseCase(repo),
    loadOlderMessagesUseCase: LoadOlderMessagesUseCase(repo),
    loadNewerMessagesUseCase: LoadNewerMessagesUseCase(repo),
    markAsReadUseCase: MarkAsReadUseCase(repo),
    markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
    markAsUnreadUseCase: MarkAsUnreadUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    user: _FakeUser(),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Property: O(1) lookup round-trip — findMessageIndex returns correct index
// for every message in the list after load.
// ---------------------------------------------------------------------------

Future<void> _propLookupRoundTrip(List<BaseMessage> messages) async {
  if (messages.isEmpty) return;

  final repo = _MockMessageListRepository();
  final bloc = _makeBloc(repo, initial: messages);

  bloc.add(const LoadMessages(
    conversationWith: 'pbt_user',
    conversationType: 'user',
  ));
  await Future<void>.delayed(const Duration(milliseconds: 80));

  for (var i = 0; i < bloc.state.messages.length; i++) {
    final msg = bloc.state.messages[i];
    final foundIndex = bloc.findMessageIndex(msg.id);
    expect(foundIndex, i,
        reason: 'findMessageIndex(${msg.id}) should return $i, got $foundIndex');
  }

  await bloc.close();
}

// ---------------------------------------------------------------------------
// Property: MessageReceived always appends to the end of the list
// (preserving existing order).
// ---------------------------------------------------------------------------

Future<void> _propMessageReceivedAppendsToEnd(
    List<BaseMessage> initial) async {
  if (initial.isEmpty) return;

  final repo = _MockMessageListRepository();
  final bloc = _makeBloc(repo, initial: initial);

  bloc.add(const LoadMessages(
    conversationWith: 'pbt_user',
    conversationType: 'user',
  ));
  await Future<void>.delayed(const Duration(milliseconds: 80));

  final newMsg = FakeBaseMessage(999999);
  bloc.add(MessageReceived(newMsg));
  await Future<void>.delayed(const Duration(milliseconds: 30));

  final state = bloc.state;
  expect(state.messages.last.id, 999999,
      reason: 'New message should be appended at end');

  // Existing messages should maintain their relative order
  for (var i = 0; i < initial.length; i++) {
    expect(state.messages[i].id, initial[i].id,
        reason: 'Existing message at index $i should be preserved');
  }

  await bloc.close();
}

// ---------------------------------------------------------------------------
// Property: findMessage returns null for non-existent IDs
// ---------------------------------------------------------------------------

Future<void> _propFindMessageNullForMissing(List<BaseMessage> messages) async {
  final repo = _MockMessageListRepository();
  final bloc = _makeBloc(repo, initial: messages);

  bloc.add(const LoadMessages(
    conversationWith: 'pbt_user',
    conversationType: 'user',
  ));
  await Future<void>.delayed(const Duration(milliseconds: 80));

  // Use an ID that's guaranteed not to be in the list
  final maxId = messages.fold<int>(0, (max, m) => m.id > max ? m.id : max);
  final result = bloc.findMessage(maxId + 1000);
  expect(result, isNull,
      reason: 'findMessage for non-existent ID should return null');

  await bloc.close();
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUser());
    registerFallbackValue(FakeBaseMessage(0));
  });

  // -------------------------------------------------------------------------
  // MessageListLocalDataSource (in-memory cache) — pure invariants
  // -------------------------------------------------------------------------

  group('MessageListLocalDataSource — properties', () {
    Glados2(
      any.intInRange(1, 30),
      any.listWithLengthInRange(0, 20, any.intInRange(1, 1000)),
    ).test(
      'cacheMessages then getCachedMessages returns all cached messages',
      (_, messageIds) async {
        final ds = MessageListLocalDataSourceImpl();
        final messages = messageIds
            .toSet()
            .map((id) => FakeBaseMessage(id) as BaseMessage)
            .toList();

        await ds.cacheMessages('conv_1', messages);
        final cached = await ds.getCachedMessages('conv_1');

        expect(cached.length, messages.length,
            reason: 'All cached messages should be retrievable');
      },
    );

    Glados(any.intInRange(1, 1000)).test(
      'removeCachedMessage then getCachedMessage returns null',
      (messageId) async {
        final ds = MessageListLocalDataSourceImpl();
        final msg = FakeBaseMessage(messageId);

        await ds.cacheMessage('conv_1', msg);
        await ds.removeCachedMessage('conv_1', messageId);
        final result = await ds.getCachedMessage('conv_1', messageId);

        expect(result, isNull);
      },
    );

    Glados(any.listWithLengthInRange(0, 15, any.intInRange(1, 500))).test(
      'clearCache removes all messages for conversation',
      (messageIds) async {
        final ds = MessageListLocalDataSourceImpl();
        final messages = messageIds
            .toSet()
            .map((id) => FakeBaseMessage(id) as BaseMessage)
            .toList();

        await ds.cacheMessages('conv_1', messages);
        await ds.clearCache('conv_1');
        final hasCached = await ds.hasCachedData('conv_1');

        expect(hasCached, isFalse);
      },
    );
  });

  // -------------------------------------------------------------------------
  // MessageListBloc — public-API properties
  // Each run spins up a real bloc + async event dispatch, so we use a reduced
  // numRuns (30 instead of default 100) to keep CI wall-clock reasonable.
  // -------------------------------------------------------------------------

  group('MessageListBloc — properties', () {
    final fast = ExploreConfig(numRuns: 30);

    Glados(distinctMessagesGen(maxLength: 8), fast).test(
      'O(1) lookup round-trip: findMessageIndex returns correct index for all messages',
      (messages) async {
        await _propLookupRoundTrip(messages);
      },
    );

    Glados(distinctMessagesGen(maxLength: 6), fast).test(
      'MessageReceived appends to end and preserves existing order',
      (messages) async {
        await _propMessageReceivedAppendsToEnd(messages);
      },
    );

    Glados(distinctMessagesGen(maxLength: 8), fast).test(
      'findMessage returns null for non-existent IDs',
      (messages) async {
        await _propFindMessageNullForMissing(messages);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Receipt notifier — properties
  // -------------------------------------------------------------------------

  group('Receipt notifier — properties', () {
    Glados(any.intInRange(1, 10000)).test(
      'getReceiptNotifier is idempotent — same ID returns same instance',
      (messageId) {
        final repo = _MockMessageListRepository();
        final bloc = _makeBloc(repo);

        final a = bloc.getReceiptNotifier(messageId);
        final b = bloc.getReceiptNotifier(messageId);

        expect(identical(a, b), isTrue,
            reason: 'Same messageId should return same notifier instance');

        bloc.close();
      },
    );

    Glados2(any.intInRange(1, 10000), any.intInRange(1, 10000)).test(
      'different IDs return different notifier instances',
      (id1, id2) {
        if (id1 == id2) return; // skip when same

        final repo = _MockMessageListRepository();
        final bloc = _makeBloc(repo);

        final a = bloc.getReceiptNotifier(id1);
        final b = bloc.getReceiptNotifier(id2);

        expect(identical(a, b), isFalse,
            reason: 'Different messageIds should return different notifiers');

        bloc.close();
      },
    );
  });

  // -------------------------------------------------------------------------
  // Typing notifier — properties
  // -------------------------------------------------------------------------

  group('Typing notifier — properties', () {
    Glados(any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s)).test(
      'getTypingNotifier returns same instance for same conversation ID',
      (convId) {
        final repo = _MockMessageListRepository();
        final bloc = _makeBloc(repo);

        final a = bloc.getTypingNotifier(convId);
        final b = bloc.getTypingNotifier(convId);

        expect(identical(a, b), isTrue);
        expect(a.value, isEmpty);

        bloc.close();
      },
    );
  });

  // -------------------------------------------------------------------------
  // Thread reply count notifier — properties
  // -------------------------------------------------------------------------

  group('Thread reply count notifier — properties', () {
    Glados2(any.intInRange(1, 10000), any.intInRange(0, 100)).test(
      'initializeThreadReplyCount sets correct value',
      (parentId, count) {
        final repo = _MockMessageListRepository();
        final bloc = _makeBloc(repo);

        bloc.initializeThreadReplyCount(parentId, count);
        expect(bloc.getThreadReplyCount(parentId), count);

        bloc.close();
      },
    );
  });
}
