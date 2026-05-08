import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'message_composer_datasource.dart';

/// Implementation of MessageComposerDataSource using CometChat SDK
class MessageComposerDataSourceImpl implements MessageComposerDataSource {
  @override
  Future<TextMessage> sendTextMessage(TextMessage message) async {
    final completer = Completer<TextMessage>();

    CometChat.sendMessage(
      message,
      onSuccess: (TextMessage sentMessage) {
        completer.complete(sentMessage);
      },
      onError: (CometChatException e) {
        completer.completeError(
          MessageComposerDataSourceException(
            message: e.message ?? 'Failed to send text message',
            code: e.code,
            originalException: e,
          ),
        );
      },
    );

    return completer.future;
  }

  @override
  Future<MediaMessage> sendMediaMessage(MediaMessage message) async {
    final completer = Completer<MediaMessage>();

    // Pass raw filesystem path — file:// prefix breaks MultipartFile.fromFile()
    debugPrint('[ComposerDatasource] sendMediaMessage — file: ${message.file}, type: ${message.type}');

    await CometChat.sendMediaMessage(
      message,
      onSuccess: (MediaMessage sentMessage) {
        completer.complete(sentMessage);
      },
      onError: (CometChatException e) {
        completer.completeError(
          MessageComposerDataSourceException(
            message: e.message ?? 'Failed to send media message',
            code: e.code,
            originalException: e,
          ),
        );
      },
    );

    return completer.future;
  }

  @override
  Future<CustomMessage> sendCustomMessage(CustomMessage message) async {
    final completer = Completer<CustomMessage>();

    CometChat.sendCustomMessage(
      message,
      onSuccess: (CustomMessage sentMessage) {
        completer.complete(sentMessage);
      },
      onError: (CometChatException e) {
        completer.completeError(
          MessageComposerDataSourceException(
            message: e.message ?? 'Failed to send custom message',
            code: e.code,
            originalException: e,
          ),
        );
      },
    );

    return completer.future;
  }

  @override
  Future<BaseMessage> editMessage(TextMessage message) async {
    final completer = Completer<BaseMessage>();

    CometChat.editMessage(
      message,
      onSuccess: (BaseMessage editedMessage) {
        completer.complete(editedMessage);
      },
      onError: (CometChatException e) {
        completer.completeError(
          MessageComposerDataSourceException(
            message: e.message ?? 'Failed to edit message',
            code: e.code,
            originalException: e,
          ),
        );
      },
    );

    return completer.future;
  }

  @override
  void startTyping({
    required String receiverUid,
    required String receiverType,
  }) {
    CometChat.startTyping(
      receiverUid: receiverUid,
      receiverType: receiverType,
    );
  }

  @override
  void endTyping({
    required String receiverUid,
    required String receiverType,
  }) {
    CometChat.endTyping(
      receiverUid: receiverUid,
      receiverType: receiverType,
    );
  }

  @override
  Future<User?> getLoggedInUser() async {
    return CometChat.getLoggedInUser();
  }
}
