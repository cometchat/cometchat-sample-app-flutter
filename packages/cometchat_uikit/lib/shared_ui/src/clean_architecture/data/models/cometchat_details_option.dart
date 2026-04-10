import 'package:flutter/material.dart';
import "package:cometchat_sdk/cometchat_sdk.dart";
import 'cometchat_base_options.dart';
import '../../presentation/view_models/cometchat_details_controller_protocol.dart';

///[CometChatDetailsOption] is a model class which contains information about options available for every [CometChatDetailsTemplate]
///
/// ```dart
///
/// CometChatDetailsOption option = CometChatDetailsOption(
///   id: 'option1',
///   title: 'Option 1',
///   icon: 'icon_url',
///   packageName: 'com.example.package',
///   titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
///   customView: Container(
///     height: 100,
///     width: 100,
///     color: Colors.red,
///   ),
///   tail: Icon(Icons.arrow_forward),
///   height: 50.0,
///   onClick: (User? user, Group? group, String section, CometChatDetailsController state) {
///     // do something on click
///   },
/// );
///
/// ```
class CometChatDetailsOption extends CometChatBaseOptions {
  ///to pass custom view to options
  Widget? customView;

  /// to pass tail component for detail option
  Widget? tail;

  ///to pass height for details
  double? height;

  ///[onClick] call function which takes 3 parameter , and one of user or group is populated at a time
  Function(User? user, Group? group, String section,
      CometChatDetailsControllerProtocol state)? onClick;

  ///[CometChatDetailsOption] constructor requires [id] , [title] and [onClick] while initializing.
  CometChatDetailsOption(
      {this.customView,
      this.onClick,
      this.tail,
      required super.id,
      this.height,
      super.title,
      super.icon,
      super.packageName,
      super.titleStyle});

  @override
  String toString() {
    return 'DetailOption{customView: $customView, tail: $tail, onClick: $onClick , id $id , title $title ';
  }
}
