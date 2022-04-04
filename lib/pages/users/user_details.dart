import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';

import '../../Utils/custom_toast.dart';
import '../../Utils/loading_indicator.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  int unreadCount = 0;
  int? lastDeliveredMessageId;

  @override
  void initState() {
    getUnreadMessageCount();
    getLastMessageId();
  }

  //-----Blocking user-----
  blockUser() async {
    showLoadingIndicatorDialog(context);
    List<String> uids = [];
    uids.add(widget.user.uid);
    await CometChat.blockUser(uids, onSuccess: (Map<String, dynamic> map) {
      debugPrint("Blocked User Successfully $map ");
      widget.user.blockedByMe = true;
      showCustomToast(msg: 'Blocked');
      setState(() {});
    }, onError: (CometChatException e) {
      debugPrint("Blocked User Unsuccessful ${e.message} ");
      showCustomToast(msg: 'Something went wrong', background: Colors.red);
    });

    Navigator.pop(context);
  }

  //-----Unblocking user-----
  unblockUser() async {
    showLoadingIndicatorDialog(context);
    List<String> uids = [];
    uids.add(widget.user.uid);

    await CometChat.unblockUser(uids, onSuccess: (Map<String, dynamic> map) {
      debugPrint("Unblocked User Successfully $map ");
      widget.user.blockedByMe = false;
      showCustomToast(msg: 'Unblocked');
      setState(() {});
    }, onError: (CometChatException e) {
      debugPrint("Unblocked User Unsuccessful ${e.message} ");
    });
    Navigator.pop(context);
  }

  getUnreadMessageCount() async {
    CometChat.getUnreadMessageCount(
        hideMessagesFromBlockedUsers: true,
        onSuccess: (Map<String, Map<String, int>> map) {
          Map<String, int>? groupCounts = map['user'];
          if (groupCounts != null) {
            unreadCount = groupCounts[widget.user.uid] ?? 0;
            setState(() {});
          }
          debugPrint(map.toString());
        },
        onError: (e) {
          debugPrint(e.toString());
        });
  }

  getLastMessageId() async {
    lastDeliveredMessageId = await CometChat.getLastDeliveredMessageId();
    debugPrint("$lastDeliveredMessageId");
    setState(() {});
  }

  tagConversation() {
    String uid = widget.user.uid;
    String conversationType = ConversationType.user;
    List<String> tags = [];
    tags.add("archived");

    CometChat.tagConversation(uid, conversationType, tags,
        onSuccess: (Conversation conversation) {
      debugPrint("Conversation tagged Successfully : $conversation");
    }, onError: (CometChatException e) {
      debugPrint("Conversation tagging failed  : ${e.message}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: SizedBox(
                  height: 72,
                  child: Center(
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Stack(
                        children: [
                          CircleAvatar(
                              child: widget.user.avatar != null &&
                                      widget.user.avatar!.isNotEmpty
                                  ? Image.network(widget.user.avatar!)
                                  : Text(widget.user.name.substring(0, 1))),
                          if (widget.user.status != null)
                            Positioned(
                              height: 12,
                              width: 12,
                              right: 1,
                              bottom: 1,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                    color: widget.user.status ==
                                            CometChatUserStatus.online
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                        ],
                      )),
                      title: Text(widget.user.name),
                      subtitle: Text("UID: ${widget.user.uid}"),
                    ),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    title: const Text(
                      "Last Active at",
                      style: TextStyle(color: Colors.blue),
                    ),
                    trailing: Text(widget.user.lastActiveAt!=null?receiptFormatter.format(widget.user.lastActiveAt!): ""),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    title: const Text("Unread Message Count"),
                    trailing: Text("$unreadCount"),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    trailing: Text('$lastDeliveredMessageId'),
                    title: const Text("Last Delivered MessageId"),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: tagConversation,
                    title: const Text("Tag Conversation"),
                  )),
            ),
            Card(
              child: SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () {
                      if (widget.user.blockedByMe ?? false) {
                        unblockUser();
                      } else {
                        blockUser();
                      }
                    },
                    title: widget.user.blockedByMe ?? false
                        ? const Text(
                            "Unblock",
                            style: TextStyle(color: Colors.blue),
                          )
                        : const Text(
                            "Block",
                            style: TextStyle(color: Colors.red),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
