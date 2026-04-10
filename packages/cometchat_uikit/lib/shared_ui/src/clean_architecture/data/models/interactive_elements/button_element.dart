import '../../../clean_architecture.dart';
/// Represents a button model class , used to draw button element .
class ButtonElement extends BaseInteractiveElement {
  ButtonElement(
      {super.elementType = UIElementTypeConstants.button,
      required super.elementId,
      required this.buttonText,
      super.action,
      String? description,
      bool? disableAfterInteracted})
      : super(disableAfterInteracted: disableAfterInteracted ?? false);

  String buttonText;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map[ModelFieldConstants.buttonText] = buttonText;
    return map;
  }

  factory ButtonElement.fromMap(dynamic map) {
    return ButtonElement(
      elementType: map[ModelFieldConstants.elementType],
      elementId: map[ModelFieldConstants.elementId],
      buttonText: map[ModelFieldConstants.buttonText] ?? "",
      action: map[ModelFieldConstants.action] != null
          ? ActionEntity.fromMap(map[ModelFieldConstants.action])
          : null,
      disableAfterInteracted: map[ModelFieldConstants.disableAfterInteracted],
    );
  }
}
