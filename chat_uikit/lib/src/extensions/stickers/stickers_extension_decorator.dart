import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[StickersExtensionDecorator] is a the view model for [StickersExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class StickersExtensionDecorator extends DataSourceDecorator
    with CometChatMessageEventListener, CometChatUIEventListener {
  String stickerTypeConstant = "extension_sticker";
  StickerConfiguration? configuration;

  StickersExtensionDecorator(super.dataSource, {this.configuration}) {
    CometChatMessageEvents.addMessagesListener(stickerTypeConstant, this);
    CometChatUIEvents.addUiListener(stickerTypeConstant, this);
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    List<CometChatMessageTemplate> templateList =
        super.getAllMessageTemplates();
    templateList.add(getTemplate());

    return templateList;
  }

  @override
  Widget getAuxiliaryOptions(User? user, Group? group, BuildContext context,
      Map<String, dynamic>? id, Color? color,
      {AdditionalConfigurations? additionalConfigurations}) {
    List<Widget> auxiliaryButtons = [];

    Widget auxiliaryOption = super.getAuxiliaryOptions(
        user, group, context, id, color,
        additionalConfigurations: additionalConfigurations);
    auxiliaryButtons.add(auxiliaryOption);
    if (additionalConfigurations?.hideStickersButton != true) {
      auxiliaryButtons
          .add(getStickerAuxiliaryButton(user, group, context, id, color));
    }

    return auxiliaryButtons.isEmpty
        ? const SizedBox()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [...auxiliaryButtons],
          );
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
  List<String> getAllMessageTypes() {
    List<String> ab = super.getAllMessageTypes();
    ab.add(stickerTypeConstant);
    return ab;
  }

  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage? message = conversation.lastMessage;
    if (message != null &&
        message.type == stickerTypeConstant &&
        message.category == MessageCategoryConstants.custom) {
      return Translations.of(context).customMessageSticker;
    } else {
      return super.getLastConversationMessage(conversation, context);
    }
  }

  BaseMessage? quotedMessage;

  @override
  void ccReplyToMessage(BaseMessage message, MessageStatus status) {
    if (status == MessageStatus.inProgress) {
      quotedMessage = message;
    }
    // Clear quotedMessage when any reply is sent or errors out
    if (status == MessageStatus.error || status == MessageStatus.sent) {
      quotedMessage = null;
    }
  }

  @override
  void ccMessageSent(BaseMessage message, MessageStatus messageStatus) {
    // Clear quotedMessage when ANY message is successfully sent
    // This ensures the quoted message doesn't persist to subsequent stickers
    if (messageStatus == MessageStatus.sent || messageStatus == MessageStatus.error) {
      quotedMessage = null;
    }
  }

  @override
  void ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage,
      User? user, Group? group, int unreadMessageCount) {
    // Clear quotedMessage when user switches to a different chat
    quotedMessage = null;
  }

  CometChatMessageTemplate getTemplate() {
    return CometChatMessageTemplate(
      type: stickerTypeConstant,
      category: CometChatMessageCategory.custom,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return super.getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        } else {
          return CometChatStickerBubble(
            message: (message as CustomMessage),
            height: configuration?.stickerBubbleHeight,
            width: configuration?.stickerBubbleWidth,
            stickerUrl: configuration?.stickerUrl,
            style: additionalConfigurations?.stickerBubbleStyle,
          );
        }
      },
      options: CometChatUIKit.getDataSource().getCommonOptions,
      bottomView: CometChatUIKit.getDataSource().getBottomView,
      replyView: CometChatUIKit.getDataSource().getReplyView,
    );
  }

  bool _isSendingSticker = false;

  getStickerAuxiliaryButton(User? user, Group? group, BuildContext context,
      Map<String, dynamic>? id, Color? color) {
    onStickerTap(Sticker st) async {
      // Prevent multiple rapid taps from sending multiple stickers
      if (_isSendingSticker) {
        return;
      }
      _isSendingSticker = true;

      int? getQuotedMessageId = ReplyUtils.getQuotedMessageId(
          quotedMessage: quotedMessage, user: user, group: group);
      if (getQuotedMessageId != null && getQuotedMessageId == -1) {
        quotedMessage = null;
      }

      Map<String, String> customData = {};
      customData["sticker_url"] = st.stickerUrl;
      customData["sticker_name"] = st.stickerName;

      String receiverID;
      String receiverType;
      int parentMessageId = id?['parentMessageId'] ?? 0;

      if (user != null) {
        receiverID = user.uid;
        receiverType = ReceiverTypeConstants.user;
      } else {
        receiverID = group!.guid;
        receiverType = ReceiverTypeConstants.group;
      }

      User? loggedInUser = await CometChat.getLoggedInUser();
      if (loggedInUser != null) {
        CustomMessage customMessage = CustomMessage(
          receiverUid: receiverID,
          type: stickerTypeConstant,
          customData: customData,
          receiverType: receiverType,
          sender: loggedInUser,
          category: CometChatMessageCategory.custom,
          parentMessageId: parentMessageId,
          muid: DateTime.now().microsecondsSinceEpoch.toString(),
          updateConversation: true,
          metadata: {
            UpdateSettingsConstant.incrementUnreadCount: true,
          },
        );

        if (quotedMessage != null) {
          customMessage.quotedMessage = quotedMessage;
          customMessage.quotedMessageId = quotedMessage!.id;
        }

        if (quotedMessage != null) {
          CometChatMessageEvents.ccReplyToMessage(
              quotedMessage!, MessageStatus.sent);
          quotedMessage = null;
        }

        CometChatUIKit.sendCustomMessage(customMessage,
            onSuccess: (customMessage) {
          _isSendingSticker = false;
        }, onError: (error) {
          _isSendingSticker = false;
          if (quotedMessage != null) {
            quotedMessage = null;
          }
        });
      } else {
        _isSendingSticker = false;
      }
    }

    return StickerAuxiliaryButton(
      keyboardButtonIcon: configuration?.keyboardButtonIcon,
      stickerButtonIcon: configuration?.stickerButtonIcon,
      stickerIconTint: configuration?.stickerIconTint ?? color,
      keyboardIconTint: configuration?.keyboardIconTint ?? color,
      onStickerTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Future.delayed(const Duration(milliseconds: 300), () {
          CometChatUIEvents.showPanel(id, CustomUIPosition.composerBottom,
              (context) {
            return CometChatStickerKeyboard(
              onStickerTap: onStickerTap,
              emptyStateView: configuration?.errorStateView,
              errorStateView: configuration?.errorStateView,
              loadingStateView: configuration?.loadingStateView,
            );
          });
        });
      },
      onKeyboardTap: () {
        CometChatUIEvents.hidePanel(
          id,
          CustomUIPosition.composerBottom,
        );
      },
    );
  }

  @override
  String getId() {
    return "Sticker";
  }
}
