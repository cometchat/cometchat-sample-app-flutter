import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/transfer_ownership/cometchat_transfer_ownership_controller.dart';


class CometChatTransferOwnership extends StatelessWidget {
  CometChatTransferOwnership({
    Key? key,
    required this.group,
  })  : transferOwnershipController = CometChatTransferOwnershipController(
    group: group,
  ),
        super(key: key);

  final Group group;

  final CometChatTransferOwnershipController transferOwnershipController;

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    String dateString = DateTime.now().microsecondsSinceEpoch.toString();
    String tag = "default_tag_for_group_members_$dateString";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPalette.background1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorPalette.iconPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          "Ownership Transfer",
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ),
        ),
      ),
      body: GetBuilder(
        init: transferOwnershipController,
        global: false,
        dispose: (GetBuilderState<CometChatTransferOwnershipController> state) =>
            state.controller?.onClose(),
        builder: (CometChatTransferOwnershipController controller) {
          return Column(
            children: [
              Expanded(
                child: CometChatGroupMembers(
                  controllerTag: tag,
                  hideAppbar: true,
                  selectionMode: SelectionMode.single,
                  submitIcon: const SizedBox(),
                  activateSelection: ActivateSelection.onClick,
                  group: group,
                  setOptions: (group, groupMember, controller, context) => const [],
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
                        if (Get.isRegistered<CometChatGroupMembersController>(
                            tag: tag)) {
                          CometChatGroupMembersController membersController =
                          Get.find<CometChatGroupMembersController>(tag: tag);
                          membersController =
                              Get.find<CometChatGroupMembersController>(tag: tag);
                          if (membersController.selectionMap.entries.isNotEmpty) {
                            final member = membersController.selectionMap.entries.first.value;
                            if(member.uid == group.owner) {
                              var snackBar = SnackBar(
                                backgroundColor: colorPalette.error,
                                content: Text(
                                  "You are already the owner of this group.",
                                  style: TextStyle(
                                    color: colorPalette.white,
                                    fontSize: typography.button?.medium?.fontSize,
                                    fontWeight: typography.button?.medium?.fontWeight,
                                    fontFamily: typography.button?.medium?.fontFamily,
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }else {
                              controller.showConfirmDialog(
                                context,
                                group.guid,
                                member,
                                colorPalette,
                                typography,
                                spacing,
                              );
                            }
                          } else {
                            debugPrint("No members selected.");
                            var snackBar = SnackBar(
                              backgroundColor: colorPalette.error,
                              content: Text(
                                "Please select a member before proceeding.",
                                style: TextStyle(
                                  color: colorPalette.white,
                                  fontSize: typography.button?.medium?.fontSize,
                                  fontWeight: typography.button?.medium?.fontWeight,
                                  fontFamily: typography.button?.medium?.fontFamily,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
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
                          "Ownership Transfer",
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