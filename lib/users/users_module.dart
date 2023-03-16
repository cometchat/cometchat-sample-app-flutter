import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class UsersModule extends StatelessWidget {
  const UsersModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Users",
      leading: Image.asset(
        'assets/icons/user-solid.png',
        height: 40,
        width: 40,
      ),
      description:
          "CometChatUsers is an independent component used to set up a screen that displays a scrollable list of users available in your app and gives you ability to search for a user. To learn more about this component tap here",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CometChatUsers()),
        );
      },
    );
  }
}
