import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for getting the currently logged-in user.
class GetCallLoggedInUserUseCase {
  final CallOperationsRepository repository;
  const GetCallLoggedInUserUseCase(this.repository);

  Future<Result<User?>> call() => repository.getLoggedInUser();
}
