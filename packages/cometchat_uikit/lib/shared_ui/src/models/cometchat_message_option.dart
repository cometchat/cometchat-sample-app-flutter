import 'package:flutter/material.dart';
import '../../cometchat_uikit_shared.dart';

///Model class for message options
///
///```dart
/// CometChatMessageOption(
///  id: 'id',
///  title: 'title',
///  icon: Icon(Icons.favorite),
///  messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
///  backgroundColor: Colors.white,
///  ),
///  onClick: (BaseMessage baseMessage,
///      CometChatMessageListController state) {}
///  )
/// ```

class CometChatMessageOption {
  ///[CometChatMessageOption] constructor requires [id] and [title] while initializing.
  CometChatMessageOption({
    required this.id,
    required this.title,
    this.icon,
    this.onItemClick,
    this.messageOptionSheetStyle,
  });

  ///[id] of the option
  String id;

  ///[title] of the option
  String title;

  ///[icon] of the option
  Widget? icon;

  ///[onItemClick] of the option
  Function(BaseMessage message, CometChatMessageListControllerProtocol state)?
  onItemClick;

  ///[messageOptionSheetStyle] is a [CometChatMessageOptionSheetStyle] that can be used to style message option sheet
  final CometChatMessageOptionSheetStyle? messageOptionSheetStyle;

  ///[toActionItem] converts [CometChatMessageOption] to [ActionItem]
  ActionItem toActionItem() {
    return ActionItem(
      id: id,
      title: title,
      icon: icon,
      onItemClick: onItemClick,
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: messageOptionSheetStyle?.titleTextStyle,
        iconColor: messageOptionSheetStyle?.iconColor,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        border: messageOptionSheetStyle?.border,
        borderRadius: messageOptionSheetStyle?.borderRadius,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }

  ///[toActionItemFromFunction] takes a function as parameter and converts [CometChatMessageOption] to [ActionItem] with the function `onClick` as onItemClick
  ActionItem toActionItemFromFunction(
    Function(BaseMessage message, CometChatMessageListControllerProtocol state)?
    passedFunction,
  ) {
    return ActionItem(
      id: id,
      title: title,
      icon: icon,
      onItemClick: passedFunction,
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: messageOptionSheetStyle?.titleTextStyle,
        iconColor: messageOptionSheetStyle?.iconColor,
        backgroundColor: messageOptionSheetStyle?.backgroundColor,
        border: messageOptionSheetStyle?.border,
        borderRadius: messageOptionSheetStyle?.borderRadius,
        titleColor: messageOptionSheetStyle?.titleColor,
      ),
    );
  }
}
