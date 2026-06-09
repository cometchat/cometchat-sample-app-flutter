import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

///[CometChatConversations] is a component that shows all conversations involving the logged in user with the help of [CometChatListBase] and [CometChatListItem]
///By default, for each conversation that will be listed, the name of the user or group the logged in user is having conversation with will be displayed in the title of every list item,
///the subtitle will contain the last message in that conversation along with its receipt status, the leading view will contain the avatars of the user and groups and
///status indicator will indicate if users are online and icons for indicating a private or password protected group,
///and the trailing view will contain the time of the last message in that conversation and the number of unread messages.
///
///fetched conversations are listed down according to the order of recent activity
///conversations are fetched using [ConversationsBuilderProtocol] and [ConversationsRequestBuilder]
///
/// ```dart
/// CometChatConversations(
///  avatarStyle: CometChatAvatarStyle(),
///  statusIndicatorStyle: CometChatStatusIndicatorStyle(),
///  badgeStyle: CometChatBadgeStyle(),
///  receiptStyle: CometChatMessageReceiptStyle(),
///  appBarOptions: [],
///  hideReceipt: false,
///  protectedGroupIcon: Icon(Icons.lock),
///  privateGroupIcon: Icon(Icons.lock),
///  )
///  ```

class CometChatConversations extends StatefulWidget {
  const CometChatConversations({
    super.key,
    this.conversationsProtocol,
    this.subtitleView,
    this.listItemView,
    this.conversationsStyle = const CometChatConversationsStyle(),
    this.scrollController,
    this.backButton,
    this.showBackButton = false,
    this.selectionMode,
    this.onSelection,
    this.title,
    this.conversationsRequestBuilder,
    this.hideError,
    this.emptyStateView,
    this.errorStateView,
    this.listItemStyle,
    this.trailingView,
    this.appBarOptions,
    this.usersStatusVisibility = true,
    this.receiptsVisibility = true,
    this.protectedGroupIcon,
    this.privateGroupIcon,
    this.readIcon,
    this.deliveredIcon,
    this.sentIcon,
    this.activateSelection,
    this.datePattern,
    this.typingIndicatorText,
    this.onBack,
    this.onItemTap,
    this.onItemLongPress,
    this.hideAppbar = false,
    this.textFormatters,
    this.mentionAllLabel,
    this.mentionAllLabelId,
    this.datePadding,
    this.dateHeight,
    this.dateBackgroundIsTransparent,
    this.dateWidth,
    this.badgeWidth,
    this.badgeHeight,
    this.badgePadding,
    this.statusIndicatorWidth,
    this.statusIndicatorHeight,
    this.statusIndicatorBorderRadius,
    this.avatarMargin,
    this.avatarPadding,
    this.avatarWidth,
    this.avatarHeight,
    this.deleteConversationOptionVisibility = true,
    this.groupTypeVisibility = true,
    this.setOptions,
    this.addOptions,
    this.loadingStateView,
    this.leadingView,
    this.titleView,
    this.controllerTag,
    this.onLoad,
    this.onEmpty,
    this.onError,
    this.customSoundForMessages,
    this.disableSoundForMessages = false,
    this.submitIcon,
    this.dateTimeFormatterCallback,
    this.conversationsBloc,
    this.routeObserver,
    this.hideSearch,
    this.searchReadOnly = false,
    this.onSearchTap,
    this.searchBoxIcon,
    this.searchPadding,
    this.searchContentPadding,
  });

  ///[routeObserver] Optional RouteObserver to detect when this widget is not visible.
  ///When provided, the widget will freeze rebuilds during keyboard animation
  ///when another screen is pushed on top (e.g., messages screen).
  ///This prevents expensive rebuilds caused by MediaQuery changes.
  ///
  ///Usage:
  ///```dart
  ///// In your app, create a global RouteObserver
  ///final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
  ///
  ///// Add it to MaterialApp
  ///MaterialApp(
  ///  navigatorObservers: [routeObserver],
  ///  ...
  ///)
  ///
  ///// Pass it to CometChatConversations
  ///CometChatConversations(
  ///  routeObserver: routeObserver,
  ///  ...
  ///)
  ///```
  final RouteObserver<ModalRoute<void>>? routeObserver;

  ///[conversationsBloc] Optional external ConversationsBloc instance.
  ///If provided, this bloc will be used instead of creating a new one internally.
  ///This allows for custom bloc implementations with overridden hooks.
  final ConversationsBloc? conversationsBloc;

  ///[conversationsProtocol] Request builder protocol to fetch conversations.
  final ConversationsBuilderProtocol? conversationsProtocol;

  ///[conversationsRequestBuilder] Request builder to fetch conversations.
  final ConversationsRequestBuilder? conversationsRequestBuilder;

  ///[subtitleView] to set subtitle for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      subtitleView;

  ///[trailingView] to set tailView for each conversation
  final Widget? Function(Conversation conversation)? trailingView;

  ///[listItemView] set custom view for each conversation
  final Widget Function(Conversation conversation)? listItemView;

  ///[conversationsStyle] sets style
  final CometChatConversationsStyle conversationsStyle;

  ///[scrollController] to handle scrolling behavior.
  final ScrollController? scrollController;

  ///[backButton] back button
  final Widget? backButton;

  ///[showBackButton] switch on/off back button
  final bool showBackButton;

  ///[selectionMode] specifies mode conversations module is opening in
  final SelectionMode? selectionMode;

  ///[onSelection] function will be performed
  final Function(List<Conversation>? list)? onSelection;

  ///[title] sets title for the list
  final String? title;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state
  final WidgetBuilder? errorStateView;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[hideError] toggle visibility of error dialog
  final bool? hideError;

  ///[listItemStyle] style for every list item
  final ListItemStyle? listItemStyle;

  ///[appBarOptions] list of options to be visible in app bar
  final List<Widget>? appBarOptions;

  ///[usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  ///[receiptsVisibility] controls visibility of receipts
  final bool? receiptsVisibility;

  ///[protectedGroupIcon] provides icon in status indicator for protected group
  final Widget? protectedGroupIcon;

  ///[privateGroupIcon] provides icon in status indicator for private group
  final Widget? privateGroupIcon;

  ///[readIcon] provides icon in read receipts if a message is read
  final Widget? readIcon;

  ///[deliveredIcon] provides icon in read receipts if a message is delivered
  final Widget? deliveredIcon;

  ///[sentIcon] provides icon in read receipts if a message is sent
  final Widget? sentIcon;

  ///[activateSelection] lets the widget know if conversations are allowed to be selected
  final ActivateSelection? activateSelection;

  ///[datePattern] is used to generate customDateString for CometChatDate
  final String Function(Conversation conversation)? datePattern;

  ///[typingIndicatorText] if not null is visible instead of default text shown when another user is typing
  final String? typingIndicatorText;

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[onItemTap] callback triggered on tapping a conversation item
  final Function(Conversation conversation)? onItemTap;

  ///[onItemLongPress] callback triggered on pressing for long on a conversation item
  final Function(Conversation conversation)? onItemLongPress;

  ///[hideAppbar] toggle visibility for app bar
  final bool? hideAppbar;

  ///[textFormatters] is a list of text formatters for message bubbles with type text
  final List<CometChatTextFormatter>? textFormatters;

  ///[mentionAllLabel] is a String which is used to set a custom label for @all mentions
  final String? mentionAllLabel;

  ///[mentionAllLabelId] is a String which is used to set a custom label ID for @all mentions
  final String? mentionAllLabelId;

  ///[datePadding] provides padding for [CometChatDate]
  final EdgeInsets? datePadding;

  ///[dateHeight] provides height for [CometChatDate]
  final double? dateHeight;

  ///[dateBackgroundIsTransparent] controls the background of [CometChatDate]
  final bool? dateBackgroundIsTransparent;

  ///[dateWidth] provides width for [CometChatDate]
  final double? dateWidth;

  ///[badgeWidth] provides width for [CometChatBadge]
  final double? badgeWidth;

  ///[badgeHeight] provides height for [CometChatBadge]
  final double? badgeHeight;

  ///[badgePadding] provides padding to the widget
  final EdgeInsetsGeometry? badgePadding;

  ///[avatarWidth] provides width to the widget
  final double? avatarWidth;

  ///[avatarHeight] provides height to the widget
  final double? avatarHeight;

  ///[avatarPadding] provides padding to the widget
  final EdgeInsetsGeometry? avatarPadding;

  ///[avatarMargin] provides margin to the widget
  final EdgeInsetsGeometry? avatarMargin;

  ///[statusIndicatorWidth] provides width to the status indicator
  final double? statusIndicatorWidth;

  ///[statusIndicatorHeight] provides height to the status indicator
  final double? statusIndicatorHeight;

  ///[statusIndicatorBorderRadius] provides borderRadius to the status indicator
  final BorderRadiusGeometry? statusIndicatorBorderRadius;

  ///[deleteConversationOptionVisibility] controls visibility of delete conversation option
  final bool? deleteConversationOptionVisibility;

  ///[groupTypeVisibility] Hide the group type icon which is visible on the group icon.
  final bool? groupTypeVisibility;

  ///[controllerTag] tag to create from , if this is passed its parent responsibility to close this
  final String? controllerTag;

  ///[submitIcon] will override the default submit icon
  final Widget? submitIcon;

  ///[setOptions] sets List of actions available on the long press of list item
  final List<CometChatOption>? Function(Conversation conversation,
      ConversationsBloc bloc, BuildContext context)? setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(Conversation conversation,
      ConversationsBloc bloc, BuildContext context)? addOptions;

  ///[leadingView] to set leading view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      leadingView;

  ///[titleView] to set title view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      titleView;

  ///[onError] callback triggered when the component encounters an error
  final OnError? onError;

  ///[onLoad] callback triggered when conversations are loaded successfully
  final OnLoad<Conversation>? onLoad;

  ///[onEmpty] callback triggered when the conversations list is empty
  final OnEmpty? onEmpty;

  ///[customSoundForMessages] set custom sound for messages
  final String? customSoundForMessages;

  ///[disableSoundForMessages] disable sound for messages
  final bool? disableSoundForMessages;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  /// [hideSearch] hides the search bar in the app bar
  final bool? hideSearch;

  ///[searchReadOnly] to specify if search box is read only
  final bool searchReadOnly;

  ///[onSearchTap] callback triggered on search box tap
  final GestureTapCallback? onSearchTap;

  ///[searchBoxIcon] search box prefix icon
  final Widget? searchBoxIcon;

  ///[searchPadding] provides padding to the search
  final EdgeInsetsGeometry? searchPadding;

  ///[searchContentPadding] provides padding to the search content
  final EdgeInsetsGeometry? searchContentPadding;

  @override
  State<CometChatConversations> createState() => _CometChatConversationsState();
}

class _CometChatConversationsState extends State<CometChatConversations>
    with AutomaticKeepAliveClientMixin, RouteAware {
  late CometChatConversationsStyle style;
  late CometChatStatusIndicatorStyle statusStyle;
  late CometChatTypingIndicatorStyle typingStyle;
  late CometChatMessageReceiptStyle receiptStyle;
  late CometChatDateStyle datesStyle;
  late CometChatTypography typography;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  late String dateString;

  ///BLoC to manage conversations state
  late ConversationsBloc conversationsBloc;

  /// Track which conversation is showing delete overlay
  String? _conversationShowingDeleteOverlay;

  /// Flag to track if theme has been initialized
  bool _themeInitialized = false;

  /// Track brightness to detect dark mode changes
  Brightness? _cachedBrightness;

  /// Track if this route is currently active (visible)
  /// When false, the widget will use cached content to prevent rebuilds
  bool _isRouteActive = true;

  /// Cached widget to return when route is not active
  /// This prevents expensive rebuilds during keyboard animation
  Widget? _cachedWidget;

  /// Keep state alive when offstage (e.g., in IndexedStack, PageView)
  /// This prevents expensive re-initialization when switching tabs
  @override
  bool get wantKeepAlive => true;

  bool _routeSubscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route changes if routeObserver is provided (only once)
    if (widget.routeObserver != null && !_routeSubscribed) {
      widget.routeObserver!.subscribe(this, ModalRoute.of(context)!);
      _routeSubscribed = true;
    }

    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;
    _cachedWidget = null; // Clear cached widget so it rebuilds with new theme

    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
            context: context, defaultTheme: CometChatConversationsStyle.of)
        .merge(widget.conversationsStyle);
    statusStyle = CometChatThemeHelper.getTheme<CometChatStatusIndicatorStyle>(
            context: context, defaultTheme: CometChatStatusIndicatorStyle.of)
        .merge(style.statusIndicatorStyle);
    typingStyle = CometChatThemeHelper.getTheme<CometChatTypingIndicatorStyle>(
            context: context, defaultTheme: CometChatTypingIndicatorStyle.of)
        .merge(style.typingIndicatorStyle);
    receiptStyle = CometChatThemeHelper.getTheme<CometChatMessageReceiptStyle>(
            context: context, defaultTheme: CometChatMessageReceiptStyle.of)
        .merge(style.receiptStyle);
    datesStyle = CometChatThemeHelper.getTheme<CometChatDateStyle>(
            context: context, defaultTheme: CometChatDateStyle.of)
        .merge(style.dateStyle);
  }

  // RouteAware callbacks - track when this route is visible
  @override
  void didPush() {
    _isRouteActive = true;
  }

  @override
  void didPopNext() {
    // Covering route was popped - this route is now visible again
    _isRouteActive = true;
    _cachedWidget = null; // Clear cache to allow fresh rebuild
  }

  @override
  void didPushNext() {
    // Another route was pushed on top - this route is no longer visible
    _isRouteActive = false;
  }

  @override
  void didPop() {
    _isRouteActive = false;
  }

  @override
  void initState() {
    dateString = DateTime.now().microsecondsSinceEpoch.toString();

    // Use external bloc if provided, otherwise create a new one
    if (widget.conversationsBloc != null) {
      conversationsBloc = widget.conversationsBloc!;
      _isExternalBloc = true;
      // Skip service locator initialization when external bloc is provided
      // The external bloc is responsible for its own dependencies
    } else {
      // Initialize service locator if not already initialized (only for internal bloc)
      _initializeServiceLocator();

      // Create BLoC with dependencies from service locator and configuration options
      conversationsBloc = ConversationsBloc(
        disableSoundForMessages: widget.disableSoundForMessages ?? false,
        customSoundForMessages: widget.customSoundForMessages,
        usersStatusVisibility: widget.usersStatusVisibility ?? true,
        receiptsVisibility: widget.receiptsVisibility ?? true,
        conversationsRequestBuilder: widget.conversationsRequestBuilder,
        conversationsProtocol: widget.conversationsProtocol,
      );
      _isExternalBloc = false;
    }

    // Load conversations
    conversationsBloc.add(const LoadConversations());

    super.initState();
  }

  /// Initialize service locator if not already initialized
  void _initializeServiceLocator() {
    if (!ConversationsServiceLocator.instance.isInitialized) {
      ConversationsServiceLocator.instance.setup();
    }
  }

  /// Track if bloc is external (should not be closed by this widget)
  bool _isExternalBloc = false;

  @override
  void dispose() {
    // Unsubscribe from route observer
    if (widget.routeObserver != null) {
      widget.routeObserver!.unsubscribe(this);
    }
    // Only close the bloc if we created it internally
    if (!_isExternalBloc) {
      conversationsBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Required for AutomaticKeepAliveClientMixin
    super.build(context);

    // When route is not active (another screen on top), return cached widget
    // This prevents expensive rebuilds during keyboard animation on the messages screen
    if (!_isRouteActive && widget.routeObserver != null) {
      if (_cachedWidget != null) {
        return _cachedWidget!;
      }
    }

    // Build the actual widget
    final builtWidget = RepaintBoundary(
      child: BlocProvider.value(
        value: conversationsBloc,
        child: ClipRRect(
          borderRadius: style.borderRadius ?? BorderRadius.circular(0),
          child: CometChatListBase(
            titleView: BlocBuilder<ConversationsBloc, ConversationsState>(
              builder: (context, state) {
                final selectedCount = state is ConversationsLoaded
                    ? state.selectedConversations.length
                    : 0;
                return Text(
                  selectedCount > 0
                      ? "$selectedCount"
                      : widget.title ?? cc.Translations.of(context).chats,
                  style: TextStyle(
                    color: colorPalette.textPrimary,
                    fontSize: typography.heading1?.bold?.fontSize,
                    fontWeight: typography.heading1?.bold?.fontWeight,
                    fontFamily: typography.heading1?.bold?.fontFamily,
                  )
                      .merge(style.titleTextStyle)
                      .copyWith(color: style.titleTextColor),
                );
              },
            ),
            titleSpacing: widget.showBackButton ? 0 : 16,
            hideSearch: widget.hideSearch ?? true,
            searchBoxIcon: widget.searchBoxIcon,
            searchPadding: widget.searchPadding ??
                EdgeInsets.symmetric(
                  horizontal: spacing.padding4 ?? 0,
                  vertical: spacing.padding3 ?? 0,
                ),
            searchContentPadding: widget.searchContentPadding ??
                EdgeInsets.symmetric(
                  horizontal: spacing.padding3 ?? 0,
                  vertical: spacing.padding2 ?? 0,
                ),
            searchBoxHeight: 40,
            onSearchTap: widget.onSearchTap,
            searchReadOnly: widget.searchReadOnly,
            hideAppBar: widget.hideAppbar,
            backIcon: BlocBuilder<ConversationsBloc, ConversationsState>(
              builder: (context, state) {
                final hasSelection = state is ConversationsLoaded &&
                    state.selectedConversations.isNotEmpty;
                return hasSelection
                    ? IconButton(
                        onPressed: () {
                          conversationsBloc
                              .add(const ClearConversationSelection());
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
              },
            ),
            showBackButton: widget.showBackButton,
            onBack: widget.onBack,
            menuOptions: [
              if (widget.appBarOptions != null &&
                  widget.appBarOptions!.isNotEmpty)
                ...widget.appBarOptions!,
              _getSelectionWidget(),
            ],
            style: ListBaseStyle(
              background: style.backgroundColor ?? colorPalette.background1,
              titleStyle: TextStyle(
                color: style.titleTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading1?.bold?.fontSize,
                fontWeight: typography.heading1?.bold?.fontWeight,
                fontFamily: typography.heading1?.bold?.fontFamily,
              )
                  .merge(
                    style.titleTextStyle,
                  )
                  .copyWith(
                    color: style.titleTextColor,
                  ),
              backIconTint: style.backIconColor ?? colorPalette.iconPrimary,
              border: style.border,
              borderRadius: style.borderRadius,
              searchIconTint:
                  style.searchIconColor ?? colorPalette.iconSecondary,
              searchBoxBackground:
                  style.searchBackgroundColor ?? colorPalette.background3,
              borderSide: style.searchBorder ??
                  BorderSide(
                    color: colorPalette.borderLight ?? Colors.transparent,
                    width: 1,
                  ),
              searchTextFieldRadius: style.searchBorderRadius ??
                  BorderRadius.circular(
                    spacing.radiusMax ?? 0,
                  ),
              searchPlaceholderStyle: TextStyle(
                color: style.searchPlaceHolderTextColor ??
                    colorPalette.textTertiary,
                fontSize: typography.heading4?.regular?.fontSize,
                fontWeight: typography.heading4?.regular?.fontWeight,
                fontFamily: typography.heading4?.regular?.fontFamily,
              ).merge(style.searchPlaceHolderTextStyle).copyWith(
                    color: style.searchPlaceHolderTextColor,
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
            container: ConversationsList(
              conversationsBloc: conversationsBloc,
              style: style,
              statusStyle: statusStyle,
              typingStyle: typingStyle,
              receiptStyle: receiptStyle,
              datesStyle: datesStyle,
              colorPalette: colorPalette,
              spacing: spacing,
              typography: typography,
              scrollController: widget.scrollController,
              loadingStateView: widget.loadingStateView,
              emptyStateView: widget.emptyStateView,
              errorStateView: widget.errorStateView,
              hideError: widget.hideError,
              listItemView: widget.listItemView,
              subtitleView: widget.subtitleView,
              trailingView: widget.trailingView,
              leadingView: widget.leadingView,
              titleView: widget.titleView,
              listItemStyle: widget.listItemStyle,
              avatarHeight: widget.avatarHeight,
              avatarWidth: widget.avatarWidth,
              avatarPadding: widget.avatarPadding,
              avatarMargin: widget.avatarMargin,
              statusIndicatorHeight: widget.statusIndicatorHeight,
              statusIndicatorWidth: widget.statusIndicatorWidth,
              statusIndicatorBorderRadius: widget.statusIndicatorBorderRadius,
              privateGroupIcon: widget.privateGroupIcon,
              protectedGroupIcon: widget.protectedGroupIcon,
              usersStatusVisibility: widget.usersStatusVisibility,
              groupTypeVisibility: widget.groupTypeVisibility,
              selectionMode: widget.selectionMode,
              activateSelection: widget.activateSelection,
              onItemTap: _handleItemTapWithDeleteDismiss,
              onItemLongPress:
                  widget.onItemLongPress ?? _handleDefaultLongPress,
              hideThreadIndicator: false,
              receiptsVisibility: widget.receiptsVisibility,
              typingIndicatorText: widget.typingIndicatorText,
              readIcon: widget.readIcon,
              deliveredIcon: widget.deliveredIcon,
              sentIcon: widget.sentIcon,
              textFormatters: widget.textFormatters,
              datePattern: widget.datePattern,
              datePadding: widget.datePadding,
              dateHeight: widget.dateHeight,
              dateWidth: widget.dateWidth,
              dateBackgroundIsTransparent: widget.dateBackgroundIsTransparent,
              badgeWidth: widget.badgeWidth,
              badgeHeight: widget.badgeHeight,
              badgePadding: widget.badgePadding,
              dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
              itemWrapperBuilder:
                  widget.deleteConversationOptionVisibility == true
                      ? _wrapItemWithDeleteOverlay
                      : null,
              onLoad: widget.onLoad,
              onEmpty: widget.onEmpty,
              onError: widget.onError,
            ),
          ),
        ),
      ),
    );

    // Cache the widget for when route becomes inactive
    _cachedWidget = builtWidget;

    return builtWidget;
  }

  /// Returns the selection widget for the app bar.
  Widget _getSelectionWidget() {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        if (state is ConversationsLoaded &&
            state.selectedConversations.isNotEmpty) {
          return IconButton(
            onPressed: () {
              final selectedIds = state.selectedConversations;
              final selectedConversations = state.conversations
                  .where((c) => selectedIds.contains(c.conversationId))
                  .toList();
              if (widget.onSelection != null) {
                widget.onSelection!(selectedConversations);
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
          return const SizedBox(height: 0, width: 0);
        }
      },
    );
  }

  /// Default long press handler that shows delete button overlay on the tile
  void _handleDefaultLongPress(Conversation conversation) {
    if (widget.deleteConversationOptionVisibility != true) {
      return;
    }

    setState(() {
      // Toggle the delete overlay for this conversation
      if (_conversationShowingDeleteOverlay == conversation.conversationId) {
        _conversationShowingDeleteOverlay = null;
      } else {
        _conversationShowingDeleteOverlay = conversation.conversationId;
      }
    });
  }

  /// Intercepts item taps to dismiss delete overlay if one is showing
  void _handleItemTapWithDeleteDismiss(Conversation conversation) {
    if (_conversationShowingDeleteOverlay != null) {
      setState(() {
        _conversationShowingDeleteOverlay = null;
      });
      return;
    }
    if (widget.onItemTap != null) {
      widget.onItemTap!(conversation);
    }
  }

  /// Handle delete button tap from overlay
  void _handleDeleteFromOverlay(Conversation conversation) {
    setState(() {
      _conversationShowingDeleteOverlay = null;
    });
    _showDeleteConfirmationDialog(conversation);
  }

  /// Wraps a conversation list item with a delete overlay when long-pressed.
  Widget _wrapItemWithDeleteOverlay(
      BuildContext context, Conversation conversation, Widget child) {
    final isShowingDelete =
        _conversationShowingDeleteOverlay == conversation.conversationId;

    if (!isShowingDelete) return child;

    return Stack(
      children: [
        ColoredBox(
          color: (colorPalette.error ?? Colors.red).withOpacity(0.08),
          child: child,
        ),
        Positioned(
          right: spacing.padding4 ?? 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _handleDeleteFromOverlay(conversation),
              child: Container(
                width: 120,
                height: 44,
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: colorPalette.background1 ?? Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color:
                          colorPalette.borderLight ?? const Color(0xFFF5F5F5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x07101828),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Color(0x14101828),
                      blurRadius: 16,
                      offset: Offset(0, 12),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/delete_icon.png',
                      package: 'cometchat_chat_uikit',
                      width: 24,
                      height: 24,
                      color: colorPalette.error ?? const Color(0xFFF44649),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cc.Translations.of(context).delete,
                      style: TextStyle(
                        color: colorPalette.error ?? const Color(0xFFF44649),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmationDialog(Conversation conversation) {
    final confirmDialogStyle =
        CometChatThemeHelper.getTheme<CometChatConfirmDialogStyle>(
                context: context, defaultTheme: CometChatConfirmDialogStyle.of)
            .merge(style.deleteConversationDialogStyle);

    CometChatConfirmDialog(
      context: context,
      confirmButtonText: cc.Translations.of(context).delete,
      cancelButtonText: cc.Translations.of(context).cancel,
      icon: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset(
          AssetConstants.deleteIcon,
          package: UIConstants.packageName,
          height: 48,
          width: 48,
          color: confirmDialogStyle.iconColor ?? colorPalette.error,
        ),
      ),
      title: Text(
        cc.Translations.of(context).deleteConversation,
        textAlign: TextAlign.center,
      ),
      messageText: Text(
        cc.Translations.of(context).confirmDeleteConversation,
        textAlign: TextAlign.center,
      ),
      onCancel: (dialogContext) {
        Navigator.of(dialogContext).pop();
      },
      style: CometChatConfirmDialogStyle(
        iconColor: confirmDialogStyle.iconColor ?? colorPalette.error,
        backgroundColor: confirmDialogStyle.backgroundColor,
        shadow: confirmDialogStyle.shadow,
        iconBackgroundColor: confirmDialogStyle.iconBackgroundColor,
        borderRadius: confirmDialogStyle.borderRadius,
        border: confirmDialogStyle.border,
        cancelButtonBackground: confirmDialogStyle.cancelButtonBackground ??
            colorPalette.transparent,
        confirmButtonBackground:
            confirmDialogStyle.confirmButtonBackground ?? colorPalette.error,
        cancelButtonTextColor: confirmDialogStyle.cancelButtonTextColor,
        confirmButtonTextColor: confirmDialogStyle.confirmButtonTextColor,
        messageTextColor: confirmDialogStyle.messageTextColor,
        titleTextColor: confirmDialogStyle.titleTextColor,
        titleTextStyle: TextStyle(
          color: confirmDialogStyle.titleTextColor ?? colorPalette.textPrimary,
          fontSize: typography.heading2?.medium?.fontSize,
          fontWeight: typography.heading2?.medium?.fontWeight,
          fontFamily: typography.heading2?.medium?.fontFamily,
        )
            .merge(
              confirmDialogStyle.titleTextStyle,
            )
            .copyWith(
              color: confirmDialogStyle.titleTextColor,
            ),
        messageTextStyle: TextStyle(
          color:
              confirmDialogStyle.messageTextColor ?? colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        )
            .merge(
              confirmDialogStyle.messageTextStyle,
            )
            .copyWith(
              color: confirmDialogStyle.messageTextColor,
            ),
        confirmButtonTextStyle: TextStyle(
          color:
              confirmDialogStyle.confirmButtonTextColor ?? colorPalette.white,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        )
            .merge(
              confirmDialogStyle.confirmButtonTextStyle,
            )
            .copyWith(
              color: confirmDialogStyle.confirmButtonTextColor,
            ),
        cancelButtonTextStyle: TextStyle(
          color: confirmDialogStyle.cancelButtonTextColor ??
              colorPalette.textPrimary,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        )
            .merge(
              confirmDialogStyle.cancelButtonTextStyle,
            )
            .copyWith(
              color: confirmDialogStyle.cancelButtonTextColor,
            ),
      ),
      onConfirm: (dialogContext) {
        Navigator.of(dialogContext).pop();
        if (conversation.conversationId != null) {
          conversationsBloc.add(
            DeleteConversation(conversation.conversationId!),
          );
        }
      },
    ).show();
  }
}
