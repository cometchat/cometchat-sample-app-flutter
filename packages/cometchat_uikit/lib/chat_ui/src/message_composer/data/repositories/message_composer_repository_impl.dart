import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/message_composer_repository.dart';
import '../datasources/message_composer_datasource.dart';

/// Implementation of MessageComposerRepository
/// Coordinates between data source and domain layer
class MessageComposerRepositoryImpl implements MessageComposerRepository {
  final MessageComposerDataSource _dataSource;

  const MessageComposerRepositoryImpl({
    required MessageComposerDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<TextMessage>> sendTextMessage(TextMessage message) async {
    try {
      final result = await _dataSource.sendTextMessage(message);
      return Success(result);
    } on MessageComposerDataSourceException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } on CometChatException catch (e) {
      return Failure(
        message: e.message ?? 'Failed to send text message',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message: 'Failed to send text message: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<MediaMessage>> sendMediaMessage(MediaMessage message) async {
    try {
      final result = await _dataSource.sendMediaMessage(message);
      return Success(result);
    } on MessageComposerDataSourceException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } on CometChatException catch (e) {
      return Failure(
        message: e.message ?? 'Failed to send media message',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message: 'Failed to send media message: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<CustomMessage>> sendCustomMessage(CustomMessage message) async {
    try {
      final result = await _dataSource.sendCustomMessage(message);
      return Success(result);
    } on MessageComposerDataSourceException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } on CometChatException catch (e) {
      return Failure(
        message: e.message ?? 'Failed to send custom message',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message: 'Failed to send custom message: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<BaseMessage>> editMessage(TextMessage message) async {
    try {
      final result = await _dataSource.editMessage(message);
      return Success(result);
    } on MessageComposerDataSourceException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } on CometChatException catch (e) {
      return Failure(
        message: e.message ?? 'Failed to edit message',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message: 'Failed to edit message: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> startTyping({
    required String receiverUid,
    required String receiverType,
  }) async {
    try {
      _dataSource.startTyping(
        receiverUid: receiverUid,
        receiverType: receiverType,
      );
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to start typing: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> endTyping({
    required String receiverUid,
    required String receiverType,
  }) async {
    try {
      _dataSource.endTyping(
        receiverUid: receiverUid,
        receiverType: receiverType,
      );
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to end typing: $e',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await _dataSource.getLoggedInUser();
      return Success(user);
    } catch (e) {
      return Failure(
        message: 'Failed to get logged in user: $e',
        exception: e is Exception ? e : null,
      );
    }
  }
}
