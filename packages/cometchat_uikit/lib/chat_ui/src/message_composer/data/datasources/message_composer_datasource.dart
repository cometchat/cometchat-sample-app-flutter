import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Exception thrown when message composer data source operations fail
class MessageComposerDataSourceException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const MessageComposerDataSourceException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() =>
      'MessageComposerDataSourceException(message: $message, code: $code)';
}

/// Abstract interface for message composer data source
/// Handles all interactions with CometChat SDK for message composition
abstract class MessageComposerDataSource {
  /// Send a text message
  Future<TextMessage> sendTextMessage(TextMessage message);

  /// Send a media message (image, video, audio, file)
  Future<MediaMessage> sendMediaMessage(MediaMessage message);

  /// Send a custom message
  Future<CustomMessage> sendCustomMessage(CustomMessage message);

  /// Edit an existing message (text, or a caption-bearing media message)
  Future<BaseMessage> editMessage(BaseMessage message);

  /// Start typing indicator
  void startTyping({required String receiverUid, required String receiverType});

  /// End typing indicator
  void endTyping({required String receiverUid, required String receiverType});

  /// Get the currently logged-in user
  Future<User?> getLoggedInUser();
}
