import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for marking a message as unread.
///
/// **Validates: Mark as Unread feature - Section 4.1**
class MarkAsUnreadUseCase {
  final MessageListRepository repository;

  const MarkAsUnreadUseCase(this.repository);

  /// Execute the use case to mark a message as unread.
  Future<Result<Conversation>> call({
    required BaseMessage message,
  }) async {
    if (message.id <= 0) {
      return const Failure(
        message: 'Message must have a valid ID',
        code: 'INVALID_MESSAGE_ID',
      );
    }

    if (message.parentMessageId > 0) {
      return const Failure(
        message: 'Cannot mark thread replies as unread',
        code: 'THREAD_REPLY_NOT_ALLOWED',
      );
    }

    return await repository.markMessageAsUnread(message);
  }
}
