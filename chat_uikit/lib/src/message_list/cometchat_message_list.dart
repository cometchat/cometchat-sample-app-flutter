import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;
import 'messages_builder_protocol.dart';

typedef ThreadRepliesClick =
    void Function(
      BaseMessage message,
      BuildContext context, {
      CometChatMessageTemplate? template,
    });

///[CometChatMessageList] is a component that lists all messages with the help of appropriate message bubbles
///messages are fetched using [MessagesBuilderProtocol] and [MessagesRequestBuilder]
///fetched messages are listed down in way such that the most recent message will appear at the bottom of the list
///and the user would have to scroll up to see the previous messages sent or received
///and as user scrolls up, messages will be fetched again using [MessagesBuilderProtocol] and [MessagesRequestBuilder] if available
///when a new message is sent it will automatically scroll to the bottom of the list if the user has scrolled to the top
///and when a new message is received then a sticky UI element displaying [newMessageIndicatorText] will show up at the top of the screen if the user has scrolled to the top
///
/// ```dart
///   CometChatMessageList(
///    user: User(uid: 'uid', name: 'name'),
///    group: Group(guid: 'guid', name: 'name', type: 'public'),
///    messageListStyle: MessageListStyle(),
///  );
/// ```
class CometChatMessageList extends StatefulWidget {
  const CometChatMessageList({
    super.key,
    this.errorStateText,
    this.emptyStateText,
    this.stateCallBack,
    this.messagesRequestBuilder,
    this.loadingStateView,
    this.emptyStateView,
    this.errorStateView,
    this.style,
    this.footerView,
    this.headerView,
    this.alignment = ChatAlignment.standard,
    this.group,
    this.user,
    this.customSoundForMessages,
    this.datePattern,
    this.deliveredIcon,
    this.disableSoundForMessages,
    this.hideTimestamp,
    this.templates,
    this.onThreadRepliesClick,
    this.readIcon,
    this.sentIcon,
    this.avatarVisibility = true,
    this.waitIcon,
    this.customSoundForMessagePackage,
    this.dateSeparatorPattern,
    this.scrollController,
    this.onError,
    this.receiptsVisibility = true,
    this.dateSeparatorStyle,
    this.disableReactions = false,
    this.addReactionIcon,
    this.addMoreReactionTap,
    this.favoriteReactions,
    this.textFormatters,
    this.disableMentions,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.reactionsRequestBuilder,
    this.onEmpty,
    this.onLoad,
    this.onReactionClick,
    this.onReactionListItemClick,
    this.onReactionLongPress,
    this.enableConversationStarters = false,
    this.hideCopyMessageOption = false,
    this.hideDeleteMessageOption = false,
    this.hideEditMessageOption = false,
    this.hideGroupActionMessages = false,
    this.hideMessageInfoOption = false,
    this.hideMessagePrivatelyOption = false,
    this.hideReactionOption = false,
    this.hideReplyInThreadOption = false,
    this.enableSmartReplies = false,
    this.hideStickyDate = false,
    this.hideTranslateMessageOption = false,
    this.hideShareMessageOption = false,
    this.smartRepliesDelayDuration = 10000,
    this.smartRepliesKeywords = const [
      'what',
      'when',
      'why',
      'who',
      'where',
      'how',
      '?',
    ],
    this.addTemplate,
    this.dateTimeFormatterCallback,
  })  : assert(user != null || group != null,
            "One of user or group should be passed"),
        assert(user == null || group == null,
            "Only one of user or group should be passed");

  ///[user] user object  for user message list
  final User? user;

  ///[group] group object  for group message list
  final Group? group;

  ///[messagesRequestBuilder] set  custom request builder which will be passed to CometChat's SDK
  final MessagesRequestBuilder? messagesRequestBuilder;

  ///[style] sets style for message list
  final CometChatMessageListStyle? style;

  ///[scrollController] sets controller for the list
  final ScrollController? scrollController;

  ///[emptyStateText] text to be displayed when the list is empty
  final String? emptyStateText;

  ///[errorStateText] text to be displayed when error occur
  final String? errorStateText;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state behind the dialog
  final WidgetBuilder? errorStateView;

  ///[stateCallBack] to access controller functions  from parent pass empty reference of  CometChatUsersController object
  final Function(CometChatMessageListController controller)? stateCallBack;

  ///disables sound for messages sent/received
  final bool? disableSoundForMessages;

  ///asset url to Sound for outgoing message
  final String? customSoundForMessages;

  ///if sending sound url from other package pass package name here
  final String? customSoundForMessagePackage;

  ///custom read icon visible at read receipt
  final Widget? readIcon;

  ///custom delivered icon visible at read receipt
  final Widget? deliveredIcon;

  /// custom sent icon visible at read receipt
  final Widget? sentIcon;

  ///custom wait icon visible at read receipt
  final Widget? waitIcon;

  ///Chat alignments
  final ChatAlignment alignment;

  ///toggle visibility for avatar
  final bool? avatarVisibility;

  ///datePattern custom date pattern visible in receipts , returned string will be visible in receipt's date place
  final String Function(BaseMessage message)? datePattern;

  ///[hideTimestamp] toggle visibility for timestamp
  final bool? hideTimestamp;

  ///[templates]Set templates for message list
  final List<CometChatMessageTemplate>? templates;

  ///call back for click on thread indicator
  final ThreadRepliesClick? onThreadRepliesClick;

  ///[headerView] sets custom widget to header
  final Widget? Function(
    BuildContext, {
    User? user,
    Group? group,
    int? parentMessageId,
  })?
  headerView;

  ///[footerView] sets custom widget to footer
  final Widget? Function(
    BuildContext, {
    User? user,
    Group? group,
    int? parentMessageId,
  })?
  footerView;

  ///[dateSeparatorPattern] pattern for  date separator
  final String Function(DateTime dateTime)? dateSeparatorPattern;

  ///[onError] callback triggered in case any error happens when fetching users
  final OnError? onError;

  ///[receiptsVisibility] controls visibility of read receipts
  final bool? receiptsVisibility;

  ///[dateSeparatorStyle] sets style for date separator
  final CometChatDateStyle? dateSeparatorStyle;

  ///[disableReactions] toggle visibility of reactions
  final bool? disableReactions;

  ///[addReactionIcon] sets custom icon for adding reaction
  final Widget? addReactionIcon;

  ///[addMoreReactionTap] sets custom onTap for adding reaction
  final Function(BaseMessage message)? addMoreReactionTap;

  ///[favoriteReactions] is a list of frequently used reactions
  final List<String>? favoriteReactions;

  ///[textFormatters] is a list of text formatters for message bubbles with type text
  final List<CometChatTextFormatter>? textFormatters;

  ///[disableMentions] disables formatting of mentions in the subtitle of the conversation
  final bool? disableMentions;

  ///[padding] sets padding for the message list
  final EdgeInsetsGeometry? padding;

  ///[margin] sets margin for the message list
  final EdgeInsetsGeometry? margin;

  ///[width] sets width for the message list
  final double? width;

  ///[height] sets height for the message list
  final double? height;

  ///[reactionsRequestBuilder] is used to fetch the reactions of a particular message
  final ReactionsRequestBuilder? reactionsRequestBuilder;

  ///[onLoad] callback triggered when list is fetched and load
  final OnLoad<BaseMessage>? onLoad;

  ///[onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  ///[onReactionClick] This is to override the click of a reaction pill.
  final Function(String? emoji, BaseMessage message)? onReactionClick;

  ///[onReactionLongPress] This is to override when user long presses on a reaction pill.
  final Function(String? emoji, BaseMessage message)? onReactionLongPress;

  ///[onReactionListItemClick] This is to override when a reaction list item is clicked.
  final Function(String? reaction, BaseMessage? message)?
  onReactionListItemClick;

  ///[hideStickyDate] Hide the date separator
  final bool? hideStickyDate;

  ///[hideReplyInThreadOption] This prop defines whether Reply In Thread option should be visible or not.
  final bool? hideReplyInThreadOption;

  ///[hideTranslateMessageOption] This prop defines whether Reply In Thread option should be visible or not.
  final bool? hideTranslateMessageOption;

  ///[hideEditMessageOption] This prop defines whether Edit Message option should be visible or not.
  final bool? hideEditMessageOption;

  ///[hideDeleteMessageOption] This prop defines whether Delete Message option should be visible or not.
  final bool? hideDeleteMessageOption;

  ///[hideReactionOption] This prop defines whether Reaction option should be visible or not.
  final bool? hideReactionOption;

  ///[hideMessagePrivatelyOption] This prop defines whether a user can privately message other member of the group or not.
  final bool? hideMessagePrivatelyOption;

  ///[hideCopyMessageOption] This prop defines whether a user can copy message or not.
  final bool? hideCopyMessageOption;

  ///[hideMessageInfoOption] This prop defines whether a user can fetch information about the message whether it's received or not.
  final bool? hideMessageInfoOption;

  ///[hideGroupActionMessages] This prop defines whether action messages in the chat is visible or not in groups. To stop action messages from being visible in Conversation List, please disable Group Action Message setting from CometChatDashboard.
  final bool? hideGroupActionMessages;

  ///[enableConversationStarters] This will not generate conversation starter in new conversations.
  final bool? enableConversationStarters;

  ///[enableSmartReplies] This will not generate smart replies in the chat.
  final bool? enableSmartReplies;

  ///[hideShareMessageOption] This prop defines whether share option should be visible or not.
  final bool? hideShareMessageOption;

  /// [smartRepliesDelayDuration] The number of milliseconds after which Smart Replies will be triggered.  If set to `0` smart replies will be fetched instantly without any delay.
  final int? smartRepliesDelayDuration;

  /// [smartRepliesKeywords] The keywords present in the incoming message that will trigger Smart Replies. If set to `[]` smart replies will be fetched for all messages.
  final List<String>? smartRepliesKeywords;

  /// [addTemplate] Add Custom message templates on the existing templated.
  final List<CometChatMessageTemplate>? addTemplate;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  @override
  State<CometChatMessageList> createState() => _CometChatMessageListState();
}

class _CometChatMessageListState extends State<CometChatMessageList> {
  late CometChatMessageListController messageListController;

  CometChatMessageOptionSheetStyle? _optionStyle;

  late CometChatMessageListStyle messageListStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    messageListStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(widget.style);
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

    messageListController = CometChatMessageListController(
      customIncomingMessageSound: widget.customSoundForMessages,
      customIncomingMessageSoundPackage: widget.customSoundForMessagePackage,
      disableSoundForMessages: widget.disableSoundForMessages ?? false,
      messagesBuilderProtocol: UIMessagesBuilder(messagesRequestBuilder),
      user: widget.user,
      group: widget.group,
      stateCallBack: widget.stateCallBack,
      messageTypes: widget.templates,
      receiptsVisibility: widget.receiptsVisibility,
      disableReactions: widget.disableReactions ?? false,
      disableMentions: widget.disableMentions ?? false,
      textFormatters: widget.textFormatters,
      mentionsStyle: widget.style?.mentionsStyle,
      messageListStyle: widget.style,
      headerView: widget.headerView,
      footerView: widget.footerView,
      scrollController: widget.scrollController,
      onError: widget.onError,
      onLoad: widget.onLoad,
      onEmpty: widget.onEmpty,
      onReactionClick: widget.onReactionClick,
      smartRepliesDelayDuration: widget.smartRepliesDelayDuration,
      enableConversationStarters: widget.enableConversationStarters,
      enableSmartReplies: widget.enableSmartReplies,
      smartRepliesKeywords: widget.smartRepliesKeywords,
      addTemplate: widget.addTemplate,
      dateSeparatorPattern: widget.dateSeparatorPattern,
    );

    super.initState();
  }

  Widget getMessageWidget(
    BaseMessage messageObject,
    BuildContext context,
    CometChatMessageListStyle style,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    return _getMessageWidget(
      messageObject,
      messageListController,
      context,
      style,
      colorPalette,
      typography,
      spacing,
      hideThreadView: true,
      overridingAlignment: BubbleAlignment.left,
      hideOptions: true,
      hideFooterView: true,
    );
  }

  Widget _getMessageWidget(
    BaseMessage messageObject,
    CometChatMessageListController controller,
    BuildContext context,
    CometChatMessageListStyle style,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing, {
    bool? hideThreadView,
    BubbleAlignment? overridingAlignment,
    bool? hideOptions,
    bool? hideFooterView,
  }) {
    BubbleContentVerifier contentVerifier = controller.checkBubbleContent(
      messageObject,
      widget.alignment,
    );
    Widget bubbleView = const SizedBox();
    if (messageObject.receiver is Group &&
        messageObject.category == MessageCategoryConstants.action &&
        widget.hideGroupActionMessages == true) {
      return bubbleView;
    }
    final outgoingMessageBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatOutgoingMessageBubbleStyle>(
          context: context,
          defaultTheme: CometChatOutgoingMessageBubbleStyle.of,
        ).merge(style.outgoingMessageBubbleStyle);
    final incomingMessageBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatIncomingMessageBubbleStyle>(
          context: context,
          defaultTheme: CometChatIncomingMessageBubbleStyle.of,
        ).merge(style.incomingMessageBubbleStyle);

    if (controller
            .templateMap["${messageObject.category}_${messageObject.type}"]
            ?.bubbleView !=
        null) {
      bubbleView =
          controller
              .templateMap["${messageObject.category}_${messageObject.type}"]
              ?.bubbleView!(
            messageObject,
            context,
            contentVerifier.alignment,
          ) ??
          const SizedBox();
    } else {
      BubbleContentVerifier contentVerifier = controller.checkBubbleContent(
        messageObject,
        widget.alignment,
      );
      CometChatMessageBubbleStyleData? bubbleStyleData =
          BubbleUIBuilder.getBubbleStyle(
            messageObject,
            outgoingMessageBubbleStyle,
            incomingMessageBubbleStyle,
            colorPalette,
          );
      Color? backgroundColor = bubbleStyleData?.backgroundColor;

      Widget? headerView;
      Widget? contentView;
      Widget? bottomView;
      Widget? footerView;
      Widget? statusInfoView;
      if (contentVerifier.showName == true) {
        headerView = getHeaderView(
          messageObject,
          context,
          controller,
          contentVerifier.alignment,
          bubbleStyleData,
          colorPalette,
          typography,
          spacing,
        );
      }

      bottomView = getBottomView(
        messageObject,
        context,
        controller,
        contentVerifier.alignment,
      );

      if (hideFooterView != true && contentVerifier.showFooterView != false) {
        footerView = _getFooterView(
          contentVerifier.alignment,
          messageObject,
          contentVerifier.showReadReceipt,
          controller,
          context,
          style,
          outgoingMessageBubbleStyle,
          incomingMessageBubbleStyle,
          spacing,
        );
      }

      if (contentVerifier.showTime != false ||
          contentVerifier.showReadReceipt != false) {
        statusInfoView = _getStatusInfoView(
          contentVerifier.alignment,
          messageObject,
          contentVerifier.showReadReceipt,
          controller,
          context,
          contentVerifier.showTime,
          colorPalette,
          CometChatThemeHelper.getTypography(context),
          CometChatThemeHelper.getSpacing(context),
          style,
          bubbleStyleData,
        );
      }

      contentView = _getSuitableContentView(
        messageObject,
        context,
        backgroundColor,
        controller,
        messageObject.sender?.uid == controller.loggedInUser?.uid
            ? BubbleAlignment.right
            : BubbleAlignment.left,
        style,
      );

      Widget? leadingView;
      if (contentVerifier.showThumbnail == true &&
          widget.avatarVisibility == true) {
        leadingView = getAvatar(
          messageObject,
          context,
          messageObject.sender,
          style,
          bubbleStyleData?.messageBubbleAvatarStyle,
        );
      }

      if (contentVerifier.showFooterView != false) {
        footerView = _getFooterView(
          contentVerifier.alignment,
          messageObject,
          contentVerifier.showReadReceipt,
          controller,
          context,
          style,
          outgoingMessageBubbleStyle,
          incomingMessageBubbleStyle,
          spacing,
        );
      }

      bubbleView = CometChatMessageBubble(
        style: CometChatMessageBubbleStyle(
          backgroundColor: backgroundColor,
          // widthFlex: 0.8,
          backgroundImage: bubbleStyleData?.messageBubbleBackgroundImage,
          border: bubbleStyleData?.border,
          borderRadius: bubbleStyleData?.borderRadius,
        ),
        headerView: headerView,
        alignment: contentVerifier.alignment,
        contentView: contentView,
        footerView: footerView,
        leadingView: leadingView,
        bottomView: bottomView,
        statusInfoView: statusInfoView,
        threadView:
            messageObject.deletedAt == null && hideThreadView != true
                ? getViewReplies(
                  messageObject,
                  context,
                  backgroundColor,
                  controller,
                  contentVerifier.alignment,
                  bubbleStyleData,
                  colorPalette,
                  typography,
                  spacing,
                )
                : null,
      );
    }

    return Row(
      mainAxisAlignment:
          overridingAlignment == BubbleAlignment.left ||
                  contentVerifier.alignment == BubbleAlignment.left
              ? MainAxisAlignment.start
              : contentVerifier.alignment == BubbleAlignment.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
      children: [
        GestureDetector(
          onLongPress: () async {
            if (hideOptions == true) return;
            FocusManager.instance.primaryFocus?.unfocus();
            if (messageObject.id > 0) {
              await _showOptions(
                messageObject,
                controller,
                colorPalette.background1,
              );
            }
          },
          child: bubbleView,
        ),
      ],
    );
  }

  Widget? getReactionsView(
    BaseMessage message,
    BubbleAlignment? alignment,
    CometChatMessageListController controller,
    CometChatMessageListStyle messageListStyle,
    CometChatOutgoingMessageBubbleStyle? outgoingMessageBubbleStyle,
    CometChatIncomingMessageBubbleStyle? incomingMessageBubbleStyle,
    CometChatSpacing spacing,
  ) {
    List<ReactionCount>? reactionList = message.reactions;

    if (reactionList.isEmpty) {
      return null;
    }

    return Transform.translate(
      offset: const Offset(0, -5),
      child: CometChatReactions(
        reactionList: reactionList,
        alignment: alignment,
        style:
            (message.sender?.uid == controller.loggedInUser?.uid
                ? outgoingMessageBubbleStyle?.messageBubbleReactionStyle
                : incomingMessageBubbleStyle?.messageBubbleReactionStyle) ??
            messageListStyle.reactionsStyle,
        onReactionTap: (reaction) {
          if (widget.onReactionClick != null) {
            widget.onReactionClick!(reaction, message);
          } else {
            if (reaction != null || reaction?.trim() != "") {
              controller.handleReactionPress(message, reaction, reactionList);
            }
          }
        },
        onReactionLongPress: (reaction) {
          if (widget.onReactionLongPress != null) {
            widget.onReactionLongPress!(reaction, message);
          } else {
            _launchReactionList(
              message,
              spacing,
              reaction: reaction,
              reactionListStyle: messageListStyle.reactionListStyle,
            );
          }
        },
      ),
    );
  }

  _launchReactionList(
    BaseMessage message,
    CometChatSpacing spacing, {
    String? reaction,
    CometChatReactionListStyle? reactionListStyle,
  }) {
    showModalBottomSheet<ActionItem>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(spacing.radius6 ?? 0),
        ),
      ),
      builder:
          (BuildContext context) => CometChatReactionList(
            message: message,
            style: reactionListStyle,
            selectedReaction: reaction,
            reactionRequestBuilder: widget.reactionsRequestBuilder,
            onReactionListItemClick: widget.onReactionListItemClick,
          ),
    );
  }

  bool _isSameDate({
    DateTime? dt1,
    DateTime? dt2,
  }) {
    if (dt1 == null || dt2 == null) return true;
    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  Widget _getDateSeparator(
    CometChatMessageListController controller,
    int index,
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (widget.hideStickyDate == true) {
      return const SizedBox.shrink();
    }

    String? customDateString;
    if (widget.dateSeparatorPattern != null &&
        controller.list[index].sentAt != null) {
      customDateString = widget.dateSeparatorPattern!(
        controller.list[index].sentAt!,
      );
    }
    if ((index == controller.list.length - 1) ||
        !(_isSameDate(
          dt1: controller.list[index].sentAt,
          dt2: controller.list[index + 1].sentAt,
        ))) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, spacing.padding2 ?? 0, 0, 0),
        child: CometChatDate(
          date: controller.list[index].sentAt,
          pattern: DateTimePattern.dayDateFormat,
          customDateString: customDateString,
          dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
          style: CometChatDateStyle(
            backgroundColor: colorPalette.background2,
            border: Border.all(
              color:
                  colorPalette.borderDark ??
                  colorPalette.transparent ??
                  Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(spacing.radius1 ?? 0),
            textStyle: TextStyle(
              fontSize: typography.caption2?.medium?.fontSize,
              fontWeight: typography.caption2?.medium?.fontWeight,
              fontFamily: typography.caption2?.medium?.fontFamily,
              letterSpacing: 0,
              color: colorPalette.textPrimary,
            ),
          ).merge(widget.dateSeparatorStyle),
        ),
      );
    } else {
      return const SizedBox(height: 0, width: 0);
    }
  }

  Widget? getHeaderView(
    BaseMessage message,
    BuildContext context,
    CometChatMessageListController controller,
    BubbleAlignment alignment,
    CometChatMessageBubbleStyleData? messageBubbleStyleData,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (controller
            .templateMap["${message.category}_${message.type}"]
            ?.headerView !=
        null) {
      return controller
          .templateMap["${message.category}_${message.type}"]
          ?.headerView!(message, context, alignment);
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getName(
              message,
              context,
              controller,
              messageBubbleStyleData,
              colorPalette,
              typography,
              spacing,
            ),
          ],
        ),
      );
    }
  }

  Widget? getBottomView(
    BaseMessage message,
    BuildContext context,
    CometChatMessageListController controller,
    BubbleAlignment alignment,
  ) {
    if (controller
            .templateMap["${message.category}_${message.type}"]
            ?.bottomView !=
        null) {
      return controller
          .templateMap["${message.category}_${message.type}"]
          ?.bottomView!(message, context, alignment);
    } else {
      return null;
    }
  }

  Widget getName(
    BaseMessage message,
    BuildContext context,
    CometChatMessageListController controller,
    CometChatMessageBubbleStyleData? messageBubbleStyleData,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    return Container(
      padding: EdgeInsets.only(
        right: spacing.padding2 ?? 0,
        left: spacing.padding2 ?? 0,
      ),
      width: MediaQuery.of(context).size.width * 0.65,
      child: Text(
        message.sender!.name,
        style: TextStyle(
          fontSize: typography.caption1?.medium?.fontSize,
          color: colorPalette.primary,
          fontWeight: typography.caption1?.medium?.fontWeight,
          fontFamily: typography.caption1?.medium?.fontFamily,
          letterSpacing: 0,
        ).merge(messageBubbleStyleData?.senderNameTextStyle),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget? getViewReplies(
    BaseMessage messageObject,
    BuildContext context,
    Color? background,
    CometChatMessageListController controller,
    BubbleAlignment alignment,
    CometChatMessageBubbleStyleData? messageBubbleStyleData,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (messageObject.replyCount != 0) {
      String replyText =
          messageObject.replyCount == 1
              ? cc.Translations.of(context).reply
              : cc.Translations.of(context).replies;

      return GestureDetector(
        onTap: () {
          CometChatMessageTemplate? template =
              controller
                  .templateMap["${messageObject.category}_${messageObject.type}"];
          if (widget.onThreadRepliesClick != null) {
            widget.onThreadRepliesClick!(
              messageObject,
              context,
              template: template,
            );
          }
        },
        child: Container(
          height: 22,
          padding: EdgeInsets.only(
            left: spacing.padding2 ?? 0,
            right: spacing.padding2 ?? 0,
            top: spacing.padding1 ?? 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
                child: Icon(
                  Icons.subdirectory_arrow_right,
                  color:
                      messageBubbleStyleData
                          ?.threadedMessageIndicatorIconColor ??
                      colorPalette.iconSecondary,
                  size: 16,
                ),
              ),
              Text(
                "${messageObject.replyCount} $replyText",
                style: TextStyle(
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  color: colorPalette.textPrimary,
                ).merge(
                  messageBubbleStyleData?.threadedMessageIndicatorTextStyle,
                ),
              ),
              if (messageObject.unreadRepliesCount > 0)
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: spacing.margin1 ?? 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.padding1 ?? 0,
                  ),
                  decoration: BoxDecoration(
                    color: colorPalette.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${messageObject.unreadRepliesCount}",
                    style: TextStyle(
                      fontSize: typography.caption2?.regular?.fontSize,
                      fontWeight: typography.caption2?.regular?.fontWeight,
                      color: colorPalette.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return null;
    }
  }

  Widget? _getFooterView(
    BubbleAlignment alignment,
    BaseMessage message,
    bool readReceipt,
    CometChatMessageListController controller,
    BuildContext context,
    CometChatMessageListStyle messageListStyle,
    CometChatOutgoingMessageBubbleStyle outgoingMessageBubbleStyle,
    CometChatIncomingMessageBubbleStyle incomingMessageBubbleStyle,
    CometChatSpacing spacing,
  ) {
    if (controller
            .templateMap["${message.category}_${message.type}"]
            ?.footerView !=
        null) {
      return controller
          .templateMap["${message.category}_${message.type}"]
          ?.footerView!(message, context, alignment);
    } else {
      return !(widget.disableReactions ??
              message.category == MessageCategoryConstants.interactive)
          ? getReactionsView(
            message,
            alignment,
            controller,
            messageListStyle,
            outgoingMessageBubbleStyle,
            incomingMessageBubbleStyle,
            spacing,
          )
          : null;
    }
  }

  Widget getTime(
    BaseMessage messageObject, {
    CometChatDateStyle? dateStyle,
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
  }) {
    if (messageObject.sentAt == null) {
      return const SizedBox();
    }

    DateTime lastMessageTime = messageObject.sentAt!;
    return CometChatDate(
      date: lastMessageTime,
      pattern: DateTimePattern.timeFormat,
      customDateString:
          widget.datePattern != null
              ? widget.datePattern!(messageObject)
              : null,
      style: CometChatDateStyle(
        backgroundColor: colorPalette?.white ?? Colors.transparent,
        textStyle: TextStyle(
          color: colorPalette?.neutral200,
          letterSpacing: 0,
          fontSize: typography?.caption2?.regular?.fontSize,
          fontWeight: typography?.caption2?.regular?.fontWeight,
          fontFamily: typography?.caption2?.regular?.fontFamily,
        ),
        border: Border.all(color: Colors.transparent, width: 0),
      ).merge(dateStyle),
    );
  }

  Widget getReceiptIcon(
    BaseMessage message,
    User? loggedInUser,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatMessageListController controller,
    CometChatMessageBubbleStyleData? messageBubbleStyleData,
  ) {
    ReceiptStatus status = MessageReceiptUtils.getReceiptStatus(message);

    return Padding(
      padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
      child: CometChatReceipt(
        status: status,
        size: 16,
        style: messageBubbleStyleData?.messageReceiptStyle,
        deliveredIcon: widget.deliveredIcon,
        readIcon: widget.readIcon,
        sentIcon: widget.sentIcon,
        waitIcon: widget.waitIcon,
      ),
    );
  }

  Widget? _getSuitableContentView(
    BaseMessage messageObject,
    BuildContext context,
    Color? background,
    CometChatMessageListController controller,
    BubbleAlignment alignment,
    CometChatMessageListStyle messageListStyle,
  ) {
    if (controller
            .templateMap["${messageObject.category}_${messageObject.type}"]
            ?.contentView !=
        null) {
      final additionalConfigurations =
          BubbleUIBuilder.getAdditionalConfigurations(
            context,
            messageObject,
            controller.textFormatters,
            messageListStyle.incomingMessageBubbleStyle,
            messageListStyle.outgoingMessageBubbleStyle,
            messageListStyle.actionBubbleStyle,
          );

      return controller
          .templateMap["${messageObject.category}_${messageObject.type}"]
          ?.contentView!(
        messageObject,
        context,
        alignment,
        additionalConfigurations: additionalConfigurations,
      );
    } else {
      return null;
    }
  }

  Widget getAvatar(
    BaseMessage messageObject,
    BuildContext context,
    User? userObject,
    CometChatMessageListStyle messageListStyle,
    CometChatAvatarStyle? globalAvatarStyle,
  ) {
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    return userObject == null
        ? const SizedBox()
        : Padding(
          padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
          child: CometChatAvatar(
            image: userObject.avatar,
            name: userObject.name,
            width: 36,
            height: 36,
            style: messageListStyle.avatarStyle ?? globalAvatarStyle,
          ),
        );
  }

  Future _showOptions(
    BaseMessage message,
    CometChatMessageListController controller,
    Color? backgroundColor,
  ) async {
    if (message.deletedAt != null) {
      return;
    }
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(widget.style);

    final optionStyle =
        CometChatThemeHelper.getTheme<CometChatMessageOptionSheetStyle>(
          context: context,
          defaultTheme: CometChatMessageOptionSheetStyle.of,
        ).merge(listStyle.messageOptionSheetStyle);
    AdditionalConfigurations additionalConfigurations =
        AdditionalConfigurations(
          messageOptionSheetStyle: optionStyle,
          hideReplyInThreadOption: widget.hideReplyInThreadOption,
          hideCopyMessageOption: widget.hideCopyMessageOption,
          hideDeleteMessageOption: widget.hideDeleteMessageOption,
          hideReactionOption: widget.hideReactionOption,
          hideEditMessageOption: widget.hideEditMessageOption,
          hideMessageInfoOption: widget.hideMessageInfoOption,
          hideMessagePrivatelyOption: widget.hideMessagePrivatelyOption,
          hideShareMessageOption: widget.hideShareMessageOption,
          hideTranslateMessageOption: widget.hideTranslateMessageOption,
        );

    if(controller.templateMap["${message.category}_${message.type}"]?.options == null) {
      return;
    }

    List<CometChatMessageOption>? options = controller
        .templateMap["${message.category}_${message.type}"]
        ?.options!(
      controller.loggedInUser!,
      message,
      context,
      controller.group,
      additionalConfigurations,
    );

    if (options != null && options.isNotEmpty) {
      List<ActionItem>? actionOptions = [];
      for (var element in options) {
        Function(BaseMessage message, CometChatMessageListController state)? fn;

        if (element.onItemClick == null) {
          fn = controller.getActionFunction(element.id);
        } else {
          fn = element.onItemClick;
        }

        if (fn
            is Function(
              BaseMessage message,
              CometChatMessageListControllerProtocol state,
            )?) {
          actionOptions.add(element.toActionItemFromFunction(fn));
        }
        _optionStyle = CometChatMessageOptionSheetStyle(
          border: element.messageOptionSheetStyle?.border ?? optionStyle.border,
          borderRadius:
              element.messageOptionSheetStyle?.borderRadius ??
              optionStyle.borderRadius,
          titleColor:
              element.messageOptionSheetStyle?.titleColor ??
              optionStyle.titleColor,
          backgroundColor:
              element.messageOptionSheetStyle?.backgroundColor ??
              optionStyle.backgroundColor,
          iconColor:
              element.messageOptionSheetStyle?.iconColor ??
              optionStyle.iconColor,
          titleTextStyle:
              element.messageOptionSheetStyle?.titleTextStyle ??
              optionStyle.titleTextStyle,
        );
      }

      if (actionOptions.isNotEmpty) {
        ActionItem? item = await showMessageOptionSheet(
          context: context,
          actionItems: actionOptions,
          colorPalette: colorPalette,
          message: message,
          state: controller,
          addReactionIcon: widget.addReactionIcon,
          addReactionIconTap: (message) {
            if (widget.addMoreReactionTap != null) {
              widget.addMoreReactionTap!(message);
            } else {
              controller.addReactionIconTap(message, colorPalette);
            }
          },
          hideReactions:
              widget.disableReactions ??
              message.category == MessageCategoryConstants.interactive,
          hideReactionOption: widget.hideReactionOption,
          favoriteReactions: widget.favoriteReactions,
          onReactionTap: (message, reaction) {
            if (widget.onReactionClick != null) {
              widget.onReactionClick!(reaction, message);
            } else {
              controller.onReactionTap(message, reaction);
            }
          },
          style: CometChatMessageOptionSheetStyle(
            titleTextStyle: _optionStyle?.titleTextStyle,
            iconColor: _optionStyle?.iconColor,
            border: _optionStyle?.border,
            borderRadius: _optionStyle?.borderRadius,
            titleColor: _optionStyle?.titleColor,
            backgroundColor: _optionStyle?.backgroundColor,
          ),
        );

        if (item != null) {
          if (item.id == MessageOptionConstants.replyInThreadMessage) {
            CometChatMessageTemplate? template =
                controller.templateMap["${message.category}_${message.type}"];
            if (widget.onThreadRepliesClick != null && mounted) {
              widget.onThreadRepliesClick!(
                message,
                context,
                template: template,
              );
            }
            return;
          }
          item.onItemClick(message, controller);
        }
      }
    }
  }

  Widget _getLoadingIndicator(
    BuildContext context,
    CometChatMessageListStyle messageListStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatMessageListController controller,
  ) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.padding4 ?? 0),
        child: CometChatShimmerEffect(
          colorPalette: colorPalette,
          child: ListView.builder(
            reverse: true,
            itemCount: 30,
            itemBuilder: (context, index) {
              return Align(
                alignment: controller.getRandomAlignment(),
                child: Container(
                  margin: EdgeInsets.only(bottom: spacing.margin3 ?? 0),
                  decoration: BoxDecoration(
                    color: colorPalette.background1,
                    borderRadius: BorderRadius.circular(spacing.radius3 ?? 0),
                  ),
                  height: controller.getRandomSize(41, 63),
                  width: controller.getRandomSize(154, 286),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _showError(
    CometChatMessageListController controller,
    BuildContext context,
    CometChatMessageListStyle messageListStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    String error;
    if (controller.error != null && controller.error is CometChatException) {
      error = Utils.getErrorTranslatedText(
        context,
        (controller.error as CometChatException).code,
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
        controller.loadMoreElements,
        errorStateText: widget.errorStateText,
        errorStateTextColor: messageListStyle.errorStateTextColor,
        errorStateTextStyle: messageListStyle.errorStateTextStyle,
        errorStateSubtitleColor: messageListStyle.errorStateSubtitleColor,
        errorStateSubtitleStyle: messageListStyle.errorStateSubtitleStyle,
      );
    }
  }

  Widget _getNewMessageBanner(
    CometChatMessageListController controller,
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    if (controller.isScrolled) {
      return Positioned(
        right: 10,
        bottom: 10,
        child: GestureDetector(
          onTap: () {
            controller.messageListScrollController.jumpTo(0.0);
            if (controller.newUnreadMessageCount != 0) {
              controller.markAsRead(controller.list[0]);
            }
          },
          child: Container(
            width: 48,
            height: controller.newUnreadMessageCount != 0 ? null : 48,
            decoration: BoxDecoration(
              color: colorPalette.background3,
              borderRadius: BorderRadius.circular(
                controller.newUnreadMessageCount != 0
                    ? (spacing.radius6 ?? 0)
                    : (spacing.radiusMax ?? 0),
              ),
              border: Border.all(
                color: colorPalette.borderDefault ?? Colors.transparent,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -2,
                  color: Color(0x10182808),
                ),
                BoxShadow(
                  offset: Offset(0, 12),
                  blurRadius: 16,
                  spreadRadius: -4,
                  color: Color(0x10182814),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              vertical: spacing.padding2 ?? 0,
              horizontal: spacing.padding2 ?? 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (controller.newUnreadMessageCount != 0)
                    ? CometChatBadge(count: controller.newUnreadMessageCount)
                    : const SizedBox(),
                Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 24,
                  color: colorPalette.iconSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _getList(
    CometChatMessageListController controller,
    BuildContext context,
    CometChatMessageListStyle messageListStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    return GetBuilder(
      init: controller,
      tag: controller.tag,
      builder: (CometChatMessageListController value) {
        value.context = context;
        if (widget.stateCallBack != null) {
          widget.stateCallBack!(value);
        }

        if (value.hasError == true) {
          return _showError(
            controller,
            context,
            messageListStyle,
            colorPalette,
            typography,
            spacing,
          );
        } else if (value.isLoading == true && (value.list.isEmpty)) {
          return _getLoadingIndicator(
            context,
            messageListStyle,
            colorPalette,
            spacing,
            controller,
          );
        } else if (value.list.isEmpty) {
          return _getNoMessagesIndicator(
            context,
            messageListStyle,
            colorPalette,
            typography,
          );
        } else {
          return Stack(
            children: [
              Column(
                children: [
                  if (value.getHeaderView() != null) value.getHeaderView()!,
                  Expanded(
                    child: ListView.builder(
                      controller: controller.messageListScrollController,
                      reverse: true,
                      itemCount:
                          value.hasMoreItems
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

                        controller.updateStickyDateFromIndex(index, controller.list[index].sentAt);

                        return Column(
                          children: [
                            _getDateSeparator(
                              value,
                              index,
                              context,
                              colorPalette,
                              typography,
                              spacing,
                            ),
                            _getMessageWidget(
                              value.list[index],
                              value,
                              context,
                              messageListStyle,
                              colorPalette,
                              typography,
                              spacing,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (value.getFooterView() != null) value.getFooterView()!,
                ],
              ),

              Positioned(
                top: 10,
                left: 0,
                right: 0,
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

              _getNewMessageBanner(controller, context, colorPalette, spacing),
            ],
          );
        }
      },
    );
  }

  Widget _buildStickyDateHeader(
      CometChatMessageListController controller,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (widget.hideStickyDate == true) {
      return const SizedBox.shrink();
    }

    if(controller.currentIndex == controller.list.length - 1) {
        return const SizedBox.shrink();
    }

    if (_isSameDate(
          dt1: controller.list[controller.currentIndex].sentAt,
          dt2: controller.list[controller.currentIndex + 1].sentAt,
        )) {
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
                backgroundColor: colorPalette.background2,
                border: Border.all(
                  color:
                  colorPalette.borderDark ??
                      colorPalette.transparent ??
                      Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(spacing.radius1 ?? 0),
                textStyle: TextStyle(
                  fontSize: typography.caption2?.medium?.fontSize,
                  fontWeight: typography.caption2?.medium?.fontWeight,
                  fontFamily: typography.caption2?.medium?.fontFamily,
                  letterSpacing: 0,
                  color: colorPalette.textPrimary,
                ),
              ).merge(widget.dateSeparatorStyle),
            ),
          );
        }
      );
    } else {
      return const SizedBox();
    }
  }

  Widget? _getStatusInfoView(
    BubbleAlignment alignment,
    BaseMessage message,
    bool readReceipt,
    CometChatMessageListController controller,
    BuildContext context,
    bool showTime,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    CometChatMessageListStyle messageListStyle,
    CometChatMessageBubbleStyleData? messageBubbleStyleData,
  ) {
    if (controller
            .templateMap["${message.category}_${message.type}"]
            ?.statusInfoView !=
        null) {
      return controller
          .templateMap["${message.category}_${message.type}"]
          ?.statusInfoView!(message, context, alignment);
    } else {
      return Container(
        padding: EdgeInsets.only(
          left:
              (message.category == MessageCategoryConstants.custom &&
                      message.type == ExtensionType.sticker &&
                      message.deletedAt == null)
                  ? (spacing.padding2 ?? 0)
                  : 0,
          top:
              (message.category == MessageCategoryConstants.custom &&
                      message.type == ExtensionType.sticker &&
                      message.deletedAt == null)
                  ? (spacing.padding2 ?? 0)
                  : 0,
          bottom: spacing.padding1 ?? 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration:
                  (message.category == MessageCategoryConstants.custom &&
                          message.type == ExtensionType.sticker &&
                          message.deletedAt == null)
                      ? BoxDecoration(
                        color: colorPalette.black?.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(
                          spacing.radiusMax ?? 0,
                        ),
                      )
                      : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.editedAt != null &&
                      (message.category == MessageCategoryConstants.message &&
                          message.type == MessageTypeConstants.text))
                    Padding(
                      padding: EdgeInsets.only(left: spacing.padding1 ?? 0),
                      child: Text(
                        cc.Translations.of(context).edited,
                        style: TextStyle(
                          color:
                              alignment == BubbleAlignment.right
                                  ? colorPalette.white
                                  : colorPalette.neutral600,
                          fontSize: typography.caption2?.regular?.fontSize,
                          fontWeight: typography.caption2?.regular?.fontWeight,
                          fontFamily: typography.caption2?.regular?.fontFamily,
                        ),
                      ),
                    ),
                  if (widget.hideTimestamp != true && (showTime))
                    getTime(
                      message,
                      dateStyle: CometChatDateStyle(
                        textStyle: TextStyle(
                          color: _getDateColor(
                            message,
                            controller,
                            colorPalette,
                          ),
                          fontSize: typography.caption2?.regular?.fontSize,
                          fontWeight: typography.caption2?.regular?.fontWeight,
                          fontFamily: typography.caption2?.regular?.fontFamily,
                        ),
                      ).merge(messageBubbleStyleData?.messageBubbleDateStyle),
                    ),
                  if (readReceipt != false)
                    getReceiptIcon(
                      message,
                      controller.loggedInUser,
                      colorPalette,
                      spacing,
                      controller,
                      messageBubbleStyleData,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Color? _getDateColor(
    BaseMessage message,
    CometChatMessageListController controller,
    CometChatColorPalette colorPalette,
  ) {
    if (message.sender?.uid == controller.loggedInUser?.uid) {
      return colorPalette.white;
    } else {
      return (message.category == MessageCategoryConstants.custom &&
              message.type == ExtensionType.sticker)
          ? colorPalette.white
          : colorPalette.neutral600;
    }
  }

  Widget _getNoMessagesIndicator(
    BuildContext context,
    CometChatMessageListStyle messageListStyle,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    } else {
      return const SizedBox(width: double.infinity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        border: messageListStyle.border,
        borderRadius: messageListStyle.borderRadius ?? BorderRadius.circular(0),
        color: messageListStyle.backgroundColor ?? colorPalette.background3,
      ),
      child: _getList(
        messageListController,
        context,
        messageListStyle,
        colorPalette,
        typography,
        spacing,
      ),
    );
  }
}
