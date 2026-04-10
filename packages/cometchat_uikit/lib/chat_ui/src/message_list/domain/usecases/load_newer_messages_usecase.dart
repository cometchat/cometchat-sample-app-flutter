import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_list_repository.dart';

/// Use case for loading newer messages for pagination (scroll down).
///
/// **Validates: Requirements 3.3**
class LoadNewerMessagesUseCase {
  final MessageListRepository repository;

  const LoadNewerMessagesUseCase(this.repository);

  /// Execute the use case to load newer messages for pagination.
  Future<Result<List<BaseMessage>>> call({
    required MessagesRequest request,
  }) async {
    return await repository.fetchNextMessages(request: request);
  }
}
