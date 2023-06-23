import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getCometChatListItemContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/menu.png",
    title: "List Item",
    description: "CometChatListItem displays data on a tile "
        "and that tile may contain leading, trailing, title and subtitle widgets. "
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CometChatListItemDashboard(),
          ));
    },
  );
}

class CometChatListItemDashboard extends StatelessWidget {
  const CometChatListItemDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/icons/user.png",
        leadingImageDimensions: 36,
        title: "User",
        description: "CometChatListItem is being used to "
            "display the using the data obtained from a User object "
            "To learn more about this component tap here",
        onTap: () {
          User _user = User(
              name: 'Kevin',
              uid: 'UID233',
              avatar:
                  "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
              role: "test",
              status: "online",
              statusMessage: "This is now status");

          StatusIndicatorUtils statusIndicatorUtils =
              StatusIndicatorUtils.getStatusIndicatorFromParams(
            theme: cometChatTheme,
            user: _user,
          );
          Color? backgroundColor = statusIndicatorUtils.statusIndicatorColor;
          Widget? icon = statusIndicatorUtils.icon;

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0.5,
                    ),
                    body: Center(
                      child: CometChatListItem(
                        avatarName: _user.name,
                        avatarURL: _user.avatar,
                        title: _user.name,
                        statusIndicatorColor: backgroundColor,
                        statusIndicatorIcon: icon,
                      ),
                    )),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/icons/group.png",
        title: "Groups",
        description: "CometChatListItem is being used to "
            "display the using the data obtained from a Group object "
            "To learn more about this component tap here",
        onTap: () {
          Group _group = Group(
              guid: "supergroup",
              owner: "superhero1",
              name: "Comic Hero's Hangout",
              icon:
                  "https://data-us.cometchat.io/assets/images/avatars/supergroup.png",
              description: "null",
              hasJoined: true,
              membersCount: 4,
              createdAt: DateTime.now(),
              joinedAt: DateTime.now(),
              updatedAt: DateTime.now(),
              type: "private");
          StatusIndicatorUtils statusIndicatorUtils =
              StatusIndicatorUtils.getStatusIndicatorFromParams(
            theme: cometChatTheme,
            group: _group,
          );
          Color? backgroundColor = statusIndicatorUtils.statusIndicatorColor;
          Widget? icon = statusIndicatorUtils.icon;

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0.5,
                    ),
                    body: Center(
                      child: CometChatListItem(
                        avatarName: _group.name,
                        avatarURL: _group.icon,
                        title: _group.name,
                        subtitleView: Text(
                          "${_group.membersCount} ${Translations.of(context).members}",
                          style: TextStyle(
                              fontSize:
                                  cometChatTheme.typography.subtitle1.fontSize,
                              fontWeight: cometChatTheme
                                  .typography.subtitle1.fontWeight,
                              fontFamily: cometChatTheme
                                  .typography.subtitle1.fontFamily,
                              color: cometChatTheme.palette.getAccent600()),
                        ),
                        statusIndicatorColor: backgroundColor,
                        statusIndicatorIcon: icon,
                        options: [
                          CometChatOption(
                              id: "dummy",
                              icon: AssetConstants.delete,
                              backgroundColor: Colors.red)
                        ],
                      ),
                    )),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/icons/chat.png",
        title: "Conversations",
        description: "CometChatListItem is being used to "
            "display the using the data obtained from a Conversation object "
            "To learn more about this component tap here",
        onTap: () {
          User _conversationWith = User(
              name: 'Kevin',
              uid: 'UID233',
              avatar:
                  "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
              role: "test",
              status: "online",
              statusMessage: "This is now status");

          TextMessage _lastMessage = TextMessage(
              receiverType: CometChatReceiverType.user,
              receiverUid: "superhero1",
              type: MessageTypeConstants.text,
              text: "HI HOW ARE YOU?",
              conversationId: "conver_Id",
              id: 2344,
              muid: "UniqueIdentifier",
              sentAt: DateTime.now());

          Conversation _conversation = Conversation(
              conversationWith: _conversationWith,
              conversationType: "user",
              conversationId: "conver_Id",
              lastMessage: _lastMessage,
              unreadMessageCount: 2);

          StatusIndicatorUtils statusIndicatorUtils =
              StatusIndicatorUtils.getStatusIndicatorFromParams(
            theme: cometChatTheme,
            user: _conversationWith,
          );
          Color? backgroundColor = statusIndicatorUtils.statusIndicatorColor;
          Widget? icon = statusIndicatorUtils.icon;

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0.5,
                    ),
                    backgroundColor: const Color(0xffeeeeee),
                    body: Center(
                      child: CometChatListItem(
                        avatarName:
                            (_conversation.conversationWith as User).name,
                        avatarURL:
                            (_conversation.conversationWith as User).avatar,
                        title: (_conversation.conversationWith as User).name,
                        subtitleView: Text(
                          (_conversation.lastMessage as TextMessage).text,
                          style: TextStyle(
                              fontSize:
                                  cometChatTheme.typography.subtitle1.fontSize,
                              fontWeight: cometChatTheme
                                  .typography.subtitle1.fontWeight,
                              fontFamily: cometChatTheme
                                  .typography.subtitle1.fontFamily,
                              color: cometChatTheme.palette.getAccent600()),
                        ),
                        statusIndicatorColor: backgroundColor,
                        statusIndicatorIcon: icon,
                        tailView: Column(
                          children: [
                            CometChatDate(
                              date: _conversation.lastMessage?.sentAt,
                              pattern: DateTimePattern.dayDateTimeFormat,
                            ),
                            CometChatBadge(
                                count: _conversation.unreadMessageCount ?? 0,
                                style: BadgeStyle(
                                  width: 25,
                                  height: 25,
                                  borderRadius: 100,
                                  textStyle: TextStyle(
                                      fontSize: cometChatTheme
                                          .typography.subtitle1.fontSize,
                                      color:
                                          cometChatTheme.palette.getAccent()),
                                  background:
                                      cometChatTheme.palette.getPrimary(),
                                ))
                          ],
                        ),
                        options: [
                          CometChatOption(
                              id: "dummy",
                              icon: AssetConstants.delete,
                              backgroundColor: Colors.red)
                        ],
                      ),
                    )),
              ));
        },
      )
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "CometChatListItem",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              WidgetCard(
                widgets: moduleList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
