import 'package:flutter/material.dart';

import '../../../../cometchat_uikit_shared.dart';

///[CometChatMessageBubble] is a widget that provides the skeleton structure for any message bubble constructed from a [CometChatMessageTemplate] which doesnt have a [bubbleView]
///it binds together the [leadingView], [headerView], [contentView], [footerView], [bottomView], [threadView] declared in the [CometChatMessageTemplate] to collectively form a message bubble
///
/// ```dart
///   CometChatMessageBubble(
///        alignment: BubbleAlignment.center,
///        leadingView: Container(),
///        headerView: Container(),
///        contentView: Container(),
///        footerView: Container(),
///        bottomView: Container(),
///        threadView: Container(),
///        replyView: Container(),
///        style: MessageBubbleStyle(),
///      );
/// ```
class CometChatMessageBubble extends StatelessWidget {
  const CometChatMessageBubble(
      {super.key,
        this.style = const CometChatMessageBubbleStyle(),
        this.alignment,
        this.contentView,
        this.footerView,
        this.headerView,
        this.leadingView,
        this.replyView,
        this.threadView,
        this.bottomView,
        this.statusInfoView,
        this.height,
        this.width,
        this.padding,
        this.margin
      });

  ///[leadingView] widget to be shown on the left side of the bubble
  final Widget? leadingView;

  ///[headerView] widget to be shown on the top of the bubble
  final Widget? headerView;

  ///[replyView] widget to be shown on the top of the bubble
  final Widget? replyView;

  ///[contentView] widget to be shown in the center of the bubble
  final Widget? contentView;

  ///[threadView] widget to be shown in the center of the bubble
  final Widget? threadView;

  ///[footerView] widget to be shown at the bottom of the bubble
  final Widget? footerView;

  ///[alignment] alignment of the bubble
  final BubbleAlignment? alignment;

  ///[style] styling for the bubble
  final CometChatMessageBubbleStyle? style;

  ///[bottomView] widget to be shown at the bottom of the bubble
  final Widget? bottomView;

  ///[statusInfoView] widget to be shown under the [contentView] of the bubble
  final Widget? statusInfoView;

  ///[width] sets width for the bubble
  final double? width;

  ///[height] sets height for the bubble
  final double? height;

  ///[padding] sets padding for the bubble
  final EdgeInsetsGeometry? padding;

  ///[margin] sets margin for the bubble
  final EdgeInsetsGeometry? margin;



  @override
  Widget build(BuildContext context) {
    final messageBubbleStyle = CometChatThemeHelper.getTheme<CometChatMessageBubbleStyle>(context: context,defaultTheme: CometChatMessageBubbleStyle.of).merge(style);
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Container(
      margin: margin,
      child: Padding(
        padding:
        padding ??  EdgeInsets.symmetric(vertical: spacing.padding2 ?? 0, horizontal: spacing.padding4 ?? 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingView != null) leadingView!,
            Column(
              crossAxisAlignment: alignment == BubbleAlignment.right
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [headerView ?? const SizedBox()],
                ),
                //-----bubble-----
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: alignment == BubbleAlignment.right
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    IntrinsicWidth(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: alignment == BubbleAlignment.right
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(spacing.padding1 ?? 0, spacing.padding1 ?? 0, spacing.padding1 ?? 0, 0),
                            decoration: BoxDecoration(
                              color: _getBubbleBackgroundColor(messageBubbleStyle, colorPalette),
                              borderRadius: messageBubbleStyle.borderRadius ??  BorderRadius.all(
                                  Radius.circular(spacing.radius3 ?? 0)),
                              border: messageBubbleStyle.border,
                              image: messageBubbleStyle.backgroundImage,
                            ),
                            child: ClipRRect(
                              borderRadius: messageBubbleStyle.borderRadius ??  BorderRadius.all(
                                  Radius.circular(spacing.radius3 ?? 0)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    alignment == BubbleAlignment.right
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (replyView != null) replyView!,
                                  if (contentView != null) contentView!,
                                  if (statusInfoView != null) statusInfoView!,
                                ],
                              ),
                            ),
                          ),
                          if (bottomView != null) bottomView!,
                          if (footerView != null)
                            Row(
                              mainAxisAlignment:
                              alignment == BubbleAlignment.right
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                footerView!,
                              ],
                            ),
                        ],
                      ),
                    ),

                    //-----thread replies-----
                    if (threadView != null) threadView!,
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _getBubbleBackgroundColor(CometChatMessageBubbleStyle style, CometChatColorPalette colorPalette) {
    return style.backgroundColor ?? (alignment == BubbleAlignment.right
        ? colorPalette.primary
        : colorPalette.neutral300);

  }
}