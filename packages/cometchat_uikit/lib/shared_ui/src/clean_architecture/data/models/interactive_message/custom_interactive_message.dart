import "package:cometchat_sdk/cometchat_sdk.dart" hide CardMessage;
import '../../../../../cometchat_uikit_shared.dart'
    show MessageTypeConstants, MessageCategoryConstants, ModelFieldConstants;
import '../interactive_elements/element_entity.dart';

/// Represents a message that includes various types of messages for interactive elements.
class CustomInteractiveMessage extends InteractiveMessage {
  /// Creates a new [CustomInteractiveMessage] instance.
  /// The rest of the parameters are optional and are inherited from [InteractiveMessage].
  CustomInteractiveMessage({
    required this.customData,
    required this.subType,
    tags,
    int? id,
    String? muid,
    super.sender,
    super.receiver,
    required super.receiverUid,
    super.type = MessageTypeConstants.customInteractive,
    required super.receiverType,
    String? category = MessageCategoryConstants.interactive,
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
    int? parentMessageId,
    int? replyCount,
  }) : super(
         id: id ?? 0,
         muid: muid ?? '',
         parentMessageId: parentMessageId ?? 0,
         replyCount: replyCount ?? 0,
         interactiveData: {ModelFieldConstants.customData: customData},
       );

  Map<String, dynamic> customData;
  String subType;

  InteractiveMessage toInteractiveMessage() {
    interactiveData[ModelFieldConstants.customData] = customData;
    return this;
  }

  factory CustomInteractiveMessage.fromInteractiveMessage(
    InteractiveMessage message,
  ) {
    List<ElementEntity> elementList = [];
    if (message.interactiveData[ModelFieldConstants.formFields] != null) {
      for (var element
          in (message.interactiveData[ModelFieldConstants.formFields]
              as List)) {
        elementList.add(ElementEntity.fromMap(element));
      }
    }

    return CustomInteractiveMessage(
      id: message.id,
      receiverType: message.receiverType,
      tags: message.tags,
      muid: message.muid,
      sender: message.sender,
      receiver: message.sender,
      receiverUid: message.receiverUid,
      type: message.type,
      category: message.category,
      sentAt: message.sentAt,
      deliveredAt: message.deliveredAt,
      readAt: message.readAt,
      metadata: message.metadata,
      readByMeAt: message.readByMeAt,
      deliveredToMeAt: message.deliveredToMeAt,
      deletedAt: message.deletedAt,
      editedAt: message.editedAt,
      deletedBy: message.deletedBy,
      editedBy: message.editedBy,
      updatedAt: message.updatedAt,
      conversationId: message.conversationId,
      parentMessageId: message.parentMessageId,
      replyCount: message.replyCount,
      customData: message.interactiveData[ModelFieldConstants.customData],
      subType: message.interactiveData[ModelFieldConstants.subType],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map[ModelFieldConstants.customData] = customData;

    return map;
  }
}
