import '../../../../../cometchat_uikit_shared.dart'
    show UIElementTypeConstants, ModelFieldConstants;
import 'base_input_element.dart';
import 'option_element.dart';

/// Represents a radio button model class , used to draw radio button .
class RadioButtonElement extends BaseInputElement<String> {
  RadioButtonElement({
    super.elementType = UIElementTypeConstants.radio,
    required super.elementId,
    required this.label,
    required this.options,
    super.response,
    super.defaultValue,
    bool? optional = true,
  }) : super(optional: optional ?? true);

  String label;
  List<OptionElement> options;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    map[ModelFieldConstants.label] = label;
    map[ModelFieldConstants.options] = options
        .map((option) => option.toMap())
        .toList();
    return map;
  }

  factory RadioButtonElement.fromMap(dynamic map) {
    return RadioButtonElement(
      elementType: map[ModelFieldConstants.elementType],
      elementId: map[ModelFieldConstants.elementId],
      optional: map[ModelFieldConstants.optional],
      label: map[ModelFieldConstants.label],
      defaultValue: map[ModelFieldConstants.defaultValue],
      options: (map[ModelFieldConstants.options] as List)
          .map((optionMap) => OptionElement.fromMap(optionMap))
          .toList(),
    );
  }

  @override
  bool validateResponse() {
    if (response == null || response!.isEmpty) return false;
    return true;
  }
}
