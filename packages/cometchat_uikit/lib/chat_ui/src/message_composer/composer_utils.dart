import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Utility helpers for the message composer.
class ComposerUtils {
  ComposerUtils._();

  /// Returns a small icon widget representing the media type of [message],
  /// or null for plain text messages.
  static Widget? getReplyIcon(
    BaseMessage message,
    BuildContext context,
    Color? color,
  ) {
    if (message is! MediaMessage) return null;

    IconData icon;
    switch (message.type) {
      case CometChatMessageType.image:
        icon = Icons.image_outlined;
        break;
      case CometChatMessageType.video:
        icon = Icons.videocam_outlined;
        break;
      case CometChatMessageType.audio:
        icon = Icons.mic_outlined;
        break;
      case CometChatMessageType.file:
        icon = Icons.insert_drive_file_outlined;
        break;
      default:
        icon = Icons.attachment_outlined;
    }

    return Icon(icon, size: 14, color: color);
  }
}
