import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class UsersWithMessagesModule extends StatelessWidget {
  const UsersWithMessagesModule({Key? key}) : super(key: key);

  navigateToUsersWithMessages(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CometChatUsersWithMessages(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Users With Messages",
      leading: Image.asset(
        'assets/icons/users-chat.png',
        height: 48,
        width: 48,
      ),
      description:
          "CometChatUsersWithMessages is an independent component used to set up a screen that shows the list of users availbale in your app"
          "and gives you the ability to search Users . To learn more about this component tap here",
      onTap: () => navigateToUsersWithMessages(context),
    );
  }
}
