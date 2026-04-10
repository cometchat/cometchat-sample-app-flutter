import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///creates a widget that gives group action bubble
///
/// ```dart
///  CometChatActionBubble(
///            text: 'Group created',
///            style: CometChatActionBubbleStyle(
///            backgroundColor: Colors.green,
///            textStyle: TextStyle(
///            color: Colors.white,
///            fontSize: 14,
///            fontWeight: FontWeight.bold,
///            ),
///            ),
///        )
///  ```
///
class CometChatActionBubble extends StatefulWidget {
  const CometChatActionBubble(
      {super.key,
      this.message,
      required this.text,
      this.style,
      this.leadingIcon,
        this.padding, this.height, this.width
      });

  ///[message] action message object
  final String? message;

  ///[text] if message object is not passed then text should be passed
  final String? text;

  ///[style] group action bubble styling properties
  final CometChatActionBubbleStyle? style;

  ///[leadingIcon] leading icon to the action bubble
  final Widget? leadingIcon;

  ///[height] height of the action bubble
  final double? height;

  ///[width] width of the action bubble
  final double? width;

  /// [padding] provides padding to the widget
  final EdgeInsetsGeometry? padding;

  @override
  State<CometChatActionBubble> createState() => _CometChatActionBubbleState();
}

class _CometChatActionBubbleState extends State<CometChatActionBubble> {
  late CometChatActionBubbleStyle actionBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  
  // Cached values to avoid MediaQuery in build()
  double _cachedMaxWidth = 300;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      _themeInitialized = true;
      // Cache theme values
      actionBubbleStyle = CometChatThemeHelper.getTheme<CometChatActionBubbleStyle>(
        context: context,
        defaultTheme: CometChatActionBubbleStyle.of
      ).merge(widget.style);
      colorPalette = CometChatThemeHelper.getColorPalette(context);
      spacing = CometChatThemeHelper.getSpacing(context);
      typography = CometChatThemeHelper.getTypography(context);
      // Cache width to avoid MediaQuery in build()
      _cachedMaxWidth = MediaQuery.sizeOf(context).width * 0.85;
    }
  }

  @override
  void didUpdateWidget(CometChatActionBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style && widget.style != null) {
      actionBubbleStyle = CometChatThemeHelper.getTheme<CometChatActionBubbleStyle>(
        context: context,
        defaultTheme: CometChatActionBubbleStyle.of
      ).merge(widget.style);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? text = widget.text;

    return Container(
      height: widget.height,
      width: widget.width,
      constraints: BoxConstraints(
        maxWidth: _cachedMaxWidth,
      ),
      padding: widget.padding ?? EdgeInsets.symmetric(vertical: spacing.padding1 ?? 0, horizontal: spacing.padding3 ?? 0),
      decoration: BoxDecoration(
          color: actionBubbleStyle.backgroundColor ?? colorPalette.background2,
          border: actionBubbleStyle.border ??
              Border.all(
                color: colorPalette.borderDefault ?? Colors.transparent,
                width: 1
              ),
          borderRadius: actionBubbleStyle.borderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 0),
        ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.leadingIcon != null) widget.leadingIcon!,
          Flexible(
            child: Text(
              _sanitizeUtf16(text ?? ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  TextStyle(
                      fontSize: typography.caption1?.regular?.fontSize,
                      fontWeight: typography.caption1?.regular?.fontWeight,
                      fontFamily: typography.caption1?.regular?.fontFamily,
                      color: colorPalette.textSecondary,
                      letterSpacing: 0
                  ).merge(actionBubbleStyle.textStyle),
            ),
          ),
        ],
      ),
    );
  }

  String _sanitizeUtf16(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final codeUnit = input.codeUnitAt(i);

      // If this is a high surrogate, check if the next code unit is a low surrogate
      if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
        if (i + 1 < input.length) {
          final nextUnit = input.codeUnitAt(i + 1);
          if (nextUnit >= 0xDC00 && nextUnit <= 0xDFFF) {
            // Valid surrogate pair, add both
            buffer.writeCharCode(codeUnit);
            buffer.writeCharCode(nextUnit);
            i++; // Skip next code unit
            continue;
          }
        }
        // Invalid high surrogate, skip it
        continue;
      }

      // If this is a low surrogate without a preceding high surrogate, skip it
      if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) continue;

      // Valid single code unit
      buffer.writeCharCode(codeUnit);
    }
    return buffer.toString();
  }
}
