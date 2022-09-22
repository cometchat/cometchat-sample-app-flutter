import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class DataItemContainer extends StatelessWidget {
  const DataItemContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Data Item",
        description:
            "CometChatDataItem is a reusable component which is used across multiple components in different variations such as User List "
            ", Group List as a list Item .",
        child: DataItemView());
  }
}

class DataItemView extends StatefulWidget {
  const DataItemView({Key? key}) : super(key: key);

  @override
  _DataItemViewState createState() => _DataItemViewState();
}

class _DataItemViewState extends State<DataItemView> {
  String localeName = "en";
  final InputData<Group> _groupInputData = InputData<Group>(
      title: true,
      status: true,
      thumbnail: true,
      subtitle: (Group grp) {
        return "${grp.membersCount} members";
      });
  final InputData<User> _userInputData = const InputData<User>(
    title: true,
    status: true,
    thumbnail: true,
  );

  final Group _group = Group(
      guid: "supergroup",
      owner: "superhero1",
      name: "Comic Heros' Hangout",
      icon: "https://data-us.cometchat.io/assets/images/avatars/supergroup.png",
      description: "null",
      hasJoined: true,
      membersCount: 4,
      createdAt: DateTime.now(),
      joinedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: "private");

  final User _user = User(
      uid: 'superhero2',
      name: 'Captain America',
      avatar:
          'https://data-us.cometchat.io/assets/images/avatars/captainamerica.png',
      status: 'online');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Group",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          CometChatDataItem(
            inputData: _groupInputData,
            group: _group,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "User",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          CometChatDataItem(
            inputData: _userInputData,
            user: _user,
          ),
        ],
      ),
    );
  }
}
