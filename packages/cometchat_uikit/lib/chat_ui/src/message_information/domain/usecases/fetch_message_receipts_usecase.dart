import 'package:cometchat_sdk/cometchat_sdk.dart';

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_information_repository.dart';

/// Use case for fetching message receipts.
///
/// Handles business logic for retrieving message receipts (read/delivered status)
/// for a specific message. This use case delegates to the repository to fetch
/// receipts from the SDK.
///
/// **Validates: Requirements 10.1, 10.2, 10.3**
class FetchMessageReceiptsUseCase {
  final MessageInformationRepository repository;

  const FetchMessageReceiptsUseCase(this.repository);

  /// Execute the use case to fetch message receipts.
  ///
  /// [messageId] - The ID of the message to fetch receipts for.
  ///
  /// Returns [Result<List<MessageReceipt>>] containing receipts on success,
  /// or a [Failure] on error.
  Future<Result<List<MessageReceipt>>> call(int messageId) async {
    // Validate input parameters
    if (messageId <= 0) {
      return const Failure(
        message: 'Message ID must be greater than 0',
        code: 'INVALID_MESSAGE_ID',
      );
    }

    // Delegate to repository
    return await repository.fetchMessageReceipts(messageId);
  }
}
