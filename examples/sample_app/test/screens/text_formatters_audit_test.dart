import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Source-code audit tests that verify all UIKit widgets in the master app
/// receive the full set of 5 text formatters:
///   1. CometChatMentionsFormatter
///   2. MarkdownTextFormatter
///   3. CometChatUrlFormatter
///   4. CometChatPhoneNumberFormatter
///   5. CometChatEmailFormatter
///
/// These tests read the actual Dart source files and check that every
/// widget constructor call that accepts `textFormatters:` includes all 5.
/// This catches regressions where a formatter is accidentally removed or
/// a new widget usage forgets to pass them.

const _requiredFormatters = [
  'CometChatMentionsFormatter',
  'MarkdownTextFormatter',
  'CometChatUrlFormatter',
  'CometChatPhoneNumberFormatter',
  'CometChatEmailFormatter',
];

/// Extracts all `textFormatters: [...]` blocks from source code.
/// Returns a list of (startIndex, formatterBlock) pairs.
List<_FormatterBlock> _extractFormatterBlocks(String source) {
  final blocks = <_FormatterBlock>[];
  final pattern = RegExp(r'textFormatters:\s*\[');
  for (final match in pattern.allMatches(source)) {
    final start = match.start;
    // Find the matching closing bracket
    var depth = 0;
    var blockStart = -1;
    for (var i = match.end - 1; i < source.length; i++) {
      if (source[i] == '[') {
        if (depth == 0) blockStart = i;
        depth++;
      } else if (source[i] == ']') {
        depth--;
        if (depth == 0) {
          blocks.add(_FormatterBlock(
            offset: start,
            content: source.substring(blockStart, i + 1),
            lineNumber: '\n'.allMatches(source.substring(0, start)).length + 1,
          ));
          break;
        }
      }
    }
  }
  return blocks;
}

class _FormatterBlock {
  final int offset;
  final String content;
  final int lineNumber;
  const _FormatterBlock({
    required this.offset,
    required this.content,
    required this.lineNumber,
  });
}

/// Returns the widget name preceding a textFormatters block by scanning
/// backwards from the offset to find the widget constructor call.
String _findWidgetName(String source, int offset) {
  // Scan backwards to find `CometChat...(\n` or similar widget constructor
  final preceding = source.substring(0, offset);
  final widgetPattern = RegExp(r'(CometChat\w+)\s*\(', multiLine: true);
  final matches = widgetPattern.allMatches(preceding).toList();
  if (matches.isEmpty) return 'Unknown';
  return matches.last.group(1) ?? 'Unknown';
}

void _verifyFile(String filePath, String screenName) {
  final file = File(filePath);
  if (!file.existsSync()) {
    fail('$filePath does not exist');
  }
  final source = file.readAsStringSync();
  final blocks = _extractFormatterBlocks(source);

  if (blocks.isEmpty) {
    fail('$screenName: No textFormatters: [...] blocks found in $filePath');
  }

  for (final block in blocks) {
    final widgetName = _findWidgetName(source, block.offset);
    for (final formatter in _requiredFormatters) {
      expect(
        block.content.contains(formatter),
        isTrue,
        reason: '$screenName → $widgetName (line ${block.lineNumber}): '
            'missing $formatter in textFormatters',
      );
    }
  }
}

void main() {
  group('Text formatters audit — all 5 formatters passed to every widget', () {
    test('home_screen.dart → CometChatConversations has all 5 formatters', () {
      _verifyFile(
        'lib/screens/home_screen.dart',
        'home_screen',
      );
    });

    test('messages_screen.dart → MessageList + Composer have all 5 formatters',
        () {
      _verifyFile(
        'lib/screens/messages_screen.dart',
        'messages_screen',
      );
    });

    test(
        'thread_screen.dart → MessageList + Composer + ThreadedHeader have all 5 formatters',
        () {
      _verifyFile(
        'lib/screens/thread_screen.dart',
        'thread_screen',
      );
    });
  });

  group('Text formatters audit — correct count per screen', () {
    test('home_screen has exactly 1 textFormatters block (Conversations)', () {
      final source = File('lib/screens/home_screen.dart').readAsStringSync();
      final blocks = _extractFormatterBlocks(source);
      expect(blocks.length, 1,
          reason: 'home_screen should have 1 textFormatters block');
    });

    test('messages_screen has exactly 2 textFormatters blocks (List + Composer)',
        () {
      final source =
          File('lib/screens/messages_screen.dart').readAsStringSync();
      final blocks = _extractFormatterBlocks(source);
      expect(blocks.length, 2,
          reason: 'messages_screen should have 2 textFormatters blocks');
    });

    test(
        'thread_screen has exactly 3 textFormatters blocks (List + Composer + ThreadedHeader)',
        () {
      final source = File('lib/screens/thread_screen.dart').readAsStringSync();
      final blocks = _extractFormatterBlocks(source);
      expect(blocks.length, 3,
          reason: 'thread_screen should have 3 textFormatters blocks');
    });
  });

  group('Text formatters audit — each block targets the right widget', () {
    test('messages_screen formatters are on MessageList and MessageComposer',
        () {
      final source =
          File('lib/screens/messages_screen.dart').readAsStringSync();
      final blocks = _extractFormatterBlocks(source);
      final widgetNames =
          blocks.map((b) => _findWidgetName(source, b.offset)).toList();
      expect(widgetNames, contains('CometChatMessageList'));
      expect(widgetNames, contains('CometChatMessageComposer'));
    });

    test(
        'thread_screen formatters are on MessageList, MessageComposer, and ThreadedHeader',
        () {
      final source = File('lib/screens/thread_screen.dart').readAsStringSync();
      final blocks = _extractFormatterBlocks(source);
      final widgetNames =
          blocks.map((b) => _findWidgetName(source, b.offset)).toList();
      expect(widgetNames, contains('CometChatMessageList'));
      expect(widgetNames, contains('CometChatMessageComposer'));
      expect(widgetNames, contains('CometChatThreadedHeader'));
    });
  });
}
