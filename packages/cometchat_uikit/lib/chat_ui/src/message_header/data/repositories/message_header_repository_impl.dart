import 'dart:async';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/message_header_repository.dart';

/// Implementation of MessageHeaderRepository using CometChat SDK
class MessageHeaderRepositoryImpl implements MessageHeaderRepository {
  @override
  Future<Result<User>> getUser(String uid) async {
    try {
      final completer = Completer<User>();

      await CometChat.getUser(
        uid,
        onSuccess: (User user) {
          completer.complete(user);
        },
        onError: (CometChatException exception) {
          completer.completeError(exception);
        },
      );

      final user = await completer.future;
      return Success(user);
    } on CometChatException catch (e) {
      return Failure(message: e.message ?? 'Failed to get user', code: e.code);
    } catch (e) {
      return Failure(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<Result<Group>> getGroup(String guid) async {
    try {
      final completer = Completer<Group>();

      await CometChat.getGroup(
        guid,
        onSuccess: (Group group) {
          completer.complete(group);
        },
        onError: (CometChatException exception) {
          completer.completeError(exception);
        },
      );

      final group = await completer.future;
      return Success(group);
    } on CometChatException catch (e) {
      return Failure(message: e.message ?? 'Failed to get group', code: e.code);
    } catch (e) {
      return Failure(message: 'Failed to get group: $e');
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await CometChat.getLoggedInUser();
      return Success(user);
    } on CometChatException catch (e) {
      return Failure(
        message: e.message ?? 'Failed to get logged-in user',
        code: e.code,
      );
    } catch (e) {
      return Failure(message: 'Failed to get logged-in user: $e');
    }
  }
}
