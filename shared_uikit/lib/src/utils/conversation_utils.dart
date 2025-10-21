import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;

///[ConversationUtils] is an Utility class that helps to
///the last message for any conversation and also
///provides the default action to execute on a conversation
class ConversationUtils {
  static List<CometChatOption>? getDefaultOptions(
      Conversation conversation,
      CometChatConversationsControllerProtocol controller,
      BuildContext context,
      CometChatColorPalette colorPalette,
      ) {
    return [
      CometChatOption(
          id: ConversationOptionConstants.delete,
          icon: AssetConstants.delete,
          packageName: UIConstants.packageName,
          backgroundColor: colorPalette.background1,
          iconTint: colorPalette.error,
          title: Translations.of(context).delete,
          onClick: () {
            controller.deleteConversation(conversation);
          },
      ),
    ];
  }

  static String getLastCustomMessage(
      Conversation conversation, BuildContext context) {
    if(conversation.lastMessage is CustomMessage) {
      CustomMessage customMessage = conversation.lastMessage as CustomMessage;
      String messageType = customMessage.type;
      String subtitle = '';

      switch (messageType) {
        default:
          subtitle = messageType;
          break;
      }
      return subtitle;
    } else if(conversation.lastMessage is AIAssistantMessage) {
      AIAssistantMessage aiAssistantMessage = conversation.lastMessage as AIAssistantMessage;
      String messageType = aiAssistantMessage.type;
      String subtitle = '';

      switch (messageType) {
        default:
          subtitle = messageType;
          break;
      }
      return subtitle;
    } else {
      return "";
    }
  }

  static String getLastMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage message = conversation.lastMessage!;
    String messageType = message.type;
    String subtitle;

    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = (message as TextMessage).text;
        if (message.mentionedUsers.isNotEmpty) {
          subtitle = CometChatMentionsFormatter.getTextWithMentions(
              message.text, message.mentionedUsers);
        }

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
    }
    return subtitle;
  }

  static String getLastInteractiveMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage message = conversation.lastMessage!;
    String messageType = message.type;
    String subtitle;
    switch (messageType) {
      case MessageTypeConstants.form:
        subtitle = Translations.of(context).formMessage;
        break;
      case MessageTypeConstants.card:
        subtitle = Translations.of(context).cardMessage;
        break;
      case MessageTypeConstants.scheduler:
        SchedulerMessage schedulerMessage =
            SchedulerMessage.fromInteractiveMessage(
                message as InteractiveMessage);
        String meetingMessage =
            SchedulerUtils.getSchedulerTitle(schedulerMessage, context);
        subtitle = "🗓️ $meetingMessage";
        break;
      default:
        subtitle = messageType;
    }
    return subtitle;
  }

  static String getLastActionMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage message = conversation.lastMessage!;
    String subtitle;

    if (message.type == MessageTypeConstants.groupActions) {
      cc.Action actionMessage = message as cc.Action;
      subtitle = actionMessage.message ?? "";
    } else {
      subtitle = message.type;
    }

    return subtitle;
  }

  static String getLastCallMessage(
      Conversation conversation, BuildContext context) {
    Call call = conversation.lastMessage as Call;
    User? conversationWithUser;
    Group? conversationWithGroup;

    if (conversation.conversationWith is User) {
      conversationWithUser = conversation.conversationWith as User;
    } else if (conversation.conversationWith is Group) {
      conversationWithGroup = conversation.conversationWith as Group;
    }

    String subtitle = call.type;
    Group? callInitiatorGroup;
    User? callInitiatorUser;
    if (call.callInitiator is User) {
      callInitiatorUser = call.callInitiator as User;
    } else {
      callInitiatorGroup = call.callInitiator as Group;
    }

    if (call.callStatus == CallStatusConstants.ongoing) {
      subtitle = Translations.of(context).ongoingCall;
    } else if (call.callStatus == CallStatusConstants.ended ||
        call.callStatus == CallStatusConstants.initiated) {
      if ((callInitiatorUser != null &&
              conversationWithUser != null &&
              callInitiatorUser.uid == conversationWithUser.uid) ||
          (callInitiatorGroup != null &&
              conversationWithGroup != null &&
              callInitiatorGroup.guid == conversationWithGroup.guid)) {
        if (call.type == MessageTypeConstants.audio) {
          subtitle = Translations.of(context).incomingAudioCall;
        } else {
          subtitle = Translations.of(context).incomingVideoCall;
        }
      } else {
        if (call.type == MessageTypeConstants.audio) {
          subtitle = Translations.of(context).outgoingAudioCall;
        } else {
          subtitle = Translations.of(context).outgoingVdeoCall;
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
          subtitle = Translations.of(context).missedVoiceCall;
        } else {
          subtitle = Translations.of(context).missedVideoCall;
        }
      } else {
        if (call.type == MessageTypeConstants.audio) {
          subtitle = Translations.of(context).unansweredAudioCall;
        } else {
          subtitle = Translations.of(context).unansweredVideoCall;
        }
      }
    }
    return subtitle;
  }

  static String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    String? messageCategory = conversation.lastMessage?.category;
    String subtitle;
    switch (messageCategory) {
      case MessageCategoryConstants.message:
        subtitle = getLastMessage(conversation, context);
        break;
      case MessageCategoryConstants.custom:
        subtitle = getLastCustomMessage(conversation, context);
        break;
      case MessageCategoryConstants.action:
        subtitle = getLastActionMessage(conversation, context);
        break;
      case MessageCategoryConstants.call:
        subtitle = getLastCallMessage(conversation, context);
        break;
      case MessageCategoryConstants.interactive:
        //TODO: appropriate implement interactive message subtitle
        // subtitle = getLastInteractiveMessage(conversation, context);
        subtitle = Translations.of(context).unsupportedMessageType;
        break;
      default:
        subtitle = conversation.lastMessage!.type;
        break;
    }

    return subtitle;
  }

  // return icon widget to be shown in the prefix to the last message

  static Widget getLastConversationIcon(
      Conversation conversation, BuildContext context, Color? iconColor) {
    String? messageCategory = conversation.lastMessage?.category;
    Widget subtitle;
    switch (messageCategory) {
      case MessageCategoryConstants.message:
        subtitle = getLastMessageWidget(conversation, context, iconColor);
        break;
      case MessageCategoryConstants.custom:
        subtitle = getLastCustomWidget(conversation, context, iconColor);
        break;
      // case MessageCategoryConstants.action:
      //   subtitle = getLastActionMessage(conversation, context);
      //   break;
      case MessageCategoryConstants.call:
        subtitle = getLastCallWidget(conversation, context, iconColor);
        break;
      case MessageCategoryConstants.interactive:
        // subtitle = getLastInteractiveWidget(conversation, context);
        subtitle =  Icon(
    Icons.block,
    color:  iconColor,
    size: 16,
    )
    ;
        break;
      default:
        subtitle = const SizedBox();
        break;
    }

    return subtitle;
  }

  static Widget getLastMessageWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    BaseMessage message = conversation.lastMessage!;
    String messageType = message.type;
    Widget subtitle;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    switch (messageType) {
      case MessageTypeConstants.text:
        subtitle = _getLastTextMessageWidget(conversation, context, iconColor);
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
          Icons.videocam,
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
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    BaseMessage message = conversation.lastMessage!;
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

  static Widget getLastCustomWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    BaseMessage message = conversation.lastMessage!;
    String messageType = message.type;
    Widget subtitle;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

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
      default:
        subtitle = const SizedBox();
    }
    return subtitle;
  }

  static Widget getLastCallWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    Call call = conversation.lastMessage as Call;
    User? conversationWithUser;
    Group? conversationWithGroup;

    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    if (conversation.conversationWith is User) {
      conversationWithUser = conversation.conversationWith as User;
    } else if (conversation.conversationWith is Group) {
      conversationWithGroup = conversation.conversationWith as Group;
    }

    Widget subtitle = const SizedBox();
    Group? callInitiatorGroup;
    User? callInitiatorUser;
    if (call.callInitiator is User) {
      callInitiatorUser = call.callInitiator as User;
    } else {
      callInitiatorGroup = call.callInitiator as Group;
    }

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
}
