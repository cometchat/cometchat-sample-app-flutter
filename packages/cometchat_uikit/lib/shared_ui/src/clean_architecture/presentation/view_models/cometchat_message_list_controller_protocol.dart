import '../../../../cometchat_uikit_shared.dart';
import 'package:flutter/widgets.dart';

abstract class CometChatMessageListControllerProtocol
    extends CometChatSearchListControllerProtocol<BaseMessage> {
  Map<String, CometChatMessageTemplate> getTemplateMap();
  ScrollController getScrollController();
  int? getParentMessageId();
  Group? getGroup();
  User? getUser();
  BuildContext getCurrentContext();
  String getConversationId();
  initializeHeaderAndFooterView();
  addMessage(BaseMessage message);

  updateMessageWithMuid(BaseMessage message);

  deleteMessage(BaseMessage message);

  updateMessageThreadCount(int parentMessageId);
}
