import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_information/data/datasources/message_information_datasource.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_information/data/repositories/message_information_repository_impl.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDataSource extends Mock implements MessageInformationDataSource {}

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
  late MockDataSource dataSource;
  late MessageInformationRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(FakeMessageReceipt());
  });

  setUp(() {
    dataSource = MockDataSource();
    repo = MessageInformationRepositoryImpl(dataSource: dataSource);
  });

  // =========================================================================
  // fetchMessageReceipts
  // =========================================================================

  group('fetchMessageReceipts', () {
    test('returns success with receipts from data source', () async {
      final receipts = [
        FakeMessageReceipt(42, 'uid_1'),
        FakeMessageReceipt(42, 'uid_2'),
      ];
      when(() => dataSource.fetchMessageReceipts(any()))
          .thenAnswer((_) async => receipts);

      final result = await repo.fetchMessageReceipts(42);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data.length, 2));
    });

    test('returns failure when data source throws exception', () async {
      when(() => dataSource.fetchMessageReceipts(any())).thenThrow(
        const MessageInformationDataSourceException(
          message: 'SDK error',
          code: 'SDK_ERR',
        ),
      );

      final result = await repo.fetchMessageReceipts(42);

      expect(result.isFailure, isTrue);
    });

    test('returns failure with message on unexpected error', () async {
      when(() => dataSource.fetchMessageReceipts(any()))
          .thenThrow(Exception('Unexpected'));

      final result = await repo.fetchMessageReceipts(42);

      expect(result.isFailure, isTrue);
    });

    test('returns empty list when no receipts exist', () async {
      when(() => dataSource.fetchMessageReceipts(any()))
          .thenAnswer((_) async => []);

      final result = await repo.fetchMessageReceipts(42);

      expect(result.isSuccess, isTrue);
      result.onSuccess((data) => expect(data, isEmpty));
    });
  });
}
