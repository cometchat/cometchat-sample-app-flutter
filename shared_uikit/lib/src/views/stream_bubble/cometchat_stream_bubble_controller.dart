import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../cometchat_uikit_shared.dart';

class CometChatStreamBubbleController extends GetxController {
  //--------------------Constructor-----------------------
  CometChatStreamBubbleController({
    required this.streamMessage,
  });

  //-------------------------Variable Declaration-----------------------------

  late StreamMessage streamMessage;

  String text = "";
  String errorText = "";

  bool hasError = false;

  final CometChatStreamService _queueManager = CometChatStreamService();

  //-------------------------LifeCycle Methods-----------------------------

  @override
  void onInit() {
    super.onInit();
    text = streamMessage.text ?? "";
    final runId = streamMessage.id;
    debugPrint(
        "[StreamBubble] onInit called for runId: $runId, initial text: $text");

    _queueManager.startStreamingForRunId(
      runId,
      onAiAssistantEvent: (event) async {
        debugPrint(
            "[StreamBubble] Received event: ${event.type} for runId: $runId");
        await Future.delayed(_queueManager.streamDelay);
        _processEvent(event);
      },
      onError: (e) {
        hasError = true;
        errorText = e.message ?? "";
        debugPrint("[StreamBubble][Error] runId: $runId, error: $errorText");
        update();
      },
    ).listen(
      (_) {},
      onError: (err) => debugPrint("[StreamBubble][StreamError] $err"),
      onDone: () => debugPrint(
          "[StreamBubble][Done] Streaming completed for runId: $runId"),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

  final Map<int, String> _originalMessageText = {};

  void _processEvent(AIAssistantBaseEvent event) {
    switch (event.type) {
      case AgenticKeys.textMessageStart:
        _handleTextMessageStart(event as AIAssistantRunStartedEvent);
        break;
      case AgenticKeys.textMessageContent:
        _handleTextMessageContent(event as AIAssistantContentReceivedEvent);
        break;
      case AgenticKeys.textMessageEnd:
        _handleTextMessageEnd(event as AIAssistantMessageEndedEvent);
        break;
      case AgenticKeys.toolCallStart:
        _handleToolCallStart(event as AIAssistantToolStartedEvent);
        break;
      case AgenticKeys.toolCallEnd:
        _handleToolCallEnd(event as AIAssistantToolEndedEvent);
        break;
    }
  }

  Future<void> _handleTextMessageStart(AIAssistantRunStartedEvent event) async {
    final runId = event.id;
    if (runId == null) return;
    if (_queueManager.checkMessageExists(runId)) {
      StreamMessage? existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        existingMessage.text = "";
        existingMessage.metadata = {AIConstants.aiShimmer: false};
        _queueManager.updateMessage(existingMessage);
        text = existingMessage.text ?? "";
        update();
      }
    }
    _queueManager.clearBuffer(runId);
  }

  Future<void> _handleTextMessageContent(
      AIAssistantContentReceivedEvent event) async {
    final runId = event.id;
    if (runId == null) return;

    final delta = event.delta ?? '';
    if (delta.isEmpty) return;

    final buffer = _queueManager.getOrCreateBuffer(runId);
    buffer.write(delta);

    final messageId = _queueManager.getMessageIdForRun(runId);

    if (messageId != null && _queueManager.checkMessageExists(messageId)) {
      StreamMessage? existingMessage = _queueManager.getMessageById(messageId);
      if (existingMessage != null) {
        // Append delta directly instead of replacing full text
        existingMessage.text = (existingMessage.text ?? '') + delta;
        text = existingMessage.text ?? "";

        // Update metadata
        existingMessage.metadata?[AIConstants.aiShimmer] = false;

        // Persist update
        _queueManager.updateMessage(existingMessage);

        update();
      }
    }
  }

  Future<void> _handleTextMessageEnd(AIAssistantMessageEndedEvent event) async {
    final runId = event.id;
    if (runId == null) return;

    // Finalize the message with complete text
    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId != null) {
      if (_queueManager.checkMessageExists(runId)) {
        StreamMessage? existingMessage = _queueManager.getMessageById(runId);
        if (existingMessage != null) {
          final finalText = _queueManager.getBufferContent(runId) ?? '';
          existingMessage.text = finalText;
          existingMessage.metadata?[AIConstants.aiShimmer] = false;
          _queueManager.updateMessage(existingMessage);
          text = finalText;
          update();
        }
      }
    }
  }

  Future<void> _handleToolCallStart(AIAssistantToolStartedEvent event) async {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId == null) return;

    if (_queueManager.checkMessageExists(runId)) {
      StreamMessage? existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        // Store original text if not already stored
        _originalMessageText.putIfAbsent(
            messageId, () => existingMessage.text ?? "");
        existingMessage.text =
            "${existingMessage.text}\n${event.executionText}";
        existingMessage.metadata?[AIConstants.aiShimmer] = false;
        _queueManager.updateMessage(existingMessage);
        text = existingMessage.text ?? "";
        update();
      }
    }
  }

  Future<void> _handleToolCallEnd(AIAssistantToolEndedEvent event) async {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId == null) return;

    if (_queueManager.checkMessageExists(runId)) {
      StreamMessage? existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        final originalText = _originalMessageText[messageId];
        if (originalText != null) {
          existingMessage.text = originalText;
          _originalMessageText.remove(messageId);
          _queueManager.updateMessage(existingMessage);
          text = existingMessage.text ?? "";
          update();
        }
      }
    }
  }
}
