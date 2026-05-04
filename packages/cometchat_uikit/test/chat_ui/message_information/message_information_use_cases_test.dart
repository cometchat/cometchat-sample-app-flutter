import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_information/domain/repositories/message_information_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/domain/usecases/fetch_message_receipts_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageInformationRepository extends Mock
    implements MessageInformationRepository {}

class FakeMessageReceipt extends Fake implements MessageReceipt {
  final int _messageId;
  final String _senderUid;

  FakeMessageReceipt([this._messageId = 1, this._senderUid = 'uid_1']);

  @override
  int get messageId => _messageId;

  @override
  User get sender => _FakeReceiptUser(_senderUid);
}

class _FakeReceiptUser extends Fake implements User {
  final String _uid;
  _FakeReceiptUser(this._uid);

  @override
  String get uid => _uid;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMessageReceipt());
  });

  // =========================================================================
  // FetchMessageReceiptsUseCase
  // =========================================================================

  group('FetchMessageReceiptsUseCase', () {
    late MockMessageInformationRepository repo;
    late FetchMessageReceiptsUseCase useCase;

    setUp(() {
      repo = MockMessageInformationRepository();
      useCase = FetchMessageReceiptsUseCase(repo);
    });

    test('returns failure when messageId is 0', () async {
      final result = await useCase(0);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('returns failure when messageId is negative', () async {
      final result = await useCase(-5);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'INVALID_MESSAGE_ID'));
    });

    test('does not call repository for invalid messageId', () async {
      await useCase(0);
      verifyNever(() => repo.fetchMessageReceipts(any()));
    });

    test('delegates to repository with valid messageId', () async {
      final receipts = [FakeMessageReceipt(42, 'uid_1')];
      when(() => repo.fetchMessageReceipts(any()))
          .thenAnswer((_) async => Success(receipts));

      final result = await useCase(42);
      expect(result.isSuccess, isTrue);
      verify(() => repo.fetchMessageReceipts(42)).called(1);
    });

    test('returns receipts from repository on success', () async {
      final receipts = [
        FakeMessageReceipt(42, 'uid_1'),
        FakeMessageReceipt(42, 'uid_2'),
      ];
      when(() => repo.fetchMessageReceipts(any()))
          .thenAnswer((_) async => Success(receipts));

      final result = await useCase(42);
      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('propagates repository failure', () async {
      when(() => repo.fetchMessageReceipts(any())).thenAnswer((_) async =>
          const Failure(message: 'SDK error', code: 'SDK_ERR'));

      final result = await useCase(42);
      expect(result.isFailure, isTrue);
      result.onFailure((f) => expect(f.code, 'SDK_ERR'));
    });

    test('accepts messageId of 1 (minimum valid)', () async {
      when(() => repo.fetchMessageReceipts(any()))
          .thenAnswer((_) async => const Success([]));

      final result = await useCase(1);
      expect(result.isSuccess, isTrue);
    });
  });
}
