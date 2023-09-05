import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';

class ContactsModule extends StatelessWidget {
  const ContactsModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ModuleCard(
      leading: Image.asset(
        'assets/icons/contacts.png',
        height: 48,
        width: 48,
      ),
      title: "Contacts",
      description:
      "CometChatContacts is a versatile UI component specifically designed to facilitate the display and management of users and groups within chat applications. It streamlines the process of showcasing all app users and available chat groups in a user-friendly interface, making it easier for users to connect and communicate effectively.",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CometChatContacts(),
          ),
        );
      },
    );
  }
}
