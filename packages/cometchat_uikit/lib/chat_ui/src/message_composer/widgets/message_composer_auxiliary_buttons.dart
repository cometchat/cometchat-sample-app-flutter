import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// A widget that displays the auxiliary action buttons (stickers, voice recording).
///
/// This widget renders buttons on the right side of the text input in the
/// single-row message composer layout:
/// - Auxiliary options from the data source (stickers, emoji, etc.)
/// - Voice recording button (with slide-to-send animation on hide)
///
/// Example usage:
/// ```dart
/// MessageComposerAuxiliaryButtons(
///   onVoiceRecordingTap: () => showVoiceRecorder(),
/// )
/// ```
class MessageComposerAuxiliaryButtons extends StatefulWidget {
  const MessageComposerAuxiliaryButtons({
    super.key,
    required this.onVoiceRecordingTap,
    this.hideVoiceRecordingButton = false,
    this.customAuxiliaryButtonView,
    this.auxiliaryOptions,
    this.voiceRecordingIcon,
    this.auxiliaryButtonIconColor,
    this.auxiliaryButtonIconBackgroundColor,
    this.auxiliaryButtonBorderRadius,
    this.colorPalette,
    this.spacing,
  });

  final VoidCallback onVoiceRecordingTap;
  final bool hideVoiceRecordingButton;
  final Widget? customAuxiliaryButtonView;
  final Widget? auxiliaryOptions;
  final Widget? voiceRecordingIcon;
  final Color? auxiliaryButtonIconColor;
  final Color? auxiliaryButtonIconBackgroundColor;
  final BorderRadiusGeometry? auxiliaryButtonBorderRadius;
  final CometChatColorPalette? colorPalette;
  final CometChatSpacing? spacing;

  @override
  State<MessageComposerAuxiliaryButtons> createState() =>
      _MessageComposerAuxiliaryButtonsState();
}

class _MessageComposerAuxiliaryButtonsState
    extends State<MessageComposerAuxiliaryButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // Track visibility to drive animation direction
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _isVisible = !widget.hideVoiceRecordingButton;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _isVisible ? 1.0 : 0.0,
    );

    _sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Slide from right (toward send button) when hiding
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(MessageComposerAuxiliaryButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldBeVisible = !widget.hideVoiceRecordingButton;
    if (shouldBeVisible != _isVisible) {
      _isVisible = shouldBeVisible;
      if (_isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customAuxiliaryButtonView != null) {
      return widget.customAuxiliaryButtonView!;
    }

    final effectiveColorPalette =
        widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);

    final bool hasAuxOptions = widget.auxiliaryOptions != null;

    return Semantics(
      label: 'Message composer auxiliary actions',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.auxiliaryButtonIconBackgroundColor,
          borderRadius: widget.auxiliaryButtonBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasAuxOptions) widget.auxiliaryOptions!,
            // Animated mic button — slides toward send button while width collapses
            SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: _sizeAnimation,
              axisAlignment: 1.0, // Collapse toward the right (send button)
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: _buildVoiceRecordingButton(
                    effectiveColorPalette,
                    needsLeftMargin: hasAuxOptions,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecordingButton(
    CometChatColorPalette colorPalette, {
    bool needsLeftMargin = false,
  }) {
    final Color iconColor =
        widget.auxiliaryButtonIconColor ??
        colorPalette.iconSecondary ??
        Colors.grey;

    return Semantics(
      label: 'Record voice message',
      button: true,
      child: Container(
        height: 24,
        width: 24,
        margin: needsLeftMargin
            ? const EdgeInsets.only(left: 12)
            : null,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          constraints: const BoxConstraints(),
          icon: widget.voiceRecordingIcon ??
              Image.asset(
                AssetConstants.microphone,
                package: UIConstants.packageName,
                height: 24,
                width: 24,
                color: iconColor,
              ),
          onPressed: widget.onVoiceRecordingTap,
        ),
      ),
    );
  }
}
