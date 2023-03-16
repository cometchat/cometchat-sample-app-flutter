import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class CreateGroupModule extends StatelessWidget {
  const CreateGroupModule({Key? key}) : super(key: key);

  navigateToCreateGroup(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
              body: Center(
            child: CometChatCreateGroup(
              onCreateTap: (group) {},
            ),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Create Group",
      leading: Image.asset(
        'assets/icons/create-group-button.png',
        height: 48,
        width: 48,
      ),
      description: 'This component is used to create a new group. '
          'Groups can of three types- public, private or password protected. '
          "To learn more about this component tap here",
      onTap: () => navigateToCreateGroup(context),
    );
  }
}
