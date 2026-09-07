import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../cometchat_calls_uikit.dart';
import '../../../../cometchat_chat_uikit.dart';

/// Session status listener for the ongoing call
class _OngoingCallSessionListener extends SessionStatusListeners {
  final OngoingCallBloc bloc;
  _OngoingCallSessionListener(this.bloc);

  @override
  void onSessionTimedOut() => bloc.add(const SessionTimeout());

  @override
  void onSessionLeft() => bloc.add(const OngoingCallEnded());

  @override
  void onConnectionClosed() => bloc.add(const OngoingCallEnded());
}

/// Button click listener for the ongoing call
class _OngoingCallButtonListener extends ButtonClickListeners {
  final OngoingCallBloc bloc;
  _OngoingCallButtonListener(this.bloc);

  @override
  void onLeaveSessionButtonClicked() => bloc.add(const EndCallButtonPressed());
}

/// Participant event listener for the ongoing call
class _OngoingCallParticipantListener extends ParticipantEventListeners {
  final OngoingCallBloc bloc;
  _OngoingCallParticipantListener(this.bloc);

  @override
  void onParticipantListChanged(List<Participant> participants) {
    bloc.add(ParticipantListChanged(participants));
  }

  @override
  void onParticipantLeft(Participant participant) {
    bloc.add(ParticipantLeft(participant));
  }
}

/// BLoC for managing ongoing call screen state and actions
///
/// This BLoC handles:
/// - Session initialization (generate token, join session)
/// - End call button press (leave session for direct calling, end call otherwise)
/// - Session timeout handling
/// - Call ended handling (end call or session based on who ended)
/// - Participant list tracking
/// - CallStateService updates on init and close
/// - Device orientation restoration in close()
class OngoingCallBloc extends Bloc<OngoingCallEvent, OngoingCallState> {
  /// Session settings builder
  final SessionSettingsBuilder sessionSettingsBuilder;

  /// Session ID for the call
  final String sessionId;

  /// Error callback
  final OnError? errorCallback;

  /// Call workflow type (directCalling or defaultCalling)
  final CallWorkFlow? callWorkFlow;

  /// Internal list of participants in the call
  List<Participant> _participantsList = [];

  /// Set once the auto-teardown has fired, so a later participant update
  /// cannot queue a second end-call sequence.
  bool _peerLeftHandled = false;

  /// Whether the call screen has already been dismissed.
  ///
  /// _closeCallScreen() runs more than once per teardown (explicitly in
  /// _onCallEnded, then again inside _endCall/_endSession's folds). After the
  /// first dismissal CallScreenOverlay.isShowing is false, so a second run
  /// would fall through to the Navigator branch and pop whatever route is
  /// underneath the call screen.
  bool _callScreenClosed = false;

  /// Internal listeners for V5 SDK callbacks
  late final _OngoingCallSessionListener _sessionListener;
  late final _OngoingCallButtonListener _buttonListener;
  late final _OngoingCallParticipantListener _participantListener;

  /// Creates an OngoingCallBloc
  OngoingCallBloc({
    required this.sessionSettingsBuilder,
    required this.sessionId,
    this.errorCallback,
    this.callWorkFlow,
  }) : super(const OngoingCallState()) {
    // Create listeners
    _sessionListener = _OngoingCallSessionListener(this);
    _buttonListener = _OngoingCallButtonListener(this);
    _participantListener = _OngoingCallParticipantListener(this);

    // Register event handlers
    on<LoadCallingScreen>(_onLoadCallingScreen);
    on<EndCallButtonPressed>(_onEndCallButtonPressed);
    on<SessionTimeout>(_onSessionTimeout);
    on<OngoingCallEnded>(_onCallEnded);
    on<ParticipantListChanged>(_onParticipantListChanged);
    on<ParticipantLeft>(_onParticipantLeft);

    // Initialize
    _initialize();
  }

  /// Initialize the BLoC
  void _initialize() {
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Update CallStateService to track active call
    CallStateService.instance.setActiveCallValue(true);

    // Load the calling screen
    add(const LoadCallingScreen());
  }

  /// Handle calls error from SDK
  void handleCallsError(CometChatCallsException ce) {
    if (errorCallback != null) {
      errorCallback!(
        CometChatException(
          ce.code,
          ce.message ?? 'Call error occurred',
          ce.details ?? '',
        ),
      );
    }
  }

  /// Infer whether a call session is audio-only.
  ///
  /// The codebase uses two equivalent conventions:
  /// 1. `SessionType.audio` (native AUDIO value) when supported by the SDK.
  /// 2. A workaround used across UIKit code where `SessionType.video` is
  ///    combined with `startVideoPaused=true` + `hideToggleVideoButton=true`
  ///    — this works around a beta-SDK bug where Android ignores
  ///    `SessionType.audio` and logs "Invalid session type: AUDIO".
  ///
  /// Both are treated as audio-only here so we don't ask for the camera
  /// runtime permission on calls that never use the camera.
  static bool _isAudioOnlySession(SessionSettings s) {
    if (s.type == SessionType.audio) return true;
    if (s.startVideoPaused && s.hideToggleVideoButton) return true;
    return false;
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Handle load calling screen event.
  ///
  /// Uses the V5 sessionId-based joinSession API. The SDK generates the
  /// call token internally — no separate generateCallToken step needed.
  Future<void> _onLoadCallingScreen(
    LoadCallingScreen event,
    Emitter<OngoingCallState> emit,
  ) async {
    emit(state.copyWith(status: OngoingCallStatus.loading));

    // Ensure the Calls SDK is fully initialized and logged in.
    await CallOperationsServiceLocator.instance.repository.waitForCallsSdk();

    // Guard: if the SDK still isn't ready after waiting, fail with a clear
    // message instead of letting the native SDK throw a cryptic error.
    if (!CallEventService.instance.isCallsSdkReady) {
      developer.log(
        'OngoingCallBloc: Calls SDK not ready after waitForCallsSdk — cannot start session',
      );
      emit(
        state.copyWith(
          status: OngoingCallStatus.error,
          errorMessage: 'Call service is not ready. Please try again.',
        ),
      );
      return;
    }

    // Android 14+ (targetSdk 34+) blocks starting the OngoingCallService
    // foreground service with SecurityException if RECORD_AUDIO / CAMERA
    // are not granted at runtime. The calls plugin's OngoingCallService
    // declares FGS types `mediaPlayback|microphone|camera` and the OS
    // validates each required runtime permission when startForeground()
    // is called. Path-level checks elsewhere (OutgoingCallBloc,
    // IncomingCallBloc, VoipCallHandler) can be bypassed by cold-boot
    // VOIP accepts (pendingCallNavigation jumps straight here). Do the
    // final check here so no path reaches startSession without mic+camera.
    final SessionSettings sessionSettings = sessionSettingsBuilder.build();
    final bool isAudioOnly = _isAudioOnlySession(sessionSettings);
    final permissionGranted = await CallPermissions.requestForCallType(
      isVideoCall: !isAudioOnly,
    );
    if (isClosed) return;
    if (!permissionGranted) {
      developer.log(
        'OngoingCallBloc: permissions denied (audioOnly=$isAudioOnly), aborting session',
      );
      emit(
        state.copyWith(
          status: OngoingCallStatus.error,
          errorMessage:
              'Microphone${isAudioOnly ? '' : ' and camera'} permission is required to join the call.',
        ),
      );
      return;
    }

    developer.log('OngoingCallBloc: Joining session $sessionId');

    // Join session directly with sessionId — SDK handles token internally
    final startSessionUseCase =
        CallOperationsServiceLocator.instance.startSessionUseCase;
    final sessionResult = await startSessionUseCase.call(
      sessionId,
      sessionSettings,
    );

    if (isClosed) return;

    sessionResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: OngoingCallStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (screen) {
        // Register listeners AFTER session starts successfully
        final session = CallSession.getInstance();
        session?.addSessionStatusListener(_sessionListener);
        session?.addButtonClickListener(_buttonListener);
        session?.addParticipantEventListener(_participantListener);

        emit(
          state.copyWith(
            status: OngoingCallStatus.active,
            callingWidget: screen,
          ),
        );
      },
    );
  }

  /// Handle end call button pressed event
  Future<void> _onEndCallButtonPressed(
    EndCallButtonPressed event,
    Emitter<OngoingCallState> emit,
  ) async {
    if (callWorkFlow == CallWorkFlow.directCalling) {
      await _endSession(emit);
    } else {
      // Mark this as a local hangup BEFORE any teardown runs.
      // _endSessionQuietly() leaves the RTC session, which fires
      // onSessionLeft/onConnectionClosed -> OngoingCallEnded. Setting the flag
      // after those awaits meant _onCallEnded always observed
      // isCallEndedByMe=false, so the ender branch never executed and the
      // teardown fell through to a second _endSession instead.
      emit(state.copyWith(isCallEndedByMe: true));

      // Per CometChat docs: leave the WebRTC session first, then notify
      // the server via endCall. This ensures the other participant receives
      // the "call ended" event only after the session is torn down.
      await _endSessionQuietly();
      // Always end the call on the server for 1-on-1 calls so the other
      // participant gets the "call ended" event. The participant count
      // check was unreliable — the list may still show 2 participants
      // at this point because the leave hasn't propagated yet, causing
      // _endCall to be skipped and the receiver to stay in the call.
      await _endCall(emit);
    }
  }

  /// Handle session timeout event
  Future<void> _onSessionTimeout(
    SessionTimeout event,
    Emitter<OngoingCallState> emit,
  ) async {
    await _endSession(emit);
  }

  /// Handle call ended event
  Future<void> _onCallEnded(
    OngoingCallEnded event,
    Emitter<OngoingCallState> emit,
  ) async {
    if (callWorkFlow == CallWorkFlow.defaultCalling) {
      if (state.isCallEndedByMe) {
        _closeCallScreen();
        if (!isClosed) {
          emit(state.copyWith(status: OngoingCallStatus.ended));
        }
      } else {
        await _endSession(emit);
      }
    }
  }

  /// Handle participant list changed event
  Future<void> _onParticipantListChanged(
    ParticipantListChanged event,
    Emitter<OngoingCallState> emit,
  ) async {
    _participantsList = [...event.participants];
    emit(state.copyWith(participantsList: _participantsList));

    _evaluatePeerLeft();
  }

  /// Handles a participant leaving the session.
  ///
  /// Not observed on iOS - the native Calls SDK emits no participant
  /// join/leave events there - but kept for platforms that do deliver it.
  /// The leaver is discounted explicitly because the participant list may not
  /// have refreshed by the time the leave arrives.
  Future<void> _onParticipantLeft(
    ParticipantLeft event,
    Emitter<OngoingCallState> emit,
  ) async {
    _evaluatePeerLeft(excludeUid: event.participant.uid);
  }

  /// Ends a 1-on-1 call once no other participant remains.
  ///
  /// Mirrors the v5 UIKit guard (`onUserLeft` -> end the session when only the
  /// local user is left), but is driven by whichever signal the platform
  /// actually delivers: on iOS only `onParticipantListChanged` arrives, and it
  /// carries an empty list at the moment the peer goes away.
  ///
  /// The peer's app can terminate without a clean hangup, in which case no
  /// call-ended message arrives and nothing else closes this screen. Ends the
  /// call through the same path as the end-call button, which tears the screen
  /// down whether or not the endCall API succeeds.
  void _evaluatePeerLeft({String? excludeUid}) {
    final remaining = _otherCount(_participantsList, excludeUid: excludeUid);

    if (callWorkFlow != CallWorkFlow.defaultCalling) return;
    if (!_isOneToOneCall) return;
    if (state.isCallEndedByMe || _peerLeftHandled) return;
    if (remaining > 0) return;

    _peerLeftHandled = true;
    add(const EndCallButtonPressed());
  }

  /// Participants other than the logged-in user.
  ///
  /// Counts *others* rather than the whole list, which keeps this correct
  /// whether or not the SDK includes the local user in the participant list.
  int _otherCount(List<Participant> participants, {String? excludeUid}) {
    final myUid = CometChatUIKit.loggedInUser?.uid;
    return participants
        .where((p) => p.uid != myUid && p.uid != excludeUid)
        .length;
  }

  /// True when the active call is a 1-on-1 (user-to-user) call.
  bool get _isOneToOneCall {
    final active = CallEventService.instance.activeCall;
    return active is Call && active.receiverType == ReceiverTypeConstants.user;
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// End the call via use case.
  Future<void> _endCall(Emitter<OngoingCallState> emit) async {
    emit(state.copyWith(status: OngoingCallStatus.ending));

    final endCallUseCase = CallOperationsServiceLocator.instance.endCallUseCase;
    final result = await endCallUseCase.call(sessionId);

    if (isClosed) return;

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Call could not be ended: ${failure.message}');
        }
        _handleError(CometChatException('ERR', failure.message, ''));
        _closeCallScreen();
        emit(
          state.copyWith(
            status: OngoingCallStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (call) {
        _closeCallScreen(call: call, callStatus: 'endCall');
        emit(state.copyWith(status: OngoingCallStatus.ended));
      },
    );
  }

  /// End the session via use case.
  Future<void> _endSession(Emitter<OngoingCallState> emit) async {
    emit(state.copyWith(status: OngoingCallStatus.ending));

    final endSessionUseCase =
        CallOperationsServiceLocator.instance.endSessionUseCase;
    final result = await endSessionUseCase.call();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Session could not be ended: ${failure.message}');
        }
        _handleError(CometChatException('ERR', failure.message, ''));
        // Close the screen even when teardown fails, matching _endCall. On the
        // remote-hangup path this fold is the only thing standing between a
        // failed endSession and a call screen the user cannot dismiss.
        _closeCallScreen();
        emit(
          state.copyWith(
            status: OngoingCallStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        _closeCallScreen();
        emit(state.copyWith(status: OngoingCallStatus.ended));
      },
    );
  }

  /// Close the call screen
  void _closeCallScreen({Call? call, String? callStatus}) {
    if (call != null && callStatus != null && callStatus == 'endCall') {
      call.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccCallEnded(call);
    }

    // Repeat calls are no-ops. The ccCallEnded event above still fires first,
    // so hosts observing it are unaffected.
    if (_callScreenClosed) return;
    _callScreenClosed = true;

    // Dismiss the isolated overlay if showing, otherwise fall back to
    // Navigator.pop for backward compatibility (e.g. standalone usage).
    if (CallScreenOverlay.isShowing) {
      CallScreenOverlay.dismiss();
    } else {
      final navigatorContext =
          CallNavigationContext.navigatorKey.currentContext;
      if (navigatorContext != null && navigatorContext.mounted) {
        final navigator = Navigator.of(navigatorContext);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    }
  }

  /// End the WebRTC session without navigation or state emission.
  Future<void> _endSessionQuietly() async {
    final endSessionUseCase =
        CallOperationsServiceLocator.instance.endSessionUseCase;
    final result = await endSessionUseCase.call();
    result.fold(
      (failure) => developer.log(
        'OngoingCallBloc: endSession quiet error: ${failure.message}',
      ),
      (_) => developer.log('OngoingCallBloc: session ended quietly'),
    );
  }

  /// Handle error - call errorCallback if provided
  void _handleError(dynamic error) {
    if (errorCallback != null) {
      if (error is CometChatException) {
        errorCallback!(error);
      } else if (error is CometChatCallsException) {
        errorCallback!(
          CometChatException(
            error.code,
            error.message ?? 'Call error occurred',
            error.details ?? '',
          ),
        );
      }
    }
  }

  /// Remove V5 listeners from CallSession
  void _removeListeners() {
    final session = CallSession.getInstance();
    session?.removeSessionStatusListener(_sessionListener);
    session?.removeButtonClickListener(_buttonListener);
    session?.removeParticipantEventListener(_participantListener);
  }

  @override
  Future<void> close() {
    // Remove SDK listeners
    _removeListeners();

    // Restore device orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Update CallStateService
    CallStateService.instance.setActiveCallValue(false);

    // Re-initialize the Calls SDK after session ends.
    // Per V5 SDK: internal state can get cleared after a session.
    CallEventService.instance.reinitializeAfterSession();

    developer.log('OngoingCallBloc closed');

    return super.close();
  }
}
