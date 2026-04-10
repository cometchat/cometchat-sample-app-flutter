import 'package:equatable/equatable.dart';

import '../../../../cometchat_calls_uikit.dart';

/// Base class for all ongoing call events
/// Uses Equatable for proper event comparison in BLoC
abstract class OngoingCallEvent extends Equatable {
  const OngoingCallEvent();

  @override
  List<Object?> get props => [];
}

/// Load the calling screen
/// Triggers token generation and session start
class LoadCallingScreen extends OngoingCallEvent {
  const LoadCallingScreen();
}

/// End call button was pressed
/// Behavior depends on callWorkFlow:
/// - directCalling: ends session
/// - defaultCalling: ends call if usersList.length <= 1
class EndCallButtonPressed extends OngoingCallEvent {
  const EndCallButtonPressed();
}

/// Session timeout occurred
/// Ends the session
class SessionTimeout extends OngoingCallEvent {
  const SessionTimeout();
}

/// Call ended (from SDK callback)
/// Behavior depends on who ended the call
class OngoingCallEnded extends OngoingCallEvent {
  const OngoingCallEnded();
}

/// User list changed (from SDK callback)
/// Updates the participants list in state
class UserListChanged extends OngoingCallEvent {
  final List<RTCUser> users;

  const UserListChanged(this.users);

  @override
  List<Object?> get props => [users];
}

/// Participant list changed (from V5 SDK callback)
/// Updates the participants list in state
class ParticipantListChanged extends OngoingCallEvent {
  final List<Participant> participants;

  const ParticipantListChanged(this.participants);

  @override
  List<Object?> get props => [participants];
}

/// Calling widget received from SDK
class CallingWidgetReceived extends OngoingCallEvent {
  final dynamic widget;

  const CallingWidgetReceived(this.widget);

  @override
  List<Object?> get props => [widget];
}
