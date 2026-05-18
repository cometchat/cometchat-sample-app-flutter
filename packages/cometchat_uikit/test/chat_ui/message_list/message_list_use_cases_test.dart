import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/repositories/message_list_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/get_messages_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/domain/usecases/mark_as_read_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageListRepository extends Mock implements MessageListRepository {}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  FakeBaseMessage([this._id = 1]);

  @override
  int get id => _id;

  @override
  User? get sender => User(uid: 'sender_1', name: 'Sender');
}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

class FakeConversation extends Fake implements Conversation {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseMessage());
    registerFallbackValue(FakeMessagesRequest());
    registerFallbackValue(FakeConversation());
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

    test('returns failure for empty conversationWith', () async {
      final result = await useCase(
        conversationWith: '',
        conversationType: 'user',
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_CONVERSATION_ID'));
    });

    test('returns failure for invalid conversationType', () async {
      final result = await useCase(
        conversationWith: 'uid123',
        conversationType: 'channel', // invalid
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_CONVERSATION_TYPE'));
    });

    test('accepts "user" as valid conversationType', () async {
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => const Success([]));

      final result = await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
      );
      expect(result.isSuccess, isTrue);
    });

    test('accepts "group" as valid conversationType', () async {
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => const Success([]));

      final result = await useCase(
        conversationWith: 'guid456',
        conversationType: 'group',
      );
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
        limit: 0,
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit exceeds 100', () async {
      final result = await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
        limit: 101,
      );
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });

    test('delegates to repository with correct params', () async {
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => const Success([]));

      await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
        limit: 30,
      );

      verify(() => repo.getMessages(
            conversationWith: 'uid123',
            conversationType: 'user',
            limit: 30,
            hideReplies: true,
          )).called(1);
    });

    test('passes parentMessageId for thread messages', () async {
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            parentMessageId: any(named: 'parentMessageId'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async => const Success([]));

      await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
        parentMessageId: 42,
      );

      verify(() => repo.getMessages(
            conversationWith: 'uid123',
            conversationType: 'user',
            limit: 30,
            parentMessageId: 42,
            hideReplies: true,
          )).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.getMessages(
            conversationWith: any(named: 'conversationWith'),
            conversationType: any(named: 'conversationType'),
            limit: any(named: 'limit'),
            hideReplies: any(named: 'hideReplies'),
          )).thenAnswer((_) async =>
          const Failure(message: 'Fetch failed', code: 'FETCH_ERR'));

      final result = await useCase(
        conversationWith: 'uid123',
        conversationType: 'user',
      );
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

    test('returns failure for message with id <= 0', () async {
      final msg = FakeBaseMessage(0);
      final result = await useCase(message: msg);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('delegates to repository for valid message', () async {
      final msg = FakeBaseMessage(99);
      when(() => repo.markAsRead(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(message: msg);
      expect(result.isSuccess, isTrue);
      verify(() => repo.markAsRead(msg)).called(1);
    });

    test('does not call repository for invalid message id', () async {
      final msg = FakeBaseMessage(-1);
      await useCase(message: msg);
      verifyNever(() => repo.markAsRead(any()));
    });

    test('propagates repository failure', () async {
      final msg = FakeBaseMessage(5);
      when(() => repo.markAsRead(any()))
          .thenAnswer((_) async =>
              const Failure(message: 'Mark read failed', code: 'READ_ERR'));

      final result = await useCase(message: msg);
      expect(result.isFailure, isTrue);
    });
  });
}
