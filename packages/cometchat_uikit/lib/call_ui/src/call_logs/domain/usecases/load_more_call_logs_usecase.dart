import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_logs_repository.dart';

/// Use case for loading more call logs with pagination support.
/// Handles business logic for fetching additional call log pages.
class LoadMoreCallLogsUseCase {
  final CallLogsRepository repository;

  const LoadMoreCallLogsUseCase(this.repository);

  /// Execute the use case to load more call logs.
  ///
  /// [limit] - Maximum number of call logs to fetch (default: 30)
  /// [currentCallLogs] - Currently loaded call logs to prevent duplicates
  ///
  /// Returns Result<List<CallLog>> containing additional call logs or failure.
  Future<Result<List<CallLog>>> call({
    int limit = 30,
    List<CallLog>? currentCallLogs,
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

    // Delegate to repository to fetch more call logs
    final result = await repository.getCallLogs(
      limit: limit,
    );

    // Handle deduplication if current call logs are provided
    return result.map((newCallLogs) {
      if (currentCallLogs == null || currentCallLogs.isEmpty) {
        return newCallLogs;
      }

      // Create a set of existing session IDs for efficient lookup
      final existingIds = currentCallLogs.map((c) => c.sessionId).toSet();

      // Filter out any call logs that already exist
      final filteredCallLogs = newCallLogs
          .where((callLog) => !existingIds.contains(callLog.sessionId))
          .toList();

      return filteredCallLogs;
    });
  }
}
