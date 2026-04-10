import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_type.dart';
import 'cometchat_rich_text_toolbar_style.dart';

/// A single button in the rich text formatting toolbar
class RichTextToolbarButton extends StatelessWidget {
  const RichTextToolbarButton({
    super.key,
    required this.formatType,
    required this.onTap,
    this.isActive = false,
    this.isDisabled = false,
    this.style,
    this.focusOrder,
  });

  /// The format type this button represents
  final FormatType formatType;

  /// Callback when the button is tapped
  final VoidCallback onTap;

  /// Whether this format is currently active
  final bool isActive;

  /// Whether this format is disabled (incompatible with active formats)
  final bool isDisabled;

  /// Custom styling for the button
  final CometChatRichTextToolbarStyle? style;

  /// Focus order for keyboard navigation
  final int? focusOrder;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        CometChatRichTextToolbarStyle.of(context).merge(style);

    final buttonSize = effectiveStyle.buttonSize ?? 36;
    final iconSize = effectiveStyle.iconSize ?? 20;

    // Determine colors based on state: active > disabled > normal
    final Color? backgroundColor;
    final Color? iconColor;

    if (isActive) {
      backgroundColor = effectiveStyle.activeButtonColor;
      iconColor = effectiveStyle.activeButtonIconColor;
    } else if (isDisabled) {
      backgroundColor = effectiveStyle.disabledButtonColor;
      iconColor = effectiveStyle.disabledButtonIconColor;
    } else {
      backgroundColor = effectiveStyle.buttonColor;
      iconColor = effectiveStyle.buttonIconColor;
    }

    Widget button = Semantics(
      label: formatType.label,
      button: true,
      selected: isActive,
      enabled: !isDisabled,
      child: Tooltip(
        message: isDisabled 
            ? '${formatType.label} (incompatible with current format)'
            : formatType.label,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              formatType.icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    // Only add keyboard support if not disabled
    if (!isDisabled) {
      button = FocusableActionDetector(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap();
              return null;
            },
          ),
        },
        child: button,
      );
    }

    // Add focus order if provided
    if (focusOrder != null) {
      button = FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder!.toDouble()),
        child: button,
      );
    }

    return button;
  }
}
