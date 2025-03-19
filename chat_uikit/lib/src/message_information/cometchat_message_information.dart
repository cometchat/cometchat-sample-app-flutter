import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

///[CometChatMessageInformation] is a widget which is used to display message information.
///to display message information.
///```dart
///CometChatMessageInformation(
///  message: message,
///  title: "Message Information",
///  template: CometChatMessageTemplate(),
///  messageInformationStyle: CometChatMessageInformationStyle(),
///  );
///  ```

class CometChatMessageInformation extends StatefulWidget {
  const CometChatMessageInformation({
    super.key,
    required this.message,
    this.title,
    this.template,
    this.messageInformationStyle,
  });

  ///[message] parent message for message information
  final BaseMessage message;

  ///[title] to be shown at head
  final String? title;

  ///[template] to get the message template
  final CometChatMessageTemplate? template;

  ///[messageInformationStyle] style parameter
  final CometChatMessageInformationStyle? messageInformationStyle;

  @override
  State<CometChatMessageInformation> createState() =>
      _CometChatMessageInformationState();
}

class _CometChatMessageInformationState
    extends State<CometChatMessageInformation> {
  late CometchatMessageInformationController
      cometchatMessageInformationController;

  late CometChatMessageTemplate _messageTemplate;

  @override
  void initState() {
    super.initState();
    List<CometChatMessageTemplate> template =
        CometChatUIKit.getDataSource().getAllMessageTemplates();
    for (var element in template) {
      if (widget.message.category == element.category &&
          widget.message.type == element.type) {
        _messageTemplate = element;
      }
    }
    _messageTemplate = widget.template ?? _messageTemplate;
    cometchatMessageInformationController =
        CometchatMessageInformationController(widget.message);
    cometchatMessageInformationController.fetchMessageRecipients(
        cometchatMessageInformationController.group,
        cometchatMessageInformationController.parentMessage);
  }

  @override
  Widget build(BuildContext context) {
    final messageInfoStyle =
        CometChatThemeHelper.getTheme<CometChatMessageInformationStyle>(
                context: context,
                defaultTheme: CometChatMessageInformationStyle.of)
            .merge(widget.messageInformationStyle);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 1,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color:
                  messageInfoStyle.backgroundColor ?? colorPalette.background1,
              border: messageInfoStyle.border,
              borderRadius: messageInfoStyle.borderRadius ??
                  BorderRadius.vertical(
                    top: Radius.circular(
                      spacing.radius6 ?? 0,
                    ),
                  ),
            ),
            child: Column(
              children: [
                // Notch and the Name
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: spacing.padding3 ?? 0,
                        bottom: spacing.padding2 ?? 0,
                      ),
                      child: Container(
                        height: 4,
                        width: 32,
                        decoration: BoxDecoration(
                          color: colorPalette.neutral500,
                          borderRadius: BorderRadius.circular(
                            spacing.radiusMax ?? 0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: messageInfoStyle.backgroundColor ??
                            colorPalette.background1,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: spacing.padding2 ?? 0,
                            horizontal: spacing.padding4 ?? 0,
                          ),
                          child: Text(
                            widget.title ??
                                cc.Translations.of(context)
                                    .messageInformation,
                            style: TextStyle(
                              color: messageInfoStyle.titleTextColor ??
                                  colorPalette.textPrimary,
                              fontSize: typography.heading2?.bold?.fontSize,
                              fontWeight:
                                  typography.heading2?.bold?.fontWeight,
                              fontFamily:
                                  typography.heading2?.bold?.fontFamily,
                            )
                                .merge(
                                  messageInfoStyle.titleTextStyle,
                                )
                                .copyWith(
                                  color: messageInfoStyle.titleTextColor,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GetBuilder(
                  init: cometchatMessageInformationController,
                  builder: (CometchatMessageInformationController value) {
                    if (value.hasError == true) {
                      // error view
                      return const SizedBox();
                    } else if (cometchatMessageInformationController
                            .messageReceiptList.isEmpty &&
                        value.isLoading == true) {
                      // loading view
                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              loadingView(
                                context,
                                colorPalette,
                                spacing,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: messageInfoStyle
                                            .backgroundHighLightColor ??
                                        colorPalette.background2,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      spacing.padding4 ?? 0,
                                    ),
                                    child: MessageUtils.getMessageBubble(
                                      context: context,
                                      colorPalette: colorPalette,
                                      spacing: spacing,
                                      typography: typography,
                                      bubbleAlignment: BubbleAlignment.right,
                                      message: value.parentMessage,
                                      template: _messageTemplate,
                                      textFormatters: CometChatUIKit.getDataSource().getDefaultTextFormatters(),
                                    ),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                itemCount: cometchatMessageInformationController
                                    .messageReceiptList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final messageReceipt =
                                      cometchatMessageInformationController
                                          .messageReceiptList[index];
                                  if (value.parentMessage.receiver is User) {
                                    return userView(
                                      context: context,
                                      messageReceipt: messageReceipt,
                                      messageInfoStyle: messageInfoStyle,
                                      colorPalette: colorPalette,
                                      spacing: spacing,
                                      typography: typography,
                                    );
                                  }
                                  return (messageReceipt.readAt == null &&
                                          messageReceipt.deliveredAt == null)
                                      ? const SizedBox()
                                      : groupView(
                                          context: context,
                                          messageReceipt: messageReceipt,
                                          messageInfoStyle: messageInfoStyle,
                                          colorPalette: colorPalette,
                                          spacing: spacing,
                                          typography: typography,
                                        );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget timeText(
    String text,
    TextStyle? mergeTextStyle,
    Color? textColor,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
  ) {
    return Text(
      text,
      style: TextStyle(
        color: textColor ?? colorPalette.textSecondary,
        fontSize: typography.body?.regular?.fontSize,
        fontWeight: typography.body?.regular?.fontWeight,
        fontFamily: typography.body?.regular?.fontFamily,
      )
          .merge(
            mergeTextStyle,
          )
          .copyWith(
            color: textColor,
          ),
    );
  }

  // Function to convert time
  static String convertTime(DateTime? time, String receiptDatePattern) {
    String formattedDate = "";
    if (time != null) {
      formattedDate = DateFormat(receiptDatePattern).format(time);
    }
    return formattedDate;
  }

  // user view
  Widget userView({
    required BuildContext context,
    required MessageReceipt messageReceipt,
    required CometChatMessageInformationStyle messageInfoStyle,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required CometChatTypography typography,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 0,
            vertical: spacing.padding3 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding1 ?? 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: spacing.padding1 ?? 0,
                      ),
                      child: CometChatReceipt(
                        status: ReceiptStatus.read,
                        size: 16,
                        style: messageInfoStyle.messageReceiptStyle,
                      ),
                    ),
                    timeText(
                      cc.Translations.of(context).read,
                      messageInfoStyle.readTextStyle,
                      messageInfoStyle.readTextColor,
                      typography,
                      colorPalette,
                    ),
                  ],
                ),
              ),
              (messageReceipt.readAt == null)
                  ? timeText(
                      "----",
                      messageInfoStyle.readDateTextStyle,
                      messageInfoStyle.readDateTextColor,
                      typography,
                      colorPalette,
                    )
                  : timeText(
                      convertTime(
                        messageReceipt.readAt,
                        "dd/M/yyyy, h:mm a",
                      ),
                      messageInfoStyle.readDateTextStyle,
                      messageInfoStyle.readDateTextColor,
                      typography,
                      colorPalette,
                    ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 0,
            vertical: spacing.padding3 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding1 ?? 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: spacing.padding1 ?? 0,
                      ),
                      child: CometChatReceipt(
                        status: ReceiptStatus.delivered,
                        size: 16,
                        style: messageInfoStyle.messageReceiptStyle,
                      ),
                    ),
                    timeText(
                      cc.Translations.of(context).delivered,
                      messageInfoStyle.deliveredTextStyle,
                      messageInfoStyle.deliveredTextColor,
                      typography,
                      colorPalette,
                    ),
                  ],
                ),
              ),
              (messageReceipt.deliveredAt == null)
                  ? timeText(
                      "----",
                      messageInfoStyle.deliveredDateTextStyle,
                      messageInfoStyle.deliveredDateTextColor,
                      typography,
                      colorPalette,
                    )
                  : timeText(
                      convertTime(
                        messageReceipt.deliveredAt,
                        "dd/M/yyyy, h:mm a",
                      ),
                      messageInfoStyle.deliveredDateTextStyle,
                      messageInfoStyle.deliveredDateTextColor,
                      typography,
                      colorPalette,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  // group view
  Widget groupView({
    required BuildContext context,
    required MessageReceipt messageReceipt,
    required CometChatMessageInformationStyle messageInfoStyle,
    required CometChatColorPalette colorPalette,
    required CometChatSpacing spacing,
    required CometChatTypography typography,
  }) {
    return ListTile(
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      horizontalTitleGap: spacing.padding3 ?? 0,
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CometChatAvatar(
            height: 40,
            width: 40,
            name: messageReceipt.sender.name,
            image: messageReceipt.sender.avatar,
            style: messageInfoStyle.avatarStyle,
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            messageReceipt.sender.name,
            style: TextStyle(
              color: messageInfoStyle.nameTextColor ?? colorPalette.textPrimary,
              fontSize: typography.heading4?.medium?.fontSize,
              fontWeight: typography.heading4?.medium?.fontWeight,
              fontFamily: typography.heading4?.medium?.fontFamily,
            ).merge(messageInfoStyle.nameTextStyle).copyWith(
                  color: messageInfoStyle.nameTextColor,
                ),
          ),
          if (messageReceipt.readAt != null)
            Row(
              children: [
                timeText(
                  cc.Translations.of(context).read,
                  messageInfoStyle.readTextStyle,
                  messageInfoStyle.readTextColor,
                  typography,
                  colorPalette,
                ),
                const Spacer(),
                timeText(
                  convertTime(
                    messageReceipt.readAt,
                    "dd/M/yyyy, h:mm a",
                  ),
                  messageInfoStyle.readDateTextStyle,
                  messageInfoStyle.readDateTextColor,
                  typography,
                  colorPalette,
                ),
              ],
            ),
          if (messageReceipt.deliveredAt != null)
            Row(
              children: [
                timeText(
                  cc.Translations.of(context).delivered,
                  messageInfoStyle.deliveredTextStyle,
                  messageInfoStyle.deliveredTextColor,
                  typography,
                  colorPalette,
                ),
                const Spacer(),
                timeText(
                  convertTime(
                    messageReceipt.deliveredAt,
                    "dd/M/yyyy, h:mm a",
                  ),
                  messageInfoStyle.deliveredDateTextStyle,
                  messageInfoStyle.deliveredDateTextColor,
                  typography,
                  colorPalette,
                ),
              ],
            ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.padding4 ?? 0,
        vertical: spacing.padding3 ?? 0,
      ),
    );
  }

  // loading view
  Widget loadingView(BuildContext context, CometChatColorPalette colorPalette,
      CometChatSpacing spacing) {
    return CometChatShimmerEffect(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.padding4 ?? 0,
              vertical: spacing.padding3 ?? 0,
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0), // Adjust as necessary
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer bar
                      Container(
                        height: 19.0,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            spacing.radius2 ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Row for shimmer bars
                      Row(
                        children: [
                          // Shimmer bars
                          Container(
                            height: 19.0,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 19.0,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ), // This will push the shimmer bars to the start
                        ],
                      ),
                      const SizedBox(height: 10),
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

///Function to show message information
Future showMessageInformation({
  required BuildContext context,
  required final BaseMessage message,
  final String? title,
  final CometChatMessageTemplate? template,
  final CometChatMessageInformationStyle? messageInformationStyle,
}) {
  final colorPalette = CometChatThemeHelper.getColorPalette(context);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor:
        messageInformationStyle?.backgroundColor ?? colorPalette.background1,
    builder: (BuildContext context) {
      return CometChatMessageInformation(
        message: message,
        title: title,
        template: template,
        messageInformationStyle: messageInformationStyle,
      );
    },
  );
}
