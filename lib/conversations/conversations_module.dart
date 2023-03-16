import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

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
          "Messages module helps you to send and receive in a conversation between a user and a group . To learn more about this component tap here",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CometChatConversations()),
        );
      },
    );
  }
}
