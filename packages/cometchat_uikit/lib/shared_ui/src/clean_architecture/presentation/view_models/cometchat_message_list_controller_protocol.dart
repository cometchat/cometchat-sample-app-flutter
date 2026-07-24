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
  void initializeHeaderAndFooterView();
  void addMessage(BaseMessage message);

  void updateMessageWithMuid(BaseMessage message);

  void deleteMessage(BaseMessage message);

  void updateMessageThreadCount(int parentMessageId);
}
