import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for message composer operations
/// Defines the contract for message sending and composition
abstract class MessageComposerRepository {
  /// Send a text message
  Future<Result<TextMessage>> sendTextMessage(TextMessage message);

  /// Send a media message (image, video, audio, file)
  Future<Result<MediaMessage>> sendMediaMessage(MediaMessage message);

  /// Send a custom message
  Future<Result<CustomMessage>> sendCustomMessage(CustomMessage message);

  /// Edit an existing text message
  Future<Result<BaseMessage>> editMessage(TextMessage message);

  /// Start typing indicator
  Future<Result<void>> startTyping({
    required String receiverUid,
    required String receiverType,
  });

  /// End typing indicator
  Future<Result<void>> endTyping({
    required String receiverUid,
    required String receiverType,
  });

  /// Get the currently logged-in user
  Future<Result<User?>> getLoggedInUser();
}
