import 'package:flutter/material.dart';

/// A loading indicator shown during pagination
///
/// This widget displays a centered loading spinner when loading
/// older or newer messages.
class LoadMoreIndicator extends StatelessWidget {
  /// Color of the loading indicator
  final Color? color;

  /// Size of the loading indicator
  final double size;

  /// Padding around the indicator
  final EdgeInsets padding;

  /// Stroke width of the indicator
  final double strokeWidth;

  const LoadMoreIndicator({
    super.key,
    this.color,
    this.size = 24,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: padding,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
      ),
    );
  }
}

/// Builder type for custom load more indicator
typedef LoadMoreBuilder = Widget Function(BuildContext context);
