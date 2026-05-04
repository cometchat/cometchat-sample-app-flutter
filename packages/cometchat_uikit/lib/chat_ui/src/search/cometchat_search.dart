import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import '../conversations/utils/conversation_subtitle_utils.dart';

/// Full-screen search widget for conversations and messages.
///
/// Supports text search with debounce, filter chips, dual-section results
/// (Conversations + Messages), "See More" pagination, and custom view slots.
class CometChatSearch extends StatefulWidget {
  const CometChatSearch({
    super.key,
    this.onBack,
    this.onConversationClicked,
    this.onMessageClicked,
    this.onEmpty,
    this.onError,
    this.onMessagesLoad,
    this.onConversationsLoad,
    this.searchFilters,
    this.searchIn,
    this.user,
    this.group,
    this.searchStyle,
    this.searchBackIcon,
    this.searchClearIcon,
    this.loadingStateView,
    this.emptyStateView,
    this.errorStateView,
    this.initialStateView,
    this.conversationItemView,
    this.conversationTitleView,
    this.conversationLeadingView,
    this.conversationSubtitleView,
    this.conversationTailView,
    this.usersStatusVisibility,
    this.receiptsVisibility,
    this.groupTypeVisibility,
    this.dateSeparatorFormatterCallback,
    this.timeSeparatorFormatterCallback,
    this.searchTextMessageView,
    this.searchImageMessageView,
    this.searchVideoMessageView,
    this.searchFileMessageView,
    this.searchAudioMessageView,
    this.conversationsRequestBuilder,
    this.messagesRequestBuilder,
  });

  final VoidCallback? onBack;
  final Function(Conversation conversation)? onConversationClicked;
  final Function(BaseMessage message)? onMessageClicked;
  final OnError? onError;
  final OnLoad<Conversation>? onConversationsLoad;
  final OnLoad<BaseMessage>? onMessagesLoad;
  final OnEmpty? onEmpty;
  final List<SearchFilter>? searchFilters;
  final List<SearchScope>? searchIn;
  final User? user;
  final Group? group;
  final CometChatSearchStyle? searchStyle;
  final Widget? searchBackIcon;
  final Widget? searchClearIcon;
  final WidgetBuilder? loadingStateView;
  final WidgetBuilder? emptyStateView;
  final WidgetBuilder? errorStateView;
  final WidgetBuilder? initialStateView;
  final Widget? Function(BuildContext, Conversation)? conversationItemView;
  final Widget? Function(BuildContext, Conversation)? conversationTitleView;
  final Widget? Function(BuildContext, Conversation)? conversationLeadingView;
  final Widget? Function(BuildContext, Conversation)? conversationSubtitleView;
  final Widget? Function(BuildContext, Conversation)? conversationTailView;
  final bool? usersStatusVisibility;
  final bool? receiptsVisibility;
  final bool? groupTypeVisibility;
  final DateTimeFormatterCallback? dateSeparatorFormatterCallback;
  final DateTimeFormatterCallback? timeSeparatorFormatterCallback;
  final Widget? Function(BuildContext, TextMessage)? searchTextMessageView;
  final Widget? Function(BuildContext, MediaMessage)? searchImageMessageView;
  final Widget? Function(BuildContext, MediaMessage)? searchVideoMessageView;
  final Widget? Function(BuildContext, MediaMessage)? searchFileMessageView;
  final Widget? Function(BuildContext, MediaMessage)? searchAudioMessageView;
  final ConversationsRequestBuilder? conversationsRequestBuilder;
  final MessagesRequestBuilder? messagesRequestBuilder;

  @override
  State<CometChatSearch> createState() => _CometChatSearchState();
}

class _CometChatSearchState extends State<CometChatSearch> {
  late final SearchBloc _searchBloc;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  // Theme caching
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  late CometChatSearchStyle style;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(
      user: widget.user,
      group: widget.group,
      initialScope: SearchScope.both,
      conversationsRequestBuilder: widget.conversationsRequestBuilder,
      messagesRequestBuilder: widget.messagesRequestBuilder,
      searchFilters: widget.searchFilters,
      searchScopes: widget.searchIn,
    );
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      colorPalette = CometChatThemeHelper.getColorPalette(context);
      spacing = CometChatThemeHelper.getSpacing(context);
      typography = CometChatThemeHelper.getTypography(context);
      style = CometChatThemeHelper.getTheme<CometChatSearchStyle>(
              context: context, defaultTheme: CometChatSearchStyle.of)
          .merge(widget.searchStyle);
      _themeInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchBloc.close();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: style.backgroundColor ?? colorPalette.background1,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.padding3 ?? 0,
              horizontal: spacing.padding4 ?? 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Search Bar
  // ===========================================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.padding3 ?? 0),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        keyboardAppearance:
            CometChatThemeHelper.getBrightness(context) == Brightness.dark
                ? Brightness.dark
                : Brightness.light,
        onChanged: (val) => _searchBloc.add(SearchTextChanged(val)),
        style: TextStyle(
          color: style.searchTextColor ?? colorPalette.textPrimary,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(style.searchTextStyle).copyWith(color: style.searchTextColor),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding3 ?? 0,
            vertical: spacing.padding2 ?? 0,
          ),
          hintText: (widget.user != null || widget.group != null)
              ? "${cc.Translations.of(context).search} in ${widget.user?.name ?? widget.group?.name ?? ""}"
              : cc.Translations.of(context).search,
          prefixIcon: GestureDetector(
            onTap: widget.onBack ?? () => Navigator.of(context).pop(),
            child: widget.searchBackIcon ??
                Icon(Icons.arrow_back,
                    color: style.searchBackIconColor ??
                        colorPalette.iconSecondary,
                    size: 24),
          ),
          suffixIcon: BlocBuilder<SearchBloc, SearchState>(
            bloc: _searchBloc,
            buildWhen: (p, c) => p.searchText.isEmpty != c.searchText.isEmpty,
            builder: (context, state) {
              if (state.searchText.isEmpty) {
                return const SizedBox(width: 24);
              }
              return GestureDetector(
                onTap: () {
                  _textController.clear();
                  _searchBloc.add(const SearchTextChanged(''));
                },
                child: widget.searchClearIcon ??
                    Icon(Icons.close,
                        color: style.searchClearIconColor ??
                            colorPalette.iconSecondary,
                        size: 24),
              );
            },
          ),
          hintStyle: TextStyle(
            color: style.searchPlaceHolderTextColor ??
                colorPalette.textTertiary,
            fontSize: typography.heading4?.regular?.fontSize,
            fontWeight: typography.heading4?.regular?.fontWeight,
            fontFamily: typography.heading4?.regular?.fontFamily,
          )
              .merge(style.searchPlaceHolderTextStyle)
              .copyWith(color: style.searchPlaceHolderTextColor),
          focusedBorder: _searchBorder(),
          enabledBorder: _searchBorder(),
          border: _searchBorder(),
          fillColor:
              style.searchBackgroundColor ?? colorPalette.background3,
          filled: true,
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder() {
    return OutlineInputBorder(
      borderSide: style.searchBorder ??
          BorderSide(
              color: colorPalette.borderDark ?? Colors.transparent, width: 1),
      borderRadius: style.searchBorderRadius ??
          BorderRadius.circular(spacing.radiusMax ?? 0),
    );
  }

  // ===========================================================================
  // Filter Chips
  // ===========================================================================

  Widget _buildFilterChips() {
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      buildWhen: (p, c) =>
          p.visibleFilters != c.visibleFilters ||
          p.selectedFilters != c.selectedFilters,
      builder: (context, state) {
        if (state.visibleFilters.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.padding3 ?? 0),
          child: Wrap(
            spacing: spacing.padding2 ?? 0,
            runSpacing: spacing.padding2 ?? 0,
            children: state.visibleFilters.map((filter) {
              final isSelected =
                  state.selectedFilters.contains(filter.label);
              return SearchFilterChip(
                label: filter.label,
                icon: filter.icon,
                isSelected: isSelected,
                onTap: () =>
                    _searchBloc.add(SearchFilterToggled(filter.label)),
                colorPalette: colorPalette,
                spacing: spacing,
                typography: typography,
                selectedColor: style.searchFilterChipSelectedBackgroundColor,
                unselectedColor: style.searchFilterChipBackgroundColor,
                selectedTextColor: style.searchFilterChipSelectedTextColor,
                unselectedTextColor: style.searchFilterChipTextColor,
                selectedBorder: style.searchFilterChipSelectedBorder,
                unSelectedBorder: style.searchFilterChipBorder,
                borderRadius: style.searchFilterChipBorderRadius,
                selectedTextStyle: style.searchFilterChipSelectedTextStyle,
                textStyle: style.searchFilterChipTextStyle,
                selectedIconColor: style.searchFilterSelectedIconColor,
                unselectedIconColor: style.searchFilterIconColor,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Results Area
  // ===========================================================================

  Widget _buildResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state.isInitial) {
          return widget.initialStateView?.call(context) ??
              const SizedBox.shrink();
        }

        if (state.bothActive && state.allLoading) {
          return widget.loadingStateView?.call(context) ??
              _buildLoadingView();
        }

        if (state.bothActive && state.allEmpty) {
          return widget.emptyStateView?.call(context) ??
              _buildEmptyView(state);
        }

        if (state.bothActive && state.allError) {
          return widget.errorStateView?.call(context) ??
              _buildErrorView();
        }

        if (state.shouldShowNoResults()) {
          return widget.emptyStateView?.call(context) ??
              _buildEmptyView(state);
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (state.showConversations)
              ..._buildConversationsSlivers(state),
            if (state.showMessages)
              ..._buildMessagesSlivers(state),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Conversations Section (Sliver-based for lazy rendering)
  // ===========================================================================

  List<Widget> _buildConversationsSlivers(SearchState state) {
    if (!state.bothActive && state.conversationsStatus == SearchStatus.loading) {
      return [
        SliverFillRemaining(
          child: widget.loadingStateView?.call(context) ?? _buildLoadingView(),
        ),
      ];
    }

    if (!state.bothActive &&
        state.conversationsStatus != SearchStatus.loading &&
        state.conversations.isEmpty) {
      return [
        SliverFillRemaining(
          child: widget.emptyStateView?.call(context) ?? _buildEmptyView(state),
        ),
      ];
    }

    if (!state.bothActive && state.conversationsStatus == SearchStatus.error) {
      return [
        SliverFillRemaining(
          child: widget.errorStateView?.call(context) ?? _buildErrorView(),
        ),
      ];
    }

    if (state.conversations.isEmpty) return [];

    final itemCount = state.selectedFilters.isNotEmpty
        ? (state.hasMoreConversations
            ? state.conversations.length + 1
            : state.conversations.length)
        : state.conversations.length;

    return [
      SliverToBoxAdapter(
        child: _sectionHeader(cc.Translations.of(context).chats),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (state.selectedFilters.isNotEmpty &&
                index >= state.conversations.length) {
              _searchBloc.add(const LoadMoreConversationResults());
              return _buildSectionLoading();
            }
            return _buildConversationItem(state.conversations[index]);
          },
          childCount: itemCount,
        ),
      ),
      if (state.selectedFilters.isEmpty &&
          state.conversations.isNotEmpty &&
          state.conversations.length >= 3 &&
          state.hasMoreConversations)
        SliverToBoxAdapter(
          child: _seeMoreButton(
            onTap: () =>
                _searchBloc.add(const LoadMoreConversationResults()),
          ),
        ),
    ];
  }

  Widget _buildConversationItem(Conversation conversation) {
    if (widget.conversationItemView != null) {
      return widget.conversationItemView!(context, conversation) ??
          const SizedBox.shrink();
    }

    User? conversationWithUser;
    Group? conversationWithGroup;
    if (conversation.conversationWith is User) {
      conversationWithUser = conversation.conversationWith as User;
    } else {
      conversationWithGroup = conversation.conversationWith as Group;
    }

    final statusIndicatorUtils =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
      context: context,
      isSelected: false,
      user: conversationWithUser,
      group: conversationWithGroup,
      onlineStatusIndicatorColor: colorPalette.success,
      privateGroupIcon: null,
      protectedGroupIcon: null,
      privateGroupIconBackground: null,
      protectedGroupIconBackground: null,
      usersStatusVisibility: widget.usersStatusVisibility ?? true,
      groupTypeVisibility: widget.groupTypeVisibility ?? true,
    );

    // Subtitle
    Widget? subtitle;
    if (widget.conversationSubtitleView != null) {
      subtitle = widget.conversationSubtitleView!(context, conversation);
    } else {
      subtitle = _getConversationSubtitle(conversation);
    }

    // Tail
    Widget? tail;
    if (widget.conversationTailView != null) {
      tail = widget.conversationTailView!(context, conversation);
    } else {
      tail = _getConversationTail(conversation);
    }

    return GestureDetector(
      onTap: () async {
        widget.onConversationClicked?.call(conversation);
        // After the user returns from the conversation, re-trigger the search
        // to refresh results (e.g., unread filter should exclude now-read chats).
        // Wait for the next frame to ensure navigation has completed.
        await WidgetsBinding.instance.endOfFrame;
        if (mounted && !_searchBloc.isClosed) {
          _searchBloc.add(RefreshCurrentSearch());
        }
      },
      child: CometChatListItem(
        avatarHeight: 48,
        avatarWidth: 48,
        id: conversation.conversationId,
        avatarName:
            conversationWithUser?.name ?? conversationWithGroup?.name,
        avatarURL:
            conversationWithUser?.avatar ?? conversationWithGroup?.icon,
        title:
            conversationWithUser?.name ?? conversationWithGroup?.name,
        key: UniqueKey(),
        avatarStyle: style.avatarStyle ?? const CometChatAvatarStyle(),
        statusIndicatorColor: statusIndicatorUtils.statusIndicatorColor,
        statusIndicatorIcon: statusIndicatorUtils.icon,
        statusIndicatorStyle: CometChatStatusIndicatorStyle(
          border: Border.all(
            width: spacing.spacing ?? 0,
            color: colorPalette.background1 ?? Colors.transparent,
          ),
          backgroundColor: colorPalette.success,
        ),
        hideSeparator: true,
        contentPadding: EdgeInsets.zero,
        style: ListItemStyle(
          background: style.searchConversationItemBackgroundColor ??
              colorPalette.transparent,
          titleStyle: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: typography.heading4?.medium?.fontSize,
            fontWeight: typography.heading4?.medium?.fontWeight,
            fontFamily: typography.heading4?.medium?.fontFamily,
            color: style.searchConversationTitleTextColor ??
                colorPalette.textPrimary,
          )
              .merge(style.searchConversationTitleTextStyle)
              .copyWith(color: style.searchConversationTitleTextColor),
          padding: EdgeInsets.symmetric(vertical: spacing.padding3 ?? 0),
        ),
        subtitleView: subtitle,
        tailView: tail,
        leadingStateView: widget.conversationLeadingView != null
            ? widget.conversationLeadingView!(context, conversation)
            : null,
        titleView: widget.conversationTitleView != null
            ? widget.conversationTitleView!(context, conversation)
            : null,
      ),
    );
  }

  Widget _getConversationSubtitle(Conversation conversation) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) return const SizedBox.shrink();

    final subtitleStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
      color: style.searchConversationSubtitleTextColor ??
          colorPalette.textSecondary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
    )
        .merge(style.searchConversationSubtitleTextStyle)
        .copyWith(color: style.searchConversationSubtitleTextColor);

    return ConversationSubtitleUtils.getConversationSubtitle(
      conversation,
      context,
      subtitleStyle,
      colorPalette.iconSecondary ?? Colors.grey,
    );
  }

  Widget _getConversationTail(Conversation conversation) {
    final lastMessage = conversation.lastMessage;
    final lastMessageTime = lastMessage?.updatedAt ?? lastMessage?.sentAt;
    final unreadCount = conversation.unreadMessageCount;

    return Padding(
      padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastMessageTime != null)
            Flexible(
              child: CometChatDate(
                date: lastMessageTime,
                padding: const EdgeInsets.all(0),
                isTransparentBackground: true,
                style: CometChatDateStyle(
                  backgroundColor: colorPalette.transparent,
                  textStyle: TextStyle(
                    color: style.searchMessageDateTextColor ??
                        colorPalette.textSecondary,
                    fontSize: typography.caption1?.regular?.fontSize,
                    fontWeight: typography.caption1?.regular?.fontWeight,
                    fontFamily: typography.caption1?.regular?.fontFamily,
                  ).merge(style.searchMessageDateTextStyle),
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                pattern: DateTimePattern.dayDateTimeFormat,
                dateTimeFormatterCallback:
                    widget.timeSeparatorFormatterCallback,
              ),
            ),
          const SizedBox(height: 6.5),
          if ((unreadCount ?? 0) > 0)
            Flexible(
              child: CometChatBadge(
                count: unreadCount ?? 0,
                height: 20,
                style: style.badgeStyle ?? const CometChatBadgeStyle(),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Messages Section (Sliver-based for lazy rendering)
  // ===========================================================================

  List<Widget> _buildMessagesSlivers(SearchState state) {
    if (!state.bothActive && state.messagesStatus == SearchStatus.loading) {
      return [
        SliverFillRemaining(
          child: widget.loadingStateView?.call(context) ?? _buildLoadingView(),
        ),
      ];
    }

    if (!state.bothActive &&
        state.messagesStatus != SearchStatus.loading &&
        state.messages.isEmpty) {
      return [
        SliverFillRemaining(
          child: widget.emptyStateView?.call(context) ?? _buildEmptyView(state),
        ),
      ];
    }

    if (!state.bothActive && state.messagesStatus == SearchStatus.error) {
      return [
        SliverFillRemaining(
          child: widget.errorStateView?.call(context) ?? _buildErrorView(),
        ),
      ];
    }

    if (state.messages.isEmpty) return [];

    final itemCount = state.selectedFilters.isNotEmpty
        ? (state.hasMoreMessages
            ? state.messages.length + 1
            : state.messages.length)
        : state.messages.length;

    return [
      SliverToBoxAdapter(
        child: _sectionHeader(cc.Translations.of(context).message),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (state.selectedFilters.isNotEmpty &&
                index >= state.messages.length) {
              _searchBloc.add(const LoadMoreMessageResults());
              return _buildSectionLoading();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getDateSeparator(index, state.messages),
                _buildMessageItem(state.messages[index], index, state),
              ],
            );
          },
          childCount: itemCount,
        ),
      ),
      if (state.selectedFilters.isEmpty &&
          state.messages.isNotEmpty &&
          state.messages.length >= 3 &&
          state.hasMoreMessages)
        SliverToBoxAdapter(
          child: _seeMoreButton(
            onTap: () => _searchBloc.add(const LoadMoreMessageResults()),
          ),
        ),
    ];
  }

  Widget _buildMessageItem(BaseMessage message, int index, SearchState state) {
    if (message.deletedAt != null) return const SizedBox.shrink();

    // Check custom view slots by message type
    Widget? customView;
    if (message is TextMessage && widget.searchTextMessageView != null) {
      customView = widget.searchTextMessageView!(context, message);
    } else if (message is MediaMessage) {
      final type = message.type;
      if (type == MessageTypeConstants.image &&
          widget.searchImageMessageView != null) {
        customView = widget.searchImageMessageView!(context, message);
      } else if (type == MessageTypeConstants.video &&
          widget.searchVideoMessageView != null) {
        customView = widget.searchVideoMessageView!(context, message);
      } else if (type == MessageTypeConstants.file &&
          widget.searchFileMessageView != null) {
        customView = widget.searchFileMessageView!(context, message);
      } else if (type == MessageTypeConstants.audio &&
          widget.searchAudioMessageView != null) {
        customView = widget.searchAudioMessageView!(context, message);
      }
    }

    if (customView != null) {
      return GestureDetector(
        onTap: () => widget.onMessageClicked?.call(message),
        child: customView,
      );
    }

    // Route to type-specific layout matching legacy buildMessageTypeBubble
    return _buildMessageTypeBubble(message);
  }

  /// Routes each message to the correct visual layout based on message.type.
  /// Matches the legacy SearchUtils.buildMessageTypeBubble pattern.
  Widget _buildMessageTypeBubble(BaseMessage message) {
    final senderName = _getMessageSenderName(message);

    switch (message.type) {
      case MessageTypeConstants.text:
        return _buildSearchItem(
          message: message,
          title: senderName,
          subtitle: (message as TextMessage).text,
          trailing: _buildMessageDate(message),
        );

      case MessageTypeConstants.image:
        final mediaMsg = message as MediaMessage;
        final imageUrl = mediaMsg.attachment?.fileUrl;
        return _buildSearchItem(
          message: message,
          title: senderName,
          subtitle: mediaMsg.attachment?.fileName ?? cc.Translations.of(context).messageImage,
          trailing: imageUrl != null
              ? CometChatImageBubble(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  style: const CometChatImageBubbleStyle(
                    borderRadius: BorderRadius.zero,
                  ),
                  colorPalette: colorPalette,
                  spacing: spacing,
                )
              : _buildMessageDate(message),
        );

      case MessageTypeConstants.video:
        final mediaMsg = message as MediaMessage;
        final videoUrl = mediaMsg.attachment?.fileUrl;
        final thumbnailUrl = _getThumbnailUrl(mediaMsg);
        return _buildSearchItem(
          message: message,
          title: senderName,
          subtitle: mediaMsg.attachment?.fileName ?? cc.Translations.of(context).messageVideo,
          trailing: videoUrl != null
              ? SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CometChatVideoBubble(
                        videoUrl: videoUrl,
                        thumbnailUrl: thumbnailUrl,
                        width: 80,
                        height: 80,
                        colorPalette: colorPalette,
                        spacing: spacing,
                        placeHolder: thumbnailUrl == null
                            ? Container(
                                color: colorPalette.background3,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.videocam,
                                  color: colorPalette.iconSecondary,
                                  size: 32,
                                ),
                              )
                            : null,
                      ),
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorPalette.neutral900?.withOpacity(0.6),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: 25,
                          color: colorPalette.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildMessageDate(message),
        );

      case MessageTypeConstants.file:
        final mediaMsg = message as MediaMessage;
        return _buildSearchItem(
          message: message,
          title: senderName,
          subtitle: mediaMsg.attachment?.fileName ?? cc.Translations.of(context).messageFile,
          leading: Image.asset(
            _getFileIconForUrl(mediaMsg.attachment?.fileUrl),
            height: 32,
            width: 32,
            package: UIConstants.packageName,
          ),
          trailing: _buildMessageDate(message),
        );

      case MessageTypeConstants.audio:
        final mediaMsg = message as MediaMessage;
        return _buildSearchItem(
          message: message,
          title: senderName,
          subtitle: mediaMsg.attachment?.fileName ?? cc.Translations.of(context).messageAudio,
          leading: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: colorPalette.buttonBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: colorPalette.buttonIconColor,
                size: 20,
              ),
            ),
          ),
          trailing: _buildMessageDate(message),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Gets the sender/receiver name for a message row title.
  String _getMessageSenderName(BaseMessage message) {
    return message.sender?.name ?? '';
  }

  /// Extracts thumbnail URL from video message metadata.
  /// Checks the thumbnail-generation extension data for available thumbnails.
  String? _getThumbnailUrl(MediaMessage message) {
    final metadata = message.metadata;
    if (metadata == null) return null;

    final injectedObject = metadata["@injected"] as Map<String, dynamic>?;
    if (injectedObject == null) return null;

    final extensions = injectedObject["extensions"] as Map<String, dynamic>?;
    if (extensions == null) return null;

    final thumbnailData = extensions["thumbnail-generation"] as Map<String, dynamic>?;
    if (thumbnailData == null) return null;

    // First try to get from root level of thumbnail-generation
    String? thumbnailUrl = thumbnailData["url_small"] as String? ??
        thumbnailData["url_medium"] as String? ??
        thumbnailData["url_large"] as String?;

    // Fallback to attachments array if not found at root level
    if (thumbnailUrl == null && thumbnailData["attachments"] != null) {
      final attachments = thumbnailData["attachments"] as List<dynamic>?;
      if (attachments != null) {
        for (final attachment in attachments) {
          if (attachment is Map<String, dynamic> &&
              attachment["error"] == null &&
              attachment["data"] != null) {
            final data = attachment["data"] as Map<String, dynamic>?;
            final thumbnails = data?["thumbnails"] as Map<String, dynamic>?;
            if (thumbnails != null) {
              thumbnailUrl = thumbnails["url_small"] as String? ??
                  thumbnails["url_medium"] as String? ??
                  thumbnails["url_large"] as String?;
              if (thumbnailUrl != null) break;
            }
          }
        }
      }
    }

    return thumbnailUrl;
  }

  /// Resolves the correct file type icon asset based on file URL extension.
  /// Mirrors the logic from CometChatFileBubble._getFileIcon().
  String _getFileIconForUrl(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return AssetConstants.fileUnknown;
    final decoded = Uri.decodeFull(fileUrl);
    final fileName = decoded.split('/').last;
    final parts = fileName.split('.');
    if (parts.length < 2) return AssetConstants.fileUnknown;
    final ext = parts.last.toLowerCase();

    const docExts = ['doc', 'docx', 'md', 'odt', 'abw', 'dot', 'dotx'];
    const sheetExts = ['csv', 'xls', 'xlsx', 'ods', 'tsv', 'xlt', 'xltx', 'numbers'];
    const pdfExts = ['pdf', 'ps', 'eps', 'ai'];
    const audioExts = ['mp3', 'wav', 'ogg', 'flac', 'aac', 'wma', 'aiff', 'm4a', 'mid', 'midi'];
    const videoExts = ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'webm', 'mpg', 'mpeg', '3gp'];
    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp', 'tiff', 'psd', 'heif', 'heic'];
    const zipExts = ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'];
    const pptExts = ['ppt', 'pptx', 'odp', 'key', 'pps', 'ppsx'];
    const txtExts = ['txt', 'wps', 'rtf', 'tex', 'log', 'json', 'xml', 'yaml', 'yml'];

    if (docExts.contains(ext)) return AssetConstants.fileDoc;
    if (sheetExts.contains(ext)) return AssetConstants.fileSpreadsheet;
    if (pdfExts.contains(ext)) return AssetConstants.filePdf;
    if (audioExts.contains(ext)) return AssetConstants.fileAudio;
    if (videoExts.contains(ext)) return AssetConstants.fileVideo;
    if (imageExts.contains(ext)) return AssetConstants.fileImage;
    if (zipExts.contains(ext)) return AssetConstants.fileZip;
    if (pptExts.contains(ext)) return AssetConstants.filePresentation;
    if (txtExts.contains(ext)) return AssetConstants.fileText;

    return AssetConstants.fileUnknown;
  }

  /// Builds a CometChatDate widget for message trailing.
  Widget _buildMessageDate(BaseMessage message) {
    return CometChatDate(
      date: message.sentAt ?? DateTime.now(),
      padding: const EdgeInsets.all(0),
      isTransparentBackground: true,
      style: CometChatDateStyle(
        backgroundColor: colorPalette.transparent,
        textStyle: TextStyle(
          color: style.searchMessageDateTextColor ?? colorPalette.textTertiary,
          fontSize: typography.caption1?.regular?.fontSize,
          fontWeight: typography.caption1?.regular?.fontWeight,
          fontFamily: typography.caption1?.regular?.fontFamily,
        ).merge(style.searchMessageDateTextStyle),
        border: Border.all(width: 0, color: Colors.transparent),
      ),
      pattern: DateTimePattern.dayDateFormat,
      dateTimeFormatterCallback: widget.timeSeparatorFormatterCallback,
    );
  }

  /// Builds a search result item row using the interstellar layout pattern.
  /// leading (optional icon) | title + subtitle | trailing (date or thumbnail)
  Widget _buildSearchItem({
    required BaseMessage message,
    required String title,
    required String subtitle,
    Widget? leading,
    Widget? trailing,
  }) {
    final titleStyle = TextStyle(
      color: style.searchMessageSenderTextColor ?? colorPalette.textPrimary,
      fontSize: typography.heading4?.medium?.fontSize,
      fontWeight: typography.heading4?.medium?.fontWeight,
      fontFamily: typography.heading4?.medium?.fontFamily,
    ).merge(style.searchMessageSenderTextStyle)
        .copyWith(color: style.searchMessageSenderTextColor);

    final subtitleStyle = TextStyle(
      color: style.searchMessagePreviewTextColor ?? colorPalette.textSecondary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
    ).merge(style.searchMessagePreviewTextStyle)
        .copyWith(color: style.searchMessagePreviewTextColor);

    return Semantics(
      button: true,
      label: 'Message from $title',
      child: GestureDetector(
        onTap: () => widget.onMessageClicked?.call(message),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: spacing.padding2 ?? 0),
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null)
                Padding(
                  padding: EdgeInsets.only(right: spacing.padding3 ?? 0),
                  child: leading,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (message.parentMessageId > 0)
                          Padding(
                            padding: EdgeInsets.only(
                                right: spacing.padding1 ?? 2),
                            child: Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                              color: colorPalette.iconSecondary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
                  child: trailing,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDateSeparator(int index, List<BaseMessage> messages) {
    if (messages[index].deletedAt != null) {
      return const SizedBox(height: 0, width: 0);
    }
    // Show separator for first message or when month changes
    if (index == 0 ||
        !_isSameMonth(
          dt1: messages[index].sentAt,
          dt2: messages[index - 1].sentAt,
        )) {
      final date = messages[index].sentAt ?? DateTime.now();
      return Padding(
        padding: EdgeInsets.fromLTRB(0, spacing.padding2 ?? 0, 0, 0),
        child: CometChatDate(
          date: date,
          customDateString:
              '${_monthName(date.month)}, ${date.year}',
          padding: EdgeInsets.zero,
          dateTimeFormatterCallback: widget.dateSeparatorFormatterCallback,
          style: CometChatDateStyle(
            backgroundColor: colorPalette.transparent,
            borderRadius: BorderRadius.zero,
            border: const Border.fromBorderSide(BorderSide.none),
            textStyle: TextStyle(
              fontSize: typography.caption1?.medium?.fontSize,
              fontWeight: typography.caption1?.medium?.fontWeight,
              fontFamily: typography.caption1?.medium?.fontFamily,
              letterSpacing: 0,
              color: colorPalette.textSecondary,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 0, width: 0);
  }

  bool _isSameMonth({DateTime? dt1, DateTime? dt2}) {
    if (dt1 == null || dt2 == null) return false;
    return dt1.year == dt2.year && dt1.month == dt2.month;
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }

  // ===========================================================================
  // Shared Helpers
  // ===========================================================================

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.padding2 ?? 0),
      child: Text(
        title,
        style: TextStyle(
          color: style.sectionHeaderTextColor ?? colorPalette.textSecondary,
          fontSize: typography.caption1?.medium?.fontSize,
          fontWeight: typography.caption1?.medium?.fontWeight,
          fontFamily: typography.caption1?.medium?.fontFamily,
        )
            .merge(style.sectionHeaderTextStyle)
            .copyWith(color: style.sectionHeaderTextColor),
      ),
    );
  }

  Widget _seeMoreButton({required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.padding2 ?? 0),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          cc.Translations.of(context).more,
          style: TextStyle(
            color: style.seeMoreTextColor ?? colorPalette.primary,
            fontSize: typography.body?.medium?.fontSize,
            fontWeight: typography.body?.medium?.fontWeight,
            fontFamily: typography.body?.medium?.fontFamily,
          ).merge(style.seeMoreTextStyle).copyWith(color: style.seeMoreTextColor),
        ),
      ),
    );
  }

  // ===========================================================================
  // State Views
  // ===========================================================================

  Widget _buildLoadingView() {
    return CometChatShimmerEffect(
      colorPalette: colorPalette,
      child: ListView.builder(
        itemCount: 30,
        shrinkWrap: true,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 0,
            vertical: spacing.padding3 ?? 0,
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.4,
                          height: 19,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0),
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          height: 19,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.circular(spacing.radius2 ?? 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(SearchState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding5 ?? 0),
            child: Image.asset(
              AssetConstants.conversationEmpty,
              package: UIConstants.packageName,
              height: 120,
              width: 120,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
            child: Text(
              cc.Translations.of(context).noRecordsFound,
              style: TextStyle(
                color: style.emptyStateTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              ).merge(style.emptyStateTextStyle),
            ),
          ),
          if (state.searchText.isNotEmpty)
            Text(
              '${cc.Translations.of(context).search} "${state.searchText}"',
              style: TextStyle(
                color: style.emptyStateSubTitleTextColor ??
                    colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ).merge(style.emptyStateSubTitleTextStyle),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: spacing.padding5 ?? 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorPalette.error,
            ),
            SizedBox(height: spacing.padding3 ?? 0),
            Text(
              cc.Translations.of(context).somethingWentWrongError,
              style: TextStyle(
                color: style.errorStateTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading4?.medium?.fontSize,
                fontWeight: typography.heading4?.medium?.fontWeight,
                fontFamily: typography.heading4?.medium?.fontFamily,
              ).merge(style.errorStateTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.padding3 ?? 0),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: colorPalette.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
