import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  CometChatConversations({
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
  });

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
  final List<CometChatOption>? Function(
      Conversation conversation,
      CometChatConversationsController controller,
      BuildContext context)? setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(
      Conversation conversation,
      CometChatConversationsController controller,
      BuildContext context)? addOptions;

  ///[leadingView] to set leading view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      leadingView;

  ///[titleView] to set title view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      titleView;

  ///[onError] call back when the component encounters an error
  final OnError? onError;

  ///[onError] is a function which will called when conversation is loading.
  final OnLoad<Conversation>? onLoad;

  ///[onError] is a function which will called when list is empty.
  final OnEmpty? onEmpty;

  ///[customSoundForMessages] set custom sound for messages
  final String? customSoundForMessages;

  ///[disableSoundForMessages] disable sound for messages
  final bool? disableSoundForMessages;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  @override
  State<CometChatConversations> createState() => _CometChatConversationsState();
}

class _CometChatConversationsState extends State<CometChatConversations> {
  final RxBool _isSelectionOn = false.obs;

  late CometChatConversationsStyle style;
  late CometChatStatusIndicatorStyle statusStyle;
  late CometChatTypingIndicatorStyle typingStyle;
  late CometChatMessageReceiptStyle receiptStyle;
  late CometChatDateStyle datesStyle;
  late CometChatTypography typography;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  late String tag;
  late String dateString;

  ///property to be set internally by using passed parameters [conversationsProtocol] ,[selectionMode] ,[options]
  ///these are passed to the [CometChatConversationsController] which is responsible for the business logic
  late CometChatConversationsController conversationsController;

  @override
  void didChangeDependencies() {
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
    super.didChangeDependencies();
  }

  @override
  void initState() {
    dateString = DateTime.now().microsecondsSinceEpoch.toString();
    tag = widget.controllerTag ?? "default_tag_for_conversations_$dateString";

    if (widget.controllerTag != null &&
        Get.isRegistered<CometChatConversationsController>(
            tag: widget.controllerTag)) {
      conversationsController =
          Get.find<CometChatConversationsController>(tag: widget.controllerTag);
    } else {
      conversationsController = Get.put<CometChatConversationsController>(
        CometChatConversationsController(
          conversationsBuilderProtocol: widget.conversationsProtocol ??
              UIConversationsBuilder(
                widget.conversationsRequestBuilder ??
                    ConversationsRequestBuilder(),
              ),
          mode: widget.selectionMode,
          disableSoundForMessages: widget.disableSoundForMessages,
          customSoundForMessages: widget.customSoundForMessages,
          usersStatusVisibility: widget.usersStatusVisibility,
          receiptsVisibility: widget.receiptsVisibility,
          onError: widget.onError,
          onEmpty: widget.onEmpty,
          onLoad: widget.onLoad,
          textFormatters: widget.textFormatters,
          mentionsStyle: widget.conversationsStyle.mentionsStyle,
          conversationsStyle: widget.conversationsStyle,
          groupTypeVisibility: widget.groupTypeVisibility,
        ),
        tag: tag,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controllerTag == null) {
      Get.delete<CometChatConversationsController>(tag: tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: style.borderRadius ??
          BorderRadius.circular(
            0,
          ),
      child: CometChatListBase(
        titleView: GetBuilder<CometChatConversationsController>(
            tag: tag,
            builder: (CometChatConversationsController value) => Text(
                  value.selectionMap.isNotEmpty
                      ? "${value.selectionMap.length}"
                      : widget.title ?? cc.Translations.of(context).chats,
                  style: TextStyle(
                    color: colorPalette.textPrimary,
                    fontSize: typography.heading1?.bold?.fontSize,
                    fontWeight: typography.heading1?.bold?.fontWeight,
                    fontFamily: typography.heading1?.bold?.fontFamily,
                  )
                      .merge(style.titleTextStyle)
                      .copyWith(color: style.titleTextColor),
                )),
        titleSpacing: widget.showBackButton ? 0 : 16,
        hideSearch: true,
        hideAppBar: widget.hideAppbar,
        backIcon: GetBuilder<CometChatConversationsController>(
            tag: tag,
            builder: (CometChatConversationsController value) =>
                value.selectionMap.isNotEmpty
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
                        ))),
        showBackButton: widget.showBackButton,
        onBack: widget.onBack,
        menuOptions: [
          if (widget.appBarOptions != null && widget.appBarOptions!.isNotEmpty)
            ...widget.appBarOptions!,
          Obx(
            () => getSelectionWidget(conversationsController),
          )
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
        ),
        container: Column(
          children: [
            Divider(
              color: style.separatorColor ?? colorPalette.borderLight,
              height: style.separatorHeight ?? 1,
            ),
            Expanded(
              child: _getList(
                conversationsController,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This method will return the selection widget
  Widget getSelectionWidget(
    CometChatConversationsController conversationsController,
  ) {
    if (_isSelectionOn.value) {
      return IconButton(
        onPressed: () {
          List<Conversation>? conversations =
              conversationsController.getSelectedList();
          if (widget.onSelection != null) {
            widget.onSelection!(conversations);
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

  // This method will have the Get Builder which will listen to the controller and will build the list of conversations
  Widget _getList(
    CometChatConversationsController conversationController,
    BuildContext context,
  ) {
    return GetBuilder(
      tag: tag,
      init: conversationController,
      global: false,
      dispose: (GetBuilderState<CometChatConversationsController> state) =>
          state.controller?.onClose(),
      builder: (CometChatConversationsController value) {
        value.context = context;
        value.colorPalette = colorPalette;
        value.spacing = spacing;
        value.typography = typography;
        if (value.hasError == true) {
          if (widget.hideError == true) {
            return const SizedBox();
          }
          if (widget.errorStateView != null) {
            return widget.errorStateView!(context);
          }
          return _showErrorView(context, value);
        } else if (value.isLoading == true && (value.list.isEmpty)) {
          return _getLoadingIndicator(context);
        } else if (value.list.isEmpty) {
          //----------- empty list widget-----------
          return _getNoConversationIndicator(context);
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
                return _getLoadingIndicator(
                  context,
                );
              }

              return SizedBox(
                key: tileKeys[index],
                child: getListItem(
                  value.list[index],
                  value,
                  context,
                  tileKeys[index],
                ),
              );
            },
          );
        }
      },
    );
  }

  // Displaying Loading View, Empty View and Error View
  // ----------------------------------------------------------------- //
  // Loading View
  Widget _getLoadingIndicator(
    BuildContext context,
  ) {
    if (widget.loadingStateView != null) {
      return widget.loadingStateView!(context);
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

  // Empty View
  Widget _getNoConversationIndicator(
    BuildContext context,
  ) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: spacing.padding5 ?? 0,
              ),
              child: Image.asset(
                AssetConstants(CometChatThemeHelper.getBrightness(context))
                    .conversationEmpty,
                package: UIConstants.packageName,
                width: 162,
                height: 121,
              ),
            ),
            Text(
              cc.Translations.of(context).noConversationsYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.emptyStateTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              )
                  .merge(
                    style.emptyStateTextStyle,
                  )
                  .copyWith(
                    color: style.emptyStateTextColor,
                  ),
            ),
            Text(
              cc.Translations.of(context).startNewChatOrInvite,
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

  // Error View
  Widget _showErrorView(
    BuildContext context,
    CometChatConversationsController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: spacing.padding5 ?? 0,
            ),
            child: Image.asset(
              AssetConstants(CometChatThemeHelper.getBrightness(context))
                  .messagesError,
              package: UIConstants.packageName,
              width: 120,
              height: 120,
            ),
          ),
          Text(
            cc.Translations.of(context).oops,
            style: TextStyle(
              color: style.errorStateTextColor ?? colorPalette.textPrimary,
              fontSize: typography.heading3?.bold?.fontSize,
              fontWeight: typography.heading3?.bold?.fontWeight,
              fontFamily: typography.heading3?.bold?.fontFamily,
            )
                .merge(
                  style.errorStateTextStyle,
                )
                .copyWith(
                  color: style.errorStateTextColor,
                ),
          ),
          Text(
            "${cc.Translations.of(context).looksLikeSomethingWrong}.\n${cc.Translations.of(context).pleaseTryAgain}.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: style.errorStateSubTitleTextColor ??
                  colorPalette.textSecondary,
              fontSize: typography.heading3?.regular?.fontSize,
              fontWeight: typography.heading3?.regular?.fontWeight,
              fontFamily: typography.heading3?.regular?.fontFamily,
            )
                .merge(
                  style.errorStateSubTitleTextStyle,
                )
                .copyWith(
                  color: style.errorStateSubTitleTextColor,
                ),
          ),
        ],
      ),
    );
  }

  // ------------------------------End of Loading, error and empty view---------------------------------- //

  // Displaying the data listItem, leading, title subtitle and trailing
  // ----------------------------------------------------------------- //

  Widget getListItem(
    Conversation conversation,
    CometChatConversationsController controller,
    BuildContext context,
    GlobalKey key,
  ) {
    if (widget.listItemView != null) {
      return widget.listItemView!(conversation);
    } else {
      return getDefaultItem(
        conversation,
        controller,
        context,
        key,
      );
    }
  }

  // This will give us the default item view which will build the Leading (CometChatListItem), title (CometChatListItem), subtitle and tail view
  // subTitle and tail view can be customized by passing the custom view in the respective functions

  Widget getDefaultItem(
    Conversation conversation,
    CometChatConversationsController controller,
    BuildContext context,
    GlobalKey key,
  ) {
    Widget? subtitle;
    Widget? tail;
    Color? backgroundColor;
    Widget? icon;

    if (widget.subtitleView != null) {
      subtitle = widget.subtitleView!(
        context,
        conversation,
      );
    } else {
      subtitle = getDefaultSubtitle(
        context: context,
        conversation: conversation,
        showTypingIndicator: controller.typingMap.containsKey(
          conversation.conversationId,
        ),
        hideThreadIndicator: controller.getHideThreadIndicator(
          conversation,
        ),
        controller: controller,
      );
    }
    if (widget.trailingView != null) {
      tail = widget.trailingView!(
        conversation,
      );
    } else {
      tail = Padding(
        padding: EdgeInsets.only(
          left: spacing.padding2 ?? 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: getTime(
                conversation,
                context,
              ),
            ),
            const SizedBox(
              height: 6.5,
            ),
            Flexible(
              child: getUnreadCount(
                conversation,
                context,
              ),
            ),
          ],
        ),
      );
    }

    User? conversationWithUser;
    Group? conversationWithGroup;
    if (conversation.conversationWith is User) {
      conversationWithUser = conversation.conversationWith as User;
    } else {
      conversationWithGroup = conversation.conversationWith as Group;
    }

    StatusIndicatorUtils statusIndicatorUtils =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
            context: context,
            isSelected:
               false,
            user: conversationWithUser,
            group: conversationWithGroup,
            onlineStatusIndicatorColor:
                statusStyle.backgroundColor ?? colorPalette.success,
            privateGroupIcon: widget.privateGroupIcon,
            protectedGroupIcon: widget.protectedGroupIcon,
            privateGroupIconBackground: style.privateGroupIconBackground,
            protectedGroupIconBackground: style.protectedGroupIconBackground,
            usersStatusVisibility:
                controller.hideUserPresence(conversationWithUser),
            groupTypeVisibility:
                controller.hideGroupIconVisibility(conversationWithGroup),
        );

    backgroundColor = statusIndicatorUtils.statusIndicatorColor;
    icon = statusIndicatorUtils.icon;
    return Container(
        decoration: BoxDecoration(
          color: (controller.selectionMap[conversation.conversationId] != null)
              ? style.listItemSelectedBackgroundColor ??
              colorPalette.background4
              : colorPalette.transparent,
        ),
      child: GestureDetector(
        key: UniqueKey(),
        onTap: () {
          if (widget.activateSelection == ActivateSelection.onClick ||
              (widget.activateSelection == ActivateSelection.onLongClick &&
                      controller.selectionMap.isNotEmpty) &&
                  !(widget.selectionMode == null ||
                      widget.selectionMode == SelectionMode.none)) {
            controller.onTap(conversation);
            if (controller.selectionMap.isEmpty) {
              _isSelectionOn.value = false;
            } else if (widget.activateSelection == ActivateSelection.onClick &&
                controller.selectionMap.isNotEmpty &&
                _isSelectionOn.value == false) {
              _isSelectionOn.value = true;
            }
          } else if (widget.onItemTap != null) {
            widget.onItemTap!(conversation);
            controller.activeConversation = conversation.conversationId;
          }
        },
        onLongPress: () {
          if (widget.activateSelection == ActivateSelection.onLongClick &&
              controller.selectionMap.isEmpty &&
              !(widget.selectionMode == null ||
                  widget.selectionMode == SelectionMode.none)) {
            controller.onTap(conversation);

            _isSelectionOn.value = true;
          } else if (widget.onItemLongPress != null) {
            widget.onItemLongPress!(conversation);

            controller.activeConversation = conversation.conversationId;
          } else {
            List<CometChatOption>? options = [];

            if (widget.setOptions != null) {
              options = widget.setOptions!(
                conversation,
                controller,
                context,
              );
            } else {
              if (widget.addOptions != null) {
                options.addAll(
                  widget.addOptions!(
                        conversation,
                        controller,
                        context,
                      ) ??
                      [],
                );
              }
              options.addAll(
                ConversationUtils.getDefaultOptions(
                        conversation, controller, context, colorPalette) ??
                    [],
              );

              if (widget.deleteConversationOptionVisibility == false) {
                for (int i = 0; i < options.length; i++) {
                  if (options[i].id == ConversationOptionConstants.delete) {
                    options.removeAt(i);
                  }
                }
              }
            }
            controller.showPopupMenu(
              context,
              options ?? [],
              key,
            );
          }
        },
        child: Row(
          children: [
            (controller.selectionMap.isNotEmpty)
                ? Checkbox(
              fillColor: (controller.selectionMap[conversation.conversationId] != null)
                  ? WidgetStateProperty.all(
                  style.checkBoxCheckedBackgroundColor ??
                      colorPalette.iconHighlight)
                  : WidgetStateProperty.all(
                  style.checkBoxBackgroundColor ??
                      colorPalette.transparent),
              value: controller.selectionMap[conversation.conversationId] != null,
              onChanged: (value) {
                if (widget.activateSelection ==
                    ActivateSelection.onClick ||
                    (widget.activateSelection ==
                        ActivateSelection.onLongClick &&
                        controller.selectionMap.isNotEmpty) &&
                        !(widget.selectionMode == null ||
                            widget.selectionMode == SelectionMode.none)) {
                  controller.onTap(conversation);
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
                avatarHeight: widget.avatarHeight ?? 48,
                avatarWidth: widget.avatarWidth ?? 48,
                avatarPadding: widget.avatarPadding,
                statusIndicatorBorderRadius: widget.statusIndicatorBorderRadius,
                avatarMargin: widget.avatarMargin,
                statusIndicatorHeight: widget.statusIndicatorHeight,
                statusIndicatorWidth: widget.statusIndicatorWidth,
                id: conversation.conversationId,
                avatarName: conversationWithUser?.name ?? conversationWithGroup?.name,
                avatarURL: conversationWithUser?.avatar ?? conversationWithGroup?.icon,
                title: conversationWithUser?.name ?? conversationWithGroup?.name,
                key: UniqueKey(),
                subtitleView: subtitle,
                tailView: tail,
                avatarStyle: style.avatarStyle ?? const CometChatAvatarStyle(),
                statusIndicatorColor: backgroundColor,
                statusIndicatorIcon: icon,
                statusIndicatorStyle: CometChatStatusIndicatorStyle(
                  border: statusStyle.border ??
                      Border.all(
                        width: spacing.spacing ?? 0,
                        color: colorPalette.background1 ?? Colors.transparent,
                      ),
                  backgroundColor: statusStyle.backgroundColor ?? colorPalette.success,
                ),
                hideSeparator: true,
                style: ListItemStyle(
                  background:
                      widget.listItemStyle?.background ?? colorPalette.transparent,
                  titleStyle: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: typography.heading4?.medium?.fontSize,
                    fontWeight: typography.heading4?.medium?.fontWeight,
                    fontFamily: typography.heading4?.medium?.fontFamily,
                    color: style.itemTitleTextColor ?? colorPalette.textPrimary,
                  ).merge(
                    widget.listItemStyle?.titleStyle ?? style.itemTitleTextStyle,
                  ),
                  height: widget.listItemStyle?.height,
                  border: widget.listItemStyle?.border,
                  borderRadius: widget.listItemStyle?.borderRadius,
                  gradient: widget.listItemStyle?.gradient,
                  width: widget.listItemStyle?.width,
                  margin: widget.listItemStyle?.margin,
                  padding: widget.listItemStyle?.padding ??
                      EdgeInsets.symmetric(
                        horizontal: spacing.padding4 ?? 0,
                        vertical: spacing.padding3 ?? 0,
                      ),
                ),
                leadingStateView: getLeadingView(conversation),
                titleView: getTitleView(conversation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? getLeadingView(Conversation conversation) {
    if (widget.leadingView != null) {
      return widget.leadingView!(context, conversation);
    }
    return null;
  }

  Widget? getTitleView(Conversation conversation) {
    if (widget.titleView != null) {
      return widget.titleView!(context, conversation);
    }
    return null;
  }

  //default subtitle
  Widget getDefaultSubtitle({
    required BuildContext context,
    required Conversation conversation,
    required bool showTypingIndicator,
    required CometChatConversationsController controller,
    bool? hideThreadIndicator = true,
    String? threadIndicatorText,
  }) {
    String prefix = "";
    if (hideThreadIndicator != null && hideThreadIndicator == false) {
      if (conversation.conversationWith is User) {
        if (conversation.lastMessage?.sender?.uid !=
            CometChatUIKit.loggedInUser?.uid) {
          prefix = "${conversation.lastMessage?.sender?.name}: ";
        } else {
          prefix = "";
        }
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hideThreadIndicator != null && hideThreadIndicator == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getReceiptIcon(
                context,
                conversation: conversation,
                hideReceipt: controller.getHideReceipt(
                  conversation,
                  widget.receiptsVisibility,
                ),
              ),
              Icon(
                Icons.subdirectory_arrow_right,
                color: colorPalette.iconSecondary,
                size: 16,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: spacing.padding ?? 0, right: spacing.padding ?? 0),
                child: Text(
                  prefix,
                  style: TextStyle(
                          color: style.itemSubtitleTextColor ??
                              colorPalette.textSecondary,
                          fontWeight: typography.body?.regular?.fontWeight,
                          fontSize: typography.body?.regular?.fontSize,
                          fontFamily: typography.body?.regular?.fontFamily,
                          letterSpacing: 0)
                      .merge(
                        style.itemSubtitleTextStyle,
                      )
                      .copyWith(
                        color: style.itemSubtitleTextColor,
                      ),
                ),
              ),
            ],
          ),
        if (!showTypingIndicator &&
            hideThreadIndicator != null &&
            hideThreadIndicator != false)
          getReceiptIcon(
            context,
            conversation: conversation,
            hideReceipt: controller.getHideReceipt(
              conversation,
              widget.receiptsVisibility,
            ),
          ),
        if (showTypingIndicator)
          Expanded(
            child: Text(
              widget.typingIndicatorText ??
                  ((conversation.conversationWith is User)
                      ? cc.Translations.of(context).isTyping
                      : "${controller.typingMap[conversation.conversationId]?.sender.name ?? ''} ${cc.Translations.of(context).isTyping}"),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorPalette.textHighlight,
                fontWeight: typography.body?.regular?.fontWeight,
                fontSize: typography.body?.regular?.fontSize,
                fontFamily: typography.body?.regular?.fontFamily,
              ).merge(
                typingStyle.textStyle,
              ),
            ),
          )
        else
          Expanded(
            child: getSubtitle(context, conversation, controller, style,
                colorPalette, spacing, typography),
          ),
      ],
    );
  }

  // Return subtitle widget
  Widget getSubtitle(
    BuildContext context,
    Conversation conversation,
    CometChatConversationsController controller,
    CometChatConversationsStyle conversationsStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    TextStyle subtitleStyle = TextStyle(
            overflow: TextOverflow.ellipsis,
            color: conversationsStyle.itemSubtitleTextColor ??
                colorPalette.textSecondary,
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
            letterSpacing: 0)
        .merge(
          conversationsStyle.itemSubtitleTextStyle,
        )
        .copyWith(
          color: conversationsStyle.itemSubtitleTextColor,
        );

    AdditionalConfigurations? configurations;

    if (conversation.lastMessage != null) {
      configurations = AdditionalConfigurations(
        textFormatters: controller.getTextFormatters(conversation.lastMessage!),
      );
    }

    Widget subtitle = CometChatUIKit.getDataSource().getConversationSubtitle(
        conversation,
        context,
        subtitleStyle,
        conversationsStyle.messageTypeIconColor ?? colorPalette.iconSecondary,
        additionalConfigurations: configurations);

    return subtitle;
  }

  // Return receipt icon
  Widget getReceiptIcon(
    context, {
    required Conversation conversation,
    bool? hideReceipt,
  }) {
    if (hideReceipt != null && hideReceipt) {
      return const SizedBox();
    } else if (conversation.lastMessage != null &&
        conversation.lastMessage?.sender != null &&
        conversation.lastMessage!.deletedAt == null &&
        conversation.lastMessage!.type != "groupMember") {
      ReceiptStatus status =
          MessageReceiptUtils.getReceiptStatus(conversation.lastMessage!);

      return Padding(
        padding: EdgeInsets.only(
          right: spacing.padding1 ?? 0,
        ),
        child: CometChatReceipt(
          status: status,
          style: receiptStyle,
          deliveredIcon: widget.deliveredIcon ??
              Icon(
                Icons.done_all,
                color: receiptStyle.deliveredIconColor ??
                    colorPalette.iconSecondary,
                size: 16,
              ),
          readIcon: widget.readIcon ??
              Icon(
                Icons.done_all,
                color: receiptStyle.readIconColor ?? colorPalette.iconHighlight,
                size: 16,
              ),
          sentIcon: widget.sentIcon ??
              Icon(
                Icons.check,
                color: receiptStyle.sentIconColor ?? colorPalette.iconSecondary,
                size: 16,
              ),
          errorIcon: Icon(
            Icons.error_outlined,
            color: receiptStyle.errorIconColor ?? colorPalette.error,
            size: 16,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

//----------- last message update time and unread message count -----------
  Widget getTime(
    Conversation conversation,
    context,
  ) {
    DateTime? lastMessageTime =
        conversation.lastMessage?.updatedAt ?? conversation.lastMessage?.sentAt;
    if (lastMessageTime == null) return const SizedBox();

    String? customDateString;

    if (widget.datePattern != null) {
      customDateString = widget.datePattern!(conversation);
    }

    return CometChatDate(
      date: lastMessageTime,
      padding: widget.datePadding ?? const EdgeInsets.all(0),
      height: widget.dateHeight,
      isTransparentBackground: widget.dateBackgroundIsTransparent,
      width: widget.dateWidth,
      style: CometChatDateStyle(
        backgroundColor: datesStyle.backgroundColor ?? colorPalette.transparent,
        textStyle: TextStyle(
          color: datesStyle.textColor ?? colorPalette.textSecondary,
          fontSize: typography.caption1?.regular?.fontSize,
          fontWeight: typography.caption1?.regular?.fontWeight,
          fontFamily: typography.caption1?.regular?.fontFamily,
        ).merge(datesStyle.textStyle).copyWith(
              color: datesStyle.textColor,
            ),
        border: datesStyle.border ??
            Border.all(
              width: 0,
              color: Colors.transparent,
            ),
        borderRadius: datesStyle.borderRadius,
        textColor: datesStyle.textColor,
      ),
      customDateString: customDateString,
      pattern: DateTimePattern.dayDateTimeFormat,
      dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
    );
  }

  // Return unread message count widget
  Widget getUnreadCount(Conversation conversation, context) {
    return CometChatBadge(
      count: conversation.unreadMessageCount ?? 0,
      width: widget.badgeWidth,
      height: widget.badgeHeight ?? 20,
      style: style.badgeStyle ?? const CometChatBadgeStyle(),
      padding: widget.badgePadding,
    );
  }
}
