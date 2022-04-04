//----------- widget for right swipe options on list tile-----------
import 'package:flutter/material.dart';

class SwipeMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  const SwipeMenu({Key? key, required this.child, required this.menuItems})
      : super(key: key);

  @override
  _SwipeMenuState createState() => _SwipeMenuState();
}

class _SwipeMenuState extends State<SwipeMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = Tween(
            begin: const Offset(0.0, 0.0),
            end: Offset(-0.2 * widget.menuItems.length, 0.0))
        .animate(CurveTween(curve: Curves.decelerate).animate(_controller));

    return GestureDetector(
      onHorizontalDragUpdate: (inputData) {
        setState(() {
          _controller.value -= (inputData.primaryDelta! / context.size!.width);
        });
      },
      onHorizontalDragEnd: (inputData) {
        if (inputData.primaryVelocity! > 500) {
          _controller.animateTo(0.0);
        } else if (_controller.value >= 0.5 ||
            inputData.primaryVelocity! < -500) {
          _controller.animateTo(1.0);
        } else {
          _controller.animateTo(0.0);
        }
      },
      child: Stack(
        children: <Widget>[
          SlideTransition(position: animation, child: widget.child),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraint) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: <Widget>[
                        Positioned(
                          right: -1,
                          top: 0,
                          bottom: 0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: Row(
                              children: widget.menuItems.map((child) {
                            return Expanded(
                              child: child,
                            );
                          }).toList()),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
