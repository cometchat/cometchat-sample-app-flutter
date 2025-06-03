import 'dart:convert';

import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sample_app_push_notifications/notifications/services/cometchat_service/cometchat_services.dart';
import 'package:sample_app_push_notifications/notifications/services/globals.dart';

import '../../../messages/messages.dart';
import '../../models/notification_date_model.dart';
import '../../models/notification_message_type.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Displays a local notification based on the incoming FCM [RemoteMessage].
  ///
  /// The notification is shown only if:
  /// - The message type is not a "call"
  /// - The conversation is not currently active
  ///
  /// If a valid notification ID (`tag`) is not provided in the payload,
  /// a fallback ID based on timestamp is generated.
  static void showNotification(Map<String, dynamic> notificationData,
      RemoteMessage remoteMessage, String? conversationId) async {
    // Define Android-specific notification configuration
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      notificationChannelId, // Channel ID for Android notifications
      notificationChannelName, // Channel name for user visibility
      importance: Importance.max, // Ensures high-importance notifications
      priority: Priority.high, // Display on top with sound/vibration
      icon: 'ic_launcher', // Custom notification icon
    );

    // Define the notification details
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

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
      return;
    }

    // Skip showing notification if it matches the currently active conversation
    if (conversationId != null &&
        conversationId.isNotEmpty &&
        conversationId == notificationData["conversationId"]?.toString()) {
      debugPrint(
          "[FCM] Skipping notification as it matches active conversation.");
      return;
    }

    // Attempt to parse the notification ID from the payload
    int id = 0;
    try {
      final tag = notificationData["tag"];
      if (tag != null) {
        id = int.parse(tag.toString());
      }
    } catch (e) {
      debugPrint("[FCM] Error parsing notification ID: ${e.toString()}");
    }

    // If parsing failed or tag was missing, generate a fallback ID
    if (id == 0) {
      id = DateTime.now().microsecondsSinceEpoch.hashCode;
    }

    // Display the local notification
    await flutterLocalNotificationsPlugin.show(
      id, // Unique notification ID
      notificationData['title'], // Title from notification data
      notificationData['body'], // Body content from notification data
      platformChannelSpecifics, // Platform-specific notification config
      payload: jsonPayload, // Encoded payload for click handling
    );
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
      CometChatService().init();
    }

    // Proceed only if the payload exists
    if (response != null && response.payload != null) {
      // Decode the JSON payload into a Dart map
      final body = jsonDecode(response.payload!) as Map<String, dynamic>;

      // Convert the map into a strongly-typed NotificationDataModel
      final notificationDataModel = NotificationDataModel.fromJson(body);

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
