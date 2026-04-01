import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Defines the category of a format type for mutual exclusivity rules.
enum FormatCategory {
  /// Inline formats that can be combined with each other.
  /// Includes: bold, italic, underline, strikethrough, link
  inline,

  /// Block formats that are mutually exclusive.
  /// Includes: blockquote, inlineCode, codeBlock, orderedList, bulletList
  exclusive,
}

/// Extension to categorize format types.
extension FormatTypeCategory on FormatType {
  /// Returns the category of this format type.
  FormatCategory get category {
    switch (this) {
      case FormatType.bold:
      case FormatType.italic:
      case FormatType.underline:
      case FormatType.strikethrough:
      case FormatType.link:
        return FormatCategory.inline;
      case FormatType.blockquote:
      case FormatType.inlineCode:
      case FormatType.codeBlock:
      case FormatType.orderedList:
      case FormatType.bulletList:
        return FormatCategory.exclusive;
    }
  }

  /// Returns true if this format can be combined with other formats.
  bool get isCombinable => category == FormatCategory.inline;

  /// Returns true if this format is mutually exclusive with other exclusive formats.
  bool get isExclusive => category == FormatCategory.exclusive;
}


/// Set of all exclusive format types.
const Set<FormatType> exclusiveFormats = {
  FormatType.blockquote,
  FormatType.inlineCode,
  FormatType.codeBlock,
  FormatType.orderedList,
  FormatType.bulletList,
};

/// Set of all inline (combinable) format types.
const Set<FormatType> inlineFormats = {
  FormatType.bold,
  FormatType.italic,
  FormatType.underline,
  FormatType.strikethrough,
  FormatType.link,
};

/// Abstract base class for format handlers.
/// 
/// Each format type has its own handler that encapsulates the logic
/// for applying, removing, and toggling that specific format.
abstract class FormatHandler {
  const FormatHandler();

  /// The format type this handler manages.
  FormatType get formatType;

  /// The regex pattern for this format.
  RegExp get pattern => FormatPatterns.getPattern(formatType);

  /// Applies the format to the given text range.
  FormattedResult apply({
    required String text,
    required int selectionStart,
    required int selectionEnd,
  }) {
    return RichTextFormatterManager.applyFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Removes the format from the given text range.
  FormattedResult remove({
    required String text,
    required int selectionStart,
    required int selectionEnd,
  }) {
    return RichTextFormatterManager.removeFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Toggles the format on the given text range.
  FormattedResult toggle({
    required String text,
    required int selectionStart,
    required int selectionEnd,
  }) {
    return RichTextFormatterManager.toggleFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Checks if the format is active at the given position.
  bool isActive({
    required String text,
    required int position,
  }) {
    return RichTextFormatterManager.hasFormat(
      text: text,
      formatType: formatType,
      position: position,
    );
  }
}


// ============================================================================
// INLINE FORMAT HANDLERS (Combinable)
// ============================================================================

/// Handler for bold formatting (**text**).
class BoldFormatHandler extends FormatHandler {
  const BoldFormatHandler();

  @override
  FormatType get formatType => FormatType.bold;
}


/// Handler for italic formatting (_text_).
class ItalicFormatHandler extends FormatHandler {
  const ItalicFormatHandler();

  @override
  FormatType get formatType => FormatType.italic;
}


/// Handler for underline formatting (<u>text</u>).
class UnderlineFormatHandler extends FormatHandler {
  const UnderlineFormatHandler();

  @override
  FormatType get formatType => FormatType.underline;
}


/// Handler for strikethrough formatting (~~text~~).
class StrikethroughFormatHandler extends FormatHandler {
  const StrikethroughFormatHandler();

  @override
  FormatType get formatType => FormatType.strikethrough;
}


/// Handler for link formatting ([text](url)).
class LinkFormatHandler extends FormatHandler {
  const LinkFormatHandler();

  @override
  FormatType get formatType => FormatType.link;
}


// ============================================================================
// EXCLUSIVE FORMAT HANDLERS (Mutually Exclusive)
// ============================================================================

/// Handler for blockquote formatting (> text).
class BlockquoteFormatHandler extends FormatHandler {
  const BlockquoteFormatHandler();

  @override
  FormatType get formatType => FormatType.blockquote;
}


/// Handler for inline code formatting (`code`).
class InlineCodeFormatHandler extends FormatHandler {
  const InlineCodeFormatHandler();

  @override
  FormatType get formatType => FormatType.inlineCode;
}


/// Handler for code block formatting (```code```).
class CodeBlockFormatHandler extends FormatHandler {
  const CodeBlockFormatHandler();

  @override
  FormatType get formatType => FormatType.codeBlock;
}


/// Handler for ordered list formatting (1. item).
class OrderedListFormatHandler extends FormatHandler {
  const OrderedListFormatHandler();

  @override
  FormatType get formatType => FormatType.orderedList;
}


/// Handler for bullet list formatting (- item).
class BulletListFormatHandler extends FormatHandler {
  const BulletListFormatHandler();

  @override
  FormatType get formatType => FormatType.bulletList;
}


// ============================================================================
// HANDLER REGISTRY
// ============================================================================

/// Registry of all format handlers.
/// 
/// Provides easy access to handlers by format type.
class FormatHandlerRegistry {
  FormatHandlerRegistry._();

  static final Map<FormatType, FormatHandler> _handlers = {
    FormatType.bold: const BoldFormatHandler(),
    FormatType.italic: const ItalicFormatHandler(),
    FormatType.underline: const UnderlineFormatHandler(),
    FormatType.strikethrough: const StrikethroughFormatHandler(),
    FormatType.link: const LinkFormatHandler(),
    FormatType.blockquote: const BlockquoteFormatHandler(),
    FormatType.inlineCode: const InlineCodeFormatHandler(),
    FormatType.codeBlock: const CodeBlockFormatHandler(),
    FormatType.orderedList: const OrderedListFormatHandler(),
    FormatType.bulletList: const BulletListFormatHandler(),
  };

  /// Gets the handler for a specific format type.
  static FormatHandler getHandler(FormatType formatType) {
    return _handlers[formatType]!;
  }

  /// Gets all handlers.
  static Iterable<FormatHandler> get allHandlers => _handlers.values;

  /// Gets handlers for inline (combinable) formats.
  static Iterable<FormatHandler> get inlineHandlers =>
      _handlers.entries
          .where((e) => e.key.isCombinable)
          .map((e) => e.value);

  /// Gets handlers for exclusive formats.
  static Iterable<FormatHandler> get exclusiveHandlers =>
      _handlers.entries
          .where((e) => e.key.isExclusive)
          .map((e) => e.value);
}
