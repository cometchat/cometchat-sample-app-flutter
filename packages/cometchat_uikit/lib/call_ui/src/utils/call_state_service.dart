import 'package:flutter/foundation.dart';

/// Service for managing global call state using ValueNotifier pattern.
///
/// Replaces the GetX-based [CallStateController] singleton with a
/// ValueNotifier-based implementation that integrates cleanly with BLoC architecture.
///
/// Usage:
/// ```dart
/// // Access the singleton instance
/// final callState = CallStateService.instance;
///
/// // Listen to state changes
/// callState.isActiveCall.addListener(() {
///   print('Active call: ${callState.isActiveCall.value}');
/// });
///
/// // Update state
/// callState.setActiveCallValue(true);
/// ```
class CallStateService {
  /// Private constructor for singleton pattern.
  CallStateService._();

  /// Singleton instance of [CallStateService].
  static final CallStateService instance = CallStateService._();

  /// ValueNotifier tracking whether there is an active ongoing call.
  final ValueNotifier<bool> isActiveCall = ValueNotifier<bool>(false);

  /// ValueNotifier tracking whether there is an active incoming call.
  final ValueNotifier<bool> isActiveIncomingCall = ValueNotifier<bool>(false);

  /// ValueNotifier tracking whether there is an active outgoing call.
  final ValueNotifier<bool> isActiveOutgoingCall = ValueNotifier<bool>(false);

  /// Sets the active call state.
  ///
  /// Call this when an ongoing call session starts or ends.
  void setActiveCallValue(bool value) {
    isActiveCall.value = value;
  }

  /// Sets the active incoming call state.
  ///
  /// Call this when an incoming call is received or dismissed.
  void setActiveIncomingValue(bool value) {
    isActiveIncomingCall.value = value;
  }

  /// Sets the active outgoing call state.
  ///
  /// Call this when an outgoing call is initiated or ends.
  void setActiveOutgoingValue(bool value) {
    isActiveOutgoingCall.value = value;
  }
}
