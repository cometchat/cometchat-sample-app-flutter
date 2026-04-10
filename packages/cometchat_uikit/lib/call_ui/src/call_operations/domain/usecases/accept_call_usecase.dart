import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for accepting an incoming call.
class AcceptCallUseCase {
  final CallOperationsRepository repository;
  const AcceptCallUseCase(this.repository);

  Future<Result<Call>> call(String sessionId) async {
    if (sessionId.isEmpty) {
      return const Failure(message: 'Session ID is required', code: 'MISSING_SESSION_ID');
    }
    return repository.acceptCall(sessionId);
  }
}
