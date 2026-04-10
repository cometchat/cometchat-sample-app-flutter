import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for ending the current WebRTC session.
class EndSessionUseCase {
  final CallOperationsRepository repository;
  const EndSessionUseCase(this.repository);

  Future<Result<void>> call() => repository.endSession();
}
