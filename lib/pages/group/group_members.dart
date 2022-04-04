import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/Utils/custom_toast.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers(
      {Key? key, required this.groupId, this.showBannedOnly = false})
      : super(key: key);
  final String groupId;
  final bool showBannedOnly;

  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  List<GroupMember> userList = [];

  bool isLoading = true;
  bool hasMoreUsers = true;

  late GroupMembersRequest groupMembersRequest;
  late BannedGroupMembersRequest bannedGroupMembersRequest;

  Set<String> menuItems = {'Kick', 'Ban', 'Change Scope'};
  String? memberScopeType = CometChatMemberScope.participant;

  @override
  void initState() {
    super.initState();

    if (widget.showBannedOnly == false) {
      groupMembersRequest =
          (GroupMembersRequestBuilder(widget.groupId)..limit = 30).build();
    } else {
      bannedGroupMembersRequest =
          (BannedGroupMembersRequestBuilder(guid: widget.groupId)..limit = 30)
              .build();
      menuItems = {'Kick', 'Unban', 'Change Scope'};
    }

    loadMoreUsers();
  }

  //Function to load more users
  loadMoreUsers() async {
    isLoading = true;

    if (widget.showBannedOnly == false) {
      await groupMembersRequest.fetchNext(
          onSuccess: (List<GroupMember> fetchedList) {
            //-----if fetch list is empty then there no more users left----
            debugPrint(fetchedList.toString());

            if (fetchedList.isEmpty) {
              setState(() {
                isLoading = false;
                hasMoreUsers = false;
              });
            }
            //-----else more users will be fetch at end of list----
            else {
              setState(() {
                isLoading = false;
                userList.addAll(fetchedList);
              });
            }
          },
          onError: (CometChatException exception) {});
    } else {
      //----fetching only banned users----
      await bannedGroupMembersRequest.fetchNext(
          onSuccess: (List<GroupMember> fetchedList) {
            //-----if fetch list is empty then there no more users left----
            debugPrint(fetchedList.toString());

            if (fetchedList.isEmpty) {
              setState(() {
                isLoading = false;
                hasMoreUsers = false;
              });
            }
            //-----else more users will be fetch at end of list----
            else {
              setState(() {
                isLoading = false;
                userList.addAll(fetchedList);
              });
            }
          },
          onError: (CometChatException exception) {});
    }
  }

  kickUser(String uid, int index) {
    String guid = widget.groupId;
    CometChat.kickGroupMember(
        guid: guid,
        uid: uid,
        onSuccess: (String message) {
          debugPrint("Group Member Kicked  Successfully : $message");
          userList.removeAt(index);
          setState(() {});
        },
        onError: (CometChatException e) {
          debugPrint("Group Member Kicked failed  : ${e.message}");
        });
    setState(() {});
  }

  banUser(String uid, int index) {
    String guid = widget.groupId;
    CometChat.banGroupMember(
        guid: guid,
        uid: uid,
        onSuccess: (String message) {
          debugPrint("Group Member Banned  Successfully : $message");
          userList.removeAt(index);
          setState(() {});
        },
        onError: (CometChatException e) {
          debugPrint("Group Member Ban failed  : ${e.message}");
        });
  }

  unBanUser(String uid, int index) {
    String guid = widget.groupId;
    CometChat.unbanGroupMember(
        guid: guid,
        uid: uid,
        onSuccess: (String message) {
          debugPrint("Group Member Unbanned  Successfully : $message");
          userList.removeAt(index);
          setState(() {});
        },
        onError: (CometChatException e) {
          debugPrint("Group Member Unban failed  : ${e.message}");
        });
  }

  showChangeMemberScopeDialog(GroupMember user, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Group Type',
                hintText: 'Group Type',
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: memberScopeType,
                  items: [
                    CometChatMemberScope.admin,
                    CometChatMemberScope.moderator,
                    CometChatMemberScope.participant
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    memberScopeType = val;
                    print(memberScopeType);
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                changeMemberScope(memberScopeType, user, index);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  changeMemberScope(String? newScope, GroupMember user, int index) {
    String UID = user.uid;
    String GUID = widget.groupId;
    String scope = newScope ?? CometChatMemberScope.participant;

    CometChat.updateGroupMemberScope(
        guid: GUID,
        uid: UID,
        scope: scope,
        onSuccess: (String message) {
          debugPrint("Group Member Scope Changed  Successfully : $message");
          userList[index].scope = scope;
          showCustomToast(msg: "Updated");
          setState(() {});
        },
        onError: (CometChatException e) {
          debugPrint("Group Member Scope Change failed  : ${e.message}");
          showCustomToast(msg: "Something went wrong", background: Colors.red);
        });
  }

  Widget getUserListTile(User user) {
    return ListTile(
      leading: CircleAvatar(
          child: Image.network(
        user.avatar ?? '',
        errorBuilder: (context, object, trace) {
          return Text(user.name.substring(0, 1));
        },
      )),
      title: Text(user.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Group Members'),
        ),
        body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: hasMoreUsers ? userList.length + 1 : userList.length,
          itemBuilder: (context, index) {
            if (index >= userList.length && hasMoreUsers) {
              //-----if end of list then fetch more users-----
              if (!isLoading) {
                loadMoreUsers();
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final GroupMember user = userList[index];

            return Card(
              elevation: 8,
              child: SizedBox(
                  height: 72,
                  child: Center(
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Image.network(
                        user.avatar ?? '',
                        errorBuilder: (context, object, trace) {
                          return Text(user.name.substring(0, 1));
                        },
                      )),
                      title: Text(user.name),
                      subtitle: Text(user.scope ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'Kick') {
                            kickUser(user.uid, index);
                          } else if (value == 'Ban') {
                            banUser(user.uid, index);
                          } else if (value == 'Unban') {
                            unBanUser(user.uid, index);
                          } else if (value == 'Change Scope') {
                            showChangeMemberScopeDialog(user, index);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return menuItems.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  )),
            );
          },
        ));
  }
}
