import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/conversations_repository.dart';

/// Use case for marking a message as delivered
/// Handles business logic for delivery receipts
class MarkAsDeliveredUseCase {
  final ConversationsRepository repository;

  const MarkAsDeliveredUseCase(this.repository);

  /// Execute the use case to mark message as delivered
  ///
  /// [message] - The message to mark as delivered
  ///
  /// Returns `Result<void>` indicating success or failure
  Future<Result<void>> call(BaseMessage message) async {
    // Validate input - message ID should be a positive integer
    if (message.id == 0) {
      return const Failure(
        message: 'Invalid message ID',
        code: 'INVALID_MESSAGE_ID',
      );
    }

    return await repository.markAsDelivered(message);
  }
}
