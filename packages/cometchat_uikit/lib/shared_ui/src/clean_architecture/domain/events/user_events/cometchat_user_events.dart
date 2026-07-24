import "package:cometchat_sdk/cometchat_sdk.dart" hide CardMessage;
import 'cometchat_user_event_listener.dart';

class CometChatUserEvents {
  static Map<String, CometChatUserEventListener> usersListener = {};

  static void addUsersListener(
    String listenerId,
    CometChatUserEventListener listenerClass,
  ) {
    usersListener[listenerId] = listenerClass;
  }

  static void removeUsersListener(String listenerId) {
    usersListener.remove(listenerId);
  }

  static void ccUserBlocked(User user) {
    usersListener.forEach((key, value) {
      value.ccUserBlocked(user);
    });
  }

  static void ccUserUnblocked(User user) {
    usersListener.forEach((key, value) {
      value.ccUserUnblocked(user);
    });
  }
}
