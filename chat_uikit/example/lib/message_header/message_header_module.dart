import 'package:master_app/utils/module_card.dart';
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
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                  body: Center(
                      child: CometChatMessageHeader(
                // group: _group,
                user: User(
                    uid: "superhero2",
                    name: "Captain America",
                    avatar: "https://data-us.cometchat.io/assets/images/avatars/ironman.png",
                    status: "online"),
              ))),
            ));
      },
    );
  }
}
