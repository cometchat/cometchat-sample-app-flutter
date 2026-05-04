import 'package:flutter/material.dart';
import '../../../cometchat_uikit_shared.dart';

class CometchatHighlightBuilder extends StatelessWidget {
  const CometchatHighlightBuilder({
    super.key,
    this.style,
    required this.text,
    this.typography,
    this.spacing,
    this.colorPalette,
  });

  final TextStyle? style;
  final String text;
  final CometChatTypography? typography;
  final CometChatColorPalette? colorPalette;
  final CometChatSpacing? spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorPalette?.background4,
        borderRadius: BorderRadius.circular(
          spacing?.radius2 ?? 0,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing?.spacing1 ?? 0,
        vertical: spacing?.spacing1 ?? 0,
      ),
      child: Text(
        text,
        style: style?.copyWith(
          color: colorPalette?.textPrimary,
          fontFamily: typography?.body?.bold?.fontFamily,
          fontSize: typography?.body?.bold?.fontSize,
          fontWeight: typography?.body?.bold?.fontWeight,
        ),
      ),
    );
  }
}
