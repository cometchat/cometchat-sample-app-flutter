import 'package:flutter/material.dart';

import '../../../cometchat_uikit_shared.dart';

///[CometChatDetailsTemplate] is the section of options displayed in [CometChatDetails]
///
/// ```dart
///
/// CometChatDetailsTemplate(
///   id: "user-details",
///   options: (user, group, context, theme) {
///     return [
///       CometChatDetailsOption(
///         id: "user-details-name",
///         title: "Name",
///         customView: Text(user?.name ?? ""),
///       ),
///       CometChatDetailsOption(
///         id: "user-details-username",
///         title: "Username",
///         customView: Text(user?.name ?? ""),
///       ),
///     ];
///   },
///   title: "User Details",
///   titleStyle: TextStyle(
///     fontSize: 18,
///     fontWeight: FontWeight.bold,
///   ),
///   sectionSeparatorColor: Colors.grey[300],
///   hideSectionSeparator: false,
///   itemSeparatorColor: Colors.grey[200],
///   hideItemSeparator: false,
/// )
///
/// ```
class CometChatDetailsTemplate {
  ///[id] is unique identifier for every [CometChatDetailsTemplate]
  final String id;

  ///[options] is a function which returns list of [CometChatDetailsOption] for every [CometChatDetailsTemplate]
  final List<CometChatDetailsOption> Function(User? user, Group? group,
      BuildContext? context)? options;

  ///[title] is the title of [CometChatDetailsTemplate]
  final String? title;

  ///[titleStyle] is the style of [title] of [CometChatDetailsTemplate]
  final TextStyle? titleStyle;

  ///[sectionSeparatorColor] is the color of section separator
  final Color? sectionSeparatorColor;

  ///[hideSectionSeparator] is a boolean which decides whether to hide section separator or not
  final bool? hideSectionSeparator;

  ///[itemSeparatorColor] is the color of item separator
  final Color? itemSeparatorColor;

  ///[hideItemSeparator] is a boolean which decides whether to hide item separator or not
  final bool? hideItemSeparator;

  ///[CometChatDetailsTemplate] constructor requires [id] and [options] while initializing.
  const CometChatDetailsTemplate(
      {required this.id,
      this.options,
      this.title,
      this.titleStyle,
      this.sectionSeparatorColor,
      this.hideSectionSeparator,
      this.itemSeparatorColor,
      this.hideItemSeparator});

  @override
  String toString() {
    return 'CometChatDetailsTemplate{id: $id, options: $options, title: $title, titleStyle: $titleStyle, sectionSeparatorColor: $sectionSeparatorColor, hideSectionSeparator: $hideSectionSeparator, itemSeparatorColor: $itemSeparatorColor, hideItemSeparator: $hideItemSeparator}';
  }
}
