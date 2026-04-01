import 'dart:convert';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sample_app_push_notifications/notifications/services/android_notification_service/firebase_services.dart';
import 'package:sample_app_push_notifications/notifications/services/android_notification_service/voip_notification_handler.dart';
import 'package:sample_app_push_notifications/notifications/services/cometchat_service/cometchat_services.dart';
import 'package:sample_app_push_notifications/notifications/services/globals.dart';
import 'package:sample_app_push_notifications/utils/initialize_cometchat.dart';

import '../../../messages/messages.dart';
import '../../models/notification_date_model.dart';
import '../../models/notification_message_type.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Tracks accumulated message lines per conversation for inbox-style
  /// notifications. Key = conversationId, Value = list of message bodies.
  static final Map<String, List<String>> _conversationMessages = {};

  /// Displays a local notification based on the incoming FCM [RemoteMessage].
  ///
  /// Uses a single notification per conversation that gets updated with each
  /// new message using InboxStyleInformation. This ensures notifications are
  /// visually grouped on all Android devices including Samsung One UI.
  static void showNotification(Map<String, dynamic> notificationData,
      RemoteMessage remoteMessage, String? conversationId, bool isAgentic) async {
    print("[FCM] Showing local notification with data: $notificationData");
    print("[FCM] Showing local notification conversationId: $conversationId");

    final unreadCount = notificationData['unreadMessageCount']?.toString();

    int unreadMessageCount = int.tryParse(unreadCount ?? '') ?? 0;

    if (unreadMessageCount >= 0) {
      try {
        await AppBadgePlus.updateBadge(unreadMessageCount);
        print('Badge count updated: $unreadMessageCount');
      } catch (e) {
        print('Error updating badge count: $e');
      }
    } else {
      print('Invalid badge count (negative): $unreadMessageCount');
    }

    if(isAgentic) {
      print("[FCM] Agentic mode - skipping local notification.");
      return;
    }

    // Encode the message data to JSON for use as payload (e.g., on notification tap)
    String? jsonPayload;
    try {
      jsonPayload = jsonEncode(remoteMessage.data);
    } catch (e) {
      debugPrint("[FCM] Failed to encode notification data: ${e.toString()}");
    }

    // Skip showing notification if it's of type "call"
    if (remoteMessage.data["type"]?.toString() == typeCall) {
      debugPrint("[FCM] Skipping notification for call type.");
      debugPrint("[FCM] Skipping notification for call type ${remoteMessage.data['sessionId']}");
      VoipNotificationHandler.activeCallSession = remoteMessage.data['sessionId'] ?? "";
      return;
    }

    // Skip showing notification if it matches the currently active conversation
    final notifConversationId = notificationData["conversationId"]?.toString() ?? '';
    if (conversationId != null &&
        conversationId.isNotEmpty &&
        conversationId == notifConversationId) {
      debugPrint(
          "[FCM] Skipping notification as it matches active conversation.");
      // Clear accumulated messages for this conversation since user is viewing it
      _conversationMessages.remove(notifConversationId);
      return;
    }

    // Use a stable notification ID per conversation so each new message
    // replaces the previous notification instead of creating a new one.
    // This works reliably on all Android devices including Samsung One UI.
    final int notificationId = notifConversationId.isNotEmpty
        ? notifConversationId.hashCode
        : DateTime.now().microsecondsSinceEpoch.hashCode;

    // Accumulate message lines for this conversation
    final String messageBody = FormatPatterns.stripFormatting(notificationData['body']?.toString() ?? '');
    _conversationMessages.putIfAbsent(notifConversationId, () => []);
    _conversationMessages[notifConversationId]!.add(messageBody);

    final messages = _conversationMessages[notifConversationId]!;
    final String title = notificationData['title']?.toString() ?? '';

    // Build notification style based on message count
    StyleInformation styleInformation;
    String bodyText;

    if (messages.length == 1) {
      // Single message — use default style
      styleInformation = const DefaultStyleInformation(false, false);
      bodyText = messageBody;
    } else {
      // Multiple messages — use InboxStyle to show stacked message lines
      styleInformation = InboxStyleInformation(
        messages,
        contentTitle: title,
        summaryText: unreadMessageCount > 0
            ? '$unreadMessageCount unread ${unreadMessageCount == 1 ? 'message' : 'messages'}'
            : '${messages.length} messages',
      );
      bodyText = messageBody; // Latest message shown as body fallback
    }

    final androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
      styleInformation: styleInformation,
      subText: unreadMessageCount > 0
          ? '$unreadMessageCount unread ${unreadMessageCount == 1 ? 'message' : 'messages'}'
          : null,
      // number shows the count badge on the notification icon (Samsung)
      number: messages.length > 1 ? messages.length : null,
    );

    final platformChannelSpecifics = NotificationDetails(android: androidDetails);

    String? notificationBody = notificationData['body'];
    if (notificationBody != null) {
      notificationBody = FormatPatterns.stripFormatting(notificationBody);
    }
    // Show (or replace) the notification for this conversation
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      notificationBody,
      platformChannelSpecifics,
      payload: jsonPayload,
    );
  }

  /// Clears the accumulated messages for a conversation.
  /// Call this when the user opens a conversation to reset the notification state.
  static void clearConversationMessages(String conversationId) {
    _conversationMessages.remove(conversationId);
  }

  /// Handles the tap action on a local notification.
  ///
  /// Decodes the payload, fetches the corresponding user or group via CometChat,
  /// and navigates to the appropriate chat screen if valid.
  ///
  /// [response] - The response from the tapped notification.
  static void handleNotificationTap(NotificationResponse? response,
      {bool? isTerminatedState = false}) async {
    if (isTerminatedState == true) {
      InitializeCometChat.init();
    }

    // Proceed only if the payload exists
    if (response != null && response.payload != null) {
      // Decode the JSON payload into a Dart map
      final body = jsonDecode(response.payload!) as Map<String, dynamic>;

      // Convert the map into a strongly-typed NotificationDataModel
      final notificationDataModel = NotificationDataModel.fromJson(body);

      // Clear accumulated messages for this conversation since user tapped it
      if (notificationDataModel.conversationId.isNotEmpty) {
        clearConversationMessages(notificationDataModel.conversationId);
      }

      // Variables to store user or group based on receiverType
      User? sendUser;
      Group? sendGroup;

      // Fetch user details if the receiverType is 'user'
      if (notificationDataModel.receiverType == receiverTypeUser) {
        final uid = notificationDataModel.sender;
        try {
          await CometChat.getUser(
            uid,
            onSuccess: (user) {
              debugPrint("[FCM] User fetched $user");
              sendUser = user;
            },
            onError: (exception) {
              debugPrint(
                  "[FCM] Error while retrieving user ${exception.message}");
            },
          );
        } catch (e) {
          debugPrint("[FCM] Failed to fetch user: $e");
        }
      }

      // Fetch group details if the receiverType is 'group'
      else if (notificationDataModel.receiverType == receiverTypeGroup) {
        final guid = notificationDataModel.receiver;

        try {
          await CometChat.getGroup(
            guid,
            onSuccess: (group) {
              sendGroup = group;
            },
            onError: (exception) {
              if (kDebugMode) {
                debugPrint(
                    "[FCM] Error while retrieving group ${exception.message}");
              }
            },
          );
        } catch (e) {
          debugPrint("[FCM] Failed to fetch group: $e");
        }
      }

      // Navigate to the chat screen if it's a message notification and the target is valid
      final isChatMessage =
          notificationDataModel.type == NotificationMessageTypeConstants.chat;

      final isUserValid =
          notificationDataModel.receiverType == ReceiverTypeConstants.user &&
              sendUser != null;

      final isGroupValid =
          notificationDataModel.receiverType == ReceiverTypeConstants.group &&
              sendGroup != null;

      // Navigating to the chat screen when messageCategory is message
      if (isChatMessage && (isUserValid || isGroupValid)) {
        final context = CallNavigationContext.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MessagesSample(
                  user: sendUser,
                  group: sendGroup,
                ),
              ),
            );
          });
        }
      }
    }
  }
}
