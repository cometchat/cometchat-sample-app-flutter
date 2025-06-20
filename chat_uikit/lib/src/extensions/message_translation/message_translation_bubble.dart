import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[MessageTranslationBubble] is a widget that is rendered as the content view for [MessageTranslationExtension]
///
/// ```dart
/// MessageTranslationBubble(
///   translatedText: "¡Hola mundo!",
///   alignment: BubbleAlignment.right,
///   style: MessageTranslationBubbleStyle(
///     translatedTextStyle: TextStyle(
///       fontSize: 16,
///       fontWeight: FontWeight.bold,
///       color: Colors.black,
///     ),
///   ),
/// );
///
/// ```
class MessageTranslationBubble extends StatelessWidget {
  const MessageTranslationBubble(
      {super.key,
      this.translatedText = "",
      required this.alignment,
      this.child,
      this.style});

  ///[translatedText] translated version of messageText
  final String translatedText;

  ///[alignment] of the bubble
  final BubbleAlignment alignment;

  ///[child] some child component
  final Widget? child;

  ///[style] styles this bubble
  final CometChatMessageTranslationBubbleStyle? style;

  @override
  Widget build(BuildContext context) {
    final style =
        CometChatThemeHelper.getTheme<CometChatMessageTranslationBubbleStyle>(
                defaultTheme: CometChatMessageTranslationBubbleStyle.of,
                context: context)
            .merge(this.style);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 232),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (child != null)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: style.dividerColor ??
                            (alignment == BubbleAlignment.right
                                ? colorPalette.extendedPrimary800
                                : colorPalette.neutral400) ??
                            Colors.transparent,
                        width: 1)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: spacing.padding2 ?? 0),
                child: child!,
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
                left: spacing.padding2 ?? 0, right: spacing.padding2 ?? 0, top: spacing.padding2 ?? 0),
            child: Text(
              translatedText,
              style: style.translatedTextStyle ??
                  TextStyle(
                      color: alignment == BubbleAlignment.right
                          ? colorPalette.white
                          : colorPalette.neutral900,
                      fontWeight: typography.body?.regular?.fontWeight,
                      fontSize: typography.body?.regular?.fontSize,
                      fontFamily: typography.body?.regular?.fontFamily),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.padding2 ?? 0,
                vertical: spacing.padding ?? 0),
            child: Text(
              Translations.of(context).textTranslated,
              style: style.infoTextStyle ??
                  TextStyle(
                      color: alignment == BubbleAlignment.right
                          ? colorPalette.white
                          : colorPalette.neutral900,
                      fontWeight: FontWeight.w400,
                      fontSize: typography.caption2?.regular?.fontSize,
                      fontFamily: typography.caption2?.regular?.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
