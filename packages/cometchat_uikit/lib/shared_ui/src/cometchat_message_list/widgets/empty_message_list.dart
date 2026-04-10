import 'package:flutter/material.dart';

/// Empty state widget shown when there are no messages
///
/// This widget displays a centered message when the message list is empty.
/// It includes a fade-in animation for a smooth appearance.
class EmptyMessageList extends StatefulWidget {
  /// Text to display
  final String text;

  /// Text style
  final TextStyle? textStyle;

  /// Icon to display above the text
  final IconData? icon;

  /// Icon size
  final double iconSize;

  /// Icon color
  final Color? iconColor;

  /// Spacing between icon and text
  final double spacing;

  /// Animation duration
  final Duration animationDuration;

  const EmptyMessageList({
    super.key,
    this.text = 'No messages yet',
    this.textStyle,
    this.icon,
    this.iconSize = 48,
    this.iconColor,
    this.spacing = 16,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EmptyMessageList> createState() => _EmptyMessageListState();
}

class _EmptyMessageListState extends State<EmptyMessageList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.iconColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              SizedBox(height: widget.spacing),
            ],
            Text(
              widget.text,
              style: widget.textStyle ?? defaultTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Builder type for custom empty state widget
typedef EmptyMessageListBuilder = Widget Function(BuildContext context);
