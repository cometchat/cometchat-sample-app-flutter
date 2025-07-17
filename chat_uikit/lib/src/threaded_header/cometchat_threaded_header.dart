import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

///[CometChatThreadedHeader] is a widget that internally uses [CometChatListBase], [CometChatMessageList] and [CometChatMessageComposer]
///to display and create messages with respect to a certain parent message
/// ```dart
/// CometChatThreadedHeader(
///  parentMessage: BaseMessage(),
///  loggedInUser: User(),
///  );
/// ```
class CometChatThreadedHeader extends StatefulWidget {
  const CometChatThreadedHeader({
    super.key,
    required this.parentMessage,
    this.messageActionView,
    this.style,
    required this.loggedInUser,
    this.template,
    this.height,
    this.width,
  });

  ///[parentMessage] parent message for thread
  final BaseMessage parentMessage;

  ///[messageActionView] custom action view
  final Function(BaseMessage message, BuildContext context)? messageActionView;

  ///[style] style parameter
  final CometChatThreadedHeaderStyle? style;

  ///[loggedInUser] get logged in user
  final User loggedInUser;

  ///[template] to get the message template
  final CometChatMessageTemplate? template;

  ///[height] provides height to the widget
  final double? height;

  ///[width] provides width to the widget
  final double? width;

  @override
  State<CometChatThreadedHeader> createState() =>
      _CometChatThreadedHeaderState();
}

class _CometChatThreadedHeaderState extends State<CometChatThreadedHeader> {
  late CometChatThreadedHeaderController threadedHeaderController;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late CometChatThreadedHeaderStyle threadedHeaderStyle;

  late CometChatMessageTemplate _messageTemplate;
  final key = GlobalKey();
  double? height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    threadedHeaderStyle =
        CometChatThemeHelper.getTheme<CometChatThreadedHeaderStyle>(
                context: context, defaultTheme: CometChatThreadedHeaderStyle.of)
            .merge(widget.style);
  }

  @override
  void initState() {
    super.initState();
    List<CometChatMessageTemplate> template =
        CometChatUIKit.getDataSource().getAllMessageTemplates();
    for (var element in template) {
      if (widget.parentMessage.category == element.category &&
          widget.parentMessage.type == element.type) {
        _messageTemplate = element;
      }
    }
    _messageTemplate = widget.template ?? _messageTemplate;
    threadedHeaderController = CometChatThreadedHeaderController(
      widget.parentMessage,
      widget.loggedInUser,
    );
  }

  Widget getActionView(
      CometChatThreadedHeaderController controller, BuildContext context) {
    if (widget.messageActionView != null) {
      return widget.messageActionView!(widget.parentMessage, context);
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: threadedHeaderStyle.countContainerBackGroundColor ??
            colorPalette.extendedPrimary100,
        border: threadedHeaderStyle.countContainerBorder ??
            Border(
              bottom: BorderSide(
                width: 1.0,
                color: colorPalette.borderDefault ?? Colors.transparent,
                style: BorderStyle.solid,
              ),
            ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding1 ?? 0,
        horizontal: spacing.padding4 ?? 0,
      ),
      child: Text(
        "${threadedHeaderController.replyCount} ${threadedHeaderController.replyCount > 1 ? cc.Translations.of(context).replies : cc.Translations.of(context).reply}",
        style: TextStyle(
          color:
              threadedHeaderStyle.countTextColor ?? colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
        )
            .merge(
              threadedHeaderStyle.countTextStyle,
            )
            .copyWith(
              color: threadedHeaderStyle.countTextColor,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final bubble = MessageUtils.getMessageBubble(
        context: context,
        colorPalette: colorPalette,
        spacing: spacing,
        typography: typography,
        bubbleAlignment: widget.parentMessage.sender?.uid==widget.loggedInUser.uid? BubbleAlignment.right:BubbleAlignment.left,
        message: widget.parentMessage,
        template: _messageTemplate,
        outgoingMessageBubbleStyle: threadedHeaderStyle
            .outgoingMessageBubbleStyle,
        incomingMessageBubbleStyle: threadedHeaderStyle.incomingMessageBubbleStyle,
        textFormatters: CometChatUIKit.getDataSource().getDefaultTextFormatters(),
        key: key
    );

    final maxHeight = MediaQuery.of(context).size.height * 0.30;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final keyContext = key.currentContext;
        if (keyContext != null && height==null) {
        final RenderBox renderBox = keyContext.findRenderObject() as RenderBox;
        height = renderBox.size.height;
        setState(() {
        });
      }
      },);
      

        return Container(
          width: widget.width ?? double.infinity,
          constraints: threadedHeaderStyle.constraints ??
              BoxConstraints(
                maxHeight: widget.height ?? (height!=null && height!<maxHeight?(height??0)+64:maxHeight),
              ),
          child: GetBuilder(
            init: threadedHeaderController,
            tag: threadedHeaderController.tag,
            builder: (CometChatThreadedHeaderController value) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: threadedHeaderStyle.bubbleContainerBackGroundColor ??
                            colorPalette.background3,
                        borderRadius:
                            threadedHeaderStyle.bubbleContainerBorderRadius,
                        border: threadedHeaderStyle.bubbleContainerBorder,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: spacing.padding4 ?? 0,
                          ),
                          child: IgnorePointer(
                            child: bubble,
                          ),
                        ),
                      ),
                    ),
                  ),
                  getActionView(value, context),
                ],
              );
            },
          ),
        );

  }
}
