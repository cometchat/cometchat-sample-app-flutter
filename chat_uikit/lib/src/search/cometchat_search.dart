import 'package:cometchat_chat_uikit/src/message_list/messages_builder_protocol.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

class CometChatSearch extends StatefulWidget {
  const CometChatSearch({
    this.onBack,
    this.onMessageClicked,
    this.onConversationClicked,
    this.onEmpty,
    this.onError,
    this.onMessagesLoad,
    this.onConversationsLoad,
    this.searchFilters,
    this.searchIn,
    this.user,
    this.group,
    this.loadingStateView,
    this.errorStateView,
    this.emptyStateView,
    this.initialStateView,
    this.conversationItemView,
    this.conversationTitleView,
    this.conversationLeadingView,
    this.conversationSubtitleView,
    this.conversationTailView,
    this.usersStatusVisibility,
    this.receiptsVisibility,
    this.groupTypeVisibility,
    this.searchStyle,
    this.searchBackIcon,
    this.searchClearIcon,
    this.dateSeparatorFormatterCallback,
    this.timeSeparatorFormatterCallback,
    this.searchMessageLinkView,
    this.searchTextMessageView,
    this.searchImageMessageView,
    this.searchVideoMessageView,
    this.searchFileMessageView,
    this.searchAudioMessageView,
    this.conversationsProtocol,
    this.conversationsRequestBuilder,
    this.messagesRequestBuilder,
    super.key,
  });

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[onConversationClicked] callback when conversation is clicked
  final Function(Conversation conversation)? onConversationClicked;

  ///[onMessageClicked] callback when message is clicked
  final Function(BaseMessage message)? onMessageClicked;

  ///[onError] call back when the component encounters an error
  final OnError? onError;

  ///[onConversationsLoad] is a function which will called when conversation is loading.
  final OnLoad<Conversation>? onConversationsLoad;

  ///[onMessagesLoad] callback triggered when list is fetched and load
  final OnLoad<BaseMessage>? onMessagesLoad;

  ///[onEmpty] is a function which will called when list is empty.
  final OnEmpty? onEmpty;

  ///[searchFilters] list of filters to be shown in the search screen
  final List<SearchFilter>? searchFilters;

  ///[SearchScope] list of scopes to be shown in the search result
  final List<SearchScope>? searchIn;

  ///[user] user object for user message search
  final User? user;

  ///[group] group object  for group message search
  final Group? group;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state
  final WidgetBuilder? errorStateView;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[loadingStateView] returns view fow initial state
  final WidgetBuilder? initialStateView;

  ///[conversationItemView] set custom view for each searched conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      conversationItemView;

  ///[conversationTitleView] to set title view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      conversationTitleView;

  ///[conversationLeadingView] to set leading view for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      conversationLeadingView;

  ///[conversationSubtitleView] to set subtitle for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      conversationSubtitleView;

  ///[conversationTailView] to set tailView for each conversation
  final Widget? Function(BuildContext context, Conversation conversation)?
      conversationTailView;

  ///[usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  ///[receiptsVisibility] controls visibility of receipts
  final bool? receiptsVisibility;

  ///[groupTypeVisibility] Hide the group type icon which is visible on the group icon.
  final bool? groupTypeVisibility;

  ///[searchStyle] sets style
  final CometChatSearchStyle? searchStyle;

  ///[searchBackIcon] sets custom back icon
  final Widget? searchBackIcon;

  ///[searchClearIcon] sets custom clear icon
  final Widget? searchClearIcon;

  /// [dateSeparatorFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateSeparatorFormatterCallback;

  /// [timeSeparatorFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? timeSeparatorFormatterCallback;

  ///[searchMessageLinkView] sets custom link view for each message
  final Widget? Function(BuildContext context, BaseMessage message)?
      searchMessageLinkView;

  ///[searchTextMessageView] sets text view for each message
  final Widget? Function(BuildContext context, TextMessage message)?
      searchTextMessageView;

  ///[searchImageMessageView] sets image view for each message
  final Widget? Function(BuildContext context, MediaMessage message)?
      searchImageMessageView;

  ///[searchVideoMessageView] sets video view for each message
  final Widget? Function(BuildContext context, MediaMessage message)?
      searchVideoMessageView;

  ///[searchFileMessageView] sets file view for each message
  final Widget? Function(BuildContext context, MediaMessage message)?
      searchFileMessageView;

  ///[searchAudioMessageView] sets audio view for each message
  final Widget? Function(BuildContext context, MediaMessage message)?
      searchAudioMessageView;

  ///[conversationsProtocol] Request builder protocol to fetch conversations.
  final ConversationsBuilderProtocol? conversationsProtocol;

  ///[conversationsRequestBuilder] Request builder to fetch conversations.
  final ConversationsRequestBuilder? conversationsRequestBuilder;

  ///[messagesRequestBuilder] set  custom request builder which will be passed to CometChat's SDK
  final MessagesRequestBuilder? messagesRequestBuilder;

  @override
  State<CometChatSearch> createState() => _CometChatSearchState();
}

class _CometChatSearchState extends State<CometChatSearch> {
  late CometChatSearchStyle style;
  late CometChatTypography typography;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  late final CometChatSearchController _searchController;
  late final CometChatConversationsSearchController _conversationsController;
  late final CometChatMessagesSearchController _messagesController;

  late final String tag;

  @override
  void didChangeDependencies() {
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatSearchStyle>(
            context: context, defaultTheme: CometChatSearchStyle.of)
        .merge(widget.searchStyle);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    tag =
        "cometchat_search_controller${widget.user?.uid ?? widget.group?.guid ?? ""}";
    initializeSearchController();
    super.initState();
  }

  initializeSearchController() {
    _searchController = Get.put(
      CometChatSearchController(
        searchFilters: widget.searchFilters,
        searchScopes: widget.searchIn,
      ),
      tag: tag,
    );
    initializeConversationController();
    initializeMessagesController();
  }

  initializeConversationController() {
    _conversationsController = Get.put(
      CometChatConversationsSearchController(
        builderProtocol: widget.conversationsProtocol ??
            UIConversationsBuilder(
              widget.conversationsRequestBuilder ??
                  RequestBuilderConstants
                      .getDefaultConversationsRequestBuilder(),
            ),
        onEmpty: widget.onEmpty,
        onError: widget.onError,
        onLoad: widget.onConversationsLoad,
        groupTypeVisibility: widget.groupTypeVisibility,
        receiptsVisibility: widget.receiptsVisibility,
        usersStatusVisibility: widget.usersStatusVisibility,
        tag: tag,
      ),
      tag: tag,
    );
  }

  initializeMessagesController() {
    MessagesRequestBuilder requestBuilder =
        widget.messagesRequestBuilder ?? MessagesRequestBuilder();

    List<String> categories = [];
    List<String> types = [];

    //only set types and categories when coming from default
    if (widget.messagesRequestBuilder == null) {
      categories = CometChatUIKit.getDataSource().getAllMessageCategories();
      types = CometChatUIKit.getDataSource().getAllMessageTypes();
      requestBuilder.types = types;
      requestBuilder.categories = categories;
    }

    if (widget.user != null) {
      requestBuilder.uid = widget.user!.uid;
    } else if (widget.group != null) {
      requestBuilder.guid = widget.group!.guid;
    }

    _messagesController = Get.put(
      CometChatMessagesSearchController(
        builderProtocol: UIMessagesBuilder(requestBuilder),
        onEmpty: widget.onEmpty,
        onError: widget.onError,
        onLoad: widget.onMessagesLoad,
        group: widget.group,
        user: widget.user,
        tag: tag,
      ),
      tag: tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<CometChatSearchController>(tag: tag)) {
      Get.delete<CometChatSearchController>(tag: tag, force: true);
    }

    if (Get.isRegistered<CometChatConversationsSearchController>(tag: tag)) {
      Get.delete<CometChatConversationsSearchController>(tag: tag, force: true);
    }

    if (Get.isRegistered<CometChatMessagesSearchController>(tag: tag)) {
      Get.delete<CometChatMessagesSearchController>(tag: tag, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.searchStyle?.backgroundColor ?? colorPalette.background1,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding3 ?? 0,
            horizontal: spacing.padding4 ?? 0,
          ),
          child: GetBuilder<CometChatSearchController>(
            init: _searchController,
            tag: tag,
            builder: (searchController) {
              searchController.context = context;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _buildSearchBar(context, typography, colorPalette, spacing,
                      style, searchController),

                  // Filter chips
                  _buildFilterChips(context, typography, colorPalette, spacing,
                      style, searchController),

                  Expanded(
                    child: searchController.shouldShowNoResultsScreen()
                        ? SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: getEmptyView(context, colorPalette, spacing,
                                typography, style, searchController),
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (searchController.bothActive == true &&
                                    _conversationsController.isLoading &&
                                    _messagesController.isLoading)
                                  getLoadingView(context, colorPalette, spacing,
                                      typography, style),
                                if (searchController.bothActive == true &&
                                    _conversationsController.list.isEmpty &&
                                    _messagesController.list.isEmpty)
                                  getEmptyView(context, colorPalette, spacing,
                                      typography, style, searchController),
                                if (searchController.bothActive == true &&
                                    _conversationsController.hasError &&
                                    _messagesController.hasError)
                                  getErrorView(context, colorPalette, spacing,
                                      typography, style),
                                // Check if the controller is loading, has an error, or has no conversations
                                if (searchController.shouldShowConversationList() &&
                                    searchController.showConversationsSearch)
                            GetBuilder<CometChatConversationsSearchController>(
                              init: _conversationsController,
                              tag: tag,
                              builder: (ctrl) {
                                if (searchController.bothActive == false &&
                                    ctrl.isLoading) {
                                  if (widget.loadingStateView != null) {
                                    return widget.loadingStateView!(context);
                                  } else {
                                    return SearchUtils.loadingView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      spacing: spacing,
                                      typography: typography,
                                    );
                                  }
                                }

                                if (searchController.bothActive == false &&
                                    !ctrl.isLoading &&
                                    ctrl.list.isEmpty) {
                                  if (widget.emptyStateView != null) {
                                    return widget.emptyStateView!(context);
                                  } else {
                                    return SearchUtils.emptyView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      typography: typography,
                                      spacing: spacing,
                                      searchText: searchController.searchText,
                                      conversationsController:
                                          _conversationsController,
                                      messagesController: _messagesController,
                                      style: style,
                                    );
                                  }
                                }

                                // If there's an error, display it
                                if (searchController.bothActive == false &&
                                    ctrl.hasError) {
                                  if (widget.errorStateView != null) {
                                    return widget.errorStateView!(context);
                                  } else {
                                    return SearchUtils.errorView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      typography: typography,
                                      spacing: spacing,
                                      conversationsController:
                                          _conversationsController,
                                      messagesController: _messagesController,
                                      style: style,
                                    );
                                  }
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_conversationsController
                                        .list.isNotEmpty)
                                      SearchUtils.headingTitle(
                                        title: cc.Translations.of(context)
                                            .conversations,
                                        colorPalette: colorPalette,
                                        typography: typography,
                                        spacing: spacing,
                                        style: style,
                                      ),
                                    ListView.builder(
                                      itemCount: (searchController
                                              .selectedFilters.isNotEmpty)
                                          ? (ctrl.hasMoreItems
                                              ? ctrl.list.length + 1
                                              : ctrl.list.length)
                                          : ctrl.list.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        if (searchController
                                                .selectedFilters.isNotEmpty &&
                                            index >= ctrl.list.length) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback(
                                                      (_) => ctrl
                                                          .loadMoreElements(),
                                                    );
                                                if (widget.loadingStateView !=
                                                    null) {
                                            return widget
                                                      .loadingStateView!(
                                                    context,
                                                  );
                                          } else {
                                            return SearchUtils.loadingView(
                                              context: context,
                                              colorPalette: colorPalette,
                                              spacing: spacing,
                                              typography: typography,
                                            );
                                          }
                                        }

                                        final conversation = ctrl.list[index];

                                        if (widget.conversationItemView !=
                                            null) {
                                          return widget.conversationItemView!(
                                              context, conversation);
                                        }
                                        User? conversationWithUser;
                                        Group? conversationWithGroup;
                                        if (conversation.conversationWith
                                            is User) {
                                          conversationWithUser = conversation
                                              .conversationWith as User;
                                        } else {
                                          conversationWithGroup = conversation
                                              .conversationWith as Group;
                                        }

                                        Widget? subtitle;
                                        Widget? tail;
                                        Color? backgroundColor;
                                        Widget? icon;

                                        if (widget.conversationSubtitleView !=
                                            null) {
                                          subtitle =
                                              widget.conversationSubtitleView!(
                                                  context, conversation);
                                        } else {
                                          subtitle =
                                              SearchUtils.getSubtitleView(
                                            context: context,
                                            conversation: conversation,
                                            showTypingIndicator:
                                                _conversationsController
                                                    .typingMap
                                                    .containsKey(
                                              conversation.conversationId,
                                            ),
                                            controller:
                                                _conversationsController,
                                            typography: typography,
                                            colorPalette: colorPalette,
                                            spacing: spacing,
                                            hideThreadIndicator: false,
                                            style: style,
                                            receiptsVisibility:
                                                widget.receiptsVisibility,
                                            receiptStyle:
                                                CometChatMessageReceiptStyle(),
                                            typingStyle:
                                                const CometChatTypingIndicatorStyle(),
                                          );
                                        }

                                        tail = SearchUtils.getTrailingView(
                                          context: context,
                                          conversation: conversation,
                                          colorPalette: colorPalette,
                                          typography: typography,
                                          spacing: spacing,
                                          trailingView:
                                              widget.conversationTailView,
                                          style: style,
                                          dateTimeFormatterCallback: widget
                                              .timeSeparatorFormatterCallback,
                                        );

                                        StatusIndicatorUtils
                                            statusIndicatorUtils =
                                            StatusIndicatorUtils
                                                .getStatusIndicatorFromParams(
                                          context: context,
                                          isSelected: false,
                                          user: conversationWithUser,
                                          group: conversationWithGroup,
                                          onlineStatusIndicatorColor:
                                              colorPalette.success,
                                          privateGroupIcon: null,
                                          protectedGroupIcon: null,
                                          privateGroupIconBackground: null,
                                          protectedGroupIconBackground: null,
                                          usersStatusVisibility:
                                              _conversationsController
                                                  .hideUserPresence(
                                                      conversationWithUser),
                                          groupTypeVisibility:
                                              _conversationsController
                                                  .hideGroupIconVisibility(
                                                      conversationWithGroup),
                                        );

                                        backgroundColor = statusIndicatorUtils
                                            .statusIndicatorColor;
                                        icon = statusIndicatorUtils.icon;

                                        return GestureDetector(
                                          onTap: () {
                                            if (widget.onConversationClicked !=
                                                null) {
                                              widget.onConversationClicked!(
                                                  conversation);
                                            }
                                          },
                                          child: CometChatListItem(
                                            avatarHeight: 48,
                                            avatarWidth: 48,
                                            avatarPadding: null,
                                            statusIndicatorBorderRadius: null,
                                            avatarMargin: null,
                                            statusIndicatorHeight: null,
                                            statusIndicatorWidth: null,
                                            id: conversation.conversationId,
                                            avatarName:
                                                conversationWithUser?.name ??
                                                    conversationWithGroup?.name,
                                            avatarURL:
                                                conversationWithUser?.avatar ??
                                                    conversationWithGroup?.icon,
                                            title: conversationWithUser?.name ??
                                                conversationWithGroup?.name,
                                            key: UniqueKey(),
                                            avatarStyle: style.avatarStyle ??
                                                const CometChatAvatarStyle(),
                                            statusIndicatorColor:
                                                backgroundColor,
                                            statusIndicatorIcon: icon,
                                            statusIndicatorStyle:
                                                CometChatStatusIndicatorStyle(
                                              border: Border.all(
                                                width: spacing.spacing ?? 0,
                                                color:
                                                    colorPalette.background1 ??
                                                        Colors.transparent,
                                              ),
                                              backgroundColor:
                                                  colorPalette.success,
                                            ),
                                            hideSeparator: true,
                                            contentPadding: EdgeInsets.zero,
                                            style: ListItemStyle(
                                              background: style
                                                      .searchConversationItemBackgroundColor ??
                                                  colorPalette.transparent,
                                              titleStyle: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: typography
                                                    .heading4?.medium?.fontSize,
                                                fontWeight: typography.heading4
                                                    ?.medium?.fontWeight,
                                                fontFamily: typography.heading4
                                                    ?.medium?.fontFamily,
                                                color: style
                                                        .searchConversationTitleTextColor ??
                                                    colorPalette.textPrimary,
                                              )
                                                  .merge(style
                                                      .searchConversationTitleTextStyle)
                                                  .copyWith(
                                                    color: style
                                                        .searchConversationTitleTextColor,
                                                  ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: spacing.padding3 ?? 0,
                                              ),
                                            ),
                                            subtitleView: subtitle,
                                            tailView: tail,
                                            leadingStateView:
                                                SearchUtils.getLeadingView(
                                              context: context,
                                              conversation: conversation,
                                              leadingView: widget
                                                  .conversationLeadingView,
                                            ),
                                            titleView: SearchUtils.getTitleView(
                                              context: context,
                                              conversation: conversation,
                                              titleView:
                                                  widget.conversationTitleView,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (searchController.selectedFilters.isEmpty &&
                                        _conversationsController
                                            .list.isNotEmpty &&
                                        _conversationsController.list.length >= 3 &&
                                        _conversationsController.hasMoreItems)
                                      SearchUtils.seeMoreButton(
                                          callback: (ctrl.isLoading == false ||
                                                  ctrl.hasError == false)
                                              ? ctrl.loadMore
                                              : null,
                                          colorPalette: colorPalette,
                                          typography: typography,
                                          spacing: spacing,
                                          style: style,
                                          context: context),
                                  ],
                                );
                              },
                            ),
                          if (searchController.shouldShowMessageList() &&
                              searchController.showMessagesSearch)
                            GetBuilder<CometChatMessagesSearchController>(
                              init: _messagesController,
                              tag: tag,
                              builder: (ctrl) {
                                if (searchController.bothActive == false &&
                                    ctrl.isLoading) {
                                  if (widget.loadingStateView != null) {
                                    return widget.loadingStateView!(context);
                                  } else {
                                    return SearchUtils.loadingView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      spacing: spacing,
                                      typography: typography,
                                    );
                                  }
                                }

                                if (searchController.bothActive == false &&
                                    !ctrl.isLoading &&
                                    ctrl.list.isEmpty) {
                                  if (widget.emptyStateView != null) {
                                    return widget.emptyStateView!(context);
                                  } else {
                                    return SearchUtils.emptyView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      typography: typography,
                                      spacing: spacing,
                                      searchText: searchController.searchText,
                                      conversationsController:
                                          _conversationsController,
                                      messagesController: _messagesController,
                                      style: style,
                                    );
                                  }
                                }

                                // If there's an error, display it
                                if (searchController.bothActive == false &&
                                    ctrl.hasError) {
                                  if (widget.errorStateView != null) {
                                    return widget.errorStateView!(context);
                                  } else {
                                    return SearchUtils.errorView(
                                      context: context,
                                      colorPalette: colorPalette,
                                      typography: typography,
                                      spacing: spacing,
                                      conversationsController:
                                          _conversationsController,
                                      messagesController: _messagesController,
                                      style: style,
                                    );
                                  }
                                }
                                // Check if the controller is loading, has an error, or has no conversations
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_messagesController.list.isNotEmpty)
                                      SearchUtils.headingTitle(
                                        title: cc.Translations.of(context)
                                            .messages,
                                        colorPalette: colorPalette,
                                        typography: typography,
                                        spacing: spacing,
                                        style: style,
                                      ),
                                    ListView.builder(
                                      itemCount: (searchController
                                              .selectedFilters.isNotEmpty)
                                          ? (ctrl.hasMoreItems
                                              ? ctrl.list.length + 1
                                              : ctrl.list.length)
                                          : ctrl.list.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        if (searchController
                                                .selectedFilters.isNotEmpty &&
                                            index >= ctrl.list.length) {
WidgetsBinding.instance
                                                    .addPostFrameCallback(
                                                      (_) => ctrl
                                                          .loadMoreElements(),
                                                    );
                                                if (widget.loadingStateView !=
                                                    null) {
                                            return widget
                                                      .loadingStateView!(
                                                    context,
                                                  );
                                          } else {
                                            return SearchUtils.loadingView(
                                              context: context,
                                              colorPalette: colorPalette,
                                              spacing: spacing,
                                              typography: typography,
                                            );
                                          }
                                        }
                                        final message = ctrl.list[index];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SearchUtils.getDateSeparator(
                                              _messagesController,
                                              index,
                                              context,
                                              colorPalette,
                                              typography,
                                              spacing,
                                              widget
                                                  .dateSeparatorFormatterCallback,
                                              style,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (widget.onMessageClicked !=
                                                    null) {
                                                  widget.onMessageClicked!(
                                                      message);
                                                }
                                              },
                                              child: SearchUtils
                                                  .buildMessageTypeBubble(
                                                context: context,
                                                message: message,
                                                controller: ctrl,
                                                colorPalette: colorPalette,
                                                typography: typography,
                                                spacing: spacing,
                                                style: style,
                                                timeSeparatorFormatterCallback:
                                                    widget
                                                        .timeSeparatorFormatterCallback,
                                                searchMessageLinkView: widget
                                                    .searchMessageLinkView,
                                                searchTextMessageView: widget
                                                    .searchTextMessageView,
                                                searchImageMessageView: widget
                                                    .searchImageMessageView,
                                                searchVideoMessageView: widget
                                                    .searchVideoMessageView,
                                                searchFileMessageView: widget
                                                    .searchFileMessageView,
                                                searchAudioMessageView: widget
                                                    .searchAudioMessageView,
                                                onMessageClicked: widget.onMessageClicked,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if (searchController
                                            .selectedFilters.isEmpty &&
                                        _messagesController.list.isNotEmpty &&
                                        _messagesController.hasMoreItems)
                                      SearchUtils.seeMoreButton(
                                        callback: (ctrl.isLoading == false ||
                                                ctrl.hasError == false)
                                            ? ctrl.loadMoreElements
                                            : null,
                                        colorPalette: colorPalette,
                                        typography: typography,
                                        spacing: spacing,
                                        style: style,
                                        context: context,
                                      ),
                                  ],
                                );
                              },
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the search bar widget

  _buildSearchBar(
    BuildContext context,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatSearchStyle style,
    CometChatSearchController searchController,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: spacing.padding3 ?? 0,
      ),
      child: TextField(
        keyboardAppearance:
            CometChatThemeHelper.getBrightness(context) == Brightness.dark
                ? Brightness.dark
                : Brightness.light,
        controller: searchController.searchEditingController,
        onChanged: (val) {
          if (searchController.bothActive == true) {
            _conversationsController.onSearch(val);
            _messagesController.onSearch(val);
          } else if (searchController.showConversationsSearch) {
            _conversationsController.onSearch(val);
          } else if (searchController.showMessagesSearch) {
            _messagesController.onSearch(val);
          }
        },
        style: TextStyle(
          color: style.searchTextColor ?? colorPalette.textPrimary,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(style.searchTextStyle).copyWith(
              color: style.searchTextColor,
            ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding3 ?? 0,
            vertical: spacing.padding2 ?? 0,
          ),
          hintText: (widget.user != null || widget.group != null)
              ? "${cc.Translations.of(context).search} in ${widget.user?.name ?? widget.group?.name ?? ""}"
              : cc.Translations.of(context).search,
          prefixIcon: GestureDetector(
            onTap: widget.onBack ??
                () {
                  Navigator.of(context).pop();
                },
            child: widget.searchBackIcon ??
                Icon(
                  Icons.arrow_back,
                  color:
                      style.searchBackIconColor ?? colorPalette.iconSecondary,
                  size: 24,
                ),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              if (searchController.searchText.isEmpty) {
                return;
              }

              searchController.searchEditingController.clear();

              _conversationsController.onSearch("");
              _messagesController.onSearch("");
            },
            child: widget.searchClearIcon ??
                Icon(
                  Icons.close,
                  color:
                      style.searchClearIconColor ?? colorPalette.iconSecondary,
                  size: 24,
                ),
          ),
          hintStyle: TextStyle(
            color:
                style.searchPlaceHolderTextColor ?? colorPalette.textTertiary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          ).merge(style.searchPlaceHolderTextStyle).copyWith(
                color: style.searchPlaceHolderTextColor,
              ),
          focusedBorder: OutlineInputBorder(
            borderSide: style.searchBorder ??
                BorderSide(
                  color: colorPalette.borderDark ?? Colors.transparent,
                  width: 1,
                ),
            borderRadius: style.searchBorderRadius ??
                BorderRadius.circular(
                  spacing.radiusMax ?? 0,
                ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: style.searchBorder ??
                BorderSide(
                  color: colorPalette.borderDark ?? Colors.transparent,
                  width: 1,
                ),
            borderRadius: style.searchBorderRadius ??
                BorderRadius.circular(
                  spacing.radiusMax ?? 0,
                ),
          ),
          border: OutlineInputBorder(
            borderSide: style.searchBorder ??
                BorderSide(
                  color: colorPalette.borderDark ?? Colors.transparent,
                  width: 1,
                ),
            borderRadius: style.searchBorderRadius ??
                BorderRadius.circular(
                  spacing.radiusMax ?? 0,
                ),
          ),
          fillColor: style.searchBackgroundColor ?? colorPalette.background3,
          filled: true,
        ),
      ),
    );
  }

  /// Builds the filter chips widget
  _buildFilterChips(
    BuildContext context,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatSearchStyle style,
    CometChatSearchController searchController,
  ) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.only(
          bottom: spacing.padding3 ?? 0,
        ),
        child: Wrap(
          spacing: spacing.padding2 ?? 0,
          runSpacing: spacing.padding2 ?? 0,
          children: searchController.visibleFilters.map((filter) {
            final isSelected =
                searchController.selectedFilters.contains(filter.label);
            return cc.FilterChip(
              label: filter.label,
              icon: filter.icon,
              isSelected: isSelected,
              onTap: () => searchController.onFilterTap(filter.label),
              selectedColor: style.searchFilterChipSelectedBackgroundColor ??
                  colorPalette.secondaryButtonBackground ??
                  Colors.transparent,
              unselectedColor: style.searchFilterChipBackgroundColor ??
                  colorPalette.background3 ??
                  Colors.transparent,
              selectedIconColor: style.searchFilterSelectedIconColor ??
                  colorPalette.iconWhite ??
                  Colors.transparent,
              unselectedIconColor: style.searchFilterIconColor ??
                  colorPalette.iconSecondary ??
                  Colors.transparent,
              selectedTextColor: style.searchFilterChipSelectedTextColor ??
                  colorPalette.textWhite,
              unselectedTextColor: style.searchFilterChipTextColor ??
                  colorPalette.textSecondary ??
                  Colors.transparent,
              selectedBorder: style.searchFilterChipSelectedBorder ??
                  Border.all(
                    color: colorPalette.neutral800 ?? Colors.transparent,
                    width: 1,
                  ),
              unSelectedBorder: style.searchFilterChipBorder ??
                  Border.all(
                    color: colorPalette.borderLight ?? Colors.transparent,
                    width: 1,
                  ),
              borderRadius: style.searchFilterChipBorderRadius ??
                  BorderRadius.circular(spacing.radiusMax ?? 0),
              selectedTextStyle: style.searchFilterChipSelectedTextStyle,
              textStyle: style.searchFilterChipTextStyle,
              typography: typography,
              spacing: spacing,
              colorPalette: colorPalette,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getLoadingView(
      context,
      CometChatColorPalette colorPalette,
      CometChatSpacing spacing,
      CometChatTypography typography,
      CometChatSearchStyle style) {
    // Check if the controller is loading, has an error, or has no conversations
    if (widget.loadingStateView != null) {
      return widget.loadingStateView!(context);
    } else {
      return SearchUtils.loadingView(
        context: context,
        colorPalette: colorPalette,
        spacing: spacing,
        typography: typography,
      );
    }
  }

  Widget getEmptyView(
    context,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
    CometChatSearchStyle style,
    CometChatSearchController searchController,
  ) {
    if (widget.emptyStateView != null) {
      return widget.emptyStateView!(context);
    } else {
      return SearchUtils.emptyView(
        context: context,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        searchText: searchController.searchText,
        conversationsController: _conversationsController,
        messagesController: _messagesController,
        style: style,
      );
    }
  }

  Widget getErrorView(
      context,
      CometChatColorPalette colorPalette,
      CometChatSpacing spacing,
      CometChatTypography typography,
      CometChatSearchStyle style) {
    if (widget.errorStateView != null) {
      return widget.errorStateView!(context);
    } else {
      return SearchUtils.errorView(
        context: context,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        conversationsController: _conversationsController,
        messagesController: _messagesController,
        style: style,
      );
    }
  }
}
