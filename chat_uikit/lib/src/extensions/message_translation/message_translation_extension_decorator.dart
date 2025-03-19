import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[MessageExtensionTranslationDecorator] is a the view model for [MessageTranslationExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class MessageExtensionTranslationDecorator extends DataSourceDecorator {
  String messageTranslationTypeConstant = 'message-translation';
  String translateMessage = "translateMessage";
  MessageTranslationConfiguration? configuration;

  MessageExtensionTranslationDecorator(super.dataSource, {this.configuration});

  @override
  Widget getTextMessageContentView(TextMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return getContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  CometChatMessageOptionSheetStyle? _messageOptionStyle;

  @override
  List<CometChatMessageOption> getTextMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    List<CometChatMessageOption> textTemplateOptions =
        super.getTextMessageOptions(
      loggedInUser,
      messageObject,
      context,
      group,
      additionalConfigurations,
    );

    if (messageObject.metadata != null &&
        messageObject.metadata!.containsKey('translated_message') == false && additionalConfigurations?.hideTranslateMessageOption != true) {
      textTemplateOptions.add(getOption(context));
    }

    return textTemplateOptions;
  }

  @override
  String getId() {
    return "MessageTranslation";
  }

  CometChatMessageOption getOption(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    return CometChatMessageOption(
      id: translateMessage,
      title: configuration?.optionTitle ??
          Translations.of(context).translateMessage,
      icon: configuration?.optionIcon ??
          Image.asset(
            AssetConstants.translate,
            package: UIConstants.packageName,
            color: _messageOptionStyle?.iconColor ?? colorPalette.iconSecondary,
            height: 24,
            width: 24,
          ),
      messageOptionSheetStyle: CometChatMessageOptionSheetStyle(
        iconColor: _messageOptionStyle?.iconColor ?? colorPalette.iconSecondary,
        titleTextStyle: TextStyle(
          color: _messageOptionStyle?.titleColor,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
        ).merge(_messageOptionStyle?.titleTextStyle),
        borderRadius: _messageOptionStyle?.borderRadius,
        border: _messageOptionStyle?.border,
        backgroundColor: _messageOptionStyle?.backgroundColor,
        titleColor: _messageOptionStyle?.titleColor,
      ),
      onItemClick: (BaseMessage message,
          CometChatMessageListControllerProtocol state) async {
        if (state is CometChatMessageListController) {
          _translateMessage(message, context, state);
        }
      },
    );
  }

  _translateMessage(BaseMessage message, BuildContext context,
      CometChatMessageListController state) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    if (message is TextMessage) {
      CometChat.callExtension(
          messageTranslationTypeConstant, 'POST', ExtensionUrls.translate, {
        "msgId": message.id,
        "text": message.text,
        "languages": [Localizations.localeOf(context).languageCode]
      }, onSuccess: (Map<String, dynamic> res) {
        Map<String, dynamic>? data = res["data"];
        if (data != null && data.containsKey('translations')) {
          String? translatedMessage =
              data['translations']?[0]?['message_translated'];

          if (translatedMessage != null &&
              translatedMessage.isNotEmpty &&
              translatedMessage != message.text) {
            Map<String, dynamic> metadata =
                message.metadata ?? <String, dynamic>{};
            metadata.addAll({'translated_message': translatedMessage});
            message.metadata = metadata;
            state.updateElement(message);
          } else {
            _showDialogPopUp(
                "Selected language for translation is similar to the language of original message",
                colorPalette,
                context, typography,);
          }
        }
      }, onError: (CometChatException e) {
        String error = getErrorTranslatedText(context, e.code);
        _showDialogPopUp(error, colorPalette, context, typography);
      });
    }
  }

  Widget getContentView(TextMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {

    Widget? child = super.getTextMessageContentView(
        message, context, alignment,
        additionalConfigurations: additionalConfigurations
    );
    if (message.metadata != null &&
        message.metadata!.containsKey('translated_message')) {
      String? translatedText = message.metadata?['translated_message'];
      if (message.mentionedUsers.isNotEmpty &&
          translatedText != null &&
          translatedText.isNotEmpty) {
        translatedText = CometChatMentionsFormatter.getTextWithMentions(
            translatedText, message.mentionedUsers);
      }

      return MessageTranslationBubble(
        translatedText: translatedText ?? "",
        alignment: alignment,
        style: configuration?.style ?? additionalConfigurations?.messageTranslationBubbleStyle,
        child: child,
      );
    } else {
      return child;
    }
  }

  String getErrorTranslatedText(BuildContext context, String errorCode) {
    if (errorCode == "ERROR_INTERNET_UNAVAILABLE") {
      return Translations.of(context).errorInternetUnavailable;
    } else {}

    return Translations.of(context).somethingWentWrongError;
  }

  _showDialogPopUp(String message, CometChatColorPalette colorPalette, BuildContext context, CometChatTypography typography) {
    CometChatConfirmDialog(
      showIcon: false,
        context: context,
        title: const Text(""),
        iconPadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(0),
        messageText: Text(
          message,
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.heading2?.regular?.fontSize,
            fontWeight: typography.heading2?.regular?.fontWeight,
            fontFamily: typography.heading2?.regular?.fontFamily,
          ),
        ),
        style: CometChatConfirmDialogStyle(
            backgroundColor: colorPalette.background1,
            confirmButtonTextStyle: TextStyle(
              color: colorPalette.textPrimary,
              fontSize: typography.button?.medium?.fontSize,
              fontWeight: typography.button?.medium?.fontWeight,
              fontFamily: typography.button?.medium?.fontFamily,
            )),
        confirmButtonText: Translations.of(context).okay,
        onConfirm: () {
          Navigator.pop(context);
        }).show();
  }
}
