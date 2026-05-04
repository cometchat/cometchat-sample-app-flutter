import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../cometchat_calls_uikit.dart';
import '../../../../cometchat_chat_uikit.dart';

/// BLoC for managing incoming call screen state and actions
///
/// This BLoC handles:
/// - Sound playback on initialization (unless disabled)
/// - Accept call action (calls SDK, navigates to OngoingCall)
/// - Reject call action (calls SDK, dismisses overlay)
/// - Call cancelled handling (dismisses overlay)
/// - CallStateService updates on init and close
///
/// Uses [CallListener] mixin for SDK events (onIncomingCallCancelled)
///
/// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7
class IncomingCallBloc extends Bloc<IncomingCallEvent, IncomingCallState>
    with CallListener {
  /// The active incoming call
  final Call call;

  /// User who is calling (optional, for display purposes)
  final User? user;

  /// Custom session settings builder (V5)
  final SessionSettingsBuilder? callSettingsBuilder;

  /// Callback when call is declined
  final Function(BuildContext, Call)? onDecline;

  /// Callback when call is accepted
  final Function(BuildContext, Call)? onAccept;

  /// Whether to disable sound for calls
  final bool? disableSoundForCalls;

  /// Custom sound asset for calls
  final String? customSoundForCalls;

  /// Package name for custom sound asset
  final String? customSoundForCallsPackage;

  /// Error callback
  final OnError? errorCallback;

  /// Unique listener ID for SDK listeners
  late final String _listenerId;

  /// Creates an IncomingCallBloc
  ///
  /// [call] is required and represents the active incoming call.
  /// Sound playback starts on init unless [disableSoundForCalls] is true.
  IncomingCallBloc({
    required this.call,
    this.user,
    this.callSettingsBuilder,
    this.onDecline,
    this.onAccept,
    this.disableSoundForCalls,
    this.customSoundForCalls,
    this.customSoundForCallsPackage,
    this.errorCallback,
  }) : super(const IncomingCallState()) {
    // Generate unique listener ID
    _listenerId =
        'incomingCall_${DateTime.now().microsecondsSinceEpoch.toString()}';

    // Register event handlers
    on<AcceptCall>(_onAcceptCall);
    on<RejectCall>(_onRejectCall);
    on<CallCancelled>(_onCallCancelled);

    // Initialize
    _initialize();
  }

  /// Initialize the BLoC - add listeners, update call state, play sound
  void _initialize() {
    // Update CallStateService to track active incoming call
    CallStateService.instance.setActiveIncomingValue(true);

    // Add SDK listener for call events
    CometChat.addCallListener(_listenerId, this);

    // Play incoming call sound unless disabled
    if (disableSoundForCalls != true) {
      _playIncomingSound();
    }
  }

  /// Play incoming call sound
  void _playIncomingSound() {
    try {
      CometChatUIKit.soundManager.play(
        sound: Sound.incomingCall,
        packageName: customSoundForCallsPackage ?? UIConstants.packageName,
        customSound: customSoundForCalls,
        isLooping: true,
      );
      developer.log('Incoming call sound playing');
    } catch (_) {
      developer.log('Failed to play incoming call sound');
    }
  }

  /// Stop sound playback
  void _stopSound() {
    try {
      CometChatUIKit.soundManager.stop();
    } catch (_) {
      developer.log('Failed to stop sound player');
    }
  }

  // ============================================================
  // SDK LISTENER CALLBACKS - CallListener
  // ============================================================

  /// Called when the incoming call is cancelled by the caller
  @override
  void onIncomingCallCancelled(Call call) {
    add(const CallCancelled());
  }

  /// Called when an outgoing call is rejected.
  /// This is an outgoing call event — do NOT dismiss the incoming call
  /// overlay here. The SDK broadcasts this to all CallListeners, but it's
  /// only relevant to the outgoing call screen.
  @override
  void onOutgoingCallRejected(Call call) {
    // No-op for incoming call — only onIncomingCallCancelled matters
  }

  /// Called when an outgoing call is accepted.
  /// Same as above — outgoing call event, not relevant to incoming overlay.
  @override
  void onOutgoingCallAccepted(Call call) {
    // No-op for incoming call
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Handle accept call event.
  ///
  /// Uses a [Completer] to bridge the callback-based [CometChat.acceptCall]
  /// into the async handler so that [emit] is called within the handler scope
  /// (prevents "emit was called after an event handler completed normally").
  Future<void> _onAcceptCall(
    AcceptCall event,
    Emitter<IncomingCallState> emit,
  ) async {
    // Guard: if the call was already cancelled/ended, don't try to accept
    if (state.status == IncomingCallStatus.cancelled ||
        state.status == IncomingCallStatus.accepting ||
        state.status == IncomingCallStatus.accepted) {
      developer.log(
        'IncomingCallBloc: ignoring AcceptCall — status is ${state.status}',
      );
      return;
    }

    // Disable buttons during accept
    emit(state.copyWith(
      status: IncomingCallStatus.accepting,
      isDisabled: true,
    ));

    // Execute custom onAccept callback if provided
    if (onAccept != null) {
      try {
        final navigatorContext =
            CallNavigationContext.navigatorKey.currentContext;
        if (navigatorContext != null) {
          onAccept!(navigatorContext, call);
        }
      } on CometChatException catch (error) {
        _handleError(error);
      }
    }

    // Get session ID
    final String? sessionId = call.sessionId;
    if (sessionId == null) {
      emit(state.copyWith(
        status: IncomingCallStatus.error,
        isDisabled: false,
        errorMessage: 'Session ID is null',
      ));
      return;
    }

    // Request microphone/camera permissions before accepting the call.
    // Without this, WebRTC throws SecurityError: Permission denied.
    final isVideoCall = call.type == CallTypeConstants.videoCall;
    final permissionGranted = await CallPermissions.requestForCallType(
      isVideoCall: isVideoCall,
    );
    if (!permissionGranted) {
      developer.log('Call permissions denied, cannot accept call');
      // Dismiss the overlay so the user isn't stuck on a frozen call screen
      IncomingCallOverlay.dismiss();
      // Reject the call on the server so the caller gets feedback
      final rejectUseCase = CallOperationsServiceLocator.instance.rejectCallUseCase;
      final rejectResult = await rejectUseCase.call(sessionId, CallStatusConstants.rejected);
      rejectResult.onSuccess((rejectedCall) {
        rejectedCall.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccCallRejected(rejectedCall);
      });
      emit(state.copyWith(
        status: IncomingCallStatus.error,
        isDisabled: false,
        errorMessage: 'Microphone${isVideoCall ? '/camera' : ''} permission denied',
      ));
      return;
    }

    // Accept call via use case
    final acceptCallUseCase = CallOperationsServiceLocator.instance.acceptCallUseCase;
    final result = await acceptCallUseCase.call(sessionId);

    result.fold(
      (failure) {
        _handleError(CometChatException('ERR', failure.message, ''));

        if (kDebugMode) {
          debugPrint('Call could not be accepted: ${failure.message}');
        }

        // Dismiss overlay on accept failure — the call is likely already
        // ended by the remote party
        IncomingCallOverlay.dismiss();

        emit(state.copyWith(
          status: IncomingCallStatus.error,
          isDisabled: false,
          errorMessage: failure.message,
        ));
      },
      (acceptedCall) {
        // Dismiss overlay
        IncomingCallOverlay.dismiss();

        // Fire call accepted event
        CometChatCallEvents.ccCallAccepted(acceptedCall);

        // Determine if audio only.
        // Log both values to diagnose cross-version type mismatches.
        developer.log(
          'IncomingCallBloc: call.type="${call.type}", '
          'acceptedCall.type="${acceptedCall.type}", '
          'sessionId="${sessionId}", acceptedCall.sessionId="${acceptedCall.sessionId}"',
        );

        // Check both the original incoming call and the accepted call.
        // For cross-version calls (V4→V5), the type field may be set
        // differently. Treat as video ONLY if explicitly marked as video.
        final bool isVideoCall =
            call.type == CallTypeConstants.videoCall ||
            acceptedCall.type == CallTypeConstants.videoCall;

        // Build session settings (V5)
        final SessionSettingsBuilder defaultSessionSettingsBuilder;
        if (callSettingsBuilder != null) {
          defaultSessionSettingsBuilder = callSettingsBuilder!;
        } else {
          defaultSessionSettingsBuilder = SessionSettingsBuilder()
            .setLayout(LayoutType.tile);
          if (!isVideoCall) {
            // Workaround: SessionType.audio sends "AUDIO" to the native
            // Android SDK which logs "Invalid session type: AUDIO" and
            // ignores it (beta SDK bug). Instead, start with video paused
            // and hide the video toggle so it behaves as audio-only.
            defaultSessionSettingsBuilder
              .startVideoPaused(true)
              .hideSwitchCameraButton(true)
              .hideToggleVideoButton(true);
          }
        }

        // Navigate to ongoing call screen via isolated overlay
        developer.log('IncomingCallBloc: showing CallScreenOverlay with sessionId=$sessionId');
        CallScreenOverlay.show(
          sessionId: sessionId,
          sessionSettingsBuilder: defaultSessionSettingsBuilder,
          callWorkFlow: CallWorkFlow.defaultCalling,
        );

        if (kDebugMode) {
          debugPrint('Call has been accepted successfully');
        }

        emit(state.copyWith(
          status: IncomingCallStatus.accepted,
          isDisabled: false,
        ));
      },
    );
  }

  /// Handle reject call event.
  ///
  /// Uses a [Completer] to bridge the callback-based [CometChatUIKitCalls.rejectCall]
  /// so that [emit] stays within the handler scope.
  Future<void> _onRejectCall(
    RejectCall event,
    Emitter<IncomingCallState> emit,
  ) async {
    // Guard: if the call was already cancelled/ended, don't try to reject
    if (state.status == IncomingCallStatus.cancelled ||
        state.status == IncomingCallStatus.rejecting ||
        state.status == IncomingCallStatus.rejected) {
      developer.log(
        'IncomingCallBloc: ignoring RejectCall — status is ${state.status}',
      );
      return;
    }

    // Update state to rejecting
    emit(state.copyWith(
      status: IncomingCallStatus.rejecting,
      isDisabled: true,
    ));

    // Execute custom onDecline callback if provided
    if (onDecline != null) {
      try {
        final navigatorContext =
            CallNavigationContext.navigatorKey.currentContext;
        if (navigatorContext != null) {
          onDecline!(navigatorContext, call);
        }
      } on CometChatException catch (error) {
        _handleError(error);
      }
    }

    // Get session ID
    final String? sessionId = call.sessionId;
    if (sessionId == null) {
      emit(state.copyWith(
        status: IncomingCallStatus.error,
        isDisabled: false,
        errorMessage: 'Session ID is null',
      ));
      return;
    }

    // Reject call via use case
    developer.log('Trying to reject call');
    final rejectCallUseCase = CallOperationsServiceLocator.instance.rejectCallUseCase;
    final result = await rejectCallUseCase.call(sessionId, CallStatusConstants.rejected);

    result.fold(
      (failure) {
        developer.log('Unable to reject call from incoming call screen');
        _handleError(CometChatException('ERR', failure.message, ''));

        // Still dismiss overlay on error
        IncomingCallOverlay.dismiss();

        emit(state.copyWith(
          status: IncomingCallStatus.error,
          isDisabled: false,
          errorMessage: failure.message,
        ));
      },
      (rejectedCall) {
        rejectedCall.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccCallRejected(rejectedCall);
        developer.log('Incoming call was rejected');

        // Dismiss overlay
        IncomingCallOverlay.dismiss();

        emit(state.copyWith(
          status: IncomingCallStatus.rejected,
          isDisabled: false,
        ));
      },
    );
  }

  /// Handle call cancelled event (caller cancelled)
  Future<void> _onCallCancelled(
    CallCancelled event,
    Emitter<IncomingCallState> emit,
  ) async {
    emit(state.copyWith(
      status: IncomingCallStatus.cancelled,
    ));

    // Dismiss overlay
    IncomingCallOverlay.dismiss();
  }

  /// Handle error - call errorCallback if provided
  void _handleError(CometChatException e) {
    if (errorCallback != null) {
      errorCallback!(e);
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get subtitle text based on call type
  String getSubtitle(BuildContext context) {
    return call.type == CallTypeConstants.audioCall
        ? Translations.of(context).incomingAudioCall
        : Translations.of(context).incomingVideoCall;
  }

  @override
  Future<void> close() {
    // Update CallStateService
    CallStateService.instance.setActiveIncomingValue(false);

    // Remove SDK listener
    CometChat.removeCallListener(_listenerId);

    // Stop sound playback
    if (disableSoundForCalls != true) {
      _stopSound();
    }

    return super.close();
  }
}
