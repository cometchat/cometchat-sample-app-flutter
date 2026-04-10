import "package:cometchat_sdk/cometchat_sdk.dart";
import 'cometchat_call_event_listener.dart';

/// class for handling call events.
class CometChatCallEvents {
  /// Map to store the registered call event listeners.
  static Map<String, CometChatCallEventListener> callEventsListener = {};

  /// Adds a call event listener with the specified tag.
  static void addCallEventsListener(
      String listenerId, CometChatCallEventListener listenerClass) {
    callEventsListener[listenerId] = listenerClass;
  }

  /// Removes the call event listener associated with the specified tag.
  static void removeCallEventsListener(String listenerId) {
    callEventsListener.remove(listenerId);
  }

  /// Called when an outgoing call is initiated by the logged-in user.
  static void ccOutgoingCall(Call call) {
    callEventsListener.forEach((key, value) {
      value.ccOutgoingCall(call);
    });
  }

  /// Called when a call is accepted by the logged-in user.
  static void ccCallAccepted(Call call) {
    callEventsListener.forEach((key, value) {
      value.ccCallAccepted(call);
    });
  }

  /// Called when a call is rejected by the logged-in user.
  static void ccCallRejected(Call call) {
    callEventsListener.forEach((key, value) {
      value.ccCallRejected(call);
    });
  }

  /// Called when a call is ended by the logged-in user.
  static void ccCallEnded(Call call) {
    callEventsListener.forEach((key, value) {
      value.ccCallEnded(call);
    });
  }
}
