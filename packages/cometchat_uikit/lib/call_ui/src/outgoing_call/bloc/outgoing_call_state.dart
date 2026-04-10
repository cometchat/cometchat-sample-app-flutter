import 'package:equatable/equatable.dart';

/// Status enum for outgoing call screen
enum OutgoingCallStatus {
  /// Initial state, waiting for receiver response
  idle,

  /// Call is being cancelled
  cancelling,

  /// Call was accepted by the receiver
  accepted,

  /// Call was rejected by the receiver
  rejected,

  /// An error occurred during cancellation
  error,
}

/// State class for OutgoingCallBloc
/// Uses Equatable for proper state comparison in BLoC
class OutgoingCallState extends Equatable {
  /// Current status of the outgoing call
  final OutgoingCallStatus status;

  /// Whether the call was rejected by the receiver
  final bool isCallRejected;

  /// Error message when status is error
  final String? errorMessage;

  const OutgoingCallState({
    this.status = OutgoingCallStatus.idle,
    this.isCallRejected = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, isCallRejected, errorMessage];

  /// Create a copy of this state with updated fields
  OutgoingCallState copyWith({
    OutgoingCallStatus? status,
    bool? isCallRejected,
    String? errorMessage,
  }) {
    return OutgoingCallState(
      status: status ?? this.status,
      isCallRejected: isCallRejected ?? this.isCallRejected,
      errorMessage: errorMessage,
    );
  }
}
