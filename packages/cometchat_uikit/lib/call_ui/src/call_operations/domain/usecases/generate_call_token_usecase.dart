import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for generating a call token to join a session.
class GenerateCallTokenUseCase {
  final CallOperationsRepository repository;
  const GenerateCallTokenUseCase(this.repository);

  Future<Result<String>> call(String sessionId) async {
    if (sessionId.isEmpty) {
      return const Failure(message: 'Session ID is required', code: 'MISSING_SESSION_ID');
    }
    return repository.generateCallToken(sessionId);
  }
}
