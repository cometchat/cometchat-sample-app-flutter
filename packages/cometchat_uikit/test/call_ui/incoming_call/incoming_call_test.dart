import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/call_ui/src/incoming_call/bloc/incoming_call_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/incoming_call/bloc/incoming_call_state.dart';
import 'package:cometchat_chat_uikit/call_ui/src/incoming_call/cometchat_incoming_call_style.dart';
import 'package:cometchat_chat_uikit/call_ui/src/incoming_call/cometchat_incoming_call_configuration.dart';

// ===========================================================================
// Fakes
// ===========================================================================

class FakeCall extends Fake implements Call {
  @override
  String get sessionId => 'session_123';

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
  // IncomingCallState — State tests
  // =========================================================================

  group('IncomingCallState', () {
    test('initial state has idle status', () {
      const state = IncomingCallState();
      expect(state.status, IncomingCallStatus.idle);
      expect(state.isDisabled, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates status', () {
      const state = IncomingCallState();
      final updated = state.copyWith(status: IncomingCallStatus.accepting);
      expect(updated.status, IncomingCallStatus.accepting);
      expect(updated.isDisabled, isFalse);
    });

    test('copyWith updates isDisabled', () {
      const state = IncomingCallState();
      final updated = state.copyWith(isDisabled: true);
      expect(updated.isDisabled, isTrue);
      expect(updated.status, IncomingCallStatus.idle);
    });

    test('copyWith updates errorMessage', () {
      const state = IncomingCallState();
      final updated = state.copyWith(errorMessage: 'Call failed');
      expect(updated.errorMessage, 'Call failed');
    });

    test('copyWith clears errorMessage when set to null explicitly', () {
      const state = IncomingCallState(errorMessage: 'Old error');
      final updated = state.copyWith(errorMessage: null);
      // copyWith with null errorMessage should clear it
      expect(updated.errorMessage, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const state = IncomingCallState(
        status: IncomingCallStatus.accepting,
        isDisabled: true,
        errorMessage: 'Error',
      );
      final updated = state.copyWith(status: IncomingCallStatus.accepted);
      expect(updated.status, IncomingCallStatus.accepted);
      expect(updated.isDisabled, isTrue);
    });

    test('equatable: same values are equal', () {
      const state1 = IncomingCallState(
        status: IncomingCallStatus.idle,
        isDisabled: false,
      );
      const state2 = IncomingCallState(
        status: IncomingCallStatus.idle,
        isDisabled: false,
      );
      expect(state1, equals(state2));
    });

    test('equatable: different status not equal', () {
      const state1 = IncomingCallState(status: IncomingCallStatus.idle);
      const state2 = IncomingCallState(status: IncomingCallStatus.accepting);
      expect(state1, isNot(equals(state2)));
    });

    test('equatable: different isDisabled not equal', () {
      const state1 = IncomingCallState(isDisabled: false);
      const state2 = IncomingCallState(isDisabled: true);
      expect(state1, isNot(equals(state2)));
    });
  });

  // =========================================================================
  // IncomingCallStatus enum
  // =========================================================================

  group('IncomingCallStatus enum', () {
    test('has all expected values', () {
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.idle));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.accepting));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.rejecting));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.accepted));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.rejected));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.cancelled));
      expect(IncomingCallStatus.values, contains(IncomingCallStatus.error));
    });

    test('has 7 values total', () {
      expect(IncomingCallStatus.values.length, 7);
    });
  });

  // =========================================================================
  // IncomingCallEvent — Event tests
  // =========================================================================

  group('IncomingCallEvent', () {
    test('AcceptCall event has empty props', () {
      const event = AcceptCall();
      expect(event.props, isEmpty);
    });

    test('RejectCall event has empty props', () {
      const event = RejectCall();
      expect(event.props, isEmpty);
    });

    test('CallCancelled event has empty props', () {
      const event = CallCancelled();
      expect(event.props, isEmpty);
    });

    test('AcceptCall events are equal', () {
      const event1 = AcceptCall();
      const event2 = AcceptCall();
      expect(event1, equals(event2));
    });

    test('RejectCall events are equal', () {
      const event1 = RejectCall();
      const event2 = RejectCall();
      expect(event1, equals(event2));
    });

    test('AcceptCall and RejectCall are not equal', () {
      const accept = AcceptCall();
      const reject = RejectCall();
      expect(accept, isNot(equals(reject)));
    });
  });

  // =========================================================================
  // CometChatIncomingCallStyle — Style tests
  // =========================================================================

  group('CometChatIncomingCallStyle defaults', () {
    test('all properties are null by default', () {
      final style = CometChatIncomingCallStyle();
      expect(style.backgroundColor, isNull);
      expect(style.avatarStyle, isNull);
      expect(style.subtitleColor, isNull);
      expect(style.subtitleTextStyle, isNull);
      expect(style.titleColor, isNull);
      expect(style.titleTextStyle, isNull);
      expect(style.borderRadius, isNull);
      expect(style.border, isNull);
      expect(style.declineButtonColor, isNull);
      expect(style.acceptButtonColor, isNull);
      expect(style.acceptTextColor, isNull);
      expect(style.acceptTextStyle, isNull);
      expect(style.declineTextColor, isNull);
      expect(style.declineTextStyle, isNull);
      expect(style.callIconColor, isNull);
    });
  });

  group('CometChatIncomingCallStyle copyWith', () {
    test('copyWith updates backgroundColor', () {
      final style = CometChatIncomingCallStyle();
      final updated = style.copyWith(backgroundColor: Colors.black);
      expect(updated.backgroundColor, Colors.black);
    });

    test('copyWith updates button colors', () {
      final style = CometChatIncomingCallStyle();
      final updated = style.copyWith(
        acceptButtonColor: Colors.green,
        declineButtonColor: Colors.red,
      );
      expect(updated.acceptButtonColor, Colors.green);
      expect(updated.declineButtonColor, Colors.red);
    });

    test('copyWith updates text styles', () {
      final style = CometChatIncomingCallStyle();
      const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
      const subtitleStyle = TextStyle(fontSize: 14);
      final updated = style.copyWith(
        titleTextStyle: titleStyle,
        subtitleTextStyle: subtitleStyle,
        titleColor: Colors.white,
        subtitleColor: Colors.grey,
      );
      expect(updated.titleTextStyle, titleStyle);
      expect(updated.subtitleTextStyle, subtitleStyle);
      expect(updated.titleColor, Colors.white);
      expect(updated.subtitleColor, Colors.grey);
    });

    test('copyWith updates accept/decline text properties', () {
      final style = CometChatIncomingCallStyle();
      final updated = style.copyWith(
        acceptTextColor: Colors.white,
        declineTextColor: Colors.white,
        acceptTextStyle: const TextStyle(fontSize: 12),
        declineTextStyle: const TextStyle(fontSize: 12),
      );
      expect(updated.acceptTextColor, Colors.white);
      expect(updated.declineTextColor, Colors.white);
      expect(updated.acceptTextStyle?.fontSize, 12);
      expect(updated.declineTextStyle?.fontSize, 12);
    });

    test('copyWith updates callIconColor', () {
      final style = CometChatIncomingCallStyle();
      final updated = style.copyWith(callIconColor: Colors.blue);
      expect(updated.callIconColor, Colors.blue);
    });

    test('copyWith preserves existing values', () {
      final style = CometChatIncomingCallStyle(
        backgroundColor: Colors.black,
        titleColor: Colors.white,
      );
      final updated = style.copyWith(acceptButtonColor: Colors.green);
      expect(updated.backgroundColor, Colors.black);
      expect(updated.titleColor, Colors.white);
      expect(updated.acceptButtonColor, Colors.green);
    });
  });

  group('CometChatIncomingCallStyle merge', () {
    test('merge with null returns same style', () {
      final style = CometChatIncomingCallStyle(backgroundColor: Colors.blue);
      final merged = style.merge(null);
      expect(merged.backgroundColor, Colors.blue);
    });

    test('merge applies other style properties', () {
      final base = CometChatIncomingCallStyle(
        backgroundColor: Colors.white,
        titleColor: Colors.black,
      );
      final other = CometChatIncomingCallStyle(
        backgroundColor: Colors.blue,
        acceptButtonColor: Colors.green,
      );
      final merged = base.merge(other);
      expect(merged.backgroundColor, Colors.blue);
      expect(merged.acceptButtonColor, Colors.green);
      expect(merged.titleColor, Colors.black);
    });

    test('merge overrides all non-null properties', () {
      final base = CometChatIncomingCallStyle();
      final other = CometChatIncomingCallStyle(
        declineButtonColor: Colors.red,
        acceptButtonColor: Colors.green,
        callIconColor: Colors.blue,
      );
      final merged = base.merge(other);
      expect(merged.declineButtonColor, Colors.red);
      expect(merged.acceptButtonColor, Colors.green);
      expect(merged.callIconColor, Colors.blue);
    });
  });

  group('CometChatIncomingCallStyle lerp', () {
    test('lerp at t=0 returns start style', () {
      final start = CometChatIncomingCallStyle(backgroundColor: Colors.white);
      final end = CometChatIncomingCallStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 0.0);
      expect(result.backgroundColor, Colors.white);
    });

    test('lerp at t=1 returns end style', () {
      final start = CometChatIncomingCallStyle(backgroundColor: Colors.white);
      final end = CometChatIncomingCallStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 1.0);
      expect(result.backgroundColor, Colors.black);
    });

    test('lerp with non-matching type returns this', () {
      final style = CometChatIncomingCallStyle(backgroundColor: Colors.blue);
      final result = style.lerp(null, 0.5);
      expect(result.backgroundColor, Colors.blue);
    });

    test('lerp interpolates button colors', () {
      final start = CometChatIncomingCallStyle(
        acceptButtonColor: Colors.green,
        declineButtonColor: Colors.red,
      );
      final end = CometChatIncomingCallStyle(
        acceptButtonColor: Colors.blue,
        declineButtonColor: Colors.orange,
      );
      final result = start.lerp(end, 0.5);
      expect(result.acceptButtonColor, isNotNull);
      expect(result.declineButtonColor, isNotNull);
    });
  });

  // =========================================================================
  // CometChatIncomingCallConfiguration — Property tests
  // =========================================================================

  group('CometChatIncomingCallConfiguration', () {
    test('all properties are null by default', () {
      final config = CometChatIncomingCallConfiguration();
      expect(config.onError, isNull);
      expect(config.disableSoundForCalls, isNull);
      expect(config.customSoundForCalls, isNull);
      expect(config.customSoundForCallsPackage, isNull);
      expect(config.onDecline, isNull);
      expect(config.onAccept, isNull);
      expect(config.incomingCallStyle, isNull);
      expect(config.callSettingsBuilder, isNull);
      expect(config.acceptButtonText, isNull);
      expect(config.declineButtonText, isNull);
      expect(config.height, isNull);
      expect(config.width, isNull);
      expect(config.titleView, isNull);
      expect(config.subTitleView, isNull);
      expect(config.leadingView, isNull);
      expect(config.itemView, isNull);
      expect(config.trailingView, isNull);
    });

    test('configuration accepts custom button text', () {
      final config = CometChatIncomingCallConfiguration(
        acceptButtonText: 'Answer',
        declineButtonText: 'Ignore',
      );
      expect(config.acceptButtonText, 'Answer');
      expect(config.declineButtonText, 'Ignore');
    });

    test('configuration accepts custom dimensions', () {
      final config = CometChatIncomingCallConfiguration(
        height: 200,
        width: 350,
      );
      expect(config.height, 200);
      expect(config.width, 350);
    });

    test('configuration accepts disableSoundForCalls', () {
      final config = CometChatIncomingCallConfiguration(
        disableSoundForCalls: true,
      );
      expect(config.disableSoundForCalls, isTrue);
    });

    test('configuration accepts custom sound', () {
      final config = CometChatIncomingCallConfiguration(
        customSoundForCalls: 'ringtone.mp3',
        customSoundForCallsPackage: 'assets',
      );
      expect(config.customSoundForCalls, 'ringtone.mp3');
      expect(config.customSoundForCallsPackage, 'assets');
    });

    test('configuration accepts onDecline callback', () {
      final config = CometChatIncomingCallConfiguration(
        onDecline: (context, call) {},
      );
      expect(config.onDecline, isNotNull);
    });

    test('configuration accepts onAccept callback', () {
      final config = CometChatIncomingCallConfiguration(
        onAccept: (context, call) {},
      );
      expect(config.onAccept, isNotNull);
    });

    test('configuration accepts custom style', () {
      final style = CometChatIncomingCallStyle(backgroundColor: Colors.black);
      final config = CometChatIncomingCallConfiguration(
        incomingCallStyle: style,
      );
      expect(config.incomingCallStyle?.backgroundColor, Colors.black);
    });
  });

  // =========================================================================
  // ThemeExtension compliance
  // =========================================================================

  group('ThemeExtension compliance', () {
    test('CometChatIncomingCallStyle extends ThemeExtension', () {
      final style = CometChatIncomingCallStyle();
      expect(style, isA<ThemeExtension<CometChatIncomingCallStyle>>());
    });
  });
}
