import 'package:cometchat_flutter_sample_app/users/users_module.dart';
import 'package:cometchat_flutter_sample_app/users_with_messages/users_with_mesages_module.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class UsersDashboard extends StatelessWidget {
  const UsersDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Users",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // WidgetCard(
              //   widgets: moduleList,
              // ),
              const UsersModule(),
              const UsersWithMessagesModule(),
              ModuleCard(
                title: "Details",
                leading: Image.asset(
                  'assets/icons/account.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    'This component can be used to view information about a user\n'
                    "To learn more about this component tap here",
                onTap: () {
                  User _user = User(
                      name: 'Kevin',
                      uid: 'UID233',
                      avatar:
                          "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
                      role: "test",
                      status: "online",
                      statusMessage: "This is now status");

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                            body: Center(
                          child: CometChatDetails(user: _user),
                        )),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
