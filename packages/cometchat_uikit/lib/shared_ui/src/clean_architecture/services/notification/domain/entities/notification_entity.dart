/// Notification Entity - Domain Model
/// Represents a notification in the domain layer
/// Pure data class with no external dependencies
class NotificationEntity {
  /// Unique identifier
  final String id;

  /// Notification title
  final String title;

  /// Notification message/body
  final String message;

  /// Notification type
  final NotificationType type;

  /// Priority level
  final NotificationPriority priority;

  /// Whether notification was read
  final bool isRead;

  /// Data payload
  final Map<String, dynamic> data;

  /// When notification was created
  final DateTime createdAt;

  /// Constructor
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.data,
    required this.createdAt,
  });

  /// Copy with method for immutability
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationEntity{id: $id, title: $title, message: $message, type: $type, priority: $priority, isRead: $isRead, createdAt: $createdAt}';
  }
}

/// Enum for notification types
enum NotificationType {
  message,
  call,
  user,
  group,
  system,
  custom,
}

/// Enum for notification priority
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}
