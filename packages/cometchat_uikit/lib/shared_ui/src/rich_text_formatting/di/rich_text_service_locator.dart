import '../../formatter/rich_text/rich_text_configuration.dart';
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

  /// Initialize all dependencies based on configuration
  /// Call this once during app startup or before using rich text formatting module
  ///
  /// Parameters:
  /// - [configuration]: Rich text configuration specifying which formatters to enable
  void setup(RichTextConfiguration configuration) {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize formatters based on configuration flags
    final Map<FormatType, FormatterDataSource> formatters = {};

    if (configuration.enableBold) {
      formatters[FormatType.bold] = BoldFormatterDataSource();
    }

    if (configuration.enableItalic) {
      formatters[FormatType.italic] = ItalicFormatterDataSource();
    }

    if (configuration.enableUnderline) {
      formatters[FormatType.underline] = UnderlineFormatterDataSource();
    }

    if (configuration.enableStrikethrough) {
      formatters[FormatType.strikethrough] = StrikethroughFormatterDataSource();
    }

    if (configuration.enableInlineCode) {
      formatters[FormatType.inlineCode] = InlineCodeFormatterDataSource();
    }

    if (configuration.enableCodeBlock) {
      formatters[FormatType.codeBlock] = CodeBlockFormatterDataSource();
    }

    if (configuration.enableLinks) {
      formatters[FormatType.link] = LinkFormatterDataSource();
    }

    if (configuration.isBulletListEnabled) {
      formatters[FormatType.bulletList] = BulletListFormatterDataSource();
    }

    if (configuration.isOrderedListEnabled) {
      formatters[FormatType.orderedList] = OrderedListFormatterDataSource();
    }

    if (configuration.isBlockquoteEnabled) {
      formatters[FormatType.blockquote] = BlockquoteFormatterDataSource();
    }

    // Initialize repository with formatters map
    _repository = RichTextRepositoryImpl(formatters: formatters);

    // Initialize use cases with repository
    _applyFormatUseCase = ApplyFormatUseCase(_repository);
    _detectActiveFormatsUseCase = DetectActiveFormatsUseCase(_repository);
    _validateLinkUseCase = ValidateLinkUseCase(_repository);
    _parseFormattedTextUseCase = ParseFormattedTextUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  // Use case getters

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

  // Repository getter (for advanced use cases)

  /// Get rich text repository
  RichTextRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'RichTextServiceLocator is not initialized. '
        'Call setup() with RichTextConfiguration before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing)
  Future<void> reset() async {
    _isInitialized = false;
    // Dependencies will be re-initialized on next setup() call
  }
}
