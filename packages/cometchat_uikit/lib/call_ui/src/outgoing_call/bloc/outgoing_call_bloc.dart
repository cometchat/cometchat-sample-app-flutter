import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../cometchat_calls_uikit.dart';
import '../../../../cometchat_chat_uikit.dart';

/// BLoC for managing outgoing call screen state and actions
///
/// This BLoC handles:
/// - Sound playback on initialization (unless disabled)
/// - Cancel call action (calls SDK with cancelled status)
/// - Outgoing call accepted handling (navigates to OngoingCall)
/// - Outgoing call rejected handling (pops screen)
/// - CallStateService updates on init and close
///
/// Uses [CometChatCallEventListener] and [CallListener] mixins for SDK events
///
/// Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7
class OutgoingCallBloc extends Bloc<OutgoingCallEvent, OutgoingCallState>
    with CometChatCallEventListener, CallListener {
  /// The active outgoing call
  final Call call;

  /// User being called (optional, for display purposes)
  final User? user;

  /// Custom session settings builder (V5)
  final SessionSettingsBuilder? callSettingsBuilder;

  /// Callback when call is cancelled
  final Function(BuildContext, Call)? onCancelledCallTap;

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

  /// Creates an OutgoingCallBloc
  ///
  /// [call] is required and represents the active outgoing call.
  /// Sound playback starts on init unless [disableSoundForCalls] is true.
  OutgoingCallBloc({
    required this.call,
    this.user,
    this.callSettingsBuilder,
    this.onCancelledCallTap,
    this.disableSoundForCalls,
    this.customSoundForCalls,
    this.customSoundForCallsPackage,
    this.errorCallback,
  }) : super(const OutgoingCallState()) {
    // Generate unique listener ID
    _listenerId =
        'outgoingCall_${DateTime.now().microsecondsSinceEpoch.toString()}';

    // Register event handlers
    on<CancelCall>(_onCancelCall);
    on<OutgoingCallAccepted>(_onOutgoingCallAccepted);
    on<OutgoingCallRejected>(_onOutgoingCallRejected);

    // Initialize
    _initialize();
  }

  /// Initialize the BLoC - add listeners, update call state, play sound
  void _initialize() {
    // Update CallStateService to track active outgoing call
    CallStateService.instance.setActiveOutgoingValue(true);

    // Add SDK listeners for call events
    CometChat.addCallListener(_listenerId, this);
    CometChatCallEvents.addCallEventsListener(_listenerId, this);

    // Play outgoing call sound unless disabled
    if (disableSoundForCalls != true) {
      _playOutgoingSound();
    }
  }

  /// Play outgoing call sound
  void _playOutgoingSound() {
    try {
      CometChatUIKit.soundManager.play(
        sound: Sound.outgoingCall,
        packageName: customSoundForCallsPackage ?? UIConstants.packageName,
        customSound: customSoundForCalls,
        isLooping: true,
      );
      developer.log('Outgoing call sound playing');
    } catch (_) {
      developer.log('Failed to play outgoing call sound');
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
  // SDK LISTENER CALLBACKS - CallListener & CometChatCallEventListener
  // ============================================================

  /// Called when the outgoing call is accepted by the receiver
  @override
  void onOutgoingCallAccepted(Call call) {
    add(OutgoingCallAccepted(call));
  }

  /// Called when the outgoing call is rejected by the receiver
  @override
  void onOutgoingCallRejected(Call call) {
    add(OutgoingCallRejected(call));
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Handle cancel call event
  Future<void> _onCancelCall(
    CancelCall event,
    Emitter<OutgoingCallState> emit,
  ) async {
    // Check if already cancelling or rejected
    if (state.isCallRejected || state.status == OutgoingCallStatus.cancelling) {
      return;
    }

    // Execute custom onCancelledCallTap callback if provided
    if (onCancelledCallTap != null) {
      try {
        final navigatorContext =
            CallNavigationContext.navigatorKey.currentContext;
        if (navigatorContext != null) {
          onCancelledCallTap!(navigatorContext, call);
          return; // Custom handler takes over
        }
      } catch (e) {
        developer.log('Error in onCancelledCallTap: $e');
      }
    }

    // Update state to cancelling
    emit(state.copyWith(
      status: OutgoingCallStatus.cancelling,
      isCallRejected: true,
    ));

    // Get session ID
    final String? sessionId = call.sessionId;
    if (sessionId == null) {
      emit(state.copyWith(
        status: OutgoingCallStatus.error,
        isCallRejected: false,
        errorMessage: 'Session ID is null',
      ));
      return;
    }

    // Cancel call via use case
    final rejectCallUseCase = CallOperationsServiceLocator.instance.rejectCallUseCase;
    final result = await rejectCallUseCase.call(sessionId, CallStatusConstants.cancelled);

    result.fold(
      (failure) {
        developer.log('Error cancelling call: ${failure.message}');
        _handleError(CometChatException('ERR', failure.message, ''));
        emit(state.copyWith(
          status: OutgoingCallStatus.error,
          isCallRejected: false,
          errorMessage: failure.message,
        ));
      },
      (cancelledCall) {
        cancelledCall.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccCallRejected(cancelledCall);
        developer.log('Outgoing call was cancelled');
        emit(state.copyWith(
          status: OutgoingCallStatus.rejected,
          isCallRejected: false,
        ));
      },
    );

    // Pop the screen regardless of success/error
    _popScreen();
  }

  /// Handle outgoing call accepted event
  Future<void> _onOutgoingCallAccepted(
    OutgoingCallAccepted event,
    Emitter<OutgoingCallState> emit,
  ) async {
    emit(state.copyWith(status: OutgoingCallStatus.accepted));

    // Request permissions before navigating to the ongoing call screen.
    // OngoingCallBloc no longer requests them to avoid race conditions.
    final isVideoCall = event.call.type == CallTypeConstants.videoCall;
    final permissionGranted = await CallPermissions.requestForCallType(
      isVideoCall: isVideoCall,
    );
    if (isClosed) return;
    if (!permissionGranted) {
      developer.log('OutgoingCallBloc: permissions denied, cannot join call');
      _popScreen();
      return;
    }

    // Determine if video call — default to audio if type is not explicitly video
    final bool isVideoForSession = event.call.type == CallTypeConstants.videoCall;

    // Build call settings
    final SessionSettingsBuilder defaultSessionSettingsBuilder;
    if (callSettingsBuilder != null) {
      defaultSessionSettingsBuilder = callSettingsBuilder!;
    } else {
      defaultSessionSettingsBuilder = SessionSettingsBuilder()
        .setLayout(LayoutType.tile);
      if (!isVideoForSession) {
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

    // Navigate to ongoing call screen
    final navigatorContext = CallNavigationContext.navigatorKey.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      Navigator.pushReplacement(
        navigatorContext,
        MaterialPageRoute(
          builder: (context) => CometChatOngoingCall(
            sessionSettingsBuilder: defaultSessionSettingsBuilder,
            sessionId: event.call.sessionId!,
            callWorkFlow: CallWorkFlow.defaultCalling,
          ),
        ),
      );
    }

    developer.log('Outgoing call was accepted');
  }

  /// Handle outgoing call rejected event
  Future<void> _onOutgoingCallRejected(
    OutgoingCallRejected event,
    Emitter<OutgoingCallState> emit,
  ) async {
    emit(state.copyWith(status: OutgoingCallStatus.rejected));

    // Pop the screen
    _popScreen();

    developer.log('Outgoing call was rejected');
  }

  /// Pop the current screen
  void _popScreen() {
    final navigatorContext = CallNavigationContext.navigatorKey.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      Navigator.pop(navigatorContext);
    }
  }

  /// Handle error - call errorCallback if provided
  void _handleError(CometChatException e) {
    if (errorCallback != null) {
      errorCallback!(e);
    }
  }

  @override
  Future<void> close() {
    // Update CallStateService
    CallStateService.instance.setActiveOutgoingValue(false);

    // Remove SDK listeners
    CometChat.removeCallListener(_listenerId);
    CometChatCallEvents.removeCallEventsListener(_listenerId);

    // Stop sound playback
    if (disableSoundForCalls != true) {
      _stopSound();
    }

    developer.log('OutgoingCallBloc closed');

    return super.close();
  }
}
