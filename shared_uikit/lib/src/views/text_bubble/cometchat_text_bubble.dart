import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatTextBubble] is a widget that gives text bubble
/// ```dart
/// CometChatTextBubble(
///     text: 'some text message',
///     alignment: BubbleAlignment.left,
///     style: TextBubbleStyle(
///          background: Colors.white,
///          textColor: Colors.black,
///       ),
/// );
/// ```
class CometChatTextBubble extends StatelessWidget {
  const CometChatTextBubble({
    super.key,
    this.text,
    this.style,
    this.alignment,
    this.formatters,
    this.width,
    this.height,
    this.padding
  });

  ///[text] if message object is not passed then text should be passed
  final String? text;

  ///[style] manages the styling of this widget
  final CometChatTextBubbleStyle? style;

  final double? width;
  final double? height;

  ///[alignment] of the bubble
  final BubbleAlignment? alignment;

  ///[formatters] is a list of [CometChatTextFormatter] which is used to style the text
  final List<CometChatTextFormatter>? formatters;

  ///[padding] is used to give padding to the text bubble
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    String? message;
    if (text != null) {
      message = text;
    }

    if (message == null) {
      return const SizedBox(height: 0, width: 0);
    }

    final textBubbleStyle = CometChatThemeHelper.getTheme<CometChatTextBubbleStyle>(context: context,defaultTheme: CometChatTextBubbleStyle.of).merge(style);
    CometChatTypography typography = CometChatThemeHelper.getTypography(context);
    CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(context);
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);

    final textStyle = TextStyle(
        color: ( alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.neutral900),
        fontWeight: typography.body?.regular?.fontWeight,
        fontSize: typography.body?.regular?.fontSize,
        fontFamily: typography.body?.regular?.fontFamily).merge(textBubbleStyle.textStyle).copyWith(color: textBubbleStyle.textColor);

    return Container(
        height: height,
      constraints: BoxConstraints(
          maxWidth: width ??
              MediaQuery.of(context).size.width *
                  (65 / 100)),
        decoration: BoxDecoration(
            border:textBubbleStyle.border,
            borderRadius: textBubbleStyle.borderRadius ?? BorderRadius.circular(spacing.radius3 ?? 0),
            color: textBubbleStyle.backgroundColor ?? colorPalette.transparent,),
        child: Padding(
          padding: padding ?? EdgeInsets.fromLTRB(spacing.padding2 ?? 0, spacing.padding2 ?? 0, spacing.padding2 ?? 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              text: TextSpan(
                  style:textStyle,
                  children: FormatterUtils.buildTextSpan(
                      message, formatters, context, alignment)),
            ),
          ),
        ));
  }
}
