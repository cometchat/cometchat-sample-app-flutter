import '../../../../../cometchat_chat_uikit.dart';

/// Data source for threaded header template resolution.
abstract class ThreadedHeaderDataSource {
  CometChatMessageTemplate? getMessageTemplate({
    required String category,
    required String type,
  });
  List<CometChatMessageTemplate> getAllMessageTemplates();
}

/// Implementation using MessageTemplateUtils.
class ThreadedHeaderDataSourceImpl implements ThreadedHeaderDataSource {
  @override
  CometChatMessageTemplate? getMessageTemplate({
    required String category,
    required String type,
  }) {
    return MessageTemplateUtils.getMessageTemplate(
      messageCategory: category,
      messageType: type,
    );
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    return MessageTemplateUtils.getAllMessageTemplates();
  }
}
