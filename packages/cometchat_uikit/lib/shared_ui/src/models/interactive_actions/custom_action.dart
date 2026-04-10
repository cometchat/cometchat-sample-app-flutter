import '../../../cometchat_uikit_shared.dart';

/// Represents a custom action in a chat application.
///
/// This action is used for custom actions that are not specifically related to API requests
/// or URL navigation. It inherits the common 'actionType' property from the [ActionEntity] class.
class CustomAction extends ActionEntity {
  CustomAction({String? actionType})
      : super(actionType: actionType ?? ActionTypeConstants.customAction);

  factory CustomAction.fromMap(dynamic map) {
    return CustomAction(actionType: map['actionType']);
  }
}
