import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/datasources/message_list_remote_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/repositories/message_list_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock
    implements MessageListRemoteDataSource {}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  FakeBaseMessage([this._id = 1]);

  @override
  int get id => _id;
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'conv_1';
}

class FakeGetMessagesResult extends Fake implements GetMessagesResult {
  final List<BaseMessage> _messages;
  FakeGetMessagesResult(this._messages);

  @override
  List<BaseMessage> get messages => _messages;

  @override
  MessagesRequest get request => FakeMessagesRequest();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late MessageListRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeBaseMessage());
    registerFallbackValue(FakeMessagesRequest());
    registerFallbackValue(FakeConversation());
  });

  setUp(() {
    remote = MockRemoteDataSource();
    repo = MessageListRepositoryImpl(remoteDataSource: remote);
  });

  // =========================================================================
  // getMessages
  // =========================================================================

  group('getMessages', () {
    test('returns success with messages from remote', () async {
      final messages = [FakeBaseMessage(1), FakeBaseMessage(2)];
      when(() => remote.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => FakeGetMessagesResult(messages));

      final result = await repo.getMessages(
        conversationWith: 'uid123',
        conversationType: 'user',
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenThrow(MessageListRemoteDataSourceException(
        message: 'Network error',
        code: 'NET_ERR',
      ));

      final result = await repo.getMessages(
        conversationWith: 'uid123',
        conversationType: 'user',
      );

      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'NET_ERR'));
    });

    test('passes all params to remote data source', () async {
      when(() => remote.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            parentMessageId: any(named: 'parentMessageId'),
            types: any(named: 'types'),
            categories: any(named: 'categories'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => FakeGetMessagesResult([]));

      await repo.getMessages(
        conversationWith: 'uid123',
        conversationType: 'user',
        limit: 20,
        parentMessageId: 5,
        types: ['text'],
        categories: ['message'],
        hideReplies: false,
      );

      verify(() => remote.getMessages(
            conversationWith: 'uid123',
            conversationType: 'user',
            limit: 20,
            parentMessageId: 5,
            types: ['text'],
            categories: ['message'],
            hideReplies: false,
          )).called(1);
    });
  });

  // =========================================================================
  // fetchPreviousMessages
  // =========================================================================

  group('fetchPreviousMessages', () {
    test('returns success with messages', () async {
      final request = FakeMessagesRequest();
      final messages = [FakeBaseMessage(10), FakeBaseMessage(11)];
      when(() => remote.fetchPreviousMessages(request: any(named: 'request')))
          .thenAnswer((_) async => messages);

      final result = await repo.fetchPreviousMessages(request: request);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when remote throws', () async {
      final request = FakeMessagesRequest();
      when(() => remote.fetchPreviousMessages(request: any(named: 'request')))
          .thenThrow(MessageListRemoteDataSourceException(
        message: 'Fetch failed',
        code: 'FETCH_ERR',
      ));

      final result = await repo.fetchPreviousMessages(request: request);

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // fetchNextMessages
  // =========================================================================

  group('fetchNextMessages', () {
    test('returns success with messages', () async {
      final request = FakeMessagesRequest();
      final messages = [FakeBaseMessage(20)];
      when(() => remote.fetchNextMessages(request: any(named: 'request')))
          .thenAnswer((_) async => messages);

      final result = await repo.fetchNextMessages(request: request);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 1));
    });
  });

  // =========================================================================
  // markAsRead
  // =========================================================================

  group('markAsRead', () {
    test('returns success when remote succeeds', () async {
      final msg = FakeBaseMessage(5);
      when(() => remote.markAsRead(any())).thenAnswer((_) async {});

      final result = await repo.markAsRead(msg);
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      final msg = FakeBaseMessage(5);
      when(() => remote.markAsRead(any()))
          .thenThrow(MessageListRemoteDataSourceException(
        message: 'Mark read failed',
        code: 'READ_ERR',
      ));

      final result = await repo.markAsRead(msg);
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // markAsDelivered
  // =========================================================================

  group('markAsDelivered', () {
    test('returns success when remote succeeds', () async {
      final msg = FakeBaseMessage(5);
      when(() => remote.markAsDelivered(any())).thenAnswer((_) async {});

      final result = await repo.markAsDelivered(msg);
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      final msg = FakeBaseMessage(5);
      when(() => remote.markAsDelivered(any()))
          .thenThrow(MessageListRemoteDataSourceException(
        message: 'Mark delivered failed',
      ));

      final result = await repo.markAsDelivered(msg);
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns success with user', () async {
      when(() => remote.getLoggedInUser()).thenAnswer((_) async => null);

      final result = await repo.getLoggedInUser();
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getLoggedInUser())
          .thenThrow(MessageListRemoteDataSourceException(
        message: 'Not logged in',
        code: 'AUTH_ERR',
      ));

      final result = await repo.getLoggedInUser();
      expect(result.isFailure, isTrue);
    });
  });
}
