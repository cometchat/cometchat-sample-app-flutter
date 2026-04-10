import '../../domain/entities/message_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/group_entity.dart';

/// Mapper to convert CometChat SDK BaseMessage to MessageEntity
class MessageMapper {
  /// Convert SDK BaseMessage to domain MessageEntity
  /// Note: Adjust property names based on actual SDK BaseMessage interface
  static MessageEntity fromSDK(dynamic message) {
    // This is a placeholder mapper - update property names to match actual SDK
    return MessageEntity(
      id: message['id']?.toString() ?? 'unknown',
      text: _extractText(message),
      senderId: message['senderId'] ?? '',
      senderName: message['senderName'] ?? 'Unknown',
      senderAvatar: message['senderAvatar'],
      receiverId: null,
      receiverName: null,
      timestamp: (message['timestamp'] ?? 0) as int,
      type: MessageType.text,
      status: MessageStatus.sent,
      isDeleted: false,
      deletedAt: null,
      attachmentUrls: null,
      metadata: message['metadata'],
      parentMessageId: null,
      replyCount: null,
      reactionCount: null,
    );
  }

  /// Convert list of SDK messages to domain entities
  static List<MessageEntity> fromSDKList(List<dynamic> messages) {
    return messages.map((msg) => fromSDK(msg)).toList();
  }

  // Helper methods

  static String _extractText(dynamic message) {
    return message['text'] ?? message['caption'] ?? '';
  }
}

/// Mapper to convert CometChat SDK User to UserEntity
class UserMapper {
  /// Convert SDK User to domain UserEntity
  /// Note: Adjust property names based on actual SDK User interface
  static UserEntity fromSDK(dynamic user) {
    return UserEntity(
      id: user['id'] ?? 'unknown',
      name: user['name'] ?? 'Unknown',
      avatar: user['avatar'],
      status: user['status'],
      isOnline: user['status'] == 'online',
      lastActive: user['lastActive'],
      statusMessage: user['statusMessage'],
      metadata: user['metadata'],
    );
  }

  /// Convert list of SDK users to domain entities
  static List<UserEntity> fromSDKList(List<dynamic> users) {
    return users.map((user) => fromSDK(user)).toList();
  }
}

/// Mapper to convert CometChat SDK Group to GroupEntity
class GroupMapper {
  /// Convert SDK Group to domain GroupEntity
  /// Note: Adjust property names based on actual SDK Group interface
  static GroupEntity fromSDK(dynamic group) {
    return GroupEntity(
      id: group['id'] ?? 'unknown',
      name: group['name'] ?? 'Unknown',
      icon: group['icon'],
      description: group['description'],
      owner: group['owner'] ?? '',
      memberCount: group['memberCount'] ?? 0,
      members: const [],
      metadata: group['metadata'],
      type: group['type'] ?? 'public',
    );
  }

  /// Convert list of SDK groups to domain entities
  static List<GroupEntity> fromSDKList(List<dynamic> groups) {
    return groups.map((group) => fromSDK(group)).toList();
  }
}
