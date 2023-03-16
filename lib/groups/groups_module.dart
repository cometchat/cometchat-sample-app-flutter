import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class GroupsModule extends StatelessWidget {
  const GroupsModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/group-chat.png',
        height: 48,
        width: 48,
      ),
      title: "Groups",
      description:
          "CometChatGroups is an independent component used to set up a screen that displays the list "
          "of groups available in your app and gives you the ability to search for a specific group . To learn more about this component tap here",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CometChatGroups()),
        );
      },
    );
  }
}
