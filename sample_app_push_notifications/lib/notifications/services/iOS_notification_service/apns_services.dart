import 'dart:convert';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apns_x/flutter_apns/src/apns_connector.dart';
import '../../../messages/messages.dart';
import '../../../utils/bool_singleton.dart';
import '../../models/call_action.dart';
import '../../models/call_type.dart';
import '../../models/notification_date_model.dart';
import '../../models/notification_message_type.dart';
import '../../models/payload.dart';
import '../cometchat_service/cometchat_services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class APNSService with CometChatCallsEventsListener, CometChatUIEventListener {


  String? id;

  late String _listenerId;

  String? conversationId;

  bool isUserAgentic = false;

  // This methods helps to retrieve the conversation id from the last message received in the chat.
  @override
  void ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {
    isUserAgentic = isAgentic(user);
    if (lastMessage != null) {
      conversationId = lastMessage.conversationId;
    }
  }

  bool isAgentic(User? user) {
    return user?.role == AIConstants.aiRole;
  }

  @override
  void onCallEndButtonPressed() async {
    await FlutterCallkitIncoming.endCall(id!);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void _showNotification(Map<String, dynamic> data, RemoteMessage msg, String? conversationId, bool? iaAgentic) async {
    if(isUserAgentic) {
      return;
    }
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails('channel_id', 'channel_name',
      importance: Importance.max, priority: Priority.high, icon: 'ic_launcher',);
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: const DarwinNotificationDetails());

    String jsonPayload = jsonEncode(msg.data);

    if (data["type"] != null && data["type"] == "call") {
      if(data["callAction"] == "cancelled") {
        await BoolSingleton().setValue(true);
        return;
      }
    }

    if (conversationId != null &&
        conversationId.isNotEmpty &&
        conversationId == (data["conversationId"] ?? "")) {
      return;
    }

    int? notifyId;
    try {
      notifyId = int.parse(data["tag"] ?? 0);
    } catch (e) {
      notifyId = 0;
      debugPrint("Error while parsing notification id ${e.toString()}");
    }

    await flutterLocalNotificationsPlugin.show(
      notifyId,
      data['title'], // Notification title
      data['body'], // Notification body
      platformChannelSpecifics,
      payload: jsonPayload,
    );
  }

  void handleNotificationTap(NotificationResponse response) async {
    if (response.payload != null) {
      debugPrint('Notification tapped with payload: ${response.payload}');
      final body = jsonDecode(response.payload!) as Map<String, dynamic>;

      // Map<String, dynamic> body = json.decode(response.payload!);
      NotificationDataModel notificationDataModel = NotificationDataModel.fromJson(body);
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
          (notificationDataModel.receiverType == ReceiverTypeConstants.group && sendGroup != null)) {
        if (CallNavigationContext.navigatorKey.currentContext != null && CallNavigationContext.navigatorKey.currentContext!.mounted) {
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

  // This method handles displaying incoming calls, accepting, declining, or ending calls using the FlutterCallkitIncoming and CometChat.
  Future<void> displayIncomingCall(rMessage) async {

    debugPrint("displayIncomingCall called with message: ${rMessage.toString()}");

    PayloadData payloadData = PayloadData.fromJson(rMessage.data);
    String messageCategory = payloadData.type ?? "";
    if (messageCategory == 'call') {

      CallAction callAction = payloadData.callAction ?? CallAction.none;
      String uuid = payloadData.sessionId ?? "";
      final callUUID = uuid;

      String callerName = payloadData.senderName ?? "";
      CallType callType = payloadData.callType ?? CallType.none;
      if (callAction == CallAction.initiated) {

        CallKitParams callKitParams = CallKitParams(
          id: callUUID,
          nameCaller: callerName,
          appName: 'notification_new',
          type: (callType == CallType.audio) ? 0 : 1,
          textAccept: 'Accept',
          textDecline: 'Decline',
          duration: 55000,
          ios: const IOSParams(
            supportsVideo: true,
            audioSessionMode: 'default',
            audioSessionActive: true,
            audioSessionPreferredSampleRate: 44100.0,
            audioSessionPreferredIOBufferDuration: 0.005,
            ringtonePath: 'system_ringtone_default',
          ),
        );

        await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
      }
    }
  }

  init(BuildContext context) {
    final _connector = ApnsPushConnector();

    _connector.shouldPresent = (x) => Future.value(false);

    _listenerId = "NotificationListener";
    CometChatUIEvents.addUiListener(_listenerId, this);

    _connector.configure(
      // onLaunch gets called, when you tap on notification on a closed app
      onLaunch: (message) async {
        debugPrint('onLaunch APNS MKAP: ${message.toString()}');
        debugPrint('onLaunch APNS MKAP: ${message.data.toString()}');
        openNotification(message,context, "");
      },

      // onResume gets called, when you tap on notification with app in background
      onResume: (message) async {
        debugPrint('onResume APNS MKAP: ${message.toString()}');
        debugPrint('onResume APNS MKAP: ${message.data.toString()}');
        openNotification(message,context, conversationId);
      },

      onMessage: (message) async{
        debugPrint('onMessage APNS MKAP: ${message.toString()}');
        debugPrint('onMessage APNS MKAP: ${message.data.toString()}');
        _showNotification(message.data,message, conversationId, isUserAgentic);
      },
    );

    //Requesting user permissions
    _connector.requestNotificationPermissions();


    //token value get//
    _connector.token.addListener(() {

      if (_connector.token.value != null || _connector.token.value != '') {
        debugPrint('Token Value MKAP ====--->>>> : ${_connector.token.value}');
        PNRegistry.registerPNService(_connector.token.value!,false,false);

      }
    });

    // Push Token VoIP
    FlutterCallkitIncoming.getDevicePushTokenVoIP().then(
          (voipToken) {

        if (voipToken != null || voipToken.toString().isNotEmpty) {

          PNRegistry.registerPNService(voipToken,false,true);
        }
      },
    );

    // Call event listeners

    FlutterCallkitIncoming.onEvent.listen(
          (CallEvent? callEvent) async {

        final Map<String, dynamic> body = callEvent?.body;


        PayloadData payloadData = PayloadData();
        if(body['extra'] != null && body['extra']['message']!=null) {
          payloadData =
              PayloadData.fromJson(jsonDecode(body['extra']['message']));

        }
        String sessionId = payloadData.sessionId ?? '';
        id = sessionId;

        switch (callEvent?.event) {
          case Event.actionCallIncoming:
            break;
          case Event.actionCallAccept:
            CallSettingsBuilder callSettingsBuilder = (CallSettingsBuilder()
              ..enableDefaultLayout = true
              ..setAudioOnlyCall=payloadData.callType == CallType.audio);

            CometChatUIKitCalls.acceptCall(sessionId,
                onSuccess: (Call call) async {
                  IncomingCallOverlay.dismiss();
                  call.category = MessageCategoryConstants.call;
                  CometChatCallEvents.ccCallAccepted(call);
                  await FlutterCallkitIncoming.setCallConnected(sessionId);
                  if(context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CometChatOngoingCall(
                          callSettingsBuilder: callSettingsBuilder,
                          sessionId: sessionId,
                          callWorkFlow: CallWorkFlow.defaultCalling,
                        ),
                      ),
                    )
                        .then((_) async {
                      await const MethodChannel('com.cometchat.sampleapp.flutter.ios').invokeMethod('endCall');

                    });
                  }
                }, onError: (CometChatException e) {
                  debugPrint("===>>>: Error: acceptCall: ${e.message}");
                });
            break;
          case Event.actionCallDecline:
            CometChatUIKitCalls.rejectCall(
                sessionId, CallStatusConstants.rejected,
                onSuccess: (Call call) async {
                  IncomingCallOverlay.dismiss();
                  call.category = MessageCategoryConstants.call;
                  CometChatCallEvents.ccCallRejected(call);
                  await FlutterCallkitIncoming.endCall(sessionId);
                }, onError: (e) {
              debugPrint(
                  "Unable to end call from incoming call screen ${e.message}");
            });
            break;
          case Event.actionCallEnded:
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

  // This method processes the incoming Remote message to handle user or group notifications and carries out appropriate actions such as initiating a chat or call.

  Future<void> openNotification(RemoteMessage? message, BuildContext context, String? conversationId) async {
    if (message != null) {
      PayloadData payloadData = PayloadData.fromJson(message.data);
      if (payloadData.type == NotificationMessageTypeConstants.call) {
        displayIncomingCall(message);
      } else {
        final receiverType = payloadData.receiverType ?? "";
        User? sendUser;
        Group? sendGroup;

        String messageCategory = payloadData.type ?? "";

        if (receiverType == CometChatReceiverType.user) {
          final uid = payloadData.sender ?? "";
          await CometChat.getUser(
            uid,
            onSuccess: (user) {
              debugPrint("Got User App Background $user");
              sendUser = user;
            },
            onError: (excep) {
              debugPrint(excep.message);
            },
          );
        } else if (receiverType == CometChatReceiverType.group) {
          final guid =
              payloadData.receiver ?? "";
          await CometChat.getGroup(
            guid,
            onSuccess: (group) {
              sendGroup = group;
            },
            onError: (excep) {
              debugPrint(excep.message);
            },
          );
        }

        if (messageCategory == NotificationMessageTypeConstants.chat &&
            (receiverType == CometChatReceiverType.user && sendUser != null) ||
            (receiverType == CometChatReceiverType.group && sendGroup != null)) {
          if (context.mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (conversationId != null &&
                  conversationId.isNotEmpty &&
                  conversationId == (payloadData.conversationId ?? "")) {
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    MessagesSample(
                      user: sendUser,
                      group: sendGroup,
                    ),
              ),);
            });
          }
        }
      }
    }
  }
}

