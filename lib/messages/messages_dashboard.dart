import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class MessagesModule extends StatelessWidget {
  const MessagesModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/message.png',
        height: 48,
        width: 48,
      ),
      title: "Messages",
      description:
          "CometChatMessages component helps you send, receive, view messages in a conversation with a user or in a group. To learn more about this component tap here",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CometChatMessages(
                    group: Group(
                        guid: "supergroup",
                        membersCount: 6,
                        name: "Avengers",
                        hasJoined: true,
                        type: GroupTypeConstants.public),
                  )),
        );
      },
    );
  }
}
