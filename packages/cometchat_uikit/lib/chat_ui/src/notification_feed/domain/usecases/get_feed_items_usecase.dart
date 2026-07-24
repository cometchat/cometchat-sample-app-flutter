import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for fetching notification feed items with pagination.
class GetFeedItemsUseCase {
  final NotificationFeedRepository repository;

  const GetFeedItemsUseCase(this.repository);

  /// Execute the use case to fetch feed items.
  ///
  /// [request] - The built NotificationFeedRequest with pagination state.
  Future<Result<List<NotificationFeedItem>>> call(
    NotificationFeedRequest request,
  ) async {
    return await repository.fetchFeedItems(request);
  }
}
