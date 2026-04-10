import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter/widgets.dart';

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Shared repository interface for call operations used across
/// call_buttons, incoming_call, outgoing_call, and ongoing_call.
///
/// Abstracts all CometChat SDK call operations behind a single interface
/// for testability and SDK isolation.
abstract class CallOperationsRepository {
  /// Initiate a call (direct call to a user).
  Future<Result<Call>> initiateCall(Call call);

  /// Accept an incoming call.
  Future<Result<Call>> acceptCall(String sessionId);

  /// Reject/cancel a call with a given status.
  Future<Result<Call>> rejectCall(String sessionId, String status);

  /// End an active call via CometChat SDK.
  Future<Result<Call>> endCall(String sessionId);

  /// Generate a call token for joining a session.
  Future<Result<String>> generateCallToken(String sessionId);

  /// Start a call session with the given token and settings.
  /// Returns the calling widget on success.
  Future<Result<Widget>> startSession(
      String callToken, SessionSettings settings);

  /// End the current WebRTC session.
  Future<Result<void>> endSession();

  /// Send a custom message (used for meeting messages).
  Future<Result<CustomMessage>> sendCustomMessage(CustomMessage message);

  /// Get the currently logged-in user.
  Future<Result<User?>> getLoggedInUser();

  /// Get the user auth token.
  Future<Result<String?>> getUserAuthToken();

  /// Wait for the Calls SDK to be fully initialized.
  Future<void> waitForCallsSdk();
}
