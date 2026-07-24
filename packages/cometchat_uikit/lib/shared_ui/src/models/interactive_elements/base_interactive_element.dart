import '../../../cometchat_uikit_shared.dart'
    hide
        BaseInteractiveElement,
        ButtonElement,
        ElementEntity,
        ActionEntity,
        APIAction,
        URLNavigationAction,
        CustomAction;
import 'button_element.dart';
import 'element_entity.dart';
import '../interactive_actions/action_entity.dart';

class BaseInteractiveElement extends ElementEntity {
  ActionEntity? action;
  bool disableAfterInteracted;

  BaseInteractiveElement({
    required super.elementId,
    required super.elementType,
    this.action,
    this.disableAfterInteracted = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    if (action != null) {
      map[ModelFieldConstants.action] = action?.toMap();
    }

    map[ModelFieldConstants.disableAfterInteracted] = disableAfterInteracted;
    return map;
  }

  factory BaseInteractiveElement.fromMap(dynamic map) {
    if (map[ModelFieldConstants.elementType] == UIElementTypeConstants.button) {
      return ButtonElement.fromMap(map);
    } else {
      ActionEntity? action;
      if (map[ModelFieldConstants.action] != null) {
        action = ActionEntity.fromMap(map[ModelFieldConstants.action]);
      }

      return BaseInteractiveElement(
        elementType: map[ModelFieldConstants.elementType],
        elementId: map[ModelFieldConstants.elementId],
        action: action,
        disableAfterInteracted: map[ModelFieldConstants.disableAfterInteracted],
      );
    }
  }
}
