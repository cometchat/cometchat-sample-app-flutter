class UIEventUtils {
  static Map<String, dynamic> createMap(
      String? uid, String? guid, int? parentMessageId) {
    Map<String, dynamic> mapId = {};

    if (uid != null) {
      mapId["uid"] = uid;
    } else {
      mapId["guid"] = guid;
    }

    if (parentMessageId != null) {
      mapId['parentMessageId'] = parentMessageId;
    }
    return mapId;
  }
}
