import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class ConversationDashboard extends StatelessWidget {
  const ConversationDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/sidebarleft.png",
        title: "Conversations With Messages",
        description:
            "Conversation Module helps you list the recent conversations between your users and groups. To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const CometChatConversationsWithMessages()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/macwindow.png",
        title: "Conversations",
        description:
            "Messages module helps you to send and receive in a conversation between a user and a group . To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CometChatConversations()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/listbullet.png",
        title: "Conversation List",
        description:
            "Users Module helps you list all the users available in your app . To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                    backgroundColor: Color(0xffeeeeee),
                    body: CometChatConversationList()),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/personrectangle.png",
        title: "Conversation List Item",
        description: "CometChatConversationListItem is a reusable component "
            "which is used to display the conversation list item in conversation list. "
            "To learn more about this component click here",
        onTap: () {
          User _sender = User(
              name: 'Kevin',
              uid: 'UID233',
              avatar:
                  "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
              role: "test",
              status: "online",
              statusMessage: "This is now status");

          TextMessage _message = TextMessage(
              receiverType: CometChatReceiverType.user,
              receiverUid: "superhero1",
              type: MessageTypeConstants.text,
              text: "HI HOW ARE YOU?",
              conversationId: "conver_Id",
              id: 2344,
              muid: "UniqueIdentifier");

          Conversation _conversation = Conversation(
              conversationWith: _sender,
              conversationType: "user",
              conversationId: "conver_Id",
              lastMessage: _message,
              unreadMessageCount: 2);

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    backgroundColor: const Color(0xffeeeeee),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CometChatConversationListItem(
                            showTypingIndicator: false,
                            onTap: () {},
                            conversation: _conversation),
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
                      "Conversations",
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
