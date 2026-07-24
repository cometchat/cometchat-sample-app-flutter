import 'package:flutter/material.dart';

/// A widget that wraps a message bubble and enables swipe-to-reply gesture.
///
/// Detects a rightward horizontal drag. Once the drag exceeds [swipeThreshold],
/// [onSwipe] is fired and the bubble snaps back to its original position.
class CometChatMessageSwipe extends StatefulWidget {
  const CometChatMessageSwipe({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enabled = true,
    this.swipeThreshold = 60.0,
    this.maxDragDistance = 80.0,
  });

  final Widget child;
  final VoidCallback onSwipe;
  final bool enabled;

  /// How far (px) the user must drag before the reply fires.
  final double swipeThreshold;

  /// Maximum visual translation before rubber-banding.
  final double maxDragDistance;

  @override
  State<CometChatMessageSwipe> createState() => _CometChatMessageSwipeState();
}

class _CometChatMessageSwipeState extends State<CometChatMessageSwipe>
    with SingleTickerProviderStateMixin {
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  double _dragOffset = 0.0;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    // Only allow rightward drag
    final newOffset = (_dragOffset + details.delta.dx).clamp(
      0.0,
      widget.maxDragDistance,
    );
    setState(() => _dragOffset = newOffset);

    if (!_triggered && _dragOffset >= widget.swipeThreshold) {
      _triggered = true;
      widget.onSwipe();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    _triggered = false;
    // Snap back to 0
    _snapAnimation =
        Tween<double>(begin: _dragOffset, end: 0.0).animate(
          CurvedAnimation(parent: _snapController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() => _dragOffset = _snapAnimation.value);
        });
    _snapController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.deferToChild,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Reply icon that fades in as drag progresses
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: (_dragOffset / widget.swipeThreshold).clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.reply_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // The message bubble, translated rightward
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
