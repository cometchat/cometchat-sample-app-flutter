import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Tests for empty list point preservation on send (Requirement 2.15)
/// 
/// **Validates: Requirements 2.15**
/// 
/// WHEN in ordered/bullet list and a point except the first is empty
/// THEN the system SHALL send the message as-is without removing the empty point
void main() {
  group('Empty List Point Preservation (Requirement 2.15)', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Ordered List - Empty Points Preserved', () {
      test('preserves empty second item in ordered list', () {
        // Setup: "1. Hi\n2. " - first item has content, second is empty
        controller.text = '1. Hi\n2. ';
        
        final markdown = controller.toMarkdown();
        
        // The empty second item should be preserved
        expect(markdown, equals('1. Hi\n2. '));
      });

      test('preserves empty third item when first two have content', () {
        // Setup: "1. First\n2. Second\n3. " - first two have content, third is empty
        controller.text = '1. First\n2. Second\n3. ';
        
        final markdown = controller.toMarkdown();
        
        // The empty third item should be preserved
        expect(markdown, equals('1. First\n2. Second\n3. '));
      });

      test('preserves multiple empty items after non-empty items', () {
        // Setup: "1. Content\n2. \n3. " - first has content, second and third are empty
        controller.text = '1. Content\n2. \n3. ';
        
        final markdown = controller.toMarkdown();
        
        // Empty items after non-empty content should be preserved
        // Note: The cleanup only removes trailing empty items if there's no content before
        expect(markdown, equals('1. Content\n2. \n3. '));
      });

      test('removes empty first item when it is the only item', () {
        // Setup: "1. " - only item is empty
        controller.text = '1. ';
        
        final markdown = controller.toMarkdown();
        
        // Empty first/only item should be removed
        expect(markdown, equals(''));
      });
    });

    group('Bullet List - Empty Points Preserved', () {
      test('preserves empty second item in bullet list', () {
        // Setup: "- Hi\n- " - first item has content, second is empty
        controller.text = '- Hi\n- ';
        
        final markdown = controller.toMarkdown();
        
        // The empty second item should be preserved
        expect(markdown, equals('- Hi\n- '));
      });

      test('preserves empty third item when first two have content', () {
        // Setup: "- First\n- Second\n- " - first two have content, third is empty
        controller.text = '- First\n- Second\n- ';
        
        final markdown = controller.toMarkdown();
        
        // The empty third item should be preserved
        expect(markdown, equals('- First\n- Second\n- '));
      });

      test('removes empty first item when it is the only item', () {
        // Setup: "- " - only item is empty
        controller.text = '- ';
        
        final markdown = controller.toMarkdown();
        
        // Empty first/only item should be removed
        expect(markdown, equals(''));
      });
    });

    group('Nested List in Blockquote - Empty Points Preserved', () {
      test('preserves empty second nested bullet item', () {
        // Setup: "> - Hi\n> - " - first nested item has content, second is empty
        controller.text = '> - Hi\n> - ';
        
        final markdown = controller.toMarkdown();
        
        // The empty second nested item should be preserved
        expect(markdown, equals('> - Hi\n> - '));
      });

      test('preserves empty second nested ordered item', () {
        // Setup: "> 1. Hi\n> 2. " - first nested item has content, second is empty
        controller.text = '> 1. Hi\n> 2. ';
        
        final markdown = controller.toMarkdown();
        
        // The empty second nested item should be preserved
        expect(markdown, equals('> 1. Hi\n> 2. '));
      });

      test('removes empty first nested item when it is the only item', () {
        // Setup: "> - " - only nested item is empty
        controller.text = '> - ';
        
        final markdown = controller.toMarkdown();
        
        // Empty first/only nested item should be removed
        expect(markdown, equals(''));
      });
    });

    group('Blockquote - Empty Lines Still Removed', () {
      test('removes trailing empty blockquote lines', () {
        // Setup: "> Content\n> " - blockquote with trailing empty line
        controller.text = '> Content\n> ';
        
        final markdown = controller.toMarkdown();
        
        // Empty blockquote lines should still be removed (not list items)
        expect(markdown, equals('> Content'));
      });

      test('removes multiple trailing empty blockquote lines', () {
        // Setup: "> Content\n> \n> " - blockquote with multiple trailing empty lines
        controller.text = '> Content\n> \n> ';
        
        final markdown = controller.toMarkdown();
        
        // All trailing empty blockquote lines should be removed
        expect(markdown, equals('> Content'));
      });
    });

    group('Mixed Content', () {
      test('preserves empty list item after text content', () {
        // Setup: "Some text\n1. Item\n2. " - text followed by list with empty second item
        controller.text = 'Some text\n1. Item\n2. ';
        
        final markdown = controller.toMarkdown();
        
        // The empty second list item should be preserved
        expect(markdown, equals('Some text\n1. Item\n2. '));
      });

      test('handles list followed by blockquote', () {
        // Setup: "1. Item\n> Quote" - list followed by blockquote
        controller.text = '1. Item\n> Quote';
        
        final markdown = controller.toMarkdown();
        
        // Both should be preserved
        expect(markdown, equals('1. Item\n> Quote'));
      });
    });
  });
}
