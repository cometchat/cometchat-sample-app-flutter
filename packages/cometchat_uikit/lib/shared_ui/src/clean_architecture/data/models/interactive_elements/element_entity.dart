import 'package:flutter/material.dart';
import '../../../../../cometchat_uikit_shared.dart'
    show ModelFieldConstants, UIElementTypeConstants;
import 'label_element.dart';
import '../interactive_elements/button_element.dart';
import 'checkbox_element.dart';
import 'dropdown_element.dart';
import 'radio_button_element.dart';
import 'text_input_element.dart';
import 'single_select_element.dart';
import 'date_time_element.dart';

class ElementEntity {
  ElementEntity({required this.elementType, required this.elementId});

  String elementType;
  String elementId;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map[ModelFieldConstants.elementType] = elementType;
    map[ModelFieldConstants.elementId] = elementId;
    return map;
  }

  factory ElementEntity.fromMap(dynamic map) {
    if (map[ModelFieldConstants.elementType] == UIElementTypeConstants.label) {
      debugPrint("mapping from label");
      return LabelElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.button) {
      debugPrint("mapping from button");
      return ButtonElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.checkbox) {
      debugPrint("mapping from checkbox");
      return CheckBoxElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.dropdown) {
      debugPrint("mapping from dropdown");

      return DropdownElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.radio) {
      debugPrint("mapping from radio");
      return RadioButtonElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.textInput) {
      debugPrint("mapping from textInput");
      return TextInputElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.singleSelect) {
      debugPrint("mapping from singleSelect");
      return SingleSelectElement.fromMap(map);
    } else if (map[ModelFieldConstants.elementType] ==
        UIElementTypeConstants.dateTime) {
      debugPrint("mapping from dateTime");
      return DateTimeElement.fromMap(map);
    }
    return ElementEntity(
      elementId: map[ModelFieldConstants.elementId],
      elementType: map[ModelFieldConstants.elementType],
    );
  }
}
