import 'package:flutter/material.dart';
import "package:cometchat_sdk/cometchat_sdk.dart" hide CardMessage;
import '../../../../cometchat_uikit_shared.dart'
    show CometChatAttachmentOptionSheetStyle;

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
    this.onToolbarTap,
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

  ///[onToolbarTap] executes when this action is tapped from the rich-text
  ///toolbar's trailing slot (Trailing Toolbar Buttons DD §3.4). Receives the
  ///live text controller — a [RichTextEditingController] when rich text is
  ///enabled, so the handler can read `text`/`selection` and call
  ///`applyFormat`/`applyInlineStyle` (same contract as `richTextToolbarView`).
  ///
  ///Surface split: the rich-text toolbar fires ONLY this callback (it
  ///ignores [onItemClick] and [style]); the attachment sheet fires ONLY
  ///[onItemClick] (it ignores this). Set the one matching where the action
  ///is used.
  final void Function(BuildContext context, TextEditingController controller)?
  onToolbarTap;

  @override
  String toString() {
    return 'CometChatMessageComposerOption{id: $id, title: $title,icon: $icon, style: $style,}';
  }
}
