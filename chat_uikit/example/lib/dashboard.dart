import 'package:master_app/login.dart';
import 'package:master_app/messages.dart';
import 'package:master_app/utils/alert.dart';
import 'package:master_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Scaffold(
      backgroundColor: colorPalette.background1,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 10, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "UI Components",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorPalette.textPrimary),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Alert.showLoadingIndicatorDialog(context);
                          logout();
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        icon: Icon(Icons.power_settings_new_rounded,
                            color: colorPalette.textPrimary))
                  ],
                ),
              ),
              ModuleCard(
                title: "Conversations",
                leading: Image.asset(
                  'assets/icons/conversations.png',
                  height: 40,
                  width: 40,
                  color: colorPalette.textPrimary,
                ),
                description:
                    "Conversations module contains all available components for listing Conversation objects\n"
                    "To explore the available components tap here\n",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatConversations(
                        onItemTap: (conversation) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                User? user;
                                Group? group;
                                if (conversation.conversationWith is User) {
                                  user = conversation.conversationWith as User;
                                } else {
                                  group =
                                      conversation.conversationWith as Group;
                                  group.type = GroupTypeConstants.password;
                                }
                                return MessagesSample(
                                  user: user,
                                  group: group,
                                  color: colorPalette.background2,
                                );

                                // return MyScrollTestWidget();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Groups",
                leading: Image.asset(
                  'assets/icons/conversations.png',
                  height: 40,
                  width: 40,
                  color: colorPalette.textPrimary,
                ),
                description:
                    "Conversations module contains all available components for listing Conversation objects\n"
                    "To explore the available components tap here\n",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatGroups(
                        onItemTap: (context,group) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MessagesSample(
                                  group: group,
                                  color: colorPalette.background2,
                                );

                                // return MyScrollTestWidget();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Users",
                leading: Image.asset(
                  'assets/icons/conversations.png',
                  height: 40,
                  width: 40,
                  color: colorPalette.textPrimary,
                ),
                description:
                    "Conversations module contains all available components for listing Conversation objects\n"
                    "To explore the available components tap here\n",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatUsers(
                        onItemTap: (context,user) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MessagesSample(
                                  user: user,
                                  color: colorPalette.background2,
                                );

                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    await CometChatUIKit.logout();
  }
}
