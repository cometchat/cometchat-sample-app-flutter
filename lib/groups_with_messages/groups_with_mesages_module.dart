import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class GroupsWithMessagesModule extends StatelessWidget {
  const GroupsWithMessagesModule({Key? key}) : super(key: key);

  navigateToGroupsWithMessages(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CometChatGroupsWithMessages(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Groups With Messages",
      leading: Image.asset(
        'assets/icons/chat-group.png',
        height: 48,
        width: 48,
      ),
      description:
          "CometChatGroupWithMessages is an independent component used to set up a screen that shows the list "
          "of groups available in your app and gives you the ability to search for a specific group to start the conversation "
          ". To learn more about this component tap here",
      onTap: () => navigateToGroupsWithMessages(context),
    );
  }
}
