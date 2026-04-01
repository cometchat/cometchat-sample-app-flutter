import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Result of a formatting operation.
///
/// Contains the modified text and the new cursor positions after
/// the formatting has been applied.
class FormattedResult {
  /// Creates a [FormattedResult] with the specified values.
  const FormattedResult({
    required this.text,
    required this.newCursorStart,
    required this.newCursorEnd,
    this.removedFormats,
  });

  /// The text after formatting has been applied.
  final String text;

  /// The new cursor start position after formatting.
  final int newCursorStart;

  /// The new cursor end position after formatting.
  final int newCursorEnd;

  /// Formats that were removed due to mutual exclusivity rules.
  /// This is populated when an exclusive format is applied and other
  /// exclusive formats were active.
  final Set<FormatType>? removedFormats;

  @override
  String toString() =>
      'FormattedResult(text: $text, newCursorStart: $newCursorStart, newCursorEnd: $newCursorEnd, removedFormats: $removedFormats)';
}

/// [RichTextFormatterManager] handles the application and removal of markdown
/// formatting to text in the composer input field.
///
/// This class provides static methods for:
/// - Applying formatting to selected text
/// - Removing formatting from text
/// - Toggling formatting on/off
/// - Detecting active formats at a cursor position
///
/// Example usage:
/// ```dart
/// final result = RichTextFormatterManager.applyFormat(
///   text: 'Hello world',
///   selectionStart: 0,
///   selectionEnd: 5,
///   formatType: FormatType.bold,
/// );
/// // result.text == '**Hello** world'
/// ```
class RichTextFormatterManager {
  // Private constructor to prevent instantiation
  RichTextFormatterManager._();

  /// Applies the specified format to the selected text.
  ///
  /// If there is no selection (selectionStart == selectionEnd), inserts
  /// the format markers at the cursor position.
  ///
  /// If there is a selection, wraps the selected text with the format markers.
  ///
  /// Returns a [FormattedResult] with the new text and cursor positions.
  static FormattedResult applyFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    // Validate selection bounds
    selectionStart = selectionStart.clamp(0, text.length);
    selectionEnd = selectionEnd.clamp(0, text.length);

    if (selectionStart > selectionEnd) {
      final temp = selectionStart;
      selectionStart = selectionEnd;
      selectionEnd = temp;
    }

    if (selectionStart == selectionEnd) {
      // No selection - insert markers at cursor
      return _insertMarkersAtCursor(text, selectionStart, formatType);
    } else {
      // Has selection - wrap selected text
      return _wrapSelection(text, selectionStart, selectionEnd, formatType);
    }
  }

  /// Toggles the specified format on the selected text.
  ///
  /// If the selected text is already formatted with the specified format,
  /// removes the format. Otherwise, applies the format.
  ///
  /// Returns a [FormattedResult] with the new text and cursor positions.
  static FormattedResult toggleFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    // Validate selection bounds
    selectionStart = selectionStart.clamp(0, text.length);
    selectionEnd = selectionEnd.clamp(0, text.length);

    if (selectionStart > selectionEnd) {
      final temp = selectionStart;
      selectionStart = selectionEnd;
      selectionEnd = temp;
    }

    if (selectionStart == selectionEnd) {
      // No selection - just insert markers
      return _insertMarkersAtCursor(text, selectionStart, formatType);
    }

    final selectedText = text.substring(selectionStart, selectionEnd);

    if (formatType.isWrapped(selectedText)) {
      // Remove format
      return removeFormat(
        text: text,
        selectionStart: selectionStart,
        selectionEnd: selectionEnd,
        formatType: formatType,
      );
    } else {
      // Apply format
      return applyFormat(
        text: text,
        selectionStart: selectionStart,
        selectionEnd: selectionEnd,
        formatType: formatType,
      );
    }
  }

  /// Removes the specified format from the selected text.
  ///
  /// If the selected text is wrapped with the format markers, removes them.
  /// Otherwise, returns the text unchanged.
  ///
  /// Returns a [FormattedResult] with the new text and cursor positions.
  static FormattedResult removeFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    // Validate selection bounds
    selectionStart = selectionStart.clamp(0, text.length);
    selectionEnd = selectionEnd.clamp(0, text.length);

    if (selectionStart > selectionEnd) {
      final temp = selectionStart;
      selectionStart = selectionEnd;
      selectionEnd = temp;
    }

    if (selectionStart == selectionEnd) {
      // No selection - nothing to remove
      return FormattedResult(
        text: text,
        newCursorStart: selectionStart,
        newCursorEnd: selectionEnd,
      );
    }

    final selectedText = text.substring(selectionStart, selectionEnd);
    final unwrappedText = formatType.unwrap(selectedText);

    if (unwrappedText == selectedText) {
      // Text was not wrapped, return unchanged
      return FormattedResult(
        text: text,
        newCursorStart: selectionStart,
        newCursorEnd: selectionEnd,
      );
    }

    final newText =
        text.replaceRange(selectionStart, selectionEnd, unwrappedText);

    return FormattedResult(
      text: newText,
      newCursorStart: selectionStart,
      newCursorEnd: selectionStart + unwrappedText.length,
    );
  }

  /// Checks if the text at the given position has the specified format.
  ///
  /// Returns true if the cursor is inside a formatted region.
  static bool hasFormat({
    required String text,
    required FormatType formatType,
    required int position,
  }) {
    position = position.clamp(0, text.length);
    final pattern = FormatPatterns.getPattern(formatType);
    
    if (formatType.isBlock) {
      return FormatPatterns.isInsideLineFormat(text, position, pattern);
    }
    return FormatPatterns.isInsidePattern(text, position, pattern);
  }

  /// Detects which formats are active at the current cursor position.
  ///
  /// Returns a [Set] of [FormatType] values that are active at the position.
  static Set<FormatType> detectActiveFormats(String text, int cursorPosition) {
    cursorPosition = cursorPosition.clamp(0, text.length);

    final activeFormats = <FormatType>{};

    for (final formatType in FormatType.values) {
      final pattern = FormatPatterns.getPattern(formatType);
      final isActive = formatType.isBlock
          ? FormatPatterns.isInsideLineFormat(text, cursorPosition, pattern)
          : FormatPatterns.isInsidePattern(text, cursorPosition, pattern);
      
      if (isActive) {
        activeFormats.add(formatType);
      }
    }

    return activeFormats;
  }

  // Private helper methods

  static FormattedResult _insertMarkersAtCursor(
    String text,
    int cursorPosition,
    FormatType formatType,
  ) {
    final prefix = formatType.prefix;
    final suffix = formatType.suffix;
    final markers = '$prefix$suffix';

    final newText = text.substring(0, cursorPosition) +
        markers +
        text.substring(cursorPosition);

    // Position cursor between markers
    final newCursorPosition = cursorPosition + prefix.length;

    return FormattedResult(
      text: newText,
      newCursorStart: newCursorPosition,
      newCursorEnd: newCursorPosition,
    );
  }

  static FormattedResult _wrapSelection(
    String text,
    int selectionStart,
    int selectionEnd,
    FormatType formatType,
  ) {
    final selectedText = text.substring(selectionStart, selectionEnd);
    final wrappedText = formatType.wrap(selectedText);

    final newText =
        text.replaceRange(selectionStart, selectionEnd, wrappedText);

    return FormattedResult(
      text: newText,
      newCursorStart: selectionStart,
      newCursorEnd: selectionStart + wrappedText.length,
    );
  }
}
