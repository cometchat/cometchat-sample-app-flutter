import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for marking a message as read.
///
/// **Validates: Requirements 3.4**
class MarkAsReadUseCase {
  final MessageListRepository repository;

  const MarkAsReadUseCase(this.repository);

  /// Execute the use case to mark a message as read.
  Future<Result<void>> call({
    required BaseMessage message,
  }) async {
    if (message.id <= 0) {
      return const Failure(
        message: 'Message must have a valid ID',
        code: 'INVALID_MESSAGE_ID',
      );
    }

    return await repository.markAsRead(message);
  }
}
