import '../../../../../../cometchat_chat_uikit.dart';

/// Repository interface for message information operations.
///
/// Defines the contract for message information data access following
/// Clean Architecture patterns. This interface abstracts the data layer
/// from the domain layer, allowing for different implementations
/// (e.g., SDK-based, mock for testing).
abstract class MessageInformationRepository {
  /// Fetches message receipts for a given message ID.
  ///
  /// Returns a [Result] containing a list of [MessageReceipt] on success,
  /// or a [Failure] on error.
  ///
  /// [messageId] - The ID of the message to fetch receipts for.
  Future<Result<List<MessageReceipt>>> fetchMessageReceipts(int messageId);
}
