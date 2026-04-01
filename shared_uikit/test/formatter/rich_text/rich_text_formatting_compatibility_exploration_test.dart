import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Bug Condition Exploration Tests for Rich Text Formatting Compatibility
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.10, 1.11, 1.21, 1.22, 1.23, 1.24**
///
/// These tests are designed to FAIL on unfixed code to confirm the bugs exist.
/// When the tests fail, they surface counterexamples that demonstrate the bug.
/// After the fix is implemented, these same tests should PASS.
///
/// **CRITICAL**: Do NOT modify these tests when they fail - the failure confirms the bug exists.

void main() {
  group('Bug Condition Exploration - Rich Text Formatting Compatibility', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    // =========================================================================
    // VERIFIED WORKING: Code Block Disables Inline Formats
    // These tests PASS - the functionality already exists
    // =========================================================================
    group('Code Block Disables Inline Formats (VERIFIED WORKING)', () {
      test('disabledFormats contains all inline formats when code block is active', () {
        controller.toggleFormat(FormatType.codeBlock);
        final disabled = controller.disabledFormats;

        expect(disabled.contains(FormatType.bold), isTrue);
        expect(disabled.contains(FormatType.italic), isTrue);
        expect(disabled.contains(FormatType.underline), isTrue);
        expect(disabled.contains(FormatType.strikethrough), isTrue);
        expect(disabled.contains(FormatType.link), isTrue);
        expect(disabled.contains(FormatType.inlineCode), isTrue);
      });
    });


    // =========================================================================
    // BUG CONDITION: Mentions Not Disabled in Code Block
    // Validates: Requirements 1.5, 1.6
    // 
    // EXPECTED: mentionsEnabled property should exist and return false when
    // code block or inline code is active
    // =========================================================================
    group('BUG: Mentions Not Disabled in Code Block', () {
      test('controller should have mentionsEnabled property that returns false when code block is active', () {
        controller.toggleFormat(FormatType.codeBlock);
        
        // BUG: The mentionsEnabled property does not exist yet
        // This test will fail until the property is implemented
        // 
        // Expected behavior: controller.mentionsEnabled should be false
        // when code block is active
        
        // Check if the property exists by trying to access it
        // If this test fails, it confirms the bug exists
        try {
          // Using dynamic to check if property exists
          final dynamic dynamicController = controller;
          final mentionsEnabled = dynamicController.mentionsEnabled as bool;
          expect(mentionsEnabled, isFalse,
              reason: 'Mentions should be disabled when code block is active');
        } catch (e) {
          // Property doesn't exist - this is the bug
          fail('BUG CONFIRMED: mentionsEnabled property does not exist on RichTextEditingController. '
              'Error: $e');
        }
      });

      test('controller should have mentionsEnabled property that returns false when inline code is active', () {
        controller.toggleFormat(FormatType.inlineCode);
        
        try {
          final dynamic dynamicController = controller;
          final mentionsEnabled = dynamicController.mentionsEnabled as bool;
          expect(mentionsEnabled, isFalse,
              reason: 'Mentions should be disabled when inline code is active');
        } catch (e) {
          fail('BUG CONFIRMED: mentionsEnabled property does not exist. Error: $e');
        }
      });
    });


    // =========================================================================
    // BUG CONDITION: Mentions Should Be Enabled in Lists/Quote
    // Validates: Requirements 1.7
    // 
    // EXPECTED: mentionsEnabled should return true when ordered list, 
    // bullet list, or quote block is active
    // =========================================================================
    group('BUG: Mentions Not Properly Enabled in Lists/Quote', () {
      test('mentionsEnabled should be true when ordered list is active', () {
        controller.text = 'test';
        controller.selection = const TextSelection.collapsed(offset: 4);
        controller.toggleFormat(FormatType.orderedList);
        
        try {
          final dynamic dynamicController = controller;
          final mentionsEnabled = dynamicController.mentionsEnabled as bool;
          expect(mentionsEnabled, isTrue,
              reason: 'Mentions should be enabled when ordered list is active');
        } catch (e) {
          fail('BUG CONFIRMED: mentionsEnabled property does not exist. Error: $e');
        }
      });

      test('mentionsEnabled should be true when bullet list is active', () {
        controller.text = 'test';
        controller.selection = const TextSelection.collapsed(offset: 4);
        controller.toggleFormat(FormatType.bulletList);
        
        try {
          final dynamic dynamicController = controller;
          final mentionsEnabled = dynamicController.mentionsEnabled as bool;
          expect(mentionsEnabled, isTrue,
              reason: 'Mentions should be enabled when bullet list is active');
        } catch (e) {
          fail('BUG CONFIRMED: mentionsEnabled property does not exist. Error: $e');
        }
      });

      test('mentionsEnabled should be true when blockquote is active', () {
        controller.text = 'test';
        controller.selection = const TextSelection.collapsed(offset: 4);
        controller.toggleFormat(FormatType.blockquote);
        
        try {
          final dynamic dynamicController = controller;
          final mentionsEnabled = dynamicController.mentionsEnabled as bool;
          expect(mentionsEnabled, isTrue,
              reason: 'Mentions should be enabled when blockquote is active');
        } catch (e) {
          fail('BUG CONFIRMED: mentionsEnabled property does not exist. Error: $e');
        }
      });
    });


    // =========================================================================
    // BUG CONDITION: Double-Enter Does Not Exit List
    // Validates: Requirements 1.22
    // 
    // EXPECTED: exitOnDoubleEnter() method should exist and properly exit
    // ordered/bullet lists when enter is pressed twice on empty item
    // =========================================================================
    group('BUG: Double-Enter Does Not Exit List', () {
      test('exitOnDoubleEnter method should exist', () {
        try {
          final dynamic dynamicController = controller;
          // Try to call the method
          dynamicController.exitOnDoubleEnter();
          // If we get here, method exists
        } catch (e) {
          if (e.toString().contains('NoSuchMethodError') || 
              e.toString().contains('exitOnDoubleEnter')) {
            fail('BUG CONFIRMED: exitOnDoubleEnter() method does not exist. Error: $e');
          }
          // Other errors might be acceptable (e.g., method exists but throws due to state)
        }
      });
    });

    // =========================================================================
    // BUG CONDITION: Triple-Enter Does Not Exit Code/Quote Block
    // Validates: Requirements 1.23, 1.24
    // 
    // EXPECTED: exitOnTripleEnter() method should exist and properly exit
    // code blocks and quote blocks when enter is pressed three times
    // =========================================================================
    group('BUG: Triple-Enter Does Not Exit Code/Quote Block', () {
      test('exitOnTripleEnter method should exist', () {
        try {
          final dynamic dynamicController = controller;
          // Try to call the method
          dynamicController.exitOnTripleEnter();
          // If we get here, method exists
        } catch (e) {
          if (e.toString().contains('NoSuchMethodError') || 
              e.toString().contains('exitOnTripleEnter')) {
            fail('BUG CONFIRMED: exitOnTripleEnter() method does not exist. Error: $e');
          }
        }
      });
    });


    // =========================================================================
    // VERIFIED WORKING: Code Block Replacement on Block Switch
    // These tests PASS - the functionality already exists
    // =========================================================================
    group('Code Block Replacement on Block Switch (VERIFIED WORKING)', () {
      test('clicking ordered list when code block is active replaces code block', () {
        controller.toggleFormat(FormatType.codeBlock);
        expect(controller.activeFormats.contains(FormatType.codeBlock), isTrue);

        controller.toggleFormat(FormatType.orderedList);

        expect(controller.activeFormats.contains(FormatType.codeBlock), isFalse);
        expect(controller.activeFormats.contains(FormatType.orderedList), isTrue);
      });

      test('clicking bullet list when code block is active replaces code block', () {
        controller.toggleFormat(FormatType.codeBlock);
        expect(controller.activeFormats.contains(FormatType.codeBlock), isTrue);

        controller.toggleFormat(FormatType.bulletList);

        expect(controller.activeFormats.contains(FormatType.codeBlock), isFalse);
        expect(controller.activeFormats.contains(FormatType.bulletList), isTrue);
      });
    });

    // =========================================================================
    // VERIFIED WORKING: Code Block Ignores Inline Format Commands
    // These tests PASS - the functionality already exists
    // =========================================================================
    group('Code Block Ignores Inline Format Commands (VERIFIED WORKING)', () {
      test('toggling bold when code block is active has no effect', () {
        controller.toggleFormat(FormatType.codeBlock);
        controller.toggleFormat(FormatType.bold);
        expect(controller.activeFormats.contains(FormatType.bold), isFalse);
      });

      test('toggling italic when code block is active has no effect', () {
        controller.toggleFormat(FormatType.codeBlock);
        controller.toggleFormat(FormatType.italic);
        expect(controller.activeFormats.contains(FormatType.italic), isFalse);
      });
    });

    // =========================================================================
    // VERIFIED WORKING: Link Insertion with Selected Text
    // Validates: Requirements 2.11 (paste-to-link underlying functionality)
    // 
    // These tests verify that the insertLink method works correctly for
    // converting selected text to links. The paste-to-link feature uses
    // similar logic internally.
    // =========================================================================
    group('Link Insertion with Selected Text (VERIFIED WORKING)', () {
      test('insertLink creates link span for selected text', () {
        controller.text = 'click here for more info';
        // Select "click here"
        controller.selection = const TextSelection(baseOffset: 0, extentOffset: 10);
        
        controller.insertLink(displayText: 'click here', url: 'https://example.com');
        
        // Verify a link span was created
        final spans = controller.spans;
        expect(spans.isNotEmpty, isTrue, reason: 'A link span should be created');
        
        final linkSpan = spans.firstWhere(
          (s) => s.formats.contains(FormatType.link),
          orElse: () => throw Exception('No link span found'),
        );
        
        expect(linkSpan.url, equals('https://example.com'));
      });

      test('insertLink replaces selected text with link', () {
        controller.text = 'visit our website today';
        // Select "website"
        controller.selection = const TextSelection(baseOffset: 10, extentOffset: 17);
        
        controller.insertLink(displayText: 'website', url: 'https://example.com');
        
        final spans = controller.spans;
        final linkSpan = spans.firstWhere(
          (s) => s.formats.contains(FormatType.link),
          orElse: () => throw Exception('No link span found'),
        );
        
        expect(linkSpan.url, equals('https://example.com'));
      });

      test('insertLink at cursor position without selection', () {
        controller.text = 'some text';
        controller.selection = const TextSelection.collapsed(offset: 5);
        
        controller.insertLink(displayText: 'link', url: 'https://example.com');
        
        // Verify a link span was created
        final linkSpans = controller.spans.where(
          (s) => s.formats.contains(FormatType.link),
        );
        
        expect(linkSpans.isNotEmpty, isTrue,
            reason: 'A link span should be created at cursor position');
      });
    });
  });
}
