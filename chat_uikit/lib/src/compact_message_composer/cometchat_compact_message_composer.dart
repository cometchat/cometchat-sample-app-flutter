import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as shared;
import 'package:get/get.dart';

/// [CometChatCompactMessageComposer] is a compact message composer component
/// that provides a streamlined messaging experience with a rounded pill-shaped
/// input field, inline rich text formatting toolbar, and support for attachments,
/// voice recording, mentions, and auxiliary actions.
///
/// The component is designed for a modern, minimal aesthetic while maintaining
/// full messaging functionality.
///
/// ```dart
/// CometChatCompactMessageComposer(
///   user: User(uid: 'uid', name: 'name'),
///   compactMessageComposerStyle: CometChatCompactMessageComposerStyle(),
///   placeholderText: 'Type a message...',
///   enableRichTextFormatting: true,
///   enterKeyBehavior: EnterKeyBehavior.sendMessage,
/// );
/// ```
///
/// _Requirements: 1.1_
class CometChatCompactMessageComposer extends StatefulWidget {
  const CometChatCompactMessageComposer({
    super.key,
    // Target configuration
    this.user,
    this.group,
    // Style configuration
    this.compactMessageComposerStyle,
    // Rich text configuration
    this.enableRichTextFormatting = true,
    this.showRichTextFormattingOptions = true,
    this.showTextSelectionMenuItems = true,
    this.hideRichTextFormattingOptions,
    this.richTextToolbarStyle,
    // Input configuration
    this.placeholderText,
    this.maxLine = 4,
    this.text,
    this.textEditingController,
    // Enter key behavior
    this.enterKeyBehavior = EnterKeyBehavior.newLine,
    // Button visibility
    this.hideAttachmentButton = false,
    this.hideVoiceRecordingButton = false,
    this.hideSendButton = false,
    // Attachment option visibility
    this.hideImageAttachmentOption = false,
    this.hideVideoAttachmentOption = false,
    this.hideAudioAttachmentOption = false,
    this.hideFileAttachmentOption = false,
    this.hidePollsOption = false,
    this.hideCollaborativeDocumentOption = false,
    this.hideCollaborativeWhiteboardOption = false,
    this.hideTakePhotoOption = false,
    this.hideStickersButton = false,
    // Mention configuration
    this.disableMentions = false,
    this.disableMentionAll = false,
    this.mentionAllLabel,
    this.mentionAllLabelId,
    // Typing events
    this.disableTypingEvents = false,
    // Sound configuration
    this.disableSoundForMessages = false,
    this.customSoundForMessage,
    this.customSoundForMessagePackage,
    // Callbacks
    this.onChange,
    this.onSendButtonTap,
    this.onError,
    this.onToolbarVisibilityChange,
    this.onMentionLimitReached,
    this.onEditCancel,
    this.stateCallBack,
    // Custom views
    this.auxiliaryButtonView,
    this.headerView,
    this.footerView,
    this.attachmentOptions,
    // Text formatters
    this.textFormatters,
    // Parent message (for threads)
    this.parentMessageId = 0,
    // Custom icons
    this.attachmentIcon,
    this.voiceRecordingIcon,
    this.sendButtonIcon,
    // Media recorder icons
    this.recorderStartButtonIcon,
    this.recorderPauseButtonIcon,
    this.recorderDeleteButtonIcon,
    this.recorderStopButtonIcon,
    this.recorderSendButtonIcon,
  }) : assert(
         user != null || group != null,
         "One of user or group should be passed",
       ),
       assert(
         user == null || group == null,
         "Only one of user or group should be passed",
       );

  //--------------------Target Configuration-----------------------

  /// [user] sets the user for the message composer.
  /// Either [user] or [group] must be provided, but not both.
  final User? user;

  /// [group] sets the group for the message composer.
  /// Either [user] or [group] must be provided, but not both.
  final Group? group;

  //--------------------Style Configuration-----------------------

  /// [compactMessageComposerStyle] provides styling for the single line composer.
  /// When provided, these styles override the default theme styles.
  final CometChatCompactMessageComposerStyle? compactMessageComposerStyle;

  //--------------------Rich Text Configuration-----------------------

  /// [enableRichTextFormatting] enables or disables rich text formatting.
  /// When set to true, rich text formatting will work if markdown is manually
  /// typed in the composer. This is the master switch — if set to false,
  /// [showRichTextFormattingOptions] and [showTextSelectionMenuItems] will
  /// not work even if they are set to true.
  /// Defaults to true.
  /// _Requirements: 2.6_
  final bool enableRichTextFormatting;

  /// [showRichTextFormattingOptions] controls whether the rich text toolbar
  /// is visible above the composer.
  /// When true, the toolbar is displayed above the composer.
  /// When false, the toolbar is hidden.
  /// Only works when [enableRichTextFormatting] is true.
  /// Defaults to true.
  /// _Requirements: 2.7_
  final bool showRichTextFormattingOptions;

  /// [showTextSelectionMenuItems] controls whether formatting options are
  /// shown in the tooltip menu when text is selected.
  /// When true, formatting options (bold, italic, etc.) appear in the
  /// text selection context menu.
  /// When false, only default text selection actions are shown.
  /// Only works when [enableRichTextFormatting] is true.
  /// Defaults to true.
  final bool showTextSelectionMenuItems;

  /// [hideRichTextFormattingOptions] specifies which format types to hide
  /// from the rich text toolbar.
  /// _Requirements: 2.5_
  final Set<FormatType>? hideRichTextFormattingOptions;

  /// [richTextToolbarStyle] provides custom styling for the rich text toolbar.
  final CometChatRichTextToolbarStyle? richTextToolbarStyle;

  //--------------------Input Configuration-----------------------

  /// [placeholderText] sets the hint text for the input field.
  /// _Requirements: 1.3_
  final String? placeholderText;

  /// [maxLine] sets the maximum number of lines the input field can expand to.
  /// Defaults to 4.
  final int maxLine;

  /// [text] sets the initial text for the input field.
  final String? text;

  /// [textEditingController] provides external control over the text field state.
  /// If not provided, an internal controller is created.
  final TextEditingController? textEditingController;

  //--------------------Enter Key Behavior-----------------------

  /// [enterKeyBehavior] defines what happens when the Enter key is pressed.
  /// - [EnterKeyBehavior.sendMessage]: Sends the message
  /// - [EnterKeyBehavior.newLine]: Inserts a new line
  /// Defaults to [EnterKeyBehavior.sendMessage].
  /// _Requirements: 4.1, 4.2, 4.3_
  final EnterKeyBehavior enterKeyBehavior;

  //--------------------Button Visibility-----------------------

  /// [hideAttachmentButton] hides the attachment button when true.
  /// Defaults to false.
  /// _Requirements: 1.9_
  final bool hideAttachmentButton;

  /// [hideVoiceRecordingButton] hides the voice recording button when true.
  /// Defaults to false.
  /// _Requirements: 1.6, 7.3_
  final bool hideVoiceRecordingButton;

  /// [hideSendButton] hides the send button when true.
  /// Defaults to false.
  /// _Requirements: 1.8_
  final bool hideSendButton;

  //--------------------Attachment Option Visibility-----------------------

  /// [hideImageAttachmentOption] hides the image attachment option when true.
  /// Defaults to false.
  final bool hideImageAttachmentOption;

  /// [hideVideoAttachmentOption] hides the video attachment option when true.
  /// Defaults to false.
  final bool hideVideoAttachmentOption;

  /// [hideAudioAttachmentOption] hides the audio attachment option when true.
  /// Defaults to false.
  final bool hideAudioAttachmentOption;

  /// [hideFileAttachmentOption] hides the file attachment option when true.
  /// Defaults to false.
  final bool hideFileAttachmentOption;

  /// [hidePollsOption] hides the polls option when true.
  /// Defaults to false.
  final bool hidePollsOption;

  /// [hideCollaborativeDocumentOption] hides the collaborative document option when true.
  /// Defaults to false.
  final bool hideCollaborativeDocumentOption;

  /// [hideCollaborativeWhiteboardOption] hides the collaborative whiteboard option when true.
  /// Defaults to false.
  final bool hideCollaborativeWhiteboardOption;

  /// [hideTakePhotoOption] hides the take photo option when true.
  /// Defaults to false.
  final bool hideTakePhotoOption;

  /// [hideStickersButton] hides the stickers button when true.
  /// Defaults to false.
  final bool hideStickersButton;

  //--------------------Mention Configuration-----------------------

  /// [disableMentions] disables the mention suggestion list when true.
  /// Defaults to false.
  /// _Requirements: 5.3_
  final bool disableMentions;

  /// [disableMentionAll] disables the @all option in mention suggestions when true.
  /// Defaults to false.
  /// _Requirements: 5.4_
  final bool disableMentionAll;

  /// [mentionAllLabel] is the label to display for @all mention.
  /// Defaults to localized "Notify All".
  final String? mentionAllLabel;

  /// [mentionAllLabelId] is the ID for @all mention.
  /// Defaults to "all".
  final String? mentionAllLabelId;

  //--------------------Typing Events-----------------------

  /// [disableTypingEvents] disables typing indicator events when true.
  /// Defaults to false.
  /// _Requirements: 9.3_
  final bool disableTypingEvents;

  //--------------------Sound Configuration-----------------------

  /// [disableSoundForMessages] disables the sound played when a message is sent.
  /// Defaults to false.
  final bool disableSoundForMessages;

  /// [customSoundForMessage] provides a custom sound asset URL for sent messages.
  final String? customSoundForMessage;

  /// [customSoundForMessagePackage] specifies the package name for custom sound assets.
  final String? customSoundForMessagePackage;

  //--------------------Callbacks-----------------------

  /// [onChange] callback invoked when the text in the input field changes.
  /// _Requirements: 12.1_
  final Function(String text)? onChange;

  /// [onSendButtonTap] callback invoked when the send button is tapped.
  /// Provides the context, message, and preview mode.
  /// _Requirements: 3.3_
  final Function(
    BuildContext context,
    BaseMessage message,
    PreviewMessageMode? previewMessageMode,
  )?
  onSendButtonTap;

  /// [onError] callback invoked when an error occurs.
  /// _Requirements: 12.3_
  final OnError? onError;

  /// [onToolbarVisibilityChange] callback invoked when the toolbar visibility changes.
  /// _Requirements: 12.2_
  final void Function(bool isVisible)? onToolbarVisibilityChange;

  /// [onMentionLimitReached] callback invoked when the mention limit is exceeded.
  /// _Requirements: 5.5_
  final void Function(int limit)? onMentionLimitReached;

  /// [onEditCancel] callback invoked when edit mode is cancelled.
  /// _Requirements: 6.3_
  final void Function()? onEditCancel;

  /// [stateCallBack] provides access to the controller for external state management.
  /// _Requirements: 12.4_
  final void Function(CometChatCompactMessageComposerController controller)?
  stateCallBack;

  //--------------------Custom Views-----------------------

  /// [auxiliaryButtonView] provides a custom widget for auxiliary buttons (emoji, etc.).
  /// _Requirements: 1.5_
  final ComposerWidgetBuilder? auxiliaryButtonView;

  /// [headerView] provides a custom widget to display above the composer.
  final ComposerWidgetBuilder? headerView;

  /// [footerView] provides a custom widget to display below the composer.
  final ComposerWidgetBuilder? footerView;

  /// [attachmentOptions] provides custom attachment options for the attachment sheet.
  /// _Requirements: 8.1_
  final ComposerActionsBuilder? attachmentOptions;

  //--------------------Text Formatters-----------------------

  /// [textFormatters] provides a list of text formatters for processing input text.
  final List<CometChatTextFormatter>? textFormatters;

  //--------------------Parent Message-----------------------

  /// [parentMessageId] sets the parent message ID for thread messages.
  /// Defaults to 0 (no parent).
  final int parentMessageId;

  //--------------------Custom Icons-----------------------

  /// [attachmentIcon] provides a custom icon for the attachment button.
  final Widget? attachmentIcon;

  /// [voiceRecordingIcon] provides a custom icon for the voice recording button.
  final Widget? voiceRecordingIcon;

  /// [sendButtonIcon] provides a custom icon for the send button.
  final Widget? sendButtonIcon;

  /// [recorderStartButtonIcon] provides a custom icon for the recorder start button.
  final Widget? recorderStartButtonIcon;

  /// [recorderPauseButtonIcon] provides a custom icon for the recorder pause button.
  final Widget? recorderPauseButtonIcon;

  /// [recorderDeleteButtonIcon] provides a custom icon for the recorder delete button.
  final Widget? recorderDeleteButtonIcon;

  /// [recorderStopButtonIcon] provides a custom icon for the recorder stop button.
  final Widget? recorderStopButtonIcon;

  /// [recorderSendButtonIcon] provides a custom icon for the recorder send button.
  final Widget? recorderSendButtonIcon;

  @override
  State<CometChatCompactMessageComposer> createState() =>
      _CometChatCompactMessageComposerState();
}

class _CometChatCompactMessageComposerState
    extends State<CometChatCompactMessageComposer> {
  /// [_controller] contains the business logic for the composer
  CometChatCompactMessageComposerController? _controller;

  /// [composerId] unique identifier for this composer instance
  late Map<String, dynamic> composerId = {};

  /// Theme-related properties
  CometChatCompactMessageComposerStyle? style;
  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  /// [_layerLink] used for positioning the suggestion list overlay
  final LayerLink _layerLink = LayerLink();

  /// Unique key for the TextField to ensure proper widget tree management
  late final Key _textFieldKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get theme properties from context
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);

    // Get and merge style
    style = CometChatThemeHelper.getTheme<CometChatCompactMessageComposerStyle>(
      context: context,
      defaultTheme: CometChatCompactMessageComposerStyle.of,
    ).merge(widget.compactMessageComposerStyle);

    // Update auxiliary button icon color from style when theme changes
    _controller?.auxiliaryButtonIconColor =
        style?.auxiliaryButtonIconColor ?? colorPalette?.iconSecondary;

    // Initialize auxiliary options here (not during build phase)
    _controller?.initAuxiliaryOptions(context);
  }

  void _initializeController() {
    // Initialize controller
    _controller = CometChatCompactMessageComposerController(
      user: widget.user,
      group: widget.group,
      text: widget.text,
      parentMessageId: widget.parentMessageId,
      disableSoundForMessages: widget.disableSoundForMessages,
      customSoundForMessage: widget.customSoundForMessage,
      customSoundForMessagePackage: widget.customSoundForMessagePackage,
      disableTypingEvents: widget.disableTypingEvents,
      disableMentions: widget.disableMentions,
      disableMentionAll: widget.disableMentionAll,
      mentionAllLabel: widget.mentionAllLabel,
      mentionAllLabelId: widget.mentionAllLabelId,
      textEditingController: widget.textEditingController,
      enterKeyBehavior: widget.enterKeyBehavior,
      enableRichTextEditor: widget.enableRichTextFormatting,
      hideRichTextFormattingOptions: widget.hideRichTextFormattingOptions,
      richTextFormatterStyle:
          widget.compactMessageComposerStyle?.richTextFormatterStyle,
      stateCallBack: widget.stateCallBack,
      onSendButtonTap: widget.onSendButtonTap,
      onError: widget.onError,
      onToolbarVisibilityChange: widget.onToolbarVisibilityChange,
      onMentionLimitReached: widget.onMentionLimitReached,
      onEditCancel: widget.onEditCancel,
      onChange: widget.onChange != null
          ? (controller) =>
                widget.onChange!(controller.textEditingController?.text ?? '')
          : null,
      attachmentOptions: widget.attachmentOptions,
      attachmentOptionSheetStyle: null, // Will be set in didChangeDependencies
      hideImageAttachmentOption: widget.hideImageAttachmentOption,
      hideVideoAttachmentOption: widget.hideVideoAttachmentOption,
      hideAudioAttachmentOption: widget.hideAudioAttachmentOption,
      hideFileAttachmentOption: widget.hideFileAttachmentOption,
      hidePollsOption: widget.hidePollsOption,
      hideCollaborativeDocumentOption: widget.hideCollaborativeDocumentOption,
      hideCollaborativeWhiteboardOption:
          widget.hideCollaborativeWhiteboardOption,
      hideTakePhotoOption: widget.hideTakePhotoOption,
      hideStickersButton: widget.hideStickersButton,
      textFormatters: widget.textFormatters,
    );

    // Populate composer ID
    if (widget.group != null) {
      composerId['guid'] = widget.group!.guid;
    } else if (widget.user != null) {
      composerId['uid'] = widget.user!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    return PopScope(
      canPop: true,
      child: SafeArea(
        child: GetBuilder(
          init: _controller,
          tag: _controller!.tag,
          dispose:
              (
                GetBuilderState<CometChatCompactMessageComposerController>
                state,
              ) => Get.delete<CometChatCompactMessageComposerController>(
                tag: state.controller?.tag,
              ),
          builder: (CometChatCompactMessageComposerController controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: effectiveStyle.border,
                borderRadius: effectiveStyle.borderRadius,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header view (if provided)
                  if (widget.headerView != null)
                    widget.headerView!(
                      context,
                      widget.user,
                      widget.group,
                      composerId,
                    ),

                  // Header panel (set via showPanel, e.g., AI features)
                  if (controller.header != null) controller.header!,

                  // Suggestion list overlay + Preview banner + Compose box
                  // The overlay is positioned above the preview banner
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: OverlayPortal(
                      controller: controller.overlayPortalController,
                      overlayChildBuilder: (context) {
                        return CompositedTransformFollower(
                          link: _layerLink,
                          targetAnchor: Alignment.topLeft,
                          followerAnchor: Alignment.bottomLeft,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child:
                                controller.preview ?? const SizedBox.shrink(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Preview banner (edit/reply mode)
                          // _Requirements: 6.1, 6.2, 6.3_
                          if (controller.previewMessageMode !=
                              PreviewMessageMode.none)
                            _buildPreviewBanner(controller),

                          // Main compose box (optionally unified with rich text toolbar)
                          // _Requirements: 1.1, 1.2, 1.3, 1.5, 1.7, 2.1, 2.2, 2.5, 2.6, 2.7_
                          Builder(
                            builder: (builderContext) {
                              return _buildComposerWithOptionalToolbar(
                                controller,
                                effectiveColorPalette,
                                effectiveSpacing,
                                effectiveTypography,
                                builderContext,
                                hasPreview:
                                    controller.previewMessageMode !=
                                    PreviewMessageMode.none,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer panel (set via showPanel, e.g., sticker keyboard)
                  if (controller.footer != null) controller.footer!,

                  // Footer view (if provided)
                  if (widget.footerView != null)
                    widget.footerView!(
                      context,
                      widget.user,
                      widget.group,
                      composerId,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the compose box, optionally unified with the rich text toolbar
  /// as a single visual component with shared background and border.
  Widget _buildComposerWithOptionalToolbar(
    CometChatCompactMessageComposerController controller,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
    CometChatTypography effectiveTypography,
    BuildContext builderContext, {
    bool hasPreview = false,
  }) {
    // Always set context so that showPanel can work properly
    controller.setContext(builderContext);

    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final showToolbar =
        widget.enableRichTextFormatting &&
        widget.showRichTextFormattingOptions &&
        !controller.isInlineAudioRecorderVisible;

    final composeBoxContent = controller.isInlineAudioRecorderVisible
        ? _buildInlineAudioRecorder(controller)
        : _buildComposeBox(
            controller,
            unified: showToolbar,
            hasPreview: hasPreview,
          );

    if (!showToolbar) {
      // No toolbar — just the compose box with its own styling
      return Padding(
        padding: EdgeInsets.only(
          left: effectiveSpacing.margin2 ?? 8,
          right: effectiveSpacing.margin2 ?? 8,
          bottom: effectiveSpacing.margin2 ?? 8,
        ),
        child: composeBoxContent,
      );
    }

    // Unified container: compose box + divider + toolbar
    final toolbarStyle =
        widget.richTextToolbarStyle ??
        effectiveStyle.richTextToolbarStyle ??
        const CometChatRichTextToolbarStyle();

    return Padding(
      padding: EdgeInsets.only(
        left: effectiveSpacing.margin2 ?? 8,
        right: effectiveSpacing.margin2 ?? 8,
        bottom: effectiveSpacing.margin2 ?? 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: hasPreview
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(effectiveSpacing.radius2 ?? 8),
                  bottomRight: Radius.circular(effectiveSpacing.radius2 ?? 8),
                )
              : (effectiveStyle.composeBoxBorderRadius ??
                    BorderRadius.circular(effectiveSpacing.radius2 ?? 8)),
          border:
              effectiveStyle.composeBoxBorder ??
              (hasPreview
                  ? Border(
                      top: BorderSide.none,
                      bottom: BorderSide(
                        color:
                            effectiveColorPalette.borderDefault ??
                            Colors.transparent,
                        width: 1,
                      ),
                      left: BorderSide(
                        color:
                            effectiveColorPalette.borderDefault ??
                            Colors.transparent,
                        width: 1,
                      ),
                      right: BorderSide(
                        color:
                            effectiveColorPalette.borderDefault ??
                            Colors.transparent,
                        width: 1,
                      ),
                    )
                  : Border.all(
                      color:
                          effectiveColorPalette.borderDefault ??
                          Colors.transparent,
                      width: 1,
                    )),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compose box with background1 (white in light mode)
            Container(
              color:
                  effectiveStyle.composeBoxBackgroundColor ??
                  effectiveColorPalette.background1,
              child: composeBoxContent,
            ),

            // Rich text toolbar with grey background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: effectiveColorPalette.background2,
                border: Border(
                  top: BorderSide(
                    color:
                        effectiveColorPalette.borderLight ?? Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: CometChatRichTextToolbar(
                onFormatTap: (FormatType formatType) {
                  controller.toggleFormat(formatType);
                },
                activeFormats: controller.activeFormats,
                hiddenFormats: widget.hideRichTextFormattingOptions ?? {},
                disabledFormats: controller.disabledFormats,
                style: toolbarStyle.merge(
                  CometChatRichTextToolbarStyle(
                    backgroundColor: Colors.transparent,
                    border: Border.all(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the pill-shaped compose box container with all buttons and input field.
  ///
  /// Layout order: attachment button | text input | toggle button | auxiliary buttons (stickers) | voice button | send button
  ///
  /// _Requirements: 1.1, 1.2, 1.3, 1.5, 1.7_
  Widget _buildComposeBox(
    CometChatCompactMessageComposerController controller, {
    bool unified = false,
    bool hasPreview = false,
  }) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    const minHeight = 56.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Container(
        decoration: unified
            ? null
            : BoxDecoration(
                color:
                    effectiveStyle.composeBoxBackgroundColor ??
                    effectiveColorPalette.background1,
                borderRadius: hasPreview
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(
                          effectiveSpacing.radius2 ?? 8,
                        ),
                        bottomRight: Radius.circular(
                          effectiveSpacing.radius2 ?? 8,
                        ),
                      )
                    : (effectiveStyle.composeBoxBorderRadius ??
                          BorderRadius.circular(effectiveSpacing.radius2 ?? 8)),
                border:
                    effectiveStyle.composeBoxBorder ??
                    (hasPreview
                        ? Border(
                            top: BorderSide.none,
                            bottom: BorderSide(
                              color:
                                  effectiveColorPalette.borderDefault ??
                                  Colors.transparent,
                              width: 1,
                            ),
                            left: BorderSide(
                              color:
                                  effectiveColorPalette.borderDefault ??
                                  Colors.transparent,
                              width: 1,
                            ),
                            right: BorderSide(
                              color:
                                  effectiveColorPalette.borderDefault ??
                                  Colors.transparent,
                              width: 1,
                            ),
                          )
                        : Border.all(
                            color:
                                effectiveColorPalette.borderDefault ??
                                Colors.transparent,
                            width: 1,
                          )),
              ),
        padding: EdgeInsets.symmetric(
          horizontal: effectiveSpacing.padding3 ?? 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button (left side)
            // _Requirements: 1.2, 1.9_
            if (!widget.hideAttachmentButton && !controller.isUserAgentic())
              _buildAttachmentButton(controller),

            // Text input field (expandable)
            // _Requirements: 1.3_
            Expanded(child: _buildTextInput(controller)),

            // Auxiliary buttons (stickers) - positioned on right, before mic and send
            // Hidden when user is agentic
            // _Requirements: 1.5_
            if (!controller.isUserAgentic()) _buildAuxiliaryButtons(controller),

            // Voice recording button with animation
            // Hidden when user is agentic
            // _Requirements: 1.6, 7.3_
            if (!widget.hideVoiceRecordingButton && !controller.isUserAgentic())
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: controller.hasText
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : KeyedSubtree(
                        key: const ValueKey('mic'),
                        child: _buildVoiceRecordingButton(controller),
                      ),
              ),

            // Send button (far right)
            // _Requirements: 1.7, 1.8_
            if (!widget.hideSendButton) _buildSendButton(controller),
          ],
        ),
      ),
    );
  }

  /// Builds the attachment button.
  ///
  /// Shows [CometChatAttachmentOptionSheet] on tap to allow users to select
  /// attachment types (image, video, audio, file).
  ///
  /// _Requirements: 1.2, 1.9, 8.1, 8.2, 8.3_
  Widget _buildAttachmentButton(
    CometChatCompactMessageComposerController controller,
  ) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);

    return Semantics(
      label: 'Attachment button',
      button: true,
      child: Container(
        height: 24,
        width: 24,
        margin: EdgeInsets.only(
          right: effectiveSpacing.margin1 ?? 4,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: effectiveStyle.attachmentButtonBackgroundColor,
          borderRadius:
              effectiveStyle.attachmentButtonBorderRadius ??
              BorderRadius.circular(12),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon:
              widget.attachmentIcon ??
              Padding(
                padding: const EdgeInsets.all(1.25),
                child: Image.asset(
                  AssetConstants.add,
                  package: UIConstants.packageName,
                  height: 21.5,
                  width: 21.5,
                  color:
                      effectiveStyle.attachmentButtonIconColor ??
                      effectiveColorPalette.iconSecondary,
                ),
              ),
          onPressed: () {
            // Show attachment options sheet
            // _Requirements: 8.1, 8.2, 8.3_
            controller.showBottomActionSheet(
              context,
              effectiveColorPalette,
              effectiveTypography,
            );
          },
        ),
      ),
    );
  }

  /// Builds the text input field.
  ///
  /// When in segmented mode (has code blocks), renders a Column of segments.
  /// Otherwise, renders a single TextField.
  ///
  /// _Requirements: 1.3_
  Widget _buildTextInput(CometChatCompactMessageComposerController controller) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);

    // If in segmented mode, render segments as a Column
    if (controller.isSegmentedMode && controller.segmentedController != null) {
      return _buildSegmentedInput(
        controller,
        effectiveStyle,
        effectiveColorPalette,
        effectiveSpacing,
        effectiveTypography,
      );
    }

    // Check if code block format is active (non-segmented mode)
    final isCodeBlockActive = controller.activeFormats.contains(
      FormatType.codeBlock,
    );

    final textField = TextField(
      key: _textFieldKey,
      controller: controller.textEditingController,
      focusNode: controller.focusNode,
      textCapitalization: TextCapitalization.sentences,
      keyboardAppearance: CometChatThemeHelper.getBrightness(context),
      minLines: 1,
      maxLines: widget.maxLine,
      style:
          TextStyle(
                color: effectiveColorPalette.textPrimary,
                fontSize: effectiveTypography.body?.regular?.fontSize,
                fontWeight: effectiveTypography.body?.regular?.fontWeight,
                fontFamily: isCodeBlockActive
                    ? 'monospace'
                    : effectiveTypography.body?.regular?.fontFamily,
              )
              .merge(effectiveStyle.textStyle)
              .copyWith(color: effectiveStyle.textColor),
      decoration: InputDecoration(
        hintText:
            widget.placeholderText ??
            cc.Translations.of(context).typeYourMessage,
        hintStyle:
            TextStyle(
                  color: effectiveColorPalette.textTertiary,
                  fontSize: effectiveTypography.body?.regular?.fontSize,
                  fontWeight: effectiveTypography.body?.regular?.fontWeight,
                  fontFamily: effectiveTypography.body?.regular?.fontFamily,
                )
                .merge(effectiveStyle.placeholderTextStyle)
                .copyWith(color: effectiveStyle.placeholderTextColor),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: effectiveSpacing.padding2 ?? 8,
          vertical: effectiveSpacing.padding2 ?? 8,
        ),
        isDense: true,
      ),
      onChanged: (text) {
        controller.onTextChanged();
        widget.onChange?.call(text);
      },
      onTap: () {
        // Check if the user tapped on a link and show the link edit menu
        controller.checkLinkTapAtCursor();
      },
      textInputAction: widget.enterKeyBehavior == EnterKeyBehavior.sendMessage
          ? TextInputAction.send
          : TextInputAction.newline,
      onSubmitted: widget.enterKeyBehavior == EnterKeyBehavior.sendMessage
          ? (_) => controller.handleEnterKey(context)
          : null,
      // Add rich text formatting options to the native text selection context menu
      contextMenuBuilder:
          (widget.enableRichTextFormatting && widget.showTextSelectionMenuItems)
          ? (context, editableTextState) {
              return shared.buildRichTextContextMenu(
                context: context,
                editableTextState: editableTextState,
                onFormatTap: (formatType) {
                  controller.toggleFormat(formatType);
                },
                hiddenFormats: widget.hideRichTextFormattingOptions ?? {},
              );
            }
          : (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: editableTextState.contextMenuButtonItems,
              );
            },
    );

    // Wrap in code block container when code block format is active
    if (isCodeBlockActive) {
      return Semantics(
        label: 'Message input field',
        textField: true,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: effectiveSpacing.margin1 ?? 4,
            vertical: effectiveSpacing.margin1 ?? 4,
          ),
          padding: EdgeInsets.all(effectiveSpacing.padding2 ?? 8),
          decoration: BoxDecoration(
            color:
                effectiveStyle
                    .richTextFormatterStyle
                    ?.codeBlockBackgroundColor ??
                effectiveColorPalette.background3,
            borderRadius: BorderRadius.circular(effectiveSpacing.radius2 ?? 8),
          ),
          child: textField,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        label: 'Message input field',
        textField: true,
        child: textField,
      ),
    );
  }

  /// Builds the segmented input with multiple segments (normal and code).
  Widget _buildSegmentedInput(
    CometChatCompactMessageComposerController controller,
    CometChatCompactMessageComposerStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
    CometChatTypography effectiveTypography,
  ) {
    final segmentedController = controller.segmentedController!;
    final segments = segmentedController.segments;
    final hasCodeBlocks = segmentedController.hasCodeBlocks;
    final pendingFocusSegment = segmentedController.pendingFocusSegment;

    // Handle pending focus after frame
    if (pendingFocusSegment != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pendingFocusSegment.focusNode.requestFocus();
        segmentedController.clearPendingFocus();
      });
    }

    // Calculate max height based on maxLine (approximately 4 lines of text)
    final lineHeight =
        (effectiveTypography.body?.regular?.fontSize ?? 16) * 1.4;
    final maxHeight =
        lineHeight * widget.maxLine + (effectiveSpacing.padding2 ?? 8) * 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: segments.map((segment) {
              // Determine visibility for empty normal segments
              final shouldHide =
                  segment.type == shared.SegmentType.normal &&
                  segment.isEmpty &&
                  hasCodeBlocks &&
                  segments.length > 1 &&
                  !segment.hasFocus &&
                  segment != pendingFocusSegment;

              if (shouldHide) {
                return SizedBox.shrink(key: ValueKey(segment.id));
              }

              if (segment.type == shared.SegmentType.code) {
                return _buildCodeSegmentWidget(
                  segment,
                  controller,
                  effectiveStyle,
                  effectiveColorPalette,
                  effectiveSpacing,
                  effectiveTypography,
                );
              } else {
                return _buildNormalSegmentWidget(
                  segment,
                  controller,
                  effectiveStyle,
                  effectiveColorPalette,
                  effectiveSpacing,
                  effectiveTypography,
                  showPlaceholder:
                      segments.indexOf(segment) == 0 && !hasCodeBlocks,
                );
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds a normal segment widget.
  Widget _buildNormalSegmentWidget(
    shared.ComposerSegment segment,
    CometChatCompactMessageComposerController controller,
    CometChatCompactMessageComposerStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
    CometChatTypography effectiveTypography, {
    bool showPlaceholder = false,
  }) {
    return KeyedSubtree(
      key: ValueKey(segment.id),
      child: Focus(
        onKeyEvent: (node, event) {
          // Handle backspace on empty normal segment
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              segment.isEmpty) {
            if (controller.handleSegmentedBackspace()) {
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: segment.controller,
          focusNode: segment.focusNode,
          textCapitalization: TextCapitalization.sentences,
          keyboardAppearance: CometChatThemeHelper.getBrightness(context),
          minLines: 1,
          maxLines: null,
          style:
              TextStyle(
                    color: effectiveColorPalette.textPrimary,
                    fontSize: effectiveTypography.body?.regular?.fontSize,
                    fontWeight: effectiveTypography.body?.regular?.fontWeight,
                    fontFamily: effectiveTypography.body?.regular?.fontFamily,
                  )
                  .merge(effectiveStyle.textStyle)
                  .copyWith(color: effectiveStyle.textColor),
          decoration: InputDecoration(
            hintText: showPlaceholder
                ? (widget.placeholderText ??
                      cc.Translations.of(context).typeYourMessage)
                : null,
            hintStyle:
                TextStyle(
                      color: effectiveColorPalette.textTertiary,
                      fontSize: effectiveTypography.body?.regular?.fontSize,
                      fontWeight: effectiveTypography.body?.regular?.fontWeight,
                      fontFamily: effectiveTypography.body?.regular?.fontFamily,
                    )
                    .merge(effectiveStyle.placeholderTextStyle)
                    .copyWith(color: effectiveStyle.placeholderTextColor),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: effectiveSpacing.padding2 ?? 8,
              vertical: effectiveSpacing.padding2 ?? 8,
            ),
            isDense: true,
          ),
          onChanged: (text) {
            // Notify controller of text change for mentions, typing indicator, etc.
            controller.onSegmentTextChanged(segment);
            widget.onChange?.call(text);
          },
          contextMenuBuilder:
              (widget.enableRichTextFormatting &&
                  widget.showTextSelectionMenuItems)
              ? (context, editableTextState) {
                  return shared.buildRichTextContextMenu(
                    context: context,
                    editableTextState: editableTextState,
                    onFormatTap: (formatType) {
                      controller.toggleFormat(formatType);
                    },
                    hiddenFormats: widget.hideRichTextFormattingOptions ?? {},
                  );
                }
              : (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: editableTextState.contextMenuButtonItems,
                  );
                },
        ),
      ),
    );
  }

  /// Builds a code segment widget.
  ///
  /// If the segment is inside a blockquote, it renders with a left border
  /// to indicate the blockquote context.
  Widget _buildCodeSegmentWidget(
    shared.ComposerSegment segment,
    CometChatCompactMessageComposerController controller,
    CometChatCompactMessageComposerStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
    CometChatTypography effectiveTypography,
  ) {
    // Determine if this code segment is inside a blockquote
    final isInsideBlockquote = segment.isInsideBlockquote;

    // Build the code block container
    Widget codeBlock = Container(
      decoration: BoxDecoration(
        color:
            effectiveStyle.richTextFormatterStyle?.codeBlockBackgroundColor ??
            effectiveColorPalette.background3,
        borderRadius: BorderRadius.circular(effectiveSpacing.radius1 ?? 5),
        border: Border.all(
          color: effectiveColorPalette.borderDark ?? const Color(0xFF565856),
          width: 1,
        ),
      ),
      child: Focus(
        onKeyEvent: (node, event) {
          // Handle backspace on empty code segment
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              segment.isEmpty) {
            if (controller.handleSegmentedBackspace()) {
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: segment.controller,
          focusNode: segment.focusNode,
          keyboardAppearance: CometChatThemeHelper.getBrightness(context),
          minLines: 1,
          maxLines: null,
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(
            color: effectiveColorPalette.textPrimary,
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.4,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.all(effectiveSpacing.padding2 ?? 8),
            isDense: true,
          ),
        ),
      ),
    );

    // If inside blockquote, wrap with a container that has a left border
    if (isInsideBlockquote) {
      codeBlock = Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color:
                  effectiveStyle
                      .richTextFormatterStyle
                      ?.blockquoteBorderColor ??
                  effectiveColorPalette.primary ??
                  Colors.blue,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: 8),
        child: codeBlock,
      );
    }

    return KeyedSubtree(
      key: ValueKey(segment.id),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: effectiveSpacing.margin1 ?? 4),
        child: codeBlock,
      ),
    );
  }

  /// Builds the auxiliary buttons (emoji, stickers, etc.).
  /// Builds the auxiliary buttons (emoji, stickers, etc.).
  ///
  /// Positioned on the right side of the compose box, after the text input,
  /// before the microphone and send buttons.
  ///
  /// _Requirements: 1.5_
  Widget _buildAuxiliaryButtons(
    CometChatCompactMessageComposerController controller,
  ) {
    // If custom auxiliary button view is provided, use it
    if (widget.auxiliaryButtonView != null) {
      return widget.auxiliaryButtonView!(
        context,
        widget.user,
        widget.group,
        composerId,
      );
    }

    // Auxiliary options are initialized in didChangeDependencies
    // If auxiliary options are available from the data source (e.g., stickers), use them
    // Wrap with compact-composer-specific margin since the default margin
    // inside StickerAuxiliaryButton is tuned for MessageComposer.
    if (controller.auxiliaryOptions != null) {
      final effectiveSpacing =
          spacing ?? CometChatThemeHelper.getSpacing(context);
      return Container(
        margin: EdgeInsets.only(
          left: effectiveSpacing.padding3 ?? 12,
          right: 0,
          bottom: 16,
        ),
        child: controller.auxiliaryOptions!,
      );
    }

    // Default: return empty widget if no auxiliary options
    return const SizedBox.shrink();
  }

  /// Builds the voice recording button.
  ///
  /// Shows the inline audio recorder on tap to allow users to record and send
  /// voice messages. The recording is handled by the controller's [sendMediaRecording] method.
  ///
  /// _Requirements: 1.6, 7.1, 7.2, 7.3_
  Widget _buildVoiceRecordingButton(
    CometChatCompactMessageComposerController controller,
  ) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    return Semantics(
      label: 'Voice recording button',
      button: true,
      child: Container(
        height: 24,
        width: 24,
        margin: EdgeInsets.only(
          left: 0,
          right: effectiveSpacing.padding3 ?? 12,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: effectiveStyle.voiceRecordingButtonBackgroundColor,
          borderRadius:
              effectiveStyle.voiceRecordingButtonBorderRadius ??
              BorderRadius.circular(12),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon:
              widget.voiceRecordingIcon ??
              Image.asset(
                AssetConstants.microphone,
                package: UIConstants.packageName,
                height: 24,
                width: 24,
                color:
                    effectiveStyle.voiceRecordingButtonIconColor ??
                    effectiveColorPalette.iconSecondary,
              ),
          onPressed: () {
            // Show the inline audio recorder
            controller.showInlineAudioRecorder();
          },
        ),
      ),
    );
  }

  /// Builds the inline audio recorder widget.
  ///
  /// This replaces the compose box when the user taps the voice recording button.
  /// It provides an inline recording experience with:
  /// - Recording state: Delete | Red dot | Waveform | Timer | Pause | Send
  /// - Paused state: Delete | Play | Waveform | 0:00 | Mic | Send
  ///
  /// _Requirements: 7.1, 7.2, 7.3_
  Widget _buildInlineAudioRecorder(
    CometChatCompactMessageComposerController controller,
  ) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    return CometChatSingleLineMediaRecorder(
      onSubmit: controller.sendMediaRecording,
      onClose: controller.hideInlineAudioRecorder,
      deleteIcon: widget.recorderDeleteButtonIcon,
      pauseIcon: widget.recorderPauseButtonIcon,
      playIcon: widget.recorderStartButtonIcon,
      micIcon: widget.voiceRecordingIcon,
      sendIcon: widget.recorderSendButtonIcon,
      style: CometChatSingleLineMediaRecorderStyle(
        backgroundColor:
            effectiveStyle.composeBoxBackgroundColor ??
            effectiveColorPalette.background2,
        borderRadius:
            effectiveStyle.composeBoxBorderRadius ??
            BorderRadius.circular(effectiveSpacing.radius2 ?? 8),
        border: effectiveStyle.composeBoxBorder,
        deleteIconColor:
            effectiveStyle.mediaRecorderStyle?.deleteButtonIconColor ??
            effectiveColorPalette.iconSecondary,
        recordingIndicatorColor: effectiveColorPalette.error,
        waveformColor:
            effectiveStyle.mediaRecorderStyle?.recordIndicatorBackgroundColor ??
            effectiveColorPalette.primary,
        waveformInactiveColor: effectiveColorPalette.iconSecondary,
        timerTextColor: effectiveColorPalette.textSecondary,
        pauseIconColor: effectiveColorPalette.iconSecondary,
        playIconColor: effectiveColorPalette.primary,
        micIconColor: effectiveColorPalette.primary,
        sendButtonBackgroundColor:
            effectiveStyle.sendButtonBackgroundColor ??
            effectiveColorPalette.primary,
        sendButtonIconColor:
            effectiveStyle.sendButtonIconColor ?? effectiveColorPalette.white,
        sendButtonBorderRadius:
            effectiveStyle.sendButtonBorderRadius ?? BorderRadius.circular(16),
      ),
    );
  }

  /// Builds the send button.
  ///
  /// _Requirements: 1.7, 1.8, 3.1, 3.2_
  Widget _buildSendButton(
    CometChatCompactMessageComposerController controller,
  ) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    final isAgentic = controller.isUserAgentic();
    final isAiBusy = isAgentic && controller.isActiveStreaming;
    final isEnabled = controller.isSendButtonEnabled;
    final bool isStopButton = isAgentic && isAiBusy;
    final shouldDisable = !isEnabled || isAiBusy;

    // Determine button size, background color, and icon based on agentic state
    final double buttonSize = isAgentic ? 40 : 32;
    final Color backgroundColor;
    if (isStopButton) {
      backgroundColor =
          effectiveColorPalette.secondaryButtonBackground ??
          effectiveColorPalette.background4 ??
          Colors.grey;
    } else if (shouldDisable) {
      backgroundColor =
          effectiveStyle.sendButtonDisabledBackgroundColor ??
          effectiveColorPalette.background4 ??
          Colors.grey;
    } else if (isAgentic) {
      backgroundColor =
          effectiveColorPalette.secondaryButtonBackground ??
          effectiveColorPalette.primary ??
          Colors.blue;
    } else {
      backgroundColor =
          effectiveStyle.sendButtonBackgroundColor ??
          effectiveColorPalette.primary ??
          Colors.blue;
    }

    final Widget buttonIcon;
    if (widget.sendButtonIcon != null) {
      buttonIcon = widget.sendButtonIcon!;
    } else if (isAgentic) {
      buttonIcon = isAiBusy
          ? Icon(
              Icons.stop_rounded,
              color:
                  effectiveColorPalette.iconWhite ??
                  effectiveColorPalette.white,
              size: 20,
            )
          : Icon(
              Icons.arrow_upward_outlined,
              color:
                  effectiveColorPalette.iconWhite ??
                  effectiveColorPalette.white,
              size: 20,
            );
    } else {
      buttonIcon = Image.asset(
        AssetConstants.send,
        package: UIConstants.packageName,
        height: 24,
        width: 24,
        color: isEnabled
            ? (effectiveStyle.sendButtonIconColor ??
                  effectiveColorPalette.white)
            : (effectiveStyle.sendButtonIconColor ??
                  effectiveColorPalette.white),
      );
    }

    return Semantics(
      label: 'Send message button',
      button: true,
      enabled: !shouldDisable || isStopButton,
      child: Container(
        height: buttonSize,
        width: buttonSize,
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          left: effectiveSpacing.margin1 ?? 4,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.all(effectiveSpacing.padding1 ?? 4),
          constraints: const BoxConstraints(),
          icon: buttonIcon,
          onPressed: (!shouldDisable || isStopButton)
              ? () => controller.onSendButtonClick(context)
              : null,
        ),
      ),
    );
  }

  /// Builds the preview banner for edit/reply mode.
  ///
  /// The preview banner is displayed above the compose box when:
  /// - [controller.previewMessageMode] is [PreviewMessageMode.edit] OR
  /// - [controller.previewMessageMode] is [PreviewMessageMode.reply]
  ///
  /// In edit mode, shows "Edit Message" label with the original message text.
  /// In reply mode, shows the sender's name with the original message preview.
  ///
  /// The cancel button calls [controller.cancelPreview()] to exit preview mode.
  ///
  /// _Requirements: 6.1, 6.2, 6.3_
  Widget _buildPreviewBanner(
    CometChatCompactMessageComposerController controller,
  ) {
    final effectiveStyle =
        style ?? const CometChatCompactMessageComposerStyle();
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);

    // Determine the preview title based on mode
    final String previewTitle;
    final String previewSubtitle;
    final BaseMessage? previewMessage;

    if (controller.previewMessageMode == PreviewMessageMode.edit) {
      // Edit mode: Show "Edit Message" label
      // _Requirements: 6.1_
      previewTitle = cc.Translations.of(context).editMessage;
      previewMessage = controller.oldMessage;

      // Get the message text for subtitle
      // Convert mentions for preview display
      if (previewMessage is TextMessage) {
        String subtitle = previewMessage.text;
        // First convert mentions to display format
        if (previewMessage.mentionedUsers.isNotEmpty) {
          subtitle = shared.CometChatMentionsFormatter.getTextWithMentions(
            subtitle,
            previewMessage.mentionedUsers,
          );
        }
        // Also handle @all mentions
        subtitle = subtitle.replaceAll(RegExp(r'<@all:[^>]+>'), '@all');
        previewSubtitle = subtitle;
      } else {
        previewSubtitle = shared.ComposerUtils().getReplySubtitle(
          previewMessage,
          context,
        );
      }
    } else if (controller.previewMessageMode == PreviewMessageMode.reply) {
      // Reply mode: Show sender's name as title
      // _Requirements: 6.2_
      previewMessage = controller.quotedMessage;
      previewTitle =
          previewMessage?.sender?.name ?? cc.Translations.of(context).reply;

      // Get the message text for subtitle
      // Convert mentions for preview display
      if (previewMessage is TextMessage) {
        String subtitle = previewMessage.text;
        // First convert mentions to display format
        if (previewMessage.mentionedUsers.isNotEmpty) {
          subtitle = shared.CometChatMentionsFormatter.getTextWithMentions(
            subtitle,
            previewMessage.mentionedUsers,
          );
        }
        // Also handle @all mentions
        subtitle = subtitle.replaceAll(RegExp(r'<@all:[^>]+>'), '@all');
        previewSubtitle = subtitle;
      } else {
        previewSubtitle = shared.ComposerUtils().getReplySubtitle(
          previewMessage,
          context,
        );
      }
    } else {
      // No preview mode - should not reach here due to conditional rendering
      return const SizedBox.shrink();
    }

    // Get the message preview style from style prop or default
    final messagePreviewStyle =
        CometChatThemeHelper.getTheme<CometChatMessagePreviewStyle>(
          context: context,
          defaultTheme: CometChatMessagePreviewStyle.of,
        ).merge(effectiveStyle.messagePreviewStyle);

    return Padding(
      padding: EdgeInsets.only(
        left: effectiveSpacing.margin2 ?? 8,
        right: effectiveSpacing.margin2 ?? 8,
      ),
      child: Container(
        padding: EdgeInsets.all(effectiveSpacing.padding2 ?? 8),
        decoration: BoxDecoration(
          color:
              effectiveStyle.backgroundColor ??
              effectiveColorPalette.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(effectiveSpacing.radius2 ?? 8),
            topRight: Radius.circular(effectiveSpacing.radius2 ?? 8),
          ),
          border: Border(
            top: BorderSide(
              color: effectiveColorPalette.borderDefault ?? Colors.transparent,
              width: 1,
            ),
            left: BorderSide(
              color: effectiveColorPalette.borderDefault ?? Colors.transparent,
              width: 1,
            ),
            right: BorderSide(
              color: effectiveColorPalette.borderDefault ?? Colors.transparent,
              width: 1,
            ),
            bottom: BorderSide.none,
          ),
        ),
        child: CometChatMessagePreview(
          message: previewMessage,
          messagePreviewTitle: previewTitle,
          messagePreviewSubtitle: previewSubtitle,
          // Pass text formatters for rich text rendering in preview
          // _Requirements: 2.14_
          textFormatters: controller.formatters,
          // Wire up cancel button to controller.cancelPreview()
          // _Requirements: 6.3_
          onCloseClick: () {
            controller.cancelPreview();
          },
          messagePreviewStyle: CometChatMessagePreviewStyle(
            messagePreviewTitleStyle: TextStyle(
              color: controller.previewMessageMode == PreviewMessageMode.edit
                  ? const Color(0xFF141414)
                  : effectiveColorPalette.textHighlight,
              fontSize: effectiveTypography.caption1?.medium?.fontSize,
              fontWeight: effectiveTypography.caption1?.medium?.fontWeight,
              fontFamily: effectiveTypography.caption1?.medium?.fontFamily,
            ),
            messagePreviewSubtitleStyle: TextStyle(
              color: effectiveColorPalette.textSecondary,
              fontSize: effectiveTypography.caption1?.regular?.fontSize,
              fontWeight: effectiveTypography.caption1?.regular?.fontWeight,
              fontFamily: effectiveTypography.caption1?.regular?.fontFamily,
            ),
            closeIconColor:
                effectiveStyle.closeIconTint ??
                effectiveColorPalette.iconPrimary,
            messagePreviewBackground: effectiveColorPalette.background3,
            messagePreviewBorderRadius:
                controller.previewMessageMode == PreviewMessageMode.edit
                ? BorderRadius.circular(4)
                : BorderRadius.zero,
            messagePreviewBorder:
                controller.previewMessageMode == PreviewMessageMode.edit
                ? Border.all(width: 0, color: Colors.transparent)
                : null,
          ).merge(messagePreviewStyle),
        ),
      ),
    );
  }
}
