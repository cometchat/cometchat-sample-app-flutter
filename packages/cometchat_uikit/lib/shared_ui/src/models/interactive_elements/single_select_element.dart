import '../../../cometchat_uikit_shared.dart' hide BaseInputElement, SingleSelectElement, ElementEntity, BaseInteractiveElement;
import 'base_input_element.dart';
/// Represents a single select element model class used to create a single select input element.
///
/// This class, [SingleSelectElement], is designed to represent a single select input element. It extends [BaseInputElement<String>]
/// and provides the specific functionality required for handling single select elements. It includes properties for label, options,
/// and methods for serialization and validation.
class SingleSelectElement extends BaseInputElement<String> {
  SingleSelectElement(
      {super.elementType = UIElementTypeConstants.singleSelect,
      required super.elementId,
      required this.label,
      required this.options,
      super.response,
      super.defaultValue,
      bool? optional = true})
      : super(optional: optional ?? true);

  /// The label to be displayed for the single select element.
  String label;

  /// A list of options available for selection within the single select element.
  List<OptionElement> options;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    map[ModelFieldConstants.label] = label;
    map[ModelFieldConstants.options] =
        options.map((option) => option.toMap()).toList();
    return map;
  }

  factory SingleSelectElement.fromMap(dynamic map) {
    return SingleSelectElement(
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
    if (response == null || response!.isEmpty) {
      return false;
    }
    return true;
  }
}
