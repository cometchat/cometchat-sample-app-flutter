import 'package:equatable/equatable.dart';

/// State for CallButtons BLoC
/// Manages button disabled state and call initiation workflow
///
/// Validates: Requirements 2.1, 2.6
class CallButtonsState extends Equatable {
  /// Whether the call buttons are disabled
  /// Buttons are disabled during call initiation to prevent double-taps
  final bool isDisabled;

  /// Whether a call is currently in progress
  /// True after successful call initiation, false after call ends/rejects
  final bool isCallInProgress;

  /// Error message if call initiation failed
  /// Null when no error has occurred
  final String? errorMessage;

  const CallButtonsState({
    this.isDisabled = false,
    this.isCallInProgress = false,
    this.errorMessage,
  });

  /// Initial state with all defaults
  factory CallButtonsState.initial() => const CallButtonsState();

  @override
  List<Object?> get props => [isDisabled, isCallInProgress, errorMessage];

  /// Create a copy of this state with updated fields
  CallButtonsState copyWith({
    bool? isDisabled,
    bool? isCallInProgress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CallButtonsState(
      isDisabled: isDisabled ?? this.isDisabled,
      isCallInProgress: isCallInProgress ?? this.isCallInProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
