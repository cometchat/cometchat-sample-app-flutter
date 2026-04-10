import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_logs_repository.dart';

/// Use case for getting call logs with pagination support.
/// Handles business logic for fetching initial call log lists.
class GetCallLogsUseCase {
  final CallLogsRepository repository;

  const GetCallLogsUseCase(this.repository);

  /// Execute the use case to get call logs.
  ///
  /// [limit] - Maximum number of call logs to fetch (default: 30)
  ///
  /// Returns Result<List<CallLog>> containing call logs or failure.
  Future<Result<List<CallLog>>> call({
    int limit = 30,
  }) async {
    // Validate input parameters
    if (limit <= 0) {
      return const Failure(
        message: 'Limit must be greater than 0',
        code: 'INVALID_LIMIT',
      );
    }

    if (limit > 100) {
      return const Failure(
        message: 'Limit cannot exceed 100 call logs',
        code: 'LIMIT_TOO_HIGH',
      );
    }

    // Delegate to repository
    return await repository.getCallLogs(
      limit: limit,
    );
  }
}
