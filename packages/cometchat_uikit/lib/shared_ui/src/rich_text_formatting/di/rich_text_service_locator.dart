import '../domain/repositories/rich_text_repository.dart';
import '../domain/usecases/apply_format_usecase.dart';
import '../domain/usecases/detect_active_formats_usecase.dart';
import '../domain/usecases/validate_link_usecase.dart';
import '../domain/usecases/parse_formatted_text_usecase.dart';
import '../domain/entities/format_type.dart';
import '../data/datasources/formatter_datasource.dart';
import '../data/datasources/bold_formatter_datasource.dart';
import '../data/datasources/italic_formatter_datasource.dart';
import '../data/datasources/underline_formatter_datasource.dart';
import '../data/datasources/strikethrough_formatter_datasource.dart';
import '../data/datasources/inline_code_formatter_datasource.dart';
import '../data/datasources/code_block_formatter_datasource.dart';
import '../data/datasources/link_formatter_datasource.dart';
import '../data/datasources/bullet_list_formatter_datasource.dart';
import '../data/datasources/ordered_list_formatter_datasource.dart';
import '../data/datasources/blockquote_formatter_datasource.dart';
import '../data/repositories/rich_text_repository_impl.dart';

/// Service Locator for Rich Text Formatting module
/// Provides dependency injection for rich text formatting clean architecture
/// Follows singleton pattern for consistent dependency resolution
class RichTextServiceLocator {
  static final RichTextServiceLocator _instance =
      RichTextServiceLocator._internal();

  RichTextServiceLocator._internal();

  /// Get singleton instance
  static RichTextServiceLocator get instance => _instance;

  // Repository
  late RichTextRepository _repository;

  // Use cases
  late ApplyFormatUseCase _applyFormatUseCase;
  late DetectActiveFormatsUseCase _detectActiveFormatsUseCase;
  late ValidateLinkUseCase _validateLinkUseCase;
  late ParseFormattedTextUseCase _parseFormattedTextUseCase;

  bool _isInitialized = false;

  /// All format types the locator knows how to wire up.
  static const Set<FormatType> _allFormatTypes = {
    FormatType.bold,
    FormatType.italic,
    FormatType.underline,
    FormatType.strikethrough,
    FormatType.inlineCode,
    FormatType.codeBlock,
    FormatType.link,
    FormatType.bulletList,
    FormatType.orderedList,
    FormatType.blockquote,
  };

  /// Initialize all dependencies.
  ///
  /// Pass [enabledFormats] to restrict the formatters to a specific subset.
  /// When omitted, every supported format is enabled (matches the
  /// composer's default "all on" rich-text model).
  ///
  /// Safe to call repeatedly — only the first call wires up the dependency
  /// graph; subsequent calls are no-ops. Use [reset] if you need to change
  /// the enabled set mid-app (typically only in tests).
  void setup({Set<FormatType>? enabledFormats}) {
    if (_isInitialized) {
      return;
    }

    final enabled = enabledFormats ?? _allFormatTypes;

    final Map<FormatType, FormatterDataSource> formatters = {};

    if (enabled.contains(FormatType.bold)) {
      formatters[FormatType.bold] = BoldFormatterDataSource();
    }
    if (enabled.contains(FormatType.italic)) {
      formatters[FormatType.italic] = ItalicFormatterDataSource();
    }
    if (enabled.contains(FormatType.underline)) {
      formatters[FormatType.underline] = UnderlineFormatterDataSource();
    }
    if (enabled.contains(FormatType.strikethrough)) {
      formatters[FormatType.strikethrough] = StrikethroughFormatterDataSource();
    }
    if (enabled.contains(FormatType.inlineCode)) {
      formatters[FormatType.inlineCode] = InlineCodeFormatterDataSource();
    }
    if (enabled.contains(FormatType.codeBlock)) {
      formatters[FormatType.codeBlock] = CodeBlockFormatterDataSource();
    }
    if (enabled.contains(FormatType.link)) {
      formatters[FormatType.link] = LinkFormatterDataSource();
    }
    if (enabled.contains(FormatType.bulletList)) {
      formatters[FormatType.bulletList] = BulletListFormatterDataSource();
    }
    if (enabled.contains(FormatType.orderedList)) {
      formatters[FormatType.orderedList] = OrderedListFormatterDataSource();
    }
    if (enabled.contains(FormatType.blockquote)) {
      formatters[FormatType.blockquote] = BlockquoteFormatterDataSource();
    }

    _repository = RichTextRepositoryImpl(formatters: formatters);

    _applyFormatUseCase = ApplyFormatUseCase(_repository);
    _detectActiveFormatsUseCase = DetectActiveFormatsUseCase(_repository);
    _validateLinkUseCase = ValidateLinkUseCase(_repository);
    _parseFormattedTextUseCase = ParseFormattedTextUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  /// Get use case for applying text formatting
  ApplyFormatUseCase get applyFormatUseCase {
    _ensureInitialized();
    return _applyFormatUseCase;
  }

  /// Get use case for detecting active formats at cursor position
  DetectActiveFormatsUseCase get detectActiveFormatsUseCase {
    _ensureInitialized();
    return _detectActiveFormatsUseCase;
  }

  /// Get use case for validating link URLs
  ValidateLinkUseCase get validateLinkUseCase {
    _ensureInitialized();
    return _validateLinkUseCase;
  }

  /// Get use case for parsing formatted text into segments
  ParseFormattedTextUseCase get parseFormattedTextUseCase {
    _ensureInitialized();
    return _parseFormattedTextUseCase;
  }

  /// Get rich text repository
  RichTextRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'RichTextServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing)
  Future<void> reset() async {
    _isInitialized = false;
  }
}
