import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/Utils/custom_toast.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';
import 'package:sdk_tutorial/pages/group/group_members.dart';
import 'package:sdk_tutorial/pages/group/update_group.dart';
import 'package:sdk_tutorial/pages/users/user_list.dart';

import '../../Utils/loading_indicator.dart';

class GroupFunctions extends StatefulWidget {
  const GroupFunctions(
      {Key? key, required this.groupId, required this.loggedInUserId})
      : super(key: key);
  final String groupId;
  final String loggedInUserId;

  @override
  _GroupFunctionsState createState() => _GroupFunctionsState();
}

class _GroupFunctionsState extends State<GroupFunctions> {
  late Group group;
  bool isLoading = true;
  bool isGroupOwner = false;
  String groupPassword = "";
  String addMemberUid = "";
  int onlineMemberCount = 0;
  int unreadCount = 0;
  int? lastDeliveredMessageId;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
    getOnlineGroupMemberCount();
    getUnreadMessageCount();
    getLastMessageId();
  }

  getGroupDetails() async {
    await CometChat.getGroup(widget.groupId, onSuccess: (Group fetchGroup) {
      debugPrint("Fetched Group Successfully : $fetchGroup ");
      group = fetchGroup;
    }, onError: (CometChatException e) {
      debugPrint("Group Request failed with exception: ${e.message}");
      return;
    });

    isGroupOwner = group.owner == widget.loggedInUserId;
    isLoading = false;
    setState(() {});
  }

  leaveGroup() async {
    showLoadingIndicatorDialog(context);

    await CometChat.leaveGroup(widget.groupId, onSuccess: (String message) {
      debugPrint("Group Left  Successfully : $message");
      showCustomToast(msg: "Group Left");
    }, onError: (CometChatException e) {
      debugPrint("Group Left failed  : ${e.message}");
    });
    Navigator.pop(context);
  }

  joinGroup() async {
    await CometChat.joinGroup(group.guid, group.type, password: groupPassword,
        onSuccess: (Group group) {
      debugPrint("Group Joined Successfully : $group ");
    }, onError: (CometChatException e) {
      debugPrint("Group Joining failed with exception: ${e.message}");
    });
    setState(() {});
  }

  deleteGroup() async {
    showLoadingIndicatorDialog(context);
    await CometChat.deleteGroup(widget.groupId, onSuccess: (String message) {
      debugPrint("Deleted Group Successfully : $message ");
      showCustomToast(msg: "Group Deleted");
    }, onError: (CometChatException e) {
      showCustomToast(msg: 'Something Went Wrong');
      debugPrint("Delete Group failed with exception: ${e.message}");
    });
    Navigator.pop(context);
  }

  transferOwnerShipOfGroup() async {
    String uid = "superhero1"; //new group owner uid

    await CometChat.transferGroupOwnership(
        guid: widget.groupId,
        uid: uid,
        onSuccess: (String message) {
          debugPrint("Owner Transferred  Successfully : $message");
        },
        onError: (CometChatException e) {
          debugPrint("Owner Transferred failed  : ${e.message}");
        });
  }

  addMembers(List<User> members) {
    //-----List of members to be added-----
    List<GroupMember> newGroupMembers = [];

    for (User user in members) {
      GroupMember newMember = GroupMember.fromUid(
          scope: CometChatMemberScope.participant,
          uid: user.uid,
          name: user.name);
      newGroupMembers.add(newMember);
    }

    CometChat.addMembersToGroup(
        guid: group.guid,
        groupMembers: newGroupMembers,
        onSuccess: (Map<String?, String?> result) {
          debugPrint("Group Member added Successfully : $result");
        },
        onError: (CometChatException e) {
          debugPrint(
              "Group Member addition failed with exception: ${e.message}");
        });
  }

  getOnlineGroupMemberCount() {
    String groupId = widget.groupId;
    CometChat.getOnlineGroupMemberCount([groupId],
        onSuccess: (Map<String, int> count) {
      onlineMemberCount = count[groupId] ?? 0;
      setState(() {});
      debugPrint("Fetched Online Group Member Count Successfully : $count ");
    }, onError: (CometChatException e) {
      debugPrint("Online Group Member  failed with exception: ${e.message}");
    });
  }

  getUnreadMessageCount() async {
    CometChat.getUnreadMessageCount(
        hideMessagesFromBlockedUsers: true,
        onSuccess: (Map<String, Map<String, int>> map) {
          Map<String, int>? groupCounts = map['group'];
          if (groupCounts != null) {
            unreadCount = groupCounts[widget.groupId] ?? 0;
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
    String guid = widget.groupId;
    String conversationType = ConversationType.group;
    List<String> tags = [];
    tags.add("archived");

    CometChat.tagConversation(guid, conversationType, tags,
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
        title: const Text("Group Details"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Card(
                      child: SizedBox(
                          height: 72,
                          child: Center(
                            child: ListTile(
                              leading: CircleAvatar(
                                  child: group.icon.isNotEmpty
                                      ? Image.network(
                                          group.icon,
                                          errorBuilder:
                                              (context, object, trace) {
                                            return Text(
                                                group.name.substring(0, 1));
                                          },
                                        )
                                      : Text(group.name.substring(0, 1))),
                              title: Text(group.name),
                              subtitle: Text(
                                  "Members :${group.membersCount}  Type: ${group.type}"),
                            ),
                          )),
                    ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupMembers(
                                            groupId: group.guid,
                                          )));
                            },
                            title: const Text("View Members"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          )),
                    ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupMembers(
                                            groupId: group.guid,
                                            showBannedOnly: true,
                                          )));
                            },
                            title: const Text("View Banned Members"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          )),
                    ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: () async {
                                List<User> addMemberList = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CometChatUserList(
                                              navigateFrom:
                                                  NavigateFrom.addMembers,
                                            )));
                                addMembers(addMemberList);
                              },
                              title: const Text("Add Members"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            )),
                      ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            trailing: Text('$onlineMemberCount'),
                            title: const Text("Online Member Count"),
                          )),
                    ),
                    Card(
                      child: SizedBox(
                          height: 50,
                          child: ListTile(
                            trailing: Text('$unreadCount'),
                            title: const Text("Unread Message Count"),
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
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UpdateGroup(
                                              group: group,
                                            )));
                              },
                              title: const Text("Update This Group"),
                            )),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: transferOwnerShipOfGroup,
                              title: const Text(
                                "Transfer Ownership",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                    if (group.hasJoined)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: leaveGroup,
                              title: const Text(
                                "Leave This Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                    if (group.owner == widget.loggedInUserId)
                      Card(
                        child: SizedBox(
                            height: 50,
                            child: ListTile(
                              onTap: deleteGroup,
                              title: const Text(
                                "Delete This Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
