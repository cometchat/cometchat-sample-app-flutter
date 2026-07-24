import '../../../../../cometchat_uikit_shared.dart'
    show ActionTypeConstants, ActionElementFields, Utils;
import 'action_entity.dart';

/// Represents an action that makes an API request in a chat application.
///
/// This action is used to encapsulate details of an API request, including the URL, HTTP method,
/// payload data, headers, and data key. It inherits the common 'actionType' property from the
/// [ActionEntity] class.
class APIAction extends ActionEntity {
  String url;
  String method; // post, put, delete, patch
  Map<String, dynamic>? payload;
  Map<String, String>? headers;
  String? dataKey; // default key: CometChatData

  APIAction({
    required this.url,
    required this.method,
    this.payload,
    this.headers,
    this.dataKey,
    String? type,
  }) : super(actionType: type ?? ActionTypeConstants.apiAction);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map['url'] = url;
    if (Utils.isValidString(method)) {
      map[ActionElementFields.method] = method;
    }
    if (Utils.isValidMap(payload)) {
      map[ActionElementFields.payload] = payload;
    }
    if (Utils.isValidMap(headers)) {
      map[ActionElementFields.headers] = headers;
    }
    if (Utils.isValidString(dataKey)) {
      map[ActionElementFields.dataKey] = dataKey;
    }

    return map;
  }

  factory APIAction.fromMap(dynamic map) {
    Map<String, String> parsedMap = {};

    if (map['headers'] != null && map['headers'] is Map<String, dynamic>) {
      (map['headers'] as Map<String, dynamic>).forEach((key, value) {
        parsedMap[key] = value?.toString() ?? "";
      });
    }

    return APIAction(
      url: map['url'] ?? "",
      method: map['method'] ?? ActionTypeConstants.urlNavigation,
      payload: map['payload']?.cast<String, dynamic>(),
      headers: map['headers']?.cast<String, String>(),
      dataKey: map['dataKey'],
      type: map['actionType'],
    );
  }
}
