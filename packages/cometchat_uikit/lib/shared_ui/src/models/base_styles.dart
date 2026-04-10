import 'package:flutter/material.dart';
import '../../cometchat_uikit_shared.dart';

///[BaseStyles] is the base style class for most style classes provided by [CometChatUIKit]
///
/// ```dart
///
/// BaseStyles(
///   width: 100.0,
///   height: 50.0,
///   background: Colors.blue,
///   gradient: LinearGradient(
///     begin: Alignment.topCenter,
///     end: Alignment.bottomCenter,
///     colors: [Colors.blue, Colors.green],
///   ),
///   border: Border.all(
///     color: Colors.grey,
///     width: 2.0,
///   ),
///   borderRadius: 10.0,
/// )
///
/// ```
class BaseStyles {
  const BaseStyles(
      {this.width,
      this.height,
      this.background,
      this.gradient,
      this.border,
      this.borderRadius});

  ///[width] provides width to the widget
  final double? width;

  ///[height] provides height to the widget
  final double? height;

  ///[background] provides background color to the widget
  final Color? background;

  ///[gradient] provides (background) gradient to the widget
  final Gradient? gradient;

  ///[border] provides border around the widget
  final BoxBorder? border;

  ///[borderRadius] provides radius to the border around the widget
  final BorderRadiusGeometry? borderRadius;
}
