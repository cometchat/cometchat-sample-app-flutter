import '../../../shared_ui/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

///[CometChatEmailFormatter] is a class which is used to style the email text
/// ```dart
/// CometChatEmailFormatter(
///    pattern: RegExp(RegexConstants.emailRegexPattern),
///    onSearch: (email) async {
///    await launchUrl(Uri.parse(('mailto:$email')));
///    },
///    messageBubbleTextStyle: (theme, alignment,{forConversation}) {
///    return TextStyle(
///    color: Colors.pink,
///    );
///    },
///    );
///    ```
class CometChatEmailFormatter extends CometChatTextFormatter {
  CometChatEmailFormatter({
    String? trackingCharacter,
    RegExp? pattern,
    super.showLoadingIndicator,
    super.onSearch,
    super.messageBubbleTextStyle,
    super.messageInputTextStyle,
    super.message,
    super.composerId,
    super.suggestionListEventSink,
    super.previousTextEventSink,
    super.user,
    super.group,
  }) : super(
          trackingCharacter: null,
          pattern: pattern ?? RegExp(RegexConstants.emailRegexPattern),
        ) {
    pattern ??= RegExp(RegexConstants.emailRegexPattern);
  }

  @override
  void init() {
    pattern ??= RegExp(RegexConstants.emailRegexPattern);
  }

  @override
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage) {}

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    if (messageInputTextStyle != null) {
      return messageInputTextStyle!(context);
    }
    CometChatTypography typography = CometChatThemeHelper.getTypography(context);
    return TextStyle(
      fontWeight: typography.body?.regular?.fontWeight,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
      decoration: TextDecoration.underline,
    );
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // No operation needed for email formatter
  }

  @override
  TextStyle getMessageBubbleTextStyle(
      BuildContext context, BubbleAlignment? alignment,
      {bool forConversation = false}) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(context, alignment,
          forConversation: forConversation);
    } else {
      CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(context);
      CometChatTypography typography = CometChatThemeHelper.getTypography(context);
      return TextStyle(
          color: alignment == BubbleAlignment.right
              ?colorPalette.white
              : colorPalette.neutral900,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          decoration: TextDecoration.underline);
    }
  }

  @override
  void onChange(
      TextEditingController textEditingController, String previousText) {
    // No operation needed for email formatter
  }

  @override
  List<AttributedText> getAttributedText(
      String text, BuildContext context, BubbleAlignment? alignment,
      {List<AttributedText>? existingAttributes,
      Function(String)? onTap,
      bool forConversation = false}) {
    return super.getAttributedText(text, context, alignment,
        existingAttributes: existingAttributes,
        onTap: onTap ??
            (text) async {
              if (pattern != null && pattern!.hasMatch(text)) {
                await launchUrl(Uri.parse(('mailto:$text')));
              }
            },
        forConversation: forConversation);
  }
}
