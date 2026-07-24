import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for marking a notification feed item as delivered.
class MarkFeedDeliveredUseCase {
  final NotificationFeedRepository repository;

  const MarkFeedDeliveredUseCase(this.repository);

  /// Execute the use case to mark a feed item as delivered.
  ///
  /// This operation is idempotent.
  Future<Result<void>> call(NotificationFeedItem feedItem) async {
    return await repository.markAsDelivered(feedItem);
  }
}
