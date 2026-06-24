import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that prevents intrinsic dimension queries from reaching its child.
///
/// This solves the `LayoutBuilder does not support returning intrinsic dimensions`
/// crash when `CometChatCardView` (which uses LayoutBuilder internally) is placed
/// inside an `IntrinsicWidth` widget in the message bubble.
///
/// It reports a fixed width for intrinsic queries and lays out the child with
/// tight width constraints, so the parent `IntrinsicWidth` never needs to
/// ask the LayoutBuilder for its intrinsic dimensions.
class NoIntrinsicCardWrapper extends SingleChildRenderObjectWidget {
  final double width;

  const NoIntrinsicCardWrapper({
    super.key,
    required this.width,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderNoIntrinsicSize(width: width);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderNoIntrinsicSize renderObject) {
    renderObject.fixedWidth = width;
  }
}

class _RenderNoIntrinsicSize extends RenderProxyBox {
  double _fixedWidth;

  _RenderNoIntrinsicSize({required double width}) : _fixedWidth = width;

  set fixedWidth(double value) {
    if (_fixedWidth != value) {
      _fixedWidth = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _fixedWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _fixedWidth;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(
        BoxConstraints.tightFor(width: _fixedWidth),
        parentUsesSize: true,
      );
      size = child!.size;
    } else {
      size = Size(_fixedWidth, 0);
    }
  }
}
