import "package:cometchat_sdk/cometchat_sdk.dart";
import 'cometchat_user_event_listener.dart';

class CometChatUserEvents {
  static Map<String, CometChatUserEventListener> usersListener = {};

  static addUsersListener(
      String listenerId, CometChatUserEventListener listenerClass) {
    usersListener[listenerId] = listenerClass;
  }

  static removeUsersListener(String listenerId) {
    usersListener.remove(listenerId);
  }

  static ccUserBlocked(User user) {
    usersListener.forEach((key, value) {
      value.ccUserBlocked(user);
    });
  }

  static ccUserUnblocked(User user) {
    usersListener.forEach((key, value) {
      value.ccUserUnblocked(user);
    });
  }
}
