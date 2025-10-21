import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;
import '../message_list/messages_builder_protocol.dart';

class CometChatAIAssistantChatHistory extends StatefulWidget {
  const CometChatAIAssistantChatHistory({
    super.key,
    this.group,
    this.user,
    this.messagesRequestBuilder,
    this.emptyStateView,
    this.errorStateView,
    this.loadingStateView,
    this.onEmpty,
    this.onError,
    this.onLoad,
    this.onMessageClicked,
    this.onNewChatButtonClicked,
    this.style,
    this.dateSeparatorPattern,
    this.dateTimeFormatterCallback,
    this.emptyStateText,
    this.errorStateText,
    this.onClose,
    this.backButton,
    this.errorStateSubtitleText,
    this.emptyStateSubtitleText,
    this.height,
    this.width,
    this.hideStickyDate,
    this.hideDateSeparator,
  })  : assert(user != null || group != null,
            "One of user or group should be passed"),
        assert(user == null || group == null,
            "Only one of user or group should be passed");

  ///[user] user object  for user message list
  final User? user;

  ///[group] group object  for group list
  final Group? group;

  ///[messagesRequestBuilder] set  custom request builder which will be passed to CometChat's SDK
  final MessagesRequestBuilder? messagesRequestBuilder;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state behind the dialog
  final WidgetBuilder? errorStateView;

  ///onMessageClicked callback when message is clicked
  final void Function(BaseMessage? message)? onMessageClicked;

  ///[onError] callback triggered in case any error happens when fetching users
  final OnError? onError;

  ///[onLoad] callback triggered when list is fetched and load
  final OnLoad<BaseMessage>? onLoad;

  ///[onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  ///onNewChatButtonClicked callback when new chat button is clicked
  final VoidCallback? onNewChatButtonClicked;

  ///[style] sets style for CometChatAIAssistantChatHistory
  final CometChatAIAssistantChatHistoryStyle? style;

  ///[dateSeparatorPattern] pattern for  date separator
  final String Function(DateTime dateTime)? dateSeparatorPattern;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  ///[emptyStateText] text to be displayed when the list is empty
  final String? emptyStateText;

  ///[emptyStateSubtitleText] sub title text to be displayed when empty occur
  final String? emptyStateSubtitleText;

  ///[errorStateText] text to be displayed when error occur
  final String? errorStateText;

  ///[errorStateSubtitleText] sub title text to be displayed when error occur
  final String? errorStateSubtitleText;

  ///[onClose] callback when back button is pressed
  final VoidCallback? onClose;

  ///[backButton] custom back button widget
  final Widget? backButton;

  ///[width] sets width for the list
  final double? width;

  ///[height] sets height for the list
  final double? height;

  ///[hideStickyDate] Hide the sticky date separator
  final bool? hideStickyDate;

  ///[hideDateSeparator] Hide the date separator
  final bool? hideDateSeparator;

  @override
  State<CometChatAIAssistantChatHistory> createState() =>
      _CometChatAIAssistantChatHistoryState();
}

class _CometChatAIAssistantChatHistoryState
    extends State<CometChatAIAssistantChatHistory> {
  late CometChatAIAssistantChatHistoryController
      aiAssistantChatHistoryController;
  late CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle;
  late CometChatDateStyle dateStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    aiAssistantChatHistoryStyle =
        CometChatThemeHelper.getTheme<CometChatAIAssistantChatHistoryStyle>(
      context: context,
      defaultTheme: CometChatAIAssistantChatHistoryStyle.of,
    ).merge(widget.style);
    dateStyle = CometChatThemeHelper.getTheme<CometChatDateStyle>(
      context: context,
      defaultTheme: CometChatDateStyle.of,
    ).merge(aiAssistantChatHistoryStyle.dateSeparatorStyle);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    MessagesRequestBuilder messagesRequestBuilder =
        widget.messagesRequestBuilder ?? MessagesRequestBuilder();

    List<String> categories = [];
    List<String> types = [];

    //only set types and categories when coming from default
    if (widget.messagesRequestBuilder == null) {
      categories = CometChatUIKit.getDataSource().getAllMessageCategories();
      types = CometChatUIKit.getDataSource().getAllMessageTypes();
      messagesRequestBuilder.types = types;
      messagesRequestBuilder.categories = categories;
    }

    if (widget.messagesRequestBuilder == null) {
      messagesRequestBuilder.hideReplies ??= true;
    }

    if (widget.user != null) {
      messagesRequestBuilder.uid = widget.user!.uid;
    } else {
      messagesRequestBuilder.guid = widget.group!.guid;
    }

    //altering message request builder if not coming from props

    aiAssistantChatHistoryController =
        CometChatAIAssistantChatHistoryController(
      user: widget.user,
      group: widget.group,
      onError: widget.onError,
      onLoad: widget.onLoad,
      onEmpty: widget.onEmpty,
      messagesBuilderProtocol: UIMessagesBuilder(messagesRequestBuilder),
      dateSeparatorPattern: widget.dateSeparatorPattern,
      hideStickyDate: widget.hideStickyDate ?? false,
    );

    super.initState();
  }

  // UI methods

  Widget _getList(
    CometChatAIAssistantChatHistoryController controller,
    BuildContext context,
    CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    return GetBuilder(
      init: controller,
      tag: controller.tag,
      builder: (CometChatAIAssistantChatHistoryController value) {
        value.context = context;
        value.colorPalette = colorPalette;
        value.spacing = spacing;
        value.typography = typography;
        if (value.hasError == true) {
          return _showError(
            controller,
            context,
            aiAssistantChatHistoryStyle,
            colorPalette,
            typography,
            spacing,
          );
        } else if (value.isLoading == true && (value.list.isEmpty)) {
          return _getLoadingIndicator(
            context,
            aiAssistantChatHistoryStyle,
            colorPalette,
            spacing,
            controller,
          );
        } else if (value.list.isEmpty) {
          return Center(
            child: _emptyStateView(
              context,
              value,
              colorPalette,
              typography,
              aiAssistantChatHistoryStyle,
            ),
          );
        } else {
          List<GlobalKey> tileKeys =
              List.generate(value.list.length, (index) => GlobalKey());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              newChatView(
                aiAssistantChatHistoryStyle,
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: spacing.padding3 ?? 0),
                  child: Stack(
                    children: [
                      ListView.builder(
                        key: controller.listViewKey,
                        controller: controller.messageListScrollController,
                        itemCount: value.hasMoreItems
                            ? value.list.length + 1
                            : value.list.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index == value.list.length) {
                            value.loadMoreElements();
                            return Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: colorPalette.primary,
                                ),
                              ),
                            );
                          }
                          return Column(
                            key: controller.keys
                                .putIfAbsent(index, () => GlobalKey()),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _getDateSeparator(
                                value,
                                index,
                                context,
                                colorPalette,
                                typography,
                                spacing,
                              ),
                              SizedBox(
                                key: tileKeys[index],
                                child: _getMessageWidget(
                                  value.list[index],
                                  value,
                                  context,
                                  aiAssistantChatHistoryStyle,
                                  colorPalette,
                                  typography,
                                  spacing,
                                  tileKeys[index],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: value.stickyDateNotifier.value != null
                            ? Center(
                                child: _buildStickyDateHeader(
                                  value,
                                  colorPalette,
                                  typography,
                                  spacing,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _getLoadingIndicator(
    BuildContext context,
    CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatAIAssistantChatHistoryController aiAssistantChatHistoryController,
  ) {
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
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(
                    spacing.radius2 ?? 0,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  bool _isSameDate({
    DateTime? dt1,
    DateTime? dt2,
  }) {
    if (dt1 == null || dt2 == null) return true;
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  Widget _getDateSeparator(
    CometChatAIAssistantChatHistoryController controller,
    int index,
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (widget.hideDateSeparator == true) {
      return const SizedBox.shrink();
    }
    if (controller.list[index].deletedAt != null) {
      return const SizedBox.shrink();
    }
    String? customDateString;
    final DateTime? currentDate = controller.list[index].sentAt;

    if (widget.dateSeparatorPattern != null && currentDate != null) {
      customDateString = widget.dateSeparatorPattern!(currentDate);
    }

    // Show separator for the first item or when date changes from previous message
    if (index == 0 ||
        !_isSameDate(
          dt1: currentDate,
          dt2: controller.list[index - 1].sentAt,
        )) {
      return CometChatDate(
        date: currentDate,
        pattern: DateTimePattern.dayDateFormat,
        customDateString: customDateString,
        dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
        style: CometChatDateStyle(
          backgroundColor: colorPalette.background3,
          border: Border.all(
            color: colorPalette.transparent ?? Colors.transparent,
            width: 0,
          ),
          borderRadius: BorderRadius.circular(spacing.radius1 ?? 0),
          textStyle: TextStyle(
            fontSize: typography.caption1?.medium?.fontSize,
            fontWeight: typography.caption1?.medium?.fontWeight,
            fontFamily: typography.caption1?.medium?.fontFamily,
            letterSpacing: 0,
            color: colorPalette.textTertiary,
          ),
        ).merge(dateStyle),
        padding: EdgeInsets.symmetric(
          vertical: spacing.padding2 ?? 0,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStickyDateHeader(
    CometChatAIAssistantChatHistoryController controller,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (widget.hideStickyDate == true) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<DateTime?>(
        valueListenable: controller.stickyDateNotifier,
        builder: (context, stickyDate, child) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, spacing.padding2 ?? 0, 0, 0),
            child: CometChatDate(
              date: stickyDate,
              pattern: DateTimePattern.dayDateFormat,
              customDateString: controller.stickyDateString,
              style: CometChatDateStyle(
                backgroundColor: colorPalette.background3,
                borderRadius: BorderRadius.circular(spacing.radius1 ?? 0),
                border: Border.all(
                  color: colorPalette.transparent ?? Colors.transparent,
                  width: 0,
                ),
                textStyle: TextStyle(
                  fontSize: typography.caption1?.medium?.fontSize,
                  fontWeight: typography.caption1?.medium?.fontWeight,
                  fontFamily: typography.caption1?.medium?.fontFamily,
                  letterSpacing: 0,
                  color: colorPalette.textTertiary,
                ),
              ).merge(dateStyle),
              padding: EdgeInsets.symmetric(
                vertical: spacing.padding2 ?? 0,
              ),
            ),
          );
        });
  }

  Widget _showError(
    CometChatAIAssistantChatHistoryController aiAssistantChatHistoryController,
    BuildContext context,
    CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    String error;
    if (aiAssistantChatHistoryController.error != null &&
        aiAssistantChatHistoryController.error is CometChatException) {
      error = Utils.getErrorTranslatedText(
        context,
        (aiAssistantChatHistoryController.error as CometChatException).code,
      );
    } else {
      error = cc.Translations.of(context).noMessagesFound;
    }
    if (widget.errorStateView != null) {
      return widget.errorStateView!(context);
    } else {
      return UIStateUtils.getDefaultErrorStateView(
        context,
        colorPalette,
        typography,
        spacing,
        aiAssistantChatHistoryController.loadMoreElements,
        errorStateText: widget.errorStateText,
        errorStateSubtitle: widget.errorStateSubtitleText,
        errorStateTextColor: aiAssistantChatHistoryStyle.errorStateTextColor,
        errorStateTextStyle: aiAssistantChatHistoryStyle.errorStateTextStyle,
        errorStateSubtitleColor:
            aiAssistantChatHistoryStyle.errorStateSubtitleColor,
        errorStateSubtitleStyle:
            aiAssistantChatHistoryStyle.errorStateSubtitleStyle,
      );
    }
  }

  Widget _emptyStateView(
    BuildContext context,
    CometChatAIAssistantChatHistoryController aiAssistantChatHistoryController,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle,
  ) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New Chat at top-left
        newChatView(aiAssistantChatHistoryStyle),

        // Spacer to push the rest to center
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacing.padding3 ?? 12),
                    child: Image.asset(
                      AssetConstants(
                              CometChatThemeHelper.getBrightness(context))
                          .messagesError,
                      package: UIConstants.packageName,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                Text(
                  widget.emptyStateText ??
                      cc.Translations.of(context).noConversationHistoryFound,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: aiAssistantChatHistoryStyle.emptyStateTextColor ??
                        colorPalette.textPrimary,
                    fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                    fontFamily: typography.body?.regular?.fontFamily,
                  )
                      .merge(aiAssistantChatHistoryStyle.emptyStateTextStyle)
                      .copyWith(
                        color: aiAssistantChatHistoryStyle.emptyStateTextColor,
                      ),
                ),
                Text(
                  widget.emptyStateSubtitleText ??
                      cc.Translations.of(context).startChatByTappingNewChat,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: aiAssistantChatHistoryStyle.emptyStateTextColor ??
                        colorPalette.textPrimary,
                    fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                    fontFamily: typography.body?.regular?.fontFamily,
                  )
                      .merge(
                          aiAssistantChatHistoryStyle.emptyStateSubtitleStyle)
                      .copyWith(
                        color:
                            aiAssistantChatHistoryStyle.emptyStateSubtitleColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getMessageWidget(
    BaseMessage messageObject,
    CometChatAIAssistantChatHistoryController controller,
    BuildContext context,
    CometChatAIAssistantChatHistoryStyle style,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    GlobalKey key,
  ) {
    if (messageObject.deletedAt != null) {
      return const SizedBox.shrink();
    }
    if (messageObject is TextMessage) {
      return GestureDetector(
        key: UniqueKey(),
        onTap: () {
          if (widget.onMessageClicked != null) {
            widget.onMessageClicked!(messageObject);
          }
        },
        onLongPress: () {
          controller.showPopupMenu(
            context,
            [
              CometChatOption(
                id: ConversationOptionConstants.delete,
                icon: AssetConstants.delete,
                packageName: UIConstants.packageName,
                backgroundColor: colorPalette.background1,
                iconTint: colorPalette.error,
                title: cc.Translations.of(context).delete,
                onClick: () {
                  controller.deleteMessage(messageObject);
                },
              ),
            ],
            key,
            messageObject,
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.padding3 ?? 0,
            ),
            child: Text(
              messageObject.text,
              maxLines: 1,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
                color: colorPalette.textPrimary,
              )
                  .merge(
                    aiAssistantChatHistoryStyle.itemTextStyle,
                  )
                  .copyWith(
                    color: aiAssistantChatHistoryStyle.itemTextColor,
                  ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget newChatView(
      CometChatAIAssistantChatHistoryStyle aiAssistantChatHistoryStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 0),
      child: GestureDetector(
        onTap: widget.onNewChatButtonClicked,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding4 ?? 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: spacing.padding2 ?? 0,
                ),
                child: Icon(
                  Icons.add,
                  color: aiAssistantChatHistoryStyle.newChatIconColor ??
                      colorPalette.iconSecondary,
                  size: 24,
                ),
              ),
              Text(
                cc.Translations.of(context).newChat,
                style: TextStyle(
                  color: colorPalette.textPrimary,
                  fontSize: typography.button?.regular?.fontSize,
                  fontWeight: typography.button?.regular?.fontWeight,
                  fontFamily: typography.button?.regular?.fontFamily,
                )
                    .merge(
                      aiAssistantChatHistoryStyle.newChaTitleStyle,
                    )
                    .copyWith(
                      color: aiAssistantChatHistoryStyle.newChatTextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CometChatListBase(
      title: cc.Translations.of(context).chatHistory,
      showBackButton: true,
      titleSpacing: spacing.padding1,
      backIcon: widget.backButton ??
          GestureDetector(
            onTap: () {
              if (widget.onClose != null) {
                widget.onClose!();
              }
            },
            child: Icon(
              Icons.close,
              size: 24,
              color: aiAssistantChatHistoryStyle.closeIconColor ??
                  colorPalette.iconSecondary,
            ),
          ),
      leadingIconPadding: EdgeInsets.only(
        left: spacing.padding ?? 0,
      ),
      hideSearch: true,
      style: ListBaseStyle(
          height: widget.height,
          width: widget.width,
          background: aiAssistantChatHistoryStyle.backgroundColor ??
              colorPalette.background3,
          appBarBackground: aiAssistantChatHistoryStyle.headerBackgroundColor ??
              aiAssistantChatHistoryStyle.backgroundColor ??
              colorPalette.background3,
          titleStyle: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading4?.medium?.fontSize,
            fontWeight: typography.heading4?.medium?.fontWeight,
            fontFamily: typography.heading4?.medium?.fontFamily,
          )
              .merge(
                aiAssistantChatHistoryStyle.headerTitleTextStyle,
              )
              .copyWith(
                color: aiAssistantChatHistoryStyle.headerTitleTextColor,
              ),
          border: aiAssistantChatHistoryStyle.border,
          borderRadius: aiAssistantChatHistoryStyle.borderRadius ??
              BorderRadius.circular(0),
          padding: EdgeInsets.only(
            top: spacing.padding2 ?? 10,
          )),
      container: Column(
        children: [
          Divider(
            color: aiAssistantChatHistoryStyle.separatorColor ??
                colorPalette.borderDefault,
            height: aiAssistantChatHistoryStyle.separatorHeight ?? 1,
          ),
          Expanded(
            child: _getList(
              aiAssistantChatHistoryController,
              context,
              aiAssistantChatHistoryStyle,
              colorPalette,
              typography,
              spacing,
            ),
          ),
        ],
      ),
    );
  }
}
