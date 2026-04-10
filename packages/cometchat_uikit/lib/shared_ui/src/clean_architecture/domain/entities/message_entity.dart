import 'package:equatable/equatable.dart';

/// Domain entity representing a chat message
/// Pure Dart model with no dependencies on CometChat SDK
class MessageEntity extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String? receiverId;
  final String? receiverName;
  final int timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isDeleted;
  final String? deletedAt;
  final List<String>? attachmentUrls;
  final Map<String, dynamic>? metadata;
  final String? parentMessageId;
  final int? replyCount;
  final int? reactionCount;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.receiverId,
    this.receiverName,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isDeleted = false,
    this.deletedAt,
    this.attachmentUrls,
    this.metadata,
    this.parentMessageId,
    this.replyCount,
    this.reactionCount,
  });

  /// Create a copy of this message with some fields changed
  MessageEntity copyWith({
    String? id,
    String? text,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? receiverName,
    int? timestamp,
    MessageType? type,
    MessageStatus? status,
    bool? isDeleted,
    String? deletedAt,
    List<String>? attachmentUrls,
    Map<String, dynamic>? metadata,
    String? parentMessageId,
    int? replyCount,
    int? reactionCount,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      metadata: metadata ?? this.metadata,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      replyCount: replyCount ?? this.replyCount,
      reactionCount: reactionCount ?? this.reactionCount,
    );
  }

  /// Check if message is recent (sent within last hour)
  bool get isRecent {
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneHourMs = 60 * 60 * 1000;
    return (now - timestamp) < oneHourMs;
  }

  /// Check if message is from today
  bool get isFromToday {
    final now = DateTime.now();
    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day;
  }

  /// Check if message is a reply
  bool get isReply => parentMessageId != null && parentMessageId!.isNotEmpty;

  /// Check if message has reactions
  bool get hasReactions => reactionCount != null && reactionCount! > 0;

  /// Check if message has attachments
  bool get hasAttachments => attachmentUrls != null && attachmentUrls!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    text,
    senderId,
    senderName,
    senderAvatar,
    receiverId,
    receiverName,
    timestamp,
    type,
    status,
    isDeleted,
    deletedAt,
    attachmentUrls,
    metadata,
    parentMessageId,
    replyCount,
    reactionCount,
  ];
}

/// Enum for message types
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  custom,
}

/// Enum for message status
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error,
}

/// Extension methods for MessageType
extension MessageTypeExt on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.file:
        return 'File';
      case MessageType.location:
        return 'Location';
      case MessageType.custom:
        return 'Custom';
    }
  }

  bool get isMedia => [
    MessageType.image,
    MessageType.video,
    MessageType.audio,
    MessageType.file,
  ].contains(this);
}

/// Extension methods for MessageStatus
extension MessageStatusExt on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.error:
        return 'Error';
    }
  }

  bool get isFinal => this == MessageStatus.read || this == MessageStatus.error;
}
