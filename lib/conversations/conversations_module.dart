import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class ConversationModule extends StatelessWidget {
  const ConversationModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ModuleCard(
      leading: Image.asset(
        'assets/icons/conversations.png',
        height: 48,
        width: 48,
      ),
      title: "Conversations",
      description:
          "Conversations module helps you to view list of conversations that the logged in user is part of. To learn more about this component, tap here.",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CometChatConversations()),
        );
      },
    );
  }
}
