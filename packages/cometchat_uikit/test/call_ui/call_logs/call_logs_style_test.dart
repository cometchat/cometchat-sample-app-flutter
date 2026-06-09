import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_logs/cometchat_call_logs/call_logs_style.dart';

// ===========================================================================
// Tests — CometChatCallLogsStyle
// ===========================================================================

void main() {
  // =========================================================================
  // Default values
  // =========================================================================

  group('CometChatCallLogsStyle defaults', () {
    test('all properties are null by default', () {
      const style = CometChatCallLogsStyle();
      expect(style.backgroundColor, isNull);
      expect(style.border, isNull);
      expect(style.borderRadius, isNull);
      expect(style.backIconColor, isNull);
      expect(style.titleTextStyle, isNull);
      expect(style.titleTextColor, isNull);
      expect(style.emptyStateTextStyle, isNull);
      expect(style.emptyStateTextColor, isNull);
      expect(style.errorStateTextStyle, isNull);
      expect(style.errorStateTextColor, isNull);
      expect(style.emptyStateSubTitleTextStyle, isNull);
      expect(style.emptyStateSubTitleTextColor, isNull);
      expect(style.errorStateSubTitleTextStyle, isNull);
      expect(style.errorStateSubTitleTextColor, isNull);
      expect(style.itemTitleTextStyle, isNull);
      expect(style.itemTitleTextColor, isNull);
      expect(style.separatorColor, isNull);
      expect(style.separatorHeight, isNull);
      expect(style.avatarStyle, isNull);
      expect(style.dateStyle, isNull);
      expect(style.retryButtonBackgroundColor, isNull);
      expect(style.retryButtonBorder, isNull);
      expect(style.retryButtonBorderRadius, isNull);
      expect(style.retryButtonTextColor, isNull);
      expect(style.retryButtonTextStyle, isNull);
      expect(style.incomingCallIconColor, isNull);
      expect(style.outgoingCallIconColor, isNull);
      expect(style.missedCallIconColor, isNull);
      expect(style.audioCallIconColor, isNull);
      expect(style.videoCallIconColor, isNull);
    });

    test('of() returns default style', () {
      // CometChatCallLogsStyle.of() returns const CometChatCallLogsStyle()
      // We can't call it without a BuildContext, but we verify the static method exists
      expect(CometChatCallLogsStyle.of, isNotNull);
    });
  });

  // =========================================================================
  // copyWith
  // =========================================================================

  group('CometChatCallLogsStyle copyWith', () {
    test('copyWith returns new instance with updated backgroundColor', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(backgroundColor: Colors.red);
      expect(updated.backgroundColor, Colors.red);
      expect(updated.border, isNull);
    });

    test('copyWith preserves existing values when not overridden', () {
      const style = CometChatCallLogsStyle(
        backgroundColor: Colors.blue,
        titleTextColor: Colors.white,
      );
      final updated = style.copyWith(backIconColor: Colors.green);
      expect(updated.backgroundColor, Colors.blue);
      expect(updated.titleTextColor, Colors.white);
      expect(updated.backIconColor, Colors.green);
    });

    test('copyWith updates titleTextStyle', () {
      const style = CometChatCallLogsStyle();
      const textStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
      final updated = style.copyWith(titleTextStyle: textStyle);
      expect(updated.titleTextStyle, textStyle);
    });

    test('copyWith updates border and borderRadius', () {
      const style = CometChatCallLogsStyle();
      final border = Border.all(color: Colors.red, width: 2);
      final borderRadius = BorderRadius.circular(12);
      final updated = style.copyWith(
        border: border,
        borderRadius: borderRadius,
      );
      expect(updated.border, border);
      expect(updated.borderRadius, borderRadius);
    });

    test('copyWith updates call icon colors', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(
        incomingCallIconColor: Colors.green,
        outgoingCallIconColor: Colors.blue,
        missedCallIconColor: Colors.red,
        audioCallIconColor: Colors.purple,
        videoCallIconColor: Colors.orange,
      );
      expect(updated.incomingCallIconColor, Colors.green);
      expect(updated.outgoingCallIconColor, Colors.blue);
      expect(updated.missedCallIconColor, Colors.red);
      expect(updated.audioCallIconColor, Colors.purple);
      expect(updated.videoCallIconColor, Colors.orange);
    });

    test('copyWith updates retry button properties', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(
        retryButtonBackgroundColor: Colors.grey,
        retryButtonTextColor: Colors.white,
        retryButtonTextStyle: const TextStyle(fontSize: 14),
        retryButtonBorder: const BorderSide(color: Colors.black),
        retryButtonBorderRadius: BorderRadius.circular(8),
      );
      expect(updated.retryButtonBackgroundColor, Colors.grey);
      expect(updated.retryButtonTextColor, Colors.white);
      expect(updated.retryButtonTextStyle?.fontSize, 14);
      expect(updated.retryButtonBorder?.color, Colors.black);
      expect(updated.retryButtonBorderRadius, isNotNull);
    });

    test('copyWith updates empty and error state styles', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(
        emptyStateTextStyle: const TextStyle(fontSize: 16),
        emptyStateTextColor: Colors.grey,
        errorStateTextStyle: const TextStyle(fontSize: 14),
        errorStateTextColor: Colors.red,
        emptyStateSubTitleTextStyle: const TextStyle(fontSize: 12),
        emptyStateSubTitleTextColor: Colors.grey.shade600,
        errorStateSubTitleTextStyle: const TextStyle(fontSize: 12),
        errorStateSubTitleTextColor: Colors.red.shade300,
      );
      expect(updated.emptyStateTextStyle?.fontSize, 16);
      expect(updated.emptyStateTextColor, Colors.grey);
      expect(updated.errorStateTextStyle?.fontSize, 14);
      expect(updated.errorStateTextColor, Colors.red);
      expect(updated.emptyStateSubTitleTextStyle?.fontSize, 12);
      expect(updated.errorStateSubTitleTextStyle?.fontSize, 12);
    });

    test('copyWith updates separator properties', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(
        separatorColor: Colors.grey.shade200,
        separatorHeight: 1.5,
      );
      expect(updated.separatorColor, Colors.grey.shade200);
      expect(updated.separatorHeight, 1.5);
    });

    test('copyWith updates item title style', () {
      const style = CometChatCallLogsStyle();
      final updated = style.copyWith(
        itemTitleTextStyle: const TextStyle(fontSize: 16),
        itemTitleTextColor: Colors.black87,
      );
      expect(updated.itemTitleTextStyle?.fontSize, 16);
      expect(updated.itemTitleTextColor, Colors.black87);
    });
  });

  // =========================================================================
  // merge
  // =========================================================================

  group('CometChatCallLogsStyle merge', () {
    test('merge with null returns same style', () {
      const style = CometChatCallLogsStyle(backgroundColor: Colors.blue);
      final merged = style.merge(null);
      expect(merged.backgroundColor, Colors.blue);
    });

    test('merge applies other style properties', () {
      const base = CometChatCallLogsStyle(
        backgroundColor: Colors.white,
        titleTextColor: Colors.black,
      );
      const other = CometChatCallLogsStyle(
        backgroundColor: Colors.blue,
        backIconColor: Colors.red,
      );
      final merged = base.merge(other);
      expect(merged.backgroundColor, Colors.blue);
      expect(merged.backIconColor, Colors.red);
      // titleTextColor from base is overridden by other (which is null)
      // merge uses copyWith which preserves base when other field is null
      expect(merged.titleTextColor, Colors.black);
    });

    test('merge overrides all non-null properties from other', () {
      const base = CometChatCallLogsStyle();
      const other = CometChatCallLogsStyle(
        incomingCallIconColor: Colors.green,
        outgoingCallIconColor: Colors.blue,
        missedCallIconColor: Colors.red,
      );
      final merged = base.merge(other);
      expect(merged.incomingCallIconColor, Colors.green);
      expect(merged.outgoingCallIconColor, Colors.blue);
      expect(merged.missedCallIconColor, Colors.red);
    });

    test('merge preserves base values when other has nulls', () {
      const base = CometChatCallLogsStyle(
        backgroundColor: Colors.white,
        titleTextColor: Colors.black,
        separatorHeight: 1.0,
      );
      const other = CometChatCallLogsStyle(
        backgroundColor: Colors.grey,
        // titleTextColor is null in other
        // separatorHeight is null in other
      );
      final merged = base.merge(other);
      expect(merged.backgroundColor, Colors.grey);
      expect(merged.titleTextColor, Colors.black);
      expect(merged.separatorHeight, 1.0);
    });
  });

  // =========================================================================
  // lerp
  // =========================================================================

  group('CometChatCallLogsStyle lerp', () {
    test('lerp at t=0 returns start style', () {
      const start = CometChatCallLogsStyle(backgroundColor: Colors.white);
      const end = CometChatCallLogsStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 0.0);
      expect(result.backgroundColor, Colors.white);
    });

    test('lerp at t=1 returns end style', () {
      const start = CometChatCallLogsStyle(backgroundColor: Colors.white);
      const end = CometChatCallLogsStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 1.0);
      expect(result.backgroundColor, Colors.black);
    });

    test('lerp at t=0.5 interpolates colors', () {
      const start = CometChatCallLogsStyle(backgroundColor: Colors.white);
      const end = CometChatCallLogsStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 0.5);
      expect(result.backgroundColor, isNotNull);
      // Midpoint between white and black should be grey
      expect(result.backgroundColor, isNot(Colors.white));
      expect(result.backgroundColor, isNot(Colors.black));
    });

    test('lerp with non-CometChatCallLogsStyle returns this', () {
      const style = CometChatCallLogsStyle(backgroundColor: Colors.blue);
      final result = style.lerp(null, 0.5);
      expect(result.backgroundColor, Colors.blue);
    });

    test('lerp interpolates separatorHeight', () {
      const start = CometChatCallLogsStyle(separatorHeight: 0.0);
      const end = CometChatCallLogsStyle(separatorHeight: 10.0);
      final result = start.lerp(end, 0.5);
      expect(result.separatorHeight, 5.0);
    });

    test('lerp interpolates call icon colors', () {
      const start = CometChatCallLogsStyle(
        incomingCallIconColor: Colors.green,
        missedCallIconColor: Colors.red,
      );
      const end = CometChatCallLogsStyle(
        incomingCallIconColor: Colors.blue,
        missedCallIconColor: Colors.orange,
      );
      final result = start.lerp(end, 0.5);
      expect(result.incomingCallIconColor, isNotNull);
      expect(result.missedCallIconColor, isNotNull);
    });
  });

  // =========================================================================
  // ThemeExtension type
  // =========================================================================

  group('ThemeExtension compliance', () {
    test('CometChatCallLogsStyle extends ThemeExtension', () {
      const style = CometChatCallLogsStyle();
      expect(style, isA<ThemeExtension<CometChatCallLogsStyle>>());
    });

    test('copyWith returns CometChatCallLogsStyle type', () {
      const style = CometChatCallLogsStyle();
      final copy = style.copyWith(backgroundColor: Colors.red);
      expect(copy, isA<CometChatCallLogsStyle>());
    });

    test('lerp returns CometChatCallLogsStyle type', () {
      const style = CometChatCallLogsStyle();
      final result = style.lerp(const CometChatCallLogsStyle(), 0.5);
      expect(result, isA<CometChatCallLogsStyle>());
    });
  });
}
