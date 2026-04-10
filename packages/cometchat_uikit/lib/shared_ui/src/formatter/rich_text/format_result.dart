import 'package:flutter/material.dart';
import 'rich_text_format_type.dart';

/// Result of applying a formatting operation
@immutable
class FormatResult {
  const FormatResult({
    required this.newText,
    required this.newSelection,
    required this.formatApplied,
  });

  /// The new text after formatting
  final String newText;

  /// The new cursor/selection position
  final TextSelection newSelection;

  /// The format type that was applied
  final RichTextFormatType formatApplied;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormatResult &&
        other.newText == newText &&
        other.newSelection == newSelection &&
        other.formatApplied == formatApplied;
  }

  @override
  int get hashCode => Object.hash(newText, newSelection, formatApplied);

  @override
  String toString() =>
      'FormatResult(newText: $newText, newSelection: $newSelection, formatApplied: $formatApplied)';
}
