import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/get_conversations_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/delete_conversation_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/get_conversation_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/mark_as_delivered_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/usecases/load_more_conversations_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/domain/repositories/conversations_repository.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockConversationsRepository extends Mock
    implements ConversationsRepository {}

class FakeConversation extends Fake implements Conversation {
  final String _id;
  FakeConversation(this._id);

  @override
  String? get conversationId => _id;
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';
}

class FakeBaseMessage extends Fake implements BaseMessage {
  @override
  int get id => 1;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ConversationsBloc _makeBloc(MockConversationsRepository repo) {
  return ConversationsBloc(
    getConversationsUseCase: GetConversationsUseCase(repo),
    loadMoreConversationsUseCase: LoadMoreConversationsUseCase(repo),
    deleteConversationUseCase: DeleteConversationUseCase(repo),
    getLoggedInUserUseCase: GetLoggedInUserUseCase(repo),
    getConversationUseCase: GetConversationUseCase(repo),
    markAsDeliveredUseCase: MarkAsDeliveredUseCase(repo),
    disableSDKListeners: true, // prevent real SDK listener registration in tests
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeConversation(''));
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeBaseMessage());
  });

  group('ConversationsBloc', () {
    late MockConversationsRepository repo;

    setUp(() {
      repo = MockConversationsRepository();
      // Default stubs
      when(() => repo.getLoggedInUser())
          .thenAnswer((_) async => Success(FakeUser()));
      when(() => repo.getConversations(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Success([]));
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state is ConversationsInitial', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state, isA<ConversationsInitial>());
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // LoadConversations
    // -----------------------------------------------------------------------

    blocTest<ConversationsBloc, ConversationsState>(
      'emits [Loading, Empty] when no conversations returned',
      build: () {
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async => const Success([]));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        isA<ConversationsLoading>(),
        isA<ConversationsEmpty>(),
      ],
    );

    blocTest<ConversationsBloc, ConversationsState>(
      'emits [Loading, Loaded] when conversations returned',
      build: () {
        final convs = [FakeConversation('conv_1'), FakeConversation('conv_2')];
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async => Success(convs));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        isA<ConversationsLoading>(),
        isA<ConversationsLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ConversationsLoaded;
        expect(state.conversations.length, 2);
      },
    );

    blocTest<ConversationsBloc, ConversationsState>(
      'emits [Loading, Error] when repository fails',
      build: () {
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async =>
                const Failure(message: 'Network error', code: 'NET_ERR'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        isA<ConversationsLoading>(),
        isA<ConversationsError>(),
      ],
    );



    // -----------------------------------------------------------------------
    // DeleteConversation
    // -----------------------------------------------------------------------

    blocTest<ConversationsBloc, ConversationsState>(
      'removes conversation from loaded list on delete',
      build: () {
        final convs = [FakeConversation('user_uid1'), FakeConversation('user_uid2')];
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async => Success(convs));
        when(() => repo.deleteConversation(any()))
            .thenAnswer((_) async => const Success(null));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadConversations());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const DeleteConversation('user_uid1'));
      },
      expect: () => [
        isA<ConversationsLoading>(),
        isA<ConversationsLoaded>(),
        isA<ConversationsLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ConversationsLoaded;
        expect(state.conversations.length, 1);
      },
    );

    // -----------------------------------------------------------------------
    // SetActiveConversation
    // -----------------------------------------------------------------------

    blocTest<ConversationsBloc, ConversationsState>(
      'updates activeConversationId in loaded state',
      build: () {
        final convs = [FakeConversation('conv_1')];
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async => Success(convs));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadConversations());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SetActiveConversation('conv_1'));
      },
      verify: (bloc) {
        final state = bloc.state as ConversationsLoaded;
        expect(state.activeConversationId, 'conv_1');
      },
    );

    // -----------------------------------------------------------------------
    // RemoveConversation (no SDK call)
    // -----------------------------------------------------------------------

    blocTest<ConversationsBloc, ConversationsState>(
      'removes conversation without calling SDK delete',
      build: () {
        final convs = [FakeConversation('conv_1'), FakeConversation('conv_2')];
        when(() => repo.getConversations(limit: any(named: 'limit')))
            .thenAnswer((_) async => Success(convs));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const LoadConversations());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RemoveConversation('conv_1'));
      },
      verify: (bloc) {
        verifyNever(() => repo.deleteConversation(any()));
        final state = bloc.state as ConversationsLoaded;
        expect(state.conversations.length, 1);
      },
    );


  });
}
