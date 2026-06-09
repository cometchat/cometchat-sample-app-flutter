import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/groups/cometchat_groups_style.dart';

// ===========================================================================
// Tests — CometChatGroupsStyle
// ===========================================================================

void main() {
  // =========================================================================
  // Default values
  // =========================================================================

  group('CometChatGroupsStyle defaults', () {
    test('all properties are null by default', () {
      const style = CometChatGroupsStyle();
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
      expect(style.itemSubtitleTextStyle, isNull);
      expect(style.itemSubtitleTextColor, isNull);
      expect(style.separatorColor, isNull);
      expect(style.separatorHeight, isNull);
      expect(style.avatarStyle, isNull);
      expect(style.statusIndicatorStyle, isNull);
      expect(style.searchBackgroundColor, isNull);
      expect(style.searchBorder, isNull);
      expect(style.searchBorderRadius, isNull);
      expect(style.searchIconColor, isNull);
      expect(style.searchInputTextColor, isNull);
      expect(style.searchInputTextStyle, isNull);
      expect(style.searchPlaceHolderTextColor, isNull);
      expect(style.searchPlaceHolderTextStyle, isNull);
      expect(style.checkBoxBackgroundColor, isNull);
      expect(style.checkBoxBorder, isNull);
      expect(style.checkBoxBorderRadius, isNull);
      expect(style.checkBoxCheckedBackgroundColor, isNull);
      expect(style.listItemSelectedBackgroundColor, isNull);
      expect(style.checkboxSelectedIconColor, isNull);
      expect(style.submitIconColor, isNull);
      expect(style.retryButtonBackgroundColor, isNull);
      expect(style.retryButtonBorder, isNull);
      expect(style.retryButtonBorderRadius, isNull);
      expect(style.retryButtonTextColor, isNull);
      expect(style.retryButtonTextStyle, isNull);
      expect(style.protectedGroupIconBackground, isNull);
      expect(style.privateGroupIconBackground, isNull);
    });
  });

  // =========================================================================
  // copyWith
  // =========================================================================

  group('CometChatGroupsStyle copyWith', () {
    test('copyWith updates backgroundColor', () {
      const style = CometChatGroupsStyle();
      final updated = style.copyWith(backgroundColor: Colors.white);
      expect(updated.backgroundColor, Colors.white);
    });

    test('copyWith preserves existing values when not overridden', () {
      const style = CometChatGroupsStyle(
        backgroundColor: Colors.blue,
        titleTextColor: Colors.white,
        separatorHeight: 1.0,
      );
      final updated = style.copyWith(backIconColor: Colors.red);
      expect(updated.backgroundColor, Colors.blue);
      expect(updated.titleTextColor, Colors.white);
      expect(updated.separatorHeight, 1.0);
      expect(updated.backIconColor, Colors.red);
    });

    test('copyWith updates group icon backgrounds', () {
      const style = CometChatGroupsStyle();
      final updated = style.copyWith(
        privateGroupIconBackground: Colors.blue,
        protectedGroupIconBackground: Colors.orange,
      );
      expect(updated.privateGroupIconBackground, Colors.blue);
      expect(updated.protectedGroupIconBackground, Colors.orange);
    });

    test('copyWith updates search properties', () {
      const style = CometChatGroupsStyle();
      final updated = style.copyWith(
        searchBackgroundColor: Colors.grey.shade100,
        searchIconColor: Colors.grey,
        searchInputTextColor: Colors.black,
        searchPlaceHolderTextColor: Colors.grey.shade400,
      );
      expect(updated.searchBackgroundColor, Colors.grey.shade100);
      expect(updated.searchIconColor, Colors.grey);
      expect(updated.searchInputTextColor, Colors.black);
      expect(updated.searchPlaceHolderTextColor, Colors.grey.shade400);
    });

    test('copyWith updates checkbox properties', () {
      const style = CometChatGroupsStyle();
      final updated = style.copyWith(
        checkBoxBackgroundColor: Colors.white,
        checkBoxCheckedBackgroundColor: Colors.blue,
        checkboxSelectedIconColor: Colors.white,
        listItemSelectedBackgroundColor: Colors.blue.shade50,
      );
      expect(updated.checkBoxBackgroundColor, Colors.white);
      expect(updated.checkBoxCheckedBackgroundColor, Colors.blue);
      expect(updated.checkboxSelectedIconColor, Colors.white);
      expect(updated.listItemSelectedBackgroundColor, Colors.blue.shade50);
    });
  });

  // =========================================================================
  // merge
  // =========================================================================

  group('CometChatGroupsStyle merge', () {
    test('merge with null returns same style', () {
      const style = CometChatGroupsStyle(backgroundColor: Colors.white);
      final merged = style.merge(null);
      expect(merged.backgroundColor, Colors.white);
    });

    test('merge applies other style properties', () {
      const base = CometChatGroupsStyle(
        backgroundColor: Colors.white,
        titleTextColor: Colors.black,
      );
      const other = CometChatGroupsStyle(
        backgroundColor: Colors.blue,
        privateGroupIconBackground: Colors.indigo,
      );
      final merged = base.merge(other);
      expect(merged.backgroundColor, Colors.blue);
      expect(merged.privateGroupIconBackground, Colors.indigo);
      // titleTextColor from base preserved since merge uses copyWith
      expect(merged.titleTextColor, Colors.black);
    });

    test('merge overrides all non-null properties from other', () {
      const base = CometChatGroupsStyle();
      const other = CometChatGroupsStyle(
        separatorColor: Colors.grey,
        separatorHeight: 2.0,
        submitIconColor: Colors.green,
        retryButtonBackgroundColor: Colors.red,
      );
      final merged = base.merge(other);
      expect(merged.separatorColor, Colors.grey);
      expect(merged.separatorHeight, 2.0);
      expect(merged.submitIconColor, Colors.green);
      expect(merged.retryButtonBackgroundColor, Colors.red);
    });
  });

  // =========================================================================
  // lerp
  // =========================================================================

  group('CometChatGroupsStyle lerp', () {
    test('lerp at t=0 returns start style', () {
      const start = CometChatGroupsStyle(backgroundColor: Colors.white);
      const end = CometChatGroupsStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 0.0);
      expect(result.backgroundColor, Colors.white);
    });

    test('lerp at t=1 returns end style', () {
      const start = CometChatGroupsStyle(backgroundColor: Colors.white);
      const end = CometChatGroupsStyle(backgroundColor: Colors.black);
      final result = start.lerp(end, 1.0);
      expect(result.backgroundColor, Colors.black);
    });

    test('lerp with non-CometChatGroupsStyle returns this', () {
      const style = CometChatGroupsStyle(backgroundColor: Colors.blue);
      final result = style.lerp(null, 0.5);
      expect(result.backgroundColor, Colors.blue);
    });

    test('lerp interpolates separatorHeight', () {
      const start = CometChatGroupsStyle(separatorHeight: 0.0);
      const end = CometChatGroupsStyle(separatorHeight: 10.0);
      final result = start.lerp(end, 0.5);
      expect(result.separatorHeight, 5.0);
    });
  });

  // =========================================================================
  // ThemeExtension compliance
  // =========================================================================

  group('ThemeExtension compliance', () {
    test('CometChatGroupsStyle extends ThemeExtension', () {
      const style = CometChatGroupsStyle();
      expect(style, isA<ThemeExtension<CometChatGroupsStyle>>());
    });

    test('of() static method exists', () {
      expect(CometChatGroupsStyle.of, isNotNull);
    });
  });
}
