import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class JoinProtectedGroupModule extends StatelessWidget {
  const JoinProtectedGroupModule({Key? key}) : super(key: key);

  navigateToJoinProtectedGroup(BuildContext context) {
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
            child: CometChatJoinProtectedGroup(group: _group),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Join Protected Group",
      leading: Image.asset(
        'assets/icons/shield-with-lock.png',
        height: 36,
        width: 36,
      ),
      description: 'This component is used to join a password protected group. '
          "To learn more about this component tap here",
      onTap: () => navigateToJoinProtectedGroup(context),
    );
  }
}
