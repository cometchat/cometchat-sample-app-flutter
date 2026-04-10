import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for getting the user auth token.
class GetUserAuthTokenUseCase {
  final CallOperationsRepository repository;
  const GetUserAuthTokenUseCase(this.repository);

  Future<Result<String?>> call() => repository.getUserAuthToken();
}
