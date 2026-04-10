import '../../../cometchat_uikit_shared.dart';

///Listener class for [CometChatCallEvents]
mixin CometChatCallEventListener implements UIEventHandler {
  ///[ccOutgoingCall] is used to inform the listeners that an outgoing call is initiated by the logged-in user.
  void ccOutgoingCall(Call call) {}

  ///[ccCallAccepted] is used to inform the listeners that a call is accepted by the logged-in user.
  void ccCallAccepted(Call call) {}

  ///[ccCallRejected] is used to inform the listeners that a call is rejected by the logged-in user.
  void ccCallRejected(Call call) {}

  ///[ccCallEnded] is used to inform the listeners that a call is ended by either the logged-in user.
  void ccCallEnded(Call call) {}
}
