import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Tests for CometChatMentionsFormatter's dynamic enable/disable functionality.
/// 
/// **Validates: Requirements 2.5, 2.6, 2.7**
void main() {
  group('CometChatMentionsFormatter - setMentionsEnabled', () {
    late CometChatMentionsFormatter formatter;

    setUp(() {
      formatter = CometChatMentionsFormatter();
      formatter.init();
    });

    test('isMentionsEnabled returns true by default', () {
      // By default, mentions should be enabled
      expect(formatter.isMentionsEnabled, isTrue);
    });

    test('setMentionsEnabled(false) disables mentions', () {
      // Disable mentions
      formatter.setMentionsEnabled(false);
      
      // Verify mentions are disabled
      expect(formatter.isMentionsEnabled, isFalse);
    });

    test('setMentionsEnabled(true) enables mentions', () {
      // First disable mentions
      formatter.setMentionsEnabled(false);
      expect(formatter.isMentionsEnabled, isFalse);
      
      // Then enable mentions
      formatter.setMentionsEnabled(true);
      
      // Verify mentions are enabled
      expect(formatter.isMentionsEnabled, isTrue);
    });

    test('setMentionsEnabled(false) resets mention tracker if active', () {
      // Simulate an active mention tracker
      formatter.mentionTracker = '@test';
      formatter.mentionStartIndex = 0;
      formatter.mentionEndIndex = 4;
      
      // Disable mentions
      formatter.setMentionsEnabled(false);
      
      // Verify mention tracker is reset
      expect(formatter.mentionTracker, isEmpty);
      expect(formatter.mentionStartIndex, equals(0));
      expect(formatter.mentionEndIndex, equals(0));
    });

    test('setMentionsEnabled(true) does not reset mention tracker', () {
      // Simulate an active mention tracker
      formatter.mentionTracker = '@test';
      formatter.mentionStartIndex = 5;
      formatter.mentionEndIndex = 9;
      
      // Enable mentions (should not reset tracker)
      formatter.setMentionsEnabled(true);
      
      // Verify mention tracker is preserved
      expect(formatter.mentionTracker, equals('@test'));
      expect(formatter.mentionStartIndex, equals(5));
      expect(formatter.mentionEndIndex, equals(9));
    });
  });
}
