import 'package:equatable/equatable.dart';
import 'format_type.dart';

/// Immutable entity representing a segment of formatted text.
///
/// Used for parsing and analyzing formatted text to identify which portions
/// have specific formatting applied.
class FormattedSegment extends Equatable {
  /// The starting position of this segment in the text
  final int start;

  /// The ending position of this segment in the text
  final int end;

  /// The format type applied to this segment
  final FormatType formatType;

  /// The actual text content of this segment
  final String text;

  /// Optional metadata for this segment (e.g., URL for links)
  final Map<String, dynamic>? metadata;

  /// Creates a [FormattedSegment] with the specified values.
  const FormattedSegment({
    required this.start,
    required this.end,
    required this.formatType,
    required this.text,
    this.metadata,
  });

  @override
  List<Object?> get props => [start, end, formatType, text, metadata];

  @override
  String toString() {
    return 'FormattedSegment(start: $start, end: $end, formatType: $formatType, text: $text, metadata: $metadata)';
  }
}
