import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class MessageListModule extends StatelessWidget {
  const MessageListModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/message-list.png',
        height: 48,
        width: 48,
      ),
      title: "Message List",
      description:
          "CometChatMessageList is an independent and a critical component that"
          " lists various types of messages such as text, image , video and custom messages in appropriate message bubbles. "
          "To learn more about this component tap here",
      onTap: () {
        Group _group = Group(
            name: "Avengers",
            hasJoined: true,
            membersCount: 8,
            guid: "supergroup",
            type: GroupTypeConstants.public);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                  body: Center(
                      child: SizedBox(
                          height: 400,
                          child: CometChatMessageList(
                            group: _group,
                          )))),
            ));
      },
    );
  }
}
