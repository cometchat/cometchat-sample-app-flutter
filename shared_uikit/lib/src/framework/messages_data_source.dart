import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;
import 'package:flutter/services.dart';

///[MessagesDataSource] is a Utility class that provides
///default templates to construct message bubbles and also provides
///the default set of options available for each message bubble
class MessagesDataSource implements DataSource {
  CometChatMessageOption getEditOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.editMessage,
      title: Translations
          .of(context)
          .edit,
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

  CometChatMessageOption getDeleteOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.deleteMessage,
      title: Translations
          .of(context)
          .delete,
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

  CometChatMessageOption getReplyInThreadOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.replyInThreadMessage,
      title: Translations.of(context).replyInThread,
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

  CometChatMessageOption getShareOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.shareMessage,
      title: Translations
          .of(context)
          .share,
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

  CometChatMessageOption getCopyOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.copyMessage,
      title: Translations
          .of(context)
          .copy,
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

  CometChatMessageOption getMessageInfo(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.messageInformation,
      title: Translations
          .of(context)
          .info,
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

  CometChatMessageOption getSendMessagePrivately(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatMessageOptionSheetStyle? messageOptionSheetStyle,) {
    return CometChatMessageOption(
      id: MessageOptionConstants.sendMessagePrivately,
      title: Translations
          .of(context)
          .messagePrivately,
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

  CometChatMessageOption getReplyToMessageOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.replyMessage,
      title: cc.Translations.of(context).reply,
      icon: Image.asset(
        AssetConstants.replyToMessage,
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

  CometChatMessageOption getMarkAsUnreadOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.markAsUnread,
      title: cc.Translations.of(context).markAsUnread,
      icon: Icon(
        Icons.mark_email_unread_outlined,
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

  bool isSentByMe(User loggedInUser, BaseMessage message) {
    return loggedInUser.uid == message.sender?.uid;
  }

  @override
  List<CometChatMessageOption> getTextMessageOptions(User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;

    if (messageObject.sender?.uid == loggedInUser.uid &&
        ModerationCheckUtil.instance
            .isMessageDisapprovedFromModeration(messageObject)) {
      if (additionalConfigurations?.hideCopyMessageOption != true) {
        messageOptionList
            .add(getCopyOption(context, colorPalette, typography, style));
      }

      if (additionalConfigurations?.hideDeleteMessageOption != true &&
          _validateOption(loggedInUser, messageObject, context, group,
              MessageOptionConstants.deleteMessage)) {
        messageOptionList
            .add(getDeleteOption(context, colorPalette, typography, style));
      }

      return messageOptionList;
    }

    if (additionalConfigurations?.hideReplyOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.replyMessage)) {
      messageOptionList.add(
          getReplyToMessageOption(context, colorPalette, typography, style));
    }

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

    if (additionalConfigurations?.showMarkAsUnreadOption != false &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.markAsUnread)) {
      messageOptionList.add(
          getMarkAsUnreadOption(context, colorPalette, typography, style));
    }
    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getImageMessageOptions(User loggedInUser,
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
  List<CometChatMessageOption> getVideoMessageOptions(User loggedInUser,
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
  List<CometChatMessageOption> getAudioMessageOptions(User loggedInUser,
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
  List<CometChatMessageOption> getFileMessageOptions(User loggedInUser,
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

  Widget getGroupActionBubble(BaseMessage messageObject,
      CometChatActionBubbleStyle? style) {
    cc.Action actionMessage = messageObject as cc.Action;

    return CometChatActionBubble(
      text: actionMessage.message,
      style: style,
    );
  }

  @override
  Widget getBottomView(BaseMessage message, BuildContext context,
      BubbleAlignment alignment) {
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
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
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
  Widget getAIAssistantMessageContentView(AIAssistantMessage message,
      BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return CometChatUIKit.getDataSource().getAIAssistantMessageBubble(
      text: message.text,
      message: message,
      style: additionalConfigurations?.aiAssistantBubbleStyle,
      alignment: alignment,
    );
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
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
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
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
    );
  }

  @override
  CometChatMessageTemplate getVideoMessageTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.video,
      category: MessageCategoryConstants.message,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
          {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }

        return CometChatUIKit.getDataSource().getVideoMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
    );
  }

  @override
  CometChatMessageTemplate getImageMessageTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.image,
      category: MessageCategoryConstants.message,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
          {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }

        return CometChatUIKit.getDataSource().getImageMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
    );
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
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
          {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }

        return CometChatUIKit.getDataSource().getFileMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
    );
  }

  @override
  CometChatMessageTemplate getFormMessageTemplate() {
    return CometChatMessageTemplate(
      // name: MessageTypeConstants.text,
      type: MessageTypeConstants.form,
      category: MessageCategoryConstants.interactive,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
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
    );
  }

  @override
  CometChatMessageTemplate getSchedulerMessageTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.scheduler,
      category: MessageCategoryConstants.interactive,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
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
    );
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
      CometChatUIKit.getDataSource().getAIAssistantMessageTemplate(),
    ];
  }

  @override
  CometChatMessageTemplate? getMessageTemplate(
      {required String messageType, required String messageCategory}) {
    CometChatMessageTemplate? template;
    if (messageCategory != MessageCategoryConstants.call) {
      if (messageCategory == MessageCategoryConstants.interactive) {
        switch (messageType) {
          case MessageTypeConstants.card:
            template = CometChatUIKit.getDataSource().getCardMessageTemplate();
            break;
          case MessageTypeConstants.form:
            template = CometChatUIKit.getDataSource().getFormMessageTemplate();
            break;
        }
      } else if (messageCategory == MessageCategoryConstants.agentic) {
        switch (messageType) {
          case MessageTypeConstants.assistant:
            template =
                CometChatUIKit.getDataSource().getAIAssistantMessageTemplate();
            break;
        }
      } else {
        switch (messageType) {
          case MessageTypeConstants.text:
            template = CometChatUIKit.getDataSource().getTextMessageTemplate();
            break;
          case MessageTypeConstants.image:
            template = CometChatUIKit.getDataSource().getImageMessageTemplate();
            break;
          case MessageTypeConstants.video:
            template = CometChatUIKit.getDataSource().getVideoMessageTemplate();
            break;
          case MessageTypeConstants.groupActions:
            template = CometChatUIKit.getDataSource().getGroupActionTemplate();
            break;
          case MessageTypeConstants.file:
            template = CometChatUIKit.getDataSource().getFileMessageTemplate();
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
  List<CometChatMessageOption> getMessageOptions(User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;
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
      if (additionalConfigurations?.hideFlagOption != true &&
          _validateOption(loggedInUser, messageObject, context, group,
              MessageOptionConstants.reportMessage)) {
        optionList.add(
          getReportOption(context, colorPalette, typography, style),
        );
      }
    } else if (messageObject.category == MessageCategoryConstants.custom) {
      optionList = CometChatUIKit.getDataSource().getCommonOptions(loggedInUser,
          messageObject, context, group, additionalConfigurations);
    } else if (messageObject.category == MessageCategoryConstants.agentic) {
      optionList = CometChatUIKit.getDataSource().getAIAssistantMessageOptions(
          loggedInUser,
          messageObject,
          context,
          group,
          additionalConfigurations);
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

    if (MessageOptionConstants.replyMessage == optionId) {
      return true;
    }
    if (MessageOptionConstants.reportMessage == optionId &&
        loggedInUser.uid != messageObject.sender?.uid) {
      return true;
    }

    // Mark as unread: only for received messages (not sent by logged-in user)
    // and not for threaded messages (parentMessageId > 0)
    if (MessageOptionConstants.markAsUnread == optionId &&
        loggedInUser.uid != messageObject.sender?.uid &&
        messageObject.parentMessageId == 0) {
      return true;
    }

    return false;
  }

  @override
  List<CometChatMessageOption> getCommonOptions(User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;

    // 🚫 Moderation Disapproved: Only return DELETE if allowed
    if (messageObject.sender?.uid == loggedInUser.uid &&
        ModerationCheckUtil.instance
            .isMessageDisapprovedFromModeration(messageObject)) {
      if (additionalConfigurations?.hideDeleteMessageOption != true &&
          _validateOption(loggedInUser, messageObject, context, group,
              MessageOptionConstants.deleteMessage)) {
        messageOptionList
            .add(getDeleteOption(context, colorPalette, typography, style));
      }
      return messageOptionList; // ✅ Only delete option is returned
    }

    if (additionalConfigurations?.hideReplyOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.replyMessage)) {
      messageOptionList.add(
          getReplyToMessageOption(context, colorPalette, typography, style));
    }

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

    if (additionalConfigurations?.hideMessageInfoOption != true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.messageInformation)) {
      messageOptionList
          .add(getMessageInfo(context, colorPalette, typography, style));
    }

    if (additionalConfigurations?.showMarkAsUnreadOption != false &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.markAsUnread)) {
      messageOptionList.add(
          getMarkAsUnreadOption(context, colorPalette, typography, style));
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
  String getMessageTypeToSubtitle(String messageType, BuildContext context) {
    String subtitle = messageType;
    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = Translations
            .of(context)
            .text;
        break;
      case MessageTypeConstants.image:
        subtitle = Translations
            .of(context)
            .messageImage;
        break;
      case MessageTypeConstants.video:
        subtitle = Translations
            .of(context)
            .messageVideo;
        break;
      case MessageTypeConstants.file:
        subtitle = Translations
            .of(context)
            .messageFile;
        break;
      case MessageTypeConstants.audio:
        subtitle = Translations
            .of(context)
            .messageAudio;
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
      MessageTypeConstants.scheduler,
      MessageTypeConstants.assistant
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
      CometChatMessageCategory.interactive,
      CometChatMessageCategory.categoryAgentic,
    ];
  }

  @override
  Widget getAuxiliaryOptions(User? user, Group? group, BuildContext context,
      Map<String, dynamic>? id, Color? color,
      {AdditionalConfigurations? additionalConfigurations}) {
    return const SizedBox();
  }

  @override
  String getId() {
    return "messageUtils";
  }

  @override
  Widget getAudioMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
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
  Widget getFileMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    // Extract file info from attachment or metadata (when upload failed)
    String? fileUrl = message.attachment?.fileUrl;
    String? fileMimeType = message.attachment?.fileMimeType;
    String? fileName = message.attachment?.fileName;
    
    // Fallback to metadata when attachment is null (e.g., upload failed due to MIME type error)
    if (message.attachment == null && message.metadata != null) {
      final localPath = message.metadata?['localPath'] as String?;
      if (localPath != null && localPath.isNotEmpty) {
        // Use local path as fileUrl for icon display
        fileUrl = localPath;
        // Extract filename from local path
        fileName = localPath.split('/').last;
        // Extract mime type from file extension if not available
        if (fileName.contains('.')) {
          final extension = fileName.split('.').last.toLowerCase();
          fileMimeType = _getMimeTypeFromExtension(extension);
        }
      }
    }
    
    return CometChatUIKit.getDataSource().getFileMessageBubble(
        fileUrl,
        fileMimeType,
        fileName,
        message.id,
        additionalConfigurations?.fileBubbleStyle,
        message,
        alignment);
  }
  
  /// Helper method to get MIME type from file extension
  String _getMimeTypeFromExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
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
      context,
    );
  }

  @override
  Widget getVideoMessageBubble(String? videoUrl,
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

  CometChatMessageComposerAction takePhotoOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.takePhoto,
      title: Translations
          .of(context)
          .camera,
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

  CometChatMessageComposerAction attachPhoto(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.attachPhoto,
      title: Translations
          .of(context)
          .attachImage,
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

  CometChatMessageComposerAction attachVideo(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.attachVideo,
      title: Translations
          .of(context)
          .attachVideo,
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

  CometChatMessageComposerAction audioAttachmentOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.audio,
      title: Translations
          .of(context)
          .attachAudio,
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

  CometChatMessageComposerAction fileAttachmentOption(BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatAttachmentOptionSheetStyle? style,) {
    return CometChatMessageComposerAction(
      id: MessageTypeConstants.file,
      title: Translations
          .of(context)
          .attachDocument,
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
  Widget getTextMessageBubble(String messageText,
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
  Widget getAudioMessageBubble(String? audioUrl,
      String? title,
      CometChatAudioBubbleStyle? style,
      MediaMessage message,
      BuildContext context,
      BubbleAlignment alignment) {
    return CometChatAudioBubble(
      style: style,
      audioUrl: audioUrl,
      title: title,
      key: ValueKey('${message.id}_${message.muid}'),
      fileMimeType: message.attachment?.fileMimeType,
      alignment: alignment,
      id: message.id,
      metadata: message.metadata,
      fileSize: _formatFileSize(message.attachment?.fileSize),
    );
  }

  /// Formats file size in bytes to human readable format
  String? _formatFileSize(int? bytes) {
    if (bytes == null) return null;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget getFileMessageBubble(String? fileUrl,
      String? fileMimeType,
      String? title,
      int? id,
      CometChatFileBubbleStyle? style,
      MediaMessage message,
      BubbleAlignment alignment,) {
    // Get file extension and size from attachment or extract from fileUrl/metadata
    String? fileExtension = message.attachment?.fileExtension;
    int? fileSize = message.attachment?.fileSize;
    
    // Fallback: extract extension from fileUrl if attachment is null
    if (fileExtension == null && fileUrl != null && fileUrl.isNotEmpty) {
      try {
        final decodedUrl = Uri.decodeFull(fileUrl);
        final fileName = decodedUrl.split('/').last;
        if (fileName.contains('.')) {
          fileExtension = fileName.split('.').last.toLowerCase();
        }
      } catch (_) {
        // fileUrl may contain invalid percent encoding (e.g. local paths)
        final fileName = fileUrl.split('/').last;
        if (fileName.contains('.')) {
          fileExtension = fileName.split('.').last.toLowerCase();
        }
      }
    }
    
    return CometChatFileBubble(
      key: UniqueKey(),
      fileUrl: fileUrl,
      fileMimeType: fileMimeType,
      alignment: alignment,
      style: style ?? const CometChatFileBubbleStyle(),
      title: title ?? "",
      id: id,
      fileSize: fileSize,
      fileExtension: fileExtension,
      dateTime: message.sentAt,
      metadata: message.metadata,
    );
  }

  @override
  Widget getImageMessageBubble(String? imageUrl,
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
  Widget getAIAssistantMessageBubble({
    String? text,
    required AIAssistantMessage message,
    BubbleAlignment? alignment,
    CometChatAIAssistantBubbleStyle? style,
  }) {
    return CometChatAIAssistantBubble(
      key: UniqueKey(),
      text: text,
      message: message,
      style: style,
      alignment: alignment,
    );
  }

  @override
  String getLastConversationMessage(Conversation conversation,
      BuildContext context) {
    return ConversationUtils.getLastConversationMessage(conversation, context);
  }

  @override
  Widget getLastConversationWidget(Conversation conversation,
      BuildContext context,
      Color? iconColor,) {
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
        Translations
            .of(context)
            .tapToStartConversation,
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
                Translations
                    .of(context)
                    .thisMessageDeleted,
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
          prefix = "${cc.Translations
              .of(context)
              .you}: ";
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
          textScaleFactor: MediaQuery
              .of(context)
              .textScaleFactor,
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
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.padding ?? 0),
                  child: Text(
                    prefix,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Handles text overflow
                    style: subtitleStyle0,
                  ),
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
        "${prefix ?? ""}${CometChatUIKit
            .getDataSource()
            .getLastConversationMessage(conversation, context)}";
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
      {CardBubbleStyle? cardBubbleStyle, required CardMessage message}) {
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
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
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
    );
  }

  @override
  Widget getCardMessageContentView(CardMessage message, BuildContext context,
      BubbleAlignment alignment) {
    return CometChatUIKit.getDataSource().getCardMessageBubble(
      message: message,
    );
  }

  @override
  List<CometChatMessageOption> getFormMessageOptions(User loggedInUser,
      BaseMessage messageObject, BuildContext context, Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    List<CometChatMessageOption> messageOptionList = [];

    messageOptionList.addAll(CometChatUIKit.getDataSource().getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));

    return messageOptionList;
  }

  @override
  List<CometChatMessageOption> getCardMessageOptions(User loggedInUser,
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
  List<CometChatMessageComposerAction> getAIOptions(User? user,
      Group? group,
      BuildContext context,
      Map<String, dynamic>? id,
      AIOptionsStyle? aiOptionStyle,) {
    return [];
  }

  @override
  Widget getSchedulerMessageBubble({
    String? title,
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
  List<CometChatMessageOption> getSchedulerMessageOptions(User loggedInUser,
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
      CometChatRichTextFormatter(),
      CometChatEmailFormatter(),
      CometChatPhoneNumberFormatter(),
      CometChatUrlFormatter(),
    ];
  }

  Widget getMessageNotSupportedWidget(BaseMessage message,
      BuildContext context,) {
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
            Translations
                .of(context)
                .unsupportedMessageType,
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

  @override
  List<CometChatMessageOption> getAIAssistantMessageOptions(User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final style = additionalConfigurations?.messageOptionSheetStyle;

    if (additionalConfigurations?.hideCopyMessageOption != true) {
      messageOptionList
          .add(getCopyOption(context, colorPalette, typography, style));
    }
    return messageOptionList;
  }

  @override
  CometChatMessageTemplate getAIAssistantMessageTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.assistant,
      category: MessageCategoryConstants.agentic,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
          {AdditionalConfigurations? additionalConfigurations}) {
        AIAssistantMessage assistantMessage = message as AIAssistantMessage;
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }

        return CometChatUIKit.getDataSource().getAIAssistantMessageContentView(
          assistantMessage,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      footerView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
          {AdditionalConfigurations? additionalConfigurations}) {
        AIAssistantMessage assistantMessage = message as AIAssistantMessage;
        return CometChatUIKit.getDataSource().getAIAssistantMessageFooterView(
          assistantMessage,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      replyView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        return CometChatUIKit.getDataSource().getReplyView(
          message,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: CometChatUIKit.getDataSource().getMessageOptions,
    );
  }

  @override
  Widget getAIAssistantMessageFooterView(AIAssistantMessage message,
      BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    // Implement your AI message footer view here
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette =
    CometChatThemeHelper.getColorPalette(context);
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding4 ?? 16,
        left: spacing.padding1 ?? 8,
        right: spacing.padding1 ?? 8,
        bottom: spacing.padding1 ?? 8,
      ),
      child: GestureDetector(
        onTap: () {
          String text = message.text ?? "";
          Clipboard.setData(ClipboardData(text: text));
        },
        child: Icon(
          Icons.copy_rounded,
          color: colorPalette.iconSecondary,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget getReplyView(
      BaseMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    if (message.deletedAt != null) {
      return const SizedBox();
    }
    if (message.quotedMessage != null) {
      final typography = CometChatThemeHelper.getTypography(context);
      final colorPalette = CometChatThemeHelper.getColorPalette(context);
      String messagePreviewTitle = message.quotedMessage?.sender?.name ?? "";
      String messagePreviewSubtitle = "";
      final style = CometChatThemeHelper.getTheme<CometChatMessagePreviewStyle>(
              context: context, defaultTheme: CometChatMessagePreviewStyle.of)
          .merge(additionalConfigurations?.messagePreviewStyle);
      if (message.quotedMessage?.deletedAt != null) {
        messagePreviewSubtitle = Translations.of(context).thisMessageDeleted;
      } else if (message.quotedMessage is TextMessage) {
        String previewText = (message.quotedMessage as TextMessage).text;
        // Always call getTextWithMentions to handle both @all and user mentions
        previewText = CometChatMentionsFormatter.getTextWithMentions(
            previewText,
            message.quotedMessage!.mentionedUsers);
        // Strip rich text formatting for preview display
        // Requirements: 8.1, 8.2, 8.3, 8.4
        messagePreviewSubtitle = FormatPatterns.stripFormatting(previewText);
      } else {
        messagePreviewSubtitle =
            ComposerUtils().getReplySubtitle(message.quotedMessage, context);
      }
      return CometChatMessagePreview(
        message: message.quotedMessage,
        messagePreviewTitle: messagePreviewTitle,
        messagePreviewSubtitle: messagePreviewSubtitle,
        messagePreviewStyle: CometChatMessagePreviewStyle(
          messagePreviewTitleStyle: TextStyle(
            color: (alignment == BubbleAlignment.left)
                ? colorPalette.textHighlight
                : colorPalette.white,
            fontSize: typography.caption1?.medium?.fontSize,
            fontWeight: typography.caption1?.medium?.fontWeight,
            fontFamily: typography.caption1?.medium?.fontFamily,
          ),
          messagePreviewSubtitleStyle: TextStyle(
            color: (alignment == BubbleAlignment.left)
                ? colorPalette.textSecondary
                : colorPalette.white,
            fontSize: typography.caption1?.regular?.fontSize,
            fontWeight: typography.caption1?.regular?.fontWeight,
            fontFamily: typography.caption1?.regular?.fontFamily,
          ),
          closeIconColor: colorPalette.iconPrimary,
          messagePreviewBackground: colorPalette.white?.withOpacity(0.2),
          messagePreviewBorder: Border(
            top: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide(
              color: ((alignment == BubbleAlignment.left)
                      ? colorPalette.borderHighlight
                      : colorPalette.white) ??
                  Colors.transparent,
              width: 2,
            ),
            right: BorderSide.none,
          ),
        ).merge(style),
        hideCloseButton: true,
      );
    } else {
      return const SizedBox();
    }
  }

  CometChatMessageOption getReportOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.reportMessage,
      title: cc.Translations.of(context).report,
      icon: Icon(
        Icons.error_outline,
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
}
