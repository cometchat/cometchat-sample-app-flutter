import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cometchat_chat_uikit/call_ui/src/ongoing_call/bloc/ongoing_call_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/ongoing_call/bloc/ongoing_call_state.dart';

// ===========================================================================
// Tests — OngoingCall BLoC State, Events, and Bug Exploration
// ===========================================================================

void main() {
  // =========================================================================
  // OngoingCallState — State tests
  // =========================================================================

  group('OngoingCallState', () {
    test('initial state has loading status', () {
      const state = OngoingCallState();
      expect(state.status, OngoingCallStatus.loading);
      expect(state.callingWidget, isNull);
      expect(state.usersList, isEmpty);
      expect(state.participantsList, isEmpty);
      expect(state.isCallEndedByMe, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates status', () {
      const state = OngoingCallState();
      final updated = state.copyWith(status: OngoingCallStatus.active);
      expect(updated.status, OngoingCallStatus.active);
    });

    test('copyWith updates callingWidget', () {
      const state = OngoingCallState();
      const widget = SizedBox(width: 100, height: 100);
      final updated = state.copyWith(callingWidget: widget);
      expect(updated.callingWidget, isNotNull);
    });

    test('copyWith updates isCallEndedByMe', () {
      const state = OngoingCallState();
      final updated = state.copyWith(isCallEndedByMe: true);
      expect(updated.isCallEndedByMe, isTrue);
    });

    test('copyWith updates errorMessage', () {
      const state = OngoingCallState();
      final updated = state.copyWith(errorMessage: 'Session failed');
      expect(updated.errorMessage, 'Session failed');
    });

    test('copyWith preserves unchanged fields', () {
      const state = OngoingCallState(
        status: OngoingCallStatus.active,
        isCallEndedByMe: false,
      );
      final updated = state.copyWith(errorMessage: 'Error');
      expect(updated.status, OngoingCallStatus.active);
      expect(updated.isCallEndedByMe, isFalse);
      expect(updated.errorMessage, 'Error');
    });

    test('equatable: same values are equal', () {
      const state1 = OngoingCallState(
        status: OngoingCallStatus.active,
        isCallEndedByMe: false,
      );
      const state2 = OngoingCallState(
        status: OngoingCallStatus.active,
        isCallEndedByMe: false,
      );
      expect(state1, equals(state2));
    });

    test('equatable: different status not equal', () {
      const state1 = OngoingCallState(status: OngoingCallStatus.active);
      const state2 = OngoingCallState(status: OngoingCallStatus.ended);
      expect(state1, isNot(equals(state2)));
    });

    test('equatable: different isCallEndedByMe not equal', () {
      const state1 = OngoingCallState(isCallEndedByMe: false);
      const state2 = OngoingCallState(isCallEndedByMe: true);
      expect(state1, isNot(equals(state2)));
    });
  });

  // =========================================================================
  // OngoingCallStatus enum
  // =========================================================================

  group('OngoingCallStatus enum', () {
    test('has all expected values', () {
      expect(OngoingCallStatus.values, contains(OngoingCallStatus.loading));
      expect(OngoingCallStatus.values, contains(OngoingCallStatus.active));
      expect(OngoingCallStatus.values, contains(OngoingCallStatus.ending));
      expect(OngoingCallStatus.values, contains(OngoingCallStatus.ended));
      expect(OngoingCallStatus.values, contains(OngoingCallStatus.error));
    });

    test('has 5 values total', () {
      expect(OngoingCallStatus.values.length, 5);
    });
  });

  // =========================================================================
  // OngoingCallEvent — Event tests
  // =========================================================================

  group('OngoingCallEvent', () {
    test('LoadCallingScreen event has empty props', () {
      const event = LoadCallingScreen();
      expect(event.props, isEmpty);
    });

    test('EndCallButtonPressed event has empty props', () {
      const event = EndCallButtonPressed();
      expect(event.props, isEmpty);
    });

    test('SessionTimeout event has empty props', () {
      const event = SessionTimeout();
      expect(event.props, isEmpty);
    });

    test('OngoingCallEnded event has empty props', () {
      const event = OngoingCallEnded();
      expect(event.props, isEmpty);
    });

    test('CallingWidgetReceived event contains widget', () {
      const widget = SizedBox();
      const event = CallingWidgetReceived(widget);
      expect(event.widget, widget);
      expect(event.props, contains(widget));
    });

    test('LoadCallingScreen events are equal', () {
      const event1 = LoadCallingScreen();
      const event2 = LoadCallingScreen();
      expect(event1, equals(event2));
    });

    test('EndCallButtonPressed events are equal', () {
      const event1 = EndCallButtonPressed();
      const event2 = EndCallButtonPressed();
      expect(event1, equals(event2));
    });
  });

  // =========================================================================
  // Blank Page Bug Exploration — null builder handling
  // =========================================================================

  group('Blank page bug exploration', () {
    test('state with null callingWidget represents blank page condition', () {
      const state = OngoingCallState(
        status: OngoingCallStatus.active,
        callingWidget: null,
      );
      // When status is active but callingWidget is null, this is the blank page bug
      expect(state.status, OngoingCallStatus.active);
      expect(state.callingWidget, isNull);
    });

    test('state with callingWidget represents normal active call', () {
      const widget = SizedBox(width: 300, height: 400);
      const state = OngoingCallState(
        status: OngoingCallStatus.active,
        callingWidget: widget,
      );
      expect(state.status, OngoingCallStatus.active);
      expect(state.callingWidget, isNotNull);
    });

    test('loading state should not have callingWidget', () {
      const state = OngoingCallState(status: OngoingCallStatus.loading);
      expect(state.callingWidget, isNull);
    });

    test('error state preserves callingWidget as null', () {
      const state = OngoingCallState(
        status: OngoingCallStatus.error,
        errorMessage: 'Token generation failed',
      );
      expect(state.callingWidget, isNull);
      expect(state.errorMessage, 'Token generation failed');
    });

    test('ended state preserves isCallEndedByMe flag', () {
      const state = OngoingCallState(
        status: OngoingCallStatus.ended,
        isCallEndedByMe: true,
      );
      expect(state.isCallEndedByMe, isTrue);
    });

    test('ending state transition from active', () {
      const active = OngoingCallState(status: OngoingCallStatus.active);
      final ending = active.copyWith(status: OngoingCallStatus.ending);
      expect(ending.status, OngoingCallStatus.ending);
    });
  });

  // =========================================================================
  // Call preservation — custom builder usage
  // =========================================================================

  group('Call preservation properties', () {
    test('callingWidget can be set via copyWith', () {
      const state = OngoingCallState(status: OngoingCallStatus.loading);
      const widget = SizedBox(key: Key('calling_widget'));
      final updated = state.copyWith(
        status: OngoingCallStatus.active,
        callingWidget: widget,
      );
      expect(updated.callingWidget, isNotNull);
      expect(updated.status, OngoingCallStatus.active);
    });

    test('usersList can be updated', () {
      const state = OngoingCallState(status: OngoingCallStatus.active);
      // usersList is typed as List<RTCUser> but we test the copyWith mechanism
      final updated = state.copyWith(usersList: []);
      expect(updated.usersList, isEmpty);
    });

    test('participantsList can be updated', () {
      const state = OngoingCallState(status: OngoingCallStatus.active);
      final updated = state.copyWith(participantsList: []);
      expect(updated.participantsList, isEmpty);
    });

    test('state transitions: loading → active → ending → ended', () {
      const loading = OngoingCallState(status: OngoingCallStatus.loading);
      expect(loading.status, OngoingCallStatus.loading);

      final active = loading.copyWith(status: OngoingCallStatus.active);
      expect(active.status, OngoingCallStatus.active);

      final ending = active.copyWith(status: OngoingCallStatus.ending);
      expect(ending.status, OngoingCallStatus.ending);

      final ended = ending.copyWith(
        status: OngoingCallStatus.ended,
        isCallEndedByMe: true,
      );
      expect(ended.status, OngoingCallStatus.ended);
      expect(ended.isCallEndedByMe, isTrue);
    });

    test('state transitions: loading → error', () {
      const loading = OngoingCallState(status: OngoingCallStatus.loading);
      final error = loading.copyWith(
        status: OngoingCallStatus.error,
        errorMessage: 'Failed to start session',
      );
      expect(error.status, OngoingCallStatus.error);
      expect(error.errorMessage, 'Failed to start session');
    });

    test('errorMessage is cleared when status changes to active', () {
      const error = OngoingCallState(
        status: OngoingCallStatus.error,
        errorMessage: 'Previous error',
      );
      // copyWith with null errorMessage clears it
      final active = error.copyWith(
        status: OngoingCallStatus.active,
        errorMessage: null,
      );
      expect(active.status, OngoingCallStatus.active);
      expect(active.errorMessage, isNull);
    });

    test('callingWidget persists across status changes', () {
      const widget = SizedBox(key: Key('persist'));
      const active = OngoingCallState(
        status: OngoingCallStatus.active,
        callingWidget: widget,
      );
      final ending = active.copyWith(status: OngoingCallStatus.ending);
      // callingWidget should persist since we didn't clear it
      expect(ending.callingWidget, widget);
    });
  });
}
