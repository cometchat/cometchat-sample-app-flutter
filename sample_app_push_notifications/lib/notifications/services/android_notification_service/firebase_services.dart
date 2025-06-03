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
import 'local_notification_handler.dart';

// This method handles incoming Firebase messages in the background, specifically for displaying incoming calls on Android platform.

// 1. This has to be defined outside of any class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage rMessage) async {
  LocalNotificationService.showNotification(rMessage.data, rMessage, "");
  await VoipNotificationHandler.displayIncomingCall(rMessage);
}

// This class provides functions to interact and manage Firebase Messaging services such as requesting permissions, initializing listeners, managing notifications, and handling tokens.

class FirebaseService
    with CometChatUIEventListener, CometChatCallEventListener, CallListener {
  late final FirebaseMessaging _firebaseMessaging;
  late final NotificationSettings _settings;
  late final Function registerToServer;

  late String _listenerId;

  String? conversationId;

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
                message.data, message, conversationId);
          }
        });

        // Handling the initial message received when the app is launched from dead (killed state)
        // When the app is killed and a new notification arrives when user clicks on it
        // It gets the data to which screen to open
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          // if (message != null) {
          debugPrint(
              "[FCM] Notification tapped from terminated state. Payload: ${message?.data}");
          openNotification(context, message, conversationId);
          // } else {
          debugPrint("[FCM] No initial message on app launch.");
          debugPrint("[FCM] No initial message on app launch. ${message}");
          // }
        });
        openFromTerminatedState(context);
      } else {
        if (kDebugMode) {
          debugPrint('User declined or has not accepted permission');
        }
      }
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
    if (lastMessage != null) {
      conversationId = lastMessage.conversationId;
    }
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

  // This method processes the incoming Firebase message to handle user or group notifications and carries out appropriate actions such as initiating a chat or call.
  Future<void> openNotification(
      context, RemoteMessage? message, String? conversationId) async {
    debugPrint("[FCM] Notification tapped from terminated state. MKAP 111");

    if (message != null) {
      debugPrint("[FCM] Notification tapped from terminated state. MKAP 22222");
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

      if (messageCategory == NotificationMessageTypeConstants.call) {
        CallAction callAction = payload.callAction!;
        String uuid = payload.sessionId ?? "";

        if (callAction == CallAction.initiated) {
          if (receiverType == ReceiverTypeConstants.user && sendUser != null) {
            Call call = Call(
                sessionId: uuid,
                receiverUid: sendUser?.uid ?? "",
                type: payload.callType?.value ?? "",
                receiverType: receiverType);

            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CometChatIncomingCall(
                    call: call,
                    user: sendUser,
                  ),
                ),
              );
            }
          }
        } else if (receiverType == ReceiverTypeConstants.group &&
            sendGroup != null) {
          if (kDebugMode) {
            debugPrint("we are in group call");
          }
        } else if (callAction == CallAction.cancelled) {
          if (activeCallSession != null) {
            await VoipNotificationHandler.endCall(sessionId: activeCallSession);
          }
        }
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

  // active call session
  String? activeCallSession;

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

  // checks For navigation when app opens from terminated state when we accept call
  openFromTerminatedState(context) {
    final sessionID = SharedPreferencesClass.getString("SessionId");
    final callType = SharedPreferencesClass.getString("callType");

    if (sessionID.isNotEmpty) {
      CallSettingsBuilder callSettingsBuilder = (CallSettingsBuilder()
        ..enableDefaultLayout = true
        ..setAudioOnlyCall = (callType == CallType.audio.value));
      CometChatUIKitCalls.acceptCall(sessionID, onSuccess: (Call call) {
        call.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccCallAccepted(call);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CometChatOngoingCall(
              callSettingsBuilder: callSettingsBuilder,
              sessionId: sessionID,
              callWorkFlow: CallWorkFlow.defaultCalling,
            ),
          ),
        );
      }, onError: (e) {
        debugPrint(
            "Unable to accept call from incoming call screen ${e.details}");
      });
    }
  }

  // checks For navigation when app opens from background state when we accept call
  resumeCallListeners(BuildContext context) async {
    FlutterCallkitIncoming.onEvent.listen(
      (CallEvent? callEvent) async {
        switch (callEvent?.event) {
          case Event.actionCallIncoming:
            CometChatUIKitCalls.init(
                AppCredentials.appId, AppCredentials.region, onSuccess: (p0) {
              debugPrint("CometChatUIKitCalls initialized successfully");
            }, onError: (e) {
              debugPrint("CometChatUIKitCalls failed ${e.message}");
            });
            activeCallSession = callEvent?.body["id"];

            break;
          case Event.actionCallAccept:
            final callType = callEvent?.body["type"];
            CallSettingsBuilder callSettingsBuilder = (CallSettingsBuilder()
              ..enableDefaultLayout = true
              ..setAudioOnlyCall = (callType == CallType.audio.value));

            CometChatUIKitCalls.acceptCall(callEvent!.body["id"],
                onSuccess: (Call call) {
              call.category = MessageCategoryConstants.call;
              CometChatCallEvents.ccCallAccepted(call);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CometChatOngoingCall(
                    callSettingsBuilder: callSettingsBuilder,
                    sessionId: callEvent.body["id"],
                  ),
                ),
              );
            }, onError: (e) {
              debugPrint(
                  "Unable to accept call from incoming call screen ${e.message}");
            });
            break;
          case Event.actionCallDecline:
            CometChatUIKitCalls.rejectCall(
                callEvent?.body["id"], CallStatusConstants.rejected,
                onSuccess: (Call call) {
              call.category = MessageCategoryConstants.call;
              CometChatCallEvents.ccCallRejected(call);
              debugPrint('incoming call was cancelled');
            }, onError: (e) {
              debugPrint(
                  "Unable to end call from incoming call screen ${e.message}");
              debugPrint(
                  "Unable to end call from incoming call screen ${e.details}");
            });
            break;
          case Event.actionCallTimeout:
            await VoipNotificationHandler.endCall(sessionId: callEvent?.body['id']);
            break;
          case Event.actionCallEnded:
            await VoipNotificationHandler.endCall(sessionId: callEvent?.body['id']);
            break;
          default:
            break;
        }
      },
      cancelOnError: false,
      onDone: () {
        debugPrint('FlutterCallkitIncoming.onEvent: done');
      },
      onError: (e) {
        debugPrint('FlutterCallkitIncoming.onEvent:error ${e.toString()}');
      },
    );
  }
}
