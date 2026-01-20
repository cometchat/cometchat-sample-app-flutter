import 'package:cometchat_sdk/models/base_message.dart' as cc;
import 'package:flutter/material.dart';

import '../../cometchat_uikit_shared.dart';

///[ComposerUtils] is an Utility class that helps to

class ComposerUtils {
  // return icon widget to be shown in the prefix to the last message

  static Widget getReplyIcon(
      cc.BaseMessage message, BuildContext context, Color? iconColor) {
    String? messageCategory = message.category;
    Widget subtitle;
    if (message.deletedAt != null) {
      final colorPalette = CometChatThemeHelper.getColorPalette(context);
      subtitle = Icon(
        Icons.block,
        color: iconColor ?? colorPalette.iconSecondary,
        size: 16,
      );
      return subtitle;
    }
    switch (messageCategory) {
      case MessageCategoryConstants.message:
        subtitle = getReplyMessageWidget(message, context, iconColor);
        break;
      case MessageCategoryConstants.custom:
        subtitle = getReplyCustomWidget(message, context, iconColor);
        break;
      // case MessageCategoryConstants.action:
      //   subtitle = getLastActionMessage(conversation, context);
      //   break;
      case MessageCategoryConstants.call:
        subtitle = getReplyCallWidget(message, context, iconColor);
        break;
      case MessageCategoryConstants.interactive:
        // subtitle = getLastInteractiveWidget(conversation, context);
        subtitle = Icon(
          Icons.block,
          color: iconColor,
          size: 16,
        );
        break;
      default:
        subtitle = const SizedBox();
        break;
    }

    return subtitle;
  }

  static Widget getReplyMessageWidget(
    BaseMessage message,
    BuildContext context,
    Color? iconColor,
  ) {
    String messageType = message.type;
    Widget subtitle;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = _getLastTextMessageWidget(message, context, iconColor);
        break;
      case MessageTypeConstants.image:
        subtitle = Icon(
          Icons.photo,
          color: iconColor ?? colorPalette.iconSecondary,
          size: 16,
        );
        break;
      case MessageTypeConstants.video:
        subtitle = Icon(
          Icons.photo,
          color: iconColor ?? colorPalette.iconSecondary,
          size: 16,
        );
        break;
      case MessageTypeConstants.file:
        subtitle = Icon(
          Icons.description,
          color: iconColor ?? colorPalette.iconSecondary,
          size: 16,
        );
        break;
      case MessageTypeConstants.audio:
        subtitle = Icon(
          Icons.mic,
          color: iconColor ?? colorPalette.iconSecondary,
          size: 16,
        );
        break;
      default:
        subtitle = const SizedBox();
    }
    return subtitle;
  }

  static Widget _getLastTextMessageWidget(
    BaseMessage message,
    BuildContext context,
    Color? iconColor,
  ) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    if (message.metadata != null && _checkForLinks(message.metadata!)) {
      return Icon(
        Icons.link,
        color: iconColor ?? colorPalette.iconSecondary,
        size: 16,
      );
    } else {
      return const SizedBox();
    }
  }

  static bool _checkForLinks(Map<String, dynamic> metadata) {
    // Check if the metadata contains the '@injected' key
    if (metadata.containsKey('@injected')) {
      var injected = metadata['@injected'];

      // Check if 'extensions' exists within 'injected'
      if (injected != null && injected['extensions'] != null) {
        var extensions = injected['extensions'];

        // Check if 'link-preview' exists within 'extensions'
        if (extensions['link-preview'] != null) {
          var linkPreview = extensions['link-preview'];

          // Check if 'links' exists within 'link-preview'
          if (linkPreview['links'] != null) {
            List<dynamic> links = linkPreview['links'];

            // Return true if the list of links is not empty
            return links.isNotEmpty;
          }
        }
      }
    }
    // Return false if no links were found
    return false;
  }

  static Widget getReplyCustomWidget(
    BaseMessage message,
    BuildContext context,
    Color? iconColor,
  ) {
    String messageType = message.type;
    Widget subtitle;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    print("Custom message type: $messageType");
    print("Custom message type: ${message.toString()}");

    switch (messageType) {
      case ExtensionType.extensionPoll:
        subtitle = Icon(
          Icons.bar_chart,
          color: iconColor ?? colorPalette.iconSecondary,
          size: 16,
        );
        break;
      case ExtensionType.document:
        subtitle = Image.asset(
          AssetConstants.collaborativeDocumentFilled,
          package: UIConstants.packageName,
          color: iconColor ?? colorPalette.iconSecondary,
          height: 16,
          width: 16,
        );
        break;
      case ExtensionType.sticker:
        subtitle = Image.asset(
          AssetConstants.stickerFilled,
          package: UIConstants.packageName,
          color: iconColor ?? colorPalette.iconSecondary,
          height: 16,
          width: 16,
        );
        break;
      case ExtensionType.whiteboard:
        subtitle = Image.asset(
          AssetConstants.collaborativeWhiteBoardFilled,
          package: UIConstants.packageName,
          color: iconColor ?? colorPalette.iconSecondary,
          height: 16,
          width: 16,
        );
        break;
      case ExtensionType.meeting:
        subtitle = getMeetingIcon(message, context, iconColor);
        break;
      default:
        subtitle = const SizedBox();
    }
    return subtitle;
  }

  static Widget getReplyCallWidget(
    BaseMessage message,
    BuildContext context,
    Color? iconColor,
  ) {
    Call call = message as Call;
    User? conversationWithUser;
    Group? conversationWithGroup;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    if (message.callReceiver is User) {
      conversationWithUser = message.callReceiver as User;
    } else if (message.callReceiver is Group) {
      conversationWithGroup = message.callReceiver as Group;
    }

    Widget subtitle = const SizedBox();
    Group? callInitiatorGroup;
    User? callInitiatorUser;
    if (call.callInitiator is User) {
      callInitiatorUser = call.callInitiator as User;
    } else {
      callInitiatorGroup = call.callInitiator as Group;
    }

    print("Call Status: ${call.callStatus}");

    if (call.callStatus == CallStatusConstants.ongoing) {
      subtitle = const SizedBox();
    } else if (call.callStatus == CallStatusConstants.ended ||
        call.callStatus == CallStatusConstants.initiated) {
      if ((callInitiatorUser != null &&
              conversationWithUser != null &&
              callInitiatorUser.uid == conversationWithUser.uid) ||
          (callInitiatorGroup != null &&
              conversationWithGroup != null &&
              callInitiatorGroup.guid == conversationWithGroup.guid)) {
        if (call.type == MessageTypeConstants.audio) {
          subtitle = Image.asset(
            AssetConstants.voiceIncoming,
            package: UIConstants.packageName,
            color: iconColor ?? colorPalette.iconSecondary,
            height: 16,
            width: 16,
          );
        } else {
          subtitle = Image.asset(
            AssetConstants.videoIncoming,
            package: UIConstants.packageName,
            color: iconColor ?? colorPalette.iconSecondary,
            height: 16,
            width: 16,
          );
        }
      } else {
        if (call.type == MessageTypeConstants.audio) {
          subtitle = Image.asset(
            AssetConstants.voiceIncoming,
            package: UIConstants.packageName,
            color: iconColor ?? colorPalette.iconSecondary,
            height: 16,
            width: 16,
          );
        } else {
          subtitle = Image.asset(
            AssetConstants.voiceIncoming,
            package: UIConstants.packageName,
            color: iconColor ?? colorPalette.iconSecondary,
            height: 16,
            width: 16,
          );
        }
      }
    } else if (call.callStatus == CallStatusConstants.cancelled ||
        call.callStatus == CallStatusConstants.unanswered ||
        call.callStatus == CallStatusConstants.rejected ||
        call.callStatus == CallStatusConstants.busy) {
      if ((callInitiatorUser != null &&
              conversationWithUser != null &&
              callInitiatorUser.uid == conversationWithUser.uid) ||
          (callInitiatorGroup != null &&
              conversationWithGroup != null &&
              callInitiatorGroup.guid == conversationWithGroup.guid)) {
        if (call.type == MessageTypeConstants.audio) {
          // subtitle = Translations.of(context).missedVoiceCall; // TODO
        } else {
          // subtitle = Translations.of(context).missedVideoCall; // TODO
        }
      } else {
        if (call.type == MessageTypeConstants.audio) {
          // subtitle = Translations.of(context).unansweredAudioCall; // TODO
        } else {
          // subtitle = Translations.of(context).unansweredVideoCall; // TODO
        }
      }
    }
    return subtitle;
  }

  static Widget getMeetingIcon(
    BaseMessage message,
    BuildContext context,
    Color? iconColor,
  ) {
    try {
      final colorPalette = CometChatThemeHelper.getColorPalette(context);
      CustomMessage meetingMessage = message as CustomMessage;
      if (meetingMessage.customData != null) {
        bool isAudio = (meetingMessage.customData!["callType"] == null)
            ? false
            : (meetingMessage.customData!["callType"] ==
                    CallTypeConstants.audioCall)
                ? true
                : false;
        return Image.asset(
          isAudio ? AssetConstants.voiceOutgoing : AssetConstants.videoOutgoing,
          package: UIConstants.packageName,
          color: iconColor ?? colorPalette.iconSecondary,
          height: 16,
          width: 16,
        );
      }
      return const SizedBox();
    } catch (e) {
      return const SizedBox();
    }
  }

  String getReplySubtitle(BaseMessage? message, BuildContext context) {
    if (message == null) {
      return "";
    }
    String subtitle = message.type;
    String messageType = message.type;
    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = Translations.of(context).text;
        break;
      case MessageTypeConstants.image:
        subtitle = (message as MediaMessage).attachment?.fileName ??
            Translations.of(context).messageImage;
        break;
      case MessageTypeConstants.video:
        subtitle = (message as MediaMessage).attachment?.fileName ??
            Translations.of(context).messageVideo;
        break;
      case MessageTypeConstants.file:
        subtitle = (message as MediaMessage).attachment?.fileName ??
            Translations.of(context).messageFile;
        break;
      case MessageTypeConstants.audio:
        subtitle = (message as MediaMessage).attachment?.fileName ??
            Translations.of(context).messageAudio;
        break;
      case ExtensionType.extensionPoll:
        subtitle = Translations.of(context).poll;
        break;
      case ExtensionType.document:
        subtitle = Translations.of(context).document;
        break;
      case ExtensionType.sticker:
        subtitle = Translations.of(context).sticker;
        break;
      case ExtensionType.whiteboard:
        subtitle = Translations.of(context).collaborateUsingWhiteboard;
        break;
      default:
        subtitle = messageType;
        break;
    }
    return subtitle;
  }
}
