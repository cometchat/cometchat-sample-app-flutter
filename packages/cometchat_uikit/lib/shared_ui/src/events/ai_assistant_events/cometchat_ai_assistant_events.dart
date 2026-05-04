import '../../../cometchat_uikit_shared.dart';

/// Event emitting class for AI Assistant features.
class CometChatAIAssistantEvents {
  static final Map<String, CometChatAIAssistantEventsListener>
      _aiAssistantListeners = {};

  static void addAIAssistantListener(
    String listenerId,
    CometChatAIAssistantEventsListener listenerClass,
  ) {
    _aiAssistantListeners[listenerId] = listenerClass;
  }

  static void removeAIAssistantListener(String listenerId) {
    _aiAssistantListeners.remove(listenerId);
  }

  /// Called when an AI assistant event is received.
  static void onAIAssistantEventReceived(
    AIAssistantBaseEvent aiAssistantBaseEvent,
  ) {
    _aiAssistantListeners.forEach((key, value) {
      value.onAIAssistantEventReceived(aiAssistantBaseEvent);
    });
  }
}
