import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../../../cometchat_calls_uikit.dart';

/// Status enum for ongoing call screen
enum OngoingCallStatus {
  /// Initial state, loading the calling screen
  loading,

  /// Call session is active
  active,

  /// Call is being ended
  ending,

  /// Call has ended
  ended,

  /// An error occurred
  error,
}

/// State class for OngoingCallBloc
/// Uses Equatable for proper state comparison in BLoC
class OngoingCallState extends Equatable {
  /// Current status of the ongoing call
  final OngoingCallStatus status;

  /// The calling widget from SDK
  final Widget? callingWidget;

  /// List of users in the call (legacy, kept for backward compat)
  final List<RTCUser> usersList;

  /// List of participants in the call (V5)
  final List<Participant> participantsList;

  /// Whether the call was ended by the current user
  final bool isCallEndedByMe;

  /// Error message when status is error
  final String? errorMessage;

  const OngoingCallState({
    this.status = OngoingCallStatus.loading,
    this.callingWidget,
    this.usersList = const [],
    this.participantsList = const [],
    this.isCallEndedByMe = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    callingWidget,
    usersList,
    participantsList,
    isCallEndedByMe,
    errorMessage,
  ];

  /// Create a copy of this state with updated fields
  OngoingCallState copyWith({
    OngoingCallStatus? status,
    Widget? callingWidget,
    List<RTCUser>? usersList,
    List<Participant>? participantsList,
    bool? isCallEndedByMe,
    String? errorMessage,
  }) {
    return OngoingCallState(
      status: status ?? this.status,
      callingWidget: callingWidget ?? this.callingWidget,
      usersList: usersList ?? this.usersList,
      participantsList: participantsList ?? this.participantsList,
      isCallEndedByMe: isCallEndedByMe ?? this.isCallEndedByMe,
      errorMessage: errorMessage,
    );
  }
}
