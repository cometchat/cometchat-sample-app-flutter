import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/outgoing_call/bloc/outgoing_call_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/outgoing_call/bloc/outgoing_call_state.dart';
import 'package:cometchat_chat_uikit/call_ui/src/outgoing_call/cometchat_outgoing_call_style.dart';
import 'package:cometchat_chat_uikit/call_ui/src/outgoing_call/cometchat_outgoing_call_configuration.dart';

// ===========================================================================
// Fakes
// ===========================================================================

class FakeCall extends Fake implements Call {
  @override
  String get sessionId => 'session_456';

  @override
  String get receiverUid => 'user_2';

  @override
  String get type => 'video';
}

// ===========================================================================
// Tests
// ===========================================================================

void main() {
  // =========================================================================
  // OutgoingCallState — State tests
  // =========================================================================

  group('OutgoingCallState', () {
    test('initial state has idle status', () {
      const state = OutgoingCallState();
      expect(state.status, OutgoingCallStatus.idle);
      expect(state.isCallRejected, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates status', () {
      const state = OutgoingCallState();
      final updated = state.copyWith(status: OutgoingCallStatus.cancelling);
      expect(updated.status, OutgoingCallStatus.cancelling);
      expect(updated.isCallRejected, isFalse);
    });

    test('copyWith updates isCallRejected', () {
      const state = OutgoingCallState();
      final updated = state.copyWith(isCallRejected: true);
      expect(updated.isCallRejected, isTrue);
      expect(updated.status, OutgoingCallStatus.idle);
    });

    test('copyWith updates errorMessage', () {
      const state = OutgoingCallState();
      final updated = state.copyWith(errorMessage: 'Timeout');
      expect(updated.errorMessage, 'Timeout');
    });

    test('copyWith preserves unchanged fields', () {
      const state = OutgoingCallState(
        status: OutgoingCallStatus.cancelling,
        isCallRejected: true,
      );
      final updated = state.copyWith(errorMessage: 'Error');
      expect(updated.status, OutgoingCallStatus.cancelling);
      expect(updated.isCallRejected, isTrue);
      expect(updated.errorMessage, 'Error');
    });

    test('equatable: same values are equal', () {
      const state1 = OutgoingCallState(
        status: OutgoingCallStatus.idle,
        isCallRejected: false,
      );
      const state2 = OutgoingCallState(
        status: OutgoingCallStatus.idle,
        isCallRejected: false,
      );
      expect(state1, equals(state2));
    });

    test('equatable: different status not equal', () {
      const state1 = OutgoingCallState(status: OutgoingCallStatus.idle);
      const state2 = OutgoingCallState(status: OutgoingCallStatus.accepted);
      expect(state1, isNot(equals(state2)));
    });

    test('equatable: different isCallRejected not equal', () {
      const state1 = OutgoingCallState(isCallRejected: false);
      const state2 = OutgoingCallState(isCallRejected: true);
      expect(state1, isNot(equals(state2)));
    });

    test('equatable: different errorMessage not equal', () {
      const state1 = OutgoingCallState(errorMessage: 'A');
      const state2 = OutgoingCallState(errorMessage: 'B');
      expect(state1, isNot(equals(state2)));
    });
  });

  // =========================================================================
  // OutgoingCallStatus enum
  // =========================================================================

  group('OutgoingCallStatus enum', () {
    test('has all expected values', () {
      expect(OutgoingCallStatus.values, contains(OutgoingCallStatus.idle));
      expect(
        OutgoingCallStatus.values,
        contains(OutgoingCallStatus.cancelling),
      );
      expect(OutgoingCallStatus.values, contains(OutgoingCallStatus.accepted));
      expect(OutgoingCallStatus.values, contains(OutgoingCallStatus.rejected));
      expect(OutgoingCallStatus.values, contains(OutgoingCallStatus.error));
    });

    test('has 5 values total', () {
      expect(OutgoingCallStatus.values.length, 5);
    });
  });

  // =========================================================================
  // OutgoingCallEvent — Event tests
  // =========================================================================

  group('OutgoingCallEvent', () {
    test('CancelCall event has empty props', () {
      const event = CancelCall();
      expect(event.props, isEmpty);
    });

    test('OutgoingCallAccepted event contains call', () {
      final call = FakeCall();
      final event = OutgoingCallAccepted(call);
      expect(event.call, call);
      expect(event.props, contains(call));
    });

    test('OutgoingCallRejected event contains call', () {
      final call = FakeCall();
      final event = OutgoingCallRejected(call);
      expect(event.call, call);
      expect(event.props, contains(call));
    });

    test('CancelCall events are equal', () {
      const event1 = CancelCall();
      const event2 = CancelCall();
      expect(event1, equals(event2));
    });

    test('OutgoingCallAccepted with same call are equal', () {
      final call = FakeCall();
      final event1 = OutgoingCallAccepted(call);
      final event2 = OutgoingCallAccepted(call);
      expect(event1, equals(event2));
    });

    test('CancelCall and OutgoingCallAccepted are not equal', () {
      const cancel = CancelCall();
      final accepted = OutgoingCallAccepted(FakeCall());
      expect(cancel, isNot(equals(accepted)));
    });
  });

  // =========================================================================
  // CometChatOutgoingCallStyle — Style tests
  // =========================================================================

  group('CometChatOutgoingCallStyle defaults', () {
    test('all properties are null by default', () {
      final style = CometChatOutgoingCallStyle();
      expect(style.backgroundColor, isNull);
      expect(style.avatarStyle, isNull);
      expect(style.declineButtonColor, isNull);
      expect(style.declineButtonBorderRadius, isNull);
      expect(style.iconColor, isNull);
      expect(style.subtitleColor, isNull);
      expect(style.subtitleTextStyle, isNull);
      expect(style.titleColor, isNull);
      expect(style.titleTextStyle, isNull);
      expect(style.borderRadius, isNull);
      expect(style.border, isNull);
    });
  });

  group('CometChatOutgoingCallStyle copyWith', () {
    test('copyWith updates backgroundColor', () {
      final style = CometChatOutgoingCallStyle();
      final updated = style.copyWith(backgroundColor: Colors.black);
      expect(updated.backgroundColor, Colors.black);
    });

    test('copyWith updates declineButtonColor', () {
      final style = CometChatOutgoingCallStyle();
      final updated = style.copyWith(declineButtonColor: Colors.red);
      expect(updated.declineButtonColor, Colors.red);
    });

    test('copyWith updates iconColor', () {
      final style = CometChatOutgoingCallStyle();
      final updated = style.copyWith(iconColor: Colors.white);
      expect(updated.iconColor, Colors.white);
    });

    test('copyWith updates text styles and colors', () {
      final style = CometChatOutgoingCallStyle();
      final updated = style.copyWith(
        titleTextStyle: const TextStyle(fontSize: 20),
        titleColor: Colors.white,
        subtitleTextStyle: const TextStyle(fontSize: 14),
        subtitleColor: Colors.grey,
      );
      expect(updated.titleTextStyle?.fontSize, 20);
      expect(updated.titleColor, Colors.white);
      expect(updated.subtitleTextStyle?.fontSize, 14);
      expect(updated.subtitleColor, Colors.grey);
    });

    test('copyWith updates border properties', () {
      final style = CometChatOutgoingCallStyle();
      final border = Border.all(color: Colors.white);
      final borderRadius = BorderRadius.circular(16);
      final updated = style.copyWith(
        border: border,
        borderRadius: borderRadius,
      );
      expect(updated.border, border);
      expect(updated.borderRadius, borderRadius);
    });

    test('copyWith updates declineButtonBorderRadius', () {
      final style = CometChatOutgoingCallStyle();
      final radius = BorderRadius.circular(24);
      final updated = style.copyWith(declineButtonBorderRadius: radius);
      expect(updated.declineButtonBorderRadius, radius);
    });

    test('copyWith preserves existing values', () {
      final style = CometChatOutgoingCallStyle(
        backgroundColor: Colors.black,
        titleColor: Colors.white,
      );
      final updated = style.copyWith(iconColor: Colors.red);
      expect(updated.backgroundColor, Colors.black);
      expect(updated.titleColor, Colors.white);
      expect(updated.iconColor, Colors.red);
    });
  });

  group('CometChatOutgoingCallStyle merge', () {
    test('merge with null returns same style', () {
      final style = CometChatOutgoingCallStyle(backgroundColor: Colors.black);
      final merged = style.merge(null);
      expect(merged.backgroundColor, Colors.black);
    });

    test('merge applies other style properties', () {
      final base = CometChatOutgoingCallStyle(
        backgroundColor: Colors.black,
        titleColor: Colors.white,
      );
      final other = CometChatOutgoingCallStyle(
        backgroundColor: Colors.blue,
        declineButtonColor: Colors.red,
      );
      final merged = base.merge(other);
      expect(merged.backgroundColor, Colors.blue);
      expect(merged.declineButtonColor, Colors.red);
      expect(merged.titleColor, Colors.white);
    });

    test('merge overrides all non-null properties', () {
      final base = CometChatOutgoingCallStyle();
      final other = CometChatOutgoingCallStyle(
        iconColor: Colors.white,
        declineButtonColor: Colors.red,
        titleColor: Colors.yellow,
      );
      final merged = base.merge(other);
      expect(merged.iconColor, Colors.white);
      expect(merged.declineButtonColor, Colors.red);
      expect(merged.titleColor, Colors.yellow);
    });
  });

  group('CometChatOutgoingCallStyle lerp', () {
    test('lerp at t=0 returns start style', () {
      final start = CometChatOutgoingCallStyle(backgroundColor: Colors.white);
      final end = CometChatOutgoingCallStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 0.0);
      expect(result.backgroundColor, Colors.white);
    });

    test('lerp at t=1 returns end style', () {
      final start = CometChatOutgoingCallStyle(backgroundColor: Colors.white);
      final end = CometChatOutgoingCallStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 1.0);
      expect(result.backgroundColor, Colors.black);
    });

    test('lerp with non-matching type returns this', () {
      final style = CometChatOutgoingCallStyle(backgroundColor: Colors.blue);
      final result = style.lerp(null, 0.5);
      expect(result.backgroundColor, Colors.blue);
    });

    test('lerp interpolates colors at midpoint', () {
      final start = CometChatOutgoingCallStyle(
        declineButtonColor: Colors.red,
        iconColor: Colors.white,
      );
      final end = CometChatOutgoingCallStyle(
        declineButtonColor: Colors.blue,
        iconColor: Colors.black,
      );
      final result = start.lerp(end, 0.5);
      expect(result.declineButtonColor, isNotNull);
      expect(result.iconColor, isNotNull);
    });
  });

  // =========================================================================
  // CometChatOutgoingCallConfiguration — Property tests
  // =========================================================================

  group('CometChatOutgoingCallConfiguration', () {
    test('all properties are null by default', () {
      final config = CometChatOutgoingCallConfiguration();
      expect(config.subtitleView, isNull);
      expect(config.onCancelled, isNull);
      expect(config.disableSoundForCalls, isNull);
      expect(config.customSoundForCalls, isNull);
      expect(config.customSoundForCallsPackage, isNull);
      expect(config.onError, isNull);
      expect(config.outgoingCallStyle, isNull);
      expect(config.sessionSettingsBuilder, isNull);
      expect(config.width, isNull);
      expect(config.height, isNull);
      expect(config.declineButtonIcon, isNull);
      expect(config.avatarView, isNull);
      expect(config.titleView, isNull);
      expect(config.cancelledView, isNull);
    });

    test('configuration accepts custom dimensions', () {
      final config = CometChatOutgoingCallConfiguration(
        height: 300,
        width: 400,
      );
      expect(config.height, 300);
      expect(config.width, 400);
    });

    test('configuration accepts disableSoundForCalls', () {
      final config = CometChatOutgoingCallConfiguration(
        disableSoundForCalls: true,
      );
      expect(config.disableSoundForCalls, isTrue);
    });

    test('configuration accepts custom sound', () {
      final config = CometChatOutgoingCallConfiguration(
        customSoundForCalls: 'outgoing_ring.mp3',
        customSoundForCallsPackage: 'assets',
      );
      expect(config.customSoundForCalls, 'outgoing_ring.mp3');
      expect(config.customSoundForCallsPackage, 'assets');
    });

    test('configuration accepts onCancelled callback', () {
      final config = CometChatOutgoingCallConfiguration(
        onCancelled: (context, call) {},
      );
      expect(config.onCancelled, isNotNull);
    });

    test('configuration accepts custom style', () {
      final style = CometChatOutgoingCallStyle(backgroundColor: Colors.black);
      final config = CometChatOutgoingCallConfiguration(
        outgoingCallStyle: style,
      );
      expect(config.outgoingCallStyle?.backgroundColor, Colors.black);
    });

    test('configuration accepts declineButtonIcon widget', () {
      const icon = Icon(Icons.call_end, color: Colors.red);
      final config = CometChatOutgoingCallConfiguration(
        declineButtonIcon: icon,
      );
      expect(config.declineButtonIcon, isNotNull);
    });
  });

  // =========================================================================
  // ThemeExtension compliance
  // =========================================================================

  group('ThemeExtension compliance', () {
    test('CometChatOutgoingCallStyle extends ThemeExtension', () {
      final style = CometChatOutgoingCallStyle();
      expect(style, isA<ThemeExtension<CometChatOutgoingCallStyle>>());
    });
  });
}
