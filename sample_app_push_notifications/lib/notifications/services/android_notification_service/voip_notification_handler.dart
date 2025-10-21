import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sample_app_push_notifications/notifications/models/call_type.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';
import 'package:sample_app_push_notifications/utils/initialize_cometchat.dart';
import '../../models/call_action.dart';
import '../../models/payload.dart';
import '../save_settings_to_native.dart';

class VoipNotificationHandler {
  // Stores the current active call session ID, if any.
  static String? activeCallSession;

  static final Set<String> _endedSessions = {};

  /// Accepts an incoming VoIP call.
  /// Navigates to the ongoing call screen and sets call session details in shared preferences.
  static void acceptVoipCall(CallEvent? callEvent, context) async {
    String sessionId = callEvent?.body["id"];
    String callTypeStr = callEvent?.body["type"] == 0
        ? CallTypeConstants.audioCall
        : CallTypeConstants.videoCall;

    debugPrint(
        "[FCM-MKAP] Accepting VoIP call with sessionId: $sessionId, callType: $callTypeStr, callEventType : ${callEvent?.body["type"]}");

    // Store session and call type for later use.
    SharedPreferencesClass.setString("SessionId", sessionId);
    SharedPreferencesClass.setString("callType", callTypeStr);

    // Wait briefly to ensure UI is ready before navigating.
    Future.delayed(const Duration(milliseconds: 200), () {
      _acceptAndNavigate(sessionId, callTypeStr, context);
    });
  }

  /// Declines an incoming VoIP call.
  /// Notifies CometChat and ends the call in CallKit.
  static declineVoipCall(CallEvent? callEvent) async {
    CometChatUIKitCalls.rejectCall(callEvent?.body["id"] ?? activeCallSession,
        CallStatusConstants.rejected, onSuccess: (Call call) async {
      IncomingCallOverlay.dismiss();
      call.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccCallRejected(call);
      await endCall(sessionId: callEvent?.body['id'] ?? activeCallSession);
      if (kDebugMode) {
        debugPrint('[FCM] incoming call was declined');
      }
    }, onError: (e) async {
        debugPrint(
            "[FCM] Unable to end call from incoming call screen ${e.message}");
        debugPrint(
            "[FCM] Unable to end call from incoming call screen ${e.code}");

        final errorMessage = e.message?.toLowerCase() ?? "";

        if (errorMessage.contains("please call the cometchat.init() method")) {
          debugPrint(
              "[CometChat] SDK not initialized. Attempting re-initialization...");

          await InitializeCometChat.init();

          // Optionally: retry rejecting the call
          CometChatUIKitCalls.rejectCall(
            callEvent?.body["id"] ?? activeCallSession,
            CallStatusConstants.rejected,
            onSuccess: (call) async {
              IncomingCallOverlay.dismiss();
              call.category = MessageCategoryConstants.call;
              CometChatCallEvents.ccCallRejected(call);
              await endCall(
                  sessionId: callEvent?.body['id'] ?? activeCallSession);
              debugPrint(
                  '[FCM] Incoming call was declined after re-initialization');
            },
            onError: (retryError) {
              debugPrint("[FCM] Retry also failed: ${retryError.message}");
            },
          );
          return;
        }
        // fallback for other errors
        if (kDebugMode) {
          debugPrint(
              "[FCM] Unable to end call from incoming call screen ${e.message}");
          debugPrint(
              "[FCM] Unable to end call from incoming call screen ${e.code}");
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

      if (kDebugMode) {
        debugPrint(
            "[FCM] Displaying incoming call: $callUUID, Action: $callAction, Type: $callType");
      }

      // Only show incoming call if it's initiated and not expired.
      if (callAction == CallAction.initiated && (callPayload.sentAt != null)) {
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
          onDecline: (reason) {
            debugPrint("[FCM] Call declined with reason: $reason");
            VoipNotificationHandler.declineVoipCall(null);
          },
        );
        // Show the incoming call notification.
        await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
      } else if (callAction == CallAction.cancelled ||
          callAction == CallAction.unanswered) {
        // If call was cancelled or unanswered, end all calls.
        if (callPayload.sessionId != null) {
          await endCall(sessionId: callPayload.sessionId);
        }
      }
    }
  }

  static Future<void> endCallFromOngoingScreen(String? session) async {
    if (kDebugMode) {
      debugPrint("[FCM] Ending call from ongoing screen");
    }

    // End the call using CallKit.
    await FlutterCallkitIncoming.endCall(session ?? "");
    await Future.delayed(const Duration(milliseconds: 200));
    await FlutterCallkitIncoming.endAllCalls();
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

  static _acceptAndNavigate(String sessionId, String callType, context) async {
    CometChatUIKitCalls.acceptCall(sessionId, onSuccess: (Call call) {
      IncomingCallOverlay.dismiss();
      call.category = MessageCategoryConstants.call;
      call.type = (callType == CallType.audio.value)
          ? CallTypeConstants.audioCall
          : CallTypeConstants.videoCall;
      CometChatCallEvents.ccCallAccepted(call);

      CallSettingsBuilder callSettingsBuilder = (CallSettingsBuilder()
        ..enableDefaultLayout = true
        ..setAudioOnlyCall = call.type == CallTypeConstants.audioCall);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CometChatOngoingCall(
            callSettingsBuilder: callSettingsBuilder,
            sessionId: call.sessionId!,
            callWorkFlow: CallWorkFlow.defaultCalling,
          ),
        ),
      ).then((_) async {
        VoipNotificationHandler.endCallFromOngoingScreen(call.sessionId!);
      });
    }, onError: (e) {
      debugPrint("[FCM] [_acceptAndNavigate] Step5 - Call Accept Error");
      debugPrint(
          "Unable to accept call from incoming call screen ${e.message}");
    });
  }

  static Future<void> handleNativeCallIntent(BuildContext context) async {
    debugPrint(
        "[FCM] [handleNativeCallIntent] Checking for native call intent...");
    try {
      final intent = await voipPlatformChannel
          .invokeMethod<Map>("get_initial_call_intent");
      debugPrint(
          "[FCM] [handleNativeCallIntent] Calling Received call intent from native Before: $intent");
      if (intent != null) {
        debugPrint("[FCM] [handleNativeCallIntent] ✅ Received intent: $intent");

        final callId = intent["call_id"];
        final callType = intent["call_type"];
        final action = intent["call_action"];

        final eventType = action == "accept"
            ? Event.actionCallAccept
            : Event.actionCallDecline;

        final event = CallEvent(
          {
            "id": callId,
            "type": callType == "audio" ? 0 : 1,
          },
          eventType,
        );

        if (action == "accept") {
          VoipNotificationHandler.acceptVoipCall(event, context);
        } else {
          VoipNotificationHandler.declineVoipCall(event);
        }
      } else {
        debugPrint("[FCM] [handleNativeCallIntent] ⚠️ No intent received.");
      }
    } catch (e) {
      debugPrint("[FCM] [handleNativeCallIntent] ❌ Error: $e");
    }
  }
}
