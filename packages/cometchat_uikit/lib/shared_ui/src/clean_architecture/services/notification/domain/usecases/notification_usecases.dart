import '../../../../core/result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Use Case for sending a notification
class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase({required this.repository});

  Future<Result<NotificationEntity>> call({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  }) {
    return repository.sendNotification(
      title: title,
      message: message,
      type: type,
      priority: priority,
      data: data,
    );
  }
}

/// Use Case for getting notifications
class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  Future<Result<List<NotificationEntity>>> call({
    required int limit,
    required int offset,
  }) {
    return repository.getNotifications(limit: limit, offset: offset);
  }
}

/// Use Case for marking notification as read
class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  Future<Result<void>> call({required String notificationId}) {
    return repository.markAsRead(notificationId: notificationId);
  }
}

/// Use Case for deleting notification
class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase({required this.repository});

  Future<Result<void>> call({required String notificationId}) {
    return repository.deleteNotification(notificationId: notificationId);
  }
}

/// Use Case for clearing all notifications
class ClearAllNotificationsUseCase {
  final NotificationRepository repository;

  ClearAllNotificationsUseCase({required this.repository});

  Future<Result<void>> call() {
    return repository.clearAll();
  }
}

/// Use Case for getting notification stream
class GetNotificationStreamUseCase {
  final NotificationRepository repository;

  GetNotificationStreamUseCase({required this.repository});

  Stream<NotificationEntity> call() {
    return repository.getNotificationStream();
  }
}
