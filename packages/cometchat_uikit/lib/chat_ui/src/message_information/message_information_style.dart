import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatMessageInformationStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatMessageInformation]
///```dart
/// CometChatMessageInformationStyle(
///  titleTextStyle: TextStyle(
///  color: Colors.red,
///  fontSize: 16,
///  fontWeight: FontWeight.bold,
///  ),
///  titleTextColor: Colors.red,
///  backgroundColor: Colors.white,
///  border: Border.all(color: Colors.red),
///  borderRadius: BorderRadius.circular(10),
///  nameTextStyle: TextStyle(
///  color: Colors.red,
///  fontSize: 16,
///  fontWeight: FontWeight.bold,
///  ),
///  );
///  ```
class CometChatMessageInformationStyle
    extends ThemeExtension<CometChatMessageInformationStyle> {
  const CometChatMessageInformationStyle({
    this.titleTextStyle,
    this.titleTextColor,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.nameTextStyle,
    this.readTextStyle,
    this.readDateTextStyle,
    this.deliveredTextStyle,
    this.deliveredDateTextStyle,
    this.deliveredDateTextColor,
    this.deliveredTextColor,
    this.nameTextColor,
    this.readDateTextColor,
    this.readTextColor,
    this.avatarStyle,
    this.backgroundHighLightColor,
    this.messageReceiptStyle,
  });

  ///[titleTextStyle] defines the style of the title in [CometChatMessageInformation]
  final TextStyle? titleTextStyle;

  ///[titleTextColor] defines the color of the title in [CometChatMessageInformation]
  final Color? titleTextColor;

  ///[backgroundColor] defines the backgroundColor in [CometChatMessageInformation]
  final Color? backgroundColor;

  ///[border] defines the border of the [CometChatMessageInformation]
  final BoxBorder? border;

  ///[borderRadius] defines the border radius of the [CometChatMessageInformation]
  final BorderRadiusGeometry? borderRadius;

  ///[nameTextStyle] defines the style of the name in [CometChatMessageInformation]
  final TextStyle? nameTextStyle;

  ///[nameTextColor] defines the color of the name in [CometChatMessageInformation]
  final Color? nameTextColor;

  ///[readTextStyle] defines the style of the read text in [CometChatMessageInformation]
  final TextStyle? readTextStyle;

  ///[readTextColor] defines the color of the read in [CometChatMessageInformation]
  final Color? readTextColor;

  ///[readDateTextStyle] defines the style of the read date in [CometChatMessageInformation]
  final TextStyle? readDateTextStyle;

  ///[readDateTextColor] defines the color of the read date in [CometChatMessageInformation]
  final Color? readDateTextColor;

  ///[deliveredTextStyle] defines the style of the delivered text in [CometChatMessageInformation]
  final TextStyle? deliveredTextStyle;

  ///[deliveredTextColor] defines the color of the delivered in [CometChatMessageInformation]
  final Color? deliveredTextColor;

  ///[deliveredDateTextStyle] defines the style of the delivered date in [CometChatMessageInformation]
  final TextStyle? deliveredDateTextStyle;

  ///[deliveredDateTextColor] defines the color of the delivered date in [CometChatMessageInformation]
  final Color? deliveredDateTextColor;

  ///[backgroundHighLightColor] defines the color of the background highlight behind the message bubble in [CometChatMessageInformation]
  final Color? backgroundHighLightColor;

  ///[avatarStyle] to style the avatar
  final CometChatAvatarStyle? avatarStyle;

  ///[messageReceipt] to get the message receipt
  final CometChatMessageReceiptStyle? messageReceiptStyle;

  static CometChatMessageInformationStyle of(BuildContext context) =>
      const CometChatMessageInformationStyle();

  @override
  CometChatMessageInformationStyle copyWith(
      {TextStyle? titleTextStyle,
      Color? titleTextColor,
      Color? backgroundColor,
      BoxBorder? border,
      BorderRadiusGeometry? borderRadius,
      TextStyle? nameTextStyle,
      TextStyle? readTextStyle,
      TextStyle? readDateTextStyle,
      TextStyle? deliveredTextStyle,
      TextStyle? deliveredDateTextStyle,
      Color? deliveredDateTextColor,
      Color? deliveredTextColor,
      Color? nameTextColor,
      Color? readDateTextColor,
      Color? readTextColor,
      CometChatAvatarStyle? messageBubbleAvatarStyle,
      Color? backgroundHighLightColor,
      CometChatMessageReceiptStyle? messageReceiptStyle}) {
    return CometChatMessageInformationStyle(
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      readTextStyle: readTextStyle ?? this.readTextStyle,
      readDateTextStyle: readDateTextStyle ?? this.readDateTextStyle,
      deliveredTextStyle: deliveredTextStyle ?? this.deliveredTextStyle,
      deliveredDateTextStyle:
          deliveredDateTextStyle ?? this.deliveredDateTextStyle,
      deliveredDateTextColor:
          deliveredDateTextColor ?? this.deliveredDateTextColor,
      deliveredTextColor: deliveredTextColor ?? this.deliveredTextColor,
      nameTextColor: nameTextColor ?? this.nameTextColor,
      readDateTextColor: readDateTextColor ?? this.readDateTextColor,
      readTextColor: readTextColor ?? this.readTextColor,
      avatarStyle: messageBubbleAvatarStyle ?? avatarStyle,
      backgroundHighLightColor:
          backgroundHighLightColor ?? this.backgroundHighLightColor,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
    );
  }

  CometChatMessageInformationStyle merge(
      CometChatMessageInformationStyle? style) {
    if (style == null) return this;
    return copyWith(
      titleTextStyle: style.titleTextStyle,
      titleTextColor: style.titleTextColor,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      nameTextStyle: style.nameTextStyle,
      readTextStyle: style.readTextStyle,
      readDateTextStyle: style.readDateTextStyle,
      deliveredTextStyle: style.deliveredTextStyle,
      deliveredDateTextStyle: style.deliveredDateTextStyle,
      deliveredDateTextColor: style.deliveredDateTextColor,
      deliveredTextColor: style.deliveredTextColor,
      nameTextColor: style.nameTextColor,
      readDateTextColor: style.readDateTextColor,
      readTextColor: style.readTextColor,
      messageBubbleAvatarStyle: style.avatarStyle,
      backgroundHighLightColor: style.backgroundHighLightColor,
      messageReceiptStyle: style.messageReceiptStyle,
    );
  }

  @override
  CometChatMessageInformationStyle lerp(
      ThemeExtension<CometChatMessageInformationStyle>? other, double t) {
    if (other is! CometChatMessageInformationStyle) {
      return this;
    }
    return CometChatMessageInformationStyle(
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      readTextStyle: TextStyle.lerp(readTextStyle, other.readTextStyle, t),
      readDateTextStyle:
          TextStyle.lerp(readDateTextStyle, other.readDateTextStyle, t),
      deliveredTextStyle:
          TextStyle.lerp(deliveredTextStyle, other.deliveredTextStyle, t),
      deliveredDateTextStyle: TextStyle.lerp(
          deliveredDateTextStyle, other.deliveredDateTextStyle, t),
      deliveredDateTextColor:
          Color.lerp(deliveredDateTextColor, other.deliveredDateTextColor, t),
      deliveredTextColor:
          Color.lerp(deliveredTextColor, other.deliveredTextColor, t),
      nameTextColor: Color.lerp(nameTextColor, other.nameTextColor, t),
      readDateTextColor:
          Color.lerp(readDateTextColor, other.readDateTextColor, t),
      readTextColor: Color.lerp(readTextColor, other.readTextColor, t),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
      backgroundHighLightColor: Color.lerp(
          backgroundHighLightColor, other.backgroundHighLightColor, t),
      messageReceiptStyle:
          messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
    );
  }
}
