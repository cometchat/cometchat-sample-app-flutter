import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for getting the total unread count for the notification feed.
class GetUnreadCountUseCase {
  final NotificationFeedRepository repository;

  const GetUnreadCountUseCase(this.repository);

  /// Execute the use case to get the unread count.
  Future<Result<int>> call() async {
    return await repository.getUnreadCount();
  }
}
