import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Base class for all call buttons events
/// Uses Equatable for proper event comparison in BLoC
abstract class CallButtonsEvent extends Equatable {
  const CallButtonsEvent();

  @override
  List<Object?> get props => [];
}

/// Initiate a voice (audio) call
/// For user receivers: initiates a direct audio call
/// For group receivers: initiates a meeting with audio only
class InitiateVoiceCall extends CallButtonsEvent {
  const InitiateVoiceCall();
}

/// Initiate a video call
/// For user receivers: initiates a direct video call
/// For group receivers: initiates a meeting with video
class InitiateVideoCall extends CallButtonsEvent {
  const InitiateVideoCall();
}

/// Call was rejected by the receiver or system
/// Re-enables the call buttons
class CallRejected extends CallButtonsEvent {
  final Call call;

  const CallRejected(this.call);

  @override
  List<Object?> get props => [call];
}

/// Call has ended (either by user or remote party)
/// Re-enables the call buttons
class CallEnded extends CallButtonsEvent {
  final Call call;

  const CallEnded(this.call);

  @override
  List<Object?> get props => [call];
}
