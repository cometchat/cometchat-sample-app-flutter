import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cometchat_add_memebers_controller.dart';

class CometChatAddMembers extends StatelessWidget {
  CometChatAddMembers({
    Key? key,
    required this.group,
  })  : _cometChatAddMembersController = CometChatAddMembersController(
    group: group,
  ),
        super(key: key);

  final Group group;

  final CometChatAddMembersController _cometChatAddMembersController;

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    String tag = "add_members_tag_${group.guid}";


    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPalette.background1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorPalette.iconPrimary,
          ),
          onPressed: () {
            Get.delete<CometChatUsersController>(tag: tag);
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Text(
          cc.Translations.of(context).addMembers,
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ),
        ),
      ),
      body: GetBuilder(
        init: _cometChatAddMembersController,
        global: false,
        dispose: (GetBuilderState<CometChatAddMembersController> state) {
          state.controller?.onClose();
          Get.delete<CometChatUsersController>(tag: tag);
        },
        builder: (CometChatAddMembersController controller) {
          return Column(
            children: [
              Expanded(
                child: CometChatUsers(
                  stickyHeaderVisibility: true,
                  controllerTag: tag,
                  hideAppbar: true,
                  title: cc.Translations.of(context).addMembers,
                  showBackButton: true,
                  selectionMode: SelectionMode.multiple,
                  onSelection: (users, context) {
                    if (users != null) {
                      controller.updateSelectedUsers(users);
                    }
                  },
                  submitIcon: const SizedBox(),
                  activateSelection: ActivateSelection.onClick,
                ),
              ),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colorPalette.background1,
                  border: Border(
                    top: BorderSide(
                      color: colorPalette.borderLight ?? Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.margin3 ?? 0,
                    vertical: spacing.margin4 ?? 0,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (Get.isRegistered<CometChatUsersController>(
                            tag: tag)) {
                          CometChatUsersController usersController =
                          Get.find<CometChatUsersController>(tag: tag);
                          controller.addMember(
                            usersController.getSelectedList(),
                            context,
                            colorPalette,
                            spacing,
                            typography,
                            userController: usersController,
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          colorPalette.primary,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 8,
                            ),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(
                            vertical: spacing.padding2 ?? 8,
                            horizontal: spacing.padding5 ?? 20,
                          ),
                        ),
                      ),
                      child: Center(
                        child: (controller.isLoading)
                            ? CircularProgressIndicator(
                          color: colorPalette.white,
                        )
                            : Text(
                          cc.Translations.of(context).addMembers,
                          style: TextStyle(
                            color: colorPalette.buttonIconColor,
                            fontSize: typography.button?.medium?.fontSize,
                            fontFamily:
                            typography.button?.medium?.fontFamily,
                            fontWeight:
                            typography.button?.medium?.fontWeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}