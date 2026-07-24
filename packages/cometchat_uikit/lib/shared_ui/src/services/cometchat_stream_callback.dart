import '../../cometchat_uikit_shared.dart';

mixin CometChatStreamCallbackListener implements UIEventHandler {
  void ccStreamInProgress(bool isInProgress);
  void ccStreamCompleted(bool isCompleted);
  void ccStreamInterrupted(bool isInterrupted);
}

class CometChatStreamCallBackEvents {
  static final Map<String, CometChatStreamCallbackListener>
  _streamCallBackListeners = {};

  static void addStreamCallBackListener(
    String listenerId,
    CometChatStreamCallbackListener listenerClass,
  ) {
    _streamCallBackListeners[listenerId] = listenerClass;
  }

  static void removeStreamCallBackListener(String listenerId) {
    _streamCallBackListeners.remove(listenerId);
  }

  static void ccStreamInProgress(bool isInProgress) {
    _streamCallBackListeners.forEach((key, value) {
      value.ccStreamInProgress(isInProgress);
    });
  }

  static void ccStreamCompleted(bool isCompleted) {
    _streamCallBackListeners.forEach((key, value) {
      value.ccStreamCompleted(isCompleted);
    });
  }

  static void ccStreamInterrupted(bool isInterrupted) {
    _streamCallBackListeners.forEach((key, value) {
      value.ccStreamInterrupted(isInterrupted);
    });
  }
}
