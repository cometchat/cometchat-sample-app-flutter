import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[AdditionalConfigurations] is a class that can be used to add additional configurations to the UI Kit
/// ```dart
/// AdditionalConfigurations(
///    textFormatters: [
///    CometChatPhoneNumberFormatter(
///    pattern: RegExp(RegexConstants.phoneNumberRegexPattern),
///    onSearch: (phoneNumber) async {
///    await launchUrl(Uri.parse(('tel:$phoneNumber')));
///    },
///    messageBubbleTextStyle: (theme, alignment,{forConversation}) {
///    return TextStyle(
///    color: Colors.pink,
///    );
///    },
///    ),
///    CometChatEmailFormatter(
///    pattern: RegExp(RegexConstants.emailRegexPattern),
///    onSearch: (email) async {
///    await launchUrl(Uri.parse(('mailto:$email')));
///    },
///    messageBubbleTextStyle: (theme, alignment,{forConversation}) {
///    return TextStyle(
///    color: Colors.red,
///    );
///    },
///    ),
///    ],
///    );
///    ```
class AdditionalConfigurations {
  AdditionalConfigurations({
    this.textFormatters,
    this.textBubbleStyle,
    this.imageBubbleStyle,
    this.videoBubbleStyle,
    this.audioBubbleStyle,
    this.fileBubbleStyle,
    this.attachmentOptionSheetStyle,
    this.messageOptionSheetStyle,
    this.collaborativeDocumentBubbleStyle,
    this.collaborativeWhiteboardBubbleStyle,
    this.pollsBubbleStyle,
    this.actionBubbleStyle,
    this.deletedBubbleStyle,
    this.messageTranslationBubbleStyle,
    this.linkPreviewBubbleStyle,
    this.stickerBubbleStyle,
    this.voiceCallBubbleStyle,
    this.videoCallBubbleStyle,
    this.callButtonsStyle,
    this.hideVideoCallButton,
    this.hideVoiceCallButton,
    this.hideImageAttachmentOption,
    this.hideVideoAttachmentOption,
    this.hideAudioAttachmentOption,
    this.hideFileAttachmentOption,
    this.hidePollsOption,
    this.hideCollaborativeDocumentOption,
    this.hideCollaborativeWhiteboardOption,
    this.hideStickersButton,
    this.hideTakPhotoOption,
    this.hideCopyMessageOption,
    this.hideDeleteMessageOption,
    this.hideEditMessageOption,
    this.hideReactionOption,
    this.hideMessagePrivatelyOption,
    this.hideMessageInfoOption,
    this.hideTranslateMessageOption,
    this.hideReplyInThreadOption,
    this.hideShareMessageOption,
  });


  ///[textFormatters] is a list of [CometChatTextFormatter] that can be used to format text
  final List<CometChatTextFormatter>? textFormatters;

  ///[textBubbleStyle] is a [CometChatTextBubbleStyle] that can be used to style text bubble
  final CometChatTextBubbleStyle? textBubbleStyle;

  ///[imageBubbleStyle] is a [CometChatImageBubbleStyle] that can be used to style image bubble
  final CometChatImageBubbleStyle? imageBubbleStyle;

  ///[videoBubbleStyle] is a [CometChatVideoBubbleStyle] that can be used to style video bubble
  final CometChatVideoBubbleStyle? videoBubbleStyle;

  ///[audioBubbleStyle] is a [CometChatAudioBubbleStyle] that can be used to style audio bubble
  final CometChatAudioBubbleStyle? audioBubbleStyle;

  ///[fileBubbleStyle] is a [CometChatFileBubbleStyle] that can be used to style file bubble
  final CometChatFileBubbleStyle? fileBubbleStyle;

  ///[attachmentOptionSheetStyle] is a [CometChatAttachmentOptionSheetStyle] that can be used to style attachment option sheet
  final CometChatAttachmentOptionSheetStyle? attachmentOptionSheetStyle;

  ///[messageOptionSheetStyle] is a [CometChatMessageOptionSheetStyle] that can be used to style message option sheet
  final CometChatMessageOptionSheetStyle? messageOptionSheetStyle;

  ///[collaborativeDocumentBubbleStyle] provides style to the collaborative document bubble of the sent message
  final CometChatCollaborativeBubbleStyle? collaborativeDocumentBubbleStyle;

  ///[collaborativeWhiteboardBubbleStyle] provides style to the collaborative whiteboard bubble of the sent message
  final CometChatCollaborativeBubbleStyle? collaborativeWhiteboardBubbleStyle;

  ///[pollsBubbleStyle] is a [CometChatPollsBubbleStyle] that can be used to style polls bubble
  final CometChatPollsBubbleStyle? pollsBubbleStyle;

  ///[actionBubbleStyle] is a [CometChatActionBubbleStyle] that can be used to style action bubble
  final CometChatActionBubbleStyle? actionBubbleStyle;

  ///[deletedBubbleStyle] is a [CometChatDeletedBubbleStyle] that can be used to style deleted bubble
  final CometChatDeletedBubbleStyle? deletedBubbleStyle;

  ///[messageTranslationBubbleStyle] is a [CometChatMessageTranslationBubbleStyle] that can be used to style message translation bubble
  final CometChatMessageTranslationBubbleStyle? messageTranslationBubbleStyle;

  ///[linkPreviewBubbleStyle] is a [CometChatLinkPreviewBubbleStyle] that can be used to style link preview bubble
  final CometChatLinkPreviewBubbleStyle? linkPreviewBubbleStyle;

  ///[stickerBubbleStyle] is a [CometChatStickerBubbleStyle] that can be used to style sticker bubble
  final CometChatStickerBubbleStyle? stickerBubbleStyle;

  ///[voiceCallBubbleStyle] is a [CometChatCallBubbleStyle] that can be used to style voice call bubble
  final CometChatCallBubbleStyle? voiceCallBubbleStyle;

  ///[videoCallBubbleStyle] is a [CometChatCallBubbleStyle] that can be used to style video call bubble
  final CometChatCallBubbleStyle? videoCallBubbleStyle;

  ///[callButtonsStyle] is a [CometChatCallButtonsStyle] that can be used to style call buttons
  final CometChatCallButtonsStyle? callButtonsStyle;

  ///[hideVideoCallButton] is a [bool] that can be used to hide/display video call button
  final bool? hideVideoCallButton;

  ///[hideVoiceCallButton] is a [bool] that can be used to hide/display voice call button
  final bool? hideVoiceCallButton;

  ///[hideImageAttachmentOption] is a [bool] that can be used to hide/display image attachment option
  final bool? hideImageAttachmentOption;

  ///[hideVideoAttachmentOption] is a [bool] that can be used to hide/display video attachment option
  final bool? hideVideoAttachmentOption;

  ///[hideAudioAttachmentOption] is a [bool] that can be used to hide/display audio attachment option
  final bool? hideAudioAttachmentOption;

  ///[hideFileAttachmentOption] is a [bool] that can be used to hide/display file attachment option
  final bool? hideFileAttachmentOption;

  ///[hidePollsOption] is a [bool] that can be used to hide/display poll option
  final bool? hidePollsOption;

  ///[hideCollaborativeDocumentOption] is a [bool] that can be used to hide/display collaborative document option
  final bool? hideCollaborativeDocumentOption;

  ///[hideCollaborativeWhiteboardOption] is a [bool] that can be used to hide/display collaborative whiteboard option
  final bool? hideCollaborativeWhiteboardOption;

  ///[hideStickersButton] is a [bool] that can be used to hide/display sticker button
  final bool? hideStickersButton;

  ///[hideTakPhotoOption] is a [bool] that can be used to hide/display take photo option
  final bool? hideTakPhotoOption;

  ///[hideReplyInThreadOption] This prop defines whether Reply In Thread option should be visible or not.
  final bool? hideReplyInThreadOption;

  ///[hideTranslateMessageOption] This prop defines whether Reply In Thread option should be visible or not.
  final bool? hideTranslateMessageOption;

  ///[hideEditMessageOption] This prop defines whether Edit Message option should be visible or not.
  final bool? hideEditMessageOption;

  ///[hideDeleteMessageOption] This prop defines whether Delete Message option should be visible or not.
  final bool? hideDeleteMessageOption;

  ///[hideReactionOption] This prop defines whether Reaction option should be visible or not.
  final bool? hideReactionOption;

  ///[hideMessagePrivatelyOption] This prop defines whether a user can privately message other member of the group or not.
  final bool? hideMessagePrivatelyOption;

  ///[hideCopyMessageOption] This prop defines whether a user can copy message or not.
  final bool? hideCopyMessageOption;

  ///[hideMessageInfoOption] This prop defines whether a user can fetch information about the message whether it's received or not.
  final bool? hideMessageInfoOption;

  ///[hideShareMessageOption] This prop defines whether share option should be visible or not.
  final bool? hideShareMessageOption;
}
