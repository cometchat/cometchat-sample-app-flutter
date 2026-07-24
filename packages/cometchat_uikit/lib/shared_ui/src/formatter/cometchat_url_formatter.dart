import '../../../shared_ui/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

///[CometChatUrlFormatter] is a class which is used to style the url text
/// ```dart
/// CometChatUrlFormatter(
///      pattern: RegExp(RegexConstants.urlRegexPattern),
///      onSearch: (url) async {
///      if (!RegExp(r'^(https?:\/\/)').hasMatch(url)) {
///      url = 'https://$url';
///      }
///      await launchUrl(Uri.parse(url));
///      },
///      messageBubbleTextStyle: (theme, alignment,{forConversation}) {
///      return TextStyle(
///      color: Colors.pink,
///      );
///      },
///      );
///      ```
class CometChatUrlFormatter extends CometChatTextFormatter {
  CometChatUrlFormatter({
    String? trackingCharacter,
    RegExp? pattern,
    super.showLoadingIndicator,
    super.onSearch,
    super.messageBubbleTextStyle,
    super.message,
    super.composerId,
    super.suggestionListEventSink,
    super.previousTextEventSink,
    super.user,
    super.group,
  }) : super(
         trackingCharacter: null,
         pattern: pattern ?? RegExp(RegexConstants.urlRegexPattern),
       ) {
    pattern ??= RegExp(RegexConstants.urlRegexPattern);
  }

  @override
  void init() {
    pattern ??= RegExp(RegexConstants.urlRegexPattern);
  }

  @override
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage) {
    // No operation needed for URL formatter
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    if (messageInputTextStyle != null) {
      return messageInputTextStyle!(context);
    }
    CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(
      context,
    );
    CometChatTypography typography = CometChatThemeHelper.getTypography(
      context,
    );
    return TextStyle(
      color: colorPalette.info,
      fontWeight: typography.body?.regular?.fontWeight,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
      decoration: TextDecoration.underline,
      decorationColor: colorPalette.info,
    );
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // No operation needed for URL formatter
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(
        context,
        alignment,
        forConversation: forConversation,
      );
    } else {
      CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(
        context,
      );
      CometChatTypography typography = CometChatThemeHelper.getTypography(
        context,
      );
      return TextStyle(
        color: alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.info,
        fontWeight: typography.body?.regular?.fontWeight,
        fontSize: typography.body?.regular?.fontSize,
        fontFamily: typography.body?.regular?.fontFamily,
        decoration: TextDecoration.underline,
        decorationColor: alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.info,
      );
    }
  }

  @override
  void onChange(
    TextEditingController textEditingController,
    String previousText,
  ) {
    // No operation needed for URL formatter
  }

  @override
  List<AttributedText> getAttributedText(
    String text,
    BuildContext context,
    BubbleAlignment? alignment, {
    List<AttributedText>? existingAttributes,
    Function(String)? onTap,
    bool forConversation = false,
  }) {
    return super.getAttributedText(
      text,
      context,
      alignment,
      existingAttributes: existingAttributes,
      onTap:
          onTap ??
          (text) async {
            if (pattern != null && pattern!.hasMatch(text)) {
              if (!RegExp(r'^(https?:\/\/)').hasMatch(text)) {
                text = 'https://$text';
              }
              await launchUrl(Uri.parse(text));
            }
          },
      forConversation: forConversation,
    );
  }
}
