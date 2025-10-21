import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;

class CometChatMarquee extends StatefulWidget {
  final String text;
  final double velocity;
  final TextStyle? style;
  final double blankSpace;
  final Duration pauseDuration;

  const CometChatMarquee({
    super.key,
    required this.text,
    this.velocity = 50,
    this.style,
    this.blankSpace = 50,
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  State<CometChatMarquee> createState() => _CometChatMarqueeState();
}

class _CometChatMarqueeState extends State<CometChatMarquee>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late double _textWidth;
  late double _containerWidth;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the container width once the layout is finalized
      _containerWidth = context.size!.width;

      final textPainter = TextPainter(
        text: TextSpan(
            text: widget.text,
            style: widget.style ?? const TextStyle(fontSize: 20)),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      _textWidth = textPainter.width;

      // If text exceeds container width, initiate scrolling
      if (_textWidth > _containerWidth) {
        _needsScrolling = true;

        final totalScrollWidth = _textWidth + widget.blankSpace;
        final scrollDuration = Duration(
          milliseconds: (totalScrollWidth / widget.velocity * 1000).toInt(),
        );

        // Total duration including pause at the start
        final totalDuration = scrollDuration + widget.pauseDuration;

        // Initialize the AnimationController only if scrolling is required
        _controller = AnimationController(vsync: this, duration: totalDuration)
          ..repeat();
      }

      // Rebuild widget to reflect changes
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose the controller properly
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(widget.text, style: widget.style);

    // If text doesn't require scrolling, return just the text
    if (widget.text == cc.Translations.of(context).online || !_needsScrolling) return textWidget;

    if (_controller == null) return const SizedBox.shrink();

    return ClipRect(
      child: SizedBox(
        height: (widget.style?.fontSize ?? 20) * 1.2,
        child: AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            final totalDurationMs = _controller!.duration!.inMilliseconds;
            final pauseMs = widget.pauseDuration.inMilliseconds;
            final scrollMs = totalDurationMs - pauseMs;

            double offset;
            if (_controller!.value * totalDurationMs < pauseMs) {
              // During pause, offset is 0
              offset = 0;
            } else {
              final scrollValue = (_controller!.value * totalDurationMs - pauseMs) / scrollMs;
              offset = -(_textWidth + widget.blankSpace) * scrollValue;
            }

            return Stack(
              children: [
                Positioned(
                  left: offset,
                  child: textWidget,
                ),
                Positioned(
                  left: offset + _textWidth + widget.blankSpace,
                  child: textWidget,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
