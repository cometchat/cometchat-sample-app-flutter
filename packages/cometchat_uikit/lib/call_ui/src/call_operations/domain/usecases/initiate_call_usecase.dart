import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for initiating a direct call to a user.
class InitiateDirectCallUseCase {
  final CallOperationsRepository repository;
  const InitiateDirectCallUseCase(this.repository);

  Future<Result<Call>> call(Call callObject) async {
    if (callObject.receiverUid.isEmpty) {
      return const Failure(
        message: 'Receiver UID is required',
        code: 'MISSING_RECEIVER_UID',
      );
    }
    return repository.initiateCall(callObject);
  }
}
