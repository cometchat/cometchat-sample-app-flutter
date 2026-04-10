import "package:cometchat_sdk/cometchat_sdk.dart";
import 'cometchat_base_options.dart';
import '../../presentation/view_models/cometchat_group_members_controller_protocol.dart';

///[CometChatGroupMemberOption] is a model class which contains information about options available to execute for every [GroupMember]
///
/// ```dart
///
/// CometChatGroupMemberOption groupMemberOption = CometChatGroupMemberOption(
///   id: '1',
///   title: 'View Profile',
///   icon: 'https://example.com/icon.png',
///   packageName: 'com.example.package',
///   backgroundColor: Colors.white,
///   titleStyle: TextStyle(color: Colors.black),
///   onClick: (group, member, state) {
///     print('Clicked on group member: ${member.name}');
///   }
/// );
///
/// ```
class CometChatGroupMemberOption extends CometChatBaseOptions {
  ///[onClick] call function which takes 2 parameters
  Function(Group group, GroupMember member,
      CometChatGroupMembersControllerProtocol state)? onClick;

  CometChatGroupMemberOption({
    this.onClick,
    required super.id,
    super.title,
    super.icon,
    super.packageName,
    super.backgroundColor,
    super.titleStyle,
    super.iconWidget,
  });
}
