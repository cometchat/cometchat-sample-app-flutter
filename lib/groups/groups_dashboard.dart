import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class GroupsDashboard extends StatelessWidget {
  const GroupsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/sidebarleft.png",
        title: "Groups With Messages",
        description:
            "CometChatGroupWithMessages is an independent component used to set up a screen that shows the list "
            "of groups available in your app and gives you the ability to search for a specific group to start the conversation "
            ". To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CometChatGroupWithMessages()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/macwindow.png",
        title: "Groups",
        description:
            "CometChatGroups is an independent component used to set up a screen that displays the list "
            "of groups available in your app and gives you the ability to search for a specific group . To learn more about this component click here",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CometChatGroups()),
          );
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/listbullet.png",
        title: "Group List",
        description:
            "CometChatGroupList component renders a scrollable list of groups in your app. To learn more about this component click here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Scaffold(body: CometChatGroupList()),
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
                      "Groups",
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
