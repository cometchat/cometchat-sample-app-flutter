import 'package:flutter/material.dart';
import '../../../clean_architecture/core/result.dart';
import '../entities/entities.dart';
import '../repositories/rich_text_repository.dart';

/// Use case for applying formatting to text
///
/// Validates inputs and delegates to repository.applyFormat()
/// Returns Result<FormatResult> with success or failure
class ApplyFormatUseCase {
  final RichTextRepository repository;

  const ApplyFormatUseCase(this.repository);

  /// Apply formatting to text at selection
  ///
  /// Validates:
  /// - Text length must not exceed 50,000 characters
  /// - Selection range must be valid (start >= 0, end <= text.length)
  ///
  /// Returns:
  /// - Success<FormatResult> if formatting applied successfully
  /// - Failure if validation fails or formatting operation fails
  Future<Result<FormatResult>> call({
    required FormatType formatType,
    required String text,
    required TextSelection selection,
    LinkData? linkData,
  }) async {
    // Validation: Text length
    if (text.length > 50000) {
      return const Failure(
        message: 'Text too long for formatting',
        code: 'TEXT_TOO_LONG',
      );
    }

    // Validation: Selection range
    if (selection.start < 0 || selection.end > text.length) {
      return const Failure(
        message: 'Invalid selection range',
        code: 'INVALID_SELECTION',
      );
    }

    // Validation: Selection start must be <= end
    if (selection.start > selection.end) {
      return const Failure(
        message: 'Selection start must be less than or equal to end',
        code: 'INVALID_SELECTION',
      );
    }

    // Delegate to repository
    return await repository.applyFormat(
      formatType: formatType,
      text: text,
      selection: selection,
      linkData: linkData,
    );
  }
}
