import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/call_operations_repository.dart';

/// Use case for sending a meeting custom message.
class SendMeetingMessageUseCase {
  final CallOperationsRepository repository;
  const SendMeetingMessageUseCase(this.repository);

  Future<Result<CustomMessage>> call(CustomMessage message) =>
      repository.sendCustomMessage(message);
}
