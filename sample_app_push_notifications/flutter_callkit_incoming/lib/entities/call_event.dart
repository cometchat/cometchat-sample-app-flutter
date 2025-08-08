/// Object CallEvent.
class CallEvent {
  Event event;
  dynamic body;

  CallEvent(this.body, this.event);
  @override
  String toString() => 'CallEvent( body: $body, event: $event)';
}

enum Event {
  actionDidUpdateDevicePushTokenVoip,
  actionCallIncoming,
  actionCallStart,
  actionCallAccept,
  actionCallDecline,
  actionCallEnded,
  actionCallTimeout,
  actionCallConnected,
  actionCallCallback,
  actionCallToggleHold,
  actionCallToggleMute,
  actionCallToggleDmtf,
  actionCallToggleGroup,
  actionCallToggleAudioSession,
  actionCallCustom,
}

/// Using extension for backward compatibility Dart SDK 2.17.0 and lower
extension EventX on Event {
  String get name {
    switch (this) {
      case Event.actionDidUpdateDevicePushTokenVoip:
        return 'com.hiennv.flutter_callkit_incoming.DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP';
      case Event.actionCallIncoming:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_INCOMING';
      case Event.actionCallStart:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_START';
      case Event.actionCallAccept:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT';
      case Event.actionCallDecline:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_DECLINE';
      case Event.actionCallEnded:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_ENDED';
      case Event.actionCallTimeout:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TIMEOUT';
      case Event.actionCallConnected:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_CONNECTED';
      case Event.actionCallCallback:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_CALLBACK';
      case Event.actionCallToggleHold:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_HOLD';
      case Event.actionCallToggleMute:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_MUTE';
      case Event.actionCallToggleDmtf:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_DMTF';
      case Event.actionCallToggleGroup:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_GROUP';
      case Event.actionCallToggleAudioSession:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_TOGGLE_AUDIO_SESSION';
      case Event.actionCallCustom:
        return 'com.hiennv.flutter_callkit_incoming.ACTION_CALL_CUSTOM';
    }
  }
}
