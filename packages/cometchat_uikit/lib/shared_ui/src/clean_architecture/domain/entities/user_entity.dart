import 'package:equatable/equatable.dart';

/// Domain entity representing a chat user
/// Pure Dart model with no dependencies on CometChat SDK
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String? status;
  final bool isOnline;
  final int? lastActive;
  final String? statusMessage;
  final Map<String, dynamic>? metadata;

  const UserEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.status,
    this.isOnline = false,
    this.lastActive,
    this.statusMessage,
    this.metadata,
  });

  /// Create a copy of this user with some fields changed
  UserEntity copyWith({
    String? id,
    String? name,
    String? avatar,
    String? status,
    bool? isOnline,
    int? lastActive,
    String? statusMessage,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      statusMessage: statusMessage ?? this.statusMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if user has a valid avatar URL
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// Get user status display text
  String get statusDisplay {
    if (isOnline) return 'Online';
    if (lastActive != null) {
      final difference = DateTime.now().millisecondsSinceEpoch - lastActive!;
      if (difference < 60000) return 'Active now';
      if (difference < 3600000) {
        final minutes = (difference / 60000).floor();
        return 'Active $minutes min ago';
      }
      if (difference < 86400000) {
        final hours = (difference / 3600000).floor();
        return 'Active $hours h ago';
      }
    }
    return 'Offline';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    status,
    isOnline,
    lastActive,
    statusMessage,
    metadata,
  ];
}
