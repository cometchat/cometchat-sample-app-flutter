import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:flutter/widgets.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for starting a call session with a token and settings.
class StartSessionUseCase {
  final CallOperationsRepository repository;
  const StartSessionUseCase(this.repository);

  Future<Result<Widget>> call(String callToken, SessionSettings settings) async {
    if (callToken.isEmpty) {
      return const Failure(message: 'Call token is required', code: 'MISSING_CALL_TOKEN');
    }
    return repository.startSession(callToken, settings);
  }
}
