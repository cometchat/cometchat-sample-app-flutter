import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class CometChatThread extends StatelessWidget {
  const CometChatThread(
      {this.user, this.group, required this.message, this.template, super.key});

  final User? user;
  final Group? group;
  final BaseMessage message;
  final CometChatMessageTemplate? template;

  @override
  Widget build(BuildContext context) {
    final ccColor = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return Scaffold(
      backgroundColor: ccColor.background1,
      resizeToAvoidBottomInset: true, // Ensures layout adjusts for the keyboard
      appBar: CometChatMessageHeader(
        user: user,
        group: group,
        padding: EdgeInsets.symmetric(
          vertical: spacing.padding2 ?? 0,
          horizontal: spacing.padding4 ?? 0,
        ),
        listItemView: (group, user, context) {
          final name = group != null ? group.name : user?.name ?? "";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.of(context).thread,
                style: TextStyle(
                  color: ccColor.textPrimary,
                  fontSize: typography.heading2?.bold?.fontSize,
                  fontFamily: typography.heading2?.bold?.fontFamily,
                  fontWeight: typography.heading2?.bold?.fontWeight,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ccColor.textSecondary,
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                ),
              ),
            ],
          );
        },
        messageHeaderStyle: CometChatMessageHeaderStyle(
          backIconColor: ccColor.iconPrimary,
          backgroundColor: ccColor.background1,
          border: Border(
            top: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide(
              width: 1.0,
              color: ccColor.borderLight ?? Colors.transparent,
              style: BorderStyle.solid,
            ),
            left: BorderSide(
              width: 1.0,
              color: ccColor.borderLight ?? Colors.transparent,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final totalHeight = constraints.maxHeight;

          final composerHeight = 60.0;
          final initialHeaderHeight = totalHeight * 0.3;

          // Adjust the height if keyboard is open
          final availableHeaderHeight = keyboardHeight > 0
              ? totalHeight - composerHeight - keyboardHeight - 16
              : initialHeaderHeight;

          return Container(
            color: ccColor.background3,
            child: Column(
              children: [
                SizedBox(
                  height: availableHeaderHeight,
                  child: CometChatThreadedHeader(
                    height: availableHeaderHeight,
                    parentMessage: message,
                    loggedInUser: CometChatUIKit.loggedInUser!,
                    template: template,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: getMessageList(user, group, context, message),
                  ),
                ),
                CometChatMessageComposer(
                    user: user,
                    group: group,
                    parentMessageId: message.id,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getMessageList(
      User? user, Group? group, context, BaseMessage parentMessage) {
    MessagesRequestBuilder? requestBuilder = MessagesRequestBuilder();

    requestBuilder = MessagesRequestBuilder()
      ..parentMessageId = parentMessage.id;

    return CometChatMessageList(
      user: user,
      group: group,
      messagesRequestBuilder: requestBuilder,
    );
  }
}
