import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/group/create_group.dart';
import '../messages/message_list.dart';

class CometChatGroupList extends StatefulWidget {
  const CometChatGroupList({Key? key}) : super(key: key);

  @override
  _CometChatGroupListState createState() => _CometChatGroupListState();
}

class _CometChatGroupListState extends State<CometChatGroupList> {
  List<Group> groupList = [];

  bool isLoading = true;
  bool hasMoreGroups = true;
  late GroupsRequest groupsRequest;
  String groupPassword = "";

  @override
  void initState() {
    super.initState();
    requestBuilder();
  }

  requestBuilder() {
    groupsRequest = (GroupsRequestBuilder()..limit = 30
        // ..searchKeyword = "abc"
        // ..joinedOnly = true
        // ..tags = []
        // ..withTags = true
        )
        .build();

    loadMoreGroups();
  }

  //Function to load more groups
  loadMoreGroups() async {
    isLoading = true;

    groupsRequest.fetchNext(
        onSuccess: (List<Group> fetchedList) {
          //-----if fetch list is empty then there no more users left----
          print(fetchedList);

          if (fetchedList.isEmpty) {
            setState(() {
              isLoading = false;
              hasMoreGroups = false;
            });
          }
          //-----else more users will be fetch at end of list----
          else {
            setState(() {
              isLoading = false;
              groupList.addAll(fetchedList);
            });
          }
          print(hasMoreGroups);
        },
        onError: (CometChatException exception) {});
  }

  joinGroup(Group group) async {
    await CometChat.joinGroup(group.guid, group.type, password: groupPassword,
        onSuccess: (Group group) {
      debugPrint("Group Joined Successfully : $group ");
      CometChat.getConversation(group.guid, CometChatConversationType.group,
          onSuccess: (Conversation conversation) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageList(
                      conversation: conversation,
                    )));
      }, onError: (CometChatException e) {});
    }, onError: (CometChatException e) {
      debugPrint("Group Joining failed with exception: ${e.message}");
    });
    setState(() {});
  }

  showJoinGroupDialog(Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Join This Group",
            textAlign: TextAlign.center,
          ),
          content: group.type == CometChatGroupType.password
              ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    onChanged: (val) {
                      groupPassword = val;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Group Password',
                    ),
                  ))
              : const SizedBox(
                  height: 0,
                  width: 0,
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
              child: Text("Join"),
              onPressed: () {
                joinGroup(group);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateGroup()));
            groupList = [];
            requestBuilder();
          },
          child: const Icon(Icons.add)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount:
                  hasMoreGroups ? groupList.length + 1 : groupList.length,
              itemBuilder: (context, index) {
                if (index >= groupList.length) {
                  //-----if end of list then fetch more users-----
                  if (!isLoading) loadMoreGroups();
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final group = groupList[index];

                return Card(
                  elevation: 8,
                  child: SizedBox(
                      height: 72,
                      child: Center(
                        child: ListTile(
                          onTap: () async {
                            if (group.hasJoined) {
                              CometChat.getConversation(
                                  group.guid, CometChatConversationType.group,
                                  onSuccess: (Conversation conversation) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MessageList(
                                              conversation: conversation,
                                            )));
                              }, onError: (CometChatException e) {});
                            } else {
                              showJoinGroupDialog(group);
                            }
                          },
                          leading: CircleAvatar(
                              child: group.icon.isNotEmpty
                                  ? Image.network(
                                      group.icon,
                                      errorBuilder: (context, object, trace) {
                                        return Text(group.name.substring(0, 1));
                                      },
                                    )
                                  : Text(group.name.substring(0, 1))),
                          title: Text(group.name),
                        ),
                      )),
                );
              },
            ),
    );
  }
}
