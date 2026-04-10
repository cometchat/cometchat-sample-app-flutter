import '../../../cometchat_calls_uikit.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///[CometChatUIKitCalls] is a class that initializes the CometChat Calls SDK. And contains methods to initiate a call, accept a call, reject a call, end a call
class CometChatUIKitCalls {
  ///[init] is the method to initialize the CometChat Calls SDK. It takes [appId] and [region] as input. And an optional [onSuccess] and [onError] callback.
  static init(
    String appId,
    String region, {
    dynamic Function(String)? onSuccess,
    dynamic Function(CometChatCallsException)? onError,
  }) {
    CallAppSettings callAppSettings = (CallAppSettingBuilder()
          ..appId = appId
          ..region = region)
        .build();

    CometChatCalls.init(callAppSettings, onSuccess: (String successMessage) {
      //execute custom onSuccess callback
      try {
        if (onSuccess != null) {
          onSuccess(successMessage);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onSuccess callback $e');
        }
      }
      debugPrint(
          "CometChatCalls initialization completed successfully  $successMessage");
    }, onError: (CometChatCallsException e) {
      //execute custom onError callback
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback $e');
        }
      }
      debugPrint(
          "CometChatCalls initialization failed with exception: ${e.message}");
    });
  }

  ///[initiateCall] is the method to initiate a call. It takes [Call] as input. And an optional [onSuccess] and [onError] callback.
  static void initiateCall(Call call,
      {dynamic Function(Call)? onSuccess,
      dynamic Function(CometChatException)? onError}) {
    CometChat.initiateCall(call, onSuccess: (Call call) {
      //execute custom onSuccess callback
      try {
        if (onSuccess != null) {
          onSuccess(call);
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onSuccess callback: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }
      if (kDebugMode) {
        debugPrint('call initiated successfully');
      }
    }, onError: (CometChatException e) {
      //execute custom onError callback
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback');
        }
      }
      if (kDebugMode) {
        debugPrint(
            'call could not be initiated ${e.message} ${e.details} ${e.code}');
      }
    });
  }

  ///[acceptCall] is the method to accept a call. It takes [sessionId] as input. And an optional [onSuccess] and [onError] callback.
  static void acceptCall(String sessionId,
      {dynamic Function(Call)? onSuccess,
      dynamic Function(CometChatException)? onError}) {
    CometChat.acceptCall(sessionId, onSuccess: (Call call) {
//execute custom onSuccess callback
      try {
        if (onSuccess != null) {
          onSuccess(call);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onSuccess callback');
        }
      }
      if (kDebugMode) {
        debugPrint('call initiated successfully');
      }
    }, onError: (CometChatException e) {
//execute custom onError callback
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback');
        }
      }
      if (kDebugMode) {
        debugPrint('call could not be initiated ${e.message}');
      }
    });
  }

  ///[rejectCall] is the method to reject or cancel a call. It takes [sessionId] and [status] as input. And an optional [onSuccess] and [onError] callback.
  static void rejectCall(String sessionId, String status,
      {dynamic Function(Call)? onSuccess,
      dynamic Function(CometChatException)? onError}) {
    CometChat.rejectCall(sessionId, status, onSuccess: (Call call) {
      //execute custom onSuccess callback
      try {
        if (onSuccess != null) {
          onSuccess(call);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onSuccess callback');
        }
      }
      if (kDebugMode) {
        debugPrint('call rejected successfully');
      }
    }, onError: (CometChatException e) {
      //execute custom onError callback
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback: $e}');
        }
      }
      if (kDebugMode) {
        debugPrint('call could not be rejected ${e.message}');
      }
    });
  }

  ///[generateToken] generates a call token for the given [sessionId].
  /// Uses [CometChatCalls.generateCallToken] which manages the auth token
  /// internally (fetched during login).
  static void generateToken(
    String sessionId, {
    dynamic Function(CallToken)? onSuccess,
    dynamic Function(CometChatCallsException)? onError,
  }) {
    CometChatCalls.generateCallToken(
        sessionId,
        onSuccess: (CallToken callToken) {
      try {
        if (onSuccess != null) {
          onSuccess(callToken);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("unable to execute custom onSuccess callback");
        }
      }
      debugPrint("token was generated successfully: ${callToken.callToken}");
    }, onError: (CometChatCallsException e) {
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback');
        }
      }
      if (kDebugMode) {
        debugPrint('token could not be generated: ${e.message}');
      }
    });
  }

  ///[startSession] is the method to start a call session. It takes [callToken] and [sessionSettings] as input. And an optional [onSuccess] and [onError] callback.
  static void startSession(
    String callToken,
    SessionSettings sessionSettings, {
    dynamic Function(Widget?)? onSuccess,
    dynamic Function(CometChatCallsException)? onError,
  }) {
    CometChatCalls.joinSession(
        callToken: CallToken(token: callToken),
        sessionSettings: sessionSettings,
        onSuccess: (Widget? callingWidget) {
      try {
        if (onSuccess != null) {
          onSuccess(callingWidget);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("unable to execute custom onSuccess callback");
        }
      }
      if (kDebugMode) {
        debugPrint("startCallSession was successful");
      }
    }, onError: (CometChatCallsException e) {
      try {
        if (onError != null) {
          onError(e);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('unable to execute custom onError callback');
        }
      }
      if (kDebugMode) {
        debugPrint('startCallSession failed: ${e.message}');
      }
    });
  }

  ///[endSession] is the method to end a call session. It takes an optional [onSuccess] and [onError] callback.
  static Future<void> endSession(
      {dynamic Function(String)? onSuccess,
      dynamic Function(CometChatCallsException)? onError}) async {
    try {
      await CallSession.getInstance()?.leaveSession();
      CometChat.clearActiveCall();
      try {
        if (onSuccess != null) {
          onSuccess('session ended successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("unable to execute custom onSuccess callback");
        }
      }
      debugPrint("session ended successfully");
    } catch (e) {
      final error = e is CometChatCallsException
          ? e
          : CometChatCallsException(
              'ERR_END_SESSION',
              'Failed to end session',
              e.toString(),
            );
      try {
        if (onError != null) {
          onError(error);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("unable to execute custom onError callback");
        }
      }
      debugPrint("session could not be ended: ${error.message}");
    }
  }

  static Future<String?> getUserAuthToken() async {
    return await CometChat.getUserAuthToken();
  }
}
