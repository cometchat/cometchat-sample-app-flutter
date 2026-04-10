import '../../../../core/result.dart';
import '../entities/notification_entity.dart';

/// Abstract repository for Notification operations
/// Defines the contract that data layer must implement
/// NO DEPENDENCIES on external packages or implementation details
///
/// CURRENT CAPABILITIES:
/// - sendNotification() - Send a notification
/// - getNotifications() - Get list of notifications
/// - markAsRead() - Mark notification as read
/// - deleteNotification() - Delete a notification
/// - clearAll() - Clear all notifications
abstract class NotificationRepository {
  /// Send a notification
  Future<Result<NotificationEntity>> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  });

  /// Get list of notifications
  Future<Result<List<NotificationEntity>>> getNotifications({
    required int limit,
    required int offset,
  });

  /// Mark notification as read
  Future<Result<void>> markAsRead({
    required String notificationId,
  });

  /// Delete a notification
  Future<Result<void>> deleteNotification({
    required String notificationId,
  });

  /// Clear all notifications
  Future<Result<void>> clearAll();

  /// Stream of notification updates
  Stream<NotificationEntity> getNotificationStream();
}
