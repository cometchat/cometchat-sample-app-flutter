/// Data representing a text segment with formatting attributes.
///
/// Used for styling text in input fields to show formatting visually
/// (e.g., bold text appears bold while typing).
class AttributedTextData {
  /// Start position of the attributed segment
  final int start;

  /// End position of the attributed segment
  final int end;

  /// Formatting attributes for this segment
  /// 
  /// Common attributes:
  /// - 'bold': true/false
  /// - 'italic': true/false
  /// - 'strikethrough': true/false
  /// - 'code': true/false
  /// - 'link': URL string
  final Map<String, dynamic> attributes;

  const AttributedTextData({
    required this.start,
    required this.end,
    required this.attributes,
  });
}
