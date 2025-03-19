import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

///[CometChatGroups] is a component that displays a list of groups available in the app with the help of [CometChatListBase] and [CometChatListItem]
///fetched groups are listed down alphabetically and in order of recent activity
///groups are fetched using [GroupsBuilderProtocol] and [GroupsRequestBuilder]
///
/// ```dart
///   CometChatGroups(
///   groupsStyle: GroupsStyle(),
/// );
/// ```
///

class CometChatGroups extends StatefulWidget {
  const CometChatGroups({
    super.key,
    this.groupsProtocol,
    this.subtitleView,
    this.listItemView,
    this.groupsStyle,
    this.scrollController,
    this.searchPlaceholder,
    this.backButton,
    this.showBackButton = true,
    this.searchBoxIcon,
    this.hideSearch = false,
    this.selectionMode,
    this.onSelection,
    this.title,
    this.stateCallBack,
    this.groupsRequestBuilder,
    this.hideError,
    this.loadingStateView,
    this.emptyStateView,
    this.errorStateView,
    this.appBarOptions,
    this.passwordGroupIcon,
    this.privateGroupIcon,
    this.activateSelection,
    this.onBack,
    this.onItemTap,
    this.onItemLongPress,
    this.onError,
    this.submitIcon,
    this.hideAppbar = false,
    this.controllerTag,
    this.height,
    this.width,
    this.searchKeyword,
    this.onLoad,
    this.onEmpty,
    this.groupTypeVisibility = true,
    this.setOptions,
    this.addOptions,
    this.titleView,
    this.leadingView,
    this.trailingView,
  });

  ///[groupsProtocol] set custom groups request builder protocol
  final GroupsBuilderProtocol? groupsProtocol;

  ///[groupsRequestBuilder] custom request builder
  final GroupsRequestBuilder? groupsRequestBuilder;

  ///[subtitleView] to set subtitle for each group
  final Widget? Function(BuildContext context, Group group)? subtitleView;

  ///[listItemView] set custom view for each group
  final Widget Function(Group group)? listItemView;

  ///[groupsStyle] sets style
  final CometChatGroupsStyle? groupsStyle;

  ///[scrollController] sets controller for the list
  final ScrollController? scrollController;

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

  ///[selectionMode] specifies mode groups module is opening in
  final SelectionMode? selectionMode;

  ///[onSelection] function will be performed
  final Function(List<Group>?)? onSelection;

  ///[title] sets title for the list
  final String? title;

  ///[loadingStateView] returns view for loading state
  final WidgetBuilder? loadingStateView;

  ///[emptyStateView] returns view for empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view for error state behind the dialog
  final WidgetBuilder? errorStateView;

  ///[hideError] toggle visibility of error dialog
  final bool? hideError;

  ///[stateCallBack] to access controller functions  from parent pass empty reference of  CometChatGroupsController object
  final Function(CometChatGroupsController controller)? stateCallBack;

  ///[appBarOptions] list of options to be visible in app bar
  final List<Widget> Function(BuildContext context)? appBarOptions;

  ///[passwordGroupIcon] sets icon in status indicator for password group
  final Widget? passwordGroupIcon;

  ///[privateGroupIcon] sets icon in status indicator for private group
  final Widget? privateGroupIcon;

  ///[activateSelection] lets the widget know if groups are allowed to be selected
  final ActivateSelection? activateSelection;

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[onItemTap] callback triggered on tapping a group item
  final Function(BuildContext context, Group group)? onItemTap;

  ///[onItemLongPress] callback triggered on pressing for long on a group item
  final Function(BuildContext context, Group group)? onItemLongPress;

  ///[submitIcon] will override the default submit icon
  final Widget? submitIcon;

  ///[hideAppbar] toggle visibility for app bar
  final bool? hideAppbar;

  ///Group tag to create from , if this is passed its parent responsibility to close this
  final String? controllerTag;

  ///[onError] callback triggered on error
  final OnError? onError;

  ///[height] provides height to the widget
  final double? height;

  ///[width] provides width to the widget
  final double? width;

  ///[searchKeyword] Used to set searchKeyword to fetch initial list with
  final String? searchKeyword;

  ///[onLoad] callback triggered when list is fetched and load
  final OnLoad<Group>? onLoad;

  ///[onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  ///[groupTypeVisibility] Hide the group type icon which is visible on the group icon.
  final bool? groupTypeVisibility;

  ///[setOptions] sets List of actions available on the long press of list item
  final List<CometChatOption>? Function(Group group,
      CometChatGroupsController controller, BuildContext context)? setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(Group group,
      CometChatGroupsController controller, BuildContext context)? addOptions;

  ///[trailingView] to set tailView for each group
  final Widget? Function(BuildContext context, Group group)? trailingView;

  ///[leadingView] to set leading view for each group
  final Widget? Function(BuildContext context, Group group)? leadingView;

  ///[titleView] to set title view for each group
  final Widget? Function(BuildContext context, Group group)? titleView;

  @override
  State<CometChatGroups> createState() => _CometChatGroupsState();
}

class _CometChatGroupsState extends State<CometChatGroups> {
  ///property to be set internally by using passed parameters [groupsProtocol] ,[selectionMode] ,[options]
  ///these are passed to the [CometChatGroupsController] which is responsible for the business logic
  late CometChatGroupsController groupsController;
  late String _currentDateTime;
  final RxBool _isSelectionOn = false.obs;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late CometChatGroupsStyle style;
  late CometChatAvatarStyle avatarStyle;
  late CometChatStatusIndicatorStyle statusIndicatorStyle;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.controllerTag != null &&
        Get.isRegistered<CometChatGroupsController>(
            tag: widget.controllerTag)) {
      groupsController =
          Get.find<CometChatGroupsController>(tag: widget.controllerTag);
    } else {
      groupsController = Get.put<CometChatGroupsController>(
          CometChatGroupsController(
            groupsBuilderProtocol: widget.groupsProtocol ??
                UIGroupsBuilder(
                  widget.groupsRequestBuilder ??
                      RequestBuilderConstants.getDefaultGroupsRequestBuilder()
                    ..searchKeyword = widget.searchKeyword,
                ),
            mode: widget.selectionMode,
            onError: widget.onError,
            onEmpty: widget.onEmpty,
            onLoad: widget.onLoad,
            groupTypeVisibility: widget.groupTypeVisibility
          ),
          tag: widget.controllerTag ??
              "default_tag_for_groups_$_currentDateTime");
    }

    debugPrint(
        "init state is called in cometchat groups default_tag_for_groups_$_currentDateTime");
  }

  @override
  void dispose() {
    if (widget.controllerTag == null) {
      Get.delete<CometChatGroupsController>(
          tag: "default_tag_for_groups_$_currentDateTime");
    }
    debugPrint("dispose is called in cometchat groups");
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatGroupsStyle>(
            context: context, defaultTheme: CometChatGroupsStyle.of)
        .merge(widget.groupsStyle);

    avatarStyle = CometChatThemeHelper.getTheme<CometChatAvatarStyle>(
            context: context, defaultTheme: CometChatAvatarStyle.of)
        .merge(style.avatarStyle);

    statusIndicatorStyle =
        CometChatThemeHelper.getTheme<CometChatStatusIndicatorStyle>(
                context: context,
                defaultTheme: CometChatStatusIndicatorStyle.of)
            .merge(style.statusIndicatorStyle);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateCallBack != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.stateCallBack!(groupsController));
    }

    return ClipRRect(
        borderRadius: style.borderRadius ??
            BorderRadius.circular(
              0,
            ),
        child: CometChatListBase(
          titleSpacing: widget.showBackButton ? 0 : 16,
          titleView: GetBuilder<CometChatGroupsController>(
              tag: widget.controllerTag ??
                  "default_tag_for_groups_$_currentDateTime",
              builder: (CometChatGroupsController value) {
                value.context = context;
                value.colorPalette = colorPalette;
                value.spacing = spacing;
                value.typography = typography;
                return Text(
                  value.selectionMap.isNotEmpty
                      ? "${value.selectionMap.length}"
                      : widget.title ?? cc.Translations.of(context).groups,
                  style: TextStyle(
                    color: colorPalette.textPrimary,
                    fontSize: typography.heading1?.bold?.fontSize,
                    fontWeight: typography.heading1?.bold?.fontWeight,
                    fontFamily: typography.heading1?.bold?.fontFamily,
                  )
                      .merge(style.titleTextStyle)
                      .copyWith(color: style.titleTextColor),
                );
              }),
          hideSearch: widget.hideSearch,
          backIcon: GetBuilder<CometChatGroupsController>(
              tag: widget.controllerTag ??
                  "default_tag_for_groups_$_currentDateTime",
              builder: (CometChatGroupsController value) {
                value.context = context;
                value.colorPalette = colorPalette;
                value.spacing = spacing;
                value.typography = typography;
                return value.selectionMap.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          value.clearSelection();
                          _isSelectionOn.value = false;
                        },
                        icon: Icon(
                          Icons.clear,
                          color: colorPalette.iconPrimary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      )
                    : (widget.backButton ??
                        IconButton(
                          onPressed: widget.onBack,
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorPalette.iconPrimary,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ));
              }),
          onBack: widget.onBack,
          placeholder: widget.searchPlaceholder,
          showBackButton: widget.showBackButton,
          searchBoxIcon: widget.searchBoxIcon,
          onSearch: groupsController.onSearch,
          hideAppBar: widget.hideAppbar,
          searchText: widget.searchKeyword,
          searchPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 0,
            vertical: spacing.padding3 ?? 0,
          ),
          searchContentPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding3 ?? 0,
            vertical: spacing.padding2 ?? 0,
          ),
          searchBoxHeight: 40,
          menuOptions: [
            if (widget.appBarOptions != null) ...widget.appBarOptions!(context),
            Obx(
              () => getSubmitWidget(groupsController),
            )
          ],
          style: ListBaseStyle(
            width: widget.width,
            height: widget.height,
            background: style.backgroundColor ?? colorPalette.background1,
            titleStyle: TextStyle(
              color: style.titleTextColor ?? colorPalette.textPrimary,
              fontSize: typography.heading1?.bold?.fontSize,
              fontWeight: typography.heading1?.bold?.fontWeight,
              fontFamily: typography.heading1?.bold?.fontFamily,
            ).merge(style.titleTextStyle).copyWith(
                  color: style.titleTextColor,
                ),
            backIconTint: style.backIconColor ?? colorPalette.iconPrimary,
            searchIconTint: style.searchIconColor ?? colorPalette.iconSecondary,
            border: style.border,
            borderRadius: style.borderRadius,
            searchTextStyle: TextStyle(
              color: style.searchInputTextColor ?? colorPalette.textPrimary,
              fontSize: typography.heading4?.regular?.fontSize,
              fontWeight: typography.heading4?.regular?.fontWeight,
              fontFamily: typography.heading4?.regular?.fontFamily,
            ).merge(style.searchInputTextStyle).copyWith(
                  color: style.searchInputTextColor,
                ),
            searchPlaceholderStyle: TextStyle(
              color:
                  style.searchPlaceHolderTextColor ?? colorPalette.textTertiary,
              fontSize: typography.heading4?.regular?.fontSize,
              fontWeight: typography.heading4?.regular?.fontWeight,
              fontFamily: typography.heading4?.regular?.fontFamily,
            ).merge(style.searchPlaceHolderTextStyle).copyWith(
                  color: style.searchPlaceHolderTextColor,
                ),
            searchBoxBackground:
                style.searchBackgroundColor ?? colorPalette.background3,
            borderSide: style.searchBorder,
            searchTextFieldRadius: style.searchBorderRadius ??
                BorderRadius.circular(
                  spacing.radiusMax ?? 0,
                ),
            appBarShape: Border(
              bottom: BorderSide(
                color: style.separatorColor ??
                    colorPalette.borderLight ??
                    Colors.transparent,
                width: style.separatorHeight ?? 1,
              ),
            ),
          ),
          container: GetBuilder<CometChatGroupsController>(
            tag: widget.controllerTag ??
                "default_tag_for_groups_$_currentDateTime",
            builder: (CometChatGroupsController value) {
              value.context = context;
              value.colorPalette = colorPalette;
              value.spacing = spacing;
              value.typography = typography;
              return _getList(context, value);
            },
          ),
        ));
  }

  Widget getDefaultItem(Group group, CometChatGroupsController controller,
      int index, BuildContext context, GlobalKey key) {
    Widget? subtitle;
    Widget? leadingView;
    Widget? titleView;
    Widget? tail;

    StatusIndicatorUtils statusIndicatorUtils =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
      context: context,
      group: group,
      privateGroupIconBackground: style.privateGroupIconBackground,
      protectedGroupIconBackground: style.protectedGroupIconBackground,
      privateGroupIcon: widget.privateGroupIcon,
      protectedGroupIcon: widget.passwordGroupIcon,
      isSelected: false,
      groupTypeVisibility: controller.hideGroupIconVisibility(group),
    );

    if (widget.subtitleView != null) {
      subtitle = widget.subtitleView!(context, group);
    } else {
      subtitle = Text(
        "${group.membersCount} ${cc.Translations.of(context).members}",
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
          color: style.itemSubtitleTextColor ?? colorPalette.textSecondary,
        )
            .merge(
              style.itemSubtitleTextStyle,
            )
            .copyWith(
              color: style.itemSubtitleTextColor,
            ),
      );
    }

    if (widget.trailingView != null) {
      tail = widget.trailingView!(context, group);
    }

    if (widget.titleView != null) {
      titleView = widget.titleView!(context, group);
    }

    if (widget.leadingView != null) {
      leadingView = widget.leadingView!(context, group);
    }

    Color? backgroundColor = statusIndicatorUtils.statusIndicatorColor;
    Widget? icon = statusIndicatorUtils.icon;

    return Container(
      decoration: BoxDecoration(
        color: (controller.selectionMap[group.guid] != null)
            ? (style.listItemSelectedBackgroundColor ??
                colorPalette.background4)
            : colorPalette.transparent,
      ),
      child: GestureDetector(
        onLongPress: () {
          if (widget.activateSelection == ActivateSelection.onLongClick &&
              controller.selectionMap.isEmpty &&
              !(widget.selectionMode == null ||
                  widget.selectionMode == SelectionMode.none)) {
            controller.onTap(group);

            _isSelectionOn.value = true;
          } else if (widget.onItemLongPress != null) {
            widget.onItemLongPress!(context, group);
          } else {
            List<CometChatOption>? options;

            if (widget.setOptions != null) {
              options = widget.setOptions!(
                group,
                controller,
                context,
              );
            } else {
              if (widget.addOptions != null) {
                options = widget.addOptions!(
                  group,
                  controller,
                  context,
                );
              }
            }
            controller.showPopupMenu(
              context,
              options ?? [],
              key,
            );
          }
        },
        onTap: () {
          if (widget.activateSelection == ActivateSelection.onClick ||
              (widget.activateSelection == ActivateSelection.onLongClick &&
                      controller.selectionMap.isNotEmpty) &&
                  !(widget.selectionMode == null ||
                      widget.selectionMode == SelectionMode.none)) {
            controller.onTap(group);
            if (controller.selectionMap.isEmpty) {
              _isSelectionOn.value = false;
            } else if (widget.activateSelection == ActivateSelection.onClick &&
                controller.selectionMap.isNotEmpty &&
                _isSelectionOn.value == false) {
              _isSelectionOn.value = true;
            }
          }
          else if (widget.onItemTap != null) {
            widget.onItemTap!(context, group);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            (controller.selectionMap.isNotEmpty)
                ? Checkbox(
                    fillColor: (controller.selectionMap[group.guid] != null)
                        ? WidgetStateProperty.all(
                            style.checkBoxCheckedBackgroundColor ??
                                colorPalette.iconHighlight)
                        : WidgetStateProperty.all(
                            style.checkBoxBackgroundColor ??
                                colorPalette.transparent),
                    value: controller.selectionMap[group.guid] != null,
                    onChanged: (value) {
                      if (widget.activateSelection ==
                              ActivateSelection.onClick ||
                          (widget.activateSelection ==
                                      ActivateSelection.onLongClick &&
                                  controller.selectionMap.isNotEmpty) &&
                              !(widget.selectionMode == null ||
                                  widget.selectionMode == SelectionMode.none)) {
                        controller.onTap(group);
                        if (controller.selectionMap.isEmpty) {
                          _isSelectionOn.value = false;
                        } else if (widget.activateSelection ==
                                ActivateSelection.onClick &&
                            controller.selectionMap.isNotEmpty &&
                            _isSelectionOn.value == false) {
                          _isSelectionOn.value = true;
                        }
                      }
                    },
                    activeColor: style.checkBoxCheckedBackgroundColor ??
                        colorPalette.iconHighlight,
                    shape: RoundedRectangleBorder(
                      borderRadius: style.checkBoxBorderRadius ??
                          BorderRadius.circular(
                            spacing.radius1 ?? 4,
                          ),
                    ),
                    checkColor:
                        style.checkboxSelectedIconColor ?? colorPalette.white,
                    side: style.checkBoxBorder ??
                        BorderSide(
                          color:
                              colorPalette.borderDefault ?? Colors.transparent,
                          width: 1.25,
                          style: BorderStyle.solid,
                        ),
                  )
                : const SizedBox(),
            Expanded(
              child: CometChatListItem(
                id: group.guid,
                avatarName: group.name.removeTabsAndLineBreaks(),
                avatarURL: group.icon,
                avatarHeight: 40,
                avatarWidth: 40,
                title: group.name.removeTabsAndLineBreaks(),
                key: UniqueKey(),
                subtitleView: subtitle,
                avatarStyle: avatarStyle,
                statusIndicatorColor: backgroundColor,
                statusIndicatorIcon: icon,
                statusIndicatorStyle: statusIndicatorStyle,
                style: ListItemStyle(
                  background: (controller.selectionMap[group.guid] != null)
                      ? (style.listItemSelectedBackgroundColor ??
                          colorPalette.background4)
                      : colorPalette.transparent,
                  titleStyle: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: typography.heading4?.medium?.fontSize,
                    fontWeight: typography.heading4?.medium?.fontWeight,
                    fontFamily: typography.heading4?.medium?.fontFamily,
                    color: style.itemTitleTextColor ?? colorPalette.textPrimary,
                  )
                      .merge(
                        style.itemTitleTextStyle,
                      )
                      .copyWith(
                        color: style.itemTitleTextColor,
                      ),
                  padding: EdgeInsets.only(
                    left: (controller.selectionMap.isNotEmpty)
                        ? 0
                        : spacing.padding4 ?? 0,
                    right: spacing.padding4 ?? 0,
                    top: spacing.padding3 ?? 0,
                    bottom: spacing.padding3 ?? 0,
                  ),
                ),
                hideSeparator: true,
                leadingStateView: leadingView,
                titleView: titleView,
                tailView: tail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getListItem(Group group, CometChatGroupsController controller,
      int index, BuildContext context, GlobalKey key) {
    if (widget.listItemView != null) {
      return widget.listItemView!(group);
    } else {
      return getDefaultItem(group, controller, index, context, key);
    }
  }

  // Loading View
  Widget _getLoadingIndicator(BuildContext context) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer bar
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
                      const SizedBox(height: 8.0),
                      // Subtitle shimmer bar
                      Container(
                        height: 12.0,
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
                ],
              ),
            );
          },
        ),
      );
    }
  }

  // No Group Indicator
  Widget _getNoGroupIndicator(BuildContext context) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetConstants(CometChatThemeHelper.getBrightness(context))
                  .emptyGroupList,
              package: UIConstants.packageName,
              width: 150,
              height: 150,
            ),
            Text(
              "No Groups Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.emptyStateTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              )
                  .merge(style.emptyStateTextStyle)
                  .copyWith(color: style.emptyStateTextColor),
            ),
            Text(
              "Create or join groups to see them listed here \n and start collaborating.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.emptyStateSubTitleTextColor ??
                    colorPalette.textSecondary,
                fontSize: typography.heading3?.regular?.fontSize,
                fontWeight: typography.heading3?.regular?.fontWeight,
                fontFamily: typography.heading3?.regular?.fontFamily,
              )
                  .merge(
                    style.emptyStateSubTitleTextStyle,
                  )
                  .copyWith(
                    color: style.emptyStateSubTitleTextColor,
                  ),
            ),
          ],
        ),
      );
    }
  }

  Widget _showErrorView(
    BuildContext context,
    CometChatGroupsController controller,
  ) {
    return UIStateUtils.getDefaultErrorStateView(
      context,
      colorPalette,
      typography,
      spacing,
      () {
        controller.retryGroups();
      },
      errorStateTextColor: style.errorStateTextColor,
      errorStateTextStyle: style.errorStateTextStyle,
      errorStateSubtitleColor: style.errorStateSubTitleTextColor,
      errorStateSubtitleStyle: style.errorStateSubTitleTextStyle,
      buttonBackgroundColor: style.retryButtonBackgroundColor,
      buttonBorderRadius: style.retryButtonBorderRadius,
      buttonBorderSide: style.retryButtonBorder,
      buttonTextColor: style.retryButtonTextColor,
      buttonTextStyle: style.retryButtonTextStyle,
    );
  }

  Widget _showError(
    CometChatGroupsController controller,
    context,
  ) {
    if (widget.hideError == true) return const SizedBox();
    return _showErrorView(context, controller);
  }

  Widget _getList(BuildContext context, CometChatGroupsController value) {
    if (value.hasError == true) {
      if (widget.errorStateView != null) {
        return widget.errorStateView!(context);
      }

      return _showError(value, context);
    } else if (value.isLoading == true && (value.list.isEmpty)) {
      return _getLoadingIndicator(context);
    } else if (value.list.isEmpty) {
      //----------- empty list widget-----------
      return _getNoGroupIndicator(context);
    } else {
      List<GlobalKey> tileKeys =
          List.generate(value.list.length, (index) => GlobalKey());
      return ListView.builder(
        controller: widget.scrollController,
        itemCount:
            value.hasMoreItems ? value.list.length + 1 : value.list.length,
        itemBuilder: (context, index) {
          if (index >= value.list.length) {
            value.loadMoreElements();
            return _getLoadingIndicator(context);
          }

          return SizedBox(
            key: tileKeys[index],
            child: getListItem(
              value.list[index],
              value,
              index,
              context,
              tileKeys[index],
            ),
          );
        },
      );
    }
  }

  Widget getSubmitWidget(CometChatGroupsController groupsController) {
    if (_isSelectionOn.value) {
      return IconButton(
        onPressed: () {
          List<Group>? groups = groupsController.getSelectedList();
          if (widget.onSelection != null) {
            widget.onSelection!(groups);
          }
        },
        icon: widget.submitIcon ??
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
