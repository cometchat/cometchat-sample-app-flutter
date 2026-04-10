import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for strikethrough text using ~~text~~ syntax.
///
/// This formatter handles strikethrough formatting in Markdown style:
/// - Pattern: `~~text~~`
/// - Opening marker: `~~`
/// - Closing marker: `~~`
/// - Placeholder: `strikethrough text`
///
/// Examples:
/// - `~~hello~~` renders as strikethrough "hello"
/// - Applying strikethrough to "world" produces `~~world~~`
/// - Applying strikethrough with no selection inserts `~~strikethrough text~~`
class StrikethroughFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'~~(.+?)~~');

  @override
  FormatType get formatType => FormatType.strikethrough;

  @override
  String get openingMarker => '~~';

  @override
  String get closingMarker => '~~';

  @override
  String get placeholderText => 'strikethrough text';

  @override
  FormatterResult applyFormat({
    required String text,
    required TextSelection selection,
    Map<String, dynamic>? metadata,
  }) {
    if (selection.isCollapsed) {
      // No selection - insert placeholder with markers
      final insertText = '$openingMarker$placeholderText$closingMarker';
      final newText = text.substring(0, selection.start) +
          insertText +
          text.substring(selection.end);

      // Position cursor to select the placeholder text
      final newCursorStart = selection.start + openingMarker.length;
      final newCursorEnd = newCursorStart + placeholderText.length;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorStart,
        newCursorEnd: newCursorEnd,
      );
    } else {
      // Check if selection is already wrapped with strikethrough markers
      final beforeSelection = selection.start >= openingMarker.length
          ? text.substring(
              selection.start - openingMarker.length, selection.start)
          : '';
      final afterSelection = selection.end + closingMarker.length <= text.length
          ? text.substring(selection.end, selection.end + closingMarker.length)
          : '';

      if (beforeSelection == openingMarker && afterSelection == closingMarker) {
        // Remove strikethrough markers (toggle off)
        final newText = text.substring(0, selection.start - openingMarker.length) +
            text.substring(selection.start, selection.end) +
            text.substring(selection.end + closingMarker.length);

        final newCursorPos = selection.end - openingMarker.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      } else {
        // Check for mention ranges in metadata
        final mentionRanges = _getOverlappingMentionRanges(
          metadata,
          selection.start,
          selection.end,
        );

        if (mentionRanges.isNotEmpty) {
          // Mention-aware formatting: split around mentions, format only non-mention text
          return _applyFormatAroundMentions(
            text: text,
            selectionStart: selection.start,
            selectionEnd: selection.end,
            mentionRanges: mentionRanges,
          );
        }

        // Wrap selected text with strikethrough markers
        final selectedText = text.substring(selection.start, selection.end);
        final wrappedText = '$openingMarker$selectedText$closingMarker';
        final newText = text.substring(0, selection.start) +
            wrappedText +
            text.substring(selection.end);

        final newCursorPos = selection.start + wrappedText.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      }
    }
  }

  /// Extracts mention ranges from metadata that overlap with the given selection.
  List<Map<String, dynamic>> _getOverlappingMentionRanges(
    Map<String, dynamic>? metadata,
    int selStart,
    int selEnd,
  ) {
    if (metadata == null || !metadata.containsKey('mentionRanges')) {
      return [];
    }
    final ranges = metadata['mentionRanges'] as List<dynamic>;
    return ranges
        .cast<Map<String, dynamic>>()
        .where((r) {
          final mStart = r['start'] as int;
          final mEnd = r['end'] as int;
          return mStart < selEnd && mEnd > selStart;
        })
        .toList()
      ..sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
  }

  /// Applies formatting markers only to non-mention text segments within the selection.
  FormatterResult _applyFormatAroundMentions({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required List<Map<String, dynamic>> mentionRanges,
  }) {
    final segments = <_TextSegment>[];
    var cursor = selectionStart;

    for (final mention in mentionRanges) {
      final mStart = mention['start'] as int;
      final mEnd = mention['end'] as int;
      final effectiveStart = mStart < selectionStart ? selectionStart : mStart;
      final effectiveEnd = mEnd > selectionEnd ? selectionEnd : mEnd;

      if (cursor < effectiveStart) {
        segments.add(_TextSegment(start: cursor, end: effectiveStart, isMention: false));
      }
      segments.add(_TextSegment(start: effectiveStart, end: effectiveEnd, isMention: true));
      cursor = effectiveEnd;
    }

    if (cursor < selectionEnd) {
      segments.add(_TextSegment(start: cursor, end: selectionEnd, isMention: false));
    }

    final buffer = StringBuffer();
    buffer.write(text.substring(0, selectionStart));

    var addedMarkerLength = 0;
    for (final segment in segments) {
      final segmentText = text.substring(segment.start, segment.end);
      if (segment.isMention) {
        buffer.write(segmentText);
      } else {
        final trimmed = segmentText.trim();
        if (trimmed.isEmpty) {
          buffer.write(segmentText);
        } else {
          final leadingSpace = segmentText.substring(0, segmentText.indexOf(trimmed));
          final trailingSpace = segmentText.substring(segmentText.indexOf(trimmed) + trimmed.length);
          buffer.write(leadingSpace);
          buffer.write('$openingMarker$trimmed$closingMarker');
          buffer.write(trailingSpace);
          addedMarkerLength += openingMarker.length + closingMarker.length;
        }
      }
    }

    buffer.write(text.substring(selectionEnd));

    final newText = buffer.toString();
    final newCursorPos = selectionEnd + addedMarkerLength;

    return FormatterResult(
      newText: newText,
      newCursorStart: newCursorPos,
      newCursorEnd: newCursorPos,
    );
  }

  @override
  bool isActiveAt(String text, int position) {
    if (position < 0 || position > text.length) {
      return false;
    }

    // Check all matches to see if position is inside any strikethrough text
    for (final match in pattern.allMatches(text)) {
      // Check if position is within the match (including markers)
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }

    return false;
  }

  @override
  List<AttributedTextData> getAttributedText(String text) {
    final List<AttributedTextData> attributedTexts = [];
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      // Apply strikethrough attribute to the entire match (including markers)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'strikethrough': true,
          },
        ),
      );
    }

    return attributedTexts;
  }
}

/// Helper class representing a text segment within a selection.
class _TextSegment {
  final int start;
  final int end;
  final bool isMention;

  const _TextSegment({
    required this.start,
    required this.end,
    required this.isMention,
  });
}
