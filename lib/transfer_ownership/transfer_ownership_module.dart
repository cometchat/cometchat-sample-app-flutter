import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class TransferOwnershipModule extends StatelessWidget {
  const TransferOwnershipModule({Key? key}) : super(key: key);
  navigateToTransferOwnership(BuildContext context) {
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
            child: CometChatTransferOwnership(
              group: _group,
              onTransferOwnership: (p0, p1) {},
            ),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Transfer Ownership",
      leading: Image.asset(
        'assets/icons/transfer-ownership.png',
        height: 48,
        width: 48,
      ),
      description: 'This component is used to transfer ownership of a group '
          'from one user to another. '
          "To learn more about this component tap here",
      onTap: () => navigateToTransferOwnership(context),
    );
  }
}
