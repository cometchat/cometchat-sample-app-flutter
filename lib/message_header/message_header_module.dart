import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class MessageHeaderModule extends StatelessWidget {
  const MessageHeaderModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/macwindow.png',
        height: 48,
        width: 48,
      ),
      title: "Message Header",
      description:
          "CometChatMessageHeader is an independent component that displays the User or Group information using SDK's User or Group object "
          ". To learn more about this component tap here",
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
                      child: CometChatMessageHeader(
                group: _group,
              ))),
            ));
      },
    );
  }
}
