import 'package:flutter/painting.dart';

import '../../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_type.dart';

/// Helper class for format markers
class _FormatMarkerPair {
  final String opening;
  final String closing;

  const _FormatMarkerPair(this.opening, this.closing);
}

/// Represents a span of text with formatting attributes
class RichTextSpan {
  final int start;
  final int end;
  final Set<FormatType> formats;

  /// Optional metadata for formats that need extra data (e.g., link URL)
  final Map<String, String>? metadata;

  const RichTextSpan({
    required this.start,
    required this.end,
    required this.formats,
    this.metadata,
  });

  RichTextSpan copyWith({
    int? start,
    int? end,
    Set<FormatType>? formats,
    Map<String, String>? metadata,
  }) {
    return RichTextSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      formats: formats ?? this.formats,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'RichTextSpan($start-$end, $formats${metadata != null ? ', meta=$metadata' : ''})';
}

/// An arbitrary inline style applied to a text range (Trailing Toolbar
/// Buttons DD §8.3 — the enabler for consumer styles like a colour picker).
///
/// Deliberately separate from [RichTextSpan]: format spans are a closed
/// [FormatType] vocabulary with markdown serialization; a styled range
/// carries an open [TextStyle] payload, is composer-local, and is ignored
/// by [RichTextSpanManager.toMarkdown] by design (cross-surface rendering
/// is out of the DD's scope).
class InlineStyleRange {
  final int start;
  final int end;
  final TextStyle style;

  /// Consumer-chosen identity (e.g. `'text-color'`) — [removeInlineStyle]
  /// with the same id removes only that consumer's styling from the range,
  /// leaving other ids intact.
  final String id;

  const InlineStyleRange({
    required this.start,
    required this.end,
    required this.style,
    required this.id,
  });

  InlineStyleRange copyWith({int? start, int? end, TextStyle? style}) {
    return InlineStyleRange(
      start: start ?? this.start,
      end: end ?? this.end,
      style: style ?? this.style,
      id: id,
    );
  }

  @override
  String toString() => 'InlineStyleRange($start-$end, id=$id)';
}

/// Manages formatting spans for rich text editing
class RichTextSpanManager {
  final List<RichTextSpan> _spans = [];

  List<RichTextSpan> get spans => List.unmodifiable(_spans);

  final List<InlineStyleRange> _styleRanges = [];

  /// Consumer-applied inline styles (DD §8.3). Unlike [spans], these carry a
  /// full [TextStyle] and never serialize to markdown.
  List<InlineStyleRange> get styleRanges => List.unmodifiable(_styleRanges);

  /// Add formatting to a range
  void addFormat(
    int start,
    int end,
    FormatType format, {
    Map<String, String>? metadata,
  }) {
    if (start >= end) return;

    // Find overlapping spans
    final overlapping = _spans
        .where((s) => (s.start < end && s.end > start))
        .toList();

    if (overlapping.isEmpty) {
      // No overlap - just add new span
      _spans.add(
        RichTextSpan(
          start: start,
          end: end,
          formats: {format},
          metadata: metadata,
        ),
      );
    } else {
      // Handle overlapping spans - need to split and merge properly
      final toRemove = <RichTextSpan>[];
      final toAdd = <RichTextSpan>[];

      // Merge metadata from new format with existing span metadata
      Map<String, String>? mergeMetadata(
        Map<String, String>? existing,
        Map<String, String>? incoming,
      ) {
        if (existing == null && incoming == null) return null;
        if (existing == null) return incoming;
        if (incoming == null) return existing;
        return {...existing, ...incoming};
      }

      for (final span in overlapping) {
        toRemove.add(span);

        // Part before the new format range (keeps original formats + metadata)
        if (span.start < start) {
          toAdd.add(
            RichTextSpan(
              start: span.start,
              end: start,
              formats: Set.from(span.formats),
              metadata: span.metadata,
            ),
          );
        }

        // Part after the new format range (keeps original formats + metadata)
        if (span.end > end) {
          toAdd.add(
            RichTextSpan(
              start: end,
              end: span.end,
              formats: Set.from(span.formats),
              metadata: span.metadata,
            ),
          );
        }

        // Overlapping part gets the new format added + merged metadata
        final overlapStart = start > span.start ? start : span.start;
        final overlapEnd = end < span.end ? end : span.end;
        toAdd.add(
          RichTextSpan(
            start: overlapStart,
            end: overlapEnd,
            formats: {...span.formats, format},
            metadata: mergeMetadata(span.metadata, metadata),
          ),
        );
      }

      // Add the part of the new range that doesn't overlap with any existing span
      // Find gaps in the overlapping spans
      overlapping.sort((a, b) => a.start.compareTo(b.start));
      int currentPos = start;
      for (final span in overlapping) {
        if (currentPos < span.start) {
          // Gap before this span
          toAdd.add(
            RichTextSpan(
              start: currentPos,
              end: span.start,
              formats: {format},
              metadata: metadata,
            ),
          );
        }
        currentPos = span.end > currentPos ? span.end : currentPos;
      }
      // Gap after all spans
      if (currentPos < end) {
        toAdd.add(
          RichTextSpan(
            start: currentPos,
            end: end,
            formats: {format},
            metadata: metadata,
          ),
        );
      }

      _spans.removeWhere((s) => toRemove.contains(s));
      _spans.addAll(toAdd);
    }

    _normalizeSpans();
  }

  /// Remove formatting from a range
  void removeFormat(int start, int end, FormatType format) {
    final toRemove = <RichTextSpan>[];
    final toAdd = <RichTextSpan>[];

    for (final span in _spans) {
      if (span.start < end &&
          span.end > start &&
          span.formats.contains(format)) {
        toRemove.add(span);

        final newFormats = {...span.formats}..remove(format);
        // If removing link format, clear link metadata from remaining formats
        final newMetadata = format == FormatType.link ? null : span.metadata;

        // Split span if needed — preserve metadata on parts that keep the format
        if (span.start < start) {
          toAdd.add(
            RichTextSpan(
              start: span.start,
              end: start,
              formats: span.formats,
              metadata: span.metadata,
            ),
          );
        }
        if (span.end > end) {
          toAdd.add(
            RichTextSpan(
              start: end,
              end: span.end,
              formats: span.formats,
              metadata: span.metadata,
            ),
          );
        }
        if (newFormats.isNotEmpty) {
          final overlapStart = start > span.start ? start : span.start;
          final overlapEnd = end < span.end ? end : span.end;
          toAdd.add(
            RichTextSpan(
              start: overlapStart,
              end: overlapEnd,
              formats: newFormats,
              metadata: newMetadata,
            ),
          );
        }
      }
    }

    _spans.removeWhere((s) => toRemove.contains(s));
    _spans.addAll(toAdd);
    _normalizeSpans();
  }

  /// Get formats active at a position
  Set<FormatType> getFormatsAt(int position) {
    final result = <FormatType>{};
    for (final span in _spans) {
      if (position >= span.start && position < span.end) {
        result.addAll(span.formats);
      }
    }
    return result;
  }

  /// Get formats that are active across the entire [start, end) range.
  /// Returns the intersection of formats at every position in the range,
  /// so only formats that cover the whole selection are returned.
  Set<FormatType> getFormatsInRange(int start, int end) {
    if (start >= end || _spans.isEmpty) return {};
    // Collect spans that fully cover the selection range
    final result = <FormatType>{};
    for (final span in _spans) {
      if (span.start <= start && span.end >= end) {
        result.addAll(span.formats);
      }
    }
    return result;
  }

  /// Get metadata at a position (e.g., link URL)
  Map<String, String>? getMetadataAt(int position) {
    for (final span in _spans) {
      if (position >= span.start &&
          position < span.end &&
          span.metadata != null) {
        return span.metadata;
      }
    }
    return null;
  }

  /// Get the link span covering [position], or null if none.
  RichTextSpan? getLinkSpanAt(int position) {
    for (final span in _spans) {
      if (position >= span.start &&
          position < span.end &&
          span.formats.contains(FormatType.link)) {
        return span;
      }
    }
    return null;
  }

  /// Applies an inline [style] to [start]..[end] under [id].
  ///
  /// Same-id overlaps are carved out first, so re-applying (e.g. picking a
  /// second colour over part of an old one) replaces rather than stacks;
  /// different ids coexist and compose in application order.
  void applyInlineStyle(
    int start,
    int end,
    TextStyle style, {
    required String id,
  }) {
    if (start >= end) return;
    removeInlineStyle(start, end, id: id);
    _styleRanges.add(
      InlineStyleRange(start: start, end: end, style: style, id: id),
    );
    _styleRanges.sort((a, b) => a.start.compareTo(b.start));
  }

  /// Removes [id]-styling from [start]..[end], splitting ranges that
  /// straddle the boundary. Other ids are untouched.
  void removeInlineStyle(int start, int end, {required String id}) {
    if (start >= end) return;
    final next = <InlineStyleRange>[];
    for (final range in _styleRanges) {
      if (range.id != id || range.end <= start || range.start >= end) {
        next.add(range);
        continue;
      }
      if (range.start < start) {
        next.add(range.copyWith(end: start));
      }
      if (range.end > end) {
        next.add(range.copyWith(start: end));
      }
    }
    _styleRanges
      ..clear()
      ..addAll(next);
  }

  /// The style ranges under [id] that intersect [start]..[end].
  List<InlineStyleRange> stylesInRange(int start, int end, {String? id}) {
    return _styleRanges
        .where(
          (range) =>
              range.start < end &&
              range.end > start &&
              (id == null || range.id == id),
        )
        .toList();
  }

  /// Adjust spans when text is inserted
  void onTextInserted(int position, int length) {
    for (int i = 0; i < _spans.length; i++) {
      final span = _spans[i];
      if (span.start >= position) {
        _spans[i] = span.copyWith(
          start: span.start + length,
          end: span.end + length,
        );
      } else if (span.end > position) {
        _spans[i] = span.copyWith(end: span.end + length);
      }
    }
    for (int i = 0; i < _styleRanges.length; i++) {
      final range = _styleRanges[i];
      if (range.start >= position) {
        _styleRanges[i] = range.copyWith(
          start: range.start + length,
          end: range.end + length,
        );
      } else if (range.end > position) {
        _styleRanges[i] = range.copyWith(end: range.end + length);
      }
    }
  }

  /// Adjust spans when text is deleted
  void onTextDeleted(int start, int end) {
    final length = end - start;
    final toRemove = <RichTextSpan>[];

    for (int i = 0; i < _spans.length; i++) {
      final span = _spans[i];

      if (span.end <= start) {
        // Span is before deletion - no change
        continue;
      } else if (span.start >= end) {
        // Span is after deletion - shift left
        _spans[i] = span.copyWith(
          start: span.start - length,
          end: span.end - length,
        );
      } else if (span.start >= start && span.end <= end) {
        // Span is completely within deletion - remove
        toRemove.add(span);
      } else if (span.start < start && span.end > end) {
        // Deletion is within span - shrink
        _spans[i] = span.copyWith(end: span.end - length);
      } else if (span.start < start) {
        // Deletion overlaps end of span
        _spans[i] = span.copyWith(end: start);
      } else {
        // Deletion overlaps start of span
        _spans[i] = span.copyWith(start: start, end: span.end - length);
      }
    }

    _spans.removeWhere((s) => toRemove.contains(s) || s.start >= s.end);

    for (int i = 0; i < _styleRanges.length; i++) {
      final range = _styleRanges[i];
      if (range.end <= start) {
        continue;
      } else if (range.start >= end) {
        _styleRanges[i] = range.copyWith(
          start: range.start - length,
          end: range.end - length,
        );
      } else if (range.start < start && range.end > end) {
        _styleRanges[i] = range.copyWith(end: range.end - length);
      } else if (range.start < start) {
        _styleRanges[i] = range.copyWith(end: start);
      } else {
        _styleRanges[i] = range.copyWith(start: start, end: range.end - length);
      }
    }
    _styleRanges.removeWhere((r) => r.start >= r.end);
  }

  /// Convert plain text to markdown
  String toMarkdown(String plainText) {
    if (_spans.isEmpty && _styleRanges.isEmpty) return plainText;

    // Sort spans by start position
    final sortedSpans = [..._spans]..sort((a, b) => a.start.compareTo(b.start));

    final buffer = StringBuffer();
    int currentPos = 0;

    for (final span in sortedSpans) {
      // Add text before this span
      if (span.start > currentPos) {
        buffer.write(plainText.substring(currentPos, span.start));
      }

      // Add formatted text
      final spanText = plainText.substring(
        span.start,
        span.end.clamp(0, plainText.length),
      );
      buffer.write(
        _wrapWithMarkers(spanText, span.formats, metadata: span.metadata),
      );

      currentPos = span.end;
    }

    // Add remaining text
    if (currentPos < plainText.length) {
      buffer.write(plainText.substring(currentPos));
    }

    return _wrapColorTags(buffer.toString(), plainText);
  }

  /// Wraps coloured ranges in `<color=#RRGGBB>…</color>` tags.
  ///
  /// Applied AFTER the format markers so the tags sit outside them
  /// (`<color=#FF0000>**bold**</color>`) — the bubble's markdown formatter
  /// strips the colour tag and then parses the inner markers as usual.
  ///
  /// Offsets are recomputed against the marked-up string: inserting `**`
  /// shifts everything after it, so a colour range recorded against the
  /// plain text would land in the wrong place. The shift for a given plain
  /// offset is the total marker length inserted before it.
  String _wrapColorTags(String markedUp, String plainText) {
    final coloured =
        _styleRanges.where((range) => range.style.color != null).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    if (coloured.isEmpty) return markedUp;

    // Map plain-text offsets → marked-up offsets by replaying the same span
    // walk that produced [markedUp].
    //
    // Start and end use different boundary rules on purpose: a marker
    // inserted AT the colour's start belongs inside the tag (so the tag
    // wraps `**bold**` rather than splitting it), while a marker inserted at
    // the colour's end must be swallowed by it. Hence strict `<` for start
    // and `<=` for end.
    final shiftStart = _buildOffsetMap(plainText, inclusive: false);
    final shiftEnd = _buildOffsetMap(plainText, inclusive: true);

    final buffer = StringBuffer();
    var cursor = 0;
    for (final range in coloured) {
      final start = shiftStart(range.start);
      final end = shiftEnd(range.end);
      if (start < cursor || end > markedUp.length || end <= start) continue;
      buffer.write(markedUp.substring(cursor, start));
      buffer.write('<color=${_hex(range.style.color!)}>');
      buffer.write(markedUp.substring(start, end));
      buffer.write('</color>');
      cursor = end;
    }
    if (cursor < markedUp.length) {
      buffer.write(markedUp.substring(cursor));
    }
    return buffer.toString();
  }

  /// Builds a plain-offset → marked-up-offset translator by walking the same
  /// spans [toMarkdown] wrapped, accumulating each opening/closing marker's
  /// length at the position it was inserted.
  int Function(int) _buildOffsetMap(
    String plainText, {
    required bool inclusive,
  }) {
    final insertions = <MapEntry<int, int>>[]; // (plainOffset, addedLength)
    final sortedSpans = [..._spans]..sort((a, b) => a.start.compareTo(b.start));
    for (final span in sortedSpans) {
      final spanText = plainText.substring(
        span.start,
        span.end.clamp(0, plainText.length),
      );
      final wrapped = _wrapWithMarkers(
        spanText,
        span.formats,
        metadata: span.metadata,
      );
      final added = wrapped.length - spanText.length;
      if (added == 0) continue;
      // Opening markers land at the span start; the rest (closing markers,
      // link URL) lands at the span end.
      final opening = wrapped.indexOf(spanText);
      final openingLen = opening < 0 ? added : opening;
      insertions.add(MapEntry(span.start, openingLen));
      if (added - openingLen > 0) {
        insertions.add(MapEntry(span.end, added - openingLen));
      }
    }
    return (int plainOffset) {
      var shifted = plainOffset;
      for (final insertion in insertions) {
        final applies = inclusive
            ? insertion.key <= plainOffset
            : insertion.key < plainOffset;
        if (applies) shifted += insertion.value;
      }
      return shifted;
    };
  }

  static String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  String _wrapWithMarkers(
    String text,
    Set<FormatType> formats, {
    Map<String, String>? metadata,
  }) {
    // Check if this is a code block - code blocks should wrap the entire text
    // including newlines, not wrap each line separately
    if (formats.contains(FormatType.codeBlock)) {
      return _wrapCodeBlock(text, formats, metadata: metadata);
    }

    // Handle newlines - close markers before newline, reopen after
    // This is correct for inline formats like bold, italic, etc.
    if (text.contains('\n')) {
      final lines = text.split('\n');
      final wrappedLines = lines.map((line) {
        if (line.isEmpty) return line;
        return _wrapSingleLine(line, formats, metadata: metadata);
      }).toList();
      return wrappedLines.join('\n');
    }

    return _wrapSingleLine(text, formats, metadata: metadata);
  }

  /// Wrap text as a code block - wraps entire text with ``` markers
  String _wrapCodeBlock(
    String text,
    Set<FormatType> formats, {
    Map<String, String>? metadata,
  }) {
    // Remove codeBlock from formats to apply other formats separately
    final otherFormats = formats
        .where((f) => f != FormatType.codeBlock)
        .toSet();

    // Apply other formats to each line if any
    String content = text;
    if (otherFormats.isNotEmpty) {
      if (text.contains('\n')) {
        final lines = text.split('\n');
        final wrappedLines = lines.map((line) {
          if (line.isEmpty) return line;
          return _wrapSingleLine(line, otherFormats, metadata: metadata);
        }).toList();
        content = wrappedLines.join('\n');
      } else {
        content = _wrapSingleLine(text, otherFormats, metadata: metadata);
      }
    }

    // Wrap the entire content with code block markers
    return '```\n$content\n```';
  }

  String _wrapSingleLine(
    String text,
    Set<FormatType> formats, {
    Map<String, String>? metadata,
  }) {
    if (text.isEmpty) return text;

    String result = text;

    // Wrap formats from innermost to outermost. Italic (_) must be the
    // innermost marker so that two adjacent spans with overlapping
    // format sets don't collide at the boundary.
    //
    // Example without this ordering (bug ENG-34742):
    //   span [0,4) {italic}       → "_uhku_"
    //   span [4,12) {italic,bold} → "_**oiuhiouh**_"
    //   concatenated              → "_uhku__**oiuhiouh**_"
    // The "__" boundary is misread by the receiver as a broken
    // double-underscore pattern and the outer "_"s render as literal
    // characters, leaving only the inner "**...**" bold.
    //
    // With italic innermost the same spans serialize to:
    //   "_uhku_" + "**_oiuhiouh_**" = "_uhku_**_oiuhiouh_**"
    // which parses cleanly: italic(uhku) + bold+italic(oiuhiouh).
    final sortedFormats = formats.toList()
      ..sort((a, b) => _wrapPriority(a).compareTo(_wrapPriority(b)));

    for (final format in sortedFormats) {
      final markers = _getMarkers(format, metadata: metadata);
      result = '${markers.opening}$result${markers.closing}';
    }

    return result;
  }

  /// Wrap priority — lower values are applied FIRST (innermost markers),
  /// higher values are applied LAST (outermost markers).
  ///
  /// Italic must be innermost so adjacent `_` markers never touch each
  /// other when spans concatenate. See [_wrapSingleLine] for details.
  int _wrapPriority(FormatType format) {
    switch (format) {
      case FormatType.italic:
        return 0;
      case FormatType.inlineCode:
        return 1;
      case FormatType.strikethrough:
        return 2;
      case FormatType.underline:
        return 3;
      case FormatType.bold:
        return 4;
      case FormatType.link:
        return 5;
      default:
        return 100;
    }
  }

  _FormatMarkerPair _getMarkers(
    FormatType format, {
    Map<String, String>? metadata,
  }) {
    switch (format) {
      case FormatType.bold:
        return const _FormatMarkerPair('**', '**');
      case FormatType.italic:
        return const _FormatMarkerPair('_', '_');
      case FormatType.strikethrough:
        return const _FormatMarkerPair('~~', '~~');
      case FormatType.inlineCode:
        return const _FormatMarkerPair('`', '`');
      case FormatType.underline:
        return const _FormatMarkerPair('<u>', '</u>');
      case FormatType.codeBlock:
        return const _FormatMarkerPair('```\n', '\n```');
      case FormatType.link:
        final url = metadata?['url'] ?? 'url';
        return _FormatMarkerPair('[', ']($url)');
      case FormatType.bulletList:
        return const _FormatMarkerPair('- ', '');
      case FormatType.orderedList:
        return const _FormatMarkerPair('1. ', '');
      case FormatType.blockquote:
        return const _FormatMarkerPair('> ', '');
    }
  }

  void _normalizeSpans() {
    // Remove empty spans
    _spans.removeWhere((s) => s.start >= s.end || s.formats.isEmpty);

    // Sort by start position
    _spans.sort((a, b) => a.start.compareTo(b.start));

    // Merge adjacent spans with identical formats
    if (_spans.length < 2) return;

    final merged = <RichTextSpan>[];
    RichTextSpan? current = _spans.first;

    for (int i = 1; i < _spans.length; i++) {
      final next = _spans[i];

      // Check if spans are adjacent (or overlapping) and have same formats and metadata
      if (current!.end >= next.start &&
          _sameFormats(current.formats, next.formats) &&
          _sameMetadata(current.metadata, next.metadata)) {
        // Merge: extend current span to include next
        current = current.copyWith(
          end: next.end > current.end ? next.end : current.end,
        );
      } else {
        // Not mergeable, save current and move to next
        merged.add(current);
        current = next;
      }
    }

    // Don't forget the last span
    if (current != null) {
      merged.add(current);
    }

    _spans.clear();
    _spans.addAll(merged);
  }

  /// Check if two format sets are identical
  bool _sameFormats(Set<FormatType> a, Set<FormatType> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  /// Check if two metadata maps are identical
  bool _sameMetadata(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void clear() {
    _spans.clear();
    _styleRanges.clear();
  }
}
