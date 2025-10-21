import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///Event emitting class for [CometChatAIAssistant]
class CometChatAIAssistantEvents {
  static Map<String, CometChatAIAssistantEventsListener> aiAssistantListener = {};

  static addAIAssistantListener(
      String listenerId, CometChatAIAssistantEventsListener listenerClass) {
    aiAssistantListener[listenerId] = listenerClass;
  }

  static removeAIAssistantListener(String listenerId) {
    aiAssistantListener.remove(listenerId);
  }

  /// Called when a AI assistant event is received.
  static void onAIAssistantEventReceived(AIAssistantBaseEvent aiAssistantBaseEvent) {
    aiAssistantListener.forEach((key, value) {
      value.onAIAssistantEventReceived(aiAssistantBaseEvent);
    });
  }
}
