import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class GroupMembersModule extends StatelessWidget {
  const GroupMembersModule({Key? key}) : super(key: key);

  navigateToGroupMembers(BuildContext context) {
    Group _group = Group(
        guid: "supergroup",
        owner: "superhero1",
        name: "Comic Hero's Hangout",
        icon:
            "https://data-us.cometchat.io/assets/images/avatars/supergroup.png",
        description: "null",
        hasJoined: true,
        membersCount: 4,
        createdAt: DateTime.now(),
        joinedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: "private");

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
              body: Center(
            child: CometChatGroupMembers(group: _group),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Group Members",
      leading: Image.asset(
        'assets/icons/group-chat.png',
        height: 48,
        width: 48,
      ),
      description: 'This component is used to view a members in a group. '
          "To learn more about this component tap here",
      onTap: () => navigateToGroupMembers(context),
    );
  }
}
