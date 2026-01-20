import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatMessageTemplate] class for setting message types and rendering appropriate views in the message list
///
///```dart
///   CometChatMessageTemplate(
///        category: 'category',
///        type: 'type',
///        bubbleView: (message, context, bubbleAlignment) => Container(),
///        headerView: (message, context, bubbleAlignment) => Container(),
///        contentView: (message, context, bubbleAlignment) => Container(),
///        footerView: (message, context, bubbleAlignment) => Container(),
///        bottomView: (message, context, bubbleAlignment) => Container(),
///        options: (loggedInUser, messageObject, context, group) =>
///            <CometChatMessageOption>[],
///      );
/// ```

class CometChatMessageTemplate {
  CometChatMessageTemplate({
    required this.type,
    required this.category,
    this.bubbleView,
    this.options,
    this.headerView,
    this.footerView,
    this.contentView,
    this.bottomView,
    this.threadView,
    this.statusInfoView,
    this.replyView,
  });

  ///[type] of the message
  String type;

  ///[category] of the message
  String category;

  ///[bubbleView] widget to be shown in the center of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      bubbleView;

  ///[headerView] widget to be shown on the top of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      headerView;

  ///[footerView] widget to be shown under the [bottomView] of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      footerView;

  ///[contentView] widget to be shown in the center of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations})? contentView;

  ///[options] list of options to be shown on the message bubble
  List<CometChatMessageOption>? Function(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations)? options;

  ///[bottomView] widget to be shown under the [statusInfoView] of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      bottomView;

  ///[statusInfoView] widget to be shown under the [contentView] of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      statusInfoView;

  ///[threadView] widget to be shown at the bottom of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment)?
      threadView;

  ///[replyView] widget to be shown at the top of the bubble
  Widget? Function(BaseMessage, BuildContext, BubbleAlignment alignment, {AdditionalConfigurations? additionalConfigurations})?
      replyView;

  @override
  String toString() {
    return 'CometChatMessageTemplate{type: $type, category: $category, bubbleView: $bubbleView, headerView: $headerView, footerView: $footerView, contentView: $contentView, options: $options}';
  }
}
