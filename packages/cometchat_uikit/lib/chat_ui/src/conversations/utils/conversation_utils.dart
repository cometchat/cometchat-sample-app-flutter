import 'package:flutter/material.dart' hide Action;
import '../../../../cometchat_chat_uikit.dart';
import 'action_type_constants.dart';

/// Utility class for conversation-related operations.
///
/// Provides helper methods for extracting and formatting conversation data
/// for display in the conversation list item.
class ConversationUtils {
  /// Gets the conversation title (user name or group name).
  ///
  /// Returns the name of the user or group that the conversation is with.
  /// Returns empty string if the conversation participant is not found.
  static String getConversationTitle(Conversation conversation) {
    if (conversation.conversationWith is User) {
      return (conversation.conversationWith as User).name;
    } else if (conversation.conversationWith is Group) {
      return (conversation.conversationWith as Group).name;
    }
    return '';
  }

  /// Gets the conversation avatar URL.
  ///
  /// Returns the avatar URL for users or icon URL for groups.
  /// Returns null if no avatar/icon is available.
  static String? getConversationAvatar(Conversation conversation) {
    if (conversation.conversationWith is User) {
      return (conversation.conversationWith as User).avatar;
    } else if (conversation.conversationWith is Group) {
      return (conversation.conversationWith as Group).icon;
    }
    return null;
  }

  /// Gets the last message text with appropriate formatting.
  ///
  /// Handles different message types and returns appropriate placeholder text.
  /// Returns localized strings for media messages, custom messages, etc.
  static String getLastMessageText(
    BuildContext context,
    BaseMessage? message,
  ) {
    if (message == null) {
      return Translations.of(context).tapToStartConversation;
    }

    // Check if message is deleted
    if (message.deletedAt != null) {
      return Translations.of(context).thisMessageDeleted;
    }

    if (message is TextMessage) {
      return message.text;
    } else if (message is MediaMessage) {
      return _getMediaMessageText(context, message);
    } else if (message is CustomMessage) {
      return _getCustomMessageText(context, message);
    } else if (message is Action) {
      return _getActionMessageText(context, message);
    }

    return '';
  }

  /// Gets the message type icon for display in subtitle.
  ///
  /// Returns appropriate icon for different message types.
  /// Returns null for plain text messages without special features.
  static IconData? getMessageTypeIcon(BaseMessage? message) {
    if (message == null) return null;

    // Check if message is deleted
    if (message.deletedAt != null) {
      return Icons.delete_outline;
    }

    // Check if message is a thread reply
    if (message.parentMessageId != 0) {
      return Icons.forum_outlined;
    }

    if (message is MediaMessage) {
      return _getMediaMessageIcon(message);
    } else if (message is CustomMessage) {
      return _getCustomMessageIcon(message);
    }

    return null;
  }

  /// Gets the sender name prefix for group messages.
  ///
  /// Returns "You: " for messages sent by current user.
  /// Returns "Name: " for messages sent by other users.
  /// Returns empty string for user-to-user conversations.
  static String getMessagePrefix(
    BuildContext context,
    BaseMessage message,
    String? loggedInUserId,
  ) {
    // Only show prefix for group messages
    if (message.receiverType != CometChatReceiverType.group) {
      return '';
    }

    final sender = message.sender;
    if (sender == null) return '';

    if (sender.uid == loggedInUserId) {
      return '${Translations.of(context).you}: ';
    } else {
      return '${sender.name}: ';
    }
  }

  // Private helper methods

  static String _getMediaMessageText(BuildContext context, MediaMessage message) {
    switch (message.type) {
      case CometChatMessageType.image:
        // Check if it's a GIF
        if (message.attachment?.toString().contains('.gif') == true) {
          return '📷 GIF';
        }
        return Translations.of(context).messageImage;
      case CometChatMessageType.video:
        return Translations.of(context).messageVideo;
      case CometChatMessageType.audio:
        return Translations.of(context).messageAudio;
      case CometChatMessageType.file:
        return Translations.of(context).messageFile;
      default:
        return Translations.of(context).messageFile;
    }
  }

  static String _getCustomMessageText(BuildContext context, CustomMessage message) {
    // Check for conversation text first
    final conversationText = message.conversationText;
    if (conversationText != null && conversationText.isNotEmpty) {
      return conversationText;
    }

    // Handle specific custom message types
    switch (message.type) {
      case 'extension_poll':
        return Translations.of(context).customMessagePoll;
      case 'extension_sticker':
        return Translations.of(context).customMessageSticker;
      case 'extension_location':
        return Translations.of(context).location;
      case 'extension_document':
        return Translations.of(context).customMessageDocument;
      case 'extension_whiteboard':
        return Translations.of(context).customMessageWhiteboard;
      default:
        return message.type;
    }
  }

  static String _getActionMessageText(BuildContext context, Action action) {
    final actionBy = action.actionBy as User?;
    final actionOn = action.actionOn as User?;

    switch (action.action) {
      case CometChatActionType.joined:
        return '${actionBy?.name ?? ''} ${Translations.of(context).joined}';
      case CometChatActionType.left:
        return '${actionBy?.name ?? ''} ${Translations.of(context).left}';
      case CometChatActionType.kicked:
        return '${actionBy?.name ?? ''} ${Translations.of(context).kick} ${actionOn?.name ?? ''}';
      case CometChatActionType.banned:
        return '${actionBy?.name ?? ''} ${Translations.of(context).ban} ${actionOn?.name ?? ''}';
      case CometChatActionType.unbanned:
        return '${actionBy?.name ?? ''} ${Translations.of(context).unban} ${actionOn?.name ?? ''}';
      case CometChatActionType.added:
        return '${actionBy?.name ?? ''} ${Translations.of(context).add} ${actionOn?.name ?? ''}';
      default:
        return action.message ?? '';
    }
  }

  static IconData? _getMediaMessageIcon(MediaMessage message) {
    switch (message.type) {
      case CometChatMessageType.image:
        // Check if it's a GIF
        if (message.attachment?.toString().contains('.gif') == true) {
          return Icons.gif;
        }
        return Icons.image_outlined;
      case CometChatMessageType.video:
        return Icons.videocam_outlined;
      case CometChatMessageType.audio:
        return Icons.mic_outlined;
      case CometChatMessageType.file:
        return Icons.insert_drive_file_outlined;
      default:
        return null;
    }
  }

  static IconData? _getCustomMessageIcon(CustomMessage message) {
    switch (message.type) {
      case 'extension_poll':
        return Icons.poll_outlined;
      case 'extension_sticker':
        return Icons.emoji_emotions_outlined;
      case 'extension_location':
        return Icons.location_on_outlined;
      case 'extension_document':
        return Icons.description_outlined;
      case 'extension_whiteboard':
        return Icons.dashboard_outlined;
      default:
        return null;
    }
  }
}
