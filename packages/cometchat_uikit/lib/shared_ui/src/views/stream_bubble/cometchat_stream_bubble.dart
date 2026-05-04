import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../cometchat_uikit_shared.dart';

/// Renders an in-progress streaming AI response with shimmer effect.
///
/// Migrated from GetX to StatefulWidget for v6 BLoC architecture.
class CometChatStreamBubble extends StatefulWidget {
  const CometChatStreamBubble({
    super.key,
    required this.message,
    this.text,
    this.style,
    this.width,
    this.height,
    this.alignment,
  });

  /// If message object is not passed then text should be passed.
  final String? text;

  /// The stream message being rendered.
  final StreamMessage message;

  /// Styling for the bubble.
  final CometChatAIAssistantBubbleStyle? style;

  /// Width of the bubble.
  final double? width;

  /// Height of the bubble.
  final double? height;

  /// Alignment of the bubble.
  final BubbleAlignment? alignment;

  @override
  State<CometChatStreamBubble> createState() => _CometChatStreamBubbleState();
}

class _CometChatStreamBubbleState extends State<CometChatStreamBubble> {
  String _text = '';
  String _errorText = '';
  bool _hasError = false;

  final CometChatStreamService _queueManager = CometChatStreamService();
  final Map<int, String> _originalMessageText = {};
  StreamSubscription<AIAssistantBaseEvent>? _streamSubscription;

  // Theme — cached in didChangeDependencies
  late CometChatAIAssistantBubbleStyle _bubbleStyle;
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;
  late CometChatTypography _typography;
  bool _themeInitialized = false;

  @override
  void initState() {
    super.initState();
    _text = widget.message.text ?? '';
    _startStreaming();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _bubbleStyle =
          CometChatThemeHelper.getTheme<CometChatAIAssistantBubbleStyle>(
        context: context,
        defaultTheme: CometChatAIAssistantBubbleStyle.of,
      ).merge(widget.style);
      _colorPalette = CometChatThemeHelper.getColorPalette(context);
      _spacing = CometChatThemeHelper.getSpacing(context);
      _typography = CometChatThemeHelper.getTypography(context);
      _themeInitialized = true;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _startStreaming() {
    final runId = widget.message.runId ?? widget.message.id;

    _streamSubscription = _queueManager
        .startStreamingForRunId(
      runId,
      onAiAssistantEvent: (event) async {
        await Future.delayed(_queueManager.streamDelay);
        _processEvent(event);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorText = e.message ?? '';
        });
      },
    )
        .listen(
      (_) {},
      onError: (err) =>
          debugPrint('[CometChatStreamBubble][StreamError] $err'),
      onDone: () => debugPrint(
          '[CometChatStreamBubble][Done] Streaming completed for runId: $runId'),
    );
  }

  void _processEvent(AIAssistantBaseEvent event) {
    if (!mounted) return;
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

  void _handleTextMessageStart(AIAssistantRunStartedEvent event) {
    final runId = event.id;
    if (runId == null) return;
    if (_queueManager.checkMessageExists(runId)) {
      final existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        existingMessage.text = '';
        existingMessage.metadata = {AIConstants.aiShimmer: false};
        _queueManager.updateMessage(existingMessage);
        setState(() => _text = existingMessage.text ?? '');
      }
    }
    _queueManager.clearBuffer(runId);
  }

  void _handleTextMessageContent(AIAssistantContentReceivedEvent event) {
    final runId = event.id;
    if (runId == null) return;

    final delta = event.delta ?? '';
    if (delta.isEmpty) return;

    final buffer = _queueManager.getOrCreateBuffer(runId);
    buffer.write(delta);

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId != null && _queueManager.checkMessageExists(messageId)) {
      final existingMessage = _queueManager.getMessageById(messageId);
      if (existingMessage != null) {
        existingMessage.text = (existingMessage.text ?? '') + delta;
        existingMessage.metadata?[AIConstants.aiShimmer] = false;
        _queueManager.updateMessage(existingMessage);
        setState(() => _text = existingMessage.text ?? '');
      }
    }
  }

  void _handleTextMessageEnd(AIAssistantMessageEndedEvent event) {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId != null && _queueManager.checkMessageExists(runId)) {
      final existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        final finalText = _queueManager.getBufferContent(runId) ?? '';
        existingMessage.text = finalText;
        existingMessage.metadata?[AIConstants.aiShimmer] = false;
        _queueManager.updateMessage(existingMessage);
        setState(() => _text = finalText);
      }
    }
  }

  void _handleToolCallStart(AIAssistantToolStartedEvent event) {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId == null) return;

    if (_queueManager.checkMessageExists(runId)) {
      final existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        _originalMessageText.putIfAbsent(
            messageId, () => existingMessage.text ?? '');
        existingMessage.text =
            '${existingMessage.text}\n${event.executionText}';
        existingMessage.metadata?[AIConstants.aiShimmer] = false;
        _queueManager.updateMessage(existingMessage);
        setState(() => _text = existingMessage.text ?? '');
      }
    }
  }

  void _handleToolCallEnd(AIAssistantToolEndedEvent event) {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId == null) return;

    if (_queueManager.checkMessageExists(runId)) {
      final existingMessage = _queueManager.getMessageById(runId);
      if (existingMessage != null) {
        final originalText = _originalMessageText[messageId];
        if (originalText != null) {
          existingMessage.text = originalText;
          _originalMessageText.remove(messageId);
          _queueManager.updateMessage(existingMessage);
          setState(() => _text = existingMessage.text ?? '');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width ?? MediaQuery.sizeOf(context).width * 0.7,
      decoration: BoxDecoration(
        border: _bubbleStyle.border,
        borderRadius: _bubbleStyle.borderRadius ?? BorderRadius.zero,
        color: _bubbleStyle.backgroundColor ?? _colorPalette.transparent,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.sizeOf(context).height * 0.0058,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CometChatShimmerEffect(
            linearGradient:
                (widget.message.metadata?[AIConstants.aiShimmer] == true)
                    ? LinearGradient(
                        colors: [
                          _colorPalette.textTertiary ?? Colors.transparent,
                          _colorPalette.textPrimary ?? Colors.transparent,
                          _colorPalette.textTertiary ?? Colors.transparent,
                        ],
                      )
                    : null,
            child: NoIntrinsicScroll(
              child: GptMarkdownTheme(
                gptThemeData: GptMarkdownThemeData(
                  brightness: Theme.of(context).brightness,
                  highlightColor: _colorPalette.background4,
                  h3: TextStyle(
                    color: _colorPalette.textPrimary,
                    fontWeight: _typography.body?.bold?.fontWeight,
                    fontSize: _typography.body?.bold?.fontSize,
                    fontFamily: _typography.body?.bold?.fontFamily,
                  ),
                ),
                child: GptMarkdown(
                  _text,
                  style: TextStyle(
                    color: _colorPalette.textPrimary,
                    fontWeight: _typography.body?.regular?.fontWeight,
                    fontSize: _typography.body?.regular?.fontSize,
                    fontFamily: _typography.body?.regular?.fontFamily,
                  )
                      .merge(_bubbleStyle.textStyle)
                      .copyWith(color: _bubbleStyle.textColor),
                  codeBuilder: (context, name, code, closed) {
                    return NoIntrinsicScroll(
                      child: CometChatAiAssistantCodeBlock(
                        language: name,
                        codes: code,
                        colorPalette: _colorPalette,
                        spacing: _spacing,
                        typography: _typography,
                      ),
                    );
                  },
                  tableBuilder: (context, tableRows, textStyle, config) {
                    return NoIntrinsicScroll(
                      child: CometChatAiAssistantTableBuilder(
                        tableRows: tableRows,
                        colorPalette: _colorPalette,
                        spacing: _spacing,
                        typography: _typography,
                        config: config,
                      ),
                    );
                  },
                  highlightBuilder: (context, text, style) {
                    return CometchatHighlightBuilder(
                      text: text,
                      style: style,
                      typography: _typography,
                      spacing: _spacing,
                      colorPalette: _colorPalette,
                    );
                  },
                  linkBuilder: (context, text, url, style) {
                    return CometchatLinkBuilder(
                      text: text,
                      url: url,
                      style: style,
                      typography: _typography,
                      spacing: _spacing,
                      colorPalette: _colorPalette,
                    );
                  },
                ),
              ),
            ),
          ),
          if (_errorText.isNotEmpty && _hasError) ...[
            SizedBox(height: _spacing.padding2),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: _spacing.padding ?? 0,
                horizontal: _spacing.padding2 ?? 0,
              ),
              color: _colorPalette.error100,
              child: Text(
                _errorText,
                style: TextStyle(
                  color: _colorPalette.error,
                  fontWeight: _typography.caption1?.regular?.fontWeight,
                  fontSize: _typography.caption1?.regular?.fontSize,
                  fontFamily: _typography.caption1?.regular?.fontFamily,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
