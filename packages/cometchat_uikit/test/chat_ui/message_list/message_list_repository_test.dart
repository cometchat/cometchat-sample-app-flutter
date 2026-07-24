import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/datasources/message_list_remote_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/datasources/message_list_local_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/data/repositories/message_list_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockRemoteDataSource extends Mock
    implements MessageListRemoteDataSource {}

class MockLocalDataSource extends Mock implements MessageListLocalDataSource {}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';
}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  FakeBaseMessage(this._id);

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  DateTime? get sentAt => DateTime.now();
}

class FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_test_user';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MessageListRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeBaseMessage(0));
    registerFallbackValue(FakeMessagesRequest());
  });

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    repo = MessageListRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
  });

  // =========================================================================
  // getMessages
  // =========================================================================

  group('getMessages', () {
    test('returns success with messages from remote', () async {
      final messages = [FakeBaseMessage(1), FakeBaseMessage(2)];
      when(
        () => remote.getMessages(
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
        (_) async => GetMessagesResult(
          request: FakeMessagesRequest(),
          messages: messages,
        ),
      );
      when(() => local.cacheMessages(any(), any())).thenAnswer((_) async {});

      final result = await repo.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('caches messages after successful remote fetch', () async {
      final messages = [FakeBaseMessage(1)];
      when(
        () => remote.getMessages(
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
        (_) async => GetMessagesResult(
          request: FakeMessagesRequest(),
          messages: messages,
        ),
      );
      when(() => local.cacheMessages(any(), any())).thenAnswer((_) async {});

      await repo.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      verify(() => local.cacheMessages('user_test_user', messages)).called(1);
    });

    test('does not cache when messages are empty', () async {
      when(
        () => remote.getMessages(
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
        (_) async =>
            GetMessagesResult(request: FakeMessagesRequest(), messages: []),
      );

      await repo.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      verifyNever(() => local.cacheMessages(any(), any()));
    });

    test('falls back to cache when remote fails', () async {
      final cached = [FakeBaseMessage(10)];
      when(
        () => remote.getMessages(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
          limit: any(named: 'limit'),
          parentMessageId: any(named: 'parentMessageId'),
          types: any(named: 'types'),
          categories: any(named: 'categories'),
          hideReplies: any(named: 'hideReplies'),
          withParent: any(named: 'withParent'),
        ),
      ).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Network error'),
      );
      when(
        () => local.getCachedMessages(any()),
      ).thenAnswer((_) async => cached);

      final result = await repo.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 1));
    });

    test('returns failure when both remote and cache fail', () async {
      when(
        () => remote.getMessages(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
          limit: any(named: 'limit'),
          parentMessageId: any(named: 'parentMessageId'),
          types: any(named: 'types'),
          categories: any(named: 'categories'),
          hideReplies: any(named: 'hideReplies'),
          withParent: any(named: 'withParent'),
        ),
      ).thenThrow(
        const MessageListRemoteDataSourceException(
          message: 'Network error',
          code: 'NET_ERR',
        ),
      );
      when(() => local.getCachedMessages(any())).thenAnswer((_) async => []);

      final result = await repo.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      // Empty cache is treated as no fallback available
      expect(result.isFailure, isTrue);
    });

    test('builds correct conversation ID for user type', () async {
      final messages = [FakeBaseMessage(1)];
      when(
        () => remote.getMessages(
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
        (_) async => GetMessagesResult(
          request: FakeMessagesRequest(),
          messages: messages,
        ),
      );
      when(() => local.cacheMessages(any(), any())).thenAnswer((_) async {});

      await repo.getMessages(
        conversationWith: 'uid123',
        conversationType: 'user',
      );

      verify(() => local.cacheMessages('user_uid123', any())).called(1);
    });

    test('builds correct conversation ID for group type', () async {
      final messages = [FakeBaseMessage(1)];
      when(
        () => remote.getMessages(
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
        (_) async => GetMessagesResult(
          request: FakeMessagesRequest(),
          messages: messages,
        ),
      );
      when(() => local.cacheMessages(any(), any())).thenAnswer((_) async {});

      await repo.getMessages(
        conversationWith: 'guid456',
        conversationType: 'group',
      );

      verify(() => local.cacheMessages('group_guid456', any())).called(1);
    });
  });

  // =========================================================================
  // fetchPreviousMessages
  // =========================================================================

  group('fetchPreviousMessages', () {
    test('returns success with messages from remote', () async {
      final messages = [FakeBaseMessage(1)];
      when(
        () => remote.fetchPreviousMessages(request: any(named: 'request')),
      ).thenAnswer((_) async => messages);

      final result = await repo.fetchPreviousMessages(
        request: FakeMessagesRequest(),
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 1));
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.fetchPreviousMessages(request: any(named: 'request')),
      ).thenThrow(
        const MessageListRemoteDataSourceException(
          message: 'Fetch failed',
          code: 'FETCH_ERR',
        ),
      );

      final result = await repo.fetchPreviousMessages(
        request: FakeMessagesRequest(),
      );

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // fetchNextMessages
  // =========================================================================

  group('fetchNextMessages', () {
    test('returns success with messages from remote', () async {
      final messages = [FakeBaseMessage(5)];
      when(
        () => remote.fetchNextMessages(request: any(named: 'request')),
      ).thenAnswer((_) async => messages);

      final result = await repo.fetchNextMessages(
        request: FakeMessagesRequest(),
      );

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 1));
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.fetchNextMessages(request: any(named: 'request')),
      ).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Fetch failed'),
      );

      final result = await repo.fetchNextMessages(
        request: FakeMessagesRequest(),
      );

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // markAsRead
  // =========================================================================

  group('markAsRead', () {
    test('returns success when remote succeeds', () async {
      when(() => remote.markAsRead(any())).thenAnswer((_) async {});

      final result = await repo.markAsRead(FakeBaseMessage(1));

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.markAsRead(any())).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Failed'),
      );

      final result = await repo.markAsRead(FakeBaseMessage(1));

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // markAsDelivered
  // =========================================================================

  group('markAsDelivered', () {
    test('returns success when remote succeeds', () async {
      when(() => remote.markAsDelivered(any())).thenAnswer((_) async {});

      final result = await repo.markAsDelivered(FakeBaseMessage(1));

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.markAsDelivered(any())).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Failed'),
      );

      final result = await repo.markAsDelivered(FakeBaseMessage(1));

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getLoggedInUser
  // =========================================================================

  group('getLoggedInUser', () {
    test('returns user from remote', () async {
      when(() => remote.getLoggedInUser()).thenAnswer((_) async => FakeUser());

      final result = await repo.getLoggedInUser();

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.getLoggedInUser()).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Not logged in'),
      );

      final result = await repo.getLoggedInUser();

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // getConversation
  // =========================================================================

  group('getConversation', () {
    test('returns conversation from remote', () async {
      when(
        () => remote.getConversation(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
        ),
      ).thenAnswer((_) async => FakeConversation());

      final result = await repo.getConversation(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(
        () => remote.getConversation(
          conversationWith: any(named: 'conversationWith'),
          conversationType: any(named: 'conversationType'),
        ),
      ).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Not found'),
      );

      final result = await repo.getConversation(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // markMessageAsUnread
  // =========================================================================

  group('markMessageAsUnread', () {
    test('returns conversation from remote on success', () async {
      when(
        () => remote.markMessageAsUnread(any()),
      ).thenAnswer((_) async => FakeConversation());

      final result = await repo.markMessageAsUnread(FakeBaseMessage(1));

      expect(result.isSuccess, isTrue);
    });

    test('returns failure when remote throws', () async {
      when(() => remote.markMessageAsUnread(any())).thenThrow(
        const MessageListRemoteDataSourceException(message: 'Failed'),
      );

      final result = await repo.markMessageAsUnread(FakeBaseMessage(1));

      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // Repository without local datasource
  // =========================================================================

  group('without local datasource', () {
    test('getMessages succeeds without caching', () async {
      final repoNoLocal = MessageListRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: null,
      );
      final messages = [FakeBaseMessage(1)];
      when(
        () => remote.getMessages(
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
        (_) async => GetMessagesResult(
          request: FakeMessagesRequest(),
          messages: messages,
        ),
      );

      final result = await repoNoLocal.getMessages(
        conversationWith: 'test_user',
        conversationType: 'user',
      );

      expect(result.isSuccess, isTrue);
      verifyNever(() => local.cacheMessages(any(), any()));
    });

    test(
      'getMessages returns failure without fallback when remote fails',
      () async {
        final repoNoLocal = MessageListRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: null,
        );
        when(
          () => remote.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            parentMessageId: any(named: 'parentMessageId'),
            types: any(named: 'types'),
            categories: any(named: 'categories'),
            hideReplies: any(named: 'hideReplies'),
            withParent: any(named: 'withParent'),
          ),
        ).thenThrow(
          const MessageListRemoteDataSourceException(message: 'Network error'),
        );

        final result = await repoNoLocal.getMessages(
          conversationWith: 'test_user',
          conversationType: 'user',
        );

        expect(result.isFailure, isTrue);
      },
    );
  });
}
