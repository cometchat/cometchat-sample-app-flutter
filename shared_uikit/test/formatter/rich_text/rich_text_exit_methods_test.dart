import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Unit tests for exitOnDoubleEnter() and exitOnTripleEnter() methods.
///
/// **Validates: Requirements 2.22, 2.23, 2.24, 2.25**
void main() {
  group('exitOnDoubleEnter - List Exit Pattern', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('returns false when text is empty', () {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);
      
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('returns false when not on a list item', () {
      controller.text = 'regular text';
      controller.selection = const TextSelection.collapsed(offset: 12);
      
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('returns false on first enter on empty bullet list item', () {
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call - should not exit yet
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('returns true on second enter on empty bullet list item', () {
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isTrue);
    });

    test('removes bullet marker on double-enter exit', () {
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit and remove marker
      controller.exitOnDoubleEnter();
      
      // Marker should be removed
      expect(controller.text, equals(''));
    });

    test('returns false on first enter on empty ordered list item', () {
      controller.text = '1. ';
      controller.selection = const TextSelection.collapsed(offset: 3);
      
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('returns true on second enter on empty ordered list item', () {
      controller.text = '1. ';
      controller.selection = const TextSelection.collapsed(offset: 3);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isTrue);
    });

    test('removes ordered list marker on double-enter exit', () {
      controller.text = '1. ';
      controller.selection = const TextSelection.collapsed(offset: 3);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit and remove marker
      controller.exitOnDoubleEnter();
      
      // Marker should be removed
      expect(controller.text, equals(''));
    });

    test('returns false when list item has content', () {
      controller.text = '- some content';
      controller.selection = const TextSelection.collapsed(offset: 14);
      
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('resets counter when resetConsecutiveEnterCount is called', () {
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Reset counter
      controller.resetConsecutiveEnterCount();
      
      // Second call after reset - should not exit
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });

    test('handles nested bullet list in blockquote', () {
      controller.text = '> - ';
      controller.selection = const TextSelection.collapsed(offset: 4);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit list but keep blockquote
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isTrue);
      expect(controller.text, equals('> '));
    });

    test('handles nested ordered list in blockquote', () {
      controller.text = '> 1. ';
      controller.selection = const TextSelection.collapsed(offset: 5);
      
      // First call
      controller.exitOnDoubleEnter();
      
      // Second call - should exit list but keep blockquote
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isTrue);
      expect(controller.text, equals('> '));
    });
  });

  group('exitOnTripleEnter - Code/Quote Block Exit Pattern', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('returns false when text is empty', () {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);
      
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('returns false when not in code block or blockquote', () {
      controller.text = 'regular text';
      controller.selection = const TextSelection.collapsed(offset: 12);
      
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('returns false on first enter on empty blockquote line', () {
      controller.text = '> ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('returns false on second enter on empty blockquote line', () {
      controller.text = '> ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call
      controller.exitOnTripleEnter();
      
      // Second call - should not exit yet
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('returns true on third enter on empty blockquote line', () {
      controller.text = '> ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call
      controller.exitOnTripleEnter();
      
      // Second call
      controller.exitOnTripleEnter();
      
      // Third call - should exit
      final result = controller.exitOnTripleEnter();
      
      expect(result, isTrue);
    });

    test('returns false when blockquote line has content', () {
      controller.text = '> some content';
      controller.selection = const TextSelection.collapsed(offset: 14);
      
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('resets counter when resetConsecutiveEnterCount is called', () {
      controller.text = '> ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First two calls
      controller.exitOnTripleEnter();
      controller.exitOnTripleEnter();
      
      // Reset counter
      controller.resetConsecutiveEnterCount();
      
      // Third call after reset - should not exit
      final result = controller.exitOnTripleEnter();
      
      expect(result, isFalse);
    });

    test('handles code block with empty line', () {
      // Simulate being inside a code block
      controller.text = '```\n';
      controller.selection = const TextSelection.collapsed(offset: 4);
      controller.toggleFormat(FormatType.codeBlock);
      
      // First call
      controller.exitOnTripleEnter();
      
      // Second call
      controller.exitOnTripleEnter();
      
      // Third call - should exit
      final result = controller.exitOnTripleEnter();
      
      expect(result, isTrue);
    });
  });

  group('Consecutive Enter Counter Reset', () {
    late RichTextEditingController controller;

    setUp(() {
      controller = RichTextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('counter resets when moving to non-empty list item', () {
      // Start with empty list item
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call on empty item
      controller.exitOnDoubleEnter();
      
      // Change to non-empty item
      controller.text = '- content';
      controller.selection = const TextSelection.collapsed(offset: 9);
      
      // Call on non-empty item - should reset counter
      controller.exitOnDoubleEnter();
      
      // Back to empty item
      controller.text = '- ';
      controller.selection = const TextSelection.collapsed(offset: 2);
      
      // First call after reset - should not exit
      final result = controller.exitOnDoubleEnter();
      
      expect(result, isFalse);
    });
  });
}
