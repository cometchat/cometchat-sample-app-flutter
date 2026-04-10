import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'format_type.dart';

/// Immutable entity representing the result of applying a text format.
///
/// Contains the newly formatted text, the updated cursor selection position,
/// and the format type that was applied.
class FormatResult extends Equatable {
  /// The text after formatting has been applied
  final String newText;

  /// The new cursor selection position after formatting
  final TextSelection newSelection;

  /// The format type that was applied
  final FormatType formatApplied;

  /// Creates a [FormatResult] with the specified values.
  const FormatResult({
    required this.newText,
    required this.newSelection,
    required this.formatApplied,
  });

  @override
  List<Object?> get props => [newText, newSelection, formatApplied];

  @override
  String toString() {
    return 'FormatResult(newText: $newText, newSelection: $newSelection, formatApplied: $formatApplied)';
  }
}
