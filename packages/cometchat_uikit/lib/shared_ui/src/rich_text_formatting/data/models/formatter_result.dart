/// Data layer result from applying a format operation.
///
/// This is the data layer equivalent of the domain's [FormatResult].
/// It contains the new text and cursor position after formatting.
class FormatterResult {
  /// The text after formatting has been applied
  final String newText;

  /// The new cursor start position
  final int newCursorStart;

  /// The new cursor end position (for selections)
  final int newCursorEnd;

  /// Optional metadata produced by the formatting operation.
  ///
  /// Used to carry side-channel data such as preserved mention information
  /// when code block formatting strips mentions from text.
  final Map<String, dynamic>? metadata;

  const FormatterResult({
    required this.newText,
    required this.newCursorStart,
    required this.newCursorEnd,
    this.metadata,
  });
}
