import '../../../cometchat_uikit_shared.dart' hide BaseInputElement, ElementEntity;
import 'element_entity.dart';
abstract class BaseInputElement<T> extends ElementEntity {
  T? response;
  T? defaultValue;
  bool optional;

  BaseInputElement({
    required super.elementId,
    required super.elementType,
    this.response,
    this.defaultValue,
    this.optional = true,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map[ModelFieldConstants.elementType] = elementType;
    map[ModelFieldConstants.elementId] = elementId;
    if (T is String && Utils.isValidString(defaultValue as String)) {
      map[ModelFieldConstants.defaultValue] = defaultValue;
    } else if (defaultValue != null) {
      map[ModelFieldConstants.defaultValue] = defaultValue;
    }
    map[ModelFieldConstants.optional] = optional;
    return map;
  }

  bool validateResponse();
}
