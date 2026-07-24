import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/cometchat_message_composer_style.dart';

// ---------------------------------------------------------------------------
// Tests — Kotlin CometChatMessageComposerStyleTest equivalent
// Tests: defaults, custom values, copyWith, merge, equality, lerp
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Default Values — Kotlin CSV #1350-1352
  // =========================================================================

  group('Default values', () {
    test('default constructor has all null properties', () {
      const style = CometChatMessageComposerStyle();

      expect(style.closeIconTint, isNull);
      expect(style.backgroundColor, isNull);
      expect(style.border, isNull);
      expect(style.borderRadius, isNull);
      expect(style.dividerColor, isNull);
      expect(style.dividerHeight, isNull);
      expect(style.sendButtonIconColor, isNull);
      expect(style.sendButtonIconBackgroundColor, isNull);
      expect(style.sendButtonBorderRadius, isNull);
      expect(style.secondaryButtonIconColor, isNull);
      expect(style.secondaryButtonIconBackgroundColor, isNull);
      expect(style.secondaryButtonBorderRadius, isNull);
      expect(style.auxiliaryButtonIconColor, isNull);
      expect(style.auxiliaryButtonIconBackgroundColor, isNull);
      expect(style.auxiliaryButtonBorderRadius, isNull);
      expect(style.textStyle, isNull);
      expect(style.textColor, isNull);
      expect(style.placeHolderTextStyle, isNull);
      expect(style.placeHolderTextColor, isNull);
      expect(style.attachmentOptionSheetStyle, isNull);
      expect(style.mentionsStyle, isNull);
      expect(style.suggestionListStyle, isNull);
      expect(style.mediaRecorderStyle, isNull);
      expect(style.filledColor, isNull);
      expect(style.richTextToolbarStyle, isNull);
      expect(style.inlineAudioRecorderStyle, isNull);
    });

    test('of() returns default style', () {
      // CometChatMessageComposerStyle.of() is a static factory
      // that returns a const default instance
      final style = CometChatMessageComposerStyle.of(_FakeBuildContext());
      expect(style.backgroundColor, isNull);
      expect(style.sendButtonIconColor, isNull);
    });
  });

  // =========================================================================
  // Custom Values — Kotlin CSV #1353-1356
  // =========================================================================

  group('Custom values', () {
    test('constructor accepts all custom values', () {
      const style = CometChatMessageComposerStyle(
        closeIconTint: Colors.red,
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        dividerColor: Colors.grey,
        dividerHeight: 2.0,
        sendButtonIconColor: Colors.blue,
        sendButtonIconBackgroundColor: Colors.lightBlue,
        sendButtonBorderRadius: BorderRadius.all(Radius.circular(20)),
        secondaryButtonIconColor: Colors.green,
        secondaryButtonIconBackgroundColor: Colors.lightGreen,
        secondaryButtonBorderRadius: BorderRadius.all(Radius.circular(8)),
        auxiliaryButtonIconColor: Colors.orange,
        auxiliaryButtonIconBackgroundColor: Colors.amber,
        auxiliaryButtonBorderRadius: BorderRadius.all(Radius.circular(6)),
        textStyle: TextStyle(fontSize: 16),
        textColor: Colors.black,
        placeHolderTextStyle: TextStyle(fontSize: 14),
        placeHolderTextColor: Colors.grey,
        filledColor: Colors.grey,
      );

      expect(style.closeIconTint, Colors.red);
      expect(style.backgroundColor, Colors.white);
      expect(style.dividerColor, Colors.grey);
      expect(style.dividerHeight, 2.0);
      expect(style.sendButtonIconColor, Colors.blue);
      expect(style.sendButtonIconBackgroundColor, Colors.lightBlue);
      expect(style.secondaryButtonIconColor, Colors.green);
      expect(style.auxiliaryButtonIconColor, Colors.orange);
      expect(style.textColor, Colors.black);
      expect(style.placeHolderTextColor, Colors.grey);
      expect(style.filledColor, Colors.grey);
    });

    test('borderRadius is correctly stored', () {
      const style = CometChatMessageComposerStyle(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );
      expect(style.borderRadius, const BorderRadius.all(Radius.circular(16)));
    });

    test('textStyle is correctly stored', () {
      const style = CometChatMessageComposerStyle(
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
      expect(style.textStyle?.fontSize, 18);
      expect(style.textStyle?.fontWeight, FontWeight.bold);
    });
  });

  // =========================================================================
  // copyWith — Kotlin CSV #1357-1360
  // =========================================================================

  group('copyWith', () {
    test('copyWith with no arguments returns equivalent style', () {
      const original = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        sendButtonIconColor: Colors.blue,
        textColor: Colors.black,
      );
      final copied = original.copyWith();

      expect(copied.backgroundColor, Colors.white);
      expect(copied.sendButtonIconColor, Colors.blue);
      expect(copied.textColor, Colors.black);
    });

    test('copyWith replaces specified fields only', () {
      const original = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        sendButtonIconColor: Colors.blue,
        textColor: Colors.black,
        dividerHeight: 1.0,
      );
      final copied = original.copyWith(
        backgroundColor: Colors.grey,
        dividerHeight: 2.0,
      );

      expect(copied.backgroundColor, Colors.grey);
      expect(copied.dividerHeight, 2.0);
      // Unchanged fields preserved
      expect(copied.sendButtonIconColor, Colors.blue);
      expect(copied.textColor, Colors.black);
    });

    test('copyWith can set all color properties', () {
      const original = CometChatMessageComposerStyle();
      final copied = original.copyWith(
        closeIconTint: Colors.red,
        backgroundColor: Colors.white,
        dividerColor: Colors.grey,
        sendButtonIconColor: Colors.blue,
        sendButtonIconBackgroundColor: Colors.lightBlue,
        secondaryButtonIconColor: Colors.green,
        secondaryButtonIconBackgroundColor: Colors.lightGreen,
        auxiliaryButtonIconColor: Colors.orange,
        auxiliaryButtonIconBackgroundColor: Colors.amber,
        textColor: Colors.black,
        placeHolderTextColor: Colors.grey,
        filledColor: Colors.blueGrey,
      );

      expect(copied.closeIconTint, Colors.red);
      expect(copied.backgroundColor, Colors.white);
      expect(copied.dividerColor, Colors.grey);
      expect(copied.sendButtonIconColor, Colors.blue);
      expect(copied.sendButtonIconBackgroundColor, Colors.lightBlue);
      expect(copied.secondaryButtonIconColor, Colors.green);
      expect(copied.secondaryButtonIconBackgroundColor, Colors.lightGreen);
      expect(copied.auxiliaryButtonIconColor, Colors.orange);
      expect(copied.auxiliaryButtonIconBackgroundColor, Colors.amber);
      expect(copied.textColor, Colors.black);
      expect(copied.placeHolderTextColor, Colors.grey);
      expect(copied.filledColor, Colors.blueGrey);
    });

    test('copyWith preserves border radius types', () {
      const original = CometChatMessageComposerStyle(
        sendButtonBorderRadius: BorderRadius.all(Radius.circular(20)),
      );
      final copied = original.copyWith(
        secondaryButtonBorderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      );

      expect(
        copied.sendButtonBorderRadius,
        const BorderRadius.all(Radius.circular(20)),
      );
      expect(
        copied.secondaryButtonBorderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
    });
  });

  // =========================================================================
  // merge — Kotlin CSV #1361-1364
  // =========================================================================

  group('merge', () {
    test('merge with null returns this', () {
      const style = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        sendButtonIconColor: Colors.blue,
      );
      final merged = style.merge(null);

      expect(merged.backgroundColor, Colors.white);
      expect(merged.sendButtonIconColor, Colors.blue);
    });

    test('merge applies other style properties', () {
      const base = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        sendButtonIconColor: Colors.blue,
        textColor: Colors.black,
      );
      const overlay = CometChatMessageComposerStyle(
        backgroundColor: Colors.grey,
        dividerHeight: 3.0,
      );
      final merged = base.merge(overlay);

      // Overlay values take precedence
      expect(merged.backgroundColor, Colors.grey);
      expect(merged.dividerHeight, 3.0);
      // Base values preserved when overlay is null
      expect(merged.sendButtonIconColor, Colors.blue);
      expect(merged.textColor, Colors.black);
    });

    test('merge with fully populated style replaces all', () {
      const base = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        sendButtonIconColor: Colors.blue,
      );
      const overlay = CometChatMessageComposerStyle(
        backgroundColor: Colors.black,
        sendButtonIconColor: Colors.red,
        closeIconTint: Colors.green,
        dividerColor: Colors.amber,
      );
      final merged = base.merge(overlay);

      expect(merged.backgroundColor, Colors.black);
      expect(merged.sendButtonIconColor, Colors.red);
      expect(merged.closeIconTint, Colors.green);
      expect(merged.dividerColor, Colors.amber);
    });

    test('merge is not commutative (order matters)', () {
      const styleA = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
      );
      const styleB = CometChatMessageComposerStyle(
        backgroundColor: Colors.black,
      );

      final aMergeB = styleA.merge(styleB);
      final bMergeA = styleB.merge(styleA);

      expect(aMergeB.backgroundColor, Colors.black);
      expect(bMergeA.backgroundColor, Colors.white);
    });
  });

  // =========================================================================
  // lerp — Kotlin CSV #1365-1367
  // =========================================================================

  group('lerp', () {
    test('lerp at t=0 returns start values', () {
      const start = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        dividerHeight: 1.0,
      );
      const end = CometChatMessageComposerStyle(
        backgroundColor: Colors.black,
        dividerHeight: 4.0,
      );
      final result = start.lerp(end, 0.0);

      expect(result.backgroundColor, Colors.white);
      expect(result.dividerHeight, 1.0);
    });

    test('lerp at t=1 returns end values', () {
      const start = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
        dividerHeight: 1.0,
      );
      const end = CometChatMessageComposerStyle(
        backgroundColor: Colors.black,
        dividerHeight: 4.0,
      );
      final result = start.lerp(end, 1.0);

      expect(result.backgroundColor, Colors.black);
      expect(result.dividerHeight, 4.0);
    });

    test('lerp at t=0.5 interpolates colors', () {
      const start = CometChatMessageComposerStyle(
        backgroundColor: Color(0xFF000000), // black
        sendButtonIconColor: Color(0xFF000000),
      );
      const end = CometChatMessageComposerStyle(
        backgroundColor: Color(0xFFFFFFFF), // white
        sendButtonIconColor: Color(0xFFFFFFFF),
      );
      final result = start.lerp(end, 0.5);

      // At t=0.5, colors should be midpoint (grey)
      expect(result.backgroundColor, isNotNull);
      expect(result.backgroundColor!.r * 255, closeTo(128, 1));
      expect(result.backgroundColor!.g * 255, closeTo(128, 1));
      expect(result.backgroundColor!.b * 255, closeTo(128, 1));
    });

    test('lerp with null other interpolates toward null (transparent)', () {
      const style = CometChatMessageComposerStyle(
        backgroundColor: Colors.white,
      );
      final result = style.lerp(null, 0.5);

      // Color.lerp(white, null, 0.5) produces alpha=0.5 (fades toward transparent)
      expect(result.backgroundColor, isNotNull);
      expect(result.backgroundColor!.a, closeTo(0.5, 0.01));
    });

    test('lerp interpolates dividerHeight', () {
      const start = CometChatMessageComposerStyle(dividerHeight: 0.0);
      const end = CometChatMessageComposerStyle(dividerHeight: 10.0);
      final result = start.lerp(end, 0.3);

      expect(result.dividerHeight, closeTo(3.0, 0.01));
    });
  });

  // =========================================================================
  // ThemeExtension compliance
  // =========================================================================

  group('ThemeExtension compliance', () {
    test('style is a ThemeExtension', () {
      const style = CometChatMessageComposerStyle();
      expect(style, isA<ThemeExtension<CometChatMessageComposerStyle>>());
    });

    test('copyWith returns CometChatMessageComposerStyle type', () {
      const style = CometChatMessageComposerStyle();
      final copied = style.copyWith(backgroundColor: Colors.red);
      expect(copied, isA<CometChatMessageComposerStyle>());
    });

    test('lerp returns CometChatMessageComposerStyle type', () {
      const style = CometChatMessageComposerStyle();
      final lerped = style.lerp(
        const CometChatMessageComposerStyle(backgroundColor: Colors.blue),
        0.5,
      );
      expect(lerped, isA<CometChatMessageComposerStyle>());
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal fake BuildContext for static factory method
// ---------------------------------------------------------------------------

class _FakeBuildContext extends Fake implements BuildContext {}
