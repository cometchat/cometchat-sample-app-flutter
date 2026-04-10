import 'package:flutter/widgets.dart';

///[CometChatBaseOptions] is a model class which contains a set of properties that is be used by [CometChatDetailsOption], [CometChatGroupMemberOption] thus forming a common base class for both
///
/// ```dart
///
/// CometChatBaseOptions(
///   id: 'option_id',
///   title: 'Option title',
///   icon: 'https://example.com/icon.png',
///   packageName: 'example.package',
///   titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
///   backgroundColor: Colors.blue,
///   iconTint: Colors.white,
/// );
///
/// ```
class CometChatBaseOptions {
  ///unique [id] foe any option
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

  /// [iconWidget] widget for icon
  Widget? iconWidget;

  // ///[action] should not be used by developer
  // Function(String optionID, String elementID)? action;

  CometChatBaseOptions({
    required this.id,
    this.title,
    this.icon,
    this.packageName,
    this.titleStyle,
    this.backgroundColor,
    this.iconTint,
    this.iconWidget,
  });
}
