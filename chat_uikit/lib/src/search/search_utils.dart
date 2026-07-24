import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

class SearchUtils {
  // Common helper for shimmer bars
  static Widget shimmerBar({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // Common helper for extracting receiver name
  static String getReceiverName(BaseMessage message) {
    if (message.receiver is User) return (message.receiver as User).name;
    if (message.receiver is Group) return (message.receiver as Group).name;
    return "";
  }

  // Common text style helper
  static TextStyle getTextStyle(
    TextStyle? base,
    Color? color, {
    FontWeight? weight,
  }) {
    return TextStyle(
      color: color ?? base?.color,
      fontSize: base?.fontSize,
      fontWeight: weight ?? base?.fontWeight,
      fontFamily: base?.fontFamily,
    );
  }

  // Loading View
  static Widget loadingView({
    required BuildContext context,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required CometChatTypography typography,
  }) {
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
                        shimmerBar(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 19,
                          radius: spacing.radius2 ?? 0,
                        ),
                        shimmerBar(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 19,
                          radius: spacing.radius2 ?? 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    shimmerBar(
                      width: double.infinity,
                      height: 16,
                      radius: spacing.radius2 ?? 0,
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

  // Empty View
  static Widget emptyView({
    required BuildContext context,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    required CometChatConversationsSearchController conversationsController,
    required CometChatMessagesSearchController messagesController,
    String? searchText,
    CometChatSearchStyle? style,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Always add spacing for centering when empty view is shown
          // This ensures consistent positioning regardless of which filter was unselected
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding5 ?? 0),
            child: Image.asset(
              AssetConstants.conversationSearchEmpty,
              package: UIConstants.packageName,
              height: 120,
              width: 120,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
            child: Text(
              cc.Translations.of(context).noResults,
              style:
                  getTextStyle(
                        typography.heading3?.bold,
                        colorPalette.textPrimary,
                      )
                      .merge(style?.searchEmptyStateTextStyle)
                      .copyWith(color: style?.searchEmptyStateTextColor),
            ),
          ),
          (searchText != null && searchText.isNotEmpty)
              ? Text(
                  "${cc.Translations.of(context).noResultsFor} \"$searchText\". ${cc.Translations.of(context).tryNewSearch}",
                  style:
                      getTextStyle(
                            typography.body?.regular,
                            colorPalette.textSecondary,
                          )
                          .merge(style?.searchEmptyStateSubtitleStyle)
                          .copyWith(
                            color: style?.searchEmptyStateSubtitleColor,
                          ),
                )
              : Text(
                  cc.Translations.of(context).startTyping,
                  style:
                      getTextStyle(
                            typography.body?.regular,
                            colorPalette.textSecondary,
                          )
                          .merge(style?.searchEmptyStateSubtitleStyle)
                          .copyWith(
                            color: style?.searchEmptyStateSubtitleColor,
                          ),
                ),
        ],
      ),
    );
  }

  // Empty View
  static Widget errorView({
    required BuildContext context,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    required CometChatConversationsSearchController conversationsController,
    required CometChatMessagesSearchController messagesController,
    CometChatSearchStyle? style,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.padding2 ?? 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (conversationsController.hasError || messagesController.hasError)
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Padding(
              padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
              child: Text(
                cc.Translations.of(context).oops,
                style:
                    getTextStyle(
                          typography.heading3?.bold,
                          colorPalette.textPrimary,
                        )
                        .merge(style?.searchErrorStateTextStyle)
                        .copyWith(color: style?.searchErrorStateTextColor),
              ),
            ),
            Text(
              cc.Translations.of(context).somethingWentWrongTryAgain,
              style:
                  getTextStyle(
                        typography.body?.regular,
                        colorPalette.textSecondary,
                      )
                      .merge(style?.searchErrorStateSubtitleStyle)
                      .copyWith(color: style?.searchErrorStateSubtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  // Show More Button
  static Widget seeMoreButton({
    VoidCallback? callback,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    CometChatSearchStyle? style,
    context,
  }) {
    return GestureDetector(
      onTap: callback,
      child: Text(
        cc.Translations.of(context).seeMore,
        style:
            getTextStyle(
                  typography.heading4?.regular,
                  colorPalette.iconHighlight,
                )
                .merge(style?.searchSeeMoreStyle)
                .copyWith(color: style?.searchSeeMoreColor),
      ),
    );
  }

  // Heading title
  static Widget headingTitle({
    required String title,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    CometChatSearchStyle? style,
  }) {
    return Text(
      title,
      style:
          getTextStyle(typography.caption1?.regular, colorPalette.textSecondary)
              .merge(style?.searchSectionHeaderTextStyle)
              .copyWith(color: style?.searchSectionHeaderTextColor),
    );
  }

  // Return subtitle view with typing indicator and receipt icons
  // This method is used to display the subtitle of a conversation item in the list.
  // It includes the typing indicator, receipt icons, and the last message sender's name.
  static Widget getSubtitleView({
    required BuildContext context,
    required Conversation conversation,
    required bool showTypingIndicator,
    required CometChatConversationsSearchController controller,
    required CometChatTypography typography,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    CometChatSearchStyle? style,
    bool? hideThreadIndicator = true,
    String? threadIndicatorText,
    bool? receiptsVisibility,
    CometChatMessageReceiptStyle? receiptStyle,
    Widget? deliveredIcon,
    Widget? sentIcon,
    Widget? readIcon,
    Widget? errorIcon,
    String? typingIndicatorText,
    CometChatTypingIndicatorStyle? typingStyle,
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
                context: context,
                typography: typography,
                colorPalette: colorPalette,
                spacing: spacing,
                conversation: conversation,
                hideReceipt: controller.getHideReceipt(
                  conversation,
                  receiptsVisibility,
                ),
                deliveredIcon: deliveredIcon,
                errorIcon: errorIcon,
                readIcon: readIcon,
                receiptStyle: receiptStyle,
                sentIcon: errorIcon,
              ),
              if (conversation.lastMessage?.parentMessageId != null &&
                  conversation.lastMessage!.parentMessageId > 0)
                Icon(
                  Icons.subdirectory_arrow_right,
                  color: colorPalette.iconSecondary,
                  size: 16,
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: spacing.padding ?? 0,
                  right: spacing.padding ?? 0,
                ),
                child: Text(
                  prefix,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(
                            color:
                                style?.searchConversationTitleSubTextColor ??
                                colorPalette.textSecondary,
                            fontWeight: typography.body?.regular?.fontWeight,
                            fontSize: typography.body?.regular?.fontSize,
                            fontFamily: typography.body?.regular?.fontFamily,
                            letterSpacing: 0,
                          )
                          .merge(style?.searchConversationTitleTextStyle)
                          .copyWith(
                            color: style?.searchConversationTitleSubTextColor,
                          ),
                ),
              ),
            ],
          ),
        if (!showTypingIndicator &&
            hideThreadIndicator != null &&
            hideThreadIndicator != false)
          getReceiptIcon(
            context: context,
            typography: typography,
            colorPalette: colorPalette,
            spacing: spacing,
            conversation: conversation,
            hideReceipt: controller.getHideReceipt(
              conversation,
              receiptsVisibility,
            ),
            deliveredIcon: deliveredIcon,
            errorIcon: errorIcon,
            readIcon: readIcon,
            receiptStyle: receiptStyle,
            sentIcon: errorIcon,
          ),
        if (showTypingIndicator)
          Expanded(
            child: Text(
              typingIndicatorText ??
                  ((conversation.conversationWith is User)
                      ? cc.Translations.of(context).isTyping
                      : "${controller.typingMap[conversation.conversationId]?.sender.name ?? ''} ${cc.Translations.of(context).isTyping}"),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorPalette.textHighlight,
                fontWeight: typography.body?.regular?.fontWeight,
                fontSize: typography.body?.regular?.fontSize,
                fontFamily: typography.body?.regular?.fontFamily,
              ).merge(typingStyle?.textStyle),
            ),
          )
        else
          Expanded(
            child: getSubtitle(
              context: context,
              conversation: conversation,
              controller: controller,
              conversationsStyle: style,
              colorPalette: colorPalette,
              spacing: spacing,
              typography: typography,
            ),
          ),
      ],
    );
  }

  // Return subtitle widget
  static Widget getSubtitle({
    required BuildContext context,
    required Conversation conversation,
    required CometChatConversationsSearchController controller,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required CometChatTypography typography,
    CometChatSearchStyle? conversationsStyle,
  }) {
    TextStyle subtitleStyle =
        TextStyle(
              overflow: TextOverflow.ellipsis,
              color:
                  conversationsStyle?.searchConversationTitleSubTextColor ??
                  colorPalette.textSecondary,
              fontSize: typography.body?.regular?.fontSize,
              fontWeight: typography.body?.regular?.fontWeight,
              fontFamily: typography.body?.regular?.fontFamily,
              letterSpacing: 0,
            )
            .merge(conversationsStyle?.searchConversationSubTitleTextStyle)
            .copyWith(
              color: conversationsStyle?.searchConversationTitleSubTextColor,
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
      colorPalette.iconSecondary,
      additionalConfigurations: configurations,
    );

    return subtitle;
  }

  // Return receipt icon
  static Widget getReceiptIcon({
    required CometChatTypography typography,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required Conversation conversation,
    required context,
    bool? hideReceipt,
    CometChatMessageReceiptStyle? receiptStyle,
    Widget? deliveredIcon,
    Widget? sentIcon,
    Widget? readIcon,
    Widget? errorIcon,
  }) {
    if (hideReceipt != null && hideReceipt) {
      return const SizedBox();
    } else if (conversation.lastMessage != null &&
        conversation.lastMessage?.sender != null &&
        conversation.lastMessage!.deletedAt == null &&
        conversation.lastMessage!.type != "groupMember") {
      ReceiptStatus status = MessageReceiptUtils.getReceiptStatus(
        conversation.lastMessage!,
      );

      return Padding(
        padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
        child: CometChatReceipt(
          status: status,
          style: receiptStyle,
          deliveredIcon:
              deliveredIcon ??
              Icon(
                Icons.done_all,
                color:
                    receiptStyle?.deliveredIconColor ??
                    colorPalette.iconSecondary,
                size: 16,
              ),
          readIcon:
              readIcon ??
              Icon(
                Icons.done_all,
                color:
                    receiptStyle?.readIconColor ?? colorPalette.iconHighlight,
                size: 16,
              ),
          sentIcon:
              sentIcon ??
              Icon(
                Icons.check,
                color:
                    receiptStyle?.sentIconColor ?? colorPalette.iconSecondary,
                size: 16,
              ),
          errorIcon: Icon(
            Icons.error_outlined,
            color: receiptStyle?.errorIconColor ?? colorPalette.error,
            size: 16,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //----------- last message update time and unread message count -----------
  static Widget getTime({
    required CometChatTypography typography,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required Conversation conversation,
    required context,
    DateTimeFormatterCallback? dateTimeFormatterCallback,
    String Function(Conversation conversation)? datePattern,
    EdgeInsetsGeometry? datePadding,
    CometChatSearchStyle? style,
    double? dateHeight,
    double? dateWidth,
    bool? dateBackgroundIsTransparent,
    CometChatDateStyle? datesStyle,
  }) {
    DateTime? lastMessageTime =
        conversation.lastMessage?.updatedAt ?? conversation.lastMessage?.sentAt;
    if (lastMessageTime == null) return const SizedBox();

    String? customDateString;

    if (datePattern != null) {
      customDateString = datePattern(conversation);
    }

    return CometChatDate(
      date: lastMessageTime,
      padding: datePadding ?? const EdgeInsets.all(0),
      height: dateHeight,
      isTransparentBackground: dateBackgroundIsTransparent,
      width: dateWidth,
      style: CometChatDateStyle(
        backgroundColor:
            datesStyle?.backgroundColor ?? colorPalette.transparent,
        textStyle:
            TextStyle(
                  color: datesStyle?.textColor ?? colorPalette.textSecondary,
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                )
                .merge(
                  style?.searchConversationDateTextStyle ??
                      datesStyle?.textStyle,
                )
                .copyWith(
                  color:
                      style?.searchConversationDateTextColor ??
                      datesStyle?.textColor,
                ),
        border:
            datesStyle?.border ??
            Border.all(width: 0, color: Colors.transparent),
        borderRadius: datesStyle?.borderRadius,
        textColor: datesStyle?.textColor,
      ),
      customDateString: customDateString,
      pattern: DateTimePattern.dayDateTimeFormat,
      dateTimeFormatterCallback: dateTimeFormatterCallback,
    );
  }

  // Return unread message count widget
  static Widget getUnreadCount({
    required Conversation conversation,
    context,
    EdgeInsetsGeometry? badgePadding,
    CometChatSearchStyle? style,
    double? badgeWidth,
    double? badgeHeight,
  }) {
    return CometChatBadge(
      count: conversation.unreadMessageCount ?? 0,
      width: badgeWidth,
      height: badgeHeight ?? 20,
      style: style?.badgeStyle ?? const CometChatBadgeStyle(),
      padding: badgePadding,
    );
  }

  static Widget? getLeadingView({
    required Conversation conversation,
    required context,
    Widget? Function(BuildContext context, Conversation conversation)?
    leadingView,
  }) {
    if (leadingView != null) {
      return leadingView(context, conversation);
    }
    return null;
  }

  static Widget? getTitleView({
    required Conversation conversation,
    required context,
    Widget? Function(BuildContext context, Conversation conversation)?
    titleView,
  }) {
    if (titleView != null) {
      return titleView(context, conversation);
    }
    return null;
  }

  static Widget? getTrailingView({
    required Conversation conversation,
    required context,
    required CometChatTypography typography,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    Widget? Function(BuildContext context, Conversation conversation)?
    trailingView,
    CometChatSearchStyle? style,
    DateTimeFormatterCallback? dateTimeFormatterCallback,
  }) {
    if (trailingView != null) {
      return trailingView(context, conversation);
    } else {
      return Padding(
        padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: getTime(
                conversation: conversation,
                context: context,
                typography: typography,
                spacing: spacing,
                colorPalette: colorPalette,
                style: style,
                dateTimeFormatterCallback: dateTimeFormatterCallback,
              ),
            ),
            const SizedBox(height: 6.5),
            Flexible(
              child: getUnreadCount(
                conversation: conversation,
                context: context,
                style: style,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Generic search item builder
  static Widget buildSearchItem({
    required BaseMessage message,
    required String title,
    required String subtitle,
    Widget? trailing,
    Widget? leading,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color? titleColor,
    Color? subtitleColor,
    CometChatSearchStyle? style,
    List<CometChatTextFormatter>? textFormatters,
    context,
  }) {
    return interstellar(
      spacing: spacing,
      colorPalette: colorPalette,
      typography: typography,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(vertical: spacing.padding2 ?? 0),
      leading: leading,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style:
            getTextStyle(
                  titleStyle ?? typography.heading4?.medium,
                  titleColor ?? colorPalette.textPrimary,
                )
                .merge(style?.searchMessageTitleTextStyle)
                .copyWith(color: style?.searchMessageTitleTextColor),
      ),
      subtitle: Row(
        children: [
          if (message.parentMessageId > 0)
            Padding(
              padding: EdgeInsets.only(right: spacing.padding1 ?? 2),
              child: Icon(
                Icons.subdirectory_arrow_right,
                size: 16,
                color: colorPalette.iconSecondary,
              ),
            ),
          Expanded(
            child: (textFormatters != null && textFormatters.isNotEmpty)
                ? RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style:
                          getTextStyle(
                                subtitleStyle ?? typography.body?.regular,
                                subtitleColor ?? colorPalette.textSecondary,
                              )
                              .merge(style?.searchMessageSubTitleTextStyle)
                              .copyWith(
                                color: style?.searchMessageSubTitleTextColor,
                              ),
                      children: FormatterUtils.buildConversationTextSpan(
                        subtitle,
                        textFormatters,
                        context,
                        getTextStyle(
                              subtitleStyle ?? typography.body?.regular,
                              subtitleColor ?? colorPalette.textSecondary,
                            )
                            .merge(style?.searchMessageSubTitleTextStyle)
                            .copyWith(
                              color: style?.searchMessageSubTitleTextColor,
                            ),
                      ),
                    ),
                    textScaler: MediaQuery.textScalerOf(context),
                  )
                : Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style:
                        getTextStyle(
                              subtitleStyle ?? typography.body?.regular,
                              subtitleColor ?? colorPalette.textSecondary,
                            )
                            .merge(style?.searchMessageSubTitleTextStyle)
                            .copyWith(
                              color: style?.searchMessageSubTitleTextColor,
                            ),
                  ),
          ),
        ],
      ),
      trailing: trailing,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      style: style,
      backgroundColor: style?.searchMessageItemBackgroundColor,
    );
  }

  // Build different message type views
  static Widget buildMessageTypeBubble({
    required BuildContext context,
    required BaseMessage message,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
    required CometChatMessagesSearchController controller,
    CometChatSearchStyle? style,
    DateTimeFormatterCallback? timeSeparatorFormatterCallback,
    Widget? Function(BuildContext context, TextMessage message)?
    searchMessageLinkView,
    Widget? Function(BuildContext context, TextMessage message)?
    searchTextMessageView,
    Widget? Function(BuildContext context, MediaMessage message)?
    searchImageMessageView,
    Widget? Function(BuildContext context, MediaMessage message)?
    searchVideoMessageView,
    Widget? Function(BuildContext context, MediaMessage message)?
    searchFileMessageView,
    Widget? Function(BuildContext context, MediaMessage message)?
    searchAudioMessageView,
    Function(BaseMessage message)? onMessageClicked,
  }) {
    if (message.deletedAt != null) {
      return const SizedBox();
    }
    String name = getReceiverName(message);

    switch (message.type) {
      case MessageTypeConstants.text:
        final links = getMessageLinks(message);

        if (links.isNotEmpty &&
            ((links[0]["image"] != null &&
                    links[0]["image"].toString().isNotEmpty) ||
                (links[0]["url"] != null &&
                    links[0]["url"].toString().isNotEmpty) ||
                (links[0]["title"] != null &&
                    links[0]["title"].toString().isNotEmpty) ||
                (links[0]["favicon"] != null &&
                    links[0]["favicon"].toString().isNotEmpty))) {
          if (searchMessageLinkView != null) {
            TextMessage textMessage = message as TextMessage;
            return searchMessageLinkView(context, textMessage)!;
          } else {
            return buildSearchItem(
              message: message,
              contentPadding: EdgeInsets.symmetric(
                vertical: spacing.padding3 ?? 0,
              ),
              leading:
                  ((links[0]["favicon"] != null &&
                          links[0]["favicon"].toString().isNotEmpty) ||
                      (links[0]["image"] != null &&
                          links[0]["image"].toString().isNotEmpty))
                  ? Padding(
                      padding: EdgeInsets.only(right: spacing.padding2 ?? 2),
                      child: Image.network(
                        links[0]["favicon"] ?? links[0]["image"] ?? "",
                        height: 36,
                        width: 36,
                        errorBuilder: (context, object, stack) {
                          return Image.asset(
                            AssetConstants.imagePlaceholder,
                            height: 36,
                            width: 36,
                            package: UIConstants.packageName,
                            color: colorPalette.iconPrimary,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              title: name,
              subtitle:
                  (links[0]["description"] != null &&
                      links[0]["description"].toString().isNotEmpty)
                  ? links[0]["description"]
                  : (links[0]["url"] ?? ""),
              subtitleColor: colorPalette.info,
              colorPalette: colorPalette,
              typography: typography,
              spacing: spacing,
              trailing: Padding(
                padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
                child: CometChatDate(
                  date: message.sentAt ?? DateTime.now(),
                  pattern: DateTimePattern.dayDateFormat,
                  dateTimeFormatterCallback: timeSeparatorFormatterCallback,
                  style: CometChatDateStyle(
                    backgroundColor: colorPalette.transparent,
                    border: const Border.fromBorderSide(BorderSide.none),
                    textStyle: getTextStyle(
                      typography.caption1?.regular,
                      colorPalette.neutral600,
                    ),
                  ).merge(style?.searchMessageTimeStampStyle),
                ),
              ),
              style: style,
            );
          }
        } else {
          if (searchTextMessageView != null) {
            TextMessage textMessage = message as TextMessage;
            return searchTextMessageView(context, textMessage)!;
          } else {
            List<CometChatTextFormatter> formatters = controller
                .getTextFormatters(message);

            return buildSearchItem(
              message: message,
              title: name,
              subtitle: (message as TextMessage).text,
              colorPalette: colorPalette,
              typography: typography,
              spacing: spacing,
              trailing: message.sentAt != null
                  ? Padding(
                      padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
                      child: CometChatDate(
                        date: message.sentAt ?? DateTime.now(),
                        pattern: DateTimePattern.dayDateFormat,
                        dateTimeFormatterCallback:
                            timeSeparatorFormatterCallback,
                        style: CometChatDateStyle(
                          backgroundColor: colorPalette.transparent,
                          border: const Border.fromBorderSide(BorderSide.none),
                          textStyle: getTextStyle(
                            typography.caption2?.regular,
                            colorPalette.neutral600,
                          ),
                        ).merge(style?.searchMessageTimeStampStyle),
                      ),
                    )
                  : const SizedBox(),
              style: style,
              textFormatters: formatters,
              context: context,
            );
          }
        }
      case MessageTypeConstants.image:
        if (searchImageMessageView != null) {
          MediaMessage mediaMessage = message as MediaMessage;
          return searchImageMessageView(context, mediaMessage)!;
        } else {
          String? imageUrl = (message as MediaMessage).attachment?.fileUrl;
          final msg = message;
          return buildSearchItem(
            message: message,
            title: name,
            subtitle: msg.attachment?.fileName ?? "",
            colorPalette: colorPalette,
            typography: typography,
            spacing: spacing,
            trailing: imageUrl != null
                ? Padding(
                    padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
                    child: CometChatImageBubble(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      style: CometChatImageBubbleStyle(
                        borderRadius: BorderRadius.zero,
                        border: Border.all(width: 0),
                      ),
                      onClick: onMessageClicked != null
                          ? () => onMessageClicked(message)
                          : null,
                    ),
                  )
                : const SizedBox(),
            style: style,
          );
        }

      case MessageTypeConstants.video:
        if (searchVideoMessageView != null) {
          MediaMessage mediaMessage = message as MediaMessage;
          return searchVideoMessageView(context, mediaMessage)!;
        } else {
          String? videoUrl = (message as MediaMessage).attachment?.fileUrl;
          final msg = message;
          String? thumbnail = checkForThumbnail(message);
          return buildSearchItem(
            message: message,
            title: name,
            subtitle: msg.attachment?.fileName ?? "",
            colorPalette: colorPalette,
            typography: typography,
            spacing: spacing,
            trailing: videoUrl != null
                ? Padding(
                    padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
                    child: CometChatVideoBubble(
                      videoUrl: videoUrl,
                      thumbnailUrl: thumbnail,
                      width: 80,
                      height: 80,
                      style: CometChatVideoBubbleStyle(
                        borderRadius: BorderRadius.zero,
                        border: Border.all(width: 0),
                      ),
                      onClick: onMessageClicked != null
                          ? () => onMessageClicked(message)
                          : null,
                      placeHolder: Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorPalette.neutral900?.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            size: 25.0,
                            color: colorPalette.buttonIconColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            style: style,
          );
        }
      case MessageTypeConstants.file:
        if (searchFileMessageView != null) {
          MediaMessage mediaMessage = message as MediaMessage;
          return searchFileMessageView(context, mediaMessage)!;
        } else {
          MediaMessage? msg = (message as MediaMessage);
          return buildSearchItem(
            message: message,
            leading: Padding(
              padding: EdgeInsets.only(right: spacing.padding2 ?? 2),
              child: Image.asset(
                FileUtils.getFileIcon(
                  FileUtils.getFileExtension(msg.attachment?.fileUrl),
                ),
                height: 32,
                width: 32,
                package: UIConstants.packageName,
              ),
            ),
            title: name,
            subtitle: msg.attachment?.fileName ?? "",
            colorPalette: colorPalette,
            typography: typography,
            spacing: spacing,
            trailing: Padding(
              padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
              child: CometChatDate(
                date: message.sentAt ?? DateTime.now(),
                pattern: DateTimePattern.dayDateFormat,
                dateTimeFormatterCallback: timeSeparatorFormatterCallback,
                style: CometChatDateStyle(
                  backgroundColor: colorPalette.transparent,
                  border: const Border.fromBorderSide(BorderSide.none),
                  textStyle: getTextStyle(
                    typography.caption2?.regular,
                    colorPalette.neutral600,
                  ),
                ).merge(style?.searchMessageTimeStampStyle),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: spacing.padding3 ?? 0,
            ),
            style: style,
          );
        }
      case MessageTypeConstants.audio:
        if (searchAudioMessageView != null) {
          MediaMessage mediaMessage = message as MediaMessage;
          return searchAudioMessageView(context, mediaMessage)!;
        } else {
          MediaMessage? msg = (message as MediaMessage);
          return buildSearchItem(
            message: message,
            leading: Padding(
              padding: EdgeInsets.only(right: spacing.padding2 ?? 2),
              child: Container(
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
            ),
            title: name,
            subtitle: msg.attachment?.fileName ?? "",
            colorPalette: colorPalette,
            typography: typography,
            spacing: spacing,
            trailing: message.sentAt != null
                ? Padding(
                    padding: EdgeInsets.only(left: spacing.padding2 ?? 0),
                    child: CometChatDate(
                      date: message.sentAt ?? DateTime.now(),
                      pattern: DateTimePattern.dayDateFormat,
                      dateTimeFormatterCallback: timeSeparatorFormatterCallback,
                      style: CometChatDateStyle(
                        backgroundColor: colorPalette.transparent,
                        border: const Border.fromBorderSide(BorderSide.none),
                        textStyle: getTextStyle(
                          typography.caption2?.regular,
                          colorPalette.neutral600,
                        ),
                      ).merge(style?.searchMessageTimeStampStyle),
                    ),
                  )
                : const SizedBox(),
            contentPadding: EdgeInsets.symmetric(
              vertical: spacing.padding3 ?? 0,
            ),
            style: style,
          );
        }
      default:
        return const SizedBox();
    }
  }

  static String? checkForThumbnail(MediaMessage message) {
    try {
      String? smallUrl = getThumbnailGeneration(message);
      Attachment? attachment = message.attachment;
      if (attachment != null) {
        if (smallUrl != null) {
          return smallUrl;
        }
      }
    } catch (_) {}

    return null;
  }

  static String? getThumbnailGeneration(BaseMessage baseMessage) {
    String? resultUrl;
    try {
      Map<String, Map>? extensionList = ExtensionModerator.extensionCheck(
        baseMessage,
      );

      if (extensionList != null &&
          extensionList.containsKey(ExtensionConstants.thumbnailGeneration)) {
        Map? thumbnailGeneration =
            extensionList[ExtensionConstants.thumbnailGeneration];
        if (thumbnailGeneration != null) {
          resultUrl = thumbnailGeneration["url_medium"];
        }
      }
    } catch (e, stack) {
      debugPrint("$stack");
    }
    return resultUrl;
  }

  static List<dynamic> getMessageLinks(BaseMessage message) {
    Map<String, Map>? extensionList = ExtensionModerator.extensionCheck(
      message,
    );
    List<dynamic> links = [];
    if (extensionList != null) {
      try {
        if (extensionList.containsKey(ExtensionConstants.linkPreview)) {
          Map<dynamic, dynamic>? linkPreview =
              extensionList[ExtensionConstants.linkPreview];
          links = linkPreview?["links"] ?? [];
        }
      } catch (e) {
        debugPrint('$e');
      }
    }
    return links;
  }

  static Widget interstellar({
    required CometChatSpacing spacing,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    Key? key,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    EdgeInsetsGeometry? contentPadding,
    double? height,
    double? width,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? subtitlePadding,
    Color? backgroundColor,
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.start,
    CometChatSearchStyle? style,
  }) {
    return Container(
      height: height,
      width: width,
      color: backgroundColor ?? Colors.transparent,
      padding: contentPadding ?? const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        children: [
          ?leading,
          Expanded(
            child: Padding(
              padding: titlePadding ?? const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title ?? const SizedBox(),
                  subtitle ?? const SizedBox(),
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  static bool _isSameMonth({DateTime? dt1, DateTime? dt2}) {
    if (dt1 == null || dt2 == null) return true;
    return dt1.year == dt2.year && dt1.month == dt2.month;
  }

  static Widget getDateSeparator(
    CometChatMessagesSearchController controller,
    int index,
    context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    DateTimeFormatterCallback? dateTimeFormatterCallback,
    CometChatSearchStyle? style,
  ) {
    final dateStyle = CometChatThemeHelper.getTheme<CometChatDateStyle>(
      context: context,
      defaultTheme: CometChatDateStyle.of,
    ).merge(style?.searchMessageDateSeparatorStyle);

    // Don't show separator if the message at this index is deleted
    // This prevents showing a date separator with no visible items below it
    if (controller.list[index].deletedAt != null) {
      debugPrint(
        'SearchUtils: Skipping date separator at index $index (message is deleted)',
      );
      return const SizedBox(height: 0, width: 0);
    }

    // Show separator for the first message or when the previous message is from a different month
    if (index == 0 ||
        !_isSameMonth(
          dt1: controller.list[index].sentAt,
          dt2: controller.list[index - 1].sentAt,
        )) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, spacing.padding2 ?? 0, 0, 0),
        child: CometChatDate(
          date: controller.list[index].sentAt,
          customDateString: DateFormat(
            'MMMM, yyyy',
          ).format(controller.list[index].sentAt ?? DateTime.now()),
          padding: EdgeInsets.zero,
          dateTimeFormatterCallback: dateTimeFormatterCallback,
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
          ).merge(dateStyle),
        ),
      );
    } else {
      return const SizedBox(height: 0, width: 0);
    }
  }
}
