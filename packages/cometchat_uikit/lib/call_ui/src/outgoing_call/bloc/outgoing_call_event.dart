import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import 'package:equatable/equatable.dart';

/// Base class for all outgoing call events
/// Uses Equatable for proper event comparison in BLoC
abstract class OutgoingCallEvent extends Equatable {
  const OutgoingCallEvent();

  @override
  List<Object?> get props => [];
}

/// Cancel the outgoing call
/// Triggers CometChatUIKitCalls.rejectCall with cancelled status
class CancelCall extends OutgoingCallEvent {
  const CancelCall();
}

/// Outgoing call was accepted by the receiver
/// Navigates to OngoingCall screen
class OutgoingCallAccepted extends OutgoingCallEvent {
  final Call call;

  const OutgoingCallAccepted(this.call);

  @override
  List<Object?> get props => [call];
}

/// Outgoing call was rejected by the receiver
/// Pops the screen
class OutgoingCallRejected extends OutgoingCallEvent {
  final Call call;

  const OutgoingCallRejected(this.call);

  @override
  List<Object?> get props => [call];
}
