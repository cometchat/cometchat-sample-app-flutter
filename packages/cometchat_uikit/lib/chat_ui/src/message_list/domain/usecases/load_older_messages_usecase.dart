import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for loading older messages for pagination (scroll up).
///
/// **Validates: Requirements 3.2**
class LoadOlderMessagesUseCase {
  final MessageListRepository repository;

  const LoadOlderMessagesUseCase(this.repository);

  /// Execute the use case to load older messages for pagination.
  Future<Result<List<BaseMessage>>> call({
    required MessagesRequest request,
  }) async {
    return await repository.fetchPreviousMessages(request: request);
  }
}
