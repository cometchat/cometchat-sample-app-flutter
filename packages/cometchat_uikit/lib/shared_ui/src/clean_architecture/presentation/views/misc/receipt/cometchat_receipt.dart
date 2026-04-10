import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

enum ReceiptStatus { error, waiting, sent, read, delivered }

///[CometChatReceipt] is a widget that indicates the delivery status of a message
///by default, a single tick mark indicates a message has been sent
///a double tick mark indicates a message has been delivered
///a double tick mark of color `cometChatTheme.palette.primary` indicates a message has been read
/// ```dart
///
///     CometChatReceipt(
///       status: ReceiptStatus.read,
///       waitIcon: Icon(Icons.schedule),
///       sentIcon: Icon(Icons.check),
///       deliveredIcon: Icon(Icons.done_all),
///       errorIcon: Icon(Icons.error_outline),
///      );
///
/// ```
class CometChatReceipt extends StatefulWidget {
  const CometChatReceipt({
    super.key,
    this.waitIcon,
    this.sentIcon,
    this.deliveredIcon,
    this.errorIcon,
    this.readIcon,
    this.style,
    required this.status,
    this.size,
    this.colorPalette,
  });

  ///[waitIcon] widget visible while sentAt and deliveredAt is null in [BaseMessage]. If blank will load default waitIcon
  final Widget? waitIcon;

  ///[sentIcon] widget visible while sentAt != null and deliveredAt is null in [BaseMessage]. If blank will load default sentIcon
  final Widget? sentIcon;

  ///[deliveredIcon] widget visible while  deliveredAt != null  in [BaseMessage]. If blank will load default deliveredIcon
  final Widget? deliveredIcon;

  ///[errorIcon] widget visible while sentAt and deliveredAt is null in [BaseMessage]. If blank will load default errorIcon
  final Widget? errorIcon;

  ///[readIcon] widget visible when readAt != null in [BaseMessage]. If blank will load default readIcon
  final Widget? readIcon;

  ///[style] to customize the appearance of [CometChatReceipt]
  final CometChatMessageReceiptStyle? style;

  ///receipt status from which sentAt and readAt will be read to get the receipts
  final ReceiptStatus status;

  ///[size] size of the receipt icon
  final double? size;

  /// [colorPalette] optional pre-cached color palette to avoid expensive lookups during keyboard animation
  final CometChatColorPalette? colorPalette;

  @override
  State<CometChatReceipt> createState() => _CometChatReceiptState();
}

class _CometChatReceiptState extends State<CometChatReceipt> {
  // Cached theme values to avoid expensive lookups during rebuilds
  CometChatMessageReceiptStyle? _receiptsStyle;
  CometChatColorPalette? _colorPalette;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize theme once to avoid expensive lookups during keyboard animation
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      _receiptsStyle = CometChatThemeHelper.getTheme<CometChatMessageReceiptStyle>(
              context: context, defaultTheme: CometChatMessageReceiptStyle.of)
          .merge(widget.style);
      // Use passed values OR fallback to lookup (for standalone usage)
      _colorPalette = widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);
      _themeInitialized = true;
    }
  }

  @override
  void didUpdateWidget(CometChatReceipt oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update style if it changed
    if (widget.style != oldWidget.style) {
      _receiptsStyle = CometChatThemeHelper.getTheme<CometChatMessageReceiptStyle>(
              context: context, defaultTheme: CometChatMessageReceiptStyle.of)
          .merge(widget.style);
    }
    // Update cached theme values if they changed
    if (widget.colorPalette != oldWidget.colorPalette && widget.colorPalette != null) {
      _colorPalette = widget.colorPalette;
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptsStyle = _receiptsStyle!;
    final colorPalette = _colorPalette!;

    late Widget receiptWidget;
    receiptWidget = widget.waitIcon ??
        Icon(
          Icons.schedule,
          color: receiptsStyle.waitIconColor ?? colorPalette.iconSecondary,
          size: widget.size,
        );
    if (widget.status == ReceiptStatus.error) {
      receiptWidget = widget.errorIcon ??
          Icon(
            Icons.error_outline_outlined,
            color: receiptsStyle.errorIconColor ?? colorPalette.error,
            size: widget.size,
          );
    } else if (widget.status == ReceiptStatus.read) {
      receiptWidget = widget.readIcon ??
          Icon(
            Icons.done_all,
            color: receiptsStyle.readIconColor ?? colorPalette.messageSeen,
            size: widget.size,
          );
    } else if (widget.status == ReceiptStatus.delivered) {
      receiptWidget = widget.deliveredIcon ??
          Icon(
            Icons.done_all,
            color:
                receiptsStyle.deliveredIconColor ?? colorPalette.iconSecondary,
            size: widget.size,
          );
    } else if (widget.status == ReceiptStatus.sent) {
      receiptWidget = widget.sentIcon ??
          Icon(
            Icons.check,
            color: receiptsStyle.sentIconColor ?? colorPalette.iconSecondary,
            size: widget.size,
          );
    } else if (widget.status == ReceiptStatus.waiting) {
      receiptWidget = widget.waitIcon ??
          Icon(
            Icons.schedule,
            color: receiptsStyle.waitIconColor ?? colorPalette.iconSecondary,
            size: widget.size,
          );
    } else {
      receiptWidget = const SizedBox();
    }

    return receiptWidget;
  }
}
