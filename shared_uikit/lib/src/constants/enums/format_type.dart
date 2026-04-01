/// [FormatType] is an enum representing the different text formatting types
/// supported by the rich text editor in [CometChatCompactMessageComposer].
///
/// Each format type has associated markdown syntax (prefix and suffix) that
/// is used to wrap selected text when formatting is applied.
enum FormatType {
  /// Bold formatting using double asterisks: **text**
  bold('**', '**'),

  /// Italic formatting using underscores: _text_
  italic('_', '_'),

  /// Underline formatting using HTML-style tags: <u>text</u>
  underline('<u>', '</u>'),

  /// Strikethrough formatting using double tildes: ~~text~~
  strikethrough('~~', '~~'),

  /// Inline code formatting using backticks: `code`
  inlineCode('`', '`'),

  /// Code block formatting using triple backticks
  codeBlock('```', '```'),

  /// Link formatting: [text](url)
  link('[', '](url)'),

  /// Bullet list formatting: - item
  bulletList('- ', ''),

  /// Ordered list formatting: 1. item
  orderedList('1. ', ''),

  /// Blockquote formatting: > text
  blockquote('> ', '');

  const FormatType(this.prefix, this.suffix);

  /// The prefix marker for this format type
  final String prefix;

  /// The suffix marker for this format type
  final String suffix;

  /// Wraps the given text with the format markers.
  ///
  /// Example:
  /// ```dart
  /// FormatType.bold.wrap('hello'); // Returns '**hello**'
  /// ```
  String wrap(String text) {
    return '$prefix$text$suffix';
  }

  /// Checks if the given text is wrapped with this format's markers.
  ///
  /// Returns true if the text starts with [prefix] and ends with [suffix].
  bool isWrapped(String text) {
    if (text.isEmpty) return false;
    if (text.length < prefix.length + suffix.length) return false;
    return text.startsWith(prefix) && text.endsWith(suffix);
  }

  /// Removes the format markers from the given text.
  ///
  /// If the text is not wrapped with this format's markers, returns the
  /// original text unchanged.
  String unwrap(String text) {
    if (!isWrapped(text)) return text;
    return text.substring(prefix.length, text.length - suffix.length);
  }

  /// Returns true if this format type is a block-level format.
  ///
  /// Block-level formats (codeBlock, bulletList, orderedList, blockquote)
  /// apply to entire lines rather than inline text.
  bool get isBlock {
    return this == FormatType.codeBlock ||
        this == FormatType.bulletList ||
        this == FormatType.orderedList ||
        this == FormatType.blockquote;
  }
}
