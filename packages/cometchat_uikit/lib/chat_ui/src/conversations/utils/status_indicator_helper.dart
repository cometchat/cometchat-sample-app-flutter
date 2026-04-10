import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';

/// Configuration for status indicator display.
class StatusIndicatorConfig {
  /// Whether to show the status indicator.
  final bool show;

  /// The color for the status indicator (for online status).
  final Color? color;

  /// The icon widget for the status indicator (for group types).
  final Widget? icon;

  const StatusIndicatorConfig({
    required this.show,
    this.color,
    this.icon,
  });
}

/// Utility class for determining status indicator configuration.
class StatusIndicatorHelper {
  /// Gets the status indicator configuration for a conversation.
  ///
  /// Returns a [StatusIndicatorConfig] that determines whether to show
  /// a status indicator and what type (color for user status, icon for group type).
  ///
  /// Parameters:
  /// - [conversation]: The conversation to get status indicator for
  /// - [hideUserStatus]: Whether to hide user online/offline status
  /// - [hideGroupType]: Whether to hide group type indicators
  static StatusIndicatorConfig getStatusIndicator({
    required Conversation conversation,
    required bool hideUserStatus,
    required bool hideGroupType,
  }) {
    if (conversation.conversationWith is User) {
      return _getUserStatusIndicator(
        conversation.conversationWith as User,
        hideUserStatus,
      );
    } else if (conversation.conversationWith is Group) {
      return _getGroupStatusIndicator(
        conversation.conversationWith as Group,
        hideGroupType,
      );
    }

    return const StatusIndicatorConfig(show: false);
  }

  /// Gets status indicator configuration for user conversations.
  static StatusIndicatorConfig _getUserStatusIndicator(
    User user,
    bool hideUserStatus,
  ) {
    if (hideUserStatus) {
      return const StatusIndicatorConfig(show: false);
    }

    // Show green indicator for online users
    final isOnline = user.status == CometChatUserStatus.online;
    return StatusIndicatorConfig(
      show: isOnline,
      color: isOnline ? Colors.green : null,
      icon: null,
    );
  }

  /// Gets status indicator configuration for group conversations.
  static StatusIndicatorConfig _getGroupStatusIndicator(
    Group group,
    bool hideGroupType,
  ) {
    if (hideGroupType) {
      return const StatusIndicatorConfig(show: false);
    }

    // Show icon for private and protected groups
    if (group.type == CometChatGroupType.private) {
      return const StatusIndicatorConfig(
        show: true,
        color: null,
        icon: Icon(Icons.shield, size: 7),
      );
    } else if (group.type == CometChatGroupType.password) {
      return const StatusIndicatorConfig(
        show: true,
        color: null,
        icon: Icon(Icons.lock, size: 7),
      );
    }

    // Public groups don't show an indicator
    return const StatusIndicatorConfig(show: false);
  }
}
