import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cometchat_user_info_controller.dart';

class CometchatUserInfo extends StatefulWidget {
  const CometchatUserInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<CometchatUserInfo> createState() => _CometchatUserInfoState();
}

class _CometchatUserInfoState extends State<CometchatUserInfo> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatUserInfoController userInfoController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    userInfoController = CometChatUserInfoController(
        widget.user, colorPalette, typography, spacing);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: userInfoController,
      global: false,
      dispose: (GetBuilderState<CometChatUserInfoController> state) =>
          state.controller?.onClose(),
      builder: (CometChatUserInfoController value) {
        value.context = context;
        value.updateUserStatue(widget.user);
        return Scaffold(
          backgroundColor: colorPalette.background1,
          appBar: AppBar(
            backgroundColor: colorPalette.background1,
            centerTitle: false,
            titleSpacing: 0,
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
              cc.Translations.of(context).userInfo,
              style: TextStyle(
                fontSize: typography.heading2?.bold?.fontSize,
                fontFamily: typography.heading2?.bold?.fontFamily,
                fontWeight: typography.heading2?.bold?.fontWeight,
                color: colorPalette.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Divider(
                  color: colorPalette.borderLight,
                  height: 1,
                ),
                if (value.getBlockedByMe())
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.padding3 ?? 0,
                      vertical: spacing.padding2 ?? 0,
                    ),
                    color: colorPalette.warning?.withValues(alpha: 0.2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: colorPalette.warning,
                        ),
                        SizedBox(
                          width: spacing.padding2,
                        ),
                        Text(
                          "${cc.Translations.of(context).youHaveBlocked} ${widget.user.name}.",
                          style: TextStyle(
                            fontSize: typography.body?.regular?.fontSize,
                            fontFamily: typography.body?.regular?.fontFamily,
                            fontWeight: typography.body?.regular?.fontWeight,
                            color: colorPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: spacing.padding5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.padding5 ?? 0,
                  ),
                  child: Column(
                    children: [
                      _getProfile(context, value),
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: typography.heading2?.medium?.fontSize,
                          fontFamily: typography.heading2?.medium?.fontFamily,
                          fontWeight: typography.heading2?.medium?.fontWeight,
                          color: colorPalette.textPrimary,
                        ),
                      ),
                      Text(
                        value.presence,
                        style: TextStyle(
                          fontSize: typography.caption1?.regular?.fontSize,
                          fontFamily: typography.caption1?.regular?.fontFamily,
                          fontWeight: typography.caption1?.regular?.fontWeight,
                          color: colorPalette.textSecondary,
                        ),
                      ),
                      if (value.isUserBlocked) _getOptionTiles(value),
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
          ),
        );
      },
    );
  }

  // Return the avatar along with status indicator.
  Widget _getProfile(context, CometChatUserInfoController userInfoController) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: spacing.padding3 ?? 0,
      ),
      child: CometChatAvatar(
        height: 120,
        width: 120,
        image: widget.user.avatar ?? "",
        name: widget.user.name,
        style: CometChatAvatarStyle(
          placeHolderTextStyle: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: colorPalette.white,
          ),
        ),
      ),
    );
  }

  Widget tile(Widget icon, String title, VoidCallback onClick) {
    return Expanded(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding2 ?? 0,
            horizontal: spacing.padding3 ?? 0,
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
                  bottom: spacing.padding2 ?? 0,
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
      enableFeedback: false,
      minLeadingWidth: 0,
      minTileHeight: 0,
      minVerticalPadding: 0,
      onTap: onClick,
      leading: icon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.padding5 ?? 0,
        vertical: spacing.padding3 ?? 0,
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

  Widget _getOptionTiles(CometChatUserInfoController controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding5 ?? 0,
        bottom: spacing.padding5 ?? 0,
        right: spacing.padding5 ?? 0,
        left: spacing.padding5 ?? 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tile(
            Icon(
              Icons.call_outlined,
              color: colorPalette.iconHighlight,
              size: 24,
            ),
            cc.Translations.of(context).voice,
            () {
              controller.initiateCallWorkflow(
                CallTypeConstants.audioCall,
                context,
              );
            },
          ),
          SizedBox(
            width: spacing.padding2,
          ),
          tile(
            Icon(
              Icons.videocam_outlined,
              color: colorPalette.iconHighlight,
              size: 24,
            ),
            cc.Translations.of(context).video,
            () {
              controller.initiateCallWorkflow(
                CallTypeConstants.videoCall,
                context,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getSecondaryActions(
      BuildContext context, CometChatUserInfoController controller) {
    return Column(
      children: [
        listTileOptions(
            (controller.user != null &&
                    controller.user?.blockedByMe != null &&
                    !controller.user!.blockedByMe!)
                ? cc.Translations.of(context).block
                : cc.Translations.of(context).unBlock,
            Icon(Icons.block, color: colorPalette.error), () {
          if ((controller.user != null &&
              controller.user?.blockedByMe != null &&
              !controller.user!.blockedByMe!)) {
            controller.blockUserDialog(
              context: context,
              colorPalette: colorPalette,
              typography: typography,
            );
          } else {
            controller.unblockUserDialog(
              context: context,
              colorPalette: colorPalette,
              typography: typography,
            );
          }
        }),
        listTileOptions(
          cc.Translations.of(context).deleteTheChat,
          Image.asset(
            AssetConstants.delete,
            color: colorPalette.error,
            package: UIConstants.packageName,
          ),
          () {
            controller.deleteChatDialog(
              context: context,
              colorPalette: colorPalette,
              typography: typography,
            );
          },
        ),
      ],
    );
  }
}
