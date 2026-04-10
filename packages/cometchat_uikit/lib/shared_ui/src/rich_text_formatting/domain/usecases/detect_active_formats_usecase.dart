import '../../../clean_architecture/core/result.dart';
import '../entities/entities.dart';
import '../repositories/rich_text_repository.dart';

/// Use case for detecting which formats are active at cursor position
///
/// Validates cursor position and delegates to repository.detectActiveFormats()
/// Returns Result<Set<FormatType>> with active formats or failure
class DetectActiveFormatsUseCase {
  final RichTextRepository repository;

  const DetectActiveFormatsUseCase(this.repository);

  /// Detect which formats are active at cursor position
  ///
  /// Validates:
  /// - Cursor position must be >= 0
  /// - Cursor position must be <= text.length
  ///
  /// Returns:
  /// - Success<Set<FormatType>> with active formats at position
  /// - Failure if validation fails or detection operation fails
  Future<Result<Set<FormatType>>> call({
    required String text,
    required int cursorPosition,
  }) async {
    // Validation: Cursor position range
    if (cursorPosition < 0 || cursorPosition > text.length) {
      return const Failure(
        message: 'Invalid cursor position',
        code: 'INVALID_CURSOR',
      );
    }

    // Delegate to repository
    return await repository.detectActiveFormats(
      text: text,
      cursorPosition: cursorPosition,
    );
  }
}
