import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app/group_info/cometchat_group_info_controller.dart';

class CometchatGroupInfo extends StatefulWidget {
  const CometchatGroupInfo({
    Key? key,
    required this.group,
    this.user,
  }) : super(key: key);

  final Group group;
  final User? user;

  @override
  State<CometchatGroupInfo> createState() => _CometchatGroupInfoState();
}

class _CometchatGroupInfoState extends State<CometchatGroupInfo> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatGroupInfoController groupInfoController;

  @override
  void initState() {
    getGroup();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    groupInfoController = CometChatGroupInfoController(
        widget.user, widget.group, colorPalette, typography, spacing);
  }

  getGroup() async {
    await CometChat.getGroup(
      widget.group.guid,
      onSuccess: (grp) {
        groupInfoController.group = grp;
        setState(() {});
      },
      onError: (e) {
        print("Group Info: Group fetching failed with exception: ${e.message}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: groupInfoController,
      global: false,
      dispose: (GetBuilderState<CometChatGroupInfoController> state) =>
          state.controller?.onClose(),
      builder: (CometChatGroupInfoController value) {
        value.context = context;
        return Scaffold(
          backgroundColor: colorPalette.background1,
          appBar: AppBar(
            backgroundColor: colorPalette.background1,
            titleSpacing: 0,
            centerTitle: false,
            leading: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: colorPalette.iconPrimary,
              ),
            ),
            title: Text(
              "Group Info",
              style: TextStyle(
                fontSize: typography.heading2?.bold?.fontSize,
                fontFamily: typography.heading2?.bold?.fontFamily,
                fontWeight: typography.heading2?.bold?.fontWeight,
                color: colorPalette.textPrimary,
              ),
            ),
          ),
          body: Column(
            children: [
              Divider(
                color: colorPalette.borderLight,
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.padding5 ?? 0,
                ),
                child: Column(
                  children: [
                    _getProfile(context, value),
                    Text(
                      widget.group.name,
                      style: TextStyle(
                        fontSize: typography.heading2?.medium?.fontSize,
                        fontFamily: typography.heading2?.medium?.fontFamily,
                        fontWeight: typography.heading2?.medium?.fontWeight,
                        color: colorPalette.textPrimary,
                      ),
                    ),
                    Text(
                      "${widget.group.membersCount} Members",
                      style: TextStyle(
                        fontSize: typography.caption1?.regular?.fontSize,
                        fontFamily: typography.caption1?.regular?.fontFamily,
                        fontWeight: typography.caption1?.regular?.fontWeight,
                        color: colorPalette.textSecondary,
                      ),
                    ),
                    _getOptionTiles(value),
                  ],
                ),
              ),
              Divider(
                color: colorPalette.borderLight,
                height: 1,
              ),
              _getSecondaryActions(context, value),
            ],
          ),
        );
      },
    );
  }

  // Return the avatar along with status indicator.
  Widget _getProfile(
      context, CometChatGroupInfoController groupInfoController) {
    Group? group = groupInfoController.group;
    Widget? status;

    if (group != null) {
      StatusIndicatorUtils statusIndicatorUtils =
          StatusIndicatorUtils.getStatusIndicatorFromParams(
        isSelected: false,
        group: group,
        usersStatusVisibility: groupInfoController.hideUserPresence(),
        context: context,
      );
      if (group.type == GroupTypeConstants.password ||
          group.type == GroupTypeConstants.private) {
        status = CometChatStatusIndicator(
          height: 20,
          width: 20,
          backgroundImage: (group.type == GroupTypeConstants.password)
              ? Icon(
                  Icons.lock,
                  color: colorPalette.background1,
                  size: 10,
                )
              : (group.type == GroupTypeConstants.private)
                  ? Icon(
                      Icons.shield,
                      color: colorPalette.background1,
                      size: 10,
                    )
                  : const SizedBox(),
          style: CometChatStatusIndicatorStyle(
            backgroundColor: statusIndicatorUtils.statusIndicatorColor,
            border: Border.all(
              color: colorPalette.background1 ?? Colors.transparent,
              width: 2,
            ),
          ),
        );
      }
    } else {
      status = const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding10 ?? 0,
        bottom: spacing.padding3 ?? 0,
      ),
      child: Stack(
        children: [
          CometChatAvatar(
            height: 120,
            width: 120,
            image: widget.group.icon ?? "",
            name: widget.group.name,
            style: CometChatAvatarStyle(
              placeHolderTextStyle: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colorPalette.white,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: status ?? const SizedBox(),
          )
        ],
      ),
    );
  }

  Widget tile(Widget icon, String title, VoidCallback onClick) {
    return Expanded(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding2 ?? 0,
            horizontal: spacing.padding2 ?? 0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorPalette.borderDefault ?? Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              spacing.radius2 ?? 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding1 ?? 0,
                ),
                child: icon,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  color: colorPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listTileOptions(String title, Widget icon, VoidCallback onClick) {
    return ListTile(
      onTap: onClick,
      leading: icon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.padding5 ?? 0,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: typography.heading4?.regular?.fontSize,
          fontFamily: typography.heading4?.regular?.fontFamily,
          fontWeight: typography.heading4?.regular?.fontWeight,
          color: colorPalette.error,
        ),
      ),
    );
  }

  Widget _getOptionTiles(CometChatGroupInfoController controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding3 ?? 0,
        bottom: spacing.padding5 ?? 0,
        right: spacing.padding2 ?? 0,
        left: spacing.padding2 ?? 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (controller.canAccessOption(GroupOptionConstants.viewMembers))
            tile(
              Icon(
                Icons.group_outlined,
                color: colorPalette.iconHighlight,
                size: 24,
              ),
              "View Members",
              () {
                if (controller.group != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CometChatGroupMembers(
                        group: controller.group!,
                      ),
                    ),
                  );
                }
              },
            ),
          if (controller.canAccessOption(GroupOptionConstants.viewMembers))
            SizedBox(
              width: spacing.padding2,
            ),
          if (controller.canAccessOption(GroupOptionConstants.addMembers))
            tile(
              Icon(
                Icons.person_add_alt,
                color: colorPalette.iconHighlight,
                size: 24,
              ),
              "Add Members",
              () {
                if (controller.group != null) {
                  controller.onAddMemberClicked(
                    controller.group!,
                  );
                }
              },
            ),
          if (controller.canAccessOption(GroupOptionConstants.addMembers))
            SizedBox(
              width: spacing.padding2,
            ),
          if (controller.canAccessOption(GroupOptionConstants.bannedMembers))
            tile(
              Icon(
                Icons.person_outline_outlined,
                color: colorPalette.iconHighlight,
                size: 24,
              ),
              "Banned Members",
              () {
                if (controller.group != null) {
                  controller.onBannedMembersClicked(
                    controller.group!,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _getSecondaryActions(
      BuildContext context, CometChatGroupInfoController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.canAccessOption(GroupOptionConstants.leave))
          getLeaveOption(context, controller),
        if (controller.canAccessOption(GroupOptionConstants.delete))
          listTileOptions(
            "Delete and Exit",
            Icon(Icons.delete, color: colorPalette.error),
            () {
              controller.deleteGroupDialog(
                context: context,
                colorPalette: colorPalette,
                typography: typography,
              );
            },
          ),
      ],
    );
  }

  Widget getLeaveOption(context, CometChatGroupInfoController controller) {
    if (controller.membersCount <= 1 &&
        controller.group?.owner == controller.loggedInUser?.uid) {
      return const SizedBox();
    }
    return listTileOptions(
      "Leave",
      Icon(Icons.exit_to_app, color: colorPalette.error),
      () {
        if (controller.membersCount > 1 &&
            controller.group?.owner == controller.loggedInUser?.uid) {
          //transfer ownership of group
          controller.transferOwnershipDialog(
              context, controller.group!, colorPalette, typography, spacing);
        } else {
          controller.leaveGroupDialog(
            context: context,
            colorPalette: colorPalette,
            typography: typography,
          );
        }
      },
    );
  }
}
