import 'package:flutter/material.dart';
import '../../../../../cometchat_chat_uikit.dart';

///[PollsExtensionDecorator] is a the view model for [PollsExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class PollsExtensionDecorator extends DataSourceDecorator {
  String pollsTypeConstant = "extension_poll";
  PollsConfiguration? configuration;

  User? loggedInUser;

  PollsExtensionDecorator(super.dataSource, {this.configuration}) {
    getLoggedInUser();
  }

  getLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
  }

  CometChatAttachmentOptionSheetStyle? _attachmentStyle;

  @override
  String getId() {
    return "Polls";
  }

  @override
  List<String> getAllMessageTypes() {
    List<String> ab = super.getAllMessageTypes();
    ab.add(pollsTypeConstant);

    return ab;
  }

  @override
  List<String> getAllMessageCategories() {
    List<String> categoryList = super.getAllMessageCategories();
    if (!categoryList.contains(MessageCategoryConstants.custom)) {
      categoryList.add(MessageCategoryConstants.custom);
    }
    return categoryList;
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {

    List<CometChatMessageTemplate> templateList =
        super.getAllMessageTemplates();

    templateList.add(getTemplate());

    return templateList;
  }

  @override
  List<CometChatMessageComposerAction> getAttachmentOptions(
      BuildContext context,
      Map<String, dynamic>? id,
      AdditionalConfigurations? additionalConfigurations) {
    _attachmentStyle = CometChatAttachmentOptionSheetStyle(
      border: additionalConfigurations?.attachmentOptionSheetStyle?.border ??
          configuration?.optionStyle?.attachmentOptionSheetStyle?.border,
      borderRadius: additionalConfigurations
              ?.attachmentOptionSheetStyle?.borderRadius ??
          configuration?.optionStyle?.attachmentOptionSheetStyle?.borderRadius,
      titleTextStyle: additionalConfigurations
              ?.attachmentOptionSheetStyle?.titleTextStyle ??
          configuration
              ?.optionStyle?.attachmentOptionSheetStyle?.titleTextStyle,
      iconColor:
          additionalConfigurations?.attachmentOptionSheetStyle?.iconColor ??
              configuration?.optionStyle?.attachmentOptionSheetStyle?.iconColor,
      backgroundColor: additionalConfigurations
              ?.attachmentOptionSheetStyle?.backgroundColor ??
          configuration
              ?.optionStyle?.attachmentOptionSheetStyle?.backgroundColor,
      titleColor: additionalConfigurations
              ?.attachmentOptionSheetStyle?.titleColor ??
          configuration?.optionStyle?.attachmentOptionSheetStyle?.titleColor,
    );
    List<CometChatMessageComposerAction> actions =
        super.getAttachmentOptions(context, id, additionalConfigurations);

    if (additionalConfigurations?.hidePollsOption != true && isNotThread(id)) {
      actions.add(getAttachmentOption(context, id, additionalConfigurations));
    }

    return actions;
  }

  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage? message = conversation.lastMessage;
    if (message != null &&
        message.type == pollsTypeConstant &&
        message.category == MessageCategoryConstants.custom) {
      return Translations.of(context).customMessagePoll;
    } else {
      return super.getLastConversationMessage(conversation, context);
    }
  }

  CometChatMessageTemplate getTemplate() {

    return CometChatMessageTemplate(
        type: pollsTypeConstant,
        category: CometChatMessageCategory.custom,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {

          if (message.deletedAt != null) {
            return super.getDeleteMessageBubble(message, context, additionalConfigurations?.deletedBubbleStyle);
          }
          return getContentView(message as CustomMessage, context,alignment,additionalConfigurations?.pollsBubbleStyle);

        },
        options: CometChatUIKit.getDataSource().getCommonOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  Widget getContentView(
      CustomMessage customMessage, BuildContext context,BubbleAlignment alignment, CometChatPollsBubbleStyle?  pollsBubbleStyle) {

    return CometChatPollsBubble(
      loggedInUser: loggedInUser?.uid,
      choosePoll: choosePoll,
      senderUid: customMessage.sender?.uid,
      pollQuestion: customMessage.customData?["question"] ?? "",
      pollId: customMessage.customData?["id"],
      metadata: getPollsResult(customMessage),
      style:
          (configuration?.pollsBubbleStyle ?? const CometChatPollsBubbleStyle())
              .merge(pollsBubbleStyle),
      alignment: alignment,
    );
  }

  CometChatMessageComposerAction getAttachmentOption(
      BuildContext context,
      Map<String, dynamic>? id,
      AdditionalConfigurations? additionalConfigurations) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    return CometChatMessageComposerAction(
      id: pollsTypeConstant,
      title: configuration?.optionTitle ?? '${Translations.of(context).poll}s',
      icon: configuration?.optionIcon ??
          Icon(
            Icons.menu,
            color: _attachmentStyle?.iconColor ?? colorPalette.iconHighlight,
            size: 24,
          ),
      style: CometChatAttachmentOptionSheetStyle(
        iconColor: _attachmentStyle?.iconColor ?? colorPalette.iconHighlight,
        titleTextStyle: TextStyle(
          color: _attachmentStyle?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(_attachmentStyle?.titleTextStyle),
        titleColor: _attachmentStyle?.titleColor,
        backgroundColor: _attachmentStyle?.backgroundColor,
        border: _attachmentStyle?.border,
        borderRadius: _attachmentStyle?.borderRadius,
      ),
      onItemClick: (context, user, group) {
        String? uid, guid;
        if (user != null) {
          uid = user.uid;
        }
        if (group != null) {
          guid = group.guid;
        }
        if (uid != null || guid != null) {
          showCometChatCreatePoll(
            context: context,
            colorPalette: colorPalette,
            spacing: spacing,
            uid: uid,
            guid: guid,
            title: configuration?.title,
          );
        }
      },
    );
  }

  Future<void> choosePoll(String vote, String id) async {
    Map<String, dynamic> body = {"vote": vote, "id": id};

    await CometChat.callExtension(
      ExtensionConstants.polls,
      "POST",
      ExtensionUrls.votePoll,
      body,
      onSuccess: (Map<String, dynamic> map) {},
      onError: (CometChatException e) {
        debugPrint('${e.message}');
      },
    );
  }

  Map<String, dynamic> getPollsResult(BaseMessage baseMessage) {
    Map<String, dynamic> result = {};
    Map<String, Map>? extensionList =
        ExtensionModerator.extensionCheck(baseMessage);
    if (extensionList != null) {
      try {
        if (extensionList.containsKey(ExtensionConstants.polls)) {
          Map? polls = extensionList[ExtensionConstants.polls];
          if (polls != null) {
            if (polls.containsKey("results")) {
              result = polls["results"];
            }
          }
        }
      } catch (e, stacktrace) {
        debugPrint("$stacktrace");
      }
    }
    return result;
  }

  bool isNotThread(Map<String, dynamic>? id) {
    int? parentMessageId;
    if (id != null && id.containsKey('parentMessageId')) {
      parentMessageId = id['parentMessageId'];
    }
    return parentMessageId == 0 || parentMessageId == null;
  }
}
