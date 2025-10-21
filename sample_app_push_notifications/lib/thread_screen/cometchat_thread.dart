import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:get/get.dart';
import 'cometchat_thread_controller.dart';

class CometChatThread extends StatefulWidget {
  const CometChatThread(
      {this.user, this.group, required this.message, this.template, super.key});

  final User? user;
  final Group? group;
  final BaseMessage message;
  final CometChatMessageTemplate? template;

  @override
  State<CometChatThread> createState() => _CometChatThreadState();
}

class _CometChatThreadState extends State<CometChatThread> {
  late CometChatThreadController threadController;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    threadController = Get.put(
      CometChatThreadController(widget.user, widget.group),
      permanent: false, // Ensures proper disposal
    );
  }

  @override
  void dispose() {
    Get.delete<CometChatThreadController>(); // Cleanup controller
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
    return GetBuilder<CometChatThreadController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: colorPalette.background1,
          resizeToAvoidBottomInset:
              true, // Ensures layout adjusts for the keyboard
          appBar: CometChatMessageHeader(
            user: widget.user,
            group: widget.group,
            hideVideoCallButton: (widget.user != null ) ||
                (widget.group != null)
                ? ((controller.user?.blockedByMe != null &&
                controller.user?.blockedByMe! == true) ||
                (controller.group?.hasJoined == false ||
                    controller.group?.isBannedFromGroup == true))
                : false,
            hideVoiceCallButton: (widget.user != null ) ||
                (widget.group != null)
                ? ((controller.user?.blockedByMe != null &&
                controller.user?.blockedByMe! == true) ||
                (controller.group?.hasJoined == false ||
                    controller.group?.isBannedFromGroup == true))
                : false,
            padding: EdgeInsets.symmetric(
              vertical: spacing.padding2 ?? 0,
              horizontal: spacing.padding4 ?? 0,
            ),
            listItemView: (group, user, context) {
              final name = group != null ? group.name : user?.name ?? "";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cc.Translations.of(context).thread,
                    style: TextStyle(
                      color: colorPalette.textPrimary,
                      fontSize: typography.heading2?.bold?.fontSize,
                      fontFamily: typography.heading2?.bold?.fontFamily,
                      fontWeight: typography.heading2?.bold?.fontWeight,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: colorPalette.textSecondary,
                        fontSize: typography.caption1?.regular?.fontSize,
                        fontFamily: typography.caption1?.regular?.fontFamily,
                        fontWeight: typography.caption1?.regular?.fontWeight,
                      ),
                    ),
                  ),
                ],
              );
            },
            messageHeaderStyle: CometChatMessageHeaderStyle(
              backIconColor: colorPalette.iconPrimary,
              backgroundColor: colorPalette.background1,
              border: Border(
                top: BorderSide.none,
                right: BorderSide.none,
                bottom: BorderSide(
                  width: 1.0,
                  color: colorPalette.borderLight ?? Colors.transparent,
                  style: BorderStyle.solid,
                ),
                left: BorderSide(
                  width: 1.0,
                  color: colorPalette.borderLight ?? Colors.transparent,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              final totalHeight = constraints.maxHeight;

              final composerHeight = 60.0;
              final initialHeaderHeight = totalHeight * 0.3;

              // Adjust the height if keyboard is open
              final availableHeaderHeight = keyboardHeight > 0
                  ? totalHeight - composerHeight - keyboardHeight - 16
                  : initialHeaderHeight;

              return Container(
                color: colorPalette.background3,
                child: Column(
                  children: [
                    SizedBox(
                      height: availableHeaderHeight,
                      child: CometChatThreadedHeader(
                        height: availableHeaderHeight,
                        parentMessage: widget.message,
                        loggedInUser: CometChatUIKit.loggedInUser!,
                        template: widget.template,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: getMessageList(
                            widget.user, widget.group, context, widget.message),
                      ),
                    ),
                    getComposer(controller),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget getMessageList(
      User? user, Group? group, context, BaseMessage parentMessage) {
    MessagesRequestBuilder? requestBuilder = MessagesRequestBuilder();

    requestBuilder = MessagesRequestBuilder()
      ..parentMessageId = parentMessage.id;

    return CometChatMessageList(
      user: user,
      group: group,
      messagesRequestBuilder: requestBuilder,
    );
  }

  Widget getComposer(CometChatThreadController controller) {
    if (controller.user != null &&
        controller.user?.blockedByMe != null &&
        controller.user?.blockedByMe! == true) {
      return _buildBlockedUserSection(controller);
    } else if (controller.group != null &&
        (controller.group?.hasJoined == false ||
            controller.group?.isBannedFromGroup == true)) {
      return _buildKickedFromGroup(controller);
    } else {
      return CometChatMessageComposer(
        user: widget.user,
        group: widget.group,
        parentMessageId: widget.message.id,
      );
    }
  }

  Widget _buildBlockedUserSection(CometChatThreadController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding5 ?? 20,
      ),
      color: colorPalette.background4,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
            child: Text(
              cc.Translations.of(context).cantSendMessageBlockedUser,
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
                        borderRadius:
                            BorderRadius.circular(spacing.radius2 ?? 0),
                        side: BorderSide(
                          color: colorPalette.borderDark ?? Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      cc.Translations.of(context).unBlock,
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

  Widget _buildKickedFromGroup(CometChatThreadController controller) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding5 ?? 20,
      ),
      color: colorPalette.background4,
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
        child: Text(
          cc.Translations.of(context).cantSendMessageNotMember,
          style: TextStyle(
            color: colorPalette.textSecondary,
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
          ),
        ),
      ),
    );
  }
}
