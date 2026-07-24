import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../../../../cometchat_calls_uikit.dart';

/// Exception thrown when call operations fail.
class CallOperationsException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const CallOperationsException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() =>
      'CallOperationsException(message: $message, code: $code)';
}

/// Abstract interface for call operations data source.
abstract class CallOperationsDataSource {
  Future<Call> initiateCall(Call call);
  Future<Call> acceptCall(String sessionId);
  Future<Call> rejectCall(String sessionId, String status);
  Future<Call> endCall(String sessionId);
  Future<String> generateCallToken(String sessionId);
  Future<Widget> startSession(String sessionId, SessionSettings settings);
  Future<void> endSession();
  Future<CustomMessage> sendCustomMessage(CustomMessage message);
  Future<User?> getLoggedInUser();
  Future<String?> getUserAuthToken();
  Future<void> waitForCallsSdk();
}
