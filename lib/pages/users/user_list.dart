import 'dart:convert';

import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/users/create_user.dart';
import 'package:sdk_tutorial/pages/users/update_user.dart';
import 'package:http/http.dart' as http;
import 'package:sdk_tutorial/pages/users/user_details.dart';

import '../../Utils/custom_toast.dart';
import '../../Utils/loading_indicator.dart';
import '../../constants.dart';
import '../messages/message_list.dart';

enum NavigateFrom { addMembers, userList }

class CometChatUserList extends StatefulWidget {
  const CometChatUserList({Key? key, required this.navigateFrom})
      : super(key: key);
  final NavigateFrom navigateFrom;

  @override
  _CometChatUserListState createState() => _CometChatUserListState();
}

class _CometChatUserListState extends State<CometChatUserList>
    with UserListener {
  List<User> userList = [];
  List<User> addMemberList = [];
  Set<int> selectedIndex = {};

  bool isLoading = true;
  bool hasMoreUsers = true;

  late UsersRequest usersRequest;

  @override
  void onUserOnline(User user) {
    if (userList.contains(user)) {
      int index = userList.indexOf(user);
      userList[index].status = CometChatUserStatus.online;
      setState(() {});
    }
  }

  @override
  void onUserOffline(User user) {
    if (userList.contains(user)) {
      int index = userList.indexOf(user);
      userList[index].status = CometChatUserStatus.offline;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    CometChat.addUserListener("user_Listener_id", this);
    requestBuilder();
  }

  requestBuilder() {
    usersRequest = (UsersRequestBuilder()..limit = 30
        // ..searchKeyword = "abc"
        // ..userStatus = CometChatUserStatus.online
        // ..hideBlockedUsers = true
        // ..friendsOnly = true
        // ..tags = []
        // ..withTags = true
        // ..uids = []
        )
        .build();

    loadMoreUsers();
  }

  //Function to load more users
  loadMoreUsers() async {
    isLoading = true;

    await usersRequest.fetchNext(
        onSuccess: (List<User> fetchedList) {
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

  //-----deleting user using http request-----
  deleteUser(String uid, int index) async {
    showLoadingIndicatorDialog(context);
    String appId = CometChatAuthConstants.appId;
    String region = CometChatAuthConstants.region;
    String apiKey = CometChatAuthConstants.apiKey;

    Uri url =
        Uri.parse('https://$appId.api-$region.cometchat.io/v3/users/$uid');
    Map<String, String> headers = {
      'apiKey': apiKey,
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> body = {
      "permanent":
          true //Permanently deletes the user along with all the messages, conversations, etc.optional
    };

    var response =
        await http.delete(url, body: jsonEncode(body), headers: headers);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data["data"]["success"] == true) {
        userList.removeAt(index);
        showCustomToast(msg: 'User Deleted');
        setState(() {});
      }
    } else {
      debugPrint(response.body);
      showCustomToast(msg: 'Something went wrong', background: Colors.red);
    }
    Navigator.pop(context);
  }

  Widget getUserListMenuOptions(User user, int index) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'Update') {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateUser(
                        user: user,
                        updateLoggedInUser: false,
                      )));

          CometChat.getUser(user.uid, onSuccess: (User user) {
            setState(() {
              userList[index] = user;
            });
          }, onError: (CometChatException e) {});
        } else if (value == 'Delete') {
          deleteUser(user.uid, index);
        } else if (value == 'Details') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDetails(
                        user: user,
                      )));
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Details', 'Update', 'Delete'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          toolbarHeight: 50,
          iconTheme: const IconThemeData(color: Colors.black),
          title: widget.navigateFrom == NavigateFrom.userList
              ? const Text(
                  'Users',
                  style: TextStyle(color: Colors.black),
                )
              : const Text(
                  "Add Members",
                  style: TextStyle(color: Colors.black),
                ),
          actions: [
            if (widget.navigateFrom == NavigateFrom.addMembers &&
                selectedIndex.isNotEmpty)
              IconButton(
                  onPressed: () {
                    Navigator.pop(context, addMemberList);
                  },
                  icon: const Icon(Icons.check))
          ],
        ),
        floatingActionButton: widget.navigateFrom == NavigateFrom.userList
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateUser()));
                  userList = [];
                  requestBuilder();
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: Column(
          children: [
            //-----Search Box on user list-----
            if (widget.navigateFrom == NavigateFrom.userList)
              Container(
                padding: const EdgeInsets.all(10),
                height: 60,
                child: Center(
                  child: TextField(
                    onSubmitted: (String val) {
                      usersRequest = (UsersRequestBuilder()
                            ..limit = 30
                            ..searchKeyword = val)
                          .build();
                      userList = [];
                      setState(() {});

                      loadMoreUsers();
                    },
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 17),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "Search",
                        prefixIcon: Icon(
                          Icons.search,
                          color: const Color(0xff141414).withOpacity(0.40),
                        ),
                        hintStyle: TextStyle(
                            color: const Color(0xff141414).withOpacity(0.58),
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.black, width: 0),
                            borderRadius: BorderRadius.circular(100)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 1),
                            borderRadius: BorderRadius.circular(100)),
                        fillColor: const Color(0xff141414).withOpacity(0.04),
                        filled: true),
                  ),
                ),
              ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount:
                          hasMoreUsers ? userList.length + 1 : userList.length,
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

                        final user = userList[index];

                        return Card(
                          elevation: 8,
                          color: selectedIndex.contains(index)
                              ? Colors.grey
                              : Colors.white,
                          child: SizedBox(
                              height: 72,
                              child: Center(
                                child: ListTile(
                                  onTap: () {
                                    if (widget.navigateFrom ==
                                            NavigateFrom.addMembers &&
                                        !selectedIndex.contains(index)) {
                                      addMemberList.add(user);
                                      selectedIndex.add(index);
                                      setState(() {});
                                    } else if (widget.navigateFrom ==
                                            NavigateFrom.addMembers &&
                                        selectedIndex.contains(index)) {
                                      selectedIndex.remove(index);
                                      addMemberList.remove(user);
                                      setState(() {});
                                    } else if (widget.navigateFrom ==
                                        NavigateFrom.userList) {
                                      CometChat.getConversation(
                                          user.uid, ConversationType.user,
                                          onSuccess:
                                              (Conversation conversation) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageList(
                                                      conversation:
                                                          conversation,
                                                    )));
                                      }, onError: (CometChatException e) {
                                        Conversation createConversation =
                                            Conversation(
                                          conversationType:
                                              ConversationType.user,
                                          conversationWith: user,
                                        );

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageList(
                                                      conversation:
                                                          createConversation,
                                                    )));
                                      });
                                    }
                                  },
                                  leading: CircleAvatar(
                                      child: Stack(
                                    children: [
                                      CircleAvatar(
                                          child: user.avatar != null &&
                                                  user.avatar!.isNotEmpty
                                              ? Image.network(user.avatar!)
                                              : Text(
                                                  user.name.substring(0, 1))),
                                      if (widget.navigateFrom ==
                                              NavigateFrom.userList &&
                                          user.status != null)
                                        Positioned(
                                          height: 12,
                                          width: 12,
                                          right: 1,
                                          bottom: 1,
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                                color: user.status ==
                                                        CometChatUserStatus
                                                            .online
                                                    ? Colors.blue
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        )
                                    ],
                                  )),
                                  title: Text(user.name),
                                  subtitle: Text(user.uid),
                                  trailing: widget.navigateFrom ==
                                          NavigateFrom.userList
                                      ? getUserListMenuOptions(user, index)
                                      : null,
                                ),
                              )),
                        );
                      },
                    ),
                  ),
          ],
        ));
  }
}
