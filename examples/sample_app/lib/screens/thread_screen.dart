import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({
    super.key,
    this.user,
    this.group,
    required this.message,
    this.template,
    this.goToMessageId,
  });

  final User? user;
  final Group? group;
  final BaseMessage message;
  final CometChatMessageTemplate? template;

  /// When set, the thread's message list scrolls to and highlights this
  /// specific reply. Used when navigating into the thread from search
  /// results so the tapped reply is immediately visible.
  final int? goToMessageId;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    final requestBuilder = MessagesRequestBuilder()
      ..parentMessageId = widget.message.id;

    return Scaffold(
      backgroundColor: colorPalette.background1,
      resizeToAvoidBottomInset: true,
      appBar: CometChatMessageHeader(
        user: widget.user,
        group: widget.group,
        onBack: () => Navigator.pop(context),
        listItemView: (group, user, context) {
          final name = group?.name ?? user?.name ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.of(context).thread,
                style: TextStyle(
                  color: colorPalette.textPrimary,
                  fontSize: typography.heading2?.bold?.fontSize,
                  fontFamily: typography.heading2?.bold?.fontFamily,
                  fontWeight: typography.heading2?.bold?.fontWeight,
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorPalette.textSecondary,
                    fontSize: typography.caption1?.regular?.fontSize,
                    fontFamily: typography.caption1?.regular?.fontFamily,
                    fontWeight: typography.caption1?.regular?.fontWeight,
                  ),
                ),
              ),
            ],
          );
        },
        messageHeaderStyle: CometChatMessageHeaderStyle(
          backIconColor: colorPalette.iconPrimary,
          backgroundColor: colorPalette.background1,
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: colorPalette.borderLight ?? Colors.transparent,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: colorPalette.background3,
          child: Column(
            children: [
              CometChatThreadedHeader(
                parentMessage: widget.message,
                loggedInUser: CometChatUIKit.loggedInUser!,
                template: widget.template,
                textFormatters: [
                  CometChatMentionsFormatter(
                      user: widget.user, group: widget.group),
                  MarkdownTextFormatter(),
                  CometChatUrlFormatter(),
                  CometChatPhoneNumberFormatter(),
                  CometChatEmailFormatter(),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: CometChatMessageList(
                    user: widget.user,
                    group: widget.group,
                    parentMessageId: widget.message.id,
                    goToMessageId: widget.goToMessageId,
                    messagesRequestBuilder: requestBuilder,
                    withParent: false,
                    textFormatters: [
                      CometChatMentionsFormatter(
                          user: widget.user, group: widget.group),
                      MarkdownTextFormatter(),
                      CometChatUrlFormatter(),
                      CometChatPhoneNumberFormatter(),
                      CometChatEmailFormatter(),
                    ],
                    hideReplyInThreadOption: true,
                  ),
                ),
              ),
              CometChatMessageComposer(
                user: widget.user,
                group: widget.group,
                parentMessageId: widget.message.id,
                resizeToAvoidBottomInset: true,
                textFormatters: [
                  CometChatMentionsFormatter(
                      user: widget.user, group: widget.group),
                  MarkdownTextFormatter(),
                  CometChatUrlFormatter(),
                  CometChatPhoneNumberFormatter(),
                  CometChatEmailFormatter(),
                ],
                enableRichTextFormatting: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
