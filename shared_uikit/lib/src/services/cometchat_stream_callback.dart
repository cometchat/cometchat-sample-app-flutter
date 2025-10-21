import '../../cometchat_uikit_shared.dart';

mixin CometChatStreamCallbackListener implements UIEventHandler {
  void ccStreamInProgress(bool isInProgress);
  void ccStreamCompleted(bool isCompleted);
  void ccStreamInterrupted(bool isInterrupted);
}


class CometChatStreamCallBackEvents {
  static Map<String, CometChatStreamCallbackListener> streamCallBackListener = {};

  static addStreamCallBackListener(
      String listenerId, CometChatStreamCallbackListener listenerClass) {
    streamCallBackListener[listenerId] = listenerClass;
  }

  static removeStreamCallBackListener(String listenerId) {
    streamCallBackListener.remove(listenerId);
  }

  static ccStreamInProgress(bool isInProgress) {
    streamCallBackListener.forEach((key, value) {
      value.ccStreamInProgress(isInProgress);
    });
  }

  static ccStreamCompleted(bool isCompleted) {
    streamCallBackListener.forEach((key, value) {
      value.ccStreamCompleted(isCompleted);
    });
  }

  static ccStreamInterrupted(bool isInterrupted) {
    streamCallBackListener.forEach((key, value) {
      value.ccStreamInterrupted(isInterrupted);
    });
  }
}
