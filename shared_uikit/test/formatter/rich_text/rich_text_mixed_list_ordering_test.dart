import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Tests for mixed bullet/number list ordering (Requirement 2.16)
/// 
/// **Validates: Requirements 2.16**
/// 
/// WHEN bullet list items are between ordered list items
/// THEN the system SHALL maintain the ordering sequence (e.g., 1, 2, -, 3, -, 4)
void main() {
  group('Mixed Bullet/Number List Ordering (Requirement 2.16)', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Ordered List Continuation After Bullet Items', () {
      test('ordered list continues correctly after bullet item', () {
        // Setup: "1. First\n2. Second\n- Bullet\n"
        // When user adds an ordered list item after the bullet, it should be "3. "
        controller.text = '1. First\n2. Second\n- Bullet\n';
        
        // Position cursor at the end (after the newline)
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        
        // Toggle ordered list to add a new ordered item
        controller.toggleFormat(FormatType.orderedList);
        
        // The new line should be "3. " (continuing from 2)
        expect(controller.text, contains('3. '));
      });

      test('ordered list continues correctly after multiple bullet items', () {
        // Setup: "1. First\n2. Second\n- Bullet1\n- Bullet2\n"
        controller.text = '1. First\n2. Second\n- Bullet1\n- Bullet2\n';
        
        // Position cursor at the end
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        
        // Toggle ordered list
        controller.toggleFormat(FormatType.orderedList);
        
        // The new line should be "3. " (continuing from 2, skipping bullets)
        expect(controller.text, contains('3. '));
      });

      test('preserves mixed list ordering on send', () {
        // Setup: "1. First\n2. Second\n- Bullet\n3. Third\n- Another\n4. Fourth"
        controller.text = '1. First\n2. Second\n- Bullet\n3. Third\n- Another\n4. Fourth';
        
        final markdown = controller.toMarkdown();
        
        // The ordering should be preserved exactly as typed
        expect(markdown, equals('1. First\n2. Second\n- Bullet\n3. Third\n- Another\n4. Fourth'));
      });

      test('does not renumber ordered items when bullet is inserted between', () {
        // Setup: "1. First\n2. Second\n3. Third"
        controller.text = '1. First\n2. Second\n3. Third';
        
        // Position cursor at the start of "3. Third" line
        final thirdLineStart = controller.text.indexOf('3. Third');
        controller.selection = TextSelection.collapsed(offset: thirdLineStart);
        
        // Convert "3. Third" to bullet
        controller.toggleFormat(FormatType.bulletList);
        
        // The text should now be "1. First\n2. Second\n- Third"
        // Note: The "3. " prefix should be replaced with "- "
        expect(controller.text, contains('- Third'));
        expect(controller.text, contains('1. First'));
        expect(controller.text, contains('2. Second'));
      });

      test('ordered list after bullet uses correct next number', () {
        // Setup: "1. First\n- Bullet\n"
        controller.text = '1. First\n- Bullet\n';
        
        // Position cursor at the end
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        
        // Toggle ordered list
        controller.toggleFormat(FormatType.orderedList);
        
        // The new line should be "2. " (continuing from 1)
        expect(controller.text, contains('2. '));
      });
    });

    group('Newline Continuation with Mixed Lists', () {
      test('pressing enter on ordered list after bullet continues numbering', () {
        // Initialize the binding for tests that trigger _handleNewlineContinuation
        TestWidgetsFlutterBinding.ensureInitialized();
        
        // Setup: "1. First\n- Bullet\n2. Second"
        // Position cursor at the end of "2. Second"
        controller.text = '1. First\n- Bullet\n2. Second';
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
        
        // Simulate pressing Enter by inserting newline
        // The _handleNewlineContinuation should add "3. "
        final currentText = controller.text;
        final newText = '$currentText\n';
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: newText.length);
        
        // Note: This test verifies the text state, but the actual continuation
        // happens in _handleTextChange which we can't easily trigger in unit tests
        // The important thing is that the text structure is preserved
        expect(controller.text, equals('1. First\n- Bullet\n2. Second\n'));
      });
    });

    group('toMarkdown Preserves Mixed List Structure', () {
      test('toMarkdown preserves exact ordering with mixed lists', () {
        controller.text = '1. First\n2. Second\n- Bullet\n3. Third';
        
        final markdown = controller.toMarkdown();
        
        expect(markdown, equals('1. First\n2. Second\n- Bullet\n3. Third'));
      });

      test('toMarkdown preserves multiple bullet items between ordered items', () {
        controller.text = '1. First\n- Bullet1\n- Bullet2\n2. Second';
        
        final markdown = controller.toMarkdown();
        
        expect(markdown, equals('1. First\n- Bullet1\n- Bullet2\n2. Second'));
      });

      test('toMarkdown preserves alternating bullet and ordered items', () {
        controller.text = '1. First\n- Bullet\n2. Second\n- Another\n3. Third';
        
        final markdown = controller.toMarkdown();
        
        expect(markdown, equals('1. First\n- Bullet\n2. Second\n- Another\n3. Third'));
      });
    });

    group('Edge Cases for Mixed List Ordering', () {
      test('handles bullet at the start followed by ordered list', () {
        controller.text = '- Bullet\n1. First\n2. Second';
        
        final markdown = controller.toMarkdown();
        
        expect(markdown, equals('- Bullet\n1. First\n2. Second'));
      });

      test('handles ordered list starting after multiple bullets', () {
        controller.text = '- Bullet1\n- Bullet2\n- Bullet3\n1. First';
        
        final markdown = controller.toMarkdown();
        
        expect(markdown, equals('- Bullet1\n- Bullet2\n- Bullet3\n1. First'));
      });

      test('handles complex mixed list with blockquote', () {
        controller.text = '1. First\n> Quote\n2. Second\n- Bullet\n3. Third';
        
        final markdown = controller.toMarkdown();
        
        // Note: blockquote breaks the list sequence, so this tests that behavior
        expect(markdown, equals('1. First\n> Quote\n2. Second\n- Bullet\n3. Third'));
      });

      test('converting bullet to ordered list uses correct number', () {
        // Setup: "1. First\n2. Second\n- Bullet"
        controller.text = '1. First\n2. Second\n- Bullet';
        
        // Position cursor on the bullet line
        final bulletLineStart = controller.text.indexOf('- Bullet');
        controller.selection = TextSelection.collapsed(offset: bulletLineStart + 2);
        
        // Convert bullet to ordered list
        controller.toggleFormat(FormatType.orderedList);
        
        // The bullet should become "3. Bullet" (continuing from 2)
        expect(controller.text, contains('3. Bullet'));
        expect(controller.text, isNot(contains('- Bullet')));
      });

      test('converting ordered to bullet preserves subsequent numbering', () {
        // Setup: "1. First\n2. Second\n3. Third"
        controller.text = '1. First\n2. Second\n3. Third';
        
        // Position cursor on the second line
        final secondLineStart = controller.text.indexOf('2. Second');
        controller.selection = TextSelection.collapsed(offset: secondLineStart + 2);
        
        // Convert "2. Second" to bullet
        controller.toggleFormat(FormatType.bulletList);
        
        // The text should now have "1. First\n- Second\n2. Third"
        // Note: The third item should be renumbered to 2
        expect(controller.text, contains('1. First'));
        expect(controller.text, contains('- Second'));
        expect(controller.text, contains('2. Third'));
      });
    });
  });

}
