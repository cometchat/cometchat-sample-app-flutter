// import 'package:flutter/material.dart';
//
// class SwipeMessage extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onSwipeRight;
//   final VoidCallback? onSwipeLeft;
//
//   const SwipeMessage({
//     Key? key,
//     required this.child,
//     this.onSwipeRight,
//     this.onSwipeLeft,
//   }) : super(key: key);
//
//   @override
//   State<SwipeMessage> createState() => _SwipeMessageState();
// }
//
// class _SwipeMessageState extends State<SwipeMessage> {
//   double _offsetX = 0.0;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         setState(() {
//           _offsetX += details.delta.dx;
//         });
//       },
//       onHorizontalDragEnd: (details) {
//         if (_offsetX > 100) {
//           // Swiped right
//           widget.onSwipeRight?.call();
//         } else if (_offsetX < -100) {
//           // Swiped left
//           widget.onSwipeLeft?.call();
//         }
//
//         // Animate back to original position
//         setState(() {
//           _offsetX = 0;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         transform: Matrix4.translationValues(_offsetX, 0, 0),
//         child: widget.child,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SwipeMessage extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;

  /// Enables or disables swipe completely
  final bool enableSwipe;

  /// Optional conditions for each direction
  final bool Function()? canSwipeRight;
  final bool Function()? canSwipeLeft;

  const SwipeMessage({
    super.key,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.enableSwipe = true,
    this.canSwipeRight,
    this.canSwipeLeft,
  });

  @override
  State<SwipeMessage> createState() => _SwipeMessageState();
}

class _SwipeMessageState extends State<SwipeMessage> {
  double _offsetX = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (!widget.enableSwipe) return;

        // only allow movement in the allowed direction
        if (details.delta.dx > 0) {
          setState(() {
            _offsetX += details.delta.dx;
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!widget.enableSwipe) return;

        if (_offsetX > 10) {
          widget.onSwipeRight?.call();
        }

        // Reset
        setState(() {
          _offsetX = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(_offsetX, 0, 0),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
