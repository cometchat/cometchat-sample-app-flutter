import 'package:equatable/equatable.dart';

/// Base class for all incoming call events
/// Uses Equatable for proper event comparison in BLoC
abstract class IncomingCallEvent extends Equatable {
  const IncomingCallEvent();

  @override
  List<Object?> get props => [];
}

/// Accept the incoming call
/// Triggers CometChat.acceptCall and navigates to OngoingCall screen on success
class AcceptCall extends IncomingCallEvent {
  const AcceptCall();
}

/// Reject the incoming call
/// Triggers CometChatUIKitCalls.rejectCall and dismisses the overlay
class RejectCall extends IncomingCallEvent {
  const RejectCall();
}

/// Call was cancelled by the caller
/// Dismisses the overlay automatically
class CallCancelled extends IncomingCallEvent {
  const CallCancelled();
}
