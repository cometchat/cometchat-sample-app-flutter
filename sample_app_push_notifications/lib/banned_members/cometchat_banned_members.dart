import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';

import 'banned_member_builder_protocol.dart';
import 'cometchat_banned_members_controller.dart';

class CometChatBannedMembers extends StatelessWidget {
  CometChatBannedMembers({
    Key? key,
    required this.group,
  }):super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final CometChatBannedMembersController bannedMembersController = Get.put(
        CometChatBannedMembersController(
          bannedMemberBuilderProtocol: UIBannedMemberBuilder(
            BannedGroupMembersRequestBuilder(guid: group.guid),
          ),
          group: group,
          disableUsersPresence: true,
        ),
        tag: "BannedMembers");

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        0,
      ),
      child: CometChatListBase(
        title: cc.Translations.of(context).bannedMembers,
        showBackButton: true,
        onSearch: bannedMembersController.onSearch,
        searchPadding: EdgeInsets.symmetric(
          horizontal: spacing.padding4 ?? 0,
          vertical: spacing.padding3 ?? 0,
        ),
        searchContentPadding: EdgeInsets.symmetric(
          horizontal: spacing.padding3 ?? 0,
          vertical: spacing.padding2 ?? 0,
        ),
        style: ListBaseStyle(
          background: colorPalette.background1,
          titleStyle: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ),
          backIconTint: colorPalette.iconPrimary,
          searchIconTint: colorPalette.iconSecondary,
          searchTextStyle: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          ),
          searchPlaceholderStyle: TextStyle(
            color: colorPalette.textTertiary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          ),
          searchBoxBackground: colorPalette.background3,
          searchTextFieldRadius: BorderRadius.circular(
            spacing.radiusMax ?? 0,
          ),
          appBarShape: Border(
            bottom: BorderSide(
              color: colorPalette.borderLight ?? Colors.transparent,
              width: 1,
            ),
          ),
        ),
        container: GetBuilder(
            init: bannedMembersController,
            global: false,
            tag: "BannedMembers",
            dispose:
                (GetBuilderState<CometChatBannedMembersController> state) =>
                    state.controller?.onClose(),
            builder: (CometChatBannedMembersController value) {
              return _getList(
                value,
                context,
                colorPalette,
                typography,
                spacing,
              );
            }),
      ),
    );
  }
}

Widget getDefaultItem(
  GroupMember bannedMember,
  CometChatBannedMembersController controller,
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  Widget? subtitle;
  Color? backgroundColor;
  Widget? icon;

  StatusIndicatorUtils statusIndicatorUtils =
      StatusIndicatorUtils.getStatusIndicatorFromParams(
    context: context,
    onlineStatusIndicatorColor: colorPalette.success,
    isSelected: false,
  );

  backgroundColor = statusIndicatorUtils.statusIndicatorColor;
  icon = statusIndicatorUtils.icon;

  return CometChatListItem(
    key: UniqueKey(),
    id: bannedMember.uid,
    avatarName: bannedMember.name,
    avatarURL: bannedMember.avatar,
    title: bannedMember.name,
    subtitleView: subtitle,
    tailView: IconButton(
      onPressed: () {
        controller.unBanMember(context, controller.group, bannedMember,
            colorPalette, typography, spacing);
      },
      icon: Icon(
        Icons.close,
        color: colorPalette.iconSecondary,
      ),
    ),
    style: ListItemStyle(
      background: colorPalette.background1,
      titleStyle: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: typography.heading4?.medium?.fontSize,
        fontWeight: typography.heading4?.medium?.fontWeight,
        fontFamily: typography.heading4?.medium?.fontFamily,
        color: colorPalette.textPrimary,
      ),
      padding: EdgeInsets.only(
        left: spacing.padding4 ?? 0,
        right: spacing.padding4 ?? 0,
        top: spacing.padding3 ?? 0,
        bottom: spacing.padding3 ?? 0,
      ),
    ),
  );
}

Widget getListItem(
  GroupMember bannedMember,
  CometChatBannedMembersController controller,
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  return getDefaultItem(
    bannedMember,
    controller,
    context,
    colorPalette,
    typography,
    spacing,
  );
}

Widget _getLoadingIndicator(
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  return CometChatShimmerEffect(
    colorPalette: colorPalette,
    child: SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            itemCount: 30,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.padding4 ?? 0,
                  vertical: spacing.padding3 ?? 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: spacing.padding3 ?? 0,
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Container(
                      height: 22.0,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _getNoBannedMemberIndicator(
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AssetConstants(CometChatThemeHelper.getBrightness(context))
              .emptyUserList,
          package: UIConstants.packageName,
          width: 120,
          height: 120,
        ),
        Text(
          cc.Translations.of(context).noBannedMembersFound,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading3?.bold?.fontSize,
            fontWeight: typography.heading3?.bold?.fontWeight,
            fontFamily: typography.heading3?.bold?.fontFamily,
          ),
        ),
        Text(
          "",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorPalette.textSecondary,
            fontSize: typography.heading3?.regular?.fontSize,
            fontWeight: typography.heading3?.regular?.fontWeight,
            fontFamily: typography.heading3?.regular?.fontFamily,
          ),
        ),
      ],
    ),
  );
}

_showError(
  CometChatBannedMembersController controller,
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  return UIStateUtils.getDefaultErrorStateView(
    context,
    colorPalette,
    typography,
    spacing,
    () {
      controller.retryUsers();
    },
  );
}

Widget _getList(
  CometChatBannedMembersController value,
  context,
  CometChatColorPalette colorPalette,
  CometChatTypography typography,
  CometChatSpacing spacing,
) {
  if (value.hasError == true) {
    return _showError(
      value,
      context,
      colorPalette,
      typography,
      spacing,
    );
  } else if (value.isLoading == true && (value.list.isEmpty)) {
    return _getLoadingIndicator(
      context,
      colorPalette,
      typography,
      spacing,
    );
  } else if (value.list.isEmpty) {
    return _getNoBannedMemberIndicator(
      context,
      colorPalette,
      typography,
      spacing,
    );
  } else {
    return ListView.builder(
      itemCount: value.hasMoreItems ? value.list.length + 1 : value.list.length,
      itemBuilder: (context, index) {
        if (index >= value.list.length) {
          value.loadMoreElements();
          return _getLoadingIndicator(
            context,
            colorPalette,
            typography,
            spacing,
          );
        }

        return Column(
          children: [
            getListItem(
              value.list[index],
              value,
              context,
              colorPalette,
              typography,
              spacing,
            ),
          ],
        );
      },
    );
  }
}
