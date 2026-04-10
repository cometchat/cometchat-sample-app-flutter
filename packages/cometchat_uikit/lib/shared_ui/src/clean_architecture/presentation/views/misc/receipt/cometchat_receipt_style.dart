import 'package:flutter/material.dart';

///[CometChatMessageReceiptStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatReceipt]
///``` dart
///CometChatMessageReceiptStyle(
/// waitIconColor: Colors.grey,
/// sentIconColor: Colors.blue,
/// deliveredIconColor: Colors.orange,
/// readIconColor: Colors.green,
/// errorIconColor: Colors.red,
/// );
/// ```
class CometChatMessageReceiptStyle
    extends ThemeExtension<CometChatMessageReceiptStyle> {
  CometChatMessageReceiptStyle({
    this.waitIconColor,
    this.sentIconColor,
    this.deliveredIconColor,
    this.readIconColor,
    this.errorIconColor,
  });

  ///[waitIconColor] It is used to change the icon color of receipt when ReceiptStatus is wait
  final Color? waitIconColor;

  ///[sentIconColor] It is used to change the icon color of receipt when ReceiptStatus is sent
  final Color? sentIconColor;

  ///[deliveredIconColor] It is used to change the icon color of receipt when ReceiptStatus is delivered
  final Color? deliveredIconColor;

  ///[readIconColor] It is used to change the icon color of receipt when ReceiptStatus is read
  final Color? readIconColor;

  ///[errorIconColor] It is used to change the icon color of receipt when ReceiptStatus is error
  final Color? errorIconColor;

  static CometChatMessageReceiptStyle of(BuildContext context) =>
      CometChatMessageReceiptStyle();

  @override
  CometChatMessageReceiptStyle copyWith({
    Color? waitIconColor,
    Color? sentIconColor,
    Color? deliveredIconColor,
    Color? readIconColor,
    Color? errorIconColor,
  }) {
    return CometChatMessageReceiptStyle(
      waitIconColor: waitIconColor ?? this.waitIconColor,
      sentIconColor: sentIconColor ?? this.sentIconColor,
      deliveredIconColor: deliveredIconColor ?? this.deliveredIconColor,
      readIconColor: readIconColor ?? this.readIconColor,
      errorIconColor: errorIconColor ?? this.errorIconColor,
    );
  }

  CometChatMessageReceiptStyle merge(CometChatMessageReceiptStyle? style) {
    if (style == null) return this;
    return copyWith(
      waitIconColor: style.waitIconColor,
      sentIconColor: style.sentIconColor,
      deliveredIconColor: style.deliveredIconColor,
      readIconColor: style.readIconColor,
      errorIconColor: style.errorIconColor,
    );
  }

  @override
  CometChatMessageReceiptStyle lerp(
      ThemeExtension<CometChatMessageReceiptStyle>? other, double t) {
    if (other is! CometChatMessageReceiptStyle) {
      return this;
    }
    return CometChatMessageReceiptStyle(
      waitIconColor: Color.lerp(waitIconColor, other.waitIconColor, t),
      sentIconColor: Color.lerp(sentIconColor, other.sentIconColor, t),
      deliveredIconColor:
          Color.lerp(deliveredIconColor, other.deliveredIconColor, t),
      readIconColor: Color.lerp(readIconColor, other.readIconColor, t),
      errorIconColor: Color.lerp(errorIconColor, other.errorIconColor, t),
    );
  }
}
