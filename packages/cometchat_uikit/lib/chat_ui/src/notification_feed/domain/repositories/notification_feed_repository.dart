import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for notification feed data operations.
/// Defines the contract for notification feed data access.
abstract class NotificationFeedRepository {
  /// Fetch notification feed items using the provided request builder.
  ///
  /// The request builder manages cursor-based pagination internally.
  /// Call this repeatedly to paginate through results.
  Future<Result<List<NotificationFeedItem>>> fetchFeedItems(
    NotificationFeedRequest request,
  );

  /// Fetch notification categories using the provided request builder.
  ///
  /// Categories are used for filter chips in the UI.
  Future<Result<List<NotificationCategory>>> fetchCategories(
    NotificationCategoriesRequest request,
  );

  /// Mark a notification feed item as delivered.
  ///
  /// This operation is idempotent — calling multiple times has no side effects.
  Future<Result<void>> markAsDelivered(NotificationFeedItem feedItem);

  /// Mark a notification feed item as read.
  ///
  /// This operation is idempotent — calling multiple times has no side effects.
  Future<Result<void>> markAsRead(NotificationFeedItem feedItem);

  /// Report engagement for a notification feed item.
  ///
  /// [interactionString] describes the type of engagement
  /// (e.g., "viewed", "clicked"). Accepts any free-form string.
  Future<Result<void>> reportEngagement(
    NotificationFeedItem feedItem,
    String interactionString,
  );

  /// Get the total unread count for the notification feed.
  Future<Result<int>> getUnreadCount();

  /// Fetch a single notification feed item by its ID.
  ///
  /// Used for deep linking — fetching a specific feed item by its ID.
  Future<Result<NotificationFeedItem>> getItem(String id);
}
