import 'dart:async';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sample_app_push_notifications/notifications/services/android_notification_service/voip_notification_handler.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';
import '../../../app_credentials.dart';
import '../../../messages/messages.dart';
import '../../models/call_action.dart';
import '../../models/call_type.dart';
import '../../models/notification_message_type.dart';
import '../../models/payload.dart';
import '../cometchat_service/cometchat_services.dart';
import '../save_settings_to_native.dart';
import 'local_notification_handler.dart';

// This method handles incoming Firebase messages in the background, specifically for displaying incoming calls on Android platform.

// 1. This has to be defined outside of any class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage rMessage) async {
  LocalNotificationService.showNotification(rMessage.data, rMessage, "", false);
  await VoipNotificationHandler.displayIncomingCall(rMessage);
}

// This class provides functions to interact and manage Firebase Messaging services such as requesting permissions, initializing listeners, managing notifications, and handling tokens.

class FirebaseService
    with
        CometChatUIEventListener,
        CometChatCallEventListener,
        CallListener,
        CometChatCallsEventsListener {
  late final FirebaseMessaging _firebaseMessaging;
  late final NotificationSettings _settings;
  late final Function registerToServer;

  late String _listenerId;

  String? conversationId;

  bool isUserAgentic = false;

  Future<void> init(BuildContext context) async {
    try {
      // 2. Get FirebaseMessaging instance
      _firebaseMessaging = FirebaseMessaging.instance;

      // 3. Request permissions
      await requestPermissions();

      // 4. Setup notification listeners
      if (context.mounted) await initListeners(context);

      // 5. Fetch and register FCM token
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        PNRegistry.registerPNService(token, true, false);
      }

      _listenerId = "NotificationListener";

      saveAppSettingsToNative();

      CometChatUIEvents.addUiListener(_listenerId, this);
      CometChatCallEvents.addCallEventsListener(_listenerId, this);
      CometChat.addCallListener(_listenerId, this);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase initialization error: $e');
      }
    }
  }

  // method for requesting notification permission
  Future<void> requestPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      _settings = settings;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting permissions: $e');
      }
    }
  }

  // This method initializes Firebase message listeners to handle background notifications, token refresh, and user interactions with messages, after checking for user permission authorization.

  Future<void> initListeners(context) async {
    try {
      if (_settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          debugPrint('User granted permission');
        }

        // For handling notification when the app is in the background
        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);

        // refresh token listener
        _firebaseMessaging.onTokenRefresh.listen((String token) async {
          if (kDebugMode) {
            debugPrint('Token refreshed: $token');
          }

          PNRegistry.registerPNService(token, true, false);
        });

        // This line sets up a listener that triggers the 'openNotification' method when a user taps on a notification and the app opens.

        // Handling a notification click event when the app is in the background
        FirebaseMessaging.onMessageOpenedApp
            .listen((RemoteMessage message) async {
          openNotification(context, message, conversationId);
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          if (message.notification != null) {
            openNotification(context, message, conversationId);
          } else if (message.data.isNotEmpty) {
            LocalNotificationService.showNotification(
                message.data, message, conversationId, isUserAgentic);
          }
        });

        // Handling the initial message received when the app is launched from dead (killed state)
        // When the app is killed and a new notification arrives when user clicks on it
        // It gets the data to which screen to open
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          if (message != null) {
            debugPrint(
                "[FCM] Notification tapped from terminated state. Payload: ${message?.data}");
            if (message.notification != null) {
              openNotification(context, message, conversationId);
            } else if (message.data.isNotEmpty) {
              LocalNotificationService.showNotification(
                  message.data, message, conversationId, isUserAgentic);
            }
            debugPrint("[FCM] No initial message on app launch.");
            debugPrint("[FCM] No initial message on app launch. ${message}");
          }
        });
      } else {
        if (kDebugMode) {
          debugPrint('User declined or has not accepted permission');
        }
      }

      initializeCallKitListeners(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing listeners: $e.');
      }
    }
  }

  // This methods helps to retrieve the conversation id from the last message received in the chat.
  @override
  void ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {
    debugPrint("ccActiveChatChanged called with id: $id, lastMessage: $lastMessage, user: $user, group: $group, unreadMessageCount: $unreadMessageCount");
    isUserAgentic = isAgentic(user);
    debugPrint("isUserAgentic: $isUserAgentic");
    if (lastMessage != null) {
      conversationId = lastMessage.conversationId;
    }
  }

  bool isAgentic(User? user) {
    return user?.role == AIConstants.aiRole;
  }

  @override
  void onIncomingCallCancelled(Call call) async {
    if (kDebugMode) {
      debugPrint("Incoming call cancelled");
    }
    if (call.sessionId != null) {
      await VoipNotificationHandler.endCall(sessionId: call.sessionId);
    }
  }

  @override
  void ccCallEnded(Call call) async {
    debugPrint("[FCM] ccCallEnded triggered.");
    await VoipNotificationHandler.endCall(sessionId: call.sessionId);
  }

  @override
  void onCallEndButtonPressed() async {
    debugPrint("[FCM] onCallEndButtonPressed triggered.");
    await VoipNotificationHandler.endCall(sessionId: VoipNotificationHandler.activeCallSession);
  }

  @override
  void onCallEnded() async {
    debugPrint("[FCM] onCallEnded triggered.");
    await FlutterCallkitIncoming.endAllCalls();
  }

  // This method processes the incoming Firebase message to handle user or group notifications and carries out appropriate actions such as initiating a chat or call.
  Future<void> openNotification(
      context, RemoteMessage? message, String? conversationId) async {
    debugPrint("[FCM] Notification tapped from terminated state.");

    if (message != null) {
      debugPrint("[FCM] Notification tapped from terminated state.");
      Map<String, dynamic> data = message.data;

      PayloadData payload = PayloadData.fromJson(data);
      String messageCategory = payload.type ?? "";

      final receiverType = payload.receiverType ?? "";
      User? sendUser;
      Group? sendGroup;

      if (receiverType == "user") {
        final uid = payload.sender ?? '';

        await CometChat.getUser(
          uid,
          onSuccess: (user) {
            debugPrint("User fetched $user");
            sendUser = user;
          },
          onError: (exception) {
            if (kDebugMode) {
              debugPrint("Error while retrieving user ${exception.message}");
            }
          },
        );
      } else if (receiverType == "group") {
        final guid = payload.receiver ?? '';

        await CometChat.getGroup(
          guid,
          onSuccess: (group) {
            sendGroup = group;
          },
          onError: (exception) {
            if (kDebugMode) {
              debugPrint("Error while retrieving group ${exception.message}");
            }
          },
        );
      }

      debugPrint("[FCM] Notification tapped from terminated state.");
      // Navigating to the chat screen when messageCategory is message
      if (messageCategory == NotificationMessageTypeConstants.chat &&
              (receiverType == ReceiverTypeConstants.user &&
                  sendUser != null) ||
          (receiverType == ReceiverTypeConstants.group && sendGroup != null)) {
        if (context.mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (conversationId != null &&
                conversationId.isNotEmpty &&
                conversationId == (payload.conversationId ?? "")) {
              return;
            }
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


  // Deletes fcm token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error while deleting token $e');
      }
    }
  }

  static initializeCallKitListeners(context) {
    // Listen for user actions on the call notification.
    FlutterCallkitIncoming.onEvent.listen(
      (CallEvent? callEvent) async {
        debugPrint(
            "[FCM] Received CallKit Event: ${callEvent?.event.name} - ${callEvent?.body}");
        switch (callEvent?.event) {
          case Event.actionCallIncoming:
            // Initialize shared preferences when call is incoming.
            SharedPreferencesClass.init();
            break;
          case Event.actionCallAccept:
            // User accepted the call.
            VoipNotificationHandler.activeCallSession = callEvent?.body['id'] ?? "";
            VoipNotificationHandler.acceptVoipCall(callEvent, context);
            break;
          case Event.actionCallDecline:
            // User declined the call.
            VoipNotificationHandler.activeCallSession = callEvent?.body['id'] ?? "";
            VoipNotificationHandler.declineVoipCall(callEvent);
            break;
          case Event.actionCallTimeout:
            // Call timed out, end the call.
            await VoipNotificationHandler.endCall(
                sessionId: callEvent?.body['id']);
            break;
          case Event.actionCallEnded:
            // Call ended, clean up.
            debugPrint("[FCM] Call Ended Event Triggered: ${callEvent?.body}");
            await VoipNotificationHandler.endCall(
                sessionId: callEvent?.body['id']);
            break;
          default:
            break;
        }
      },
      cancelOnError: false,
      onDone: () {
        if (kDebugMode) {
          debugPrint('[FCM] FlutterCallkitIncoming.onEvent: done');
        }
      },
      onError: (e) {
        if (kDebugMode) {
          debugPrint(
              '[FCM] FlutterCallkitIncoming.onEvent:error ${e.toString()}');
        }
      },
    );
  }
}
