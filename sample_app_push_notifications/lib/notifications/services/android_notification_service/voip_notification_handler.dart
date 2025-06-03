import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sample_app_push_notifications/notifications/models/call_type.dart';
import 'package:sample_app_push_notifications/notifications/services/cometchat_service/cometchat_services.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';

import '../../models/call_action.dart';
import '../../models/payload.dart';

class VoipNotificationHandler {
  // Stores the current active call session ID, if any.
  static String? activeCallSession;

  static final Set<String> _endedSessions = {};

  /// Accepts an incoming VoIP call.
  /// Navigates to the ongoing call screen and sets call session details in shared preferences.
  static void acceptVoipCall(CallEvent? callEvent, CallType callType) async {
    String sessionId = callEvent?.body["id"];
    String callType = callEvent?.body["type"] == 0 ? "audio" : "video";

    // Store session and call type for later use.
    SharedPreferencesClass.setString("SessionId", sessionId);
    SharedPreferencesClass.setString("callType", callType);

    // Wait briefly to ensure UI is ready before navigating.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (CallNavigationContext.navigatorKey.currentContext != null &&
          CallNavigationContext.navigatorKey.currentContext!.mounted) {
        // Navigate to the ongoing call screen.
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
        // If context is not ready, retry after a short delay.
        debugPrint("[FCM] Navigation context is still null, retrying...");
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
  }

  /// Declines an incoming VoIP call.
  /// Notifies CometChat and ends the call in CallKit.
  static declineVoipCall(CallEvent? callEvent) async {
    CometChatUIKitCalls.rejectCall(
        callEvent?.body["id"], CallStatusConstants.rejected,
        onSuccess: (Call call) async {
      call.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccCallRejected(call);
      await endCall(sessionId: callEvent?.body['id']);
      if (kDebugMode) {
        debugPrint('[FCM] incoming call was declined');
      }
    }, onError: (e) {
      if (kDebugMode) {
        debugPrint(
            "[FCM] Unable to end call from incoming call screen ${e.message}");
      }
    });
  }

  /// Displays an incoming call notification using CallKit.
  /// Handles user actions (accept, decline, timeout, end) via event listeners.
  static Future<void> displayIncomingCall(RemoteMessage rMessage) async {
    Map<String, dynamic> ccMessage = rMessage.data;

    // Parse the payload from the incoming message.
    PayloadData callPayload = PayloadData.fromJson(ccMessage);

    String messageCategory = callPayload.type ?? "";

    if (messageCategory == 'call') {
      CallAction callAction = callPayload.callAction!;
      String uuid = callPayload.sessionId ?? "";
      final callUUID = uuid;
      String callerName = callPayload.senderName ?? "";
      CallType callType = callPayload.callType ?? CallType.none;

      // Only show incoming call if it's initiated and not expired.
      if (callAction == CallAction.initiated &&
          (callPayload.sentAt != null)) {
        // Prepare CallKit parameters for the incoming call UI.
        CallKitParams callKitParams = CallKitParams(
          id: callUUID,
          nameCaller: callerName,
          appName: 'CometChat Messenger',
          type: (callType == CallType.audio) ? 0 : 1,
          textAccept: 'Accept',
          textDecline: 'Decline',
          duration: 45000,
          android: const AndroidParams(
            isCustomNotification: true,
            isShowLogo: true,
            incomingCallNotificationChannelName: "Incoming Call",
            isShowFullLockedScreen: false,
          ),
        );
        // Show the incoming call notification.
        await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);

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
                acceptVoipCall(callEvent, callType);
                break;
              case Event.actionCallDecline:
                // User declined the call.
                declineVoipCall(callEvent);
                break;
              case Event.actionCallTimeout:
                // Call timed out, end the call.
                await endCall(sessionId: callEvent?.body['id']);
                break;
              case Event.actionCallEnded:
                // Call ended, clean up.
                debugPrint(
                    "[FCM] Call Ended Event Triggered: ${callEvent?.body}");
                await endCall(sessionId: callEvent?.body['id']);
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
      } else if (callAction == CallAction.cancelled ||
          callAction == CallAction.unanswered) {
        // If call was cancelled or unanswered, end all calls.
        if (callPayload.sessionId != null) {
          await endCall(sessionId: callPayload.sessionId);
        }
      }
    }
  }

  static Future<void> endCall({String? sessionId}) async {
    if (kDebugMode) {
      debugPrint("[FCM] Ending call called");
    }

    final id = sessionId ?? activeCallSession;
    if (id == null) {
      if (kDebugMode) {
        debugPrint("[FCM] No active call session to end.");
      }
      return;
    }

    if (_endedSessions.contains(id)) {
      if (kDebugMode) {
        debugPrint("[FCM] Call already ended for sessionId: $id");
      }
      return;
    }

    _endedSessions.add(id);

    await FlutterCallkitIncoming.endCall(id);
    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterCallkitIncoming.endAllCalls();

    activeCallSession = null;
  }
}
