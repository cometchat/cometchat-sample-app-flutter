import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;

///[MessagesDataSource] is a Utility class that provides
///default templates to construct message bubbles and also provides
///the default set of options available for each message bubble
class MessagesDataSource implements DataSource {
  CometChatMessageOption getEditOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.editMessage,
      title: Translations.of(context).edit,
      icon: Icon(
        Icons.edit_outlined,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
        size: 24,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  CometChatMessageOption getDeleteOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.deleteMessage,
      title: Translations.of(context).delete,
      icon: Image.asset(
        AssetConstants.delete,
        package: UIConstants.packageName,
        height: 24,
        width: 24,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.error,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor ?? colorPalette.error,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  CometChatMessageOption getReplyInThreadOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.replyInThreadMessage,
      title: Translations.of(context).reply,
      icon: Icon(
        Icons.subdirectory_arrow_right,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
        size: 24,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  CometChatMessageOption getShareOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.shareMessage,
      title: Translations.of(context).share,
      icon: Image.asset(
        AssetConstants.shareOutlined,
        package: UIConstants.packageName,
        height: 24,
        width: 24,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  CometChatMessageOption getCopyOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.copyMessage,
      title: Translations.of(context).copy,
      icon: Icon(
        Icons.content_copy,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
        size: 24,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  CometChatMessageOption getMessageInfo(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.messageInformation,
      title: Translations.of(context).info,
      icon: Icon(
        Icons.info_outline,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
        size: 24,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  // CometChatMessageOption getForwardOption(BuildContext context) {
  //   return CometChatMessageOption(
  //       id: MessageOptionConstants.forwardMessage,
  //       title: Translations.of(context).forward,
  //       icon: AssetConstants.forward,
  //       packageName: UIConstants.packageName);
  // }

  CometChatMessageOption getSendMessagePrivately(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.sendMessagePrivately,
      title: Translations.of(context).messagePrivately,
      icon: Image.asset(
        AssetConstants.replyPrivately,
        package: UIConstants.packageName,
        height: 24,
        width: 24,
        color: messageOptionSheetStyle?.iconColor ?? colorPalette.iconSecondary,
      ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: messageOptionSheetStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(messageOptionSheetStyle?.titleTextStyle),
        borderRadius: messageOptionSheetStyle?.borderRadius,
        border: messageOptionSheetStyle?.border,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        iconColor: messageOptionSheetStyle?.iconColor,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  bool isSentByMe(User loggedInUser, BaseMessage message) {
    return loggedInUser.uid == message.sender?.uid;
  }

  @override
  List<CometChatMessageOption> getTextMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;

    if (additionalConfigurations?.hideReplyInThreadOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.replyInThreadMessage)) {
      messageOptionList.add(
          getReplyInThreadOption(context, colorPalette, typography, style));
    }
    if (additionalConfigurations?.hideShareMessageOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.shareMessage)) {
      messageOptionList
          .add(getShareOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideCopyMessageOption != true) {
      messageOptionList
          .add(getCopyOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideEditMessageOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.editMessage)) {
      messageOptionList
          .add(getEditOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideMessageInfoOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.messageInformation)) {
      messageOptionList
          .add(getMessageInfo(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideDeleteMessageOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.deleteMessage)) {
      messageOptionList
          .add(getDeleteOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideMessagePrivatelyOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.sendMessagePrivately)) {
      messageOptionList.add(
          getSendMessagePrivately(context, colorPalette, typography, style));
    }
    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getImageMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getVideoMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getAudioMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    // messageOptionList.add(getForwardOption(context));
    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getFileMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    // messageOptionList.add(getForwardOption(context));
    return messageOptionList;
  }

  @override
  Widget getDeleteMessageBubble(BaseMessage messageObject, BuildContext context,
      CometChatDeletedBubbleStyle? style) {
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    final style0 = CometChatThemeHelper.getTheme<CometChatDeletedBubbleStyle>(
            context: context, defaultTheme: CometChatDeletedBubbleStyle.of)
        .merge(style);
    return CometChatDeletedBubble(
      style: CometChatDeletedBubbleStyle(
        iconColor: style0.iconColor ??
            (messageObject.sender?.uid == CometChatUIKit.loggedInUser?.uid
                ? colorPalette.white
                : colorPalette.neutral600),
        textColor: style0.textColor ??
            (messageObject.sender?.uid == CometChatUIKit.loggedInUser?.uid
                ? colorPalette.white
                : colorPalette.neutral600),
      ).merge(style0),
    );
  }

  Widget getGroupActionBubble(
      BaseMessage messageObject, CometChatActionBubbleStyle? style) {
    cc.Action actionMessage = messageObject as cc.Action;

    return CometChatActionBubble(
      text: actionMessage.message,
      style: style,
    );
  }

  @override
  Widget getBottomView(
      BaseMessage message, BuildContext context, BubbleAlignment alignment) {
    return const SizedBox();
  }

  @override
  CometChatMessageTemplate getTextMessageTemplate() {
    return CometChatMessageTemplate(
      // name: MessageTypeConstants.text,
      type: MessageTypeConstants.text,
      category: MessageCategoryConstants.message,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        TextMessage textMessage = message as TextMessage;
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }

        return CometChatUIKit.getDataSource().getTextMessageContentView(
            textMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
      bottomView: CometChatUIKit.getDataSource().getBottomView,
    );
  }

  @override
  Widget getTextMessageContentView(TextMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getTextMessageBubble(
        message.text,
        message,
        context,
        alignment,
        additionalConfigurations?.textBubbleStyle,
        additionalConfigurations?.textFormatters);
  }

  @override
  Widget getFormMessageContentView(FormMessage message, BuildContext context,
      BubbleAlignment alignment) {
    return CometChatUIKit.getDataSource()
        .getFormMessageBubble(message: message);
  }

  @override
  CometChatMessageTemplate getAudioMessageTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.audio,
        category: MessageCategoryConstants.message,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          MediaMessage audioMessage = message as MediaMessage;
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }

          return CometChatUIKit.getDataSource().getAudioMessageContentView(
            audioMessage,
            context,
            alignment,
            additionalConfigurations: additionalConfigurations,
          );
        },
        options: CometChatUIKit.getDataSource().getMessageOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  CometChatMessageTemplate getVideoMessageTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.video,
        category: MessageCategoryConstants.message,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }

          return CometChatUIKit.getDataSource().getVideoMessageContentView(
              message as MediaMessage, context, alignment,
              additionalConfigurations: additionalConfigurations);
        },
        options: CometChatUIKit.getDataSource().getMessageOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  CometChatMessageTemplate getImageMessageTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.image,
        category: MessageCategoryConstants.message,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }

          return CometChatUIKit.getDataSource().getImageMessageContentView(
              message as MediaMessage, context, alignment,
              additionalConfigurations: additionalConfigurations);
        },
        options: CometChatUIKit.getDataSource().getMessageOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  CometChatMessageTemplate getGroupActionTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.groupActions,
        category: MessageCategoryConstants.action,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          return getGroupActionBubble(
              message, additionalConfigurations?.actionBubbleStyle);
        });
  }

  CometChatMessageTemplate getDefaultMessageActionsTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.message,
      category: MessageCategoryConstants.action,
    );
  }

  @override
  CometChatMessageTemplate getFileMessageTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.file,
        category: MessageCategoryConstants.message,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }

          return CometChatUIKit.getDataSource().getFileMessageContentView(
              message as MediaMessage, context, alignment,
              additionalConfigurations: additionalConfigurations);
        },
        options: CometChatUIKit.getDataSource().getMessageOptions,
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  CometChatMessageTemplate getFormMessageTemplate() {
    return CometChatMessageTemplate(
        // name: MessageTypeConstants.text,
        type: MessageTypeConstants.form,
        category: MessageCategoryConstants.interactive,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }
          //TODO: Implement FormMessage ContentView
          // FormMessage formMessage = message as FormMessage;
          // return CometChatUIKit.getDataSource().getFormMessageContentView(
          //     formMessage, context, alignment, theme);
          return getMessageNotSupportedWidget(message, context);
        },
        //TODO: Implement FormMessage Options
        // options: CometChatUIKit.getDataSource().getFormMessageOptions,
        options: (loggedInUser, messageObject, context, group,
                additionalConfigurations) =>
            [],
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  CometChatMessageTemplate getSchedulerMessageTemplate() {
    return CometChatMessageTemplate(
        type: MessageTypeConstants.scheduler,
        category: MessageCategoryConstants.interactive,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }
          //TODO: Implement SchedulerMessage ContentView
          // SchedulerMessage meetingMessage = message as SchedulerMessage;
          // return CometChatUIKit.getDataSource().getSchedulerMessageContentView(
          //     meetingMessage, context, alignment, theme);
          return getMessageNotSupportedWidget(message, context);
        },
        //TODO: Implement SchedulerMessage Options
        // options: CometChatUIKit.getDataSource().getSchedulerMessageOptions,
        options: (loggedInUser, messageObject, context, group,
                additionalConfigurations) =>
            [],
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    return [
      CometChatUIKit.getDataSource().getTextMessageTemplate(),
      CometChatUIKit.getDataSource().getImageMessageTemplate(),
      CometChatUIKit.getDataSource().getVideoMessageTemplate(),
      CometChatUIKit.getDataSource().getAudioMessageTemplate(),
      CometChatUIKit.getDataSource().getFileMessageTemplate(),
      CometChatUIKit.getDataSource().getGroupActionTemplate(),
      CometChatUIKit.getDataSource().getFormMessageTemplate(),
      CometChatUIKit.getDataSource().getCardMessageTemplate(),
      CometChatUIKit.getDataSource().getSchedulerMessageTemplate(),
    ];
  }

  @override
  CometChatMessageTemplate? getMessageTemplate(
      {required String messageType,
      required String messageCategory}) {

    CometChatMessageTemplate? template;
    if (messageCategory != MessageCategoryConstants.call) {
      if (messageCategory == MessageCategoryConstants.interactive) {
        switch (messageType) {
          case MessageTypeConstants.card:
            template =
                CometChatUIKit.getDataSource().getCardMessageTemplate();
            break;
          case MessageTypeConstants.form:
            template =
                CometChatUIKit.getDataSource().getFormMessageTemplate();
            break;
        }
      } else {
        switch (messageType) {
          case MessageTypeConstants.text:
            template =
                CometChatUIKit.getDataSource().getTextMessageTemplate();
            break;
          case MessageTypeConstants.image:
            template =
                CometChatUIKit.getDataSource().getImageMessageTemplate();
            break;
          case MessageTypeConstants.video:
            template =
                CometChatUIKit.getDataSource().getVideoMessageTemplate();
            break;
          case MessageTypeConstants.groupActions:
            template = CometChatUIKit.getDataSource().getGroupActionTemplate();
            break;
          case MessageTypeConstants.file:
            template =
                CometChatUIKit.getDataSource().getFileMessageTemplate();
            break;
          case MessageTypeConstants.audio:
            template = CometChatUIKit.getDataSource().getAudioMessageTemplate();
            break;
        }
      }
    }

    return template;
  }

  @override
  List<CometChatMessageOption> getMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> optionList = [];
    if (messageObject.category == MessageCategoryConstants.message) {
      switch (messageObject.type) {
        case MessageTypeConstants.text:
          optionList = CometChatUIKit.getDataSource().getTextMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.image:
          optionList = CometChatUIKit.getDataSource().getImageMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.video:
          optionList = CometChatUIKit.getDataSource().getVideoMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.groupActions:
          optionList = [];
          break;
        case MessageTypeConstants.file:
          optionList = CometChatUIKit.getDataSource().getFileMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.audio:
          optionList = CometChatUIKit.getDataSource().getAudioMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
      }
    } else if (messageObject.category == MessageCategoryConstants.custom) {
      optionList = CometChatUIKit.getDataSource().getCommonOptions(loggedInUser,
          messageObject, context, group, additionalConfigurations);
    }
    return optionList;
  }

  bool _validateOption(User loggedInUser, BaseMessage messageObject,
      BuildContext context, Group? group, String optionId) {
    if (MessageOptionConstants.replyInThreadMessage == optionId &&
        messageObject.parentMessageId == 0) {
      return true;
    }

    if (MessageOptionConstants.shareMessage == optionId &&
        (messageObject is TextMessage || messageObject is MediaMessage)) {
      return true;
    }

    if (MessageOptionConstants.copyMessage == optionId &&
        messageObject is TextMessage) {
      return true;
    }

    bool isSendMyMeOption = isSentByMe(loggedInUser, messageObject);

    if (MessageOptionConstants.messageInformation == optionId &&
        isSendMyMeOption) {
      return true;
    }

    bool memberIsNotParticipant = (group != null) &&
        ((group.owner == loggedInUser.uid) ||
            (group.scope != GroupMemberScope.participant));

    if (MessageOptionConstants.deleteMessage == optionId &&
        (isSendMyMeOption == true || memberIsNotParticipant == true)) {
      return true;
    }

    if (MessageOptionConstants.editMessage == optionId &&
        (isSendMyMeOption == true || memberIsNotParticipant == true)) {
      return true;
    }

    if (MessageOptionConstants.copyMessage == optionId &&
        messageObject is TextMessage) {
      return true;
    }

    if (MessageOptionConstants.sendMessagePrivately == optionId &&
        group != null &&
        loggedInUser.uid != messageObject.sender?.uid) {
      return true;
    }

    return false;
  }

  @override
  List<CometChatMessageOption> getCommonOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;

    if (additionalConfigurations?.hideReplyInThreadOption != true && _validateOption(loggedInUser, messageObject, context, group,
        MessageOptionConstants.replyInThreadMessage)) {
      messageOptionList.add(
          getReplyInThreadOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideShareMessageOption != true && _validateOption(loggedInUser, messageObject, context, group,
        MessageOptionConstants.shareMessage)) {
      messageOptionList
          .add(getShareOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideMessageInfoOption != true && _validateOption(loggedInUser, messageObject, context, group,
        MessageOptionConstants.messageInformation)) {
      messageOptionList
          .add(getMessageInfo(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideDeleteMessageOption != true && _validateOption(loggedInUser, messageObject, context, group,
        MessageOptionConstants.deleteMessage)) {
      messageOptionList
          .add(getDeleteOption(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.hideMessagePrivatelyOption != true && _validateOption(loggedInUser, messageObject, context, group,
        MessageOptionConstants.sendMessagePrivately)) {
      messageOptionList.add(
          getSendMessagePrivately(context, colorPalette, typography, style));
    }

    return messageOptionList;
  }

  @override
  String getMessageTypeToSubtitle(String messageType, BuildContext context) {
    String subtitle = messageType;
    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = Translations.of(context).text;
        break;
      case MessageTypeConstants.image:
        subtitle = Translations.of(context).messageImage;
        break;
      case MessageTypeConstants.video:
        subtitle = Translations.of(context).messageVideo;
        break;
      case MessageTypeConstants.file:
        subtitle = Translations.of(context).messageFile;
        break;
      case MessageTypeConstants.audio:
        subtitle = Translations.of(context).messageAudio;
        break;
      default:
        subtitle = messageType;
        break;
    }
    return subtitle;
  }

  // @override
  // List<CometChatMessageComposerAction> getAttachmentOptions(
  //     CometChatTheme theme, BuildContext context,
  //     {User? user, Group? group}) {
  //   List<CometChatMessageComposerAction> actions = [
  //     CometChatMessageComposerAction(
  //       id: MessageTypeConstants.takePhoto,
  //       title: Translations.of(context).take_photo,
  //       iconUrl: AssetConstants.photoLibrary,
  //       iconUrlPackageName: UIConstants.packageName,
  //       titleStyle: TextStyle(
  //           color: theme.palette.getAccent(),
  //           fontSize: theme.typography.subtitle1.fontSize,
  //           fontWeight: theme.typography.subtitle1.fontWeight),
  //       iconTint: theme.palette.getAccent700(),
  //     ),
  //     CometChatMessageComposerAction(
  //       id: MessageTypeConstants.photoAndVideo,
  //       title: Translations.of(context).photo_and_video_library,
  //       iconUrl: AssetConstants.photoLibrary,
  //       iconUrlPackageName: UIConstants.packageName,
  //       titleStyle: TextStyle(
  //           color: theme.palette.getAccent(),
  //           fontSize: theme.typography.subtitle1.fontSize,
  //           fontWeight: theme.typography.subtitle1.fontWeight),
  //       iconTint: theme.palette.getAccent700(),
  //     ),
  //     CometChatMessageComposerAction(
  //       id: MessageTypeConstants.file,
  //       title: Translations.of(context).file,
  //       iconUrl: AssetConstants.audio,
  //       iconUrlPackageName: UIConstants.packageName,
  //       titleStyle: TextStyle(
  //           color: theme.palette.getAccent(),
  //           fontSize: theme.typography.subtitle1.fontSize,
  //           fontWeight: theme.typography.subtitle1.fontWeight),
  //       iconTint: theme.palette.getAccent700(),
  //     ),
  //     CometChatMessageComposerAction(
  //       id: MessageTypeConstants.audio,
  //       title: Translations.of(context).audio,
  //       iconUrl: AssetConstants.attachmentFile,
  //       iconUrlPackageName: UIConstants.packageName,
  //       titleStyle: TextStyle(
  //           color: theme.palette.getAccent(),
  //           fontSize: theme.typography.subtitle1.fontSize,
  //           fontWeight: theme.typography.subtitle1.fontWeight),
  //       iconTint: theme.palette.getAccent700(),
  //     )
  //   ];

  //   return actions;
  // }

  @override
  List<String> getAllMessageTypes() {
    return [
      CometChatMessageType.text,
      CometChatMessageType.image,
      CometChatMessageType.audio,
      CometChatMessageType.video,
      CometChatMessageType.file,
      MessageTypeConstants.groupActions,
      MessageTypeConstants.form,
      MessageTypeConstants.card,
      MessageTypeConstants.scheduler
    ];
  }

  String addList() {
    return "<Message Utils>";
  }

  @override
  List<String> getAllMessageCategories() {
    return [
      CometChatMessageCategory.message,
      CometChatMessageCategory.action,
      CometChatMessageCategory.interactive
    ];
  }

  @override
  Widget getAuxiliaryOptions(
      User? user,
      Group? group,
      BuildContext context,
      Map<String, dynamic>? id,
      Color? color,
      {AdditionalConfigurations? additionalConfigurations}) {
    return const SizedBox();
  }

  @override
  String getId() {
    return "messageUtils";
  }

  @override
  Widget getAudioMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getAudioMessageBubble(
        message.attachment?.fileUrl,
        message.attachment?.fileName,
        additionalConfigurations?.audioBubbleStyle,
        message,
        context,
        alignment);
  }

  @override
  Widget getFileMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getFileMessageBubble(
        message.attachment?.fileUrl,
        message.attachment?.fileMimeType,
        message.attachment?.fileName,
        message.id,
        additionalConfigurations?.fileBubbleStyle,
        message,
        alignment);
  }

  @override
  Widget getImageMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getImageMessageBubble(
        message.attachment?.fileUrl,
        AssetConstants.imagePlaceholder,
        message.caption,
        additionalConfigurations?.imageBubbleStyle,
        message,
        null,
        context,);
  }

  @override
  Widget getVideoMessageBubble(
      String? videoUrl,
      String? thumbnailUrl,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,
      CometChatVideoBubbleStyle? style) {
    return CometChatVideoBubble(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      style: style,
      metadata: message.metadata,
    );
  }

  @override
  Widget getVideoMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getVideoMessageBubble(
        message.attachment?.fileUrl,
        null,
        message,
        null,
        context,
        additionalConfigurations?.videoBubbleStyle);
  }

  CometChatMessageComposerAction takePhotoOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatAttachmentOptionSheetStyle? style,
  ) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.takePhoto,
      title: Translations.of(context).camera,
      icon: Icon(
        Icons.photo_camera,
        color: style?.iconColor ?? colorPalette.iconHighlight,
        size: 24,
      ),
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: style?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(
          style?.titleTextStyle,
        ),
        backgroundColor: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        titleColor: style?.titleColor,
        iconColor: style?.iconColor,
      ),
    );
  }

  CometChatMessageComposerAction attachPhoto(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatAttachmentOptionSheetStyle? style,
  ) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.attachPhoto,
      title: Translations.of(context).attachImage,
      icon: Icon(
        Icons.image,
        color: style?.iconColor ?? colorPalette.iconHighlight,
        size: 24,
      ),
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: style?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(
          style?.titleTextStyle,
        ),
        backgroundColor: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        titleColor: style?.titleColor,
        iconColor: style?.iconColor,
      ),
    );
  }

  CometChatMessageComposerAction attachVideo(
      BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,
      ) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.attachVideo,
      title: Translations.of(context).attachVideo,
      icon: Icon(
        Icons.videocam_rounded,
        color: style?.iconColor ?? colorPalette.iconHighlight,
        size: 24,
      ),
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: style?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(
          style?.titleTextStyle,
        ),
        backgroundColor: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        titleColor: style?.titleColor,
        iconColor: style?.iconColor,
      ),
    );
  }

  CometChatMessageComposerAction audioAttachmentOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatAttachmentOptionSheetStyle? style,
  ) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.audio,
      title: Translations.of(context).attachAudio,
      icon: Icon(
        Icons.play_circle,
        color: style?.iconColor ?? colorPalette.iconHighlight,
        size: 24,
      ),
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: style?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(
          style?.titleTextStyle,
        ),
        backgroundColor: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        titleColor: style?.titleColor,
        iconColor: style?.iconColor,
      ),
    );
  }

  CometChatMessageComposerAction fileAttachmentOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatAttachmentOptionSheetStyle? style,
  ) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.file,
      title: Translations.of(context).attachDocument,
      icon: Icon(
        Icons.description,
        color: style?.iconColor ?? colorPalette.iconHighlight,
        size: 24,
      ),
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: style?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(
          style?.titleTextStyle,
        ),
        backgroundColor: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        titleColor: style?.titleColor,
        iconColor: style?.iconColor,
      ),
    );
  }

  @override
  List<CometChatMessageComposerAction> getAttachmentOptions(
      BuildContext context,
      Map<String, dynamic>? id,
      AdditionalConfigurations? additionalConfigurations) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.attachmentOptionSheetStyle;
    List<CometChatMessageComposerAction> actions = [];

    if (additionalConfigurations?.hideTakPhotoOption != true) {
      actions.add(
        takePhotoOption(context, colorPalette, typography, style),
      );
    }
    if (additionalConfigurations?.hideImageAttachmentOption != true) {
      actions.add(
        attachPhoto(context, colorPalette, typography, style),
      );
    }
    if (additionalConfigurations?.hideVideoAttachmentOption != true) {
      actions.add(
        attachVideo(context, colorPalette, typography, style),
      );
    }
    if (additionalConfigurations?.hideAudioAttachmentOption != true) {
      actions.add(
        audioAttachmentOption(context, colorPalette, typography, style),
      );
    }
    if (additionalConfigurations?.hideFileAttachmentOption != true) {
      actions.add(
        fileAttachmentOption(context, colorPalette, typography, style),
      );
    }
    return actions;
  }

  @override
  Widget getTextMessageBubble(
      String messageText,
      TextMessage message,
      BuildContext context,
      BubbleAlignment alignment,
      CometChatTextBubbleStyle? style,
      List<CometChatTextFormatter>? formatters) {
    return CometChatTextBubble(
      text: messageText,
      alignment: alignment,
      formatters: formatters,
      style: style,
    );
  }

  @override
  Widget getAudioMessageBubble(
      String? audioUrl,
      String? title,
      CometChatAudioBubbleStyle? style,
      MediaMessage message,
      BuildContext context,
      BubbleAlignment alignment) {
    return CometChatAudioBubble(
      style: style,
      audioUrl: audioUrl,
      title: title,
      key: ValueKey(message.muid),
      fileMimeType: message.attachment?.fileMimeType,
      alignment: alignment,
      id: message.id,
      metadata: message.metadata,
    );
  }

  @override
  Widget getFileMessageBubble(
    String? fileUrl,
    String? fileMimeType,
    String? title,
    int? id,
    CometChatFileBubbleStyle? style,
    MediaMessage message,
    BubbleAlignment alignment,
  ) {
    return CometChatFileBubble(
      key: UniqueKey(),
      fileUrl: fileUrl,
      fileMimeType: fileMimeType,
      alignment: alignment,
      style: style ?? const CometChatFileBubbleStyle(),
      title: title ?? "",
      id: id,
      fileSize: message.attachment?.fileSize,
      fileExtension: message.attachment?.fileExtension,
      dateTime: message.sentAt,
      metadata: message.metadata,
    );
  }

  @override
  Widget getImageMessageBubble(
      String? imageUrl,
      String? placeholderImage,
      String? caption,
      CometChatImageBubbleStyle? style,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,) {
    return CometChatImageBubble(
        key: UniqueKey(),
        imageUrl: imageUrl,
        placeholderImage: placeholderImage,
        style: style ?? const CometChatImageBubbleStyle(),
        onClick: onClick,
        metadata: message.metadata);
  }

  @override
  Widget getFormMessageBubble({
    String? title,
    required FormMessage message,
  }) {
    return const SizedBox();
  }

  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    return ConversationUtils.getLastConversationMessage(conversation, context);
  }

  @override
  Widget getLastConversationWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    return ConversationUtils.getLastConversationIcon(
        conversation, context, iconColor);
  }

  @override
  Widget getConversationSubtitle(Conversation conversation,
      BuildContext context, TextStyle? subtitleStyle, Color? iconColor,
      {AdditionalConfigurations? additionalConfigurations}) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    TextStyle subtitleStyle0 = TextStyle(
            overflow: TextOverflow.ellipsis,
            color: colorPalette.textSecondary,
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
            letterSpacing: 0)
        .merge(
      subtitleStyle,
    );

    BaseMessage? lastMessage = conversation.lastMessage;
    String? messageCategory = lastMessage?.category;

    final spacing = CometChatThemeHelper.getSpacing(context);

    if (messageCategory == null || lastMessage == null) {
      return Text(
        Translations.of(context).tapToStartConversation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: subtitleStyle0,
      );
    } else if (lastMessage.deletedBy != null &&
        lastMessage.deletedBy!.trim() != '') {
      return Row(
        children: [
          Icon(
            Icons.block,
            color: colorPalette.iconSecondary,
            size: 16,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: spacing.padding ?? 0),
              child: Text(
                Translations.of(context).thisMessageDeleted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle0,
              ),
            ),
          ),
        ],
      );
    } else {
      String? prefix;
      if (conversation.conversationWith is Group) {
        if ((lastMessage.category == MessageCategoryConstants.action &&
                lastMessage.type == MessageTypeConstants.groupActions) ||
            (lastMessage.category == MessageCategoryConstants.custom &&
                lastMessage.type == MessageTypeConstants.meeting)) {
          prefix = "";
        } else if (lastMessage.sender?.uid !=
            CometChatUIKit.loggedInUser?.uid) {
          prefix = "${lastMessage.sender?.name}: ";
        } else {
          prefix = "${cc.Translations.of(context).you}: ";
        }
      }

      if (additionalConfigurations != null &&
          additionalConfigurations.textFormatters != null &&
          additionalConfigurations.textFormatters!.isNotEmpty &&
          lastMessage is TextMessage) {
        String text = (lastMessage).text;

        return RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: prefix,
            style: subtitleStyle0,
            children: FormatterUtils.buildConversationTextSpan(
              text,
              additionalConfigurations.textFormatters,
              context,
              subtitleStyle0,
            ),
          ),
        );
      } else {
        String? text;
        Widget? icon;

        if (prefix != null && prefix.isNotEmpty) {
          icon = CometChatUIKit.getDataSource()
              .getLastConversationWidget(conversation, context, iconColor);
          return Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: spacing.padding ?? 0),
                child: Text(
                  prefix,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Handles text overflow
                  style: subtitleStyle0,
                ),
              ),
              icon,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.padding ?? 0),
                  child: Text(
                    CometChatUIKit.getDataSource()
                        .getLastConversationMessage(conversation, context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Handles text overflow
                    style: subtitleStyle0,
                  ),
                ),
              ),
            ],
          );
        }

        text =
            "${prefix ?? ""}${CometChatUIKit.getDataSource().getLastConversationMessage(conversation, context)}";
        icon = CometChatUIKit.getDataSource()
            .getLastConversationWidget(conversation, context, iconColor);
        return Row(
          children: [
            icon,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: spacing.padding ?? 0),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Handles text overflow
                  style: subtitleStyle0,
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget? getAuxiliaryHeaderMenu(BuildContext context, User? user, Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    return null;
  }

  @override
  Widget getCardMessageBubble(
      {CardBubbleStyle? cardBubbleStyle,
      required CardMessage message}) {
    return CometChatCardBubble(
      cardMessage: message,
      loggedInUser: CometChatUIKit.loggedInUser,
    );
  }

  @override
  CometChatMessageTemplate getCardMessageTemplate() {
    return CometChatMessageTemplate(
        // name: MessageTypeConstants.text,
        type: MessageTypeConstants.card,
        category: MessageCategoryConstants.interactive,
        contentView: (BaseMessage message, BuildContext context,
            BubbleAlignment alignment,
            {AdditionalConfigurations? additionalConfigurations}) {
          if (message.deletedAt != null) {
            return getDeleteMessageBubble(
                message, context, additionalConfigurations?.deletedBubbleStyle);
          }
          //TODO: Implement CardMessage ContentView
          // CardMessage cardMessage = message as CardMessage;
          // return CometChatUIKit.getDataSource().getCardMessageContentView(
          //     cardMessage, context, alignment, theme);
          return getMessageNotSupportedWidget(message, context);
        },
        //TODO: Implement CardMessage Options
        // options: CometChatUIKit.getDataSource().getCardMessageOptions,
        options: (loggedInUser, messageObject, context, group,
                additionalConfigurations) =>
            [],
        bottomView: CometChatUIKit.getDataSource().getBottomView);
  }

  @override
  Widget getCardMessageContentView(CardMessage message, BuildContext context,
      BubbleAlignment alignment) {
    return CometChatUIKit.getDataSource().getCardMessageBubble(
      message: message,
    );
  }

  @override
  List<CometChatMessageOption> getFormMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    List<CometChatMessageOption> messageOptionList = [];

    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));

    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getCardMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];

    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));

    return messageOptionList;
  }

  @override
  List<CometChatMessageComposerAction> getAIOptions(
    User? user,
    Group? group,
    BuildContext context,
    Map<String, dynamic>? id,
    AIOptionsStyle? aiOptionStyle,
  ) {
    return [];
  }

  @override
  Widget getSchedulerMessageBubble(
      {String? title,
      schedulerBubbleStyle,
      required SchedulerMessage message,
      }) {
    return const SizedBox();
  }

  @override
  Widget getSchedulerMessageContentView(SchedulerMessage message,
      BuildContext context, BubbleAlignment alignment) {
    return CometChatUIKit.getDataSource()
        .getSchedulerMessageBubble(message: message);
  }

  @override
  List<CometChatMessageOption> getSchedulerMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];

    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));

    return messageOptionList;
  }

  @override
  List<CometChatTextFormatter> getDefaultTextFormatters() {
    return [
      CometChatMentionsFormatter(),
      CometChatEmailFormatter(),
      CometChatPhoneNumberFormatter(),
      CometChatUrlFormatter(),
    ];
  }

  Widget getMessageNotSupportedWidget(
    BaseMessage message,
    BuildContext context,
  ) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatTypography typography =
        CometChatThemeHelper.getTypography(context);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    return Container(
      padding: EdgeInsets.fromLTRB(spacing.padding2 ?? 0, spacing.padding2 ?? 0,
          spacing.padding2 ?? 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
            child: Icon(
              Icons.block,
              color: message.sender?.uid == CometChatUIKit.loggedInUser?.uid
                  ? colorPalette.white
                  : colorPalette.neutral600,
              size: 16,
            ),
          ),
          Text(
            Translations.of(context).unsupportedMessageType,
            style: TextStyle(
              color: message.sender?.uid == CometChatUIKit.loggedInUser?.uid
                  ? colorPalette.white
                  : colorPalette.neutral600,
              fontSize: typography.body?.regular?.fontSize,
              fontWeight: typography.body?.regular?.fontWeight,
              fontFamily: typography.body?.regular?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
