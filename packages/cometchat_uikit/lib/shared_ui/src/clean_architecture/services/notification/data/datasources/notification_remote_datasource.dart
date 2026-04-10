import 'dart:async';

import '../../../../core/result.dart';
import '../../domain/entities/notification_entity.dart';

/// Remote Data Source - Wraps existing notification system
/// This bridges the new clean architecture with native notification capabilities
abstract class NotificationRemoteDataSource {
  /// Send notification
  Future<Result<NotificationEntity>> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  });

  /// Get notifications list
  Future<Result<List<NotificationEntity>>> getNotifications({
    required int limit,
    required int offset,
  });

  /// Mark as read
  Future<Result<void>> markAsRead({
    required String notificationId,
  });

  /// Delete notification
  Future<Result<void>> deleteNotification({
    required String notificationId,
  });

  /// Clear all
  Future<Result<void>> clearAll();

  /// Stream notifications
  Stream<NotificationEntity> getNotificationStream();
}

/// Implementation using existing notification system
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  /// Map to store notifications in memory (can be replaced with local db)
  final Map<String, NotificationEntity> _notifications = {};
  
  /// Stream controller for notification updates
  late final StreamController<NotificationEntity> _notificationController =
      StreamController<NotificationEntity>.broadcast();

  /// Constructor
  NotificationRemoteDataSourceImpl();

  @override
  Future<Result<NotificationEntity>> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  }) async {
    try {
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        priority: priority,
        isRead: false,
        data: data,
        createdAt: DateTime.now(),
      );

      _notifications[notification.id] = notification;
      _notificationController.add(notification);

      return Success(notification);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to send notification: ${e.toString()}',
        code: 'NOTIFICATION_SEND_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      final notifications = _notifications.values.toList();
      
      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply pagination
      final paginated = notifications
          .skip(offset)
          .take(limit)
          .toList();

      return Success(paginated);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to get notifications: ${e.toString()}',
        code: 'NOTIFICATION_GET_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      if (_notifications.containsKey(notificationId)) {
        final notification = _notifications[notificationId]!;
        _notifications[notificationId] = notification.copyWith(isRead: true);
        _notificationController.add(_notifications[notificationId]!);
      }
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to mark as read: ${e.toString()}',
        code: 'NOTIFICATION_MARK_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      _notifications.remove(notificationId);
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to delete notification: ${e.toString()}',
        code: 'NOTIFICATION_DELETE_ERROR',
        exception: e,
      );
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      _notifications.clear();
      return const Success(null);
    } on Exception catch (e) {
      return Failure(
        message: 'Failed to clear notifications: ${e.toString()}',
        code: 'NOTIFICATION_CLEAR_ERROR',
        exception: e,
      );
    }
  }

  @override
  Stream<NotificationEntity> getNotificationStream() {
    return _notificationController.stream;
  }
}
