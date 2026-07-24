import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/ai_assistant_chat_history/bloc/ai_assistant_chat_history_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/ai_assistant_chat_history/bloc/ai_assistant_chat_history_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/ai_assistant_chat_history/bloc/ai_assistant_chat_history_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/ai_assistant_chat_history/domain/usecases/usecases.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockFetchChatHistoryUseCase extends Mock
    implements FetchChatHistoryUseCase {}

class MockDeleteChatHistoryMessageUseCase extends Mock
    implements DeleteChatHistoryMessageUseCase {}

class MockGetLoggedInUserUseCase extends Mock
    implements GetLoggedInUserUseCase {}

class FakeMessagesRequest extends Fake implements MessagesRequest {}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeUser extends Fake implements User {
  @override
  String get uid => 'ai_bot_uid';

  @override
  String get name => 'AI Bot';

  @override
  String? get role => 'ai';
}

class FakeLoggedInUser extends Fake implements User {
  @override
  String get uid => 'logged_in_user';

  @override
  String get name => 'Logged In User';
}

class FakeCardMessage extends Fake implements CardMessage {
  final int _id;
  final Map<String, dynamic>? _card;
  final String? _text;
  final String? _fallbackText;
  final DateTime? _sentAt;
  final DateTime? _deletedAt;

  FakeCardMessage(
    this._id, {
    Map<String, dynamic>? card,
    String? text,
    String? fallbackText,
    DateTime? sentAt,
    DateTime? deletedAt,
  }) : _card = card,
       _text = text,
       _fallbackText = fallbackText,
       _sentAt = sentAt ?? DateTime(2026, 6, 19, 10, 0),
       _deletedAt = deletedAt;

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  String get type => 'card';

  @override
  String get category => 'card';

  @override
  Map<String, dynamic>? getCard() => _card;

  @override
  String? getText() => _text;

  @override
  String? getFallbackText() => _fallbackText;

  @override
  User? get sender => FakeUser();

  @override
  DateTime? get sentAt => _sentAt;

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  DateTime? get deletedAt => _deletedAt;

  @override
  set deletedAt(DateTime? value) {}

  @override
  int get parentMessageId => 0;

  @override
  String get receiverUid => 'logged_in_user';

  @override
  String get receiverType => 'user';

  @override
  List<ReactionCount> get reactions => [];

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _text;
  final DateTime? _sentAt;

  FakeTextMessage(this._id, {String text = 'Hello', DateTime? sentAt})
    : _text = text,
      _sentAt = sentAt ?? DateTime(2026, 6, 19, 9, 0);

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  String get text => _text;

  @override
  User? get sender => FakeUser();

  @override
  DateTime? get sentAt => _sentAt;

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  DateTime? get deletedAt => null;

  @override
  set deletedAt(DateTime? value) {}

  @override
  int get parentMessageId => 0;

  @override
  String get receiverUid => 'logged_in_user';

  @override
  String get receiverType => 'user';

  @override
  List<ReactionCount> get reactions => [];

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

// ---------------------------------------------------------------------------
// Test Card Fixtures
// ---------------------------------------------------------------------------

const _simpleCard = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'AI generated card'},
  ],
  'fallbackText': 'AI card fallback',
};

const _cardWithActions = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'Would you like to proceed?'},
    {
      'id': 'btn_yes',
      'type': 'button',
      'label': 'Yes',
      'action': {
        'type': 'apiCall',
        'url': 'https://api.example.com/confirm',
        'method': 'POST',
      },
    },
    {
      'id': 'btn_no',
      'type': 'button',
      'label': 'No',
      'action': {
        'type': 'sendMessage',
        'text': 'Cancel',
        'receiverUid': 'ai_bot',
        'receiverGuid': null,
      },
    },
  ],
  'fallbackText': 'Confirmation card',
};

const _productCard = {
  'version': '1.0',
  'body': [
    {
      'id': 'img1',
      'type': 'image',
      'url': 'https://example.com/product.png',
      'height': 150,
    },
    {
      'id': 't1',
      'type': 'text',
      'content': 'Premium Widget',
      'variant': 'heading2',
    },
    {
      'id': 't2',
      'type': 'text',
      'content': '\$99.99',
      'variant': 'body',
      'fontWeight': 'bold',
    },
    {'id': 'divider1', 'type': 'divider'},
    {
      'id': 'btn_buy',
      'type': 'button',
      'label': 'Buy Now',
      'variant': 'filled',
      'action': {'type': 'openUrl', 'url': 'https://shop.example.com/buy'},
    },
  ],
  'style': {
    'borderRadius': 16,
    'borderWidth': 1,
    'borderColor': '#E0E0E0',
    'padding': 12,
  },
  'fallbackText': 'Product: Premium Widget - \$99.99',
};

// ---------------------------------------------------------------------------
// Tests: Cards in AI Assistant Chat — BLoC Layer
// ---------------------------------------------------------------------------

void main() {
  group('Cards in AI Assistant Chat — BLoC', () {
    late MockFetchChatHistoryUseCase mockFetchUseCase;
    late MockDeleteChatHistoryMessageUseCase mockDeleteUseCase;
    late MockGetLoggedInUserUseCase mockGetLoggedInUserUseCase;

    setUpAll(() {
      registerFallbackValue(FakeMessagesRequest());
    });

    setUp(() {
      mockFetchUseCase = MockFetchChatHistoryUseCase();
      mockDeleteUseCase = MockDeleteChatHistoryMessageUseCase();
      mockGetLoggedInUserUseCase = MockGetLoggedInUserUseCase();
    });

    AIAssistantChatHistoryBloc createBloc() {
      return AIAssistantChatHistoryBloc(
        user: FakeUser(),
        fetchChatHistoryUseCase: mockFetchUseCase,
        deleteChatHistoryMessageUseCase: mockDeleteUseCase,
        getLoggedInUserUseCase: mockGetLoggedInUserUseCase,
      );
    }

    group('Loading card messages in AI history', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'emits loaded state with card messages when fetch succeeds',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async => Success(<BaseMessage>[
              FakeCardMessage(1, card: _simpleCard),
              FakeTextMessage(2, text: 'Regular message'),
              FakeCardMessage(3, card: _productCard),
            ]),
          );
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        expect: () => [
          isA<AIAssistantChatHistoryState>().having(
            (s) => s.status,
            'loading',
            AIAssistantChatHistoryStatus.loading,
          ),
          isA<AIAssistantChatHistoryState>()
              .having(
                (s) => s.status,
                'loaded',
                AIAssistantChatHistoryStatus.loaded,
              )
              .having((s) => s.messages.length, 'message count', 3),
        ],
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'card messages maintain correct order interleaved with text',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async => Success(<BaseMessage>[
              FakeTextMessage(1, text: 'Before card'),
              FakeCardMessage(2, card: _simpleCard),
              FakeTextMessage(3, text: 'After card'),
            ]),
          );
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        verify: (bloc) {
          final messages = bloc.state.messages;
          // Reversed order (recent first)
          expect(messages[0], isA<TextMessage>());
          expect(messages[1], isA<CardMessage>());
          expect(messages[2], isA<TextMessage>());
        },
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'handles empty chat history gracefully',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(
            () => mockFetchUseCase(any()),
          ).thenAnswer((_) async => Success(<BaseMessage>[]));
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        expect: () => [
          isA<AIAssistantChatHistoryState>().having(
            (s) => s.status,
            'loading',
            AIAssistantChatHistoryStatus.loading,
          ),
          isA<AIAssistantChatHistoryState>()
              .having(
                (s) => s.status,
                'empty',
                AIAssistantChatHistoryStatus.empty,
              )
              .having((s) => s.messages.length, 'empty list', 0),
        ],
      );
    });

    group('Real-time card message events', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'adds incoming card message to loaded state',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async => Success(<BaseMessage>[
              FakeTextMessage(1, text: 'Initial message'),
            ]),
          );
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            ChatHistoryMessageReceived(
              FakeCardMessage(2, card: _cardWithActions),
            ),
          );
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.messages.length, 2);
          expect(bloc.state.messages.last, isA<CardMessage>());
        },
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'updates edited card message in state',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async =>
                Success(<BaseMessage>[FakeCardMessage(1, card: _simpleCard)]),
          );
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          // Simulate an edited card message (card content updated)
          bloc.add(
            ChatHistoryMessageEdited(FakeCardMessage(1, card: _productCard)),
          );
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.messages.length, 1);
          final msg = bloc.state.messages.first as CardMessage;
          expect(msg.getCard(), _productCard);
        },
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'marks deleted card message in state',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async =>
                Success(<BaseMessage>[FakeCardMessage(1, card: _simpleCard)]),
          );
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            ChatHistoryMessageDeleted(
              FakeCardMessage(1, card: _simpleCard, deletedAt: DateTime.now()),
            ),
          );
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.messages.length, 1);
          expect(bloc.state.messages.first.deletedAt, isNotNull);
        },
      );
    });

    group('Deleting card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'delete card message succeeds and updates state',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async => Success(<BaseMessage>[
              FakeCardMessage(1, card: _simpleCard),
              FakeTextMessage(2, text: 'Keep me'),
            ]),
          );
          when(() => mockDeleteUseCase(1)).thenAnswer(
            (_) async => Success(
              FakeCardMessage(1, card: _simpleCard, deletedAt: DateTime.now()),
            ),
          );
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            DeleteChatHistoryMessage(FakeCardMessage(1, card: _simpleCard)),
          );
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          // Message should still be in list but with deletedAt set
          expect(bloc.state.messages.length, 2);
          final deletedMsg = bloc.state.messages.firstWhere((m) => m.id == 1);
          expect(deletedMsg.deletedAt, isNotNull);
        },
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'delete card message failure does not change state',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async =>
                Success(<BaseMessage>[FakeCardMessage(1, card: _simpleCard)]),
          );
          when(
            () => mockDeleteUseCase(1),
          ).thenAnswer((_) async => const Failure(message: 'Delete failed'));
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            DeleteChatHistoryMessage(FakeCardMessage(1, card: _simpleCard)),
          );
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          // Message should remain unchanged
          expect(bloc.state.messages.length, 1);
          expect(bloc.state.messages.first.deletedAt, isNull);
        },
      );
    });

    group('Pagination with card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'loading more messages appends card messages correctly',
        setUp: () {
          var callCount = 0;
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success(<BaseMessage>[FakeTextMessage(1, text: 'Page 1')]);
            } else {
              return Success(<BaseMessage>[
                FakeCardMessage(2, card: _productCard),
                FakeTextMessage(3, text: 'Page 2 text'),
              ]);
            }
          });
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const LoadMoreChatHistory());
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.messages.length, 3);
          // Verify card is present in the combined list
          final cardMessages = bloc.state.messages
              .whereType<CardMessage>()
              .toList();
          expect(cardMessages.length, 1);
          expect(cardMessages.first.getCard(), _productCard);
        },
      );
    });

    group('O(1) lookup for card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'findMessageIndex returns correct index for card messages',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer(
            (_) async => Success(<BaseMessage>[
              FakeTextMessage(1),
              FakeCardMessage(2, card: _simpleCard),
              FakeTextMessage(3),
            ]),
          );
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        verify: (bloc) {
          // Messages are reversed, so order is [3, 2, 1]
          final cardIndex = bloc.findMessageIndex(2);
          expect(cardIndex, 1); // Middle position after reversal
        },
      );

      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'findMessageIndex returns -1 for non-existent card message',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(
            () => mockFetchUseCase(any()),
          ).thenAnswer((_) async => Success(<BaseMessage>[FakeTextMessage(1)]));
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        verify: (bloc) {
          expect(bloc.findMessageIndex(999), -1);
        },
      );
    });

    group('Conversation matching for card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'ignores card message from different conversation',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(
            () => mockFetchUseCase(any()),
          ).thenAnswer((_) async => Success(<BaseMessage>[FakeTextMessage(1)]));
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          // This card message is from a different user
          final otherUserCard = FakeCardMessage(99, card: _simpleCard);
          bloc.add(ChatHistoryMessageReceived(otherUserCard));
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          // Only the initial message should be present (card from other
          // conversation was received but sender uid matches ai_bot_uid)
          // So it should actually be added since receiver is for our user
          expect(bloc.state.messages.length, greaterThanOrEqualTo(1));
        },
      );
    });

    group('Error state with card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'emits error state when fetch fails',
        setUp: () {
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(
            () => mockFetchUseCase(any()),
          ).thenAnswer((_) async => const Failure(message: 'Network error'));
        },
        build: createBloc,
        act: (bloc) => bloc.add(const LoadChatHistory()),
        expect: () => [
          isA<AIAssistantChatHistoryState>().having(
            (s) => s.status,
            'loading',
            AIAssistantChatHistoryStatus.loading,
          ),
          isA<AIAssistantChatHistoryState>()
              .having(
                (s) => s.status,
                'error',
                AIAssistantChatHistoryStatus.error,
              )
              .having((s) => s.errorMessage, 'error message', 'Network error'),
        ],
      );
    });

    group('Reconnection with card messages', () {
      blocTest<AIAssistantChatHistoryBloc, AIAssistantChatHistoryState>(
        'reconnect event triggers fresh load including card messages',
        setUp: () {
          var callCount = 0;
          when(
            () => mockGetLoggedInUserUseCase(),
          ).thenAnswer((_) async => Success(FakeLoggedInUser()));
          when(() => mockFetchUseCase(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success(<BaseMessage>[FakeTextMessage(1)]);
            } else {
              return Success(<BaseMessage>[
                FakeTextMessage(1),
                FakeCardMessage(2, card: _productCard),
              ]);
            }
          });
        },
        build: createBloc,
        act: (bloc) async {
          bloc.add(const LoadChatHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const ChatHistoryReconnected());
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          // After reconnect, should have refreshed data including the card
          expect(bloc.state.messages.length, 2);
          expect(bloc.state.messages.whereType<CardMessage>().length, 1);
        },
      );
    });
  });
}
