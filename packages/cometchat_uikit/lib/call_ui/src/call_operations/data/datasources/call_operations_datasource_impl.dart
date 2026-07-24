import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../cometchat_calls_uikit.dart';
import '../../../../../cometchat_chat_uikit.dart';

/// Implementation of [CallOperationsDataSource] using CometChat SDK.
///
/// Uses [Completer] to bridge callback-based SDK APIs to async/await.
class CallOperationsDataSourceImpl implements CallOperationsDataSource {
  @override
  Future<Call> initiateCall(Call call) async {
    final completer = Completer<Call>();
    CometChatUIKitCalls.initiateCall(
      call,
      onSuccess: (Call returnedCall) => completer.complete(returnedCall),
      onError: (CometChatException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to initiate call',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Call> acceptCall(String sessionId) async {
    final completer = Completer<Call>();
    CometChat.acceptCall(
      sessionId,
      onSuccess: (Call acceptedCall) => completer.complete(acceptedCall),
      onError: (CometChatException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to accept call',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Call> rejectCall(String sessionId, String status) async {
    final completer = Completer<Call>();
    CometChatUIKitCalls.rejectCall(
      sessionId,
      status,
      onSuccess: (Call rejectedCall) => completer.complete(rejectedCall),
      onError: (CometChatException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to reject call',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Call> endCall(String sessionId) async {
    final completer = Completer<Call>();
    CometChat.endCall(
      sessionId,
      onSuccess: (Call call) => completer.complete(call),
      onError: (CometChatException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to end call',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<String> generateCallToken(String sessionId) async {
    final completer = Completer<String>();
    CometChatUIKitCalls.generateToken(
      sessionId,
      onSuccess: (callToken) {
        final token = callToken.callToken;
        if (token == null) {
          completer.completeError(
            const CallOperationsException(
              message: 'Call token is null',
              code: 'NULL_TOKEN',
            ),
          );
        } else {
          completer.complete(token);
        }
      },
      onError: (CometChatCallsException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to generate call token',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Widget> startSession(
    String sessionId,
    SessionSettings settings,
  ) async {
    final completer = Completer<Widget>();
    CometChatUIKitCalls.startSession(
      sessionId,
      settings,
      onSuccess: (dynamic screen) {
        developer.log(
          'CallOperationsDataSource: startSession onSuccess, screen=$screen, platform=${defaultTargetPlatform.name}',
        );
        // On Android, joinSession returns null — the call UI is rendered
        // natively by the Calls SDK. Return a transparent widget so the
        // bloc can emit active status.
        // On iOS, screen is a Flutter Widget.
        if (screen != null) {
          completer.complete(screen as Widget);
        } else {
          completer.complete(const SizedBox.shrink());
        }
      },
      onError: (CometChatCallsException e) {
        developer.log(
          'CallOperationsDataSource: startSession onError: ${e.message}',
        );
        completer.completeError(
          CallOperationsException(
            message: e.message ?? 'Failed to start session',
            code: e.code,
            originalException: e,
          ),
        );
      },
    );

    // On Android the native SDK may never call onSuccess/onError because
    // it launches a separate Activity. Time out after 5s and resolve anyway.
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        developer.log(
          'CallOperationsDataSource: startSession timed out — assuming Android native UI launched',
        );
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Future<void> endSession() async {
    final completer = Completer<void>();
    CometChatUIKitCalls.endSession(
      onSuccess: (_) => completer.complete(),
      onError: (CometChatCallsException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to end session',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<CustomMessage> sendCustomMessage(CustomMessage message) async {
    final completer = Completer<CustomMessage>();
    CometChatUIKit.sendCustomMessage(
      message,
      onSuccess: (CustomMessage sent) => completer.complete(sent),
      onError: (CometChatException e) => completer.completeError(
        CallOperationsException(
          message: e.message ?? 'Failed to send custom message',
          code: e.code,
          originalException: e,
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<User?> getLoggedInUser() async {
    return await CometChatUIKit.getLoggedInUser();
  }

  @override
  Future<String?> getUserAuthToken() async {
    return await CometChat.getUserAuthToken();
  }

  @override
  Future<void> waitForCallsSdk() async {
    await CallEventService.instance.waitForCallsSdk();
  }
}
