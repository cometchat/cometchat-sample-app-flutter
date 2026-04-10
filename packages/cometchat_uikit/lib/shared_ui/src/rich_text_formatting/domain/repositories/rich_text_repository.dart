import 'package:flutter/material.dart';
import '../../../clean_architecture/core/result.dart';
import '../entities/format_type.dart';
import '../entities/format_result.dart';
import '../entities/formatted_segment.dart';
import '../entities/link_data.dart';

/// Repository interface for rich text formatting operations.
///
/// Defines the contract for applying formatting, detecting active formats,
/// validating links, parsing formatted text, and handling special key presses.
///
/// All operations return [Result<T>] for consistent error handling without exceptions.
abstract class RichTextRepository {
  /// Apply formatting to text at the specified selection.
  ///
  /// Parameters:
  /// - [formatType]: The type of formatting to apply
  /// - [text]: The current text content
  /// - [selection]: The current text selection/cursor position
  /// - [linkData]: Optional link data (required for link formatting)
  ///
  /// Returns:
  /// - [Success<FormatResult>] with the formatted text and new selection
  /// - [Failure] if the format type is disabled or operation fails
  ///
  /// Validates: Requirements 1.2, 6.1
  Future<Result<FormatResult>> applyFormat({
    required FormatType formatType,
    required String text,
    required TextSelection selection,
    LinkData? linkData,
  });

  /// Detect which formats are active at the specified cursor position.
  ///
  /// Parameters:
  /// - [text]: The current text content
  /// - [cursorPosition]: The cursor position to check
  ///
  /// Returns:
  /// - [Success<Set<FormatType>>] with the set of active formats
  /// - [Failure] if the cursor position is invalid
  ///
  /// Validates: Requirements 1.2, 6.1
  Future<Result<Set<FormatType>>> detectActiveFormats({
    required String text,
    required int cursorPosition,
  });

  /// Validate a URL for link formatting.
  ///
  /// Accepts any non-empty string as a valid link URL.
  /// Empty or whitespace-only strings are rejected.
  ///
  /// Parameters:
  /// - [url]: The URL string to validate
  ///
  /// Returns:
  /// - [Success<bool>] with true if valid, false if invalid
  /// - [Failure] if validation fails
  ///
  /// Validates: Requirements 1.2, 6.1
  Future<Result<bool>> validateLink(String url);

  /// Parse formatted text into segments.
  ///
  /// Analyzes the text and identifies all formatted segments,
  /// returning them sorted by start position.
  ///
  /// Parameters:
  /// - [text]: The formatted text to parse
  ///
  /// Returns:
  /// - [Success<List<FormattedSegment>>] with the list of segments
  /// - [Failure] if parsing fails
  ///
  /// Validates: Requirements 1.2, 6.1
  Future<Result<List<FormattedSegment>>> parseFormattedText(String text);

  /// Handle Enter key press for list continuation and code block newlines.
  ///
  /// Checks if the cursor is inside a list or code block and handles
  /// the Enter key appropriately:
  /// - Bullet/ordered lists: Continue with new item or exit if empty
  /// - Code blocks: Insert newline without exiting
  /// - Blockquotes: Continue with new blockquote line
  ///
  /// Parameters:
  /// - [text]: The current text content
  /// - [selection]: The current text selection/cursor position
  ///
  /// Returns:
  /// - [Success<FormatResult?>] with the result if handled, null if not handled
  /// - [Failure] if operation fails
  ///
  /// Validates: Requirements 1.2, 6.1
  Future<Result<FormatResult?>> handleEnterKey({
    required String text,
    required TextSelection selection,
  });
}
