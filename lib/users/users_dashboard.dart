import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class UsersDashboard extends StatelessWidget {
  const UsersDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/sidebarleft.png",
        title: "Users With Messages",
        description:
            "CometChatUsersWithMessages is an independent component used to set up a screen that shows the list of users availbale in your app"
            "and gives you the ability to search Users . To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CometChatUsersWithMessages()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/macwindow.png",
        title: "Users",
        description:
            "CometChatUsers is an independent component used to set up a screen that displays a scrollable list of users available in your app and gives you ability to search for a user. To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CometChatUsers()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/listbullet.png",
        title: "Users List",
        description:
            "CometChatUserList component renders a scrollable list of users in your app . To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Scaffold(body: CometChatUserList()),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/personrectangle.png",
        title: "Data Item",
        description:
            "CometChatDataItem is a reusable component which is used across multiple components in different variations such as User List "
            ", Group List as a list Item",
        onTap: () {
          InputData<Group> _data = InputData<Group>(
              title: true,
              thumbnail: true,
              status: true,
              subtitle: (Group grp) {
                return grp.guid;
              });

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
                  child: CometChatDataItem(
                    inputData: _data,
                    group: _group,
                  ),
                )),
              ));
        },
      )
    ];

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
              WidgetCard(
                widgets: moduleList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
