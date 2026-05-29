import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for fetching a single notification feed item by ID.
/// Used for deep linking — fetching a specific feed item by its ID.
class GetFeedItemUseCase {
  final NotificationFeedRepository repository;

  const GetFeedItemUseCase(this.repository);

  /// Execute the use case to get a single feed item.
  ///
  /// [id] - The unique ID of the feed item to fetch.
  Future<Result<NotificationFeedItem>> call(String id) async {
    if (id.isEmpty) {
      return const Failure(
        message: 'Feed item ID cannot be empty',
        code: 'INVALID_ID',
      );
    }
    return await repository.getItem(id);
  }
}
