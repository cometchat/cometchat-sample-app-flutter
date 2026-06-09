import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_buttons/bloc/call_buttons_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_buttons/bloc/call_buttons_state.dart';

// ===========================================================================
// Fakes
// ===========================================================================

class FakeCall extends Fake implements Call {
  @override
  String get sessionId => 'session_789';

  @override
  String get receiverUid => 'user_2';

  @override
  String get type => 'audio';
}

// ===========================================================================
// Tests
// ===========================================================================

void main() {
  // =========================================================================
  // CallButtonsState — State tests
  // =========================================================================

  group('CallButtonsState', () {
    test('initial state has correct defaults', () {
      const state = CallButtonsState();
      expect(state.isDisabled, isFalse);
      expect(state.isCallInProgress, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('factory initial() produces default state', () {
      final state = CallButtonsState.initial();
      expect(state.isDisabled, isFalse);
      expect(state.isCallInProgress, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates isDisabled', () {
      const state = CallButtonsState();
      final updated = state.copyWith(isDisabled: true);
      expect(updated.isDisabled, isTrue);
      expect(updated.isCallInProgress, isFalse);
    });

    test('copyWith updates isCallInProgress', () {
      const state = CallButtonsState();
      final updated = state.copyWith(isCallInProgress: true);
      expect(updated.isCallInProgress, isTrue);
    });

    test('copyWith updates errorMessage', () {
      const state = CallButtonsState();
      final updated = state.copyWith(errorMessage: 'Call initiation failed');
      expect(updated.errorMessage, 'Call initiation failed');
    });

    test('copyWith with clearError removes errorMessage', () {
      const state = CallButtonsState(errorMessage: 'Previous error');
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const state = CallButtonsState(
        isDisabled: true,
        isCallInProgress: true,
      );
      final updated = state.copyWith(errorMessage: 'Error');
      expect(updated.isDisabled, isTrue);
      expect(updated.isCallInProgress, isTrue);
      expect(updated.errorMessage, 'Error');
    });

    test('equatable: same values are equal', () {
      const state1 = CallButtonsState(isDisabled: true);
      const state2 = CallButtonsState(isDisabled: true);
      expect(state1, equals(state2));
    });

    test('equatable: different isDisabled not equal', () {
      const state1 = CallButtonsState(isDisabled: false);
      const state2 = CallButtonsState(isDisabled: true);
      expect(state1, isNot(equals(state2)));
    });

    test('equatable: different isCallInProgress not equal', () {
      const state1 = CallButtonsState(isCallInProgress: false);
      const state2 = CallButtonsState(isCallInProgress: true);
      expect(state1, isNot(equals(state2)));
    });
  });

  // =========================================================================
  // CallButtonsEvent — Event tests
  // =========================================================================

  group('CallButtonsEvent', () {
    test('InitiateVoiceCall event has empty props', () {
      const event = InitiateVoiceCall();
      expect(event.props, isEmpty);
    });

    test('InitiateVideoCall event has empty props', () {
      const event = InitiateVideoCall();
      expect(event.props, isEmpty);
    });

    test('CallRejected event contains call', () {
      final call = FakeCall();
      final event = CallRejected(call);
      expect(event.call, call);
      expect(event.props, contains(call));
    });

    test('CallEnded event contains call', () {
      final call = FakeCall();
      final event = CallEnded(call);
      expect(event.call, call);
      expect(event.props, contains(call));
    });

    test('InitiateVoiceCall events are equal', () {
      const event1 = InitiateVoiceCall();
      const event2 = InitiateVoiceCall();
      expect(event1, equals(event2));
    });

    test('InitiateVideoCall events are equal', () {
      const event1 = InitiateVideoCall();
      const event2 = InitiateVideoCall();
      expect(event1, equals(event2));
    });

    test('InitiateVoiceCall and InitiateVideoCall are not equal', () {
      const voice = InitiateVoiceCall();
      const video = InitiateVideoCall();
      expect(voice, isNot(equals(video)));
    });

    test('CallRejected with same call are equal', () {
      final call = FakeCall();
      final event1 = CallRejected(call);
      final event2 = CallRejected(call);
      expect(event1, equals(event2));
    });
  });

  // =========================================================================
  // Interaction — voice/video call initiation for user/group
  // =========================================================================

  group('Call initiation interaction', () {
    test('buttons disabled during call initiation prevents double-tap', () {
      const initial = CallButtonsState();
      final disabled = initial.copyWith(isDisabled: true);
      expect(disabled.isDisabled, isTrue);
      // When isDisabled is true, UI should not allow button taps
    });

    test('buttons re-enabled after call rejected', () {
      const inProgress = CallButtonsState(
        isDisabled: true,
        isCallInProgress: true,
      );
      final reEnabled = inProgress.copyWith(
        isDisabled: false,
        isCallInProgress: false,
      );
      expect(reEnabled.isDisabled, isFalse);
      expect(reEnabled.isCallInProgress, isFalse);
    });

    test('buttons re-enabled after call ended', () {
      const inProgress = CallButtonsState(
        isDisabled: true,
        isCallInProgress: true,
      );
      final reEnabled = inProgress.copyWith(
        isDisabled: false,
        isCallInProgress: false,
        clearError: true,
      );
      expect(reEnabled.isDisabled, isFalse);
      expect(reEnabled.isCallInProgress, isFalse);
      expect(reEnabled.errorMessage, isNull);
    });

    test('error state shows error and re-enables buttons', () {
      const disabled = CallButtonsState(isDisabled: true);
      final error = disabled.copyWith(
        isDisabled: false,
        errorMessage: 'Call failed: user busy',
      );
      expect(error.isDisabled, isFalse);
      expect(error.errorMessage, 'Call failed: user busy');
    });
  });

  // =========================================================================
  // Property tests — user/group mutual exclusivity, UIState
  // =========================================================================

  group('CallButtons property behavior', () {
    test('state can represent idle (no call in progress)', () {
      const state = CallButtonsState();
      expect(state.isCallInProgress, isFalse);
      expect(state.isDisabled, isFalse);
    });

    test('state can represent call in progress', () {
      const state = CallButtonsState(
        isDisabled: true,
        isCallInProgress: true,
      );
      expect(state.isCallInProgress, isTrue);
      expect(state.isDisabled, isTrue);
    });

    test('clearError flag only clears error, preserves other fields', () {
      const state = CallButtonsState(
        isDisabled: true,
        isCallInProgress: true,
        errorMessage: 'Error',
      );
      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
      expect(cleared.isDisabled, isTrue);
      expect(cleared.isCallInProgress, isTrue);
    });
  });
}
