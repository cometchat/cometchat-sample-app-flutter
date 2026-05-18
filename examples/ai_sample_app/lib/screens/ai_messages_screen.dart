import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class AiMessagesScreen extends StatefulWidget {
  final User user;
  final BaseMessage? parentMessage;
  final bool isHistory;
  const AiMessagesScreen({super.key, required this.user, this.parentMessage, this.isHistory = false});
  @override
  State<AiMessagesScreen> createState() => _AiMessagesScreenState();
}

class _AiMessagesScreenState extends State<AiMessagesScreen> {
  Widget _buildMessageList() {
    int? parentMessageId;
    MessagesRequestBuilder? requestBuilder;
    if (widget.parentMessage != null && widget.isHistory) {
      parentMessageId = widget.parentMessage!.id;
      requestBuilder = MessagesRequestBuilder()
        ..parentMessageId = widget.parentMessage!.id
        ..withParent = true
        ..hideReplies = false;
    }
    return CometChatMessageList(
      user: widget.user,
      parentMessageId: parentMessageId,
      messagesRequestBuilder: requestBuilder,
      hideReplies: widget.isHistory ? false : true,
      disableReactions: true,
      enableSwipeToReply: false,
      enableSmartReplies: true,
      enableConversationStarters: true,
      hideReplyInThreadOption: true,
      textFormatters: [
        CometChatMentionsFormatter(user: widget.user),
        MarkdownTextFormatter(),
        CometChatUrlFormatter(),
        CometChatPhoneNumberFormatter(),
        CometChatEmailFormatter(),
      ],
    );
  }

  Widget _buildComposer() {
    return CometChatMessageComposer(
      user: widget.user,
      parentMessageId: widget.parentMessage?.id ?? 0,
      placeholderText: 'Ask anything...',
      disableTypingEvents: true,
      hideVoiceRecordingButton: true,
      hideAttachmentButton: true,
      hideStickersButton: true,
      disableMentions: true,
      textFormatters: [],
      enableRichTextFormatting: false,
    );
  }

  void _openChatHistory(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => CometChatAIAssistantChatHistory(
      user: widget.user,
      onNewChatButtonClicked: () {
        if (widget.isHistory) Navigator.of(ctx).pop();
        Navigator.pushReplacement(ctx,
          MaterialPageRoute(builder: (_) => AiMessagesScreen(user: widget.user)));
      },
      onMessageClicked: (message) {
        if (message != null) {
          Navigator.of(ctx)..pop()..pop();
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => AiMessagesScreen(
            user: widget.user, parentMessage: message, isHistory: true)));
        }
      },
      onClose: () => Navigator.of(ctx).pop(),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Scaffold(
      backgroundColor: colorPalette.background1,
      resizeToAvoidBottomInset: false,
      appBar: CometChatMessageHeader(
        user: widget.user,
        onBack: () => Navigator.pop(context),
        hideVideoCallButton: true,
        hideVoiceCallButton: true,
        chatHistoryButtonClick: () => _openChatHistory(context),
        messageHeaderStyle: CometChatMessageHeaderStyle(
          backgroundColor: colorPalette.background1,
          border: Border(bottom: BorderSide(
            color: colorPalette.borderLight ?? Colors.transparent, width: 1.0))),
        trailingView: (user, group, ctx) => [
          IconButton(icon: Icon(Icons.add, color: colorPalette.iconPrimary),
            tooltip: 'New Chat',
            onPressed: () => Navigator.pushReplacement(ctx,
              MaterialPageRoute(builder: (_) => AiMessagesScreen(user: widget.user)))),
          IconButton(icon: Icon(Icons.history, color: colorPalette.iconPrimary),
            tooltip: 'AI Chat History',
            onPressed: () => _openChatHistory(ctx)),
        ]),
      body: Container(
        color: colorPalette.background3,
        child: Column(children: [
          Expanded(child: _buildMessageList()),
          _buildComposer(),
        ])),
    );
  }
}
