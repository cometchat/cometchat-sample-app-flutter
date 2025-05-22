import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/thread_screen/cometchat_thread.dart';
import 'package:sample_app_push_notifications/user_info/cometchat_user_info.dart';
import 'package:sample_app_push_notifications/utils/page_manager.dart';

import 'dashboard.dart';
import 'group_info/cometchat_group_info.dart';

class MessagesSample extends StatelessWidget {
  final User? user;
  final Group? group;

  const MessagesSample({
    Key? key,
    this.user,
    this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ccColor = CometChatThemeHelper.getColorPalette(context);
    return Scaffold(
      backgroundColor: ccColor.background1,
      appBar: CometChatMessageHeader(
        user: user,
        group: group,
        onBack: () {
          // UnFocus the keyboard if it's open
          if (FocusManager.instance.primaryFocus != null &&
              FocusManager.instance.primaryFocus!.context?.widget
                  is EditableText) {
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(
              Duration(milliseconds: 300),
              () {
                Navigator.of(context).pop();
              },
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        appBarOptions: (user, group, context) {
          if (group != null) {
            return [
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometchatGroupInfo(
                        group: group,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.info_outline,
                  color: ccColor.iconPrimary,
                ),
              ),
            ];
          } else if (user != null) {
            return [
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CometchatUserInfo(
                          user: user,
                        );
                      },
                    ),
                  );
                },
                icon: SizedBox(
                  height: 24,
                  width: 24,
                  child: Icon(
                    Icons.info_outline,
                    color: ccColor.iconPrimary,
                    size: 24,
                  ),
                ),
              ),
            ];
          }
        },
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        color: ccColor.background3,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: CometChatMessageList(
                  user: user,
                  group: group,
                  showAvatar: true,
                  onThreadRepliesClick: (message, context, {template}) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CometChatThread(
                                user: user,
                                group: group,
                                message: message,
                                template: template,
                              )),
                    );
                  },
                ),
              ),
            ),
            CometChatMessageComposer(
              user: user,
              group: group,
            ),
          ],
        ),
      ),
    );
  }
}
