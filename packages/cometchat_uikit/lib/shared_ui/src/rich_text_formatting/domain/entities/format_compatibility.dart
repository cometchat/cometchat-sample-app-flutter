/// Format compatibility matrix for rich text formatting.
///
/// This class defines which formats can be combined together.
///
/// Compatibility Rules:
/// - All inline formats (Bold, Italic, Underline, Strike, Inline Code, Link,
///   Code Block) are compatible with each other
/// - Bullet List and Numbered List are mutually exclusive
/// - All other combinations are allowed
import 'format_type.dart';

/// Provides format compatibility checking based on Slack's rules.
class FormatCompatibility {
  FormatCompatibility._();

  /// Compatibility matrix: Map<ActiveFormat, Set<CompatibleFormats>>
  /// If a format is NOT in the compatible set, it should be disabled.
  static const Map<FormatType, Set<FormatType>> _compatibilityMatrix = {
    FormatType.bold: {
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.italic: {
      FormatType.bold,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.underline: {
      FormatType.bold,
      FormatType.italic,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.strikethrough: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.inlineCode: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.bulletList: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.blockquote,
      FormatType.orderedList,
    },
    FormatType.orderedList: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.blockquote,
      FormatType.bulletList,
    },
    FormatType.blockquote: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.link,
      FormatType.bulletList,
      FormatType.orderedList,
    },
    FormatType.codeBlock: {
      // Code block disables inline formats but line-based formats stay enabled.
      // Tapping a line-based format while code block is active switches modes.
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
    FormatType.link: {
      FormatType.bold,
      FormatType.italic,
      FormatType.underline,
      FormatType.strikethrough,
      FormatType.inlineCode,
      FormatType.codeBlock,
      FormatType.bulletList,
      FormatType.orderedList,
      FormatType.blockquote,
    },
  };

  /// Check if [targetFormat] is compatible with all [activeFormats].
  ///
  /// Returns true if [targetFormat] can be applied when [activeFormats] are active.
  static bool isCompatible(
    FormatType targetFormat,
    Set<FormatType> activeFormats,
  ) {
    if (activeFormats.isEmpty) return true;
    if (activeFormats.contains(targetFormat)) return true;

    // Check if target format is compatible with ALL active formats
    for (final activeFormat in activeFormats) {
      final compatibleFormats = _compatibilityMatrix[activeFormat];
      if (compatibleFormats == null || !compatibleFormats.contains(targetFormat)) {
        return false;
      }
    }

    return true;
  }

  /// Get all formats that are disabled given the [activeFormats].
  ///
  /// Returns a set of formats that should be shown as disabled in the toolbar.
  static Set<FormatType> getDisabledFormats(Set<FormatType> activeFormats) {
    if (activeFormats.isEmpty) return {};

    final disabledFormats = <FormatType>{};

    for (final format in FormatType.values) {
      if (!activeFormats.contains(format) && !isCompatible(format, activeFormats)) {
        disabledFormats.add(format);
      }
    }

    return disabledFormats;
  }

  /// Get all formats that are compatible with the [activeFormats].
  ///
  /// Returns a set of formats that can be applied when [activeFormats] are active.
  static Set<FormatType> getCompatibleFormats(Set<FormatType> activeFormats) {
    if (activeFormats.isEmpty) return FormatType.values.toSet();

    final compatibleFormats = <FormatType>{};

    for (final format in FormatType.values) {
      if (isCompatible(format, activeFormats)) {
        compatibleFormats.add(format);
      }
    }

    return compatibleFormats;
  }
}
