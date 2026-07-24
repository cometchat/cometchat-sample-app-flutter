import '../entities/message_entity.dart';
import '../entities/user_entity.dart';
import '../entities/group_entity.dart';
import '../../core/result.dart';

/// Abstract repository for message operations
/// Defines contract for message-related use cases
abstract class MessageRepository {
  /// Get all messages for a conversation
  Future<Result<List<MessageEntity>>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  });

  /// Get a single message by ID
  Future<Result<MessageEntity>> getMessage(String messageId);

  /// Send a text message
  Future<Result<MessageEntity>> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  });

  /// Send a media message (image, video, audio, file)
  Future<Result<MessageEntity>> sendMediaMessage({
    required String conversationId,
    required String filePath,
    required MessageType type,
    String? caption,
  });

  /// Edit a message
  Future<Result<MessageEntity>> editMessage({
    required String messageId,
    required String newText,
  });

  /// Delete a message
  Future<Result<void>> deleteMessage(String messageId);

  /// React to a message
  Future<Result<void>> reactToMessage({
    required String messageId,
    required String reaction,
  });

  /// Search messages in a conversation
  Future<Result<List<MessageEntity>>> searchMessages({
    required String conversationId,
    required String query,
  });

  /// Stream of new messages
  Stream<MessageEntity> getMessagesStream(String conversationId);

  /// Get unread message count
  Future<Result<int>> getUnreadCount();

  /// Mark messages as read
  Future<Result<void>> markAsRead({required List<String> messageIds});
}

/// Abstract repository for user operations
abstract class UserRepository {
  /// Get user by ID
  Future<Result<UserEntity>> getUser(String userId);

  /// Get all contacts
  Future<Result<List<UserEntity>>> getContacts({
    int limit = 50,
    int offset = 0,
  });

  /// Search users
  Future<Result<List<UserEntity>>> searchUsers(String query);

  /// Get current user
  Future<Result<UserEntity>> getCurrentUser();

  /// Update user status
  Future<Result<void>> updateUserStatus(String status);

  /// Block user
  Future<Result<void>> blockUser(String userId);

  /// Unblock user
  Future<Result<void>> unblockUser(String userId);

  /// Stream of user status changes
  Stream<UserEntity> getUserStatusStream(String userId);
}

/// Abstract repository for group operations
abstract class GroupRepository {
  /// Get group by ID
  Future<Result<GroupEntity>> getGroup(String groupId);

  /// Get all groups
  Future<Result<List<GroupEntity>>> getGroups({int limit = 50, int offset = 0});

  /// Search groups
  Future<Result<List<GroupEntity>>> searchGroups(String query);

  /// Create a new group
  Future<Result<GroupEntity>> createGroup({
    required String name,
    required String type,
    String? icon,
    String? description,
  });

  /// Update group information
  Future<Result<void>> updateGroup({
    required String groupId,
    String? name,
    String? icon,
    String? description,
  });

  /// Add member to group
  Future<Result<void>> addMember({
    required String groupId,
    required String userId,
  });

  /// Remove member from group
  Future<Result<void>> removeMember({
    required String groupId,
    required String userId,
  });

  /// Delete group
  Future<Result<void>> deleteGroup(String groupId);

  /// Stream of group updates
  Stream<GroupEntity> getGroupUpdatesStream(String groupId);
}
