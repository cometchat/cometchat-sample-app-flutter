import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';

///
/// [CometChatMessageComposer] component allows users to
/// send messages and attachments to the chat, participating in the conversation.
///
/// ```dart
///  CometChatMessageComposer(
///        user: User(uid: 'uid', name: 'name'),
///        group: Group(guid: 'guid', name: 'name', type: 'public'),
///        messageComposerStyle: MessageComposerStyle(),
///        stateCallBack: (CometChatMessageComposerController state) {},
///        customSoundForMessage: 'asset url',
///        disableSoundForMessages: true,
///        placeholderText: 'Message',
///      );
///
/// ```
///
///
///
class CometChatMessageComposer extends StatefulWidget {
  const CometChatMessageComposer({
    super.key,
    this.user,
    this.group,
    this.messageComposerStyle,
    this.placeholderText,
    this.disableTypingEvents = false,
    this.disableSoundForMessages = false,
    this.parentMessageId = 0,
    this.customSoundForMessage,
    this.customSoundForMessagePackage,
    this.auxiliaryButtonView,
    this.headerView,
    this.footerView,
    this.secondaryButtonView,
    this.sendButtonView,
    this.attachmentOptions,
    this.text,
    this.onChange,
    this.maxLine,
    this.auxiliaryButtonsAlignment,
    this.attachmentIconURL,
    this.stateCallBack,
    this.attachmentIcon,
    this.onError,
    this.onSendButtonTap,
    this.hideVoiceRecordingButton,
    this.voiceRecordingIcon,
    this.aiIcon,
    this.aiIconURL,
    this.aiIconPackageName,
    this.textFormatters,
    this.disableMentions,
    this.textEditingController,
    this.padding,
    this.messageInputPadding,
    this.recorderStartButtonIcon,
    this.recorderPauseButtonIcon,
    this.recorderDeleteButtonIcon,
    this.recorderStopButtonIcon,
    this.recorderSendButtonIcon,
    this.hideSendButton,
    this.hideAttachmentButton,
    this.hideStickersButton,
    this.hideAudioAttachmentOption,
    this.hideFileAttachmentOption,
    this.hideImageAttachmentOption,
    this.hideVideoAttachmentOption,
    this.hidePollsOption,
    this.hideCollaborativeDocumentOption,
    this.hideCollaborativeWhiteboardOption,
    this.hideTakePhotoOption,
    this.sendButtonIcon,
  })  : assert(
          user != null || group != null,
          "One of user or group should be passed",
        ),
        assert(
          user == null || group == null,
          "Only one of user or group should be passed",
        );

  ///sets [user] for message composer
  final User? user;

  ///set [group] for message composer
  final Group? group;

  ///[messageComposerStyle] message composer style
  final CometChatMessageComposerStyle? messageComposerStyle;

  ///[auxiliaryButtonView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? auxiliaryButtonView;

  ///[secondaryButtonView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? secondaryButtonView;

  ///[sendButtonView] ui component to be forwarded to message input component
  final Widget? sendButtonView;

  ///[text] initial text for the input field
  final String? text;

  ///[placeholderText] hint text for input field
  final String? placeholderText;

  ///[onChange] callback to handle change in value of text in the input field
  final Function(String text)? onChange;

  ///[maxLine] maximum lines allowed to increase in the input field
  final int? maxLine;

  ///[auxiliaryButtonsAlignment] controls position auxiliary button view
  final AuxiliaryButtonsAlignment? auxiliaryButtonsAlignment;

  ///[attachmentIconURL] path of the icon to show in the attachments button
  final String? attachmentIconURL;

  ///[attachmentIcon] custom attachment icon
  final Widget? attachmentIcon;

  ///[hideVoiceRecordingButton] provides option to hide voice recording button
  final bool? hideVoiceRecordingButton;

  ///[voiceRecordingIcon] provides icon to the voice recording Icon/widget
  final Widget? voiceRecordingIcon;

  final int parentMessageId;

  ///[attachmentIcon] custom ai icon
  final Widget? aiIcon;

  ///[aiIconURL] path of the icon to show in the ai button
  final String? aiIconURL;

  ///[aiIconPackageName] package name to show icon from
  final String? aiIconPackageName;

  ///[disableMentions] disables mentions in the composer
  final bool? disableMentions;

  ///[textEditingController] controls the state of the text field
  final TextEditingController? textEditingController;

  ///[padding] provides padding to the message composer
  final EdgeInsetsGeometry? padding;

  ///[messageInputPadding] sets the padding to the message input field
  final EdgeInsetsGeometry? messageInputPadding;

  ///[customSoundForMessage] provides custom sound for message sent
  final String? customSoundForMessage;

  ///[customSoundForMessagePackage] package name to show icon from
  final String? customSoundForMessagePackage;

  ///[disableSoundForMessages] disables sound for message sent
  final bool disableSoundForMessages;

  ///[disableTypingEvents] disables typing events
  final bool disableTypingEvents;

  ///[headerView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? headerView;

  ///[footerView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? footerView;

  ///[attachmentOptions] provides options to attach files
  final ComposerActionsBuilder? attachmentOptions;

  ///[stateCallBack] callback to handle state of the message composer
  final void Function(CometChatMessageComposerController controller)?
      stateCallBack;

  ///[onError] callback to handle error
  final OnError? onError;

  ///[onSendButtonTap] callback to handle send button tap
  final Function(
    BuildContext context,
    BaseMessage message,
    PreviewMessageMode? prviewMessageMode,
  )? onSendButtonTap;

  ///[textFormatters] provides list of text formatters
  final List<CometChatTextFormatter>? textFormatters;

  ///[recorderStartButtonIcon] defines the icon of the start button.
  final Widget? recorderStartButtonIcon;

  ///[recorderPauseButtonIcon] defines the icon of the pause button.
  final Widget? recorderPauseButtonIcon;

  ///[recorderDeleteButtonIcon] defines the icon of the delete button.
  final Widget? recorderDeleteButtonIcon;

  ///[recorderStopButtonIcon] defines the icon of the stop button.
  final Widget? recorderStopButtonIcon;

  ///[recorderSendButtonIcon] defines the icon of the send button.
  final Widget? recorderSendButtonIcon;

  ///[hideSendButton] is a [bool] that can be used to hide/display send button
  final bool? hideSendButton;

  ///[hideAttachmentButton] is a [bool] that can be used to hide/display attachment button
  final bool? hideAttachmentButton;

  ///[hideStickersButton] is a [bool] that can be used to hide/display sticker button
  final bool? hideStickersButton;

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

  ///[hideTakePhotoOption] is a [bool] that can be used to hide/display take photo option
  final bool? hideTakePhotoOption;

  ///[sendButtonIcon] custom send button icon
  final Widget? sendButtonIcon;

  @override
  State<CometChatMessageComposer> createState() =>
      _CometChatMessageComposerState();
}

class _CometChatMessageComposerState extends State<CometChatMessageComposer> {
  ///[cometChatMessageComposerController] contains the business logic
  late CometChatMessageComposerController cometChatMessageComposerController;
  late Map<String, dynamic> composerId = {};

  late CometChatMessageComposerStyle style;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  late CometChatSuggestionListStyle suggestionListStyle;
  late AIOptionsStyle? aiOptionStyle;
  late List<CometChatMessageComposerAction> elementList;

  @override
  void didChangeDependencies() {
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatMessageComposerStyle>(
      context: context,
      defaultTheme: CometChatMessageComposerStyle.of,
    ).merge(widget.messageComposerStyle);

    suggestionListStyle =
        CometChatThemeHelper.getTheme<CometChatSuggestionListStyle>(
      context: context,
      defaultTheme: CometChatSuggestionListStyle.of,
    ).merge(style.suggestionListStyle);

    aiOptionStyle = CometChatThemeHelper.getTheme<AIOptionsStyle>(
      context: context,
      defaultTheme: AIOptionsStyle.of,
    ).merge(style.aiOptionStyle);

    elementList = CometChatUIKit.getDataSource().getAIOptions(
      widget.user,
      widget.group,
      context,
      composerId,
      aiOptionStyle,
    );

    cometChatMessageComposerController = CometChatMessageComposerController(
      parentMessageId: widget.parentMessageId,
      disableSoundForMessages: widget.disableSoundForMessages,
      customSoundForMessage: widget.customSoundForMessage,
      customSoundForMessagePackage: widget.customSoundForMessagePackage,
      group: widget.group,
      user: widget.user,
      text: widget.text,
      disableTypingEvents: widget.disableTypingEvents,
      attachmentOptions: widget.attachmentOptions,
      stateCallBack: widget.stateCallBack,
      footerView: widget.footerView,
      headerView: widget.headerView,
      onSendButtonTap: widget.onSendButtonTap,
      onError: widget.onError,
      aiOptionStyle: aiOptionStyle,
      textFormatters: widget.textFormatters,
      textEditingController: widget.textEditingController,
      mentionsStyle: style.mentionsStyle,
      style: widget.messageComposerStyle,
      context: context,
      colorPalette: colorPalette,
      spacing: spacing,
      typography: typography,
      suggestionListStyle: suggestionListStyle,
      auxiliaryButtonIconColor: style.auxiliaryButtonIconColor,
      hideStickersButton: widget.hideStickersButton,
      hideAudioAttachmentOption: widget.hideAudioAttachmentOption,
      hideFileAttachmentOption: widget.hideFileAttachmentOption,
      hideImageAttachmentOption: widget.hideImageAttachmentOption,
      hideVideoAttachmentOption: widget.hideVideoAttachmentOption,
      hidePollsOption: widget.hidePollsOption,
      hideCollaborativeDocumentOption: widget.hideCollaborativeDocumentOption,
      hideCollaborativeWhiteboardOption:
          widget.hideCollaborativeWhiteboardOption,
      hideTakePhotoOption: widget.hideTakePhotoOption,
      disableMentions: widget.disableMentions,
    );

    super.didChangeDependencies();
  }

  Widget _getSendButton(
    CometChatMessageComposerController value,
    CometChatMessageComposerStyle messageComposerStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    if (widget.hideSendButton == true) {
      return const SizedBox();
    }
    if (widget.sendButtonView != null) {
      return GestureDetector(
        onTap: value.onSendButtonClick,
        child: widget.sendButtonView,
      );
    } else {
      final isTextControllerEmpty = value.textEditingController != null &&
          value.textEditingController!.text.trim().isEmpty;

      final isSameAsOldMessage = value.oldMessage is TextMessage &&
          value.textEditingController!.text ==
              (value.oldMessage as TextMessage).text;

      final isEditModeWithoutChanges =
          value.previewMessageMode == PreviewMessageMode.edit &&
              !value.hasMeaningfulChange(
                (value.oldMessage as TextMessage).text,
                value.textEditingController!.text,
              );

      final shouldUseBackgroundColor =
          isTextControllerEmpty || isSameAsOldMessage || isEditModeWithoutChanges;

      return Container(
        decoration: BoxDecoration(
            color: messageComposerStyle.sendButtonIconBackgroundColor ??
                (shouldUseBackgroundColor
                    ? colorPalette.background4
                    : colorPalette.primary),
          borderRadius: messageComposerStyle.sendButtonBorderRadius ??
              BorderRadius.circular(spacing.radiusMax ?? 0),
        ),
        alignment: Alignment.center,
        height: 32,
        width: 32,
        child: widget.sendButtonView ??
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: widget.sendButtonIcon ??
                  Image.asset(
                    AssetConstants.send,
                    package: UIConstants.packageName,
                    height: 24,
                    width: 24,
                    color: messageComposerStyle.sendButtonIconColor,
                  ),
              onPressed: value.onSendButtonClick,
            ),
      );
    }
  }

  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    if (widget.group != null) {
      composerId['guid'] = widget.group!.guid;
    } else if (widget.user != null) {
      composerId['uid'] = widget.user!.uid;
    }

    return PopScope(
      canPop: true,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: widget.padding,
              child: GetBuilder(
                init: cometChatMessageComposerController,
                tag: cometChatMessageComposerController.tag,
                dispose: (
                  GetBuilderState<CometChatMessageComposerController> state,
                ) =>
                    Get.delete<CometChatMessageComposerController>(
                  tag: state.controller?.tag,
                ),
                builder: (CometChatMessageComposerController value) {
                  return Column(
                    children: [
                      //-----message preview container-----
                      //-----
                      Container(
                        child: Column(
                          children: [
                            if (value.header != null) value.header!,
                            if (value.messagePreviewTitle != null &&
                                    value.messagePreviewTitle!.isNotEmpty ||
                                value.preview != null)
                              CompositedTransformTarget(
                                link: _link,
                                child: OverlayPortal(
                                  controller: value.overlayPortalController,
                                  overlayChildBuilder: (context) {
                                    return CompositedTransformFollower(
                                      link: _link,
                                      targetAnchor: Alignment.bottomLeft,
                                      followerAnchor: Alignment.bottomLeft,
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (value.messagePreviewTitle !=
                                                    null &&
                                                value.messagePreviewTitle!
                                                    .isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: spacing.padding2 ?? 0,
                                                  right: spacing.padding2 ?? 0,
                                                  bottom: (value.preview != null
                                                      ? 8
                                                      : 0),
                                                ),
                                                child: CometChatMessagePreview(
                                                  messagePreviewTitle: value
                                                      .messagePreviewTitle!,
                                                  messagePreviewSubtitle: value
                                                          .messagePreviewSubtitle ??
                                                      '',
                                                  onCloseClick: value
                                                      .onMessagePreviewClose,
                                                  style:
                                                      CometChatMessagePreviewStyle(
                                                    messagePreviewTitleStyle:
                                                        TextStyle(
                                                      color: colorPalette
                                                          .textPrimary,
                                                      fontSize: typography.body
                                                          ?.regular?.fontSize,
                                                      fontWeight: typography
                                                          .body
                                                          ?.regular
                                                          ?.fontWeight,
                                                      fontFamily: typography
                                                          .body
                                                          ?.regular
                                                          ?.fontFamily,
                                                    ),
                                                    messagePreviewSubtitleStyle:
                                                        TextStyle(
                                                      color: colorPalette
                                                          .textSecondary,
                                                      fontSize: typography
                                                          .caption1
                                                          ?.regular
                                                          ?.fontSize,
                                                      fontWeight: typography
                                                          .caption1
                                                          ?.regular
                                                          ?.fontWeight,
                                                      fontFamily: typography
                                                          .caption1
                                                          ?.regular
                                                          ?.fontFamily,
                                                    ),
                                                    closeIconColor:
                                                        style.closeIconTint ??
                                                            colorPalette
                                                                .iconPrimary,
                                                    messagePreviewBackground:
                                                        colorPalette
                                                            .background3,
                                                  ),
                                                ),
                                              ),
                                            if (value.preview != null)
                                              value.preview!,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      Container(), // Placeholder child, can be empty or other widget
                                ),
                              ),
                            Padding(
                              padding: widget.messageInputPadding ??
                                  EdgeInsets.fromLTRB(
                                    spacing.padding2 ?? 0,
                                    0,
                                    spacing.padding2 ?? 0,
                                    spacing.padding2 ?? 0,
                                  ),
                              child: CometChatMessageInput(
                                text: widget.text,
                                textEditingController:
                                    value.textEditingController,
                                placeholderText: widget.placeholderText,
                                maxLine: widget.maxLine,
                                onChange: (val) {
                                  if (widget.onChange != null) {
                                    widget.onChange!(val);
                                  }
                                  value.onChange(value);
                                },
                                primaryButtonView: _getSendButton(
                                  value,
                                  style,
                                  colorPalette,
                                  spacing,
                                ),
                                secondaryButtonView: widget
                                            .secondaryButtonView !=
                                        null
                                    ? widget.secondaryButtonView!(
                                        context,
                                        value.user,
                                        value.group,
                                        value.composerId,
                                      )
                                    : DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: style
                                              .secondaryButtonIconBackgroundColor,
                                          borderRadius:
                                              style.secondaryButtonBorderRadius,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (widget.hideAttachmentButton !=
                                                true)
                                              Container(
                                                height: 24,
                                                width: 24,
                                                margin: EdgeInsets.only(
                                                  right: spacing.margin4 ?? 0,
                                                ),
                                                child: IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: widget.attachmentIcon ??
                                                      Image.asset(
                                                        widget.attachmentIconURL ??
                                                            AssetConstants.add,
                                                        package: UIConstants
                                                            .packageName,
                                                        color: style
                                                                .secondaryButtonIconColor ??
                                                            colorPalette
                                                                .iconSecondary,
                                                      ),
                                                  onPressed: () async {
                                                    value.showBottomActionSheet(
                                                      context,
                                                      colorPalette,
                                                      typography,
                                                    );
                                                  },
                                                ),
                                              ),
                                            //-----show voice recording-----
                                            if (widget
                                                    .hideVoiceRecordingButton !=
                                                true)
                                              Container(
                                                height: 24,
                                                width: 24,
                                                margin: EdgeInsets.only(
                                                  right: spacing.margin4 ?? 0,
                                                ),
                                                child: IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: widget
                                                          .voiceRecordingIcon ??
                                                      Image.asset(
                                                        AssetConstants
                                                            .microphone,
                                                        package: UIConstants
                                                            .packageName,
                                                        color: style
                                                                .secondaryButtonIconColor ??
                                                            colorPalette
                                                                .iconSecondary,
                                                        // height: 24,
                                                        // width: 24,
                                                      ),
                                                  onPressed: () {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    showModalBottomSheet<void>(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (
                                                        BuildContext context,
                                                      ) {
                                                        return CometChatMediaRecorder(
                                                          startButtonIcon: widget
                                                              .recorderStartButtonIcon,
                                                          pauseButtonIcon: widget
                                                              .recorderPauseButtonIcon,
                                                          stopButtonIcon: widget
                                                              .recorderStopButtonIcon,
                                                          deleteButtonIcon: widget
                                                              .recorderDeleteButtonIcon,
                                                          sendButtonIcon: widget
                                                              .recorderSendButtonIcon,
                                                          style: style
                                                              .mediaRecorderStyle,
                                                          onSubmit: value
                                                              .sendMediaRecording,
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                auxiliaryButtonsAlignment:
                                    widget.auxiliaryButtonsAlignment ??
                                        AuxiliaryButtonsAlignment.left,
                                auxiliaryButtonView: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: style
                                        .auxiliaryButtonIconBackgroundColor,
                                    borderRadius:
                                        style.auxiliaryButtonBorderRadius,
                                  ),
                                  child: widget.auxiliaryButtonView != null
                                      ? widget.auxiliaryButtonView!(
                                          context,
                                          value.user,
                                          value.group,
                                          value.composerId,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            //-----show emoji keyboard-----

                                            if (value.auxiliaryOptions != null)
                                              value.auxiliaryOptions!,

                                            if (value.parentMessageId == 0 &&
                                                elementList.isNotEmpty)
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: widget.aiIcon ??
                                                      Image.asset(
                                                        widget.aiIconURL ??
                                                            (value.activeAiFeatures
                                                                ? AssetConstants
                                                                    .aiActive
                                                                : AssetConstants
                                                                    .aiInactive),
                                                        package: widget
                                                                .aiIconPackageName ??
                                                            UIConstants
                                                                .packageName,
                                                        color: style
                                                                .auxiliaryButtonIconColor ??
                                                            (value.activeAiFeatures
                                                                ? colorPalette
                                                                    .iconHighlight
                                                                : colorPalette
                                                                    .iconSecondary),
                                                      ),
                                                  onPressed: () {
                                                    value.aiButtonTap(
                                                      context,
                                                      value.composerId,
                                                      style.aiOptionSheetStyle,
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                                style: CometChatMessageInputStyle(
                                  filledColor: style.filledColor,
                                  dividerTint: style.dividerColor ??
                                      colorPalette.borderLight,
                                  dividerHeight: style.dividerHeight,
                                  backgroundColor: style.backgroundColor ??
                                      colorPalette.background1,
                                  textStyle: TextStyle(
                                    color: colorPalette.textPrimary,
                                    fontSize:
                                        typography.body?.regular?.fontSize,
                                    fontWeight:
                                        typography.body?.regular?.fontWeight,
                                    fontFamily:
                                        typography.body?.regular?.fontFamily,
                                  )
                                      .merge(style.textStyle)
                                      .copyWith(color: style.textColor),
                                  placeholderTextStyle: TextStyle(
                                    color: colorPalette.textTertiary,
                                    fontSize:
                                        typography.body?.regular?.fontSize,
                                    fontWeight:
                                        typography.body?.regular?.fontWeight,
                                    fontFamily:
                                        typography.body?.regular?.fontFamily,
                                  ).merge(style.placeHolderTextStyle).copyWith(
                                        color: style.placeHolderTextColor,
                                      ),
                                  border: style.border ??
                                      Border.all(
                                        color: colorPalette.borderDefault ??
                                            Colors.transparent,
                                        width: 1,
                                      ),
                                  borderRadius: style.borderRadius ??
                                      BorderRadius.circular(
                                        spacing.radius2 ?? 0,
                                      ),
                                ),
                                focusNode: value.focusNode,
                              ),
                            ),
                            if (value.footer != null) value.footer!,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
