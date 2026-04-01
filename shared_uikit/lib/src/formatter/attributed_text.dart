import 'package:flutter/material.dart';

///[AttributedText] is a class which is used to style the text
/// ```dart
/// AttributedText(
///    start: 0,
///    end: 5,
///    underlyingText: 'Hello',
///    style: TextStyle(
///    color: Colors.pink,
///    ),
///    onTap: (text) {
///    print(text);
///    },
///    );
///    ```
class AttributedText {
  AttributedText(
      {required this.start,
      required this.end,
      this.underlyingText,
      this.style,
      this.onTap,
      this.padding,
      this.backgroundColor,
      this.borderRadius,
      this.border,
      this.isFullWidth = false,
      this.childSpans,
      });

  ///[start] is an integer value which is used to store the start index of the text
  int start;

  ///[end] is an integer value which is used to store the end index of the text
  int end;

  ///[style] is a [TextStyle] object which is used to style the text
  TextStyle? style;

  ///[underlyingText] is a [String] value which is used to store the text
  String? underlyingText;

  ///[onTap] is a function which is used to perform some action when the text is tapped
  Function(String)? onTap;

  ///[backgroundColor] is a [Color] object which is used to give background color to the text
  Color? backgroundColor;

  ///[padding] is a [EdgeInsetsGeometry] object which is used to give padding to the text
  EdgeInsetsGeometry? padding;

  ///[borderRadius] is a [double] value which is used to give border radius to the text
  double? borderRadius;

  ///[border] is a [Border] object which is used to give border to the text container
  Border? border;

  ///[isFullWidth] is a boolean to indicate if the container should span full width
  bool isFullWidth;

  ///[childSpans] is a list of [InlineSpan] objects for rich text content
  ///When provided, the attributed text will render using RichText with these spans
  ///instead of a simple Text widget. This enables mixed formatting within containers.
  List<InlineSpan>? childSpans;

  @override
  String toString() {
    return 'AttributedText{start: $start, end: $end, underlyingText: $underlyingText, style: $style}';
  }
}
