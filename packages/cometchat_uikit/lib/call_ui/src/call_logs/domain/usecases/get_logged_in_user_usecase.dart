import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_logs_repository.dart';

/// Use case for getting the currently logged-in user.
/// Handles business logic for user retrieval.
class GetLoggedInUserUseCase {
  final CallLogsRepository repository;

  const GetLoggedInUserUseCase(this.repository);

  /// Execute the use case to get logged-in user.
  ///
  /// Returns `Result<User?>` containing user or null if not logged in.
  Future<Result<User?>> call() async {
    return await repository.getLoggedInUser();
  }
}
