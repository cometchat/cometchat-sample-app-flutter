import '../../../clean_architecture/core/result.dart';
import '../repositories/rich_text_repository.dart';

/// Use case for validating a URL for link formatting
///
/// Validates URL is not empty and delegates to repository.validateLink()
/// Returns Result<bool> indicating if URL is valid
class ValidateLinkUseCase {
  final RichTextRepository repository;

  const ValidateLinkUseCase(this.repository);

  /// Validate a URL for link formatting
  ///
  /// Validates:
  /// - URL must not be empty
  ///
  /// Returns:
  /// - Success<bool> with true if URL is valid, false otherwise
  /// - Failure if URL is empty or validation operation fails
  Future<Result<bool>> call(String url) async {
    // Validation: URL must not be empty
    if (url.isEmpty) {
      return const Failure(
        message: 'URL cannot be empty',
        code: 'EMPTY_URL',
      );
    }

    // Delegate to repository
    return await repository.validateLink(url);
  }
}
