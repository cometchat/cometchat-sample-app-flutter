import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

///[MessageTranslationConfiguration] is a data class that has configuration properties
///to customize the functionality and appearance of [MessageTranslationExtension]
///
/// ```dart
/// MessageTranslationConfiguration translationConfig = MessageTranslationConfiguration(
///     optionTitle: 'Translate',
///     optionIconUrl: 'https://example.com/translate-icon.png',
///     style: MessageTranslationBubbleStyle(
///         infoTextStyle: TextStyle(
///             color: Colors.black,
///             fontSize: 14,
///         ),
///     ),
///     optionStyle: MessageTranslationOptionStyle(
///         titleStyle: TextStyle(
///             color: Colors.black,
///             fontSize: 16,
///         ),
///         iconTint: Colors.blue,
///     ),
///     theme: CometChatTheme(palette: Palette(),typography: Typography()),
/// );
///
/// ```
class MessageTranslationConfiguration {
  MessageTranslationConfiguration({
    this.optionTitle,
    this.optionIcon,
    this.optionStyle,
    this.style,
  });

  ///[style] provides style
  final CometChatMessageTranslationBubbleStyle? style;

  ///[optionTitle] is the name for the option for this extension
  final String? optionTitle;

  ///[optionIcon] is the path to the icon image for the option for this extension
  final Widget? optionIcon;

  ///[optionStyle] provides style to the option
  final MessageTranslationOptionStyle? optionStyle;
}
