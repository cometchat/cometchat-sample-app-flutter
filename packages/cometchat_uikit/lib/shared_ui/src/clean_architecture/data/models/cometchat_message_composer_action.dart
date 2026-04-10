import 'package:flutter/material.dart';
import "package:cometchat_sdk/cometchat_sdk.dart";
import '../../../../cometchat_uikit_shared.dart' show CometChatAttachmentOptionSheetStyle;

///[CometChatMessageComposerAction] is the type of menu items allowed to be displayed `CometChatMessageComposer`
///
/// ```dart
///
/// final CometChatMessageComposerAction exampleMessageComposerAction = CometChatMessageComposerAction(
///   id: "example",
///   title: "Example Action",
///   icon: Icon(Icons.example),
///   style: CometChatAttachmentOptionSheetStyle(
///   backgroundColor: Colors.white,
///   ),
///   onItemClick: () {
///     // Do something when this message composer action is selected
///   },
/// );
///
/// ```
class CometChatMessageComposerAction {
  ///[CometChatMessageComposerAction] constructor requires [id] and [title] while initializing.
  const CometChatMessageComposerAction({
    required this.id,
    required this.title,
    this.icon,
    this.style,
    this.onItemClick,
  });

  ///[id] is an unique id for this message composer action
  final String id;

  ///[title] is the name for this message composer action
  final String title;

  ///[icon] is the icon for this message composer action
  final Widget? icon;

  ///[style] is the style for this message composer action
  final CometChatAttachmentOptionSheetStyle? style;

  ///[onItemClick] executes some task when this message composer action is selected
  final Function(BuildContext, User?, Group?)? onItemClick;

  @override
  String toString() {
    return 'CometChatMessageComposerOption{id: $id, title: $title,icon: $icon, style: $style,}';
  }
}
