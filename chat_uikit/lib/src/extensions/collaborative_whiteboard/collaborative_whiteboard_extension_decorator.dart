import 'package:flutter/material.dart';

import '../../../../../cometchat_chat_uikit.dart';

///[CollaborativeWhiteBoardExtensionDecorator] is a the view model for [CollaborativeWhiteBoardExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class CollaborativeWhiteBoardExtensionDecorator extends DataSourceDecorator {
  String collaborativeWhiteBoardExtensionTypeConstant =
      ExtensionType.whiteboard;
  CollaborativeWhiteBoardConfiguration? configuration;

  User? loggedInUser;

  CollaborativeWhiteBoardExtensionDecorator(super.dataSource,
      {this.configuration}) {
    getLoggedInUser();
  }

  CometChatAttachmentOptionSheetStyle? _attachmentStyle;

  getLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
  }

  @override
  String getId() {
    return "CollaborativeWhiteBoard";
  }

  @override
  List<String> getAllMessageTypes() {
    List<String> ab = super.getAllMessageTypes();
    ab.add(collaborativeWhiteBoardExtensionTypeConstant);

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

    if (additionalConfigurations?.hideCollaborativeWhiteboardOption != true && isNotThread(id)) {
      actions.add(getAttachmentOption(context, id, additionalConfigurations));
    }

    return actions;
  }

  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage? message = conversation.lastMessage;
    if (message != null &&
        message.type == collaborativeWhiteBoardExtensionTypeConstant &&
        message.category == MessageCategoryConstants.custom) {
      return Translations.of(context).customMessageWhiteboard;
    } else {
      return super.getLastConversationMessage(conversation, context);
    }
  }

  CometChatMessageTemplate getTemplate() {

    return CometChatMessageTemplate(
        type: collaborativeWhiteBoardExtensionTypeConstant,
        category: CometChatMessageCategory.custom,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return super.getDeleteMessageBubble(message, context, additionalConfigurations?.deletedBubbleStyle);
          }
          return getContentView(message as CustomMessage, context,alignment,additionalConfigurations?.collaborativeWhiteboardBubbleStyle);
        },
        options: CometChatUIKit.getDataSource().getCommonOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  Widget getContentView(
      CustomMessage customMessage, BuildContext context, BubbleAlignment alignment, CometChatCollaborativeBubbleStyle? collaborativeBubbleStyle) {

    return CometChatCollaborativeBubble(
      url: getWebViewUrl(customMessage),
      title: configuration?.title ??
          Translations.of(context).collaborativeWhiteboard,
      subtitle: configuration?.subtitle ??
          Translations.of(context).openWhiteboardSubtitle,
      buttonText:
          configuration?.buttonText ?? Translations.of(context).openWhiteboard,
      icon: configuration?.icon,
      previewImage: AssetConstants.collaborativeWhiteboardPreview,
      alignment: alignment,
      style: (configuration?.style ?? const CometChatCollaborativeBubbleStyle()).merge(collaborativeBubbleStyle),
    );
  }

  sendCollaborativeWhiteBoard(
      BuildContext context, String receiverID, String receiverType) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    CometChat.callExtension(
        ExtensionConstants.whiteboard,
        "POST",
        ExtensionUrls.whiteboard,
        {"receiver": receiverID, "receiverType": receiverType},
        onSuccess: (Map<String, dynamic> map) {
      debugPrint("Success map $map");
    }, onError: (CometChatException e) {
      debugPrint('$e');
      String error = getErrorTranslatedText(context, e.code);
      CometChatConfirmDialog(
          context: context,
          messageText: Text(
            error,
            style: TextStyle(
              color: colorPalette.textPrimary,
              fontFamily: typography.heading4?.regular?.fontFamily,
              fontWeight: typography.heading4?.regular?.fontWeight,
              fontSize: typography.heading4?.regular?.fontSize,
            ),
          ),
          confirmButtonText: Translations.of(context).tryAgain,
          cancelButtonText: Translations.of(context).cancelCapital,
          onConfirm: () {
            Navigator.pop(context);
            sendCollaborativeWhiteBoard(context, receiverID, receiverType);
          }).show();
    });
  }

  CometChatMessageComposerAction getAttachmentOption(
      BuildContext context,
      Map<String, dynamic>? id,
      AdditionalConfigurations? additionalConfigurations) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    return CometChatMessageComposerAction(
        id: collaborativeWhiteBoardExtensionTypeConstant,
        title: configuration?.optionTitle ??
            Translations.of(context).collaborativeWhiteboard,
        icon: configuration?.optionIcon ??
            Image.asset(
              AssetConstants.whiteBoard,
              package: UIConstants.packageName,
              color: _attachmentStyle?.iconColor ?? colorPalette.iconHighlight,
              height: 24,
              width: 24,
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
          String receiverType = '';
          if (user != null) {
            uid = user.uid;
            receiverType = ReceiverTypeConstants.user;
          }
          if (group != null) {
            guid = group.guid;
            receiverType = ReceiverTypeConstants.group;
          }

          if (uid != null || guid != null) {
            sendCollaborativeWhiteBoard(
                context, uid ?? guid ?? '', receiverType);
          }
        });
  }

  String? getWebViewUrl(CustomMessage? messageObject) {
    if (messageObject != null &&
        messageObject.customData != null &&
        messageObject.customData!.containsKey("whiteboard")) {
      Map? whiteboard = messageObject.customData?["whiteboard"];
      if (whiteboard != null && whiteboard.containsKey("board_url")) {
        return whiteboard["board_url"];
      }
    }
    return null;
  }

  String getErrorTranslatedText(BuildContext context, String errorCode) {
    if (errorCode == "ERROR_INTERNET_UNAVAILABLE") {
      return Translations.of(context).errorInternetUnavailable;
    } else {}

    return Translations.of(context).somethingWentWrongError;
  }

  bool isNotThread(Map<String, dynamic>? id) {
    int? parentMessageId;
    if (id != null && id.containsKey('parentMessageId')) {
      parentMessageId = id['parentMessageId'];
    }
    return parentMessageId == 0 || parentMessageId == null;
  }
}
