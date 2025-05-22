import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

///[CometChatGroupMembers] is a component that displays all the members of a [Group] in the form of a list with the help of [CometChatListBase] and [CometChatListItem]
///fetched  are listed down alphabetically and in order of recent activity
///group members are fetched using [GroupMembersBuilderProtocol] and [GroupMembersRequestBuilder]
///
/// ```dart
///   CometChatGroupMembers(
///    group: Group(guid: 'guid', name: 'name', type: 'public'),
///    groupMemberStyle: GroupMembersStyle(),
///    groupScopeStyle: GroupScopeStyle(),
///  );
/// ```
///
class CometChatGroupMembers extends StatelessWidget {
  CometChatGroupMembers({
    super.key,
    this.groupMembersProtocol,
    this.subtitleView,
    this.hideSeparator,
    this.listItemView,
    this.style,
    this.controller,
    this.searchPlaceholder,
    this.backButton,
    this.showBackButton = true,
    this.searchBoxIcon,
    this.hideSearch = false,
    this.selectionMode,
    this.onSelection,
    this.stateCallBack,
    this.groupMembersRequestBuilder,
    this.hideError,
    this.loadingStateView,
    this.emptyStateView,
    this.errorStateView,
    this.appBarOptions,
    this.options,
    required this.group,
    this.trailingView,
    this.selectIcon,
    this.submitIcon,
    this.onError,
    this.onBack,
    this.onItemTap,
    this.onItemLongPress,
    this.activateSelection,
    this.height,
    this.width,
    this.controllerTag,
    this.hideAppbar,
    this.searchKeyword,
    this.onLoad,
    this.onEmpty,
    this.setOptions,
    this.addOptions,
    this.leadingView,
    this.titleView,
    this.hideBanMemberOption,
    this.hideKickMemberOption,
    this.hideScopeChangeOption,
    this.usersStatusVisibility = true,
  });

  ///property to be set internally by using passed parameters [groupMembersProtocol] ,[selectionMode] ,[options]
  ///these are passed to the [CometChatGroupMembersController] which is responsible for the business logic

  ///[groupMembersProtocol] set custom request builder protocol
  final GroupMembersBuilderProtocol? groupMembersProtocol;

  ///[groupMembersRequestBuilder] set custom request builder
  final GroupMembersRequestBuilder? groupMembersRequestBuilder;

  ///[subtitleView] to set subtitle for each groupMember
  final Widget? Function(BuildContext context, GroupMember groupMember)?
      subtitleView;

  ///[hideSeparator] toggle visibility of separator
  final bool? hideSeparator;

  ///[listItemView] set custom view for each groupMember
  final Widget Function(GroupMember groupMember)? listItemView;

  ///[style] sets style for [CometChatGroupMembers]
  final CometChatGroupMembersStyle? style;

  ///[controller] sets controller for the list
  final ScrollController? controller;

  ///[options]  set options which will be visible at slide of each groupMember
  final List<CometChatOption>? Function(
      Group group,
      GroupMember member,
      CometChatGroupMembersController controller,
      BuildContext context)? options;

  ///[searchPlaceholder] placeholder text of search input
  final String? searchPlaceholder;

  ///[backButton] back button
  final Widget? backButton;

  ///[showBackButton] switch on/off back button
  final bool showBackButton;

  ///[searchBoxIcon] search icon
  final Widget? searchBoxIcon;

  ///[hideSearch] switch on/ff search input
  final bool hideSearch;

  ///[selectionMode] specifies mode groupMembers module is opening in
  final SelectionMode? selectionMode;

  ///[onSelection] function will be performed
  final Function(List<GroupMember>?)? onSelection;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state behind the dialog
  final WidgetBuilder? errorStateView;

  ///[hideError] toggle visibility of error dialog
  final bool? hideError;

  ///[stateCallBack] to access controller functions  from parent pass empty reference of  CometChatGroupMembersController object
  final Function(CometChatGroupMembersController controller)? stateCallBack;

  ///[appBarOptions] list of options to be visible in app bar
  final List<Widget>? appBarOptions;

  ///object to passed across to fetch members of
  final Group group;

  ///[trailingView] a custom widget for the tail section of the group member list item
  final Function(BuildContext context, GroupMember groupMember)? trailingView;

  ///[submitIcon] will override the default selection complete icon
  final Widget? submitIcon;

  ///[selectIcon] will override the default selection icon
  final Widget? selectIcon;

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[onItemTap] callback triggered on tapping a user item
  final Function(GroupMember groupMember)? onItemTap;

  ///[onItemLongPress] callback triggered on pressing for long on a user item
  final Function(GroupMember groupMember)? onItemLongPress;

  ///[activateSelection] lets the widget know if groups are allowed to be selected
  final ActivateSelection? activateSelection;

  ///[onError] in case any error occurs
  final OnError? onError;

  final RxBool _isSelectionOn = false.obs;

  ///[height] height of the widget
  final double? height;

  ///[width] width of the widget
  final double? width;

  ///[controllerTag] tag to access the widget's GetXController
  final String? controllerTag;

  ///[hideAppbar] hides the appbar
  final bool? hideAppbar;

  ///[searchKeyword] Used to set searchKeyword to fetch initial list with
  final String? searchKeyword;

  ///[onLoad] callback triggered when list is fetched and load
  final OnLoad<GroupMember>? onLoad;

  ///[onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  ///[leadingView] to set leading view for each GroupMember
  final Widget? Function(BuildContext context, GroupMember groupMember)?
      leadingView;

  ///[titleView] to set title view for each GroupMember
  final Widget? Function(BuildContext context, GroupMember groupMember)?
      titleView;

  ///[usersStatusVisibility] Hide status indicator of user which is visible on user avatar
  final bool? usersStatusVisibility;

  ///[hideAppbar] This prop defines whether a member can be kicked or not.
  final bool? hideKickMemberOption;

  ///[hideAppbar] This prop defines whether a member can be banned or not.
  final bool? hideBanMemberOption;

  ///[hideAppbar] This prop defines whether a member's scope can be changed or not.
  final bool? hideScopeChangeOption;

  ///[setOptions] sets List of actions available on the long press of list item
  final List<CometChatOption>? Function(
      Group group,
      GroupMember groupMember,
      CometChatGroupMembersController controller,
      BuildContext context)? setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(
      Group group,
      GroupMember groupMember,
      CometChatGroupMembersController controller,
      BuildContext context)? addOptions;

  Widget getDefaultItem(
      GroupMember member,
      CometChatGroupMembersController controller,
      BuildContext context,
      GlobalKey key,
      CometChatGroupMembersStyle groupMemberStyle,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    Widget? subtitle;
    Widget? tail;
    Color? backgroundColor;
    Widget? icon;
    Widget? title;
    Widget? leading;

    if (titleView != null) {
      title = titleView!(context, member);
    }

    if (leadingView != null) {
      leading = leadingView!(context, member);
    }

    if (subtitleView != null) {
      subtitle = subtitleView!(context, member);
    }

    if (trailingView != null) {
      tail = trailingView!(context, member);
    } else {
      tail = _getTail(member, controller, groupMemberStyle, colorPalette,
          typography, spacing);
    }

    StatusIndicatorUtils statusIndicatorUtils =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
      context: context,
      groupMember: member,
      onlineStatusIndicatorColor:
          groupMemberStyle.onlineStatusColor ?? colorPalette.success,
      usersStatusVisibility: usersStatusVisibility,
      selectIcon: selectIcon,
    );

    backgroundColor = statusIndicatorUtils.statusIndicatorColor;
    icon = statusIndicatorUtils.icon;

    return Container(
      decoration: BoxDecoration(
        color: (controller.selectionMap[member.uid] != null)
            ? (groupMemberStyle.listItemSelectedBackgroundColor ??
                colorPalette.background4)
            : colorPalette.transparent,
      ),
      // padding: EdgeInsets.symmetric(vertical:spacing.padding2 ?? 0 , horizontal: spacing.padding4 ?? 0),
      padding: EdgeInsets.only(
        left: (controller.selectionMap.isNotEmpty) ? 0 : spacing.padding4 ?? 0,
        right: spacing.padding4 ?? 0,
        top: spacing.padding2 ?? 0,
        bottom: spacing.padding2 ?? 0,
      ),
      child: GestureDetector(
        onLongPress: () {
          if (member.uid != controller.group.owner &&
              (activateSelection == ActivateSelection.onLongClick &&
                  controller.selectionMap.isEmpty &&
                  !(selectionMode == null ||
                      selectionMode == SelectionMode.none))) {
            controller.onTap(member);

            _isSelectionOn.value = true;
          } else if (onItemLongPress != null) {
            onItemLongPress!(member);
          } else {
            List<CometChatOption>? options = [];

            if (setOptions != null) {
              options = setOptions!(
                group,
                member,
                controller,
                context,
              );
            } else {
              if (addOptions != null) {
                options.addAll(
                  addOptions!(
                        group,
                        member,
                        controller,
                        context,
                      ) ??
                      [],
                );
              }
              options.addAll(
                controller.defaultFunction(
                    group, member, context, colorPalette, typography, spacing),
              );
              if (addOptions != null) {
                if (group.owner != CometChatUIKit.loggedInUser?.uid &&
                    member.scope == GroupMemberScope.admin) {
                  return;
                }
              }
            }
            showPopupMenu(
              context,
              options ?? [],
              groupMemberStyle,
              colorPalette,
              typography,
              spacing,
              key,
              member,
            );
          }
        },
        onTap: () {
          if (member.uid != controller.group.owner &&
              (activateSelection == ActivateSelection.onClick ||
                  (activateSelection == ActivateSelection.onLongClick &&
                          controller.selectionMap.isNotEmpty) &&
                      !(selectionMode == null ||
                          selectionMode == SelectionMode.none))) {
            controller.onTap(member);
            if (controller.selectionMap.isEmpty) {
              _isSelectionOn.value = false;
            } else if (activateSelection == ActivateSelection.onClick &&
                controller.selectionMap.isNotEmpty &&
                _isSelectionOn.value == false) {
              _isSelectionOn.value = true;
            }
          } else if (onItemTap != null) {
            onItemTap!(member);
          }
        },
        child: Row(
          children: [
            (controller.selectionMap.isNotEmpty)
                ? Checkbox(
                    fillColor: (controller.selectionMap[member.uid] != null)
                        ? WidgetStateProperty.all(
                            groupMemberStyle.checkboxCheckedBackgroundColor ??
                                colorPalette.iconHighlight)
                        : WidgetStateProperty.all(
                            groupMemberStyle.checkboxBackgroundColor ??
                                colorPalette.transparent),
                    value: controller.selectionMap[member.uid] != null,
                    onChanged: (value) {
                      if (activateSelection == ActivateSelection.onClick ||
                          (activateSelection == ActivateSelection.onLongClick &&
                                  controller.selectionMap.isNotEmpty) &&
                              !(selectionMode == null ||
                                  selectionMode == SelectionMode.none)) {
                        controller.onTap(member);
                        if (controller.selectionMap.isEmpty) {
                          _isSelectionOn.value = false;
                        } else if (activateSelection ==
                                ActivateSelection.onClick &&
                            controller.selectionMap.isNotEmpty &&
                            _isSelectionOn.value == false) {
                          _isSelectionOn.value = true;
                        }
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: groupMemberStyle.checkboxBorderRadius ??
                          BorderRadius.circular(
                            spacing.radius1 ?? 0,
                          ),
                    ),
                    checkColor: groupMemberStyle.checkboxSelectedIconColor ??
                        colorPalette.white,
                    side: groupMemberStyle.checkboxBorder ??
                        BorderSide(
                          color: (controller.selectionMap[member.uid] != null
                                  ? colorPalette.borderHighlight
                                  : colorPalette.borderDefault) ??
                              Colors.transparent,
                          width: 1.25,
                          style: BorderStyle.solid,
                        ),
                  )
                : const SizedBox(),
            Expanded(
              child: CometChatListItem(
                  id: member.uid,
                  avatarName: member.name,
                  avatarURL: member.avatar,
                  title: (controller.loggedInUser != null &&
                          controller.loggedInUser!.uid == member.uid)
                      ? cc.Translations.of(context).you
                      : member.name,
                  key: UniqueKey(),
                  subtitleView: subtitle,
                  tailView: tail,
                  avatarStyle: groupMemberStyle.avatarStyle ??
                      const CometChatAvatarStyle(),
                  avatarHeight: 40,
                  avatarWidth: 40,
                  statusIndicatorColor: backgroundColor,
                  statusIndicatorIcon: icon,
                  statusIndicatorStyle: groupMemberStyle.statusIndicatorStyle ??
                      const CometChatStatusIndicatorStyle(),
                  hideSeparator: hideSeparator ?? true,
                  titleView: title,
                  leadingStateView: leading,
                  style: ListItemStyle(
                    background: colorPalette.transparent,
                    titleStyle: TextStyle(
                        fontSize: typography.heading4?.medium?.fontSize,
                        fontWeight: typography.heading4?.medium?.fontWeight,
                        fontFamily: typography.heading4?.medium?.fontFamily,
                        color: colorPalette.textPrimary),
                  ).merge(groupMemberStyle.listItemStyle)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getListItem(
      GroupMember member,
      CometChatGroupMembersController controller,
      BuildContext context,
      GlobalKey key,
      CometChatGroupMembersStyle groupMemberStyle,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (listItemView != null) {
      return listItemView!(member);
    } else {
      return getDefaultItem(member, controller, context, key, groupMemberStyle,
          colorPalette, typography, spacing);
    }
  }

  Widget _getLoadingIndicator(
      BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (loadingStateView != null) {
      return Center(child: loadingStateView!(context));
    } else {
      return CometChatShimmerEffect(
        colorPalette: colorPalette,
        child: ListView.builder(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title shimmer bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 19.0,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  spacing.radius2 ?? 0,
                                ),
                              ),
                            ),
                            Container(
                              height: 19.0,
                              width: MediaQuery.of(context).size.width * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  spacing.radius2 ?? 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        // Subtitle shimmer bar
                        Container(
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _getList(
      CometChatGroupMembersController value,
      BuildContext context,
      CometChatGroupMembersStyle groupMemberStyle,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (value.hasError == true) {
      if (errorStateView != null) {
        return errorStateView!(context);
      } else {
        return UIStateUtils.getDefaultErrorStateView(
          context,
          colorPalette,
          typography,
          spacing,
          value.loadMoreElements,
          errorStateTextStyle: groupMemberStyle.errorStateTextStyle,
          errorStateSubtitleStyle: groupMemberStyle.errorStateSubtitleStyle,
          buttonBackgroundColor: groupMemberStyle.retryButtonBackgroundColor,
          buttonBorderRadius: groupMemberStyle.retryButtonBorderRadius,
          buttonBorderSide: groupMemberStyle.retryButtonBorder,
          buttonTextColor: groupMemberStyle.retryButtonTextColor,
          buttonTextStyle: groupMemberStyle.retryButtonTextStyle,
        );
      }
    } else if (value.isLoading == true && (value.list.isEmpty)) {
      return _getLoadingIndicator(context, colorPalette, typography, spacing);
    } else if (value.list.isEmpty) {
      //----------- empty list widget-----------
      return _getNoUserIndicator(
          context, groupMemberStyle, colorPalette, typography, spacing);
    } else {
      List<GlobalKey> tileKeys =
          List.generate(value.list.length, (index) => GlobalKey());

      return ListView.builder(
        controller: controller,
        itemCount:
            value.hasMoreItems ? value.list.length + 1 : value.list.length,
        itemBuilder: (context, index) {
          if (index >= value.list.length) {
            value.loadMoreElements();
            return Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color:
                      groupMemberStyle.loadingIconColor ?? colorPalette.primary,
                ),
              ),
            );
          }

          return SizedBox(
            key: tileKeys[index],
            child: getListItem(
                value.list[index],
                value,
                context,
                tileKeys[index],
                groupMemberStyle,
                colorPalette,
                typography,
                spacing),
          );
        },
      );
    }
  }

  Widget _getTail(
      GroupMember groupMember,
      CometChatGroupMembersController controller,
      CometChatGroupMembersStyle groupMembersStyle,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    Color? backgroundColor;
    BoxBorder? border;
    String scope = groupMember.scope ?? GroupMemberScope.participant;
    Color? textColor;
    TextStyle? textStyle;

    if (groupMember.uid == controller.group.owner) {
      scope = GroupMemberScope.owner;
      backgroundColor = groupMembersStyle.ownerMemberScopeBackgroundColor ??
          colorPalette.primary;
      textColor = groupMembersStyle.ownerMemberScopeTextColor ??
          groupMembersStyle.ownerMemberScopeTextStyle?.color ??
          colorPalette.white;
      border = groupMembersStyle.ownerMemberScopeBorder;
      textStyle = groupMembersStyle.ownerMemberScopeTextStyle;
    } else if (scope == GroupMemberScope.admin) {
      backgroundColor = groupMembersStyle.adminMemberScopeBackgroundColor ??
          colorPalette.extendedPrimary100;
      border = groupMembersStyle.adminMemberScopeBorder ??
          Border.all(
              color: colorPalette.borderHighlight ?? Colors.transparent,
              width: 1);
      textColor = groupMembersStyle.adminMemberScopeTextColor ??
          groupMembersStyle.adminMemberScopeTextStyle?.color ??
          colorPalette.textHighlight;
      textStyle = groupMembersStyle.adminMemberScopeTextStyle;
    } else if (scope == GroupMemberScope.moderator) {
      backgroundColor = groupMembersStyle.moderatorMemberScopeBackgroundColor ??
          colorPalette.extendedPrimary100;
      textColor = groupMembersStyle.moderatorMemberScopeTextColor ??
          groupMembersStyle.moderatorMemberScopeTextStyle?.color ??
          colorPalette.textHighlight;
      border = groupMembersStyle.moderatorMemberScopeBorder;
      textStyle = groupMembersStyle.moderatorMemberScopeTextStyle;
    } else {
      return const SizedBox();
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
          horizontal: spacing.padding3 ?? 0, vertical: spacing.padding1 ?? 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: BorderRadius.circular(spacing.radiusMax ?? 0),
      ),
      child: Text(
        scope.capitalizeFirst ?? "",
        style: TextStyle(
                fontSize: typography.caption1?.regular?.fontSize,
                fontWeight: typography.caption1?.regular?.fontWeight,
                color: textColor)
            .merge(textStyle)
            .copyWith(color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final groupMemberStyle =
        CometChatThemeHelper.getTheme<CometChatGroupMembersStyle>(
                context: context, defaultTheme: CometChatGroupMembersStyle.of)
            .merge(style);
    final confirmDialogStyle =
        CometChatThemeHelper.getTheme<CometChatConfirmDialogStyle>(
                context: context, defaultTheme: CometChatConfirmDialogStyle.of)
            .merge(groupMemberStyle.confirmDialogStyle);
    final changeScopeStyle =
        CometChatThemeHelper.getTheme<CometChatChangeScopeStyle>(
                context: context, defaultTheme: CometChatChangeScopeStyle.of)
            .merge(groupMemberStyle.changeScopeStyle);
    final groupMembersController = Get.put(
        CometChatGroupMembersController(
          groupMembersBuilderProtocol: groupMembersProtocol ??
              UIGroupMembersBuilder(
                groupMembersRequestBuilder ??
                    GroupMembersRequestBuilder(group.guid)
                  ..searchKeyword = searchKeyword,
              ),
          mode: selectionMode,
          group: group,
          onError: onError,
          onEmpty: onEmpty,
          onLoad: onLoad,
          confirmDialogStyle: confirmDialogStyle,
          changeScopeStyle: changeScopeStyle,
          userStatusVisibility: usersStatusVisibility,
          hideBanMemberOption: hideBanMemberOption,
          hideKickMemberOption: hideKickMemberOption,
          hideScopeChangeOption: hideScopeChangeOption,
        ),
        tag: controllerTag);

    if (stateCallBack != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => stateCallBack!(groupMembersController));
    }

    return CometChatListBase(
        titleSpacing: showBackButton ? 0 : 16,
        titleView: GetBuilder<CometChatGroupMembersController>(
            global: false,
            init: groupMembersController,
            tag: controllerTag,
            builder: (CometChatGroupMembersController value) => Text(
                  value.selectionMap.isNotEmpty
                      ? "${value.selectionMap.length}"
                      : cc.Translations.of(context).members,
                  style: TextStyle(
                    color: colorPalette.textPrimary,
                    fontSize: typography.heading1?.bold?.fontSize,
                    fontWeight: typography.heading1?.bold?.fontWeight,
                    fontFamily: typography.heading1?.bold?.fontFamily,
                  ).merge(groupMemberStyle.titleStyle),
                )),
        hideSearch: hideSearch,
        hideAppBar: hideAppbar ?? false,
        backIcon: GetBuilder<CometChatGroupMembersController>(
          init: groupMembersController,
          global: false,
          tag: controllerTag,
          builder: (controller) => controller.selectionMap.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clearSelection();
                    _isSelectionOn.value = false;
                  },
                  icon: Icon(
                    Icons.clear,
                    color: colorPalette.iconPrimary,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                )
              : (backButton ??
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: groupMemberStyle.backIconColor ??
                          colorPalette.iconPrimary,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                  )),
        ),
        onBack: onBack,
        placeholder: searchPlaceholder,
        searchText: searchKeyword,
        showBackButton: showBackButton,
        searchBoxIcon: searchBoxIcon,
        onSearch: groupMembersController.onSearch,
        menuOptions: [
          if (appBarOptions != null && appBarOptions!.isNotEmpty)
            ...appBarOptions!,
          Obx(() => getSelectionWidget(
              groupMembersController, groupMemberStyle, colorPalette)),
        ],
        searchPadding: EdgeInsets.symmetric(
          horizontal: spacing.padding4 ?? 0,
          vertical: spacing.padding3 ?? 0,
        ),
        searchContentPadding: EdgeInsets.symmetric(
          horizontal: spacing.padding3 ?? 0,
          vertical: spacing.padding2 ?? 0,
        ),
        searchBoxHeight: 40,
        style: ListBaseStyle(
          background:
              groupMemberStyle.backgroundColor ?? colorPalette.background1,
          titleStyle: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ).merge(groupMemberStyle.titleStyle),
          height: height,
          width: width,
          backIconTint: groupMemberStyle.backIconColor,
          searchIconTint:
              groupMemberStyle.searchIconColor ?? colorPalette.iconSecondary,
          border: groupMemberStyle.border,
          borderRadius: groupMemberStyle.borderRadius,
          searchTextStyle: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          ).merge(groupMemberStyle.searchTextStyle),
          searchPlaceholderStyle: TextStyle(
            color: colorPalette.textTertiary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          ).merge(groupMemberStyle.searchPlaceholderStyle),
          searchTextFieldRadius: groupMemberStyle.searchBorderRadius,
          searchBoxBackground:
              groupMemberStyle.searchBackground ?? colorPalette.background3,
          appBarShape: Border(
            bottom: BorderSide(
              color: groupMemberStyle.separatorColor ??
                  colorPalette.borderLight ??
                  Colors.transparent,
              width: groupMemberStyle.separatorHeight ?? 1,
            ),
          ),
        ),
        container: GetBuilder<CometChatGroupMembersController>(
            init: groupMembersController,
            global: false,
            tag: controllerTag,
            builder: (CometChatGroupMembersController value) => _getList(value,
                context, groupMemberStyle, colorPalette, typography, spacing)));
  }

  // Function to show pop-up menu on long press
  void showPopupMenu(
    BuildContext context,
    List<CometChatOption> options,
    CometChatGroupMembersStyle groupMemberStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    GlobalKey widgetKey,
    GroupMember member,
  ) {
    if (options.isEmpty) {
      return;
    }
    RelativeRect? position =
        WidgetPositionUtil.getWidgetPosition(context, widgetKey);
    showMenu(
      context: context,
      position: position ?? const RelativeRect.fromLTRB(0, 0, 0, 0),
      menuPadding: EdgeInsets.zero,
      color:
          groupMemberStyle.optionsBackgroundColor ?? colorPalette.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
        side: BorderSide(
          color: colorPalette.borderLight ?? Colors.transparent,
          width: 1,
        ),
      ),
      shadowColor: colorPalette.transparent,
      elevation: 8,
      items: options.map((CometChatOption option) {
        return CustomPopupMenuItem<CometChatOption>(
          value: option,
          child: GetMenuView(
            option: option,
            textStyle: groupMemberStyle.optionsTextStyle,
            iconTint: groupMemberStyle.optionsIconColor ?? option.iconTint,
          ),
        );
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        selectedOption.onClick!();
      }
    });
  }

  Widget _getNoUserIndicator(
      BuildContext context,
      CometChatGroupMembersStyle style,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (emptyStateView != null) {
      return Center(child: emptyStateView!(context));
    } else {
      return UIStateUtils.getDefaultEmptyStateView(
        context,
        colorPalette,
        typography,
        spacing,
        icon: Image.asset(
          AssetConstants(CometChatThemeHelper.getBrightness(context))
              .emptyUserList,
          package: UIConstants.packageName,
          width: 120,
          height: 120,
        ),
        emptyStateText: cc.Translations.of(context).usersUnavailable,
        emptyStateTextStyle: style.emptyStateTextStyle,
        emptyStateTextColor: style.emptyStateTextColor,
        emptyStateSubtitle: cc.Translations.of(context).usersUnavailableMessage,
        emptyStateSubtitleStyle: style.emptyStateSubtitleTextStyle,
        emptyStateSubtitleColor: style.emptyStateSubtitleTextColor,
      );
    }
  }

  Widget getSelectionWidget(CometChatGroupMembersController memberController,
      CometChatGroupMembersStyle style, CometChatColorPalette colorPalette) {
    if (_isSelectionOn.value) {
      return IconButton(
        onPressed: () {
          List<GroupMember>? member = memberController.getSelectedList();
          if (onSelection != null) {
            onSelection!(member);
          }
        },
        icon: submitIcon ??
            Icon(
              Icons.check,
              color: style.submitIconColor ?? colorPalette.iconPrimary,
              size: 24,
            ),
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }
}
