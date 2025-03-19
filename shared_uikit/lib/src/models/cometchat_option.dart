import 'package:flutter/widgets.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatOption] is a model class which is used to execute any action on a [CometChatListItem]
///
/// ```dart
///
/// CometChatOption option = CometChatOption(
///     id: '1',
///     title: 'Option 1',
///     icon: 'https://example.com/icon.png',
///     packageName: 'com.example.package',
///     titleStyle: TextStyle(
///         color: Colors.black,
///         fontSize: 16.0,
///         fontWeight: FontWeight.bold,
///     ),
///     backgroundColor: Colors.white,
///     iconTint: Colors.blue,
///     onClick: () {
///         // Do something when this option is clicked
///     }
/// );
///
/// ```
class CometChatOption {
  ///unique id for an option
  String id;

  ///[title] passes title to option
  String? title;

  ///to pass icon url
  String? icon;

  ///to pass package name for the used icon
  String? packageName;

  ///[titleStyle] styling property for [title]
  TextStyle? titleStyle;

  ///[backgroundColor] background color for option
  Color? backgroundColor;

  ///[iconTint] tint color for icon
  Color? iconTint;

  ///[onClick] callback function for option
  Function()? onClick;

  /// [iconWidget] widget for icon
  Widget? iconWidget;

  CometChatOption({
    required this.id,
    this.title,
    this.icon,
    this.packageName,
    this.titleStyle,
    this.backgroundColor,
    this.iconTint,
    this.onClick,
    this.iconWidget,
  });
}
