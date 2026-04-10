import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for marking a message as delivered.
///
/// **Validates: Requirements 3.5**
class MarkAsDeliveredUseCase {
  final MessageListRepository repository;

  const MarkAsDeliveredUseCase(this.repository);

  /// Execute the use case to mark a message as delivered.
  Future<Result<void>> call({
    required BaseMessage message,
  }) async {
    if (message.id <= 0) {
      return const Failure(
        message: 'Message must have a valid ID',
        code: 'INVALID_MESSAGE_ID',
      );
    }

    return await repository.markAsDelivered(message);
  }
}
