import 'package:equatable/equatable.dart';

/// Status enum for incoming call screen
enum IncomingCallStatus {
  /// Initial state, waiting for user action
  idle,

  /// Call is being accepted
  accepting,

  /// Call is being rejected
  rejecting,

  /// Call was successfully accepted
  accepted,

  /// Call was successfully rejected
  rejected,

  /// Call was cancelled by the caller
  cancelled,

  /// An error occurred during accept/reject
  error,
}

/// State class for IncomingCallBloc
/// Uses Equatable for proper state comparison in BLoC
class IncomingCallState extends Equatable {
  /// Current status of the incoming call
  final IncomingCallStatus status;

  /// Whether the accept/reject buttons are disabled
  final bool isDisabled;

  /// Error message when status is error
  final String? errorMessage;

  const IncomingCallState({
    this.status = IncomingCallStatus.idle,
    this.isDisabled = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, isDisabled, errorMessage];

  /// Create a copy of this state with updated fields
  IncomingCallState copyWith({
    IncomingCallStatus? status,
    bool? isDisabled,
    String? errorMessage,
  }) {
    return IncomingCallState(
      status: status ?? this.status,
      isDisabled: isDisabled ?? this.isDisabled,
      errorMessage: errorMessage,
    );
  }
}
