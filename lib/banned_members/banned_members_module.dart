import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class BannedMembersModule extends StatelessWidget {
  const BannedMembersModule({Key? key}) : super(key: key);

  navigateToBannedMembers(BuildContext context) {
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
            child: CometChatBannedMembers(group: _group),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      leading: Image.asset(
        'assets/icons/ban-user.png',
        height: 48,
        width: 48,
      ),
      title: "Banned members",
      description: 'This component is used to add users to a group. '
          "To learn more about this component tap here",
      onTap: () => navigateToBannedMembers(context),
    );
  }
}
