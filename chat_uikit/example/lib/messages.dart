import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class MessagesSample extends StatelessWidget {
  User? user;
  Group? group;
  Color? color;
  MessagesSample({Key? key, this.user, this.group, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: color,
        appBar: CometChatMessageHeader(
          user: user,
          group: group,
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  child: CometChatMessageList(
                    user: user,
                    group: group,
                    onThreadRepliesClick: (message, context, {template}) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SafeArea(
                            child: Scaffold(
                              backgroundColor: color,
                              resizeToAvoidBottomInset: true,
                              appBar: CometChatMessageHeader(
                                user: user,
                                group: group,
                                padding: EdgeInsets.symmetric(
                                  vertical: spacing.padding2 ?? 0,
                                  horizontal: spacing.padding4 ?? 0,
                                ),
                                listItemView: (group, user, context) {
                                  final name = group != null
                                      ? group.name
                                      : user?.name ?? "";
                                  return Column(
                                    children: [
                                      Text(
                                        Translations.of(context).thread,
                                        style: TextStyle(
                                          color: colorPalette.textPrimary,
                                          fontSize: typography
                                              .heading2?.bold?.fontSize,
                                          fontFamily: typography
                                              .heading2?.bold?.fontFamily,
                                          fontWeight: typography
                                              .heading2?.bold?.fontWeight,
                                        ),
                                      ),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: colorPalette.textSecondary,
                                          fontSize: typography
                                              .caption1?.regular?.fontSize,
                                          fontFamily: typography
                                              .caption1?.regular?.fontFamily,
                                          fontWeight: typography
                                              .caption1?.regular?.fontWeight,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                messageHeaderStyle: CometChatMessageHeaderStyle(
                                  backIconColor: colorPalette.iconPrimary,
                                  backgroundColor: colorPalette.background1,
                                  border: Border(
                                    top: BorderSide.none,
                                    right: BorderSide.none,
                                    bottom: BorderSide(
                                      width: 1.0,
                                      color: colorPalette.borderLight ??
                                          Colors.transparent,
                                      style: BorderStyle.solid,
                                    ),
                                    left: BorderSide(
                                      width: 1.0,
                                      color: colorPalette.borderLight ??
                                          Colors.transparent,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                              body: Column(
                                children: [
                                  CometChatThreadedHeader(
                                    parentMessage: message,
                                    loggedInUser: CometChatUIKit.loggedInUser!,
                                  ),
                                  Expanded(
                                    child: getMessageList(
                                      user,
                                      group,
                                      context,
                                      message,
                                    ),
                                  ),
                                  CometChatMessageComposer(
                                    user: user,
                                    group: group,
                                    parentMessageId: message.id,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CometChatMessageComposer(
                  user: user,
                  group: group,
                  // attachmentOptionSheetStyle: CometChatAttachmentOptionSheetStyle(
                  //   iconColor: Colors.yellow,
                  //   // titleTextStyle: TextStyle(
                  //   //   color: Colors.yellow,
                  //   //   fontSize: 16,
                  //   //   fontWeight: FontWeight.bold,
                  //   // ),
                  //   backgroundColor: Colors.red,
                  //   titleColor: Colors.blue,
                  //   // borderRadius: BorderRadius.circular(200),
                  //   border: Border.all(
                  //     color: Colors.blue,
                  //     width: 5,
                  //   ),
                  // ),
                  // mentionsStyle: CometChatMentionsStyle(
                  //   mentionSelfTextBackgroundColor: Colors.blue,
                  //   mentionSelfTextColor: Colors.white,
                  //   mentionTextColor: Colors.yellow,
                  //   mentionTextBackgroundColor: Colors.red,
                  // )
                ),
              ],
            ),
          ),
        ),
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
