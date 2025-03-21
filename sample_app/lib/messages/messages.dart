import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';
import 'package:sample_app/thread_screen/cometchat_thread.dart';
import 'package:sample_app/user_info/cometchat_user_info.dart';
import '../group_info/cometchat_group_info.dart';
import 'messages_controller.dart';

class MessagesSample extends StatefulWidget {
  final User? user;
  final Group? group;

  const MessagesSample({
    Key? key,
    this.user,
    this.group,
  }) : super(key: key);

  @override
  State<MessagesSample> createState() => _MessagesSampleState();
}

class _MessagesSampleState extends State<MessagesSample> {
  late CometChatMessagesController messagesController;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    messagesController = Get.put(
      CometChatMessagesController(widget.user, widget.group),
      permanent: false, // Ensures proper disposal
    );
  }

  @override
  void dispose() {
    Get.delete<CometChatMessagesController>(); // Cleanup controller
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    final ccColor = CometChatThemeHelper.getColorPalette(context);
    return GetBuilder<CometChatMessagesController>(builder: (controller) {
      return Scaffold(
        backgroundColor: ccColor.background1,
        appBar: CometChatMessageHeader(
          user: widget.user,
          group: widget.group,
          hideVideoCallButton: (widget.user != null) ? !controller.isUserBlocked : false,
          hideVoiceCallButton: (widget.user != null) ? !controller.isUserBlocked : false,
          onBack: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
          trailingView: (user, group, context) {
            if (group != null) {
              return [
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CometchatGroupInfo(group: group),
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
              if (!controller.isUserBlocked) {
                return [];
              } else {
                return [
                  IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CometchatUserInfo(user: user),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: ccColor.iconPrimary,
                      size: 24,
                    ),
                  ),
                ];
              }
            }
            return null;
          },
        ),
        resizeToAvoidBottomInset: true,
        body: Container(
          color: ccColor.background3,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: CometChatMessageList(
                    user: widget.user,
                    group: widget.group,
                    onThreadRepliesClick: (message, context, {template}) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CometChatThread(
                            user: widget.user,
                            group: widget.group,
                            message: message,
                            template: template,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              (widget.user != null && !controller.isUserBlocked)
                  ? _buildBlockedUserSection(controller)
                  : CometChatMessageComposer(
                      user: widget.user,
                      group: widget.group,
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBlockedUserSection(CometChatMessagesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding5 ?? 20,
      ),
      color: colorPalette.background4,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: spacing.padding1 ?? 0,
            ),
            child: Text(
              "Can’t send a message as the user is blocked",
              style: TextStyle(
                color: colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ),
            ),
          ),
          controller.isBlockLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorPalette.background2,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.unBlockUser(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          colorPalette.transparent, // Set proper color
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 0,
                        ),
                        side: BorderSide(
                          color: colorPalette.borderDark ?? Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      "UNBLOCK",
                      style: TextStyle(
                        color: colorPalette.textPrimary,
                        fontSize: typography.caption1?.regular?.fontSize,
                        fontWeight: typography.caption1?.regular?.fontWeight,
                        fontFamily: typography.caption1?.regular?.fontFamily,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
