import '../../../clean_architecture/core/result.dart';
import '../entities/entities.dart';
import '../repositories/rich_text_repository.dart';

/// Use case for parsing formatted text into segments
///
/// Delegates to repository.parseFormattedText()
/// Returns `Result<List<FormattedSegment>>` with parsed segments or failure
class ParseFormattedTextUseCase {
  final RichTextRepository repository;

  const ParseFormattedTextUseCase(this.repository);

  /// Parse formatted text into segments
  ///
  /// No validation required - repository handles all parsing logic
  ///
  /// Returns:
  /// - `Success<List<FormattedSegment>>` with parsed segments
  /// - Failure if parsing operation fails
  Future<Result<List<FormattedSegment>>> call(String text) async {
    // Delegate to repository
    return await repository.parseFormattedText(text);
  }
}
