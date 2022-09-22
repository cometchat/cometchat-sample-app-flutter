import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class MessagesDashboard extends StatelessWidget {
  const MessagesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/sidebarleft.png",
        title: "Messages",
        description:
            "Message module helps you send and receive in a conversation between a user or group. To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CometChatMessages(
                      group: "supergroup",
                    )),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/macwindow.png",
        title: "Message Header",
        description:
            "CometChatMessageHeader is an independent component that displays the User or Group information using SDK's User or Group object "
            ". To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                    body: Center(
                        child: CometChatMessageHeader(
                  group: "supergroup",
                ))),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/listbullet.png",
        title: "Messsage List",
        description:
            "Users Module helps you list all the users available in your app . To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                    body: CometChatMessageList(
                  group: "supergroup",
                )),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/personrectangle.png",
        title: "Message Composer",
        description:
            "CometChatMessageComposer is an independent and a critical component that"
            " allows users to compose and send various types of messages such as text, image , video and custom messages . "
            "To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                    body: Center(
                        child: SizedBox(
                            height: 400,
                            child: CometChatMessageComposer(
                              group: "supergroup",
                            )))),
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
                      "Messages",
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
