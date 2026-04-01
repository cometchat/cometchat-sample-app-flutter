import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Represents a span of text with associated formatting.
///
/// This class is used to track which portions of text have which formats
/// applied, enabling WYSIWYG-style rich text editing where the format
/// markers are hidden from the user but the formatting is visually applied.
class RichTextSpan {
  /// Creates a [RichTextSpan] with the specified range and formats.
  const RichTextSpan({
    required this.start,
    required this.end,
    required this.formats,
    this.url,
  });

  /// The start index of this span (inclusive).
  final int start;

  /// The end index of this span (exclusive).
  final int end;

  /// The set of formats applied to this span.
  final Set<FormatType> formats;

  /// The URL associated with this span (for link format).
  final String? url;

  /// Returns true if this span overlaps with the given range.
  bool overlaps(int rangeStart, int rangeEnd) {
    return start < rangeEnd && end > rangeStart;
  }

  /// Returns true if this span contains the given position.
  bool contains(int position) {
    return position >= start && position < end;
  }

  /// Returns a copy of this span with updated values.
  RichTextSpan copyWith({
    int? start,
    int? end,
    Set<FormatType>? formats,
    String? url,
  }) {
    return RichTextSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      formats: formats ?? this.formats,
      url: url ?? this.url,
    );
  }

  @override
  String toString() => 'RichTextSpan(start: $start, end: $end, formats: $formats, url: $url)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RichTextSpan &&
        other.start == start &&
        other.end == end &&
        other.url == url &&
        _setEquals(other.formats, formats);
  }

  @override
  int get hashCode => Object.hash(start, end, formats, url);

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }
}
