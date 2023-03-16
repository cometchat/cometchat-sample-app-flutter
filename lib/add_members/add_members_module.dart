import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class AddMembersModule extends StatelessWidget {
  const AddMembersModule({Key? key}) : super(key: key);

  navigateToAddMembers(BuildContext context) {
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
            child: CometChatAddMembers(group: _group),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/user-plus.png',
        height: 48,
        width: 48,
      ),
      title: "Add members",
      description: 'This component is used to add users to a group. '
          "To learn more about this component tap here",
      onTap: () => navigateToAddMembers(context),
    );
  }
}
