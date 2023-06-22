import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class MessageComposerModule extends StatelessWidget {
  const MessageComposerModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/compose.png',
        height: 36,
        width: 36,
      ),
      title: "Message Composer",
      description:
          "CometChatMessageComposer is an independent and a critical component that"
          " allows users to compose and send various types of messages such as text, image , video and custom messages . "
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
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0.5,
                  ),
                  body: Center(
                      child: SizedBox(
                          height: 400,
                          child: CometChatMessageComposer(
                            group: _group,
                            onSendButtonClick: () {},
                          )))),
            ));
      },
    );
  }
}
