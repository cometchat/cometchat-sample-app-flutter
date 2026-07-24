import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for rejecting or cancelling a call.
class RejectCallUseCase {
  final CallOperationsRepository repository;
  const RejectCallUseCase(this.repository);

  Future<Result<Call>> call(String sessionId, String status) async {
    if (sessionId.isEmpty) {
      return const Failure(
        message: 'Session ID is required',
        code: 'MISSING_SESSION_ID',
      );
    }
    return repository.rejectCall(sessionId, status);
  }
}
