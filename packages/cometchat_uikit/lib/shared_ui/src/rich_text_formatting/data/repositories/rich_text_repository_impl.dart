import 'package:flutter/material.dart';
import '../../../clean_architecture/core/result.dart';
import '../../domain/entities/format_type.dart';
import '../../domain/entities/format_result.dart';
import '../../domain/entities/formatted_segment.dart';
import '../../domain/entities/link_data.dart';
import '../../domain/repositories/rich_text_repository.dart';
import '../datasources/formatter_datasource.dart';
import '../datasources/code_block_formatter_datasource.dart';
import '../datasources/bullet_list_formatter_datasource.dart';
import '../datasources/ordered_list_formatter_datasource.dart';
import '../datasources/blockquote_formatter_datasource.dart';
import '../../domain/entities/format_compatibility.dart';

/// Implementation of [RichTextRepository] that delegates to formatter data sources.
///
/// This repository coordinates between multiple formatter data sources to provide
/// rich text formatting operations. It handles format conflict resolution,
/// validation, and conversion between data layer and domain layer types.
///
/// Format priority (for conflict resolution):
/// 1. codeBlock (highest)
/// 2. inlineCode
/// 3. link
/// 4. bold/italic/strikethrough (equal priority)
class RichTextRepositoryImpl implements RichTextRepository {
  /// Map of format types to their corresponding data sources
  final Map<FormatType, FormatterDataSource> _formatters;

  /// Creates a [RichTextRepositoryImpl] with the specified formatters.
  ///
  /// The formatters map should contain all supported format types.
  const RichTextRepositoryImpl({
    required Map<FormatType, FormatterDataSource> formatters,
  }) : _formatters = formatters;

  @override
  Future<Result<FormatResult>> applyFormat({
    required FormatType formatType,
    required String text,
    required TextSelection selection,
    LinkData? linkData,
  }) async {
    try {
      // Get the formatter for this format type
      final formatter = _formatters[formatType];
      if (formatter == null) {
        return Failure(
          message: 'Formatter not found for format type: $formatType',
          code: 'FORMATTER_NOT_FOUND',
        );
      }

      // Resolve block-level format conflicts by removing the conflicting
      // format first, then applying the new one to the cleaned text.
      var processedText = text;
      var processedSelection = selection;

      final resolveResult = _resolveBlockFormatConflicts(
        text: text,
        selection: selection,
        formatType: formatType,
      );
      if (resolveResult != null) {
        processedText = resolveResult.newText;
        processedSelection = resolveResult.newSelection;
      }

      // Check for remaining format conflicts that can't be resolved
      final conflictResult = _checkFormatConflicts(
        text: processedText,
        selection: processedSelection,
        formatType: formatType,
      );
      if (conflictResult != null) {
        return conflictResult;
      }

      // Prepare metadata for link formatting
      Map<String, dynamic>? metadata;
      if (formatType == FormatType.link) {
        if (linkData == null) {
          return const Failure(
            message: 'Link data is required for link formatting',
            code: 'MISSING_LINK_DATA',
          );
        }
        metadata = {'url': linkData.url, 'displayText': linkData.displayText};
      }

      // Apply the format using the data source
      final result = formatter.applyFormat(
        text: processedText,
        selection: processedSelection,
        metadata: metadata,
      );

      // Convert data layer result to domain entity
      final formatResult = FormatResult(
        newText: result.newText,
        newSelection: TextSelection(
          baseOffset: result.newCursorStart,
          extentOffset: result.newCursorEnd,
        ),
        formatApplied: formatType,
      );

      return Success(formatResult);
    } catch (e) {
      return Failure(
        message: 'Failed to apply format: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<Set<FormatType>>> detectActiveFormats({
    required String text,
    required int cursorPosition,
  }) async {
    try {
      // Validate cursor position
      if (cursorPosition < 0 || cursorPosition > text.length) {
        return const Failure(
          message: 'Invalid cursor position',
          code: 'INVALID_CURSOR_POSITION',
        );
      }

      final activeFormats = <FormatType>{};

      // Check each formatter to see if it's active at the cursor position
      for (final entry in _formatters.entries) {
        final formatType = entry.key;
        final formatter = entry.value;

        if (formatter.isActiveAt(text, cursorPosition)) {
          activeFormats.add(formatType);
        }
      }

      return Success(activeFormats);
    } catch (e) {
      return Failure(
        message: 'Failed to detect active formats: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<bool>> validateLink(String url) async {
    try {
      // Accept any non-empty string as a valid link URL.
      // Empty or whitespace-only strings are rejected.
      if (url.trim().isEmpty) {
        return const Success(false);
      }

      return const Success(true);
    } catch (e) {
      return Failure(
        message: 'Failed to validate link: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<List<FormattedSegment>>> parseFormattedText(String text) async {
    try {
      final segments = <FormattedSegment>[];

      // Extract segments from all formatters
      for (final entry in _formatters.entries) {
        final formatType = entry.key;
        final formatter = entry.value;

        // Get all matches for this formatter
        final matches = formatter.pattern.allMatches(text);

        for (final match in matches) {
          // Extract metadata based on format type
          Map<String, dynamic>? metadata;
          if (formatType == FormatType.link) {
            // For links, extract URL and display text
            final displayText = match.group(1);
            final url = match.group(2);
            if (displayText != null && url != null) {
              metadata = {'url': url, 'displayText': displayText};
            }
          }

          // Create formatted segment
          final segment = FormattedSegment(
            start: match.start,
            end: match.end,
            formatType: formatType,
            text: match.group(0) ?? '',
            metadata: metadata,
          );

          segments.add(segment);
        }
      }

      // Sort segments by start position
      segments.sort((a, b) => a.start.compareTo(b.start));

      return Success(segments);
    } catch (e) {
      return Failure(
        message: 'Failed to parse formatted text: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<FormatResult?>> handleEnterKey({
    required String text,
    required TextSelection selection,
  }) async {
    try {
      // Check formatters in priority order:
      // 1. Code block (highest priority)
      // 2. Bullet list
      // 3. Ordered list
      // 4. Blockquote

      final priorityOrder = [
        FormatType.codeBlock,
        FormatType.bulletList,
        FormatType.orderedList,
        FormatType.blockquote,
      ];

      for (final formatType in priorityOrder) {
        final formatter = _formatters[formatType];
        if (formatter == null) continue;

        // Check if this formatter can handle the Enter key
        dynamic result;
        if (formatter is CodeBlockFormatterDataSource) {
          result = formatter.handleEnterKey(text: text, selection: selection);
        } else if (formatter is BulletListFormatterDataSource) {
          result = formatter.handleEnterKey(text: text, selection: selection);
        } else if (formatter is OrderedListFormatterDataSource) {
          result = formatter.handleEnterKey(text: text, selection: selection);
        } else if (formatter is BlockquoteFormatterDataSource) {
          result = formatter.handleEnterKey(text: text, selection: selection);
        }

        // If formatter handled the Enter key, convert and return result
        if (result != null) {
          final formatResult = FormatResult(
            newText: result.newText,
            newSelection: TextSelection(
              baseOffset: result.newCursorStart,
              extentOffset: result.newCursorEnd,
            ),
            formatApplied: formatType,
          );
          return Success(formatResult);
        }
      }

      // No formatter handled the Enter key
      return const Success(null);
    } catch (e) {
      return Failure(
        message: 'Failed to handle Enter key: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  /// Resolves block-level format conflicts by removing the conflicting format
  /// from the text before the new format is applied.
  ///
  /// Handles these cases:
  /// - Applying bullet/ordered list while code block is active → strips code block
  /// - Applying code block while blockquote is active → strips blockquote
  /// - Applying blockquote while code block is active → strips code block
  ///
  /// Returns a [_ResolvedText] with cleaned text and adjusted selection,
  /// or null if no resolvable conflict was found.
  _ResolvedText? _resolveBlockFormatConflicts({
    required String text,
    required TextSelection selection,
    required FormatType formatType,
  }) {
    // Detect active block-level formats at the selection
    final codeBlockFormatter = _formatters[FormatType.codeBlock];
    final blockquoteFormatter = _formatters[FormatType.blockquote];

    final codeBlockActive =
        codeBlockFormatter != null &&
        _isFormatActiveInRange(codeBlockFormatter, text, selection);
    final blockquoteActive =
        blockquoteFormatter != null &&
        _isFormatActiveInRange(blockquoteFormatter, text, selection);

    // Case 1: Applying list (bullet/ordered) over code block → strip code block
    // Case 2: Applying blockquote over code block → strip code block
    if (codeBlockActive &&
        (formatType == FormatType.bulletList ||
            formatType == FormatType.orderedList ||
            formatType == FormatType.blockquote)) {
      return _stripCodeBlockMarkers(text, selection);
    }

    // Case 3: Applying code block over blockquote → strip blockquote
    if (blockquoteActive && formatType == FormatType.codeBlock) {
      return _stripBlockquoteMarkers(text, selection);
    }

    return null;
  }

  /// Checks if a formatter is active anywhere within the selection range.
  bool _isFormatActiveInRange(
    FormatterDataSource formatter,
    String text,
    TextSelection selection,
  ) {
    for (int pos = selection.start; pos <= selection.end; pos++) {
      try {
        if (formatter.isActiveAt(text, pos)) {
          return true;
        }
      } catch (_) {
        // Some formatters may throw on boundary positions; skip safely
      }
    }
    return false;
  }

  /// Strips code block markers (```) from text, extracting the inner content.
  ///
  /// Finds the code block that contains the selection and removes the opening
  /// and closing ``` markers, adjusting the selection to cover the extracted
  /// content.
  _ResolvedText _stripCodeBlockMarkers(String text, TextSelection selection) {
    final codeBlockFormatter = _formatters[FormatType.codeBlock];
    if (codeBlockFormatter == null) {
      return _ResolvedText(newText: text, newSelection: selection);
    }

    final codeBlockPattern = codeBlockFormatter.pattern;
    for (final match in codeBlockPattern.allMatches(text)) {
      // Check if the selection overlaps with this code block
      if (selection.start >= match.start && selection.start <= match.end) {
        final openMarker = codeBlockFormatter.openingMarker; // ```
        final closeMarker = codeBlockFormatter.closingMarker; // ```
        final contentStart = match.start + openMarker.length;
        final contentEnd = match.end - closeMarker.length;
        final innerContent = text.substring(contentStart, contentEnd);

        final newText =
            text.substring(0, match.start) +
            innerContent +
            text.substring(match.end);

        // Adjust selection to cover the extracted content
        final newSelection = TextSelection(
          baseOffset: match.start,
          extentOffset: match.start + innerContent.length,
        );

        return _ResolvedText(newText: newText, newSelection: newSelection);
      }
    }

    return _ResolvedText(newText: text, newSelection: selection);
  }

  /// Strips blockquote markers (`> `) from lines in the selection range.
  ///
  /// Removes the `> ` prefix from each line that has it, adjusting the
  /// selection accordingly.
  _ResolvedText _stripBlockquoteMarkers(String text, TextSelection selection) {
    final blockquoteFormatter = _formatters[FormatType.blockquote];
    if (blockquoteFormatter == null) {
      return _ResolvedText(newText: text, newSelection: selection);
    }

    final marker = blockquoteFormatter.openingMarker; // "> "
    final lines = text.split('\n');
    var charCount = 0;
    var removedBeforeStart = 0;
    var removedTotal = 0;

    for (int i = 0; i < lines.length; i++) {
      final lineStart = charCount;
      final lineEnd = charCount + lines[i].length;

      // Check if this line overlaps with the selection and has blockquote marker
      if (lineEnd >= selection.start &&
          lineStart <= selection.end &&
          lines[i].startsWith(marker)) {
        lines[i] = lines[i].substring(marker.length);
        if (lineStart < selection.start) {
          removedBeforeStart += marker.length;
        }
        removedTotal += marker.length;
      }

      charCount = lineEnd + 1; // +1 for the \n
    }

    final newText = lines.join('\n');
    final newStart = (selection.start - removedBeforeStart).clamp(
      0,
      newText.length,
    );
    final newEnd = (selection.end - removedTotal).clamp(
      newStart,
      newText.length,
    );

    return _ResolvedText(
      newText: newText,
      newSelection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
    );
  }

  /// Check for format conflicts using the [FormatCompatibility] matrix.
  ///
  /// Detects active formats at the cursor/selection position and checks
  /// whether the requested [formatType] is compatible with them.
  /// If the requested format is disabled by any active format (e.g., inline
  /// formatting inside a code block), returns a [Failure].
  ///
  /// Returns a [Failure] if there's a conflict, null otherwise.
  Result<FormatResult>? _checkFormatConflicts({
    required String text,
    required TextSelection selection,
    required FormatType formatType,
  }) {
    // Detect all active formats at the cursor/selection position
    final activeFormats = <FormatType>{};
    for (final entry in _formatters.entries) {
      final existingFormatType = entry.key;
      final existingFormatter = entry.value;

      // Skip checking the same format type (toggling is allowed)
      if (existingFormatType == formatType) continue;

      // Check if this format is active anywhere in the selection range
      for (int pos = selection.start; pos <= selection.end; pos++) {
        try {
          if (existingFormatter.isActiveAt(text, pos)) {
            activeFormats.add(existingFormatType);
            break;
          }
        } catch (_) {
          // Some formatters may throw on boundary positions; skip safely
        }
      }
    }

    if (activeFormats.isEmpty) return null;

    // Use FormatCompatibility to determine if the requested format is blocked
    final disabledFormats = FormatCompatibility.getDisabledFormats(
      activeFormats,
    );
    if (disabledFormats.contains(formatType)) {
      return Failure(
        message:
            'Cannot apply $formatType: incompatible with active formats $activeFormats',
        code: 'FORMAT_CONFLICT',
      );
    }

    return null; // No conflicts
  }
}

/// Helper class for resolved text after stripping block-level format markers.
class _ResolvedText {
  final String newText;
  final TextSelection newSelection;

  const _ResolvedText({required this.newText, required this.newSelection});
}
