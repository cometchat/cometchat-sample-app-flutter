import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';

/// Abstract interface for formatter data sources.
///
/// Each formatter implementation (bold, italic, link, etc.) must implement
/// this interface to provide consistent formatting operations.
///
/// Formatters are stateless and pure functions - they should not depend on
/// Flutter widgets or BuildContext beyond basic types like TextSelection.
abstract class FormatterDataSource {
  /// Regex pattern for detecting this format in text
  RegExp get pattern;

  /// The format type this data source handles
  FormatType get formatType;

  /// Opening marker for this format (e.g., "**" for bold)
  String get openingMarker;

  /// Closing marker for this format (e.g., "**" for bold)
  String get closingMarker;

  /// Placeholder text to use when no text is selected
  String get placeholderText;

  /// Apply this format to text at the given selection.
  ///
  /// Parameters:
  /// - [text]: The full text content
  /// - [selection]: The current text selection
  /// - [metadata]: Optional metadata (e.g., URL for links)
  ///
  /// Returns a [FormatterResult] with the new text and cursor position.
  FormatterResult applyFormat({
    required String text,
    required TextSelection selection,
    Map<String, dynamic>? metadata,
  });

  /// Check if this format is active at the given position in the text.
  ///
  /// Parameters:
  /// - [text]: The full text content
  /// - [position]: The cursor position to check
  ///
  /// Returns true if the format is active at the position.
  bool isActiveAt(String text, int position);

  /// Get attributed text data for input field styling.
  ///
  /// This method parses the text and returns a list of text segments
  /// with their formatting attributes for visual styling in the input field.
  ///
  /// Parameters:
  /// - [text]: The full text content to parse
  ///
  /// Returns a list of [AttributedTextData] segments.
  List<AttributedTextData> getAttributedText(String text);
}
