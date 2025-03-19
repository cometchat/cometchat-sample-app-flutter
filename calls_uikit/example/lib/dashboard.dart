import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with
        CometChatUserEventListener,
        CometChatMessageEventListener,
        CometChatGroupEventListener,
        CometChatConversationEventListener {
  late User? loggedInUser;

  // ValueNotifier<String?> initialText = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    initializeLoggedInUser();
  }

  List<CallLog> callLogsList = [];

  initializeLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
    userAuthToken = await CometChatUIKitCalls.getUserAuthToken();
    setState(() {});
  }

  RegExp messageShortcutPattern = RegExp(r'![a-zA-Z0-9]{1,}');

  @override
  void dispose() {
    // TODO: implement dispose
    CometChatUserEvents.removeUsersListener("dashboard_user_listener");
    CometChatGroupEvents.removeGroupsListener("group_listener");
    CometChatConversationEvents.removeConversationListListener(
        "dashboard_conversation_listener");
    CometChatMessageEvents.removeMessagesListener("dashboard_message_listener");

    super.dispose();
  }

  CometChatMessageComposerController? composerState;

  composerStateCallBack(CometChatMessageComposerController composerState) {
    this.composerState = composerState;
  }

  String? userAuthToken;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await CometChatUIKit.logout(
            onSuccess: (String msg) {
              if (kDebugMode) {
                debugPrint("user logged out successfully");
              }
            },
            onError: (_) {});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CometChatConversationsWithMessages"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.dark_mode)),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.18),
                      side: BorderSide(
                          color: Colors.blueGrey.shade800, width: 3)),
                  elevation: 0,
                  child: ListTile(
                      title: const Text(
                        "Conversations",
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'This will take you to CometChat Conversations',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CometChatConversations(
                              showBackButton: false,
                              onItemTap: (conversation) {
                                User? user;
                                Group? group;
                                if (conversation.conversationWith is User) {
                                  user = conversation.conversationWith as User;
                                } else {
                                  group =
                                  conversation.conversationWith as Group;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Scaffold(
                                        appBar: CometChatMessageHeader(
                                          user: user,
                                          group: group,
                                          trailingView:
                                              (user, group, context) {
                                            if (group != null) {
                                              return [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons.info_outline,
                                                  ),
                                                ),
                                              ];
                                            }
                                            return [
                                              const SizedBox()
                                            ];
                                          },
                                        ),
                                        resizeToAvoidBottomInset:
                                        true, // Ensures layout adjusts when keyboard appears
                                        body: SingleChildScrollView(
                                          reverse: true,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: CometChatMessageList(
                                                    user: user,
                                                    group: group,
                                                  ),
                                                ),
                                                CometChatMessageComposer(
                                                  user: user,
                                                  group: group,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );

                                      // return MyScrollTestWidget();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
