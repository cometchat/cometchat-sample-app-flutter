import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for marking a notification feed item as read.
class MarkFeedReadUseCase {
  final NotificationFeedRepository repository;

  const MarkFeedReadUseCase(this.repository);

  /// Execute the use case to mark a feed item as read.
  ///
  /// This operation is idempotent.
  Future<Result<void>> call(NotificationFeedItem feedItem) async {
    return await repository.markAsRead(feedItem);
  }
}
