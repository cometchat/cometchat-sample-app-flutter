import '../../../../../cometchat_chat_uikit.dart';

/// Use case for resolving a message template by category and type.
class GetMessageTemplateUseCase {
  final ThreadedHeaderRepository repository;
  const GetMessageTemplateUseCase(this.repository);

  CometChatMessageTemplate? call({
    required String category,
    required String type,
  }) {
    return repository.getMessageTemplate(category: category, type: type);
  }
}

/// Use case for getting all message templates.
class GetAllMessageTemplatesUseCase {
  final ThreadedHeaderRepository repository;
  const GetAllMessageTemplatesUseCase(this.repository);

  List<CometChatMessageTemplate> call() => repository.getAllMessageTemplates();
}
