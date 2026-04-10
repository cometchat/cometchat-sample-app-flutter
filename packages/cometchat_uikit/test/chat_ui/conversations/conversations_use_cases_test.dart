import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/repositories/conversations_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/get_conversations_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/delete_conversation_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockConversationsRepository extends Mock
    implements ConversationsRepository {}

class FakeConversation extends Fake implements Conversation {}

class FakeBaseMessage extends Fake implements BaseMessage {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeConversation());
    registerFallbackValue(FakeBaseMessage());
  });

  // =========================================================================
  // GetConversationsUseCase
  // =========================================================================

  group('GetConversationsUseCase', () {
    late MockConversationsRepository repo;
    late GetConversationsUseCase useCase;

    setUp(() {
      repo = MockConversationsRepository();
      useCase = GetConversationsUseCase(repo);
    });

    test('returns failure when limit is 0', () async {
      final result = await useCase(limit: 0);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_LIMIT'));
    });

    test('returns failure when limit is negative', () async {
      final result = await useCase(limit: -5);
      expect(result.isFailure, isTrue);
    });

    test('returns failure when limit exceeds 100', () async {
      final result = await useCase(limit: 101);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'LIMIT_TOO_HIGH'));
    });

    test('delegates to repository with default limit', () async {
      when(() => repo.getConversations(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Success([]));

      final result = await useCase();
      expect(result.isSuccess, isTrue);
      verify(() => repo.getConversations(limit: 30)).called(1);
    });

    test('passes custom limit to repository', () async {
      when(() => repo.getConversations(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Success([]));

      await useCase(limit: 50);
      verify(() => repo.getConversations(limit: 50)).called(1);
    });

    test('passes fromId to repository', () async {
      when(() => repo.getConversations(
            limit: any(named: 'limit'),
            fromId: any(named: 'fromId'),
          )).thenAnswer((_) async => const Success([]));

      await useCase(limit: 10, fromId: 'conv_123');
      verify(() => repo.getConversations(limit: 10, fromId: 'conv_123'))
          .called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.getConversations(limit: any(named: 'limit')))
          .thenAnswer(
              (_) async => const Failure(message: 'Network error', code: 'NET_ERR'));

      final result = await useCase();
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.message, 'Network error'));
    });

    test('accepts limit of exactly 100', () async {
      when(() => repo.getConversations(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Success([]));

      final result = await useCase(limit: 100);
      expect(result.isSuccess, isTrue);
    });
  });

  // =========================================================================
  // DeleteConversationUseCase
  // =========================================================================

  group('DeleteConversationUseCase', () {
    late MockConversationsRepository repo;
    late DeleteConversationUseCase useCase;

    setUp(() {
      repo = MockConversationsRepository();
      useCase = DeleteConversationUseCase(repo);
    });

    test('returns failure for empty conversation ID', () async {
      final result = await useCase('');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_CONVERSATION_ID'));
    });

    test('delegates to repository with valid ID', () async {
      when(() => repo.deleteConversation(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase('user_abc');
      expect(result.isSuccess, isTrue);
      verify(() => repo.deleteConversation('user_abc')).called(1);
    });

    test('propagates repository failure', () async {
      when(() => repo.deleteConversation(any()))
          .thenAnswer(
              (_) async => const Failure(message: 'Delete failed', code: 'DEL_ERR'));

      final result = await useCase('user_abc');
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'DEL_ERR'));
    });

    test('does not call repository for empty ID', () async {
      await useCase('');
      verifyNever(() => repo.deleteConversation(any()));
    });
  });
}
