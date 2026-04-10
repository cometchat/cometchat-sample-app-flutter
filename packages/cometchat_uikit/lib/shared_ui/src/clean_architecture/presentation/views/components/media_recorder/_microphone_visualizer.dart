import 'package:flutter/material.dart';

class MicrophoneVisualizer extends StatefulWidget {
  final bool isAnimating;
  final double startSize;
  final double endSize;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const MicrophoneVisualizer({Key? key, required this.isAnimating, required this.startSize, required this.endSize, this.color, this.borderRadius})
      : super(key: key);

  @override
  _MicrophoneVisualizerState createState() => _MicrophoneVisualizerState();
}

class _MicrophoneVisualizerState extends State<MicrophoneVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750), // Duration of one cycle
    )..addStatusListener((status) {
      // Keep repeating the animation
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _sizeAnimation = Tween<double>(begin: widget.startSize, end: widget.endSize).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant MicrophoneVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the animation state has changed
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.forward();
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sizeAnimation,
      builder: (context, child) {
        return Container(
          width: _sizeAnimation.value,
          height: _sizeAnimation.value,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}