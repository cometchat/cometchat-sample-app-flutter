import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:get/get.dart';
import '../utils/page_manager.dart';
import 'messages_controller.dart';

class MessagesSample extends StatefulWidget {
  final User? user;
  final Group? group;
  final BaseMessage? parentMessage;
  final bool? isHistory;

  const MessagesSample(
      {Key? key, this.user, this.group, this.parentMessage, this.isHistory})
      : super(key: key);

  @override
  State<MessagesSample> createState() => _MessagesSampleState();
}

class _MessagesSampleState extends State<MessagesSample> {
  late CometChatMessagesController messagesController;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    messagesController = CometChatMessagesController(widget.user, widget.group);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  CometChatMentionsFormatter getMentionsTap() {
    CometChatMentionsFormatter mentionsFormatter;
    return mentionsFormatter = CometChatMentionsFormatter(
      user: widget.user,
      group: widget.group,
      onMentionTap: (mention, mentionedUser, {message}) {
        if (mentionedUser.uid != CometChatUIKit.loggedInUser!.uid) {
          PageManager().navigateToMessages(
            context: context,
            user: mentionedUser,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ccColor = CometChatThemeHelper.getColorPalette(context);
    return GetBuilder<CometChatMessagesController>(
      init: messagesController,
      tag: messagesController.tag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ccColor.background1,
          appBar: CometChatMessageHeader(
            user: widget.user,
            group: widget.group,
            messageHeaderStyle: CometChatMessageHeaderStyle(
                backgroundColor:
                    (controller.isUserAgentic()) ? ccColor.background1 : null,
                border: (controller.isUserAgentic())
                    ? Border(
                        bottom: BorderSide(
                          color: ccColor.borderLight ?? Colors.transparent,
                          width: 1.0,
                        ),
                      )
                    : null,
                statusIndicatorStyle: CometChatStatusIndicatorStyle(
                  backgroundColor: colorPalette.transparent,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    width: 0,
                    color: colorPalette.transparent ?? Colors.transparent,
                  ),
                )),
            hideVideoCallButton: widget.user != null
                ? (controller.user?.blockedByMe == true ||
                    controller.isUserAgentic())
                : widget.group != null
                    ? (controller.group?.hasJoined == false ||
                        controller.group?.isBannedFromGroup == true)
                    : false,
            hideVoiceCallButton: widget.user != null
                ? (controller.user?.blockedByMe == true ||
                    controller.isUserAgentic())
                : widget.group != null
                    ? (controller.group?.hasJoined == false ||
                        controller.group?.isBannedFromGroup == true)
                    : false,
            onBack: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            chatHistoryButtonClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CometChatAIAssistantChatHistory(
                    user: widget.user,
                    group: widget.group,
                    onNewChatButtonClicked: () {
                      onNewChatClicked(true);
                    },
                    onMessageClicked: (message) {
                      if (message != null) {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesSample(
                              user: widget.user,
                              group: widget.group,
                              parentMessage: message,
                              isHistory: true,
                            ),
                          ),
                        );
                      }
                    },
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
            newChatButtonClick: () {
              onNewChatClicked(false);
            },
          ),
          resizeToAvoidBottomInset: true,
          body: Container(
            color: ccColor.background3,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: getMessageList(
                        user: widget.user,
                        group: widget.group,
                        context: context,
                        parentMessage: widget.parentMessage,
                        controller: controller,
                      ),
                    ),
                  ),
                  getComposer(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getComposer(CometChatMessagesController controller) {
    bool agentic = controller.isUserAgentic();
    if (controller.user != null &&
        controller.user?.blockedByMe != null &&
        controller.user?.blockedByMe! == true) {
      return _buildBlockedUserSection(controller);
    } else if (controller.group != null &&
        (controller.group?.hasJoined == false ||
            controller.group?.isBannedFromGroup == true)) {
      return _buildKickedFromGroup(controller);
    } else {
      return CometChatMessageComposer(
        user: widget.user,
        group: widget.group,
        disableMentions:
            controller.isUserAgentic() ? true : false,
        placeholderText: (controller.isUserAgentic())
            ? "${cc.Translations.of(context).askAnything}..."
            : null,
        parentMessageId: widget.parentMessage?.id ?? 0,
        messageComposerStyle: CometChatMessageComposerStyle(
          dividerColor: agentic ? Colors.transparent : null,
          dividerHeight: agentic ? 0 : null,
          backgroundColor: agentic ? colorPalette.background1 : null,
        ),
      );
    }
  }

  Widget _buildBlockedUserSection(CometChatMessagesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding5 ?? 20,
      ),
      color: colorPalette.background4,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
            child: Text(
              cc.Translations.of(context).cantSendMessageBlockedUser,
              style: TextStyle(
                color: colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ),
            ),
          ),
          controller.isBlockLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorPalette.background2,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.unBlockUser(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          colorPalette.transparent, // Set proper color
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(spacing.radius2 ?? 0),
                        side: BorderSide(
                          color: colorPalette.borderDark ?? Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      cc.Translations.of(context).unBlock,
                      style: TextStyle(
                        color: colorPalette.textPrimary,
                        fontSize: typography.caption1?.regular?.fontSize,
                        fontWeight: typography.caption1?.regular?.fontWeight,
                        fontFamily: typography.caption1?.regular?.fontFamily,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildKickedFromGroup(CometChatMessagesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding5 ?? 20,
      ),
      color: colorPalette.background4,
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
        child: Text(
          cc.Translations.of(context).cantSendMessageNotMember,
          style: TextStyle(
            color: colorPalette.textSecondary,
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
          ),
        ),
      ),
    );
  }

  onNewChatClicked(bool isHistory) async {
    if (isHistory) {
      Navigator.of(context).pop();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesSample(
          user: widget.user,
          group: widget.group,
        ),
      ),
    );
  }

  Widget getMessageList({
    User? user,
    Group? group,
    context,
    BaseMessage? parentMessage,
    required CometChatMessagesController controller,
  }) {
    MessagesRequestBuilder? requestBuilder = MessagesRequestBuilder();

    if (widget.isHistory != null &&
        widget.isHistory == true &&
        parentMessage != null &&
        controller.isUserAgentic()) {
      requestBuilder = MessagesRequestBuilder()
        ..parentMessageId = parentMessage.id
        ..withParent = true
        ..hideReplies = true;
    }

    return CometChatMessageList(
      user: user,
      group: group,
      textFormatters: [
        getMentionsTap(),
      ],
      hideReplyInThreadOption: (controller.isUserAgentic())
          ? true
          : false,
      hideThreadView: true,
      messagesRequestBuilder: requestBuilder,
        style: CometChatMessageListStyle(
          backgroundColor:
          (controller.isUserAgentic()) ? colorPalette.background3 : null,
          outgoingMessageBubbleStyle: CometChatOutgoingMessageBubbleStyle(
            textBubbleStyle: CometChatTextBubbleStyle(
              backgroundColor:
              (controller.isUserAgentic()) ? colorPalette.background4 : null,
              textColor:
              (controller.isUserAgentic()) ? colorPalette.textPrimary : null,
              messageBubbleDateStyle: CometChatDateStyle(
                textColor:
                (controller.isUserAgentic()) ? colorPalette.neutral600 : null,
              ),
            ),
            messageBubbleDateStyle: CometChatDateStyle(
              textColor:
              (controller.isUserAgentic()) ? colorPalette.textPrimary : null,
            ),
          ),
        ),
    );
  }
}
