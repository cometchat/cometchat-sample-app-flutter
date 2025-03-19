import 'dart:async';
import 'dart:convert';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sample_app_push_notifications/notifications/models/notification_date_model.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';

import '../../app_credentials.dart';
import '../../demo_meta_info_constants.dart';
import '../../messages/messages.dart';
import '../models/call_action.dart';
import '../models/call_type.dart';
import '../models/notification_message_type.dart';
import '../models/payload.dart';
import 'cometchat_services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// This method handles incoming Firebase messages in the background, specifically for displaying incoming calls on Android platform.

// 1. This has to be defined outside of any class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage rMessage) async {
  _showNotification(rMessage.data, rMessage, "");
  await displayIncomingCall(rMessage);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void _showNotification(Map<String, dynamic> data, RemoteMessage msg,
    String? conversationId) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
    icon: 'ic_launcher',
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  String jsonPayload = jsonEncode(msg.data);

  if (msg.data["type"] != null && msg.data["type"] == "call") {
    return;
  }

  if (conversationId != null &&
      conversationId.isNotEmpty &&
      conversationId == (data["conversationId"] ?? "")) {
    return;
  }

  int? id;
  try {
    id = int.parse(data["tag"] ?? 0);
  } catch (e) {
    id = 0;
    debugPrint("Error while parsing notification id ${e.toString()}");
  }
  await flutterLocalNotificationsPlugin.show(
    id, // Notification ID
    data['title'], // Notification title
    data['body'], // Notification body
    platformChannelSpecifics,
    payload: jsonPayload,
  );
}

void handleNotificationTap(NotificationResponse response) async {
  if (response.payload != null) {
    final body = jsonDecode(response.payload!) as Map<String, dynamic>;

    // Map<String, dynamic> body = json.decode(response.payload!);
    NotificationDataModel notificationDataModel =
        NotificationDataModel.fromJson(body);
    // You can navigate to a specific screen based on the payload
    User? sendUser;
    Group? sendGroup;

    if (notificationDataModel.receiverType == "user") {
      final uid = notificationDataModel.sender;

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
    } else if (notificationDataModel.receiverType == "group") {
      final guid = notificationDataModel.receiver;

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

    // Navigating to the chat screen when messageCategory is message
    if (notificationDataModel.type == NotificationMessageTypeConstants.chat &&
            (notificationDataModel.receiverType == ReceiverTypeConstants.user &&
                sendUser != null) ||
        (notificationDataModel.receiverType == ReceiverTypeConstants.group &&
            sendGroup != null)) {
      if (CallNavigationContext.navigatorKey.currentContext != null &&
          CallNavigationContext.navigatorKey.currentContext!.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(CallNavigationContext.navigatorKey.currentContext!).push(
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

init() async {
  UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
        ..subscriptionType = CometChatSubscriptionType.allUsers
        ..region = AppCredentials.region
        ..autoEstablishSocketConnection = true
        ..appId = AppCredentials.appId
        ..authKey = AppCredentials.authKey
        ..callingExtension = CometChatCallingExtension()
        ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions()
        ..aiFeature = CometChatUIKitChatAIFeatures.getDefaultAiFeatures())
      .build();

  CometChatUIKit.init(
    uiKitSettings: uiKitSettings,
    onSuccess: (successMessage) async {
      try {
        CometChat.setDemoMetaInfo(jsonObject: {
          "name": DemoMetaInfoConstants.name,
          "type": DemoMetaInfoConstants.type,
          "version": DemoMetaInfoConstants.version,
          "bundle": DemoMetaInfoConstants.bundle,
          "platform": DemoMetaInfoConstants.platform,
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint("setDemoMetaInfo ended with error");
        }
      }
    },
  );
  debugPrint("CallingExtension enable with context called in login");
}

// This method handles displaying incoming calls, accepting, declining, or ending calls using the FlutterCallkitIncoming and CometChat.
String? activeCallSession;
Future<void> displayIncomingCall(RemoteMessage rMessage) async {
  Map<String, dynamic> ccMessage = rMessage.data;

  PayloadData callPayload = PayloadData.fromJson(ccMessage);

  String messageCategory = callPayload.type ?? "";

  if (messageCategory == 'call') {
    CallAction callAction = callPayload.callAction!;
    String uuid = callPayload.sessionId ?? "";
    final callUUID = uuid;
    String callerName = callPayload.senderName ?? "";
    CallType callType = callPayload.callType ?? CallType.none;
    if (callAction == CallAction.initiated &&
        (callPayload.sentAt != null &&
            DateTime.now().isBefore(
                callPayload.sentAt!.add(const Duration(seconds: 40))))) {
      CallKitParams callKitParams = CallKitParams(
        id: callUUID,
        nameCaller: callerName,
        appName: 'CometChat Messenger',
        type: (callType == CallType.audio) ? 0 : 1,
        textAccept: 'Accept',
        textDecline: 'Decline',
        duration: 40000,
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          incomingCallNotificationChannelName: "Incoming Call",
          isShowFullLockedScreen: false,
        ),
        ios: const IOSParams(
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);

      FlutterCallkitIncoming.onEvent.listen(
        (CallEvent? callEvent) async {
          debugPrint(
              "Received CallKit Event: ${callEvent?.event.name} - ${callEvent?.body}");
          switch (callEvent?.event) {
            case Event.actionCallIncoming:
              SharedPreferencesClass.init();
              break;
            case Event.actionCallAccept:
              String sessionId = callEvent?.body["id"];
              String callType = callEvent?.body["type"] == 0 ? "audio" : "video";

              SharedPreferencesClass.setString("SessionId", sessionId);
              SharedPreferencesClass.setString("callType", callType);

              // Wait for Flutter to initialize UI before navigating
              Future.delayed(const Duration(milliseconds: 200), () {
                if (CallNavigationContext.navigatorKey.currentContext != null &&
                    CallNavigationContext.navigatorKey.currentContext!.mounted) {
                  Navigator.push(
                    CallNavigationContext.navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => CometChatOngoingCall(
                        sessionId: sessionId,
                        callSettingsBuilder: (CallSettingsBuilder()
                          ..enableDefaultLayout = true
                          ..setAudioOnlyCall = (callType == "audio")),
                      ),
                    ),
                  );
                } else {
                  debugPrint("Navigation context is still null, retrying...");
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (CallNavigationContext.navigatorKey.currentContext != null &&
                        CallNavigationContext.navigatorKey.currentContext!.mounted) {
                      Navigator.push(
                        CallNavigationContext.navigatorKey.currentContext!,
                        MaterialPageRoute(
                          builder: (context) => CometChatOngoingCall(
                            sessionId: sessionId,
                            callSettingsBuilder: (CallSettingsBuilder()
                              ..enableDefaultLayout = true
                              ..setAudioOnlyCall = (callType == "audio")),
                          ),
                        ),
                      );
                    }
                  });
                }
              });
              break;
            case Event.actionCallDecline:
              init();
              CometChatUIKitCalls.rejectCall(
                  callEvent?.body["id"], CallStatusConstants.rejected,
                  onSuccess: (Call call) async {
                call.category = MessageCategoryConstants.call;
                CometChatCallEvents.ccCallRejected(call);
                await FlutterCallkitIncoming.endCall(callEvent?.body['id']);
                if (kDebugMode) {
                  debugPrint('incoming call was rejected');
                }
              }, onError: (e) {
                if (kDebugMode) {
                  debugPrint(
                      "Unable to end call from incoming call screen ${e.message}");
                }
              });

              break;
            case Event.actionCallTimeout:
              await FlutterCallkitIncoming.endCall(callEvent?.body['id']);
              break;
            case Event.actionCallEnded:
              debugPrint("Call Ended Event Triggered: ${callEvent?.body}");
              await FlutterCallkitIncoming.endCall(callEvent?.body['id']);
              await Future.delayed(const Duration(seconds: 2));
              FlutterCallkitIncoming.endAllCalls();
              break;
            default:
              break;
          }
        },
        cancelOnError: false,
        onDone: () {
          if (kDebugMode) {
            debugPrint('FlutterCallkitIncoming.onEvent: done');
          }
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('FlutterCallkitIncoming.onEvent:error ${e.toString()}');
          }
        },
      );
    } else if (callAction == CallAction.cancelled ||
        callAction == CallAction.unanswered) {
      if (callPayload.sessionId != null) {
        await FlutterCallkitIncoming.endCall(callPayload.sessionId ?? "");
        await FlutterCallkitIncoming.endAllCalls();
        activeCallSession = null;
      }
    } else {
    }
  }
}

// This class provides functions to interact and manage Firebase Messaging services such as requesting permissions, initializing listeners, managing notifications, and handling tokens.

class FirebaseService
    with CometChatUIEventListener, CometChatCallEventListener, CallListener{
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
            _showNotification(message.data, message, conversationId);
          }
        });

        // Handling the initial message received when the app is launched from dead (killed state)
        // When the app is killed and a new notification arrives when user clicks on it
        // It gets the data to which screen to open
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          if (message != null) {
            openNotification(context, message, conversationId);
          }
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
  void onIncomingCallCancelled(Call call) {
    if (kDebugMode) {
      debugPrint("Incoming call cancelled");
    }
    if(call.sessionId != null) {
      FlutterCallkitIncoming.endCall(call.sessionId!);
    }
  }

  // This method processes the incoming Firebase message to handle user or group notifications and carries out appropriate actions such as initiating a chat or call.
  Future<void> openNotification(
      context, RemoteMessage? message, String? conversationId) async {
    if (message != null) {
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
            await FlutterCallkitIncoming.endCall(activeCallSession!);
            activeCallSession = null;
          }
        }
      }

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
            CometChatUIKitCalls.init(AppCredentials.appId, AppCredentials.region,
                onSuccess: (p0) {
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
            await FlutterCallkitIncoming.endCall(callEvent?.body['id']);
            break;
          case Event.actionCallEnded:
            await FlutterCallkitIncoming.endCall(callEvent?.body['id']);
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
