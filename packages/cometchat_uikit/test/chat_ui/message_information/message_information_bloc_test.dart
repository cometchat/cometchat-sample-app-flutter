import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_information/bloc/message_information_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/bloc/message_information_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/bloc/message_information_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/domain/repositories/message_information_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/domain/usecases/fetch_message_receipts_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageInformationRepository extends Mock
    implements MessageInformationRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  final String _name;

  FakeUser([this._uid = 'uid_1', this._name = 'Test User']);

  @override
  String get uid => _uid;

  @override
  String get name => _name;
}

class FakeGroup extends Fake implements Group {
  final String _guid;

  FakeGroup([this._guid = 'guid_1']);

  @override
  String get guid => _guid;

  @override
  String get name => 'Test Group';

  @override
  int get membersCount => 5;
}

class FakeBaseMessage extends Fake implements BaseMessage {
  final User? _receiver;
  final Group? _groupReceiver;
  final User? _sender;

  FakeBaseMessage({User? receiver, Group? groupReceiver, User? sender})
    : _receiver = receiver,
      _groupReceiver = groupReceiver,
      _sender = sender;

  @override
  int get id => 42;

  @override
  AppEntity? get receiver => _groupReceiver ?? _receiver;

  @override
  String get receiverType => _groupReceiver != null ? 'group' : 'user';

  @override
  String get receiverUid => _groupReceiver?.guid ?? (_receiver)?.uid ?? '';

  @override
  User? get sender => _sender ?? FakeUser('sender_uid', 'Sender');

  @override
  DateTime? get sentAt => DateTime(2026, 4, 20);

  @override
  DateTime? get deliveredAt => DateTime(2026, 4, 20, 0, 1);

  @override
  DateTime? get readAt => DateTime(2026, 4, 20, 0, 2);
}

class FakeMessageReceipt extends Fake implements MessageReceipt {
  final int _messageId;
  final User _sender;
  final String _receiverType;
  final String _receiverId;
  final DateTime? _deliveredAt;
  final DateTime? _readAt;

  FakeMessageReceipt({
    int messageId = 42,
    User? sender,
    String receiverType = 'user',
    String receiverId = 'uid_1',
    DateTime? deliveredAt,
    DateTime? readAt,
  }) : _messageId = messageId,
       _sender = sender ?? FakeUser('uid_1'),
       _receiverType = receiverType,
       _receiverId = receiverId,
       _deliveredAt = deliveredAt,
       _readAt = readAt;

  @override
  int get messageId => _messageId;

  @override
  User get sender => _sender;

  @override
  String get receiverType => _receiverType;

  @override
  String get receiverId => _receiverId;

  @override
  DateTime? get deliveredAt => _deliveredAt;

  @override
  DateTime? get readAt => _readAt;

  @override
  DateTime get timestamp => DateTime(2026, 4, 20);

  @override
  String get receiptType => '';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageInformationBloc _makeBloc(MockMessageInformationRepository repo) {
  return MessageInformationBloc(
    fetchMessageReceiptsUseCase: FetchMessageReceiptsUseCase(repo),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseMessage());
    registerFallbackValue(FakeMessageReceipt());
  });

  group('MessageInformationBloc', () {
    late MockMessageInformationRepository repo;

    setUp(() {
      repo = MockMessageInformationRepository();
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('initial state has initial status', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageInformationStatus.initial);
      expect(bloc.state.receipts, isEmpty);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // FetchMessageReceipts
    // -----------------------------------------------------------------------

    blocTest<MessageInformationBloc, MessageInformationState>(
      'FetchMessageReceipts returns receipts on success',
      build: () {
        final receipts = [
          FakeMessageReceipt(sender: FakeUser('uid_1')),
          FakeMessageReceipt(sender: FakeUser('uid_2')),
        ];
        when(
          () => repo.fetchMessageReceipts(any()),
        ).thenAnswer((_) async => Success(receipts));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const FetchMessageReceipts(messageId: 42, senderUid: 'sender_uid'),
      ),
      expect: () => [
        // Loading state
        isA<MessageInformationState>().having(
          (s) => s.status,
          'status',
          MessageInformationStatus.loading,
        ),
        // Loaded state with receipts (sender filtered out)
        isA<MessageInformationState>()
            .having((s) => s.status, 'status', MessageInformationStatus.loaded)
            .having((s) => s.receipts.length, 'receipts count', 2),
      ],
    );

    blocTest<MessageInformationBloc, MessageInformationState>(
      'FetchMessageReceipts filters out sender from receipts',
      build: () {
        final receipts = [
          FakeMessageReceipt(sender: FakeUser('sender_uid')),
          FakeMessageReceipt(sender: FakeUser('uid_2')),
        ];
        when(
          () => repo.fetchMessageReceipts(any()),
        ).thenAnswer((_) async => Success(receipts));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(
        const FetchMessageReceipts(messageId: 42, senderUid: 'sender_uid'),
      ),
      verify: (bloc) {
        expect(bloc.state.receipts.length, 1);
        expect(bloc.state.receipts.first.sender.uid, 'uid_2');
      },
    );

    blocTest<MessageInformationBloc, MessageInformationState>(
      'FetchMessageReceipts emits error on failure',
      build: () {
        when(() => repo.fetchMessageReceipts(any())).thenAnswer(
          (_) async => const Failure(message: 'SDK error', code: 'SDK_ERR'),
        );
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchMessageReceipts(messageId: 42)),
      expect: () => [
        isA<MessageInformationState>().having(
          (s) => s.status,
          'status',
          MessageInformationStatus.loading,
        ),
        isA<MessageInformationState>().having(
          (s) => s.status,
          'status',
          MessageInformationStatus.error,
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // State helper getters
    // -----------------------------------------------------------------------

    test('isUserConversation returns true when user is set', () {
      final state = MessageInformationState(
        status: MessageInformationStatus.loaded,
        user: FakeUser(),
      );
      expect(state.isUserConversation, isTrue);
      expect(state.isGroupConversation, isFalse);
    });

    test('isGroupConversation returns true when group is set', () {
      final state = MessageInformationState(
        status: MessageInformationStatus.loaded,
        group: FakeGroup(),
      );
      expect(state.isGroupConversation, isTrue);
      expect(state.isUserConversation, isFalse);
    });

    test('hasError returns true when status is error', () {
      const state = MessageInformationState(
        status: MessageInformationStatus.error,
        errorMessage: 'Something went wrong',
      );
      expect(state.hasError, isTrue);
    });

    test('copyWith creates new state with updated fields', () {
      const original = MessageInformationState(
        status: MessageInformationStatus.initial,
      );
      final updated = original.copyWith(
        status: MessageInformationStatus.loaded,
      );
      expect(updated.status, MessageInformationStatus.loaded);
      expect(original.status, MessageInformationStatus.initial);
    });
  });
}
