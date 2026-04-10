import '../../../../core/result.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Repository Implementation - Mediates between Use Cases and Data Sources
/// This is the Data Layer connecting to Domain Layer
///
/// Responsibilities:
/// 1. Delegate calls to appropriate data sources
/// 2. Handle any cross-datasource logic
/// 3. Provide a clean interface to use cases
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  /// Constructor accepts injected data source
  /// This allows easy testing and switching implementations
  NotificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<NotificationEntity>> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
  }) async {
    return remoteDataSource.sendNotification(
      title: title,
      message: message,
      type: type,
      priority: priority,
      data: data,
    );
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    return remoteDataSource.getNotifications(
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Result<void>> markAsRead({
    required String notificationId,
  }) async {
    return remoteDataSource.markAsRead(notificationId: notificationId);
  }

  @override
  Future<Result<void>> deleteNotification({
    required String notificationId,
  }) async {
    return remoteDataSource.deleteNotification(notificationId: notificationId);
  }

  @override
  Future<Result<void>> clearAll() async {
    return remoteDataSource.clearAll();
  }

  @override
  Stream<NotificationEntity> getNotificationStream() {
    return remoteDataSource.getNotificationStream();
  }
}
