import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

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
  String get uid => 'fake_user';
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  final int _parentMessageId;
  final User? _sender;

  FakeBaseMessage(this._id, {int parentMessageId = 0, User? sender})
    : _parentMessageId = parentMessageId,
      _sender = sender;

  @override
  int get id => _id;

  @override
  int get parentMessageId => _parentMessageId;

  @override
  User? get sender => _sender;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseMessage(0));
    registerFallbackValue(FakeMessagesRequest());
  });

  // =========================================================================
  // GetMessagesUseCase
  // =========================================================================

  group('GetMessagesUseCase', () {
    late MockMessageListRepository repo;
    late GetMessagesUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = GetMessagesUseCase(repo);
    });

    test('returns failure when conversationWith is empty', () async {
      final result = await useCase(
        conversationWith: '',
        conversationType: 'user',
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_CONVERSATION_ID'));
    });

    test('returns failure when conversationType is invalid', () async {
      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'channel',
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_CONVERSATION_TYPE'));
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        limit: 0,
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit is negative', () async {
      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        limit: -5,
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit exceeds 100', () async {
      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        limit: 101,
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });

    test('accepts limit of exactly 100', () async {
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

      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        limit: 100,
      );
      expect(result.isSuccess, isTrue);
    });

    test('accepts limit of exactly 1', () async {
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

      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        limit: 1,
      );
      expect(result.isSuccess, isTrue);
    });

    test('delegates to repository with default limit of 30', () async {
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

      await useCase(conversationWith: 'uid1', conversationType: 'user');

      verify(
        () => repo.getMessages(
          conversationWith: 'uid1',
          conversationType: 'user',
          limit: 30,
          parentMessageId: null,
          types: null,
          categories: null,
          hideReplies: true,
          withParent: true,
        ),
      ).called(1);
    });

    test('passes parentMessageId to repository', () async {
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

      await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
        parentMessageId: 42,
      );

      verify(
        () => repo.getMessages(
          conversationWith: 'uid1',
          conversationType: 'user',
          limit: 30,
          parentMessageId: 42,
          types: null,
          categories: null,
          hideReplies: true,
          withParent: true,
        ),
      ).called(1);
    });

    test('accepts user conversation type', () async {
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

      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
      );
      expect(result.isSuccess, isTrue);
    });

    test('accepts group conversation type', () async {
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

      final result = await useCase(
        conversationWith: 'guid1',
        conversationType: 'group',
      );
      expect(result.isSuccess, isTrue);
    });

    test('propagates repository failure', () async {
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

      final result = await useCase(
        conversationWith: 'uid1',
        conversationType: 'user',
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.message, 'Network error'));
    });

    test('does not call repository for invalid inputs', () async {
      await useCase(conversationWith: '', conversationType: 'user');
      verifyNever(
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
      );
    });
  });

  // =========================================================================
  // LoadOlderMessagesUseCase
  // =========================================================================

  group('LoadOlderMessagesUseCase', () {
    late MockMessageListRepository repo;
    late LoadOlderMessagesUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = LoadOlderMessagesUseCase(repo);
    });

    test('delegates to repository fetchPreviousMessages', () async {
      final request = FakeMessagesRequest();
      when(
        () => repo.fetchPreviousMessages(request: any(named: 'request')),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase(request: request);
      expect(result.isSuccess, isTrue);
      verify(() => repo.fetchPreviousMessages(request: request)).called(1);
    });

    test('propagates repository failure', () async {
      when(
        () => repo.fetchPreviousMessages(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => const Failure(message: 'Fetch failed', code: 'ERR'),
      );

      final result = await useCase(request: FakeMessagesRequest());
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // LoadNewerMessagesUseCase
  // =========================================================================

  group('LoadNewerMessagesUseCase', () {
    late MockMessageListRepository repo;
    late LoadNewerMessagesUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = LoadNewerMessagesUseCase(repo);
    });

    test('delegates to repository fetchNextMessages', () async {
      final request = FakeMessagesRequest();
      when(
        () => repo.fetchNextMessages(request: any(named: 'request')),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase(request: request);
      expect(result.isSuccess, isTrue);
      verify(() => repo.fetchNextMessages(request: request)).called(1);
    });

    test('propagates repository failure', () async {
      when(
        () => repo.fetchNextMessages(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => const Failure(message: 'Fetch failed', code: 'ERR'),
      );

      final result = await useCase(request: FakeMessagesRequest());
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // MarkAsReadUseCase
  // =========================================================================

  group('MarkAsReadUseCase', () {
    late MockMessageListRepository repo;
    late MarkAsReadUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = MarkAsReadUseCase(repo);
    });

    test('returns failure for zero message ID', () async {
      final result = await useCase(message: FakeBaseMessage(0));
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('returns failure for negative message ID', () async {
      final result = await useCase(message: FakeBaseMessage(-1));
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('returns failure when sender is null', () async {
      final result = await useCase(message: FakeBaseMessage(1, sender: null));
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_SENDER'));
    });

    test('delegates to repository for valid message', () async {
      when(
        () => repo.markAsRead(any()),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase(
        message: FakeBaseMessage(42, sender: FakeUser()),
      );
      expect(result.isSuccess, isTrue);
      verify(() => repo.markAsRead(any())).called(1);
    });

    test('does not call repository for invalid message', () async {
      await useCase(message: FakeBaseMessage(0));
      verifyNever(() => repo.markAsRead(any()));
    });

    test('propagates repository failure', () async {
      when(
        () => repo.markAsRead(any()),
      ).thenAnswer((_) async => const Failure(message: 'Mark failed'));

      final result = await useCase(
        message: FakeBaseMessage(42, sender: FakeUser()),
      );
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // MarkAsDeliveredUseCase
  // =========================================================================

  group('MarkAsDeliveredUseCase', () {
    late MockMessageListRepository repo;
    late MarkAsDeliveredUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = MarkAsDeliveredUseCase(repo);
    });

    test('returns failure for zero message ID', () async {
      final result = await useCase(message: FakeBaseMessage(0));
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('returns failure for negative message ID', () async {
      final result = await useCase(message: FakeBaseMessage(-1));
      expect(result.isFailure, isTrue);
    });

    test('delegates to repository for valid message', () async {
      when(
        () => repo.markAsDelivered(any()),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase(message: FakeBaseMessage(42));
      expect(result.isSuccess, isTrue);
      verify(() => repo.markAsDelivered(any())).called(1);
    });

    test('does not call repository for invalid message', () async {
      await useCase(message: FakeBaseMessage(0));
      verifyNever(() => repo.markAsDelivered(any()));
    });

    test('propagates repository failure', () async {
      when(
        () => repo.markAsDelivered(any()),
      ).thenAnswer((_) async => const Failure(message: 'Delivery failed'));

      final result = await useCase(message: FakeBaseMessage(42));
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // MarkAsUnreadUseCase
  // =========================================================================

  group('MarkAsUnreadUseCase', () {
    late MockMessageListRepository repo;
    late MarkAsUnreadUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = MarkAsUnreadUseCase(repo);
    });

    test('returns failure for zero message ID', () async {
      final result = await useCase(message: FakeBaseMessage(0));
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('returns failure for thread reply', () async {
      final result = await useCase(
        message: FakeBaseMessage(42, parentMessageId: 10),
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'THREAD_REPLY_NOT_ALLOWED'));
    });

    test('delegates to repository for valid non-thread message', () async {
      when(
        () => repo.markMessageAsUnread(any()),
      ).thenAnswer((_) async => Success(_FakeConversation()));

      final result = await useCase(message: FakeBaseMessage(42));
      expect(result.isSuccess, isTrue);
      verify(() => repo.markMessageAsUnread(any())).called(1);
    });

    test('does not call repository for invalid message', () async {
      await useCase(message: FakeBaseMessage(0));
      verifyNever(() => repo.markMessageAsUnread(any()));
    });

    test('does not call repository for thread reply', () async {
      await useCase(message: FakeBaseMessage(42, parentMessageId: 10));
      verifyNever(() => repo.markMessageAsUnread(any()));
    });

    test('propagates repository failure', () async {
      when(
        () => repo.markMessageAsUnread(any()),
      ).thenAnswer((_) async => const Failure(message: 'Unread failed'));

      final result = await useCase(message: FakeBaseMessage(42));
      expect(result.isFailure, isTrue);
    });
  });

  // =========================================================================
  // GetLoggedInUserUseCase
  // =========================================================================

  group('GetLoggedInUserUseCase', () {
    late MockMessageListRepository repo;
    late GetLoggedInUserUseCase useCase;

    setUp(() {
      repo = MockMessageListRepository();
      useCase = GetLoggedInUserUseCase(repo);
    });

    test('returns user from repository', () async {
      final user = FakeUser();
      when(() => repo.getLoggedInUser()).thenAnswer((_) async => Success(user));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data, user));
    });

    test('returns success with null when no user logged in', () async {
      when(
        () => repo.getLoggedInUser(),
      ).thenAnswer((_) async => const Success<User?>(null));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data, isNull));
    });

    test('propagates repository failure', () async {
      when(
        () => repo.getLoggedInUser(),
      ).thenAnswer((_) async => const Failure(message: 'Not authenticated'));

      final result = await useCase();
      expect(result.isFailure, isTrue);
    });
  });
}

class _FakeConversation extends Fake implements Conversation {
  @override
  String? get conversationId => 'user_uid1';
}
