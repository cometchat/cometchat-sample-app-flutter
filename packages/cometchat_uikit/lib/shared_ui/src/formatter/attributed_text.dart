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
  AttributedText({
    required this.start,
    required this.end,
    this.underlyingText,
    this.style,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.isBlockElement = false,
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
  ///Useful for Slack-style blockquotes with left border
  Border? border;

  ///[isBlockElement] indicates if this is a block-level element (like code block or blockquote)
  ///Block elements should take full width and have distinct visual styling
  bool isBlockElement;

  @override
  String toString() {
    return 'AttributedText{start: $start, end: $end, underlyingText: $underlyingText, style: $style}';
  }
}
