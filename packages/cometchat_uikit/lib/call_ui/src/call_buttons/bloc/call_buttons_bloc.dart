import 'dart:async';

import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cometchat_calls_uikit.dart';
import '../../../../cometchat_chat_uikit.dart';
import '../../../../shared_ui/src/clean_architecture/core/constants/enums.dart'
    as core_enums;
import '../../call_settings/call_navigation_context.dart';
import '../../outgoing_call/cometchat_outgoing_call.dart';
import 'call_buttons_event.dart';
import 'call_buttons_state.dart';

/// BLoC for managing call buttons state and call initiation workflow
///
/// This BLoC handles:
/// - Voice and video call initiation for users (direct call) and groups (meeting)
/// - SDK listener callbacks for call events (rejected, ended)
/// - Button disabled state management during call workflow
///
/// Uses [CometChatCallEventListener] mixin for UI Kit events (ccCallRejected, ccCallEnded)
/// Uses [CallListener] mixin for SDK events (onOutgoingCallRejected, onCallEndedMessageReceived)
///
/// Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7
class CallButtonsBloc extends Bloc<CallButtonsEvent, CallButtonsState>
    with CometChatCallEventListener, CallListener {
  /// User receiver for direct calls
  final User? user;

  /// Group receiver for meeting calls
  final Group? group;

  /// Configuration for outgoing call screen
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  /// Custom call settings builder
  final SessionSettingsBuilder Function(
      User? user, Group? group, bool? isAudioOnly)? callSettingsBuilder;

  /// Error callback
  final OnError? errorCallback;

  /// Unique listener ID for SDK listeners
  late final String _listenerId;

  /// Receiver type (user or group)
  late final String _receiverType;

  /// Receiver ID (uid or guid)
  late final String _receiverId;

  /// Logged in user
  User? _loggedInUser;

  /// Creates a CallButtonsBloc
  ///
  /// Either [user] or [group] must be provided to determine the receiver.
  /// - For [user] receivers: initiates direct calls
  /// - For [group] receivers: initiates meetings
  CallButtonsBloc({
    this.user,
    this.group,
    this.outgoingCallConfiguration,
    this.callSettingsBuilder,
    this.errorCallback,
  }) : super(CallButtonsState.initial()) {
    // Initialize receiver info
    _initializeReceiver();

    // Generate unique listener ID
    _listenerId =
        'callButtons_${DateTime.now().microsecondsSinceEpoch.toString()}';

    // Register event handlers
    on<InitiateVoiceCall>(_onInitiateVoiceCall);
    on<InitiateVideoCall>(_onInitiateVideoCall);
    on<CallRejected>(_onCallRejected);
    on<CallEnded>(_onCallEnded);

    // Add SDK listeners
    _addListeners();

    // Initialize logged in user
    _initializeLoggedInUser();
  }

  /// Initialize receiver type and ID from user or group
  void _initializeReceiver() {
    if (user != null) {
      _receiverType = ReceiverTypeConstants.user;
      _receiverId = user!.uid;
    } else if (group != null) {
      _receiverType = ReceiverTypeConstants.group;
      _receiverId = group!.guid;
    } else {
      _receiverType = '';
      _receiverId = '';
    }
  }

  /// Initialize logged in user
  Future<void> _initializeLoggedInUser() async {
    final result = await CallOperationsServiceLocator.instance.getLoggedInUserUseCase.call();
    result.onSuccess((user) => _loggedInUser = user);
  }

  /// Add SDK and event listeners
  void _addListeners() {
    CometChat.addCallListener(_listenerId, this);
    CometChatCallEvents.addCallEventsListener(_listenerId, this);
  }

  /// Remove SDK and event listeners
  void _removeListeners() {
    CometChat.removeCallListener(_listenerId);
    CometChatCallEvents.removeCallEventsListener(_listenerId);
  }

  // ============================================================
  // SDK LISTENER CALLBACKS - CometChatCallEventListener
  // ============================================================

  /// Called when a call is rejected by the logged-in user
  @override
  void ccCallRejected(Call call) {
    add(CallRejected(call));
  }

  /// Called when a call is ended by the logged-in user
  @override
  void ccCallEnded(Call call) {
    add(CallEnded(call));
  }

  // ============================================================
  // SDK LISTENER CALLBACKS - CallListener
  // ============================================================

  /// Called when an outgoing call is rejected by the receiver
  @override
  void onOutgoingCallRejected(Call call) {
    add(CallRejected(call));
  }

  /// Called when a call ended message is received
  @override
  void onCallEndedMessageReceived(Call call) {
    add(CallEnded(call));
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Handle voice call initiation
  Future<void> _onInitiateVoiceCall(
    InitiateVoiceCall event,
    Emitter<CallButtonsState> emit,
  ) async {
    await _initiateCall(CallTypeConstants.audioCall, emit);
  }

  /// Handle video call initiation
  Future<void> _onInitiateVideoCall(
    InitiateVideoCall event,
    Emitter<CallButtonsState> emit,
  ) async {
    await _initiateCall(CallTypeConstants.videoCall, emit);
  }

  /// Handle call rejected event - re-enable buttons
  Future<void> _onCallRejected(
    CallRejected event,
    Emitter<CallButtonsState> emit,
  ) async {
    emit(state.copyWith(
      isDisabled: false,
      isCallInProgress: false,
      clearError: true,
    ));
  }

  /// Handle call ended event - re-enable buttons
  Future<void> _onCallEnded(
    CallEnded event,
    Emitter<CallButtonsState> emit,
  ) async {
    emit(state.copyWith(
      isDisabled: false,
      isCallInProgress: false,
      clearError: true,
    ));
  }

  // ============================================================
  // CALL INITIATION LOGIC
  // ============================================================

  /// Initiate a call based on receiver type
  Future<void> _initiateCall(
    String callType,
    Emitter<CallButtonsState> emit,
  ) async {
    // Disable buttons during call initiation
    emit(state.copyWith(isDisabled: true, clearError: true));

    if (_receiverType == ReceiverTypeConstants.group) {
      await _initiateMeetWorkflow(callType, emit);
    } else {
      await _initiateCallWorkflow(callType, emit);
    }
  }

  /// Initiate a meeting workflow for group receivers
  Future<void> _initiateMeetWorkflow(
    String callType,
    Emitter<CallButtonsState> emit,
  ) async {
    final bool isAudioOnly = callType == CallTypeConstants.audioCall;

    // Same Android 14+ FGS permission gate as direct calls.
    final permissionGranted = await CallPermissions.requestForCallType(
      isVideoCall: !isAudioOnly,
    );
    if (isClosed) return;
    if (!permissionGranted) {
      emit(state.copyWith(
        isDisabled: false,
        isCallInProgress: false,
        errorMessage:
            'Microphone${isAudioOnly ? '' : ' and camera'} permission is required to start the meeting.',
      ));
      return;
    }

    // Build call settings
    final SessionSettingsBuilder defaultSessionSettingsBuilder;
    if (callSettingsBuilder != null) {
      defaultSessionSettingsBuilder = callSettingsBuilder!(user, group, isAudioOnly);
    } else if (outgoingCallConfiguration?.sessionSettingsBuilder != null) {
      defaultSessionSettingsBuilder =
          outgoingCallConfiguration!.sessionSettingsBuilder!;
    } else {
      defaultSessionSettingsBuilder = SessionSettingsBuilder()
        .setLayout(LayoutType.tile)
        .startVideoPaused(false)
        .startAudioMuted(false);
      if (isAudioOnly) {
        // Workaround: SessionType.audio is not recognized by the native
        // Android SDK (beta bug). Use startVideoPaused + hide video buttons.
        defaultSessionSettingsBuilder
          .startVideoPaused(true)
          .hideSwitchCameraButton(true)
          .hideToggleVideoButton(true);
      }
    }

    // Navigate to ongoing call screen via isolated overlay
    CallScreenOverlay.show(
      sessionId: _receiverId,
      sessionSettingsBuilder: defaultSessionSettingsBuilder,
      callWorkFlow: CallWorkFlow.directCalling,
      onError: errorCallback,
    );

    if (kDebugMode) {
      debugPrint('Navigated to CometChatOngoingCall screen for meeting');
    }

    // Create and send custom message for meeting
    await _sendMeetingMessage(callType, emit);
  }

  /// Send meeting custom message
  Future<void> _sendMeetingMessage(
    String callType,
    Emitter<CallButtonsState> emit,
  ) async {
    final Map<String, dynamic> customData = <String, dynamic>{
      'callType': callType,
      'sessionID': _receiverId,
    };

    final CustomMessage customMessage = CustomMessage(
      receiverUid: _receiverId,
      receiverType: ReceiverTypeConstants.group,
      type: MessageTypeConstants.meeting,
      customData: customData,
    );

    customMessage.receiver = group;
    customMessage.sentAt = DateTime.now();
    customMessage.muid = DateTime.now().microsecondsSinceEpoch.toString();
    customMessage.category = MessageCategoryConstants.custom;
    customMessage.sender = _loggedInUser;
    customMessage.updateConversation = true;

    // Set metadata for unread count
    Map<String, dynamic> metadata = customMessage.metadata ?? {};
    metadata[UpdateSettingsConstant.incrementUnreadCount] = true;
    customMessage.metadata = metadata;

    // Send meeting message via use case
    final sendMeetingUseCase = CallOperationsServiceLocator.instance.sendMeetingMessageUseCase;
    final result = await sendMeetingUseCase.call(customMessage);

    if (isClosed) return;
    result.fold(
      (failure) {
        if (customMessage.metadata != null) {
          customMessage.metadata!['error'] = failure.message;
        } else {
          customMessage.metadata = {'error': failure.message};
        }
        CometChatMessageEvents.ccMessageSent(
          customMessage,
          core_enums.MessageStatus.error,
        );
        emit(state.copyWith(
          isDisabled: false,
          isCallInProgress: false,
          errorMessage: failure.message,
        ));
      },
      (directCallMessage) {
        CometChatMessageEvents.ccMessageSent(
          directCallMessage,
          core_enums.MessageStatus.sent,
        );
        emit(state.copyWith(
          isDisabled: false,
          isCallInProgress: true,
        ));
      },
    );
  }

  /// Initiate a direct call workflow for user receivers
  Future<void> _initiateCallWorkflow(
    String callType,
    Emitter<CallButtonsState> emit,
  ) async {
    final bool isAudioOnly = callType == CallTypeConstants.audioCall;

    // Android 14+ requires RECORD_AUDIO (and CAMERA for video) granted at
    // runtime BEFORE the Calls SDK registers the session and starts its
    // foreground service. Request here so the dialog shows before we hit
    // the network; this is the earliest point we know the call type.
    final permissionGranted = await CallPermissions.requestForCallType(
      isVideoCall: !isAudioOnly,
    );
    if (isClosed) return;
    if (!permissionGranted) {
      emit(state.copyWith(
        isDisabled: false,
        isCallInProgress: false,
        errorMessage:
            'Microphone${isAudioOnly ? '' : ' and camera'} permission is required to start the call.',
      ));
      return;
    }

    // Build call settings
    final SessionSettingsBuilder defaultSessionSettingsBuilder;
    if (callSettingsBuilder != null) {
      defaultSessionSettingsBuilder = callSettingsBuilder!(user, group, isAudioOnly);
    } else if (outgoingCallConfiguration?.sessionSettingsBuilder != null) {
      defaultSessionSettingsBuilder =
          outgoingCallConfiguration!.sessionSettingsBuilder!;
    } else {
      defaultSessionSettingsBuilder = SessionSettingsBuilder()
        .setLayout(LayoutType.tile)
        .startAudioMuted(false);
      if (isAudioOnly) {
        // Workaround: SessionType.audio is not recognized by the native
        // Android SDK (beta bug). Use startVideoPaused + hide video buttons.
        defaultSessionSettingsBuilder
          .startVideoPaused(true)
          .hideSwitchCameraButton(true)
          .hideToggleVideoButton(true);
      }
    }

    // Create call object
    final Call call = Call(
      receiverUid: _receiverId,
      receiverType: ReceiverTypeConstants.user,
      type: callType,
    );

    // Initiate call via use case
    final initiateCallUseCase = CallOperationsServiceLocator.instance.initiateCallUseCase;
    final result = await initiateCallUseCase.call(call);

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(
          isDisabled: false,
          isCallInProgress: false,
          errorMessage: failure.message,
        ));

        if (errorCallback != null) {
          errorCallback!(CometChatException('ERR', failure.message, ''));
        }

        if (kDebugMode) {
          debugPrint('Error initiating call: ${failure.message}');
        }
      },
      (returnedCall) {
        emit(state.copyWith(
          isDisabled: false,
          isCallInProgress: true,
        ));

        returnedCall.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccOutgoingCall(returnedCall);

        // Unfocus any active input
        FocusManager.instance.primaryFocus?.unfocus();

        // Navigate to outgoing call screen
        _navigateToOutgoingCall(returnedCall, defaultSessionSettingsBuilder);
      },
    );
  }

  /// Navigate to outgoing call screen
  void _navigateToOutgoingCall(
    Call call,
    SessionSettingsBuilder sessionSettingsBuilder,
  ) {
    final navigatorContext = CallNavigationContext.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) {
      if (kDebugMode) {
        debugPrint('Context is not mounted for navigation');
      }
      return;
    }

    // Delay navigation slightly to allow UI to settle
    Future.delayed(const Duration(milliseconds: 300), () {
      final currentContext = CallNavigationContext.navigatorKey.currentContext;
      if (currentContext == null || !currentContext.mounted) {
        if (kDebugMode) {
          debugPrint('Context is not mounted during delayed navigation');
        }
        return;
      }

      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => CometChatOutgoingCall(
            call: call,
            user: user,
            subtitleView: outgoingCallConfiguration?.subtitleView,
            declineButtonIcon: outgoingCallConfiguration?.declineButtonIcon,
            onCancelled: outgoingCallConfiguration?.onCancelled,
            disableSoundForCalls: outgoingCallConfiguration?.disableSoundForCalls,
            customSoundForCalls: outgoingCallConfiguration?.customSoundForCalls,
            customSoundForCallsPackage:
                outgoingCallConfiguration?.customSoundForCallsPackage,
            onError: outgoingCallConfiguration?.onError,
            outgoingCallStyle: outgoingCallConfiguration?.outgoingCallStyle,
            sessionSettingsBuilder: sessionSettingsBuilder,
            height: outgoingCallConfiguration?.height,
            width: outgoingCallConfiguration?.width,
            avatarView: outgoingCallConfiguration?.avatarView,
            titleView: outgoingCallConfiguration?.titleView,
            cancelledView: outgoingCallConfiguration?.cancelledView,
          ),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    // Remove all SDK and event listeners
    _removeListeners();
    return super.close();
  }
}
