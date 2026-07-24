import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Represents a stream message in the chat.
///
/// Extends [AIAssistantMessage] and initializes with predefined
/// [type] = "run_started" and [category] = "custom".
class StreamMessage extends AIAssistantMessage {
  StreamMessage({
    super.runId,
    super.threadId,
    required String super.text,
    super.tags,
    super.id,
    String super.muid = '',
    super.sender,
    super.receiver,
    required super.receiverUid,
    required super.receiverType,
    super.sentAt,
    super.deliveredAt,
    super.readAt,
    super.metadata,
    super.readByMeAt,
    super.deliveredToMeAt,
    super.deletedAt,
    super.editedAt,
    super.deletedBy,
    super.editedBy,
    super.updatedAt,
    super.conversationId,
    super.parentMessageId,
  }) : super(
         type: CometChatMessageType.runStarted,
         category: CometChatMessageCategory.streamMessage,
       );

  StreamMessage copyWith({
    int? runId,
    String? threadId,
    String? text,
    List<String>? tags,
    int? id,
    String? muid,
    User? sender,
    AppEntity? receiver,
    String? receiverUid,
    String? receiverType,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
    DateTime? readByMeAt,
    DateTime? deliveredToMeAt,
    DateTime? deletedAt,
    DateTime? editedAt,
    String? deletedBy,
    String? editedBy,
    DateTime? updatedAt,
    String? conversationId,
    int? parentMessageId,
  }) {
    return StreamMessage(
      runId: runId ?? this.runId,
      threadId: threadId ?? this.threadId,
      text: text ?? this.text ?? '',
      tags: tags ?? this.tags,
      id: id ?? this.id,
      muid: muid ?? this.muid,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      receiverUid: receiverUid ?? this.receiverUid,
      receiverType: receiverType ?? this.receiverType,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
      readByMeAt: readByMeAt ?? this.readByMeAt,
      deliveredToMeAt: deliveredToMeAt ?? this.deliveredToMeAt,
      deletedAt: deletedAt ?? this.deletedAt,
      editedAt: editedAt ?? this.editedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      conversationId: conversationId ?? this.conversationId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
    );
  }
}
