import 'package:flutter/material.dart';

/// Style configuration for [CometChatNewMessageIndicator].
///
/// Controls the appearance of the "New Messages" divider that appears
/// above the first unread message in the message list.
class CometChatNewMessageIndicatorStyle {
  /// Color of the "New Messages" text
  final Color? textColor;

  /// Color of the horizontal divider lines
  final Color? dividerColor;

  /// Text style for the "New Messages" label
  final TextStyle? textStyle;

  /// Background color behind the indicator
  final Color? backgroundColor;

  const CometChatNewMessageIndicatorStyle({
    this.textColor,
    this.dividerColor,
    this.textStyle,
    this.backgroundColor,
  });

  /// Merges this style with [other]. Non-null values in [other] take precedence.
  CometChatNewMessageIndicatorStyle merge(
    CometChatNewMessageIndicatorStyle? other,
  ) {
    if (other == null) return this;
    return CometChatNewMessageIndicatorStyle(
      textColor: other.textColor ?? textColor,
      dividerColor: other.dividerColor ?? dividerColor,
      textStyle: other.textStyle ?? textStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
    );
  }
}
