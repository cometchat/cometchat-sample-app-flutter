import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/src/ai/ai_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///[AISmartRepliesDecorator] is a the view model for [AiSmartReplyExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class AISmartRepliesDecorator extends DataSourceDecorator
    with CometChatUIEventListener, CometChatMessageEventListener {
  late String dateStamp = "";
  late String _listenerId = "";
  User? loggedInUser;
  AISmartRepliesConfiguration? configuration;

  AISmartRepliesDecorator(super.dataSource, {this.configuration}) {
    CometChatUIEvents.removeUiListener(_listenerId);
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    _listenerId = "AiSmartReply$dateStamp";
    closeCall();
    CometChatUIEvents.addUiListener(_listenerId, this);
    CometChatMessageEvents.addMessagesListener(_listenerId, this);
    getLoggedInUser();
  }

  getLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
  }

  closeCall() {
    CometChatMessageEvents.removeMessagesListener(_listenerId);
    CometChatUIEvents.removeUiListener(_listenerId);
  }

  @override
  List<CometChatMessageComposerAction> getAIOptions(
      User? user,
      Group? group,
      BuildContext context,
      Map<String, dynamic>? id,
      AIOptionsStyle? aiOptionStyle,
      ) {
    List<CometChatMessageComposerAction> actionList =
        super.getAIOptions(user, group, context, id, aiOptionStyle);
    actionList.add(getAIComposerButton(context));
    return actionList;
  }

  CometChatMessageComposerAction getAIComposerButton(
      BuildContext context) {
    return CometChatMessageComposerAction(
      id: getId(),
      icon: Image.asset(
        AssetConstants.aiSuggestReply,
        height: 24,
        width: 24,
        package: UIConstants.packageName,
      ),
      title: cc.Translations.of(context).suggestAReply.toLowerCase().capitalizeFirst ?? "",
      onItemClick: (BuildContext context, User? user, Group? group) {
        checkAndShowReplies(user, group);
      },
    );
  }

  checkAndShowReplies(User? user, Group? group) async {
    Map<String, dynamic>? apiMap;

    if (configuration != null && configuration?.apiConfiguration != null) {
      apiMap = await configuration?.apiConfiguration!(user, group);
    }

    Map<String, dynamic> id = {};
    String receiverId = "";
    id[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
    if (user != null) {
      receiverId = user.uid;
      id['uid'] = receiverId;
    } else if (group != null) {
      receiverId = group.guid;
      id['guid'] = receiverId;
    }

    CometChatUIEvents.showPanel(
      id,
      CustomUIPosition.composerTop,
      (context) => CometChatAISmartRepliesView(
        style: configuration?.smartRepliesStyle,
        theme: configuration?.theme ?? cometChatTheme,
        user: user,
        group: group,
        emptyStateText: configuration?.emptyStateText,
        errorStateText: configuration?.errorStateText,
        onError: configuration?.onError,
        customView: configuration?.customView,
        loadingStateText: configuration?.loadingStateText,
        emptyIconUrl: configuration?.emptyIconUrl,
        loadingStateView: configuration?.loadingStateView,
        loadingIconUrl: configuration?.loadingIconUrl,
        errorStateView: configuration?.errorStateView,
        emptyStateView: configuration?.emptyStateView,
        errorIconUrl: configuration?.errorIconUrl,
        apiConfiguration: apiMap,
      ),
    );
  }

  @override
  String getId() {
    return "aismartreply";
  }

  @override
  void onSchedulerMessageReceived(SchedulerMessage schedulerMessage) {
    Map<String, dynamic> id = {};

    if (schedulerMessage.receiver is User) {
      id['uid'] = (schedulerMessage.sender as User).uid;
    } else if (schedulerMessage.receiver is Group) {
      id['guid'] = (schedulerMessage.receiver as Group).guid;
    }

    if (schedulerMessage.parentMessageId != 0) {
      id['parentMessageId'] = schedulerMessage.parentMessageId;
    }
    id[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
    CometChatUIEvents.hidePanel(id, CustomUIPosition.composerTop);
  }
}
