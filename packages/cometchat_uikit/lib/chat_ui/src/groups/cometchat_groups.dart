import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;
import 'bloc/bloc.dart';

/// [CometChatGroups] is a component that displays a list of groups available in the app
/// using Clean Architecture with BLoC pattern.
///
/// Fetched groups are listed down alphabetically and in order of recent activity.
/// Groups are fetched using [GroupsBloc] which internally uses [GroupsRepository].
///
/// This widget supports:
/// - External BLoC injection via [groupsBloc] parameter (Requirement 9.2)
/// - All existing constructor parameters for backward compatibility (Requirement 9.1)
/// - BlocProvider to provide GroupsBloc to child widgets (Requirement 5.1)
///
/// ```dart
/// CometChatGroups(
///   groupsStyle: CometChatGroupsStyle(),
///   onItemTap: (context, group) => navigateToGroup(group),
/// );
/// ```
class CometChatGroups extends StatefulWidget {
  const CometChatGroups({
    super.key,
    this.groupsBloc,
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

  /// [groupsBloc] Optional external GroupsBloc instance.
  /// If provided, this bloc will be used instead of creating a new one internally.
  /// This allows for custom bloc implementations with overridden hooks.
  /// Requirement: 9.2
  final GroupsBloc? groupsBloc;

  /// [groupsProtocol] set custom groups request builder protocol
  /// @deprecated Use groupsBloc for custom implementations
  final GroupsBuilderProtocol? groupsProtocol;

  /// [groupsRequestBuilder] custom request builder
  /// @deprecated Use groupsBloc for custom implementations
  final GroupsRequestBuilder? groupsRequestBuilder;

  /// [subtitleView] to set subtitle for each group
  final Widget? Function(BuildContext context, Group group)? subtitleView;

  /// [listItemView] set custom view for each group
  final Widget Function(Group group)? listItemView;

  /// [groupsStyle] sets style
  final CometChatGroupsStyle? groupsStyle;

  /// [scrollController] sets controller for the list
  final ScrollController? scrollController;

  /// [searchPlaceholder] placeholder text of search input
  final String? searchPlaceholder;

  /// [backButton] back button
  final Widget? backButton;

  /// [showBackButton] switch on/off back button
  final bool showBackButton;

  /// [searchBoxIcon] search icon
  final Widget? searchBoxIcon;

  /// [hideSearch] switch on/ff search input
  final bool hideSearch;

  /// [selectionMode] specifies mode groups module is opening in
  final SelectionMode? selectionMode;

  /// [onSelection] function will be performed
  final Function(List<Group>?)? onSelection;

  /// [title] sets title for the list
  final String? title;

  /// [loadingStateView] returns view for loading state
  final WidgetBuilder? loadingStateView;

  /// [emptyStateView] returns view for empty state
  final WidgetBuilder? emptyStateView;

  /// [errorStateView] returns view for error state behind the dialog
  final WidgetBuilder? errorStateView;

  /// [hideError] toggle visibility of error dialog
  final bool? hideError;

  /// [appBarOptions] list of options to be visible in app bar
  final List<Widget> Function(BuildContext context)? appBarOptions;

  /// [passwordGroupIcon] sets icon in status indicator for password group
  final Widget? passwordGroupIcon;

  /// [privateGroupIcon] sets icon in status indicator for private group
  final Widget? privateGroupIcon;

  /// [activateSelection] lets the widget know if groups are allowed to be selected
  final ActivateSelection? activateSelection;

  /// [onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  /// [onItemTap] callback triggered on tapping a group item
  final Function(BuildContext context, Group group)? onItemTap;

  /// [onItemLongPress] callback triggered on pressing for long on a group item
  final Function(BuildContext context, Group group)? onItemLongPress;

  /// [submitIcon] will override the default submit icon
  final Widget? submitIcon;

  /// [hideAppbar] toggle visibility for app bar
  final bool? hideAppbar;

  /// Group tag to create from, if this is passed its parent responsibility to close this
  /// @deprecated Use groupsBloc parameter for external bloc injection
  final String? controllerTag;

  /// [onError] callback triggered on error
  final OnError? onError;

  /// [height] provides height to the widget
  final double? height;

  /// [width] provides width to the widget
  final double? width;

  /// [searchKeyword] Used to set searchKeyword to fetch initial list with
  final String? searchKeyword;

  /// [onLoad] callback triggered when list is fetched and load
  final OnLoad<Group>? onLoad;

  /// [onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  /// [groupTypeVisibility] Hide the group type icon which is visible on the group icon.
  final bool? groupTypeVisibility;

  /// [setOptions] sets List of actions available on the long press of list item
  final List<CometChatOption>? Function(
      Group group, GroupsBloc bloc, BuildContext context)? setOptions;

  /// [addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(
      Group group, GroupsBloc bloc, BuildContext context)? addOptions;

  /// [trailingView] to set tailView for each group
  final Widget? Function(BuildContext context, Group group)? trailingView;

  /// [leadingView] to set leading view for each group
  final Widget? Function(BuildContext context, Group group)? leadingView;

  /// [titleView] to set title view for each group
  final Widget? Function(BuildContext context, Group group)? titleView;

  @override
  State<CometChatGroups> createState() => _CometChatGroupsState();
}

class _CometChatGroupsState extends State<CometChatGroups>
    with AutomaticKeepAliveClientMixin {
  /// BLoC to manage groups state
  late GroupsBloc groupsBloc;

  /// Track if bloc is external (should not be closed by this widget)
  bool _isExternalBloc = false;

  /// Flag to track if theme has been initialized
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;
  @override
  bool get wantKeepAlive => true;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late CometChatGroupsStyle style;
  late CometChatAvatarStyle avatarStyle;
  late CometChatStatusIndicatorStyle statusIndicatorStyle;

  @override
  void initState() {
    super.initState();

    // Use external bloc if provided, otherwise create a new one (Requirement 9.2)
    if (widget.groupsBloc != null) {
      groupsBloc = widget.groupsBloc!;
      _isExternalBloc = true;
    } else {
      // Initialize service locator if not already initialized
      _initializeServiceLocator();

      // Create BLoC with dependencies from service locator
      groupsBloc = GroupsBloc();
      _isExternalBloc = false;
    }

    // Dispatch LoadGroups event on init (Requirement 5.1)
    groupsBloc.add(LoadGroups(searchKeyword: widget.searchKeyword));
  }

  /// Initialize service locator if not already initialized
  void _initializeServiceLocator() {
    if (!GroupsServiceLocator.instance.isInitialized) {
      GroupsServiceLocator.instance.setup();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;

    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);

    style = CometChatThemeHelper.getTheme<CometChatGroupsStyle>(
      context: context,
      defaultTheme: CometChatGroupsStyle.of,
    ).merge(widget.groupsStyle);

    avatarStyle = CometChatThemeHelper.getTheme<CometChatAvatarStyle>(
      context: context,
      defaultTheme: CometChatAvatarStyle.of,
    ).merge(style.avatarStyle);

    statusIndicatorStyle =
        CometChatThemeHelper.getTheme<CometChatStatusIndicatorStyle>(
      context: context,
      defaultTheme: CometChatStatusIndicatorStyle.of,
    ).merge(style.statusIndicatorStyle);
  }

  @override
  void dispose() {
    // Only close the bloc if we created it internally
    if (!_isExternalBloc) {
      groupsBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Required for AutomaticKeepAliveClientMixin
    super.build(context);
    
    // Use BlocProvider to provide GroupsBloc to child widgets (Requirement 5.1)
    return RepaintBoundary(
      child: BlocProvider.value(
        value: groupsBloc,
        child: ClipRRect(
          borderRadius: style.borderRadius ?? BorderRadius.circular(0),
          child: CometChatListBase(
          titleView: _buildTitleView(),
          titleSpacing: widget.showBackButton ? 0 : 16,
          hideSearch: widget.hideSearch,
          backIcon: _buildBackIcon(),
          placeholder: widget.searchPlaceholder,
          showBackButton: widget.showBackButton,
          searchBoxIcon: widget.searchBoxIcon,
          onSearch: (keyword) => groupsBloc.add(SearchGroups(keyword)),
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
            _buildSelectionWidget(),
          ],
          onBack: widget.onBack,
          style: _buildListBaseStyle(),
          container: GroupsList(
            groupsBloc: groupsBloc,
            style: style,
            colorPalette: colorPalette,
            spacing: spacing,
            typography: typography,
            scrollController: widget.scrollController,
            loadingStateView: widget.loadingStateView,
            emptyStateView: widget.emptyStateView,
            errorStateView: widget.errorStateView,
            listItemView: widget.listItemView,
            subtitleView: widget.subtitleView,
            trailingView: widget.trailingView,
            leadingView: widget.leadingView,
            titleView: widget.titleView,
            hideGroupTypeIcon: !(widget.groupTypeVisibility ?? true),
            selectionMode: widget.selectionMode,
            activateSelection: widget.activateSelection,
            onItemTap: widget.onItemTap,
            onItemLongPress: widget.onItemLongPress,
            avatarStyle: avatarStyle,
            statusIndicatorStyle: statusIndicatorStyle,
            privateGroupIcon: widget.privateGroupIcon,
            protectedGroupIcon: widget.passwordGroupIcon,
          ),
        ),
      ),
    ),
    );
  }

  /// Builds the title view for the app bar
  Widget _buildTitleView() {
    return BlocBuilder<GroupsBloc, GroupsState>(
      bloc: groupsBloc,
      builder: (context, state) {
        final selectedCount =
            state is GroupsLoaded ? state.selectedGroups.length : 0;
        return Text(
          selectedCount > 0
              ? "$selectedCount"
              : widget.title ?? cc.Translations.of(context).groups,
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ).merge(style.titleTextStyle).copyWith(color: style.titleTextColor),
        );
      },
    );
  }

  /// Builds the back icon for the app bar
  Widget _buildBackIcon() {
    return BlocBuilder<GroupsBloc, GroupsState>(
      bloc: groupsBloc,
      builder: (context, state) {
        final hasSelection =
            state is GroupsLoaded && state.selectedGroups.isNotEmpty;
        return hasSelection
            ? IconButton(
                onPressed: () => groupsBloc.add(const ClearGroupSelection()),
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
      },
    );
  }

  /// Builds the list base style
  ListBaseStyle _buildListBaseStyle() {
    return ListBaseStyle(
      width: widget.width,
      height: widget.height,
      background: style.backgroundColor ?? colorPalette.background1,
      titleStyle: TextStyle(
        color: style.titleTextColor ?? colorPalette.textPrimary,
        fontSize: typography.heading1?.bold?.fontSize,
        fontWeight: typography.heading1?.bold?.fontWeight,
        fontFamily: typography.heading1?.bold?.fontFamily,
      ).merge(style.titleTextStyle).copyWith(color: style.titleTextColor),
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
        color: style.searchPlaceHolderTextColor ?? colorPalette.textTertiary,
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
          BorderRadius.circular(spacing.radiusMax ?? 0),
      appBarShape: Border(
        bottom: BorderSide(
          color: style.separatorColor ??
              colorPalette.borderLight ??
              Colors.transparent,
          width: style.separatorHeight ?? 1,
        ),
      ),
    );
  }

  /// Builds the selection widget for the app bar
  Widget _buildSelectionWidget() {
    return BlocBuilder<GroupsBloc, GroupsState>(
      bloc: groupsBloc,
      builder: (context, state) {
        if (state is GroupsLoaded && state.selectedGroups.isNotEmpty) {
          return IconButton(
            onPressed: () {
              final selectedGroups = groupsBloc.getSelectedGroups();
              widget.onSelection?.call(selectedGroups);
            },
            icon: widget.submitIcon ??
                Icon(
                  Icons.check,
                  color: style.submitIconColor ?? colorPalette.iconPrimary,
                  size: 24,
                ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
