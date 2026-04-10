import 'package:cometchat_sdk/cometchat_sdk.dart';

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_logs_repository.dart';

/// Use case for initiating a call from a call log entry.
/// Handles business logic for call initiation.
class InitiateCallUseCase {
  final CallLogsRepository repository;

  const InitiateCallUseCase(this.repository);

  /// Execute the use case to initiate a call.
  ///
  /// [call] - The call object containing receiver details and call type
  ///
  /// Returns Result<Call> containing the initiated call or failure.
  Future<Result<Call>> call(Call callObject) async {
    // Validate call object - these are required non-nullable fields,
    // but we still validate they're not empty strings
    if (callObject.receiverUid.isEmpty) {
      return const Failure(
        message: 'Receiver UID is required',
        code: 'MISSING_RECEIVER_UID',
      );
    }

    if (callObject.receiverType.isEmpty) {
      return const Failure(
        message: 'Receiver type is required',
        code: 'MISSING_RECEIVER_TYPE',
      );
    }

    if (callObject.type.isEmpty) {
      return const Failure(
        message: 'Call type is required',
        code: 'MISSING_CALL_TYPE',
      );
    }

    // Delegate to repository
    return await repository.initiateCall(callObject);
  }
}
