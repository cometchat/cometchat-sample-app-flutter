import 'package:flutter/material.dart';
import '../../cometchat_uikit_shared.dart';

///[ActionItem] is the type of items displayed in [CometChatAttachmentOptionSheet]
///
/// ```dart
///
/// ActionItem item = ActionItem(
///   id: '1',
///   title: 'Like',
///   icon: Icon(Icons.favorite),
///   iconTint: Colors.red,
///   background: Colors.white,
///   titleStyle: TextStyle(
///     fontSize: 16.0,
///     fontWeight: FontWeight.bold,
///     color: Colors.black,
///   ),
///   onItemClick: () {
///     print('Like button clicked!');
///   },
/// );
///
/// ```
class ActionItem {
  ///[id] is an unique id for this action item
  final String id;

  ///[title] is the name for this action item
  final String title;

  ///[icon] is the icon for this action item
  final Widget? icon;

  ///[style] is the style for this message composer action
  final CometChatAttachmentOptionSheetStyle? style;

  ///[onItemClick] is the callback function when this action item is selected
  final dynamic onItemClick;

  ///[ActionItem] constructor requires [id] and [title] while initializing.
  const ActionItem({
    required this.id,
    required this.title,
    this.style,
    this.icon,
    this.onItemClick,
  });

  @override
  String toString() {
    return 'ActionItem{id: $id, title: $title, style: $style,icon: $icon,}';
  }
}
