import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared_ui/cometchat_uikit_shared.dart';
import '../../../../shared_ui/cometchat_uikit_shared.dart' as cc;
import '../../../../call_ui/src/call_bubble/cometchat_call_bubble.dart';
import '../../../../call_ui/src/calling_configuration.dart';
import '../../../../call_ui/src/utils/call_utils.dart';
import '../../../../call_ui/src/utils/call_extension_constants.dart';
import '../../../../call_ui/src/ongoing_call/call_screen_overlay.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' show SessionSettingsBuilder, LayoutType;
import '../../extensions/extension_constants.dart';
import '../../extensions/polls/cometchat_polls_bubble.dart';
import '../../extensions/stickers/cometchat_sticker_bubble.dart';
import '../../extensions/collaborative/cometchat_collaborative_bubble.dart';
import '../../extensions/link_preview/cometchat_link_preview_bubble.dart';
import '../../extensions/extension_moderator.dart';
import 'package:url_launcher/url_launcher.dart';

///[MessageTemplateUtils] provides default templates to construct
///message bubbles and the default set of options for each bubble type.
class MessageTemplateUtils {
  static CometChatMessageOption getEditOption(
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

  static CometChatMessageOption getDeleteOption(
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

  static CometChatMessageOption getReplyOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.replyMessage,
      title: Translations.of(context).reply,
      icon: Icon(
        Icons.reply,
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

  static CometChatMessageOption getReplyInThreadOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
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

  static CometChatMessageOption getShareOption(
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

  static CometChatMessageOption getCopyOption(
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

  static CometChatMessageOption getMessageInfo(
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

  static CometChatMessageOption getSendMessagePrivately(
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

  static CometChatMessageOption getMarkAsUnreadOption(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
  ) {
    return CometChatMessageOption(
      id: MessageOptionConstants.markAsUnread,
      title: Translations.of(context).markAsUnread,
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

  static bool isSentByMe(User loggedInUser, BaseMessage message) {
    return loggedInUser.uid == message.sender?.uid;
  }


  static List<CometChatMessageOption> getTextMessageOptions(
      User loggedInUser,
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

    if (additionalConfigurations?.hideReplyOption != true) {
      messageOptionList.add(
          getReplyOption(context, colorPalette, typography, style));
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

    if (additionalConfigurations?.showMarkAsUnreadOption == true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.markAsUnread)) {
      messageOptionList.add(
          getMarkAsUnreadOption(context, colorPalette, typography, style));
    }

    return messageOptionList;
  }


  static List<CometChatMessageOption> getImageMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(MessageTemplateUtils.getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    return messageOptionList;
  }


  static List<CometChatMessageOption> getVideoMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(MessageTemplateUtils.getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    return messageOptionList;
  }


  static List<CometChatMessageOption> getAudioMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(MessageTemplateUtils.getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    // messageOptionList.add(getForwardOption(context));
    return messageOptionList;
  }


  static List<CometChatMessageOption> getFileMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> messageOptionList = [];
    messageOptionList.addAll(MessageTemplateUtils.getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations));
    // messageOptionList.add(getForwardOption(context));
    return messageOptionList;
  }


  static Widget getDeleteMessageBubble(BaseMessage messageObject, BuildContext context,
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

  static Widget getGroupActionBubble(
      BaseMessage messageObject, CometChatActionBubbleStyle? style) {
    cc.Action actionMessage = messageObject as cc.Action;

    return CometChatActionBubble(
      text: actionMessage.message,
      style: style,
    );
  }


  static CometChatMessageTemplate getTextMessageTemplate() {
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

        return MessageTemplateUtils.getTextMessageContentView(
            textMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      options: MessageTemplateUtils.getMessageOptions,
    );
  }


  static Widget getTextMessageContentView(
      TextMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    final textBubble = MessageTemplateUtils.getTextMessageBubble(
        message.text,
        message,
        context,
        alignment,
        additionalConfigurations?.textBubbleStyle,
        additionalConfigurations?.textFormatters);

    // Check for link preview extension data in message metadata
    final extensionMap = ExtensionModerator.extensionCheck(message);
    if (extensionMap != null &&
        extensionMap.containsKey(ExtensionConstants.linkPreview)) {
      final linkPreviewData = extensionMap[ExtensionConstants.linkPreview];
      if (linkPreviewData != null && linkPreviewData['links'] != null) {
        final List<dynamic> links = linkPreviewData['links'];
        if (links.isNotEmpty) {
          return CometChatLinkPreviewBubble(
            links: links,
            style: additionalConfigurations?.linkPreviewBubbleStyle,
            alignment: alignment,
            onTapUrl: (url) async {
              if (!RegExp(r'^(https?:\/\/)').hasMatch(url)) {
                url = 'https://$url';
              }
              await launchUrl(Uri.parse(url));
            },
            child: textBubble,
          );
        }
      }
    }

    return textBubble;
  }


  static CometChatMessageTemplate getAudioMessageTemplate() {
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

        return MessageTemplateUtils.getAudioMessageContentView(
          audioMessage,
          context,
          alignment,
          additionalConfigurations: additionalConfigurations,
        );
      },
      options: MessageTemplateUtils.getMessageOptions,
    );
  }


  static CometChatMessageTemplate getVideoMessageTemplate() {
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

        return MessageTemplateUtils.getVideoMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      options: MessageTemplateUtils.getMessageOptions,
    );
  }


  static CometChatMessageTemplate getImageMessageTemplate() {
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

        return MessageTemplateUtils.getImageMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      options: MessageTemplateUtils.getMessageOptions,
    );
  }


  static CometChatMessageTemplate getGroupActionTemplate() {
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

  static CometChatMessageTemplate getDefaultMessageActionsTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.message,
      category: MessageCategoryConstants.action,
    );
  }


  static CometChatMessageTemplate getFileMessageTemplate() {
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

        return MessageTemplateUtils.getFileMessageContentView(
            message as MediaMessage, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
      options: MessageTemplateUtils.getMessageOptions,
    );
  }


  static CometChatMessageTemplate getFormMessageTemplate() {
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
        // return MessageUIService.getFormMessageContentView(
        //     formMessage, context, alignment, theme);
        return getMessageNotSupportedWidget(message, context);
      },
      //TODO: Implement FormMessage Options
      // options: MessageUIService.getFormMessageOptions,
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          [],
    );
  }


  static CometChatMessageTemplate getSchedulerMessageTemplate() {
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
        // return MessageUIService.getSchedulerMessageContentView(
        //     meetingMessage, context, alignment, theme);
        return getMessageNotSupportedWidget(message, context);
      },
      //TODO: Implement SchedulerMessage Options
      // options: MessageUIService.getSchedulerMessageOptions,
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          [],
    );
  }


  static List<CometChatMessageTemplate> getAllMessageTemplates() {
    List<CometChatMessageTemplate> templates = [
      MessageTemplateUtils.getTextMessageTemplate(),
      MessageTemplateUtils.getImageMessageTemplate(),
      MessageTemplateUtils.getVideoMessageTemplate(),
      MessageTemplateUtils.getAudioMessageTemplate(),
      MessageTemplateUtils.getFileMessageTemplate(),
      MessageTemplateUtils.getGroupActionTemplate(),
      MessageTemplateUtils.getFormMessageTemplate(),
      MessageTemplateUtils.getCardMessageTemplate(),
      MessageTemplateUtils.getSchedulerMessageTemplate(),
      MessageTemplateUtils.getPollMessageTemplate(),
      MessageTemplateUtils.getStickerMessageTemplate(),
      MessageTemplateUtils.getCollaborativeDocumentTemplate(),
      MessageTemplateUtils.getCollaborativeWhiteboardTemplate(),
    ];
    if (CometChatUIKit.authenticationSettings?.enableCalls == true) {
      templates.add(_getGroupCallTemplate());
      templates.add(_getDefaultVoiceCallTemplate());
      templates.add(_getDefaultVideoCallTemplate());
    }
    // AI message templates
    templates.add(getAIAssistantMessageTemplate());
    templates.add(getStreamMessageTemplate());
    return templates;
  }


  static CometChatMessageTemplate? getMessageTemplate(
      {required String messageType, required String messageCategory}) {
    CometChatMessageTemplate? template;
    if (messageCategory == MessageCategoryConstants.call) {
      // Handle call message templates
      if (CometChatUIKit.authenticationSettings?.enableCalls == true) {
        switch (messageType) {
          case CallTypeConstants.audioCall:
            template = _getDefaultVoiceCallTemplate();
            break;
          case CallTypeConstants.videoCall:
            template = _getDefaultVideoCallTemplate();
            break;
        }
      }
    } else if (messageCategory == MessageCategoryConstants.custom &&
        messageType == MessageTypeConstants.meeting) {
      if (CometChatUIKit.authenticationSettings?.enableCalls == true) {
        template = _getGroupCallTemplate();
      }
    } else if (messageCategory == MessageCategoryConstants.custom) {
      switch (messageType) {
        case ExtensionType.extensionPoll:
          template = MessageTemplateUtils.getPollMessageTemplate();
          break;
        case ExtensionType.sticker:
          template = MessageTemplateUtils.getStickerMessageTemplate();
          break;
        case ExtensionType.document:
          template = MessageTemplateUtils.getCollaborativeDocumentTemplate();
          break;
        case ExtensionType.whiteboard:
          template = MessageTemplateUtils.getCollaborativeWhiteboardTemplate();
          break;
      }
    } else if (messageCategory != MessageCategoryConstants.call) {
      if (messageCategory == MessageCategoryConstants.interactive) {
        switch (messageType) {
          case MessageTypeConstants.card:
            template = MessageTemplateUtils.getCardMessageTemplate();
            break;
          case MessageTypeConstants.form:
            template = MessageTemplateUtils.getFormMessageTemplate();
            break;
        }
      } else {
        switch (messageType) {
          case MessageTypeConstants.text:
            template = MessageTemplateUtils.getTextMessageTemplate();
            break;
          case MessageTypeConstants.image:
            template = MessageTemplateUtils.getImageMessageTemplate();
            break;
          case MessageTypeConstants.video:
            template = MessageTemplateUtils.getVideoMessageTemplate();
            break;
          case MessageTypeConstants.groupActions:
            template = MessageTemplateUtils.getGroupActionTemplate();
            break;
          case MessageTypeConstants.file:
            template = MessageTemplateUtils.getFileMessageTemplate();
            break;
          case MessageTypeConstants.audio:
            template = MessageTemplateUtils.getAudioMessageTemplate();
            break;
        }
      }
    }

    return template;
  }


  static List<CometChatMessageOption> getMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> optionList = [];
    if (messageObject.category == MessageCategoryConstants.message) {
      switch (messageObject.type) {
        case MessageTypeConstants.text:
          optionList = MessageTemplateUtils.getTextMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.image:
          optionList = MessageTemplateUtils.getImageMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.video:
          optionList = MessageTemplateUtils.getVideoMessageOptions(
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
          optionList = MessageTemplateUtils.getFileMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
        case MessageTypeConstants.audio:
          optionList = MessageTemplateUtils.getAudioMessageOptions(
              loggedInUser,
              messageObject,
              context,
              group,
              additionalConfigurations);
          break;
      }
    } else if (messageObject.category == MessageCategoryConstants.custom) {
      optionList = MessageTemplateUtils.getCommonOptions(loggedInUser,
          messageObject, context, group, additionalConfigurations);
    }
    return optionList;
  }

  static bool _validateOption(User loggedInUser, BaseMessage messageObject,
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

    if (MessageOptionConstants.markAsUnread == optionId &&
        loggedInUser.uid != messageObject.sender?.uid &&
        messageObject.parentMessageId == 0) {
      return true;
    }

    return false;
  }


  static List<CometChatMessageOption> getCommonOptions(
      User loggedInUser,
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

    if (additionalConfigurations?.hideReplyOption != true) {
      messageOptionList.add(
          getReplyOption(context, colorPalette, typography, style));
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

    if (additionalConfigurations?.showMarkAsUnreadOption == true &&
        _validateOption(loggedInUser, messageObject, context, group,
            MessageOptionConstants.markAsUnread)) {
      messageOptionList.add(
          getMarkAsUnreadOption(context, colorPalette, typography, style));
    }

    return messageOptionList;
  }


  static List<String> getAllMessageTypes() {
    List<String> types = [
      CometChatMessageType.text,
      CometChatMessageType.image,
      CometChatMessageType.audio,
      CometChatMessageType.video,
      CometChatMessageType.file,
      MessageTypeConstants.groupActions,
      MessageTypeConstants.form,
      MessageTypeConstants.card,
      MessageTypeConstants.scheduler,
      ExtensionType.extensionPoll,
      ExtensionType.sticker,
      ExtensionType.document,
      ExtensionType.whiteboard,
      CometChatMessageType.assistant,
      CometChatMessageType.runStarted,
    ];
    if (CometChatUIKit.authenticationSettings?.enableCalls == true) {
      if (!types.contains(MessageTypeConstants.audio)) {
        types.add(MessageTypeConstants.audio);
      }
      if (!types.contains(MessageTypeConstants.video)) {
        types.add(MessageTypeConstants.video);
      }
      if (!types.contains(MessageTypeConstants.meeting)) {
        types.add(MessageTypeConstants.meeting);
      }
    }
    return types;
  }

  static List<String> getAllMessageCategories() {
    List<String> categories = [
      CometChatMessageCategory.message,
      CometChatMessageCategory.action,
      CometChatMessageCategory.interactive,
      MessageCategoryConstants.custom,
      CometChatMessageCategory.categoryAgentic,
      CometChatMessageCategory.streamMessage,
    ];
    if (CometChatUIKit.authenticationSettings?.enableCalls == true) {
      if (!categories.contains(MessageCategoryConstants.call)) {
        categories.add(MessageCategoryConstants.call);
      }
    }
    return categories;
  }


  static Widget getAudioMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return MessageTemplateUtils.getAudioMessageBubble(
        message.attachment?.fileUrl,
        message.attachment?.fileName,
        additionalConfigurations?.audioBubbleStyle,
        message,
        context,
        alignment);
  }


  static Widget getFileMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return MessageTemplateUtils.getFileMessageBubble(
        message.attachment?.fileUrl,
        message.attachment?.fileMimeType,
        message.attachment?.fileName,
        message.id,
        additionalConfigurations?.fileBubbleStyle,
        message,
        alignment);
  }


  static Widget getImageMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return MessageTemplateUtils.getImageMessageBubble(
      message.attachment?.fileUrl,
      AssetConstants.imagePlaceholder,
      message.caption,
      additionalConfigurations?.imageBubbleStyle,
      message,
      null,
      context,
    );
  }


  static Widget getVideoMessageBubble(
      String? videoUrl,
      String? thumbnailUrl,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,
      CometChatVideoBubbleStyle? style) {
    return CometChatVideoBubble(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      style: style as dynamic,
      metadata: message.metadata,
    );
  }


  static Widget getVideoMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    String? thumbnailUrl;
    Map<String, dynamic>? metadata = message.metadata;
    if (metadata != null) {
      Map? injectedObject = metadata["@injected"];
      if (injectedObject != null && injectedObject.containsKey("extensions")) {
        Map extensionsObject = injectedObject["extensions"];
        if (extensionsObject.containsKey("thumbnail-generation")) {
          Map thumbnailData = extensionsObject["thumbnail-generation"];
          // First try to get from root level of thumbnail-generation
          thumbnailUrl = thumbnailData["url_small"] ??
              thumbnailData["url_medium"] ??
              thumbnailData["url_large"];
          // Fallback to attachments array if not found at root level
          if (thumbnailUrl == null && thumbnailData["attachments"] != null) {
            List attachments = thumbnailData["attachments"];
            for (var attachment in attachments) {
              if (attachment["error"] == null && attachment["data"] != null) {
                var thumbnails = attachment["data"]["thumbnails"];
                if (thumbnails != null) {
                  thumbnailUrl = thumbnails["url_small"] ??
                      thumbnails["url_medium"] ??
                      thumbnails["url_large"];
                  if (thumbnailUrl != null) break;
                }
              }
            }
          }
        }
      }
    }
    return MessageTemplateUtils.getVideoMessageBubble(
        message.attachment?.fileUrl,
        thumbnailUrl,
        message,
        null,
        context,
        additionalConfigurations?.videoBubbleStyle);
  }

  static Widget getTextMessageBubble(
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
      style: style as dynamic,
    );
  }


  static Widget getAudioMessageBubble(
      String? audioUrl,
      String? title,
      CometChatAudioBubbleStyle? style,
      MediaMessage message,
      BuildContext context,
      BubbleAlignment alignment) {
    return CometChatAudioBubbleV2(
      style: style,
      audioUrl: audioUrl,
      title: title,
      key: ValueKey('${message.id}_${message.muid}'),
      alignment: alignment,
      id: message.id,
      metadata: message.metadata,
    );
  }


  static Widget getFileMessageBubble(
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
      style: (style ?? const CometChatFileBubbleStyle()) as dynamic,
      title: title ?? "",
      id: id,
      fileSize: message.attachment?.fileSize,
      fileExtension: message.attachment?.fileExtension,
      dateTime: message.sentAt,
      metadata: message.metadata,
    );
  }


  static Widget getImageMessageBubble(
    String? imageUrl,
    String? placeholderImage,
    String? caption,
    CometChatImageBubbleStyle? style,
    MediaMessage message,
    Function()? onClick,
    BuildContext context,
  ) {
    return CometChatImageBubble(
        key: UniqueKey(),
        imageUrl: imageUrl,
        placeholderImage: placeholderImage,
        style: (style ?? const CometChatImageBubbleStyle()) as dynamic,
        onClick: onClick,
        metadata: message.metadata);
  }


  static Widget getCardMessageBubble(
      {CardBubbleStyle? cardBubbleStyle, required CardMessage message}) {
    return CometChatCardBubble(
      cardMessage: message,
      loggedInUser: CometChatUIKit.loggedInUser,
    );
  }


  static CometChatMessageTemplate getCardMessageTemplate() {
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
        // return MessageUIService.getCardMessageContentView(
        //     cardMessage, context, alignment, theme);
        return getMessageNotSupportedWidget(message, context);
      },
      //TODO: Implement CardMessage Options
      // options: MessageUIService.getCardMessageOptions,
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          [],
    );
  }


  static List<CometChatTextFormatter> getDefaultTextFormatters() {
    return <CometChatTextFormatter>[
      CometChatMentionsFormatter() as CometChatTextFormatter,
      CometChatEmailFormatter() as CometChatTextFormatter,
      CometChatPhoneNumberFormatter() as CometChatTextFormatter,
      CometChatUrlFormatter() as CometChatTextFormatter,
    ];
  }

  static Widget getMessageNotSupportedWidget(
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


  // -------- Extension Message Templates --------

  static CometChatMessageTemplate getPollMessageTemplate() {
    return CometChatMessageTemplate(
      type: ExtensionType.extensionPoll,
      category: MessageCategoryConstants.custom,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        if (message is! CustomMessage) {
          return getMessageNotSupportedWidget(message, context);
        }
        final customMessage = message;
        final metadata = customMessage.customData;
        if (metadata == null) {
          return getMessageNotSupportedWidget(message, context);
        }

        final String pollQuestion =
            metadata['question']?.toString() ?? '';
        final String loggedInUserUid =
            CometChatUIKit.loggedInUser?.uid ?? '';

        // Extract poll results from message metadata injected extensions
        Map<String, dynamic>? pollResults;
        final msgMetadata = customMessage.metadata;
        if (msgMetadata != null) {
          final injected = msgMetadata['@injected'];
          if (injected is Map && injected.containsKey('extensions')) {
            final extensions = injected['extensions'];
            if (extensions is Map && extensions.containsKey(ExtensionConstants.polls)) {
              final pollData = extensions[ExtensionConstants.polls];
              if (pollData is Map) {
                pollResults = Map<String, dynamic>.from(pollData);
              }
            }
          }
        }

        // Build options from poll results (has vote counts) or fall back to customData
        List<PollOptions> options = [];

        // Poll ID from extension metadata, fallback to message ID
        final String pollId = (pollResults != null && pollResults['id'] != null)
            ? pollResults['id'].toString()
            : customMessage.id.toString();

        if (pollResults != null) {
          // Vote data lives under pollResults['results']['options']
          // per CometChat docs: @injected.extensions.polls.results.options
          final Map<String, dynamic>? resultsMap =
              pollResults['results'] is Map
                  ? Map<String, dynamic>.from(pollResults['results'])
                  : null;

          if (resultsMap != null && resultsMap.containsKey('options')) {
            final Map<String, dynamic> opts =
                Map<String, dynamic>.from(resultsMap['options'] ?? {});
            for (var key in opts.keys) {
              final opt = opts[key];
              if (opt is Map) {
                final Map<String, dynamic> votersMap =
                    Map<String, dynamic>.from(opt['voters'] ?? {});
                final List<User> voters = votersMap.entries
                    .map((e) => User(
                          uid: e.key,
                          name: (e.value is Map ? e.value['name'] : null) ?? e.key,
                          avatar: e.value is Map ? e.value['avatar'] : null,
                        ))
                    .toList();
                options.add(PollOptions(
                  id: key,
                  optionText: opt['text']?.toString() ?? '',
                  voteCount: opt['count'] ?? 0,
                  votersUid: votersMap.keys.toList(),
                  voters: voters,
                ));
              }
            }
          } else if (pollResults.containsKey('options')) {
            // Fallback: poll exists but no votes yet — build from top-level options
            final topOptions = pollResults['options'];
            if (topOptions is Map) {
              for (var key in topOptions.keys) {
                options.add(PollOptions(
                  id: key.toString(),
                  optionText: topOptions[key]?.toString() ?? '',
                  voteCount: 0,
                  votersUid: [],
                  voters: [],
                ));
              }
            }
          }
        } else if (metadata.containsKey('options')) {
          // Fallback: build from customData options (no vote data)
          final rawOptions = metadata['options'];
          if (rawOptions is List) {
            for (int i = 0; i < rawOptions.length; i++) {
              options.add(PollOptions(
                id: (i + 1).toString(),
                optionText: rawOptions[i]?.toString() ?? '',
                voteCount: 0,
                votersUid: [],
                voters: [],
              ));
            }
          }
        }

        return CometChatPollsBubble(
          pollQuestion: pollQuestion,
          options: options,
          pollId: pollId,
          loggedInUser: loggedInUserUid,
          senderUid: customMessage.sender?.uid,
          metadata: pollResults,
          alignment: alignment,
          choosePoll: (String vote, String id) async {
            try {
              await CometChat.callExtension(
                ExtensionConstants.polls,
                'POST',
                ExtensionUrls.votePoll,
                {'vote': vote, 'id': id},
                onSuccess: (Map<String, dynamic> map) {
                  debugPrint('[Polls] Vote success: $map');
                },
                onError: (CometChatException e) {
                  debugPrint('[Polls] Vote error: ${e.code} ${e.message}');
                },
              );
            } catch (e) {
              debugPrint('[Polls] Vote exception: $e');
            }
          },
        );
      },
      options: MessageTemplateUtils.getCommonOptions,
    );
  }

  static CometChatMessageTemplate getStickerMessageTemplate() {
    return CometChatMessageTemplate(
      type: ExtensionType.sticker,
      category: MessageCategoryConstants.custom,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        if (message is! CustomMessage) {
          return getMessageNotSupportedWidget(message, context);
        }
        return CometChatStickerBubble(
          message: message,
        );
      },
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          MessageTemplateUtils.getCommonOptions(
              loggedInUser, messageObject, context, group, additionalConfigurations),
    );
  }

  static CometChatMessageTemplate getCollaborativeDocumentTemplate() {
    return CometChatMessageTemplate(
      type: ExtensionType.document,
      category: MessageCategoryConstants.custom,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        if (message is! CustomMessage) {
          return getMessageNotSupportedWidget(message, context);
        }
        String? documentUrl;
        final metadata = message.metadata;
        if (metadata != null) {
          final injected = metadata['@injected'];
          if (injected is Map && injected.containsKey('extensions')) {
            final extensions = injected['extensions'];
            if (extensions is Map &&
                extensions.containsKey(ExtensionConstants.document)) {
              final docData = extensions[ExtensionConstants.document];
              if (docData is Map) {
                documentUrl = docData['document_url']?.toString();
              }
            }
          }
        }
        documentUrl ??= message.customData?['document_url']?.toString();

        return CometChatCollaborativeBubble(
          url: documentUrl,
          title: Translations.of(context).collaborativeDocument,
          subtitle: Translations.of(context).openDocumentSubtitle,
          buttonText: Translations.of(context).openDocument,
          alignment: alignment,
          icon: Image.asset(
            AssetConstants.collaborativeDocumentFilled,
            package: UIConstants.packageName,
            height: 24,
            width: 24,
          ),
          previewImage: AssetConstants.collaborativeDocumentPreview,
        );
      },
      options: MessageTemplateUtils.getCommonOptions,
    );
  }

  static CometChatMessageTemplate getCollaborativeWhiteboardTemplate() {
    return CometChatMessageTemplate(
      type: ExtensionType.whiteboard,
      category: MessageCategoryConstants.custom,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        if (message is! CustomMessage) {
          return getMessageNotSupportedWidget(message, context);
        }
        String? whiteboardUrl;
        final metadata = message.metadata;
        if (metadata != null) {
          final injected = metadata['@injected'];
          if (injected is Map && injected.containsKey('extensions')) {
            final extensions = injected['extensions'];
            if (extensions is Map &&
                extensions.containsKey(ExtensionConstants.whiteboard)) {
              final wbData = extensions[ExtensionConstants.whiteboard];
              if (wbData is Map) {
                whiteboardUrl = wbData['board_url']?.toString();
              }
            }
          }
        }
        whiteboardUrl ??= message.customData?['board_url']?.toString();

        return CometChatCollaborativeBubble(
          url: whiteboardUrl,
          title: Translations.of(context).collaborativeWhiteboard,
          subtitle: Translations.of(context).openWhiteboardSubtitle,
          buttonText: Translations.of(context).openWhiteboard,
          alignment: alignment,
          icon: Image.asset(
            AssetConstants.collaborativeWhiteBoardFilled,
            package: UIConstants.packageName,
            height: 24,
            width: 24,
          ),
          previewImage: AssetConstants.collaborativeWhiteboardPreview,
        );
      },
      options: MessageTemplateUtils.getCommonOptions,
    );
  }

  // -------- Call Message Templates (used when enableCalls == true) --------

  /// Template for AI assistant messages (category: agentic, type: assistant).
  /// Renders using [CometChatAIAssistantBubble] with full markdown support.
  static CometChatMessageTemplate getAIAssistantMessageTemplate() {
    return CometChatMessageTemplate(
      type: CometChatMessageType.assistant,
      category: CometChatMessageCategory.categoryAgentic,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        if (message is AIAssistantMessage) {
          return CometChatAIAssistantBubble(
            message: message,
            alignment: alignment,
          );
        }
        // Fallback: render as text if somehow not AIAssistantMessage
        return Text(message.toString());
      },
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          [], // No long-press options for AI messages
    );
  }

  /// Template for stream messages (category: streamMessage, type: run_started).
  /// Renders using [CometChatStreamBubble] with shimmer streaming effect.
  static CometChatMessageTemplate getStreamMessageTemplate() {
    return CometChatMessageTemplate(
      type: CometChatMessageType.runStarted,
      category: CometChatMessageCategory.streamMessage,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message is StreamMessage) {
          return CometChatStreamBubble(
            message: message,
            alignment: alignment,
          );
        }
        return const SizedBox.shrink();
      },
      options: (loggedInUser, messageObject, context, group,
              additionalConfigurations) =>
          [], // No long-press options for stream messages
    );
  }

  static CometChatMessageTemplate _getGroupCallTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.meeting,
      category: MessageCategoryConstants.custom,
      options: MessageTemplateUtils.getCommonOptions,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message.deletedAt != null || message is! CustomMessage) {
          return getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        return _getCallBubble(message, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
    );
  }

  static Widget _getCallBubble(
      CustomMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    final loggedInUser = CometChatUIKit.loggedInUser;
    String? callType;
    if (message.customData != null &&
        message.customData?.containsKey('callType') == true) {
      callType = message.customData?['callType'];
    }
    String title;
    String icon;
    CometChatCallBubbleStyle? style;

    if (callType == CallTypeConstants.videoCall) {
      title = cc.Translations.of(context).videoCall;
      style = additionalConfigurations?.videoCallBubbleStyle;
      icon = message.sender?.uid == loggedInUser?.uid
          ? AssetConstants.videoOutgoing
          : AssetConstants.videoIncoming;
    } else {
      title = cc.Translations.of(context).voiceCall;
      style = additionalConfigurations?.voiceCallBubbleStyle;
      icon = message.sender?.uid == loggedInUser?.uid
          ? AssetConstants.voiceOutgoing
          : AssetConstants.voiceIncoming;
    }

    String receiver = message.receiverUid;
    String? subtitle;
    if (message.sentAt != null) {
      subtitle = DateFormat('d MMM, hh:mm a').format(message.sentAt!);
    }

    final callingConfig = CometChatUIKit.authenticationSettings?.callingConfiguration;

    return CometChatCallBubble(
      title: title,
      iconUrl: icon,
      subtitle: subtitle,
      onTap: (context) => _initiateDirectCall(context, receiver, message,
          callingConfig: callingConfig,
          call: Call(
              receiverUid: receiver,
              receiverType: CometChatReceiverType.group,
              category: MessageCategoryConstants.call,
              type: MessageTypeConstants.meeting)),
      style: style,
      alignment: alignment,
    );
  }

  static void _initiateDirectCall(
      BuildContext context, String sessionID, CustomMessage message,
      {Call? call, CallingConfiguration? callingConfig}) async {
    SessionSettingsBuilder defaultSessionSettingsBuilder;
    if (callingConfig?.groupSessionSettingsBuilder != null) {
      defaultSessionSettingsBuilder = callingConfig!.groupSessionSettingsBuilder!;
    } else {
      defaultSessionSettingsBuilder =
          SessionSettingsBuilder().setLayout(LayoutType.tile);
    }
    String? callType;
    String? sessionId;
    if (message.customData != null &&
        message.customData?.containsKey('callType') == true) {
      callType = message.customData?['callType'];
    }
    if (message.customData != null &&
        message.customData?.containsKey('sessionID') == true) {
      sessionId = message.customData?['sessionID'];
    }
    if (callType == CallTypeConstants.audioCall) {
      // Workaround: SessionType.audio is not recognized by the native
      // Android SDK (beta bug). Use startVideoPaused + hide video buttons.
      defaultSessionSettingsBuilder
        .startVideoPaused(true)
        .hideSwitchCameraButton(true)
        .hideToggleVideoButton(true);
    }
    CallScreenOverlay.show(
      sessionId: sessionId ?? sessionID,
      sessionSettingsBuilder: defaultSessionSettingsBuilder,
      callWorkFlow: CallWorkFlow.directCalling,
    );
  }

  static CometChatMessageTemplate _getDefaultVoiceCallTemplate() {
    return CometChatMessageTemplate(
      type: CallTypeConstants.audioCall,
      category: MessageCategoryConstants.call,
      footerView: null,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message is Call) {
          final loggedInUser = CometChatUIKit.loggedInUser;
          final CometChatColorPalette colorPalette =
              CometChatThemeHelper.getColorPalette(context);
          final typography = CometChatThemeHelper.getTypography(context);
          return CometChatActionBubble(
            text: CallUtils.getCallStatus(context, message, loggedInUser),
            leadingIcon: Image.asset(
              CallUtils.getCallIconByStatus(
                  context, message, loggedInUser, true),
              package: UIConstants.packageName,
              color: CallUtils.getCallTextColor(
                  context, message, loggedInUser, colorPalette),
              height: 20,
              width: 20,
            ),
            style: CometChatActionBubbleStyle(
              textStyle: TextStyle(
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                  color: CallUtils.getCallTextColor(
                      context, message, loggedInUser, colorPalette),
                  letterSpacing: 0),
            ).merge(additionalConfigurations?.actionBubbleStyle),
          );
        } else {
          return null;
        }
      },
    );
  }

  static CometChatMessageTemplate _getDefaultVideoCallTemplate() {
    return CometChatMessageTemplate(
      type: CallTypeConstants.videoCall,
      category: MessageCategoryConstants.call,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message is Call) {
          final loggedInUser = CometChatUIKit.loggedInUser;
          final CometChatColorPalette colorPalette =
              CometChatThemeHelper.getColorPalette(context);
          final typography = CometChatThemeHelper.getTypography(context);

          return CometChatActionBubble(
            text: CallUtils.getCallStatus(context, message, loggedInUser),
            leadingIcon: Image.asset(
              CallUtils.getCallIconByStatus(
                  context, message, loggedInUser, false),
              package: UIConstants.packageName,
              color: CallUtils.getCallIconColor(
                  context, message, loggedInUser, colorPalette),
              height: 24,
              width: 24,
            ),
            style: CometChatActionBubbleStyle(
              textStyle: TextStyle(
                fontSize: typography.caption1?.regular?.fontSize,
                fontWeight: typography.caption1?.regular?.fontWeight,
                color: CallUtils.getCallTextColor(
                    context, message, loggedInUser, colorPalette),
              ),
            ).merge(additionalConfigurations?.actionBubbleStyle),
          );
        } else {
          return null;
        }
      },
    );
  }
}
