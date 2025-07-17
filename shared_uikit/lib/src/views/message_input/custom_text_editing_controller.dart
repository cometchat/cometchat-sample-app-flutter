import 'dart:math' as math;

import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomTextEditingController extends TextEditingController {

  List<CometChatTextFormatter>? formatters;
  CustomTextEditingController({
    super.text,
    this.formatters,
  }) {
    formatters;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    if (formatters == null || formatters!.isEmpty) {
      return super.buildTextSpan(
          context: context, style: style, withComposing: withComposing);
    } else {
      return TextSpan(
          style: style, children:buildSpan(context, style, withComposing)
      );
    }
  }

  List<InlineSpan> buildSpan(
      BuildContext context,
      TextStyle? style,
      bool withComposing
      ) {
    // 1. Get default styling
    final defaultStyle = _getDefaultTextStyle(context, style);

    // 2. Collect all attributions from formatters
    final attributions = _collectAttributions(context, style, withComposing);

    // 3. Build spans
    return _buildSpansFromAttributions(text, attributions, defaultStyle);
  }

  TextStyle _getDefaultTextStyle(BuildContext context, TextStyle? style) {
    final palette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return TextStyle(
      color: palette.textPrimary,
      fontWeight: typography.body?.regular?.fontWeight,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
    ).merge(style);
  }

  List<AttributedText> _collectAttributions(
      BuildContext context,
      TextStyle? style,
      bool withComposing
      ) {
    final attributions = <AttributedText>[];

    for (final formatter in formatters ?? []) {
      attributions.addAll(formatter.buildInputFieldText(
        text: text,
        style: style,
        context: context,
        withComposing: withComposing,
      ));
    }

    return _mergeOverlappingAttributions(attributions);
  }

  List<InlineSpan> _buildSpansFromAttributions(
      String text,
      List<AttributedText> attributions,
      TextStyle defaultStyle,
      ) {
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final attr in attributions) {
      // Add text before attribution
      if (attr.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, attr.start),
          style: defaultStyle,
        ));
      }

      // Add attributed text
      spans.add(_buildAttributedSpan(attr, defaultStyle));
      lastEnd = attr.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  InlineSpan _buildAttributedSpan(AttributedText attr, TextStyle defaultStyle) {
    final onTap = attr.onTap;

    return TextSpan(
      text: attr.underlyingText ?? text.substring(attr.start, attr.end),
      style: (attr.style ?? defaultStyle).copyWith(
        backgroundColor: attr.backgroundColor,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final tappedText = attr.underlyingText ?? text.substring(attr.start, attr.end);
          if (onTap != null) onTap(tappedText);
        },
    );
  }


  String _mergeUnderlyingText(AttributedText a, AttributedText b) {
    final start = math.min(a.start, b.start);
    final end = math.max(a.end, b.end);
    return text.substring(start, end);
  }


  List<AttributedText> _mergeOverlappingAttributions(List<AttributedText> attributions) {
    if (attributions.isEmpty) return [];

    // 1. Sort attributions by start position
    attributions.sort((a, b) => a.start.compareTo(b.start));

    final merged = <AttributedText>[];
    var current = attributions.first;

    for (var i = 1; i < attributions.length; i++) {
      final next = attributions[i];

      // 2. Check if attributions overlap or are adjacent
      if (current.end >= next.start) {
        // Merge the two attributions
        current = AttributedText(
          start: math.min(current.start, next.start),
          end: math.max(current.end, next.end),
          underlyingText: _mergeUnderlyingText(current, next),
          style: _mergeStyles(current.style, next.style),
          backgroundColor: _mergeBackgrounds(current.backgroundColor, next.backgroundColor),
          borderRadius: current.borderRadius ?? next.borderRadius,
          padding: current.padding ?? next.padding,
          onTap: current.onTap ?? next.onTap,
        );
      } else {
        // 3. No overlap - add current and move to next
        merged.add(current);
        current = next;
      }
    }

    // 4. Add the last merged attribution
    merged.add(current);
    return merged;
  }

// Helper to merge text styles
  TextStyle? _mergeStyles(TextStyle? a, TextStyle? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.merge(b);
  }

// Helper to merge background colors
  Color? _mergeBackgrounds(Color? a, Color? b) {
    if (a == null) return b;
    if (b == null) return a;

    // Merge the two background colors using alpha blending.
    // This approach ensures that the resulting color is a blend of both inputs,
    // taking into account their respective alpha values. This strategy was chosen
    // to provide a visually consistent result when overlapping attributions have
    // different background colors.

    return Color.alphaBlend(a, b); // Or choose one based on priority
  }
}
