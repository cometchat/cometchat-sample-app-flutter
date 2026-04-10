import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Base class for all message information events
/// Uses Equatable for proper event comparison in BLoC
abstract class MessageInformationEvent extends Equatable {
  const MessageInformationEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the message information with parent message
class InitializeMessageInformation extends MessageInformationEvent {
  final BaseMessage parentMessage;

  const InitializeMessageInformation({required this.parentMessage});

  @override
  List<Object?> get props => [parentMessage];
}

/// Fetch receipts for group message
class FetchMessageReceipts extends MessageInformationEvent {
  final int messageId;
  final String? senderUid;

  const FetchMessageReceipts({required this.messageId, this.senderUid});

  @override
  List<Object?> get props => [messageId, senderUid];
}

/// Update receipt when read event received
class ReceiptRead extends MessageInformationEvent {
  final MessageReceipt receipt;

  const ReceiptRead(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

/// Update receipt when delivered event received
class ReceiptDelivered extends MessageInformationEvent {
  final MessageReceipt receipt;

  const ReceiptDelivered(this.receipt);

  @override
  List<Object?> get props => [receipt];
}
