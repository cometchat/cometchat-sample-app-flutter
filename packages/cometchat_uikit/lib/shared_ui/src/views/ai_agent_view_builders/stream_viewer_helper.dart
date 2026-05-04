import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that blocks intrinsic measurement from its child.
///
/// Use this to wrap scroll views or other widgets that don't support
/// intrinsic layout when used inside IntrinsicWidth/IntrinsicHeight.
class NoIntrinsicScroll extends SingleChildRenderObjectWidget {
  const NoIntrinsicScroll({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoIntrinsic();
}

class _RenderNoIntrinsic extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => null;
}
