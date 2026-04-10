import '../../../../../cometchat_chat_uikit.dart';

/// Implementation of MessageInformationRepository
///
/// Wraps data source operations in Result types for error handling,
/// following the Clean Architecture pattern.
///
/// Requirements: 4.2, 10.2, 10.3
class MessageInformationRepositoryImpl implements MessageInformationRepository {
  final MessageInformationDataSource dataSource;

  const MessageInformationRepositoryImpl({
    required this.dataSource,
  });

  /// Fetches message receipts for a given message ID.
  ///
  /// Wraps the data source call with Result pattern:
  /// - Returns [Success] with receipt list on successful fetch
  /// - Returns [Failure] on error with appropriate error message
  ///
  /// Requirements: 10.2, 10.3
  @override
  Future<Result<List<MessageReceipt>>> fetchMessageReceipts(
      int messageId) async {
    try {
      final receipts = await dataSource.fetchMessageReceipts(messageId);
      return Success(receipts);
    } on MessageInformationDataSourceException catch (e) {
      return Failure(
        message: 'Failed to fetch message receipts: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while fetching message receipts: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }
}
