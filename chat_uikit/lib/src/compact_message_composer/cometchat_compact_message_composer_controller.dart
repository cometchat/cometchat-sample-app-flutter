import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Stores mention data so it can be restored when inline code is removed.
class _SavedMention {
  final int position;
  final String mentionText;
  final User? user;
  _SavedMention({required this.position, required this.mentionText, this.user});
}

/// [CometChatCompactMessageComposerController] is the view model for [CometChatCompactMessageComposer].
/// It contains all the business logic involved in changing the state of the UI
/// of [CometChatCompactMessageComposer].
///
/// This controller manages:
/// - Text input state via [TextEditingController]
/// - Rich text toolbar visibility
/// - Active text formats tracking
/// - Preview mode state (edit/reply)
/// - Mention count tracking
/// - Typing indicator events
///
/// The controller extends [GetxController] and mixes in event listeners for:
/// - [CometChatMessageEventListener] - Message-related events
/// - [CometChatUIEventListener] - UI-related events
/// - [CometChatUserEventListener] - User-related events
///
/// _Requirements: 2.1, 2.4, 6.1, 6.2, 6.4_
class CometChatCompactMessageComposerController extends GetxController
    with
        CometChatMessageEventListener,
        CometChatUIEventListener,
        CometChatUserEventListener,
        CometChatStreamCallbackListener {
  //--------------------Constructor-----------------------

  CometChatCompactMessageComposerController({
    this.user,
    this.group,
    this.text,
    this.parentMessageId = 0,
    this.disableSoundForMessages = false,
    this.customSoundForMessage,
    this.customSoundForMessagePackage,
    this.disableTypingEvents = false,
    this.stateCallBack,
    this.onSendButtonTap,
    this.onError,
    this.onToolbarVisibilityChange,
    this.onMentionLimitReached,
    this.onEditCancel,
    this.onChange,
    this.disableMentions = false,
    this.disableMentionAll = false,
    this.mentionAllLabel,
    this.mentionAllLabelId,
    this.textEditingController,
    this.enterKeyBehavior = EnterKeyBehavior.sendMessage,
    this.enableRichTextEditor = true,
    this.hideRichTextFormattingOptions,
    this.richTextFormatterStyle,
    this.attachmentOptions,
    this.hideImageAttachmentOption = false,
    this.hideVideoAttachmentOption = false,
    this.hideAudioAttachmentOption = false,
    this.hideFileAttachmentOption = false,
    this.hidePollsOption = false,
    this.hideCollaborativeDocumentOption = false,
    this.hideCollaborativeWhiteboardOption = false,
    this.hideTakePhotoOption = false,
    this.hideStickersButton = false,
    this.attachmentOptionSheetStyle,
    this.textFormatters,
    this.mentionsStyle,
    this.suggestionListStyle,
  }) {
    tag = "tag$counter";
    counter++;
  }

  //--------------------State Properties-----------------------

  /// [textEditingController] controls the state of the text field
  TextEditingController? textEditingController;

  /// [focusNode] manages focus for the text input field
  /// Enables proper keyboard navigation and focus management
  /// _Requirements: 11.2_
  FocusNode? focusNode;

  /// [isToolbarVisible] tracks whether the rich text toolbar is visible
  bool isToolbarVisible = false;

  /// [previewMessageMode] controls the visibility of message preview above input field
  PreviewMessageMode previewMessageMode = PreviewMessageMode.none;

  /// [oldMessage] the message being edited (in edit mode)
  BaseMessage? oldMessage;

  /// [quotedMessage] the message being replied to (in reply mode)
  BaseMessage? quotedMessage;

  /// [activeFormats] tracks which text formats are currently active
  /// When using RichTextEditingController, this delegates to the controller's activeFormats
  /// When in segmented mode, delegates to the segmented controller
  Set<FormatType> get activeFormats {
    // In segmented mode, use segmented controller's active formats
    if (isSegmentedMode) {
      final focused = _segmentedController!.focusedSegment;
      if (focused != null) {
        if (focused.type == SegmentType.code) {
          return {FormatType.codeBlock};
        }
        if (focused.controller is RichTextEditingController) {
          return (focused.controller as RichTextEditingController).activeFormats;
        }
      }
      return {};
    }
    
    if (_richTextController != null) {
      return _richTextController!.activeFormats;
    }
    return _activeFormats;
  }
  
  /// [disabledFormats] returns the set of formats that should be disabled
  /// When code block is active, inline formats are disabled but block formats
  /// (orderedList, bulletList, blockquote) remain available
  Set<FormatType> get disabledFormats {
    // In segmented mode, check if focused on code segment
    if (isSegmentedMode) {
      final focused = _segmentedController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.code) {
        // Only inline formats are disabled - block formats remain available
        return {
          FormatType.bold,
          FormatType.italic,
          FormatType.underline,
          FormatType.strikethrough,
          FormatType.link,
          FormatType.inlineCode,
        };
      }
    }
    
    if (_richTextController != null) {
      return _richTextController!.disabledFormats;
    }
    return {};
  }
  
  /// [mentionsEnabled] returns whether mentions should be enabled based on active format.
  /// 
  /// Mentions are disabled when code block or inline code is active, as these
  /// formats should display mentions as plain text (@username/@all) without
  /// formatting or styling.
  /// 
  /// Mentions are enabled for all other formats including:
  /// - No block format active (normal text)
  /// - Ordered list
  /// - Bullet list
  /// - Quote block (blockquote)
  /// 
  /// _Bug_Condition: isBugCondition(input) where activeFormat IN ["codeBlock", "inlineCode"] AND mentionSuggestionShown_
  /// _Expected_Behavior: mentionsEnabled = false when code block or inline code is active_
  /// _Preservation: mentionsEnabled = true for all other formats_
  /// _Requirements: 2.5, 2.6, 2.7_
  bool get mentionsEnabled {
    // In segmented mode, check if focused on code segment
    if (isSegmentedMode) {
      final focused = _segmentedController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.code) {
        // Mentions are disabled in code segments
        return false;
      }
      // For normal segments, delegate to the segment's controller
      if (focused != null && focused.controller is RichTextEditingController) {
        return (focused.controller as RichTextEditingController).mentionsEnabled;
      }
      // Default to enabled if no focused segment
      return true;
    }
    
    if (_richTextController != null) {
      return _richTextController!.mentionsEnabled;
    }
    // Default to enabled when not using RichTextEditingController
    return true;
  }
  
  /// Internal storage for active formats when not using RichTextEditingController
  final Set<FormatType> _activeFormats = {};

  /// [mentionCount] tracks the number of mentions in the current message
  int mentionCount = 0;

  /// [isActiveStreaming] tracks whether AI streaming is currently in progress
  /// When true, the send button should be disabled
  /// _Requirements: 15.1, 15.2, 15.3_
  bool isActiveStreaming = false;

  /// [streamService] manages AI streaming connections
  CometChatStreamService streamService = CometChatStreamService();

  /// [isInlineAudioRecorderVisible] tracks whether the inline audio recorder is visible
  /// When true, the compose box is replaced with the audio recorder UI
  bool isInlineAudioRecorderVisible = false;

  /// [_previousText] holds the state of the last typed text
  String _previousText = "";

  /// [_isTyping] state of typing events
  bool _isTyping = false;

  /// [loggedInUser] is the user the message is being sent from
  User loggedInUser = User(name: '', uid: '');

  //--------------------Mention Suggestion State-----------------------

  /// [suggestions] list of suggestion items for mentions
  /// _Requirements: 5.1, 5.2_
  List<SuggestionListItem> suggestions = [];

  /// [_suggestionListController] stream controller for suggestion list updates
  final StreamController<List<SuggestionListItem>> _suggestionListController =
      StreamController<List<SuggestionListItem>>();

  /// [_previousTextController] stream controller for previous text updates
  final StreamController<String> _previousTextController =
      StreamController<String>();

  /// [_suggestionListStream] stream for suggestion list updates
  late Stream<List<SuggestionListItem>> _suggestionListStream;

  /// [_previousTextStream] stream for previous text updates
  late Stream<String> _previousTextStream;

  /// [_suggestionSubscription] subscription to the suggestion list stream
  late StreamSubscription<List<SuggestionListItem>> _suggestionSubscription;

  /// [_formatters] list of text formatters including mentions formatter
  List<CometChatTextFormatter> _formatters = [];

  /// [formatters] public getter for the list of text formatters
  /// Used for passing formatters to child widgets like CometChatMessagePreview
  /// _Requirements: 2.14_
  List<CometChatTextFormatter> get formatters => _formatters;

  /// [_currentSearchKeyword] current search keyword for mentions
  String? _currentSearchKeyword;

  /// [_searchKeywordChanged] flag to track if search keyword changed
  bool _searchKeywordChanged = true;

  /// [hasMoreSuggestions] flag to track if there are more suggestions to load
  bool hasMoreSuggestions = true;

  /// [overlayPortalController] controller for the overlay portal showing suggestions
  var overlayPortalController = OverlayPortalController();

  /// [receiverID] the uid of the user or guid of the group
  String receiverID = "";

  /// [receiverType] type of AppEntity
  String receiverType = "";

  //--------------------Configuration Properties-----------------------

  /// [user] user object to send messages to
  final User? user;

  /// [group] group object to send messages to
  final Group? group;

  /// [text] initial text for the input field
  final String? text;

  /// [parentMessageId] parent message id for in thread messages
  int parentMessageId;

  /// [disableSoundForMessages] if true then disables outgoing message sound
  final bool disableSoundForMessages;

  /// [customSoundForMessage] custom outgoing message sound assets url
  final String? customSoundForMessage;

  /// [customSoundForMessagePackage] if sending sound url from other package pass package name here
  final String? customSoundForMessagePackage;

  /// [disableTypingEvents] if true then disables is typing indicator
  final bool disableTypingEvents;

  /// [disableMentions] disables mentions in the composer
  final bool disableMentions;

  /// [disableMentionAll] is a boolean which is used to disable @all mentions in groups
  final bool disableMentionAll;

  /// [mentionAllLabel] is the label to display for @all mention (default: localized "Notify All")
  final String? mentionAllLabel;

  /// [mentionAllLabelId] is the ID for @all mention (default: "all")
  final String? mentionAllLabelId;

  /// [enterKeyBehavior] defines what happens when Enter is pressed
  final EnterKeyBehavior enterKeyBehavior;

  /// [enableRichTextEditor] enables/disables rich text formatting
  final bool enableRichTextEditor;

  /// [hideRichTextFormattingOptions] set of format types to hide from toolbar
  final Set<FormatType>? hideRichTextFormattingOptions;

  /// [richTextFormatterStyle] provides style to the rich text formatter
  final CometChatRichTextFormatterStyle? richTextFormatterStyle;

  /// [attachmentOptions] provides custom attachment options for the attachment sheet
  final ComposerActionsBuilder? attachmentOptions;

  /// [hideImageAttachmentOption] hides the image attachment option when true
  final bool hideImageAttachmentOption;

  /// [hideVideoAttachmentOption] hides the video attachment option when true
  final bool hideVideoAttachmentOption;

  /// [hideAudioAttachmentOption] hides the audio attachment option when true
  final bool hideAudioAttachmentOption;

  /// [hideFileAttachmentOption] hides the file attachment option when true
  final bool hideFileAttachmentOption;

  /// [hidePollsOption] hides the polls option when true
  final bool hidePollsOption;

  /// [hideCollaborativeDocumentOption] hides the collaborative document option when true
  final bool hideCollaborativeDocumentOption;

  /// [hideCollaborativeWhiteboardOption] hides the collaborative whiteboard option when true
  final bool hideCollaborativeWhiteboardOption;

  /// [hideTakePhotoOption] hides the take photo option when true
  final bool hideTakePhotoOption;

  /// [hideStickersButton] hides the stickers button when true
  final bool hideStickersButton;

  /// [attachmentOptionSheetStyle] provides custom styling for the attachment option sheet
  final CometChatAttachmentOptionSheetStyle? attachmentOptionSheetStyle;

  /// [textFormatters] list of text formatters for processing input text
  /// _Requirements: 5.1, 5.2_
  final List<CometChatTextFormatter>? textFormatters;

  /// [mentionsStyle] style for the mentions in the composer
  final CometChatMentionsStyle? mentionsStyle;

  /// [suggestionListStyle] style for the suggestion list
  final CometChatSuggestionListStyle? suggestionListStyle;

  //--------------------Callbacks-----------------------

  /// [stateCallBack] retrieves the state of the composer
  final void Function(CometChatCompactMessageComposerController)? stateCallBack;

  /// [onSendButtonTap] callback when send button is tapped
  final Function(BuildContext, BaseMessage, PreviewMessageMode?)?
      onSendButtonTap;

  /// [onError] callback triggered in case any error happens
  final OnError? onError;

  /// [onToolbarVisibilityChange] callback when toolbar visibility changes
  final void Function(bool isVisible)? onToolbarVisibilityChange;

  /// [onMentionLimitReached] callback when mention limit is exceeded
  final void Function(int limit)? onMentionLimitReached;

  /// [onEditCancel] callback when edit mode is cancelled
  final void Function()? onEditCancel;

  /// [onChange] callback when text changes
  final void Function(CometChatCompactMessageComposerController)? onChange;

  //--------------------Internal State-----------------------

  /// Counter for unique tag generation
  static int counter = 0;

  /// Unique tag for this controller instance
  late String tag;

  /// Date string for listener registration
  late String _dateString;

  /// Listener IDs
  late String _uiMessageListener;
  late String _uiEventListener;
  late String _streamCallbackListenerId;

  /// Debouncer for typing events
  final _deBouncer = Debouncer(milliseconds: 1000);

  /// Flag to track if we created the text controller
  bool _isMyController = true;

  /// Flag to track if we created the focus node
  final bool _isMyFocusNode = true;

  /// Composer ID for event filtering
  Map<String, dynamic> composerId = {};

  /// [_actionItems] list of attachment options to show in the attachment sheet
  final List<ActionItem> _actionItems = [];

  /// [_actionStyle] style for the attachment option sheet
  CometChatAttachmentOptionSheetStyle? _actionStyle;

  /// [_attachmentOptionsInitialized] flag to track if attachment options have been initialized
  bool _attachmentOptionsInitialized = false;

  /// [auxiliaryOptions] provides auxiliary options (stickers, etc.) to the composer
  Widget? auxiliaryOptions;

  /// [auxiliaryButtonIconColor] provides color to the auxiliary button icon
  Color? auxiliaryButtonIconColor;

  /// [_auxiliaryOptionsInitialized] flag to track if auxiliary options have been initialized
  bool _auxiliaryOptionsInitialized = false;

  /// [header] widget to display above the composer (set via showPanel)
  Widget? header;

  /// [footer] widget to display below the composer (set via showPanel, e.g., sticker keyboard)
  Widget? footer;

  /// [preview] widget to display in the preview area (set via showPanel)
  Widget? preview;

  /// [_context] stores the build context for panel rendering
  BuildContext? _context;

  /// [_richTextController] reference to the RichTextEditingController when rich text is enabled
  RichTextEditingController? _richTextController;

  /// Saved mention data for restoring when inline code is removed.
  /// Each entry stores: position → (mentionText, user)
  List<_SavedMention>? _savedMentionsForInlineCode;

  /// [_segmentedController] manages segmented composer with code block support
  SegmentedComposerController? _segmentedController;

  /// Returns true if segmented mode is active (has code blocks)
  bool get isSegmentedMode => _segmentedController != null && _segmentedController!.hasCodeBlocks;

  /// Gets the segmented composer controller
  SegmentedComposerController? get segmentedController => _segmentedController;

  //--------------------Lifecycle Methods-----------------------

  @override
  void onInit() {
    if (textEditingController != null) {
      _isMyController = false;
    }

    _populateComposerId();

    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _uiMessageListener = "${_dateString}UI_message_listener";
    _uiEventListener = "${_dateString}UI_event_listener";
    _streamCallbackListenerId = "${_dateString}UI_streamCallback_listener";

    // Initialize suggestion list streams for mentions
    // _Requirements: 5.1, 5.2_
    _suggestionListStream = _suggestionListController.stream;
    _previousTextStream = _previousTextController.stream;

    // Subscribe to suggestion list stream
    _suggestionSubscription =
        _suggestionListStream.listen((List<SuggestionListItem> value) {
      _handleSuggestionListUpdate(value);
    });

    // Subscribe to previous text stream
    _previousTextStream.listen((String value) {
      _previousText = value;
    });

    // Initialize text formatters including mentions formatter
    _initializeFormatters();

    // Use RichTextEditingController when rich text editing is enabled
    if (textEditingController == null) {
      if (enableRichTextEditor) {
        final richController = RichTextEditingController(
          text: text,
          formatters: _formatters,
          richTextStyle: richTextFormatterStyle,
        );
        textEditingController = richController;
        _richTextController = richController;
      } else {
        textEditingController = CustomTextEditingController(text: text, formatters: _formatters);
      }
    } else if (textEditingController is RichTextEditingController) {
      _richTextController = textEditingController as RichTextEditingController;
    }
    
    // Wire up onLinkLongPress callback for link editing
    // _Requirements: 4.1_
    if (_richTextController != null) {
      _richTextController!.onLinkLongPress = (RichTextSpan linkSpan) {
        if (_context != null) {
          showLinkEditMenu(_context!, linkSpan);
        }
      };
      
      // Wire up onLinkTap callback for link editing when tapping on a link
      _richTextController!.onLinkTap = (RichTextSpan linkSpan) {
        if (_context != null) {
          showLinkEditMenu(_context!, linkSpan);
        }
      };
      
      // Listen to RichTextEditingController changes to update toolbar state
      // This ensures the toolbar reflects the correct active formats when
      // text is modified programmatically (e.g., list continuation on Enter)
      _richTextController!.addListener(_onRichTextControllerChanged);
    }
    
    // Initialize focus node for keyboard navigation
    // _Requirements: 11.2_
    focusNode ??= FocusNode();
    
    // Add focus listener to hide sticker panel when keyboard appears
    focusNode!.addListener(_onFocusChange);

    CometChatMessageEvents.addMessagesListener(_uiMessageListener, this);
    CometChatUIEvents.addUiListener(_uiEventListener, this);
    CometChatUserEvents.addUsersListener(_uiEventListener, this);
    CometChatStreamCallBackEvents.addStreamCallBackListener(
        _streamCallbackListenerId, this);

    if (stateCallBack != null) {
      stateCallBack!(this);
    }

    if (user != null) {
      receiverID = user!.uid;
      receiverType = ReceiverTypeConstants.user;
    } else if (group != null) {
      receiverID = group!.guid;
      receiverType = ReceiverTypeConstants.group;
    }

    _getLoggedInUser();

    super.onInit();
  }

  @override
  void onClose() {
    if (_isMyController) {
      textEditingController?.dispose();
    } else {
      // Remove listener if we didn't create the controller
      _richTextController?.removeListener(_onRichTextControllerChanged);
    }
    if (_isMyFocusNode) {
      focusNode?.removeListener(_onFocusChange);
      focusNode?.dispose();
    }
    // Dispose segmented controller if it exists
    if (_segmentedController != null) {
      _segmentedController!.removeListener(_onSegmentedControllerChanged);
      _segmentedController!.dispose();
      _segmentedController = null;
    }
    _segmentPreviousTexts.clear();
    _suggestionSubscription.cancel();
    _suggestionListController.close();
    _previousTextController.close();
    CometChatMessageEvents.removeMessagesListener(_uiMessageListener);
    CometChatUIEvents.removeUiListener(_uiEventListener);
    CometChatUserEvents.removeUsersListener(_uiEventListener);
    CometChatStreamCallBackEvents.removeStreamCallBackListener(
        _streamCallbackListenerId);
    super.onClose();
  }
  
  /// Callback for RichTextEditingController changes.
  /// Updates the UI when text is modified programmatically.
  /// Also notifies formatters to preserve mention tracking when text is modified
  /// by formatting operations (e.g., adding blockquote prefix).
  /// 
  /// Additionally, updates the mentions formatter's enabled state based on
  /// the current active format (code block/inline code disables mentions).
  /// _Requirements: 2.5, 2.6, 2.7_
  void _onRichTextControllerChanged() {
    // Get the current text
    final currentText = textEditingController?.text ?? '';
    
    // Only notify formatters if the text actually changed
    // This prevents unnecessary processing when only selection changes
    if (currentText != _previousText) {
      // Notify formatters of the text change to update mention tracking
      // This is important when formatting operations modify the text
      // (e.g., adding "> " prefix for blockquote)
      _notifyFormattersOnChange();
      
      // Update _previousText to reflect the new text state
      _previousText = currentText;
    }
    
    // Update mentions formatter enabled state based on active format
    // This ensures mentions are disabled when code block or inline code is active
    _updateMentionsFormatterState();
    
    update();
  }
  
  /// Updates the mentions formatter's enabled state based on the current
  /// mentionsEnabled property.
  /// 
  /// This method should be called whenever the active format changes to ensure
  /// the mentions formatter respects the code block/inline code state.
  /// 
  /// _Requirements: 2.5, 2.6, 2.7_
  void _updateMentionsFormatterState() {
    final mentionFormatter = _formatters.whereType<CometChatMentionsFormatter>().firstOrNull;
    if (mentionFormatter != null) {
      mentionFormatter.setMentionsEnabled(mentionsEnabled);
    }
  }

  //--------------------Public Methods-----------------------

  /// Returns true if the text field has any text content.
  ///
  /// Used to determine whether to show/hide the voice recording button.
  /// When text is present, the mic button should be hidden.
  bool get hasText {
    // In segmented mode, check if any segment has content
    if (isSegmentedMode) {
      return _segmentedController!.hasSegmentContent;
    }
    final currentText = textEditingController?.text ?? '';
    return currentText.isNotEmpty;
  }

  /// Returns true if the send button should be enabled.
  ///
  /// The send button is enabled when:
  /// - The text contains at least one non-whitespace character (excluding formatting prefixes) AND
  /// - Either not in edit mode OR the text differs from the original message
  ///
  /// _Requirements: 3.1, 3.2, 3.5_
  bool get isSendButtonEnabled {
    // In segmented mode, check if any segment has content
    if (isSegmentedMode) {
      return _segmentedController!.hasSegmentContent;
    }
    
    final currentText = textEditingController?.text ?? '';
    final hasActualContent = _hasActualContent(currentText);

    if (!hasActualContent) {
      return false;
    }

    // In edit mode, check if text has changed
    if (previewMessageMode == PreviewMessageMode.edit && oldMessage != null) {
      if (oldMessage is TextMessage) {
        final originalText = (oldMessage as TextMessage).text;
        // When using RichTextEditingController, compare markdown representation
        // to detect formatting changes (e.g., applying bold to plain text)
        final currentMarkdown = _richTextController?.toMarkdown() ?? currentText;
        return currentMarkdown != originalText;
      }
    }

    return true;
  }

  /// Checks if the text has actual content beyond formatting prefixes.
  ///
  /// This method strips line-level formatting prefixes (block quote, bullet list,
  /// ordered list) from each line and checks if there's any remaining content.
  /// This prevents the send button from being enabled when only formatting
  /// prefixes are present without actual user content.
  ///
  /// _Requirements: 3.1_
  bool _hasActualContent(String text) {
    if (text.isEmpty) return false;

    final lines = text.split('\n');
    for (final line in lines) {
      final strippedLine = _stripFormattingPrefixes(line);
      if (strippedLine.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Strips formatting prefixes from a single line of text.
  ///
  /// Handles:
  /// - Block quote prefix: "> "
  /// - Bullet list prefix: "- "
  /// - Ordered list prefix: "N. " (where N is a number)
  /// - Nested formats: "> - " or "> N. "
  String _stripFormattingPrefixes(String line) {
    String result = line;

    // Strip block quote prefix
    if (result.startsWith('> ')) {
      result = result.substring(2);
    }

    // Strip bullet list prefix
    if (result.startsWith('- ')) {
      result = result.substring(2);
    }

    // Strip ordered list prefix (e.g., "1. ", "10. ")
    final orderedListMatch = RegExp(r'^\d+\. ').firstMatch(result);
    if (orderedListMatch != null) {
      result = result.substring(orderedListMatch.end);
    }

    return result;
  }

  /// Toggles the visibility of the rich text toolbar.
  ///
  /// Invokes [onToolbarVisibilityChange] callback with the new visibility state.
  ///
  /// _Requirements: 2.1, 12.2_
  void toggleToolbar() {
    isToolbarVisible = !isToolbarVisible;
    onToolbarVisibilityChange?.call(isToolbarVisible);
    update();
  }

  /// Gets the mentions limit from the mentions formatter.
  ///
  /// Returns the configured limit or default value of 10.
  int get mentionsLimit {
    final mentionFormatter = _formatters.whereType<CometChatMentionsFormatter>().firstOrNull;
    return mentionFormatter?.mentionsLimit ?? 10;
  }

  /// Applies the specified format to the selected text.
  ///
  /// If using RichTextEditingController, activates the format for subsequent typing.
  /// If text is selected, wraps it with the format markers.
  /// If no text is selected, toggles the format for subsequent input.
  ///
  /// _Requirements: 2.3, 2.4_
  void applyFormat(FormatType formatType) {
    if (_richTextController != null) {
      // Use WYSIWYG formatting - activate the format
      _richTextController!.activateFormat(formatType);
      
      // Hide suggestion list if it's showing (formatting may have removed '@')
      _hideSuggestionListIfMentionTrackerInvalid();
      
      requestFocus();
      update();
      return;
    }
    
    // Fallback to markdown-based formatting
    if (textEditingController == null) return;

    final text = textEditingController!.text;
    final selection = textEditingController!.selection;

    final result = RichTextFormatterManager.applyFormat(
      text: text,
      selectionStart: selection.start,
      selectionEnd: selection.end,
      formatType: formatType,
    );

    // Use value to set text and selection atomically to preserve cursor position
    textEditingController!.value = TextEditingValue(
      text: result.text,
      selection: TextSelection(
        baseOffset: result.newCursorStart,
        extentOffset: result.newCursorEnd,
      ),
    );

    // Hide suggestion list if it's showing (formatting may have removed '@')
    _hideSuggestionListIfMentionTrackerInvalid();

    // Update active formats
    _activeFormats.clear();
    _activeFormats.addAll(RichTextFormatterManager.detectActiveFormats(
      result.text,
      result.newCursorEnd,
    ));

    // Request focus back to the text field so user can continue typing
    requestFocus();

    update();
  }

  /// Removes the specified format from the selected text.
  ///
  /// If using RichTextEditingController, deactivates the format.
  ///
  /// _Requirements: 2.9_
  void removeFormat(FormatType formatType) {
    if (_richTextController != null) {
      // Use WYSIWYG formatting - deactivate the format
      _richTextController!.deactivateFormat(formatType);
      
      // Hide suggestion list if it's showing (formatting may have removed '@')
      _hideSuggestionListIfMentionTrackerInvalid();
      
      requestFocus();
      update();
      return;
    }
    
    // Fallback to markdown-based formatting
    if (textEditingController == null) return;

    final text = textEditingController!.text;
    final selection = textEditingController!.selection;

    final result = RichTextFormatterManager.removeFormat(
      text: text,
      selectionStart: selection.start,
      selectionEnd: selection.end,
      formatType: formatType,
    );

    // Use value to set text and selection atomically to preserve cursor position
    textEditingController!.value = TextEditingValue(
      text: result.text,
      selection: TextSelection(
        baseOffset: result.newCursorStart,
        extentOffset: result.newCursorEnd,
      ),
    );

    // Hide suggestion list if it's showing (formatting may have removed '@')
    _hideSuggestionListIfMentionTrackerInvalid();

    // Update active formats
    _activeFormats.clear();
    _activeFormats.addAll(RichTextFormatterManager.detectActiveFormats(
      result.text,
      result.newCursorEnd,
    ));

    // Request focus back to the text field so user can continue typing
    requestFocus();

    update();
  }

  /// Toggles the specified format on the selected text.
  ///
  /// If using RichTextEditingController, delegates to its toggleFormat method
  /// which handles WYSIWYG formatting without visible markers.
  ///
  /// If the selected text already has the format, removes it.
  /// Otherwise, applies the format.
  ///
  /// For link format, shows a dialog to input text and URL.
  /// For code block format, uses the segmented composer controller.
  void toggleFormat(FormatType formatType) {
    // Handle link format specially - show dialog
    if (formatType == FormatType.link) {
      _showLinkDialog();
      return;
    }
    
    // Handle code block format with segmented composer
    if (formatType == FormatType.codeBlock) {
      _toggleCodeBlock();
      return;
    }
    
    // If in segmented mode and focused on a code segment, handle specially
    if (isSegmentedMode) {
      final focused = _segmentedController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.code) {
        // For list/blockquote formats, convert code segment to normal and apply format
        if (formatType == FormatType.bulletList || 
            formatType == FormatType.orderedList || 
            formatType == FormatType.blockquote) {
          _convertCodeSegmentToNormalWithFormat(formatType);
          return;
        }
        // Other formatting is blocked inside code segments
        return;
      }
      // Apply format to the focused normal segment
      if (focused != null && focused.controller is RichTextEditingController) {
        // Handle inline code toggle with mention save/restore
        if (formatType == FormatType.inlineCode) {
          final rtc = focused.controller as RichTextEditingController;
          final sel = rtc.selection;
          if (!sel.isCollapsed) {
            final isRemoving = rtc.hasFormatInRange(sel.start, sel.end, FormatType.inlineCode);
            if (isRemoving) {
              _restoreMentionsInSelection(focused.controller);
            } else {
              _saveMentionsInSelection(focused.controller);
              _clearMentionsInSelection(focused.controller);
            }
          }
        }
        (focused.controller as RichTextEditingController).toggleFormat(formatType);
        _hideSuggestionListIfMentionTrackerInvalid();
        // Update mentions formatter state based on new active format
        // _Requirements: 2.5, 2.6, 2.7_
        _updateMentionsFormatterState();
        update();
        return;
      }
    }
    
    if (_richTextController != null) {
      // Handle inline code toggle with mention save/restore
      if (formatType == FormatType.inlineCode) {
        final sel = _richTextController!.selection;
        if (!sel.isCollapsed) {
          final isRemoving = _richTextController!.hasFormatInRange(sel.start, sel.end, FormatType.inlineCode);
          if (isRemoving) {
            _restoreMentionsInSelection(_richTextController!);
          } else {
            _saveMentionsInSelection(_richTextController!);
            _clearMentionsInSelection(_richTextController!);
          }
        }
      }
      
      // Use WYSIWYG formatting via RichTextEditingController
      _richTextController!.toggleFormat(formatType);
      
      // Hide suggestion list if it's showing (formatting may have removed '@')
      _hideSuggestionListIfMentionTrackerInvalid();
      
      // Update mentions formatter state based on new active format
      // This ensures mentions are disabled when code block or inline code is active
      // _Requirements: 2.5, 2.6, 2.7_
      _updateMentionsFormatterState();
      
      // Request focus back to the text field so user can continue typing
      requestFocus();
      update();
      return;
    }
    
    // Fallback to markdown-based formatting
    if (textEditingController == null) return;

    final text = textEditingController!.text;
    final selection = textEditingController!.selection;

    final result = RichTextFormatterManager.toggleFormat(
      text: text,
      selectionStart: selection.start,
      selectionEnd: selection.end,
      formatType: formatType,
    );

    // Use value to set text and selection atomically to preserve cursor position
    textEditingController!.value = TextEditingValue(
      text: result.text,
      selection: TextSelection(
        baseOffset: result.newCursorStart,
        extentOffset: result.newCursorEnd,
      ),
    );

    // Hide suggestion list if it's showing (formatting may have removed '@')
    _hideSuggestionListIfMentionTrackerInvalid();

    // Update active formats
    _activeFormats.clear();
    _activeFormats.addAll(RichTextFormatterManager.detectActiveFormats(
      result.text,
      result.newCursorEnd,
    ));

    // Request focus back to the text field so user can continue typing
    requestFocus();

    update();
  }

  /// Toggles code block mode using the segmented composer.
  /// 
  /// If not in segmented mode, initializes the segmented controller and
  /// transfers the current text to it.
  void _toggleCodeBlock() {
    // Initialize segmented controller if needed
    if (_segmentedController == null) {
      // Get the markdown text and selection from the current controller
      // Use markdown to preserve formatting (bold, italic, mentions, etc.)
      String initialMarkdown = '';
      TextSelection selection = const TextSelection.collapsed(offset: 0);
      if (_richTextController != null) {
        initialMarkdown = _richTextController!.toMarkdown();
        selection = _richTextController!.selection;
      } else if (textEditingController != null) {
        initialMarkdown = textEditingController!.text;
        selection = textEditingController!.selection;
      }
      
      _segmentedController = SegmentedComposerController(
        formatters: _formatters,
        richTextStyle: richTextFormatterStyle,
        initialMarkdown: initialMarkdown,
      );
      
      // Listen to segmented controller changes
      _segmentedController!.addListener(_onSegmentedControllerChanged);
      
      // Initialize segment previous texts for mention tracking
      _segmentPreviousTexts.clear();
      for (final segment in _segmentedController!.segments) {
        _segmentPreviousTexts[segment.id] = segment.text;
      }
      
      // Request focus on the first segment and set selection
      if (_segmentedController!.segments.isNotEmpty) {
        final firstSegment = _segmentedController!.segments.first;
        // Set the selection - note that markdown conversion may change text length
        // so we need to clamp the selection to the new text length
        final textLength = firstSegment.text.length;
        final safeSelection = TextSelection(
          baseOffset: selection.baseOffset.clamp(0, textLength),
          extentOffset: selection.extentOffset.clamp(0, textLength),
        );
        firstSegment.controller.selection = safeSelection;
        // Set last focused segment so focusedSegment returns it even before focus is processed
        _segmentedController!.setLastFocusedSegment(firstSegment);
        firstSegment.focusNode.requestFocus();
      }
    } else if (!isSegmentedMode) {
      // Segmented controller exists but not in segmented mode (no code blocks)
      // This means we removed a code block and are now adding a new one
      // We need to sync both the text content and selection from the 
      // rich text controller to the segmented controller's first segment
      // Use markdown to preserve formatting
      String currentMarkdown = '';
      TextSelection selection = const TextSelection.collapsed(offset: 0);
      if (_richTextController != null) {
        currentMarkdown = _richTextController!.toMarkdown();
        selection = _richTextController!.selection;
      } else if (textEditingController != null) {
        currentMarkdown = textEditingController!.text;
        selection = textEditingController!.selection;
      }
      
      // Update the text and selection in the segmented controller's first segment
      if (_segmentedController!.segments.isNotEmpty) {
        final firstSegment = _segmentedController!.segments.first;
        if (firstSegment.type == SegmentType.normal) {
          // Sync the text content from rich text controller (with markdown formatting)
          if (firstSegment.controller is RichTextEditingController) {
            (firstSegment.controller as RichTextEditingController).loadMarkdown(currentMarkdown);
          } else {
            firstSegment.controller.text = currentMarkdown;
          }
          // Set selection after text update - note that markdown conversion may change text length
          final textLength = firstSegment.text.length;
          final safeSelection = TextSelection(
            baseOffset: selection.baseOffset.clamp(0, textLength),
            extentOffset: selection.extentOffset.clamp(0, textLength),
          );
          firstSegment.controller.selection = safeSelection;
          // Set last focused segment so focusedSegment returns it even before focus is processed
          _segmentedController!.setLastFocusedSegment(firstSegment);
          firstSegment.focusNode.requestFocus();
        }
      }
    }
    
    // Toggle code block
    _segmentedController!.toggleCodeBlock();
    
    update();
  }

  /// Converts a code segment to a normal segment and applies the specified format.
  /// 
  /// This is called when the user clicks on bullet list, ordered list, or blockquote
  /// while focused on a code segment. Only the current line is extracted from the
  /// code block and converted to the selected format. The rest of the text remains
  /// in code blocks.
  void _convertCodeSegmentToNormalWithFormat(FormatType formatType) {
    if (_segmentedController == null) return;
    
    final focused = _segmentedController!.focusedSegment;
    if (focused == null || focused.type != SegmentType.code) return;
    
    // Extract only the current line from the code segment
    final extractedSegment = _segmentedController!.extractLineFromCodeSegment(focused);
    
    if (extractedSegment != null && extractedSegment.controller is RichTextEditingController) {
      // Apply the format to the extracted line
      (extractedSegment.controller as RichTextEditingController).toggleFormat(formatType);
    }
    
    _hideSuggestionListIfMentionTrackerInvalid();
    _updateMentionsFormatterState();
    update();
  }

  /// Called when the segmented controller changes.
  void _onSegmentedControllerChanged() {
    update();
  }

  /// Initializes the segmented controller for editing a message with code blocks.
  /// 
  /// This parses the markdown text and creates appropriate segments for
  /// normal text and code blocks.
  void _initializeSegmentedControllerForEdit(
    String markdownText,
    int mentionFormatterIndex,
    List<User> mentionedUsers,
  ) {
    // Dispose existing segmented controller if any
    if (_segmentedController != null) {
      _segmentedController!.removeListener(_onSegmentedControllerChanged);
      _segmentedController!.dispose();
    }
    
    // Create new segmented controller
    _segmentedController = SegmentedComposerController(
      formatters: _formatters,
      richTextStyle: richTextFormatterStyle,
    );
    
    // Load the markdown with code blocks
    _segmentedController!.loadFromMarkdown(markdownText);
    
    // Listen to changes
    _segmentedController!.addListener(_onSegmentedControllerChanged);
    
    // Update previous text for change detection
    _previousText = _segmentedController!.plainText;
    
    // Initialize segment previous texts for mention tracking
    // Each segment tracks its own previous text for mention detection
    _segmentPreviousTexts.clear();
    for (final segment in _segmentedController!.segments) {
      _segmentPreviousTexts[segment.id] = segment.text;
    }
    
    // Set up mention tracking for each normal segment
    // The mentions formatter uses trackedMentionPositions to style mentions
    if (mentionFormatterIndex != -1) {
      final mentionsFormatter = _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;
      
      // Set the mentioned users so the formatter knows about them
      if (mentionedUsers.isNotEmpty) {
        mentionsFormatter.setMentionedUsers(mentionedUsers);
      }
      
      // For each normal segment, set up mention tracking
      for (final segment in _segmentedController!.segments) {
        if (segment.type == SegmentType.normal) {
          final segmentText = segment.text;
          
          // Find @all mentions in this segment
          final allLabel = mentionAllLabel ?? '@all';
          int searchStart = 0;
          while (true) {
            int pos = segmentText.indexOf(allLabel, searchStart);
            if (pos == -1) break;
            
            mentionsFormatter.trackedMentionPositions[pos] = allLabel;
            if (!mentionsFormatter.mentionAllPositions.contains(allLabel)) {
              mentionsFormatter.mentionAllPositions.add(allLabel);
            }
            
            if (mentionsFormatter.mentionTextToPositions.containsKey(allLabel)) {
              mentionsFormatter.mentionTextToPositions[allLabel]!.add(pos);
            } else {
              mentionsFormatter.mentionTextToPositions[allLabel] = [pos];
            }
            
            searchStart = pos + allLabel.length;
          }
          
          // Find user mentions in this segment
          for (var user in mentionedUsers) {
            final mention = '@${user.name}';
            searchStart = 0;
            
            while (true) {
              int pos = segmentText.indexOf(mention, searchStart);
              if (pos == -1) break;
              
              mentionsFormatter.trackedMentionPositions[pos] = mention;
              
              if (mentionsFormatter.mentionTextToPositions.containsKey(mention)) {
                mentionsFormatter.mentionTextToPositions[mention]!.add(pos);
              } else {
                mentionsFormatter.mentionTextToPositions[mention] = [pos];
              }
              
              if (!mentionsFormatter.mentionCount.contains(user.uid)) {
                mentionsFormatter.mentionCount.add(user.uid);
              }
              
              searchStart = pos + mention.length;
            }
          }
          
          // Update the formatter's previous text to match this segment
          mentionsFormatter.updatePreviousText(segmentText);
        }
      }
    }
    
    update();
  }

  /// Handles backspace key event for segmented composer.
  /// Returns true if handled, false otherwise.
  bool handleSegmentedBackspace() {
    if (_segmentedController == null) return false;
    
    final focused = _segmentedController!.focusedSegment;
    if (focused == null) return false;
    
    if (focused.type == SegmentType.code && focused.isEmpty) {
      return _segmentedController!.handleBackspaceOnEmptyCodeBlock();
    }
    
    if (focused.type == SegmentType.normal && focused.isEmpty) {
      return _segmentedController!.handleBackspaceOnEmptyNormalSegment();
    }
    
    return false;
  }

  /// Shows the link dialog for inserting a link.
  ///
  /// The dialog has two fields:
  /// - Text (optional): The display text for the link
  /// - Link (required): The URL
  ///
  /// If text is provided, the link will be displayed as the text.
  /// If only URL is provided, the URL itself will be displayed.
  void _showLinkDialog() {
    if (_context == null) return;
    
    // Save the current selection/cursor position before showing dialog
    // because the text field will lose focus when dialog opens
    final savedSelection = textEditingController?.selection;
    final savedText = textEditingController?.text ?? '';
    
    // Get selected text to pre-populate the text field
    String? selectedText;
    if (savedSelection != null && 
        !savedSelection.isCollapsed &&
        savedSelection.start >= 0 &&
        savedSelection.end <= savedText.length) {
      selectedText = savedText.substring(savedSelection.start, savedSelection.end);
    }

    // Check if the selection already contains a link — if so, open edit dialog
    if (selectedText != null && selectedText.isNotEmpty) {
      RichTextEditingController? rtc;
      if (isSegmentedMode) {
        final focused = _segmentedController!.focusedSegment;
        if (focused != null && focused.controller is RichTextEditingController) {
          rtc = focused.controller as RichTextEditingController;
        }
      } else {
        rtc = _richTextController;
      }
      if (rtc != null && savedSelection != null) {
        final linkSpan = rtc.getLinkSpanAtPosition(savedSelection.start);
        if (linkSpan != null &&
            linkSpan.start <= savedSelection.start &&
            linkSpan.end >= savedSelection.end) {
          final displayText = savedText.substring(
            linkSpan.start.clamp(0, savedText.length),
            linkSpan.end.clamp(0, savedText.length),
          );
          _showLinkDialogForEdit(linkSpan, displayText, linkSpan.url ?? '');
          return;
        }
      }
    }
    
    CometChatLinkDialog(
      context: _context!,
      initialText: selectedText,
      onDone: (result) {
        // Restore the selection before inserting the link
        if (savedSelection != null && textEditingController != null) {
          textEditingController!.selection = savedSelection;
        }
        _insertLink(displayText: result.text, url: result.url);
      },
      onCancel: () {
        // Request focus back to the text field
        requestFocus();
      },
    ).show();
  }

  /// Shows a bottom sheet with Edit/Remove options for a link span.
  ///
  /// This is called when a user long-presses on a link in the input field.
  /// The dialog displays:
  /// - Header: "Link"
  /// - The link URL in primary color
  /// - Two buttons: "Edit" and "Remove" (Remove has red background)
  ///
  /// _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  void showLinkEditMenu(BuildContext context, RichTextSpan linkSpan) {
    final currentText = textEditingController?.text ?? '';
    final displayText = currentText.substring(
      linkSpan.start.clamp(0, currentText.length),
      linkSpan.end.clamp(0, currentText.length),
    );
    final url = linkSpan.url ?? '';

    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: colorPalette.borderLight ?? Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(spacing.radius4 ?? 16),
          ),
        ),
        backgroundColor: colorPalette.background1,
        insetPadding: EdgeInsets.symmetric(
          horizontal: spacing.margin4 ?? 16,
          vertical: spacing.margin4 ?? 16,
        ),
        titlePadding: EdgeInsets.only(
          left: spacing.padding5 ?? 20,
          right: spacing.padding5 ?? 20,
          top: spacing.padding5 ?? 20,
          bottom: spacing.padding3 ?? 12,
        ),
        contentPadding: EdgeInsets.only(
          left: spacing.padding5 ?? 20,
          right: spacing.padding5 ?? 20,
          bottom: spacing.padding3 ?? 12,
        ),
        actionsPadding: EdgeInsets.only(
          left: spacing.padding5 ?? 20,
          right: spacing.padding5 ?? 20,
          bottom: spacing.padding5 ?? 20,
        ),
        title: Text(
          'Link',
          style: TextStyle(
            fontSize: typography.heading3?.medium?.fontSize,
            fontWeight: typography.heading3?.medium?.fontWeight,
            fontFamily: typography.heading3?.medium?.fontFamily,
            color: colorPalette.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Link URL in primary color
            Text(
              url,
              style: TextStyle(
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
                color: colorPalette.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              // Edit button
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showLinkDialogForEdit(linkSpan, displayText, url);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: colorPalette.borderDark ?? Colors.transparent,
                        width: 1,
                      ),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        horizontal: spacing.padding4 ?? 16,
                        vertical: spacing.padding2 ?? 8,
                      ),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: typography.button?.medium?.fontSize,
                      fontWeight: typography.button?.medium?.fontWeight,
                      fontFamily: typography.button?.medium?.fontFamily,
                      color: colorPalette.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing.padding2 ?? 8),
              // Remove button with red background
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _richTextController?.removeLink(linkSpan.start, linkSpan.end);
                    update();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(colorPalette.error),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        horizontal: spacing.padding4 ?? 16,
                        vertical: spacing.padding2 ?? 8,
                      ),
                    ),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: typography.button?.medium?.fontSize,
                      fontWeight: typography.button?.medium?.fontWeight,
                      fontFamily: typography.button?.medium?.fontFamily,
                      color: colorPalette.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows the link dialog pre-populated with existing link data for editing.
  ///
  /// _Requirements: 4.3_
  void _showLinkDialogForEdit(RichTextSpan linkSpan, String displayText, String url) {
    if (_context == null) return;

    CometChatLinkDialog(
      context: _context!,
      initialText: displayText,
      initialUrl: url,
      isEditing: true,
      onDone: (result) {
        // Remove the old link and insert the new one
        _richTextController?.removeLink(linkSpan.start, linkSpan.end);
        
        // Set cursor position to the start of the old link
        textEditingController?.selection = TextSelection.collapsed(offset: linkSpan.start);
        
        // Delete the old text
        final currentText = textEditingController?.text ?? '';
        final newText = currentText.substring(0, linkSpan.start) +
            currentText.substring(linkSpan.end);
        textEditingController?.text = newText;
        textEditingController?.selection = TextSelection.collapsed(offset: linkSpan.start);
        
        // Insert the new link
        _insertLink(displayText: result.text, url: result.url);
      },
      onCancel: () {
        requestFocus();
      },
    ).show();
  }

  /// Inserts a link at the current cursor position or replaces selected text.
  ///
  /// If [displayText] is provided, the link will be displayed as the text.
  /// If [displayText] is null, the URL itself will be displayed.
  void _insertLink({String? displayText, required String url}) {
    if (_richTextController != null) {
      // Use WYSIWYG formatting via RichTextEditingController
      _richTextController!.insertLink(displayText: displayText, url: url);
      // Request focus back to the text field so user can continue typing
      requestFocus();
      update();
      return;
    }
    
    // Fallback to markdown-based formatting
    if (textEditingController == null) return;

    final text = textEditingController!.text;
    final selection = textEditingController!.selection;
    
    // Create the markdown link
    final linkText = displayText ?? url;
    final markdownLink = '[$linkText]($url)';
    
    String newText;
    int newCursorPosition;
    
    if (selection.isCollapsed) {
      // No selection - insert at cursor position
      newText = text.substring(0, selection.baseOffset) + 
                markdownLink + 
                text.substring(selection.baseOffset);
      newCursorPosition = selection.baseOffset + markdownLink.length;
    } else {
      // Has selection - replace selected text
      newText = text.substring(0, selection.start) + 
                markdownLink + 
                text.substring(selection.end);
      newCursorPosition = selection.start + markdownLink.length;
    }

    // Use value to set text and selection atomically to preserve cursor position
    textEditingController!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );

    // Request focus back to the text field so user can continue typing
    requestFocus();

    update();
  }

  /// Handles the send button click.
  ///
  /// Creates and sends a TextMessage via CometChat SDK.
  /// In edit mode, updates the existing message instead of creating a new one.
  /// In reply mode, sets the parentMessageId on the new message.
  /// Clears the text input field after sending.
  /// Plays sound if not disabled.
  /// Invokes onSendButtonTap callback if provided.
  ///
  /// _Requirements: 3.3, 3.4_
  void onSendButtonClick(BuildContext context) {
    // Block sending while AI agent is streaming a response
    final isAiBusy = isUserAgentic() && isActiveStreaming;
    if (isAiBusy) {
      return;
    }
    
    // In segmented mode, check segmented controller for content
    if (isSegmentedMode) {
      if (!_segmentedController!.hasContent) return;
    } else {
      if (textEditingController == null) return;
      final text = textEditingController!.text;
      if (text.trim().isEmpty) return;
    }
    
    if (previewMessageMode == PreviewMessageMode.edit) {
      _editTextMessage(context);
    } else if (previewMessageMode == PreviewMessageMode.reply) {
      _sendTextMessage(context, metadata: {"reply-message": quotedMessage?.toJson()});
    } else {
      _sendTextMessage(context);
    }
  }

  /// Sends a new text message via CometChat SDK.
  ///
  /// If in reply mode, includes the quoted message reference in the sent message.
  ///
  /// _Requirements: 3.3, 3.4, 13.4_
  void _sendTextMessage(BuildContext context, {Map<String, dynamic>? metadata}) {
    if (textEditingController == null && !isSegmentedMode) return;
    
    // Get the message text - use segmented controller if in segmented mode
    String messagesText;
    if (isSegmentedMode) {
      messagesText = _segmentedController!.segmentFinalText;
      // Convert mentions in the markdown text (segments use toMarkdown which preserves @mentions)
      messagesText = _convertMentionsInMarkdown(messagesText);
    } else if (_richTextController != null) {
      // Get markdown output first
      messagesText = _richTextController!.toMarkdown();
      // Then convert mentions in the markdown text by searching for mention text
      messagesText = _convertMentionsInMarkdown(messagesText);
    } else {
      messagesText = textEditingController!.text;
    }

    // Replace emoji characters inside inline code and code blocks with their
    // Unicode code point representation so they are shown as codes, not glyphs.
    messagesText = _replaceEmojisInCodeRegions(messagesText);
    
    TextMessage textMessage = TextMessage(
      sender: loggedInUser,
      text: messagesText,
      receiverUid: receiverID,
      receiverType: receiverType,
      type: MessageTypeConstants.text,
      metadata: metadata,
      parentMessageId: parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );
    
    // Include quoted message reference if in reply mode
    // _Requirements: 13.4_
    if (quotedMessage != null) {
      textMessage.quotedMessageId = quotedMessage!.id;
      textMessage.quotedMessage = quotedMessage;
    }
    
    // Process mentions before sending - converts @Name to <@uid:123> format
    // Note: For rich text, mentions are already converted above, but this handles
    // non-rich-text cases and sets mentionedUsers on the message
    _handlePreMessageSend(context, textMessage);
    // Trim leading/trailing whitespace but preserve formatting markers
    // Don't trim if the text ends with a list marker (e.g., "- " or "N. ")
    // as this would break empty list item formatting
    final trimmedText = textMessage.text.trim();
    // Check if trimming would break list formatting (e.g., "- " -> "-")
    if (trimmedText.isNotEmpty && !_wouldBreakListFormatting(textMessage.text, trimmedText)) {
      textMessage.text = trimmedText;
    }
    
    // Store reference to quoted message for event emission after clearing state
    final messageBeingRepliedTo = quotedMessage;
    
    // Clear state before sending
    final currentPreviewMode = previewMessageMode;
    oldMessage = null;
    quotedMessage = null;
    previewMessageMode = PreviewMessageMode.none;
    textEditingController?.clear();
    _previousText = '';
    // Clear rich text formatting state
    _richTextController?.clearFormatting();
    // Clear segmented controller if in segmented mode
    if (_segmentedController != null) {
      _segmentedController!.clearSegments();
      // Dispose and reset segmented controller after clearing
      _segmentedController!.removeListener(_onSegmentedControllerChanged);
      _segmentedController!.dispose();
      _segmentedController = null;
    }
    _segmentPreviousTexts.clear();
    mentionCount = 0;
    update();
    
    // Emit reply event to clear reply preview in other components
    // _Requirements: 13.4_
    if (messageBeingRepliedTo != null) {
      CometChatMessageEvents.ccReplyToMessage(
        messageBeingRepliedTo,
        MessageStatus.sent,
      );
    }
    
    // Invoke callback if provided, otherwise send via SDK
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, textMessage, currentPreviewMode);
    } else {
      CometChatMessageEvents.ccMessageSent(
        textMessage,
        MessageStatus.inProgress,
      );
      
      CometChat.sendMessage(
        textMessage,
        onSuccess: (TextMessage message) {
          debugPrint("Message sent successfully: ${message.text}");
          // For agentic users, thread subsequent messages under the first one
          if (isUserAgentic() && parentMessageId == 0) {
            parentMessageId = message.id;
            message.parentMessageId = parentMessageId;
          }
          _playSound();
          CometChatMessageEvents.ccMessageSent(message, MessageStatus.sent);
        },
        onError: onError ?? (CometChatException e) {
          if (textMessage.metadata != null) {
            textMessage.metadata!["error"] = e;
          } else {
            textMessage.metadata = {"error": e};
          }
          CometChatMessageEvents.ccMessageSent(
            textMessage,
            MessageStatus.error,
          );
          debugPrint("Message sending failed with exception: ${e.message}");
        },
      );
    }
  }

  /// Edits an existing text message via CometChat SDK.
  ///
  /// _Requirements: 6.5_
  void _editTextMessage(BuildContext context) {
    if (oldMessage == null || oldMessage is! TextMessage) return;
    
    // Get the message text - use segmented controller if in segmented mode
    String newText;
    if (isSegmentedMode) {
      newText = _segmentedController!.segmentFinalText;
      // Convert mentions in the markdown text (segments use toMarkdown which preserves @mentions)
      newText = _convertMentionsInMarkdown(newText);
    } else if (_richTextController != null) {
      // Get markdown output first
      newText = _richTextController!.toMarkdown();
      // Then convert mentions in the markdown text by searching for mention text
      newText = _convertMentionsInMarkdown(newText);
    } else {
      if (textEditingController == null) return;
      newText = textEditingController!.text;
    }

    // Replace emoji characters inside inline code and code blocks with their
    // Unicode code point representation so they are shown as codes, not glyphs.
    newText = _replaceEmojisInCodeRegions(newText);

    final originalText = (oldMessage as TextMessage).text;
    
    // Check if there's any meaningful difference
    if (newText.trim() == originalText.trim()) return;
    
    TextMessage editedMessage = oldMessage as TextMessage;
    editedMessage.text = newText;
    
    // Process mentions before sending - converts @Name to <@uid:123> format
    // Note: For rich text, mentions are already converted above, but this handles
    // non-rich-text cases and sets mentionedUsers on the message
    _handlePreMessageSend(context, editedMessage);
    editedMessage.text = editedMessage.text.trim();
    
    // Clear state before sending
    previewMessageMode = PreviewMessageMode.none;
    oldMessage = null;
    quotedMessage = null;
    textEditingController?.clear();
    _previousText = '';
    // Clear rich text formatting state
    _richTextController?.clearFormatting();
    // Clear segmented controller if in segmented mode
    if (_segmentedController != null) {
      _segmentedController!.clearSegments();
      _segmentedController!.removeListener(_onSegmentedControllerChanged);
      _segmentedController!.dispose();
      _segmentedController = null;
    }
    _segmentPreviousTexts.clear();
    mentionCount = 0;
    update();
    
    // Invoke callback if provided, otherwise edit via SDK
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, editedMessage, PreviewMessageMode.edit);
    } else {
      CometChat.editMessage(
        editedMessage,
        onSuccess: (BaseMessage updatedMessage) {
          _playSound();
          CometChatMessageEvents.ccMessageEdited(
            updatedMessage,
            MessageEditStatus.success,
          );
        },
        onError: onError ?? (CometChatException e) {
          if (editedMessage.metadata != null) {
            editedMessage.metadata!["error"] = e;
          } else {
            editedMessage.metadata = {"error": e};
          }
          CometChatMessageEvents.ccMessageSent(
            editedMessage,
            MessageStatus.error,
          );
          debugPrint("Message editing failed with exception: ${e.message}");
        },
      );
    }
  }

  /// Plays sound on message sent if not disabled.
  void _playSound() {
    if (disableSoundForMessages == false) {
      CometChatUIKit.soundManager.play(
        sound: Sound.outgoingMessage,
        customSound: customSoundForMessage,
        packageName: customSoundForMessage == null || customSoundForMessage == ""
            ? UIConstants.packageName
            : customSoundForMessagePackage,
      );
    }
  }

  /// Enters preview mode for editing or replying to a message.
  ///
  /// In edit mode, populates the text field with the original message text
  /// and converts internal mention format to display format.
  ///
  /// _Requirements: 6.1, 6.2, 6.4_
  void previewMessage(BaseMessage message, PreviewMessageMode mode) {
    previewMessageMode = mode;

    if (mode == PreviewMessageMode.edit) {
      oldMessage = message;
      // Populate text field with original message text
      if (message is TextMessage) {
        // Use the formatter's onMessageEdit which handles position tracking
        int mentionFormatterIndex = _formatters
            .indexWhere((element) => element is CometChatMentionsFormatter);

        String editText = message.text;

        // Step 1: Convert mention patterns to display format (@username)
        // Handle @all mentions
        if (mentionAllLabelId != null) {
          String specificPattern = '<@all:$mentionAllLabelId>';
          String replacement = mentionAllLabel ?? '@all';
          editText = editText.replaceAll(specificPattern, replacement);
        }
        editText = editText.replaceAll('<@all:all>', mentionAllLabel ?? '@all');

        // Handle user mentions
        if (message.mentionedUsers.isNotEmpty) {
          editText = CometChatMentionsFormatter.getTextWithMentions(
              editText, message.mentionedUsers);
        }

        // Step 2: Check if the text contains fenced code blocks
        // Match both multi-line (```\ncode\n```) and inline (```code```) code blocks
        final hasCodeBlocks = RegExp(r'```[\s\S]*?```').hasMatch(editText);

        if (hasCodeBlocks) {
          // Use segmented composer for messages with code blocks
          _initializeSegmentedControllerForEdit(editText, mentionFormatterIndex, message.mentionedUsers);
        } else if (_richTextController != null) {
          // No code blocks - use regular RichTextEditingController
          _richTextController!.loadMarkdown(editText);
          _previousText = _richTextController!.text;
          
          // Re-initialize mention tracking on the final text
          if (mentionFormatterIndex != -1) {
            CometChatMentionsFormatter mentionsFormatter =
                _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;
            
            // Clear existing tracking and rebuild based on the final text
            _rebuildMentionTracking(
              mentionsFormatter,
              _richTextController!.text,
              message.mentionedUsers,
            );
            
            // Update the formatter's previous text to match the controller
            mentionsFormatter.updatePreviousText(_richTextController!.text);
          }
        } else {
          // For non-RichTextEditingController, we need to:
          // 1. First let onMessageEdit process the ORIGINAL text with <@uid:xxx> patterns
          // 2. This will convert them to @username and track positions
          
          if (mentionFormatterIndex != -1 && textEditingController != null) {
            CometChatMentionsFormatter mentionsFormatter =
                _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;

            // Set the original text first (with <@uid:xxx> patterns)
            textEditingController?.text = message.text;
            
            // Let the formatter handle the conversion and tracking
            // onMessageEdit expects text with <@uid:xxx> patterns
            mentionsFormatter.onMessageEdit(
              textEditingController!,
              mentionedUsers: message.mentionedUsers,
            );

            // Update _previousText to the converted text
            _previousText = textEditingController!.text;
          } else {
            textEditingController?.text = editText;
            _previousText = editText;
          }
        }
      }
    } else if (mode == PreviewMessageMode.reply) {
      quotedMessage = message;
      
      // Reset _previousText to match the current text field state (empty for reply)
      _previousText = textEditingController?.text ?? '';
    }

    update();
  }
  
  /// Rebuilds mention tracking for the given text after markdown has been stripped.
  ///
  /// This method finds all @username patterns in the text and updates the
  /// mentions formatter's tracking maps to reflect their positions.
  void _rebuildMentionTracking(
    CometChatMentionsFormatter mentionsFormatter,
    String text,
    List<User> mentionedUsers,
  ) {
    // Clear existing tracking but don't send empty list to sink
    // (we don't want to hide the suggestion panel during rebuild)
    mentionsFormatter.mentionCount.clear();
    mentionsFormatter.mentionedUsersMap.clear();
    mentionsFormatter.mentionAllPositions.clear();
    mentionsFormatter.trackedMentionPositions.clear();
    mentionsFormatter.mentionTextToPositions.clear();
    
    // Reset mention tracker state without sending empty list to sink
    mentionsFormatter.mentionTracker = "";
    mentionsFormatter.mentionStartIndex = 0;
    mentionsFormatter.mentionEndIndex = 0;
    mentionsFormatter.listItems.clear();
    
    // Update lastCursorPos to the end of the text
    mentionsFormatter.lastCursorPos = text.length;
    
    // Find @all mentions
    final allLabel = mentionAllLabel ?? '@all';
    int searchStart = 0;
    while (true) {
      int pos = text.indexOf(allLabel, searchStart);
      if (pos == -1) break;
      
      mentionsFormatter.trackedMentionPositions[pos] = allLabel;
      mentionsFormatter.mentionAllPositions.add(allLabel);
      
      if (mentionsFormatter.mentionTextToPositions.containsKey(allLabel)) {
        mentionsFormatter.mentionTextToPositions[allLabel]!.add(pos);
      } else {
        mentionsFormatter.mentionTextToPositions[allLabel] = [pos];
      }
      
      if (mentionsFormatter.mentionedUsersMap.containsKey(allLabel)) {
        mentionsFormatter.mentionedUsersMap[allLabel]!.add(null);
      } else {
        mentionsFormatter.mentionedUsersMap[allLabel] = [null];
      }
      
      searchStart = pos + allLabel.length;
    }
    
    // Find user mentions
    for (var user in mentionedUsers) {
      final mention = '@${user.name}';
      searchStart = 0;
      
      while (true) {
        int pos = text.indexOf(mention, searchStart);
        if (pos == -1) break;
        
        mentionsFormatter.trackedMentionPositions[pos] = mention;
        
        if (mentionsFormatter.mentionTextToPositions.containsKey(mention)) {
          mentionsFormatter.mentionTextToPositions[mention]!.add(pos);
        } else {
          mentionsFormatter.mentionTextToPositions[mention] = [pos];
        }
        
        if (mentionsFormatter.mentionedUsersMap.containsKey(mention)) {
          mentionsFormatter.mentionedUsersMap[mention]!.add(user);
        } else {
          mentionsFormatter.mentionedUsersMap[mention] = [user];
        }
        
        if (!mentionsFormatter.mentionCount.contains(user.uid)) {
          mentionsFormatter.mentionCount.add(user.uid);
        }
        
        searchStart = pos + mention.length;
      }
    }
  }

  /// Cancels the current preview mode.
  ///
  /// Clears the text field if in edit mode and invokes [onEditCancel] callback.
  ///
  /// _Requirements: 6.3_
  void cancelPreview() {
    final wasEditMode = previewMessageMode == PreviewMessageMode.edit;

    previewMessageMode = PreviewMessageMode.none;
    oldMessage = null;
    quotedMessage = null;

    if (wasEditMode) {
      textEditingController?.clear();
      _previousText = "";
      
      // Clear rich text formatting state
      _richTextController?.clearFormatting();
      
      // Reset formatter state when cancelling edit
      for (var element in _formatters) {
        if (element is CometChatMentionsFormatter && textEditingController != null) {
          element.onMessageEdit(textEditingController!, mentionedUsers: []);
        }
      }
      
      onEditCancel?.call();
    }

    update();
  }

  /// Called when text changes in a segment (segmented mode).
  ///
  /// Handles typing indicator events and mention tracking for the specific segment.
  ///
  /// _Requirements: 9.1, 9.2, 9.3, 9.4, 12.1_
  void onSegmentTextChanged(ComposerSegment segment) {
    // Only process normal segments for mentions (code segments don't have mentions)
    if (segment.type == SegmentType.normal) {
      // Notify formatters of text change for mention detection
      _notifyFormattersOnChangeForSegment(segment);
    }
    
    _handleTypingIndicator();
    _updateMentionCount();

    // Invoke onChange callback
    onChange?.call(this);

    update();
  }

  /// Called when text changes in the input field.
  ///
  /// Handles typing indicator events and mention tracking.
  ///
  /// _Requirements: 9.1, 9.2, 9.3, 9.4, 12.1_
  void onTextChanged() {
    // Notify formatters of text change for mention detection FIRST
    // This must happen before _handleTypingIndicator updates _previousText
    // _Requirements: 5.1, 5.2_
    // Skip if _onRichTextControllerChanged already notified formatters
    // (it updates _previousText after notifying, so if they match, it was already handled)
    final currentText = textEditingController?.text ?? '';
    if (currentText != _previousText) {
      _notifyFormattersOnChange();
    }
    
    // Handle newline continuation for lists/blockquotes in markdown mode
    if (_richTextController == null) {
      _handleMarkdownNewlineContinuation();
    }
    
    _handleTypingIndicator();
    _updateMentionCount();
    _updateActiveFormats();

    // Invoke onChange callback
    onChange?.call(this);

    update();
  }

  /// Handles Enter key press based on [enterKeyBehavior].
  ///
  /// _Requirements: 4.1, 4.2_
  void handleEnterKey(BuildContext context) {
    if (enterKeyBehavior == EnterKeyBehavior.sendMessage) {
      if (isSendButtonEnabled) {
        onSendButtonClick(context);
      }
    }
    // For newLine behavior, the default TextField behavior handles it
  }

  /// Requests focus on the text input field.
  ///
  /// This method can be called to programmatically focus the text field,
  /// enabling proper keyboard navigation and accessibility.
  ///
  /// _Requirements: 11.2_
  void requestFocus() {
    focusNode?.requestFocus();
  }

  /// Unfocuses the text input field.
  ///
  /// _Requirements: 11.2_
  void unfocus() {
    focusNode?.unfocus();
  }

  /// Checks if the cursor is on a link and shows the link edit menu.
  ///
  /// This is called when the user taps in the text field to check if
  /// they tapped on a link.
  void checkLinkTapAtCursor() {
    if (_richTextController == null || _context == null) return;
    
    final linkSpan = _richTextController!.getLinkSpanAtPosition(
      _richTextController!.selection.baseOffset,
    );
    
    if (linkSpan != null) {
      showLinkEditMenu(_context!, linkSpan);
    }
  }

  /// Sets the build context for the controller.
  ///
  /// This is needed for showing dialogs like the link dialog.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Shows the attachment options bottom sheet.
  ///
  /// Displays a list of attachment options (image, video, audio, file) and handles
  /// the selection by picking the appropriate media and sending it as a message.
  ///
  /// _Requirements: 8.1, 8.2, 8.3_
  Future<void> showBottomActionSheet(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) async {
    // Initialize attachment options if not already done
    if (!_attachmentOptionsInitialized) {
      _initializeAttachmentOptions(context, colorPalette, typography);
      _attachmentOptionsInitialized = true;
    }

    // Unfocus the text field before showing the sheet
    FocusManager.instance.primaryFocus?.unfocus();

    // Show the attachment option sheet and get the selected item
    ActionItem? item = await showCometChatAttachmentOptionSheet(
      colorPalette: colorPalette,
      context: context,
      actionItems: _actionItems,
      style: CometChatAttachmentOptionSheetStyle(
        titleTextStyle: TextStyle(
          color: _actionStyle?.titleColor,
          fontSize: typography.heading4?.regular?.fontSize,
          fontWeight: typography.heading4?.regular?.fontWeight,
          fontFamily: typography.heading4?.regular?.fontFamily,
        ).merge(_actionStyle?.titleTextStyle),
        backgroundColor: _actionStyle?.backgroundColor,
        iconColor: _actionStyle?.iconColor,
        titleColor: _actionStyle?.titleColor,
        borderRadius: _actionStyle?.borderRadius,
        border: _actionStyle?.border,
      ),
    );

    if (item == null) {
      return;
    }

    // Handle custom onItemClick callback
    if (item.onItemClick != null &&
        item.onItemClick is Function(BuildContext, User?, Group?)) {
      try {
        if (context.mounted) {
          item.onItemClick(context, user, group);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("The attachment option could not be executed: $e");
        }
      }
    } else {
      // Handle default attachment options
      await _handleAttachmentSelection(item);
    }
  }

  /// Handles the selection of a default attachment option.
  ///
  /// Picks the appropriate media type and sends it as a message.
  ///
  /// _Requirements: 8.2, 8.3_
  Future<void> _handleAttachmentSelection(ActionItem item) async {
    PickedFile? pickedFile;
    String? type;

    // Pick the appropriate media based on the selected option
    if (item.id == MessageTypeConstants.attachPhoto ||
        item.id == MessageTypeConstants.image) {
      pickedFile = await MediaPicker.pickImage();
      type = pickedFile?.fileType ?? MessageTypeConstants.image;
    } else if (item.id == MessageTypeConstants.attachVideo ||
        item.id == MessageTypeConstants.video) {
      pickedFile = await MediaPicker.pickVideo();
      type = pickedFile?.fileType ?? MessageTypeConstants.video;
    } else if (item.id == 'takePhoto') {
      pickedFile = await MediaPicker.takePhoto();
      type = MessageTypeConstants.image;
    } else if (item.id == MessageTypeConstants.file) {
      pickedFile = await MediaPicker.pickAnyFile();
      type = MessageTypeConstants.file;
    } else if (item.id == MessageTypeConstants.audio) {
      pickedFile = await MediaPicker.pickAudio();
      type = MessageTypeConstants.audio;
    }

    if (pickedFile != null && type != null) {
      // Check if the picked image is HEIC or HEIF format and change type to file
      bool isHeicOrHeif = false;

      if (pickedFile.fileType != null &&
          pickedFile.fileType == MessageTypeConstants.image) {
        isHeicOrHeif = _isHeicOrHeif(pickedFile.path);
      }

      if (type == MessageTypeConstants.image && !isHeicOrHeif) {
        isHeicOrHeif = _isHeicOrHeif(pickedFile.path);
      }

      if (isHeicOrHeif) {
        type = MessageTypeConstants.file;
      }

      Map<String, dynamic> metadata = {};
      metadata["localPath"] = pickedFile.path;

      sendMediaMessage(
        path: pickedFile.path,
        messageType: type,
        metadata: metadata,
      );
    }
  }

  /// Checks if the file is in HEIC or HEIF format.
  bool _isHeicOrHeif(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.heic') || lowerPath.endsWith('.heif');
  }

  /// Sends a media message via CometChat SDK.
  ///
  /// _Requirements: 8.3_
  void sendMediaMessage({
    required String path,
    required String messageType,
    Map<String, dynamic>? metadata,
  }) {
    // On iOS, file paths need to be prefixed with file://
    String filePath = (Platform.isIOS && (!path.startsWith('file://')))
        ? 'file://$path'
        : path;

    MediaMessage mediaMessage = MediaMessage(
      receiverType: receiverType,
      type: messageType,
      receiverUid: receiverID,
      file: filePath,
      metadata: metadata,
      sender: loggedInUser,
      parentMessageId: parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    CometChatMessageEvents.ccMessageSent(
      mediaMessage,
      MessageStatus.inProgress,
    );

    CometChat.sendMediaMessage(
      mediaMessage,
      onSuccess: (MediaMessage message) {
        if (Platform.isIOS && message.file != null) {
          message.file = message.file?.replaceAll("file://", '');
        }
        debugPrint("Media message sent successfully");
        _playSound();
        CometChatMessageEvents.ccMessageSent(message, MessageStatus.sent);
      },
      onError: onError ??
          (CometChatException e) {
            if (mediaMessage.metadata != null) {
              mediaMessage.metadata!["error"] = e;
            } else {
              mediaMessage.metadata = {"error": e};
            }
            CometChatMessageEvents.ccMessageSent(
              mediaMessage,
              MessageStatus.error,
            );
            debugPrint("Media message sending failed with exception: ${e.message}");
          },
    );
  }

  /// Initializes the attachment options list.
  ///
  /// If custom [attachmentOptions] are provided, uses those.
  /// Otherwise, uses the default attachment options from the data source.
  ///
  /// _Requirements: 8.1, 8.2_
  void _initializeAttachmentOptions(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) {
    final defaultAttachmentOptionSheetStyle =
        CometChatThemeHelper.getTheme<CometChatAttachmentOptionSheetStyle>(
      context: context,
      defaultTheme: CometChatAttachmentOptionSheetStyle.of,
    ).merge(attachmentOptionSheetStyle);

    if (attachmentOptions != null) {
      // Use custom attachment options
      List<CometChatMessageComposerAction> actionList =
          attachmentOptions!(context, user, group, composerId);

      for (CometChatMessageComposerAction attachmentOption in actionList) {
        _actionStyle = CometChatAttachmentOptionSheetStyle(
          border: attachmentOption.style?.border ??
              defaultAttachmentOptionSheetStyle.border,
          borderRadius: attachmentOption.style?.borderRadius ??
              defaultAttachmentOptionSheetStyle.borderRadius,
          titleColor: attachmentOption.style?.titleColor ??
              defaultAttachmentOptionSheetStyle.titleColor,
          backgroundColor: attachmentOption.style?.backgroundColor ??
              defaultAttachmentOptionSheetStyle.backgroundColor,
          iconColor: attachmentOption.style?.iconColor ??
              defaultAttachmentOptionSheetStyle.iconColor,
          titleTextStyle: attachmentOption.style?.titleTextStyle ??
              defaultAttachmentOptionSheetStyle.titleTextStyle,
        );
        _actionItems.add(
          ActionItem(
            id: attachmentOption.id,
            title: attachmentOption.title,
            icon: attachmentOption.icon,
            style: CometChatAttachmentOptionSheetStyle(
              titleTextStyle: TextStyle(
                color: _actionStyle?.titleColor,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
              ).merge(_actionStyle?.titleTextStyle),
              backgroundColor: _actionStyle?.backgroundColor,
              iconColor: _actionStyle?.iconColor,
              titleColor: _actionStyle?.titleColor,
              borderRadius: _actionStyle?.borderRadius,
              border: _actionStyle?.border,
            ).merge(_actionStyle),
            onItemClick: attachmentOption.onItemClick,
          ),
        );
      }
    } else {
      // Use default attachment options from data source
      AdditionalConfigurations additionalConfigurations =
          AdditionalConfigurations(
        attachmentOptionSheetStyle: defaultAttachmentOptionSheetStyle,
        hideAudioAttachmentOption: hideAudioAttachmentOption,
        hideFileAttachmentOption: hideFileAttachmentOption,
        hideImageAttachmentOption: hideImageAttachmentOption,
        hideVideoAttachmentOption: hideVideoAttachmentOption,
        hidePollsOption: hidePollsOption,
        hideCollaborativeDocumentOption: hideCollaborativeDocumentOption,
        hideCollaborativeWhiteboardOption: hideCollaborativeWhiteboardOption,
        hideTakPhotoOption: hideTakePhotoOption,
        hideStickersButton: hideStickersButton,
      );

      final defaultOptions =
          CometChatUIKit.getDataSource().getAttachmentOptions(
        context,
        composerId,
        additionalConfigurations,
      );

      for (CometChatMessageComposerAction defaultAttachmentOption
          in defaultOptions) {
        _actionStyle = CometChatAttachmentOptionSheetStyle(
          border: defaultAttachmentOption.style?.border,
          borderRadius: defaultAttachmentOption.style?.borderRadius,
          titleColor: defaultAttachmentOption.style?.titleColor,
          backgroundColor: defaultAttachmentOption.style?.backgroundColor,
          iconColor: defaultAttachmentOption.style?.iconColor,
          titleTextStyle: defaultAttachmentOption.style?.titleTextStyle,
        );
        _actionItems.add(
          ActionItem(
            id: defaultAttachmentOption.id,
            title: defaultAttachmentOption.title,
            icon: defaultAttachmentOption.icon,
            style: CometChatAttachmentOptionSheetStyle(
              titleTextStyle: TextStyle(
                color: _actionStyle?.titleColor,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
              ).merge(_actionStyle?.titleTextStyle),
              backgroundColor: _actionStyle?.backgroundColor,
              iconColor: _actionStyle?.iconColor,
              titleColor: _actionStyle?.titleColor,
              borderRadius: _actionStyle?.borderRadius,
              border: _actionStyle?.border,
            ).merge(_actionStyle),
            onItemClick: defaultAttachmentOption.onItemClick,
          ),
        );
      }
    }
  }

  /// Initializes auxiliary options (stickers, emoji, etc.) from the data source.
  ///
  /// This method retrieves auxiliary options from CometChatUIKit's data source,
  /// which includes stickers if the stickers extension is enabled.
  void initAuxiliaryOptions(BuildContext context) {
    // Store context for panel rendering
    _context = context;
    
    if (_auxiliaryOptionsInitialized) return;
    
    AdditionalConfigurations additionalConfigurations = AdditionalConfigurations(
      hideStickersButton: hideStickersButton,
    );
    
    auxiliaryOptions = CometChatUIKit.getDataSource().getAuxiliaryOptions(
      user,
      group,
      context,
      composerId,
      auxiliaryButtonIconColor,
      additionalConfigurations: additionalConfigurations,
    );
    
    _auxiliaryOptionsInitialized = true;
    update();
  }

  /// Increments the mention count and checks against the limit.
  ///
  /// _Requirements: 5.5, 5.6_
  void addMention() {
    mentionCount++;
    final limit = mentionsLimit;
    if (mentionCount > limit) {
      onMentionLimitReached?.call(limit);
    }
    update();
  }

  /// Decrements the mention count.
  void removeMention() {
    if (mentionCount > 0) {
      mentionCount--;
      update();
    }
  }

  /// Resets the mention count.
  void resetMentionCount() {
    mentionCount = 0;
    update();
  }

  //--------------------Event Listener Overrides-----------------------

  @override
  void ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    if (status == MessageEditStatus.inProgress &&
        message.parentMessageId == parentMessageId) {
      previewMessage(message, PreviewMessageMode.edit);
    }
  }

  /// Handles the ccReplyToMessage event from CometChatMessageEvents.
  ///
  /// When [status] is [MessageStatus.inProgress], enters reply mode by:
  /// - Setting the preview mode to reply
  /// - Storing the quoted message
  /// - Focusing the text input field
  ///
  /// When [status] is [MessageStatus.sent] or [MessageStatus.error],
  /// clears the reply preview if currently in reply mode.
  ///
  /// _Requirements: 13.1, 13.2, 13.3_
  @override
  void ccReplyToMessage(BaseMessage message, MessageStatus status) {
    if (status == MessageStatus.inProgress &&
        message.parentMessageId == parentMessageId) {
      // Focus the text input field when entering reply mode
      // _Requirements: 13.2_
      if (focusNode != null && !focusNode!.hasFocus) {
        focusNode!.requestFocus();
      }
      // Enter reply mode and display the reply preview
      // _Requirements: 13.1_
      previewMessage(message, PreviewMessageMode.reply);
      quotedMessage = message;
      update();
    } else if ((status == MessageStatus.sent || status == MessageStatus.error) &&
        previewMessageMode == PreviewMessageMode.reply) {
      // Clear the reply preview when message is sent or on error
      // _Requirements: 13.3_
      hideReplyPreview();
    }
  }

  /// Hides the reply preview and clears the reply state.
  ///
  /// This method:
  /// - Hides the overlay portal if showing
  /// - Clears the preview mode
  /// - Clears the quoted message and old message references
  ///
  /// _Requirements: 13.3, 13.5_
  void hideReplyPreview() {
    if (overlayPortalController.isShowing) {
      overlayPortalController.hide();
    }
    previewMessageMode = PreviewMessageMode.none;
    quotedMessage = null;
    oldMessage = null;
    update();
  }

  @override
  void ccComposeMessage(String text, MessageEditStatus status) {
    textEditingController?.text = text;
    _previousText = text;
    update();
  }

  @override
  void showPanel(Map<String, dynamic>? id, CustomUIPosition uiPosition,
      WidgetBuilder child) {
    if (_isForThisWidget(id) == false) return;
    
    if (uiPosition == CustomUIPosition.composerBottom && _context != null) {
      footer = child(_context!);
    } else if (uiPosition == CustomUIPosition.composerTop && _context != null) {
      header = child(_context!);
    } else if (uiPosition == CustomUIPosition.composerPreview && _context != null) {
      preview = child(_context!);
    }
    update();
  }

  @override
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    if (_isForThisWidget(id) == false) return;
    
    if (uiPosition == CustomUIPosition.composerBottom) {
      footer = null;
    } else if (uiPosition == CustomUIPosition.composerTop) {
      header = null;
    } else if (uiPosition == CustomUIPosition.composerPreview) {
      preview = null;
      // Also hide the overlay portal when preview is hidden
      if (overlayPortalController.isShowing) {
        overlayPortalController.hide();
      }
    }
    update();
  }

  //--------------------Private Methods-----------------------

  void _populateComposerId() {
    if (parentMessageId != 0) {
      composerId['parentMessageId'] = parentMessageId;
    }
    if (group != null) {
      composerId['guid'] = group!.guid;
    } else if (user != null) {
      composerId['uid'] = user!.uid;
    }
  }

  Future<void> _getLoggedInUser() async {
    User? user = await CometChat.getLoggedInUser();
    if (user != null) {
      loggedInUser = user;
    }
  }

  bool _isForThisWidget(Map<String, dynamic>? id) {
    if (id == null) return true;

    if (composerId.containsKey('parentMessageId') &&
        id.containsKey('parentMessageId')) {
      if (composerId['parentMessageId'] != id['parentMessageId']) {
        return false;
      }
    }

    if (composerId.containsKey('guid') && id.containsKey('guid')) {
      return composerId['guid'] == id['guid'];
    }

    if (composerId.containsKey('uid') && id.containsKey('uid')) {
      return composerId['uid'] == id['uid'];
    }

    return true;
  }

  /// Handles typing indicator events with debouncing.
  ///
  /// _Requirements: 9.1, 9.2, 9.3, 9.4_
  void _handleTypingIndicator() {
    if (textEditingController == null) return;

    final currentText = textEditingController!.text;

    // Skip if typing events are disabled
    if (disableTypingEvents) {
      _previousText = currentText;
      return;
    }

    // Check if user is not blocked (for user conversations)
    if (user != null && !_userIsNotBlocked()) {
      _previousText = currentText;
      return;
    }

    // Start typing if not already typing
    if (_isTyping == false && currentText.isNotEmpty) {
      CometChat.startTyping(
        receiverUid: receiverID,
        receiverType: receiverType,
      );
      _isTyping = true;
    }

    // Debounce end typing
    _deBouncer.run(() {
      if (_isTyping) {
        CometChat.endTyping(
          receiverUid: receiverID,
          receiverType: receiverType,
        );
        _isTyping = false;
      }
    });

    _previousText = currentText;
  }

  bool _userIsNotBlocked() {
    if (user == null) return true;
    return user!.blockedByMe != true;
  }

  /// Handles focus changes on the text input field.
  ///
  /// When the text field gains focus (keyboard appears), hides the sticker panel
  /// to prevent both keyboard and sticker panel from being visible simultaneously.
  void _onFocusChange() {
    if (focusNode?.hasFocus == true) {
      // Hide the sticker panel when keyboard appears
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerBottom);
    }
  }

  /// Updates the mention count based on current text.
  ///
  /// Shows the mention info banner when the count reaches or exceeds the limit.
  ///
  /// _Requirements: 1.1, 3.1, 3.2_
  void _updateMentionCount() {
    if (textEditingController == null) return;

    final text = textEditingController!.text;
    // Count @ symbols that are followed by non-whitespace (simple heuristic)
    final mentionPattern = RegExp(r'@\S+');
    final matches = mentionPattern.allMatches(text);
    final newCount = matches.length;

    final limit = mentionsLimit;
    if (newCount > mentionCount && newCount > limit) {
      onMentionLimitReached?.call(limit);
    }

    mentionCount = newCount;
  }

  /// Updates active formats based on cursor position.
  void _updateActiveFormats() {
    if (textEditingController == null) return;

    // If using RichTextEditingController, update from cursor position
    if (_richTextController != null) {
      _richTextController!.updateActiveFormatsFromCursor();
      return;
    }

    // Fallback to markdown-based detection
    final text = textEditingController!.text;
    final cursorPosition = textEditingController!.selection.baseOffset;

    if (cursorPosition >= 0) {
      _activeFormats.clear();
      _activeFormats.addAll(RichTextFormatterManager.detectActiveFormats(
        text,
        cursorPosition,
      ));
    }
  }

  // Regex patterns for detecting line-level formats in markdown mode
  static final RegExp _mdBulletLinePattern = RegExp(r'^- (.*)$');
  static final RegExp _mdOrderedLinePattern = RegExp(r'^(\d+)\. (.*)$');
  static final RegExp _mdBlockquoteLinePattern = RegExp(r'^> (.*)$');

  /// Handles newline continuation for bullet lists, ordered lists, and blockquotes
  /// in markdown mode (when RichTextEditingController is not used).
  ///
  /// When the user presses Enter at the end of a list item or blockquote line,
  /// the next line automatically gets the same prefix. If the current line's
  /// content is empty (just the prefix), the prefix is removed instead.
  void _handleMarkdownNewlineContinuation() {
    if (textEditingController == null) return;

    final currentText = textEditingController!.text;
    final cursorPos = textEditingController!.selection.baseOffset;

    // Only proceed if cursor position is valid and a newline was just typed
    if (cursorPos <= 0 || cursorPos > currentText.length) return;
    if (currentText[cursorPos - 1] != '\n') return;

    // Avoid re-processing if the text hasn't changed in a way that indicates a new newline
    // (i.e., the previous text didn't have this newline)
    if (_previousText.length >= currentText.length) return;

    final newlinePosition = cursorPos - 1;

    // If the newline is at the very start of the text, there's no previous line to continue
    if (newlinePosition == 0) return;

    // Find the line before the newline
    final lineStart = currentText.lastIndexOf('\n', newlinePosition - 1) + 1;
    final previousLine = currentText.substring(lineStart, newlinePosition);

    String? continuationPrefix;

    // Check bullet list: "- content"
    final bulletMatch = _mdBulletLinePattern.firstMatch(previousLine);
    if (bulletMatch != null) {
      final content = bulletMatch.group(1) ?? '';
      if (content.isEmpty) {
        // Empty bullet item — remove the prefix and exit list mode
        _removeMarkdownLinePrefixAndNewline(lineStart, newlinePosition, '- ');
        return;
      }
      continuationPrefix = '- ';
    }

    // Check ordered list: "N. content"
    if (continuationPrefix == null) {
      final orderedMatch = _mdOrderedLinePattern.firstMatch(previousLine);
      if (orderedMatch != null) {
        final content = orderedMatch.group(2) ?? '';
        final currentNumber = int.tryParse(orderedMatch.group(1) ?? '1') ?? 1;
        if (content.isEmpty) {
          _removeMarkdownLinePrefixAndNewline(lineStart, newlinePosition, '$currentNumber. ');
          return;
        }
        continuationPrefix = '${currentNumber + 1}. ';
      }
    }

    // Check blockquote: "> content"
    if (continuationPrefix == null) {
      final blockquoteMatch = _mdBlockquoteLinePattern.firstMatch(previousLine);
      if (blockquoteMatch != null) {
        final content = blockquoteMatch.group(1) ?? '';
        if (content.isEmpty) {
          _removeMarkdownLinePrefixAndNewline(lineStart, newlinePosition, '> ');
          return;
        }
        continuationPrefix = '> ';
      }
    }

    if (continuationPrefix == null) return;

    // Insert the continuation prefix after the newline
    final insertPos = newlinePosition + 1;
    final newText = currentText.substring(0, insertPos) +
        continuationPrefix +
        currentText.substring(insertPos);

    final newCursorPos = insertPos + continuationPrefix.length;
    textEditingController!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Removes the line prefix and trailing newline when the user presses Enter
  /// on an empty list item or blockquote in markdown mode.
  void _removeMarkdownLinePrefixAndNewline(
    int lineStart,
    int newlinePosition,
    String prefix,
  ) {
    if (textEditingController == null) return;

    final currentText = textEditingController!.text;
    final removeStart = lineStart;
    final removeEnd = newlinePosition + 1; // include the newline character

    final newText = currentText.substring(0, removeStart) +
        currentText.substring(removeEnd);

    textEditingController!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: removeStart),
    );
  }

  /// Processes the message before sending to convert mentions to internal format.
  ///
  /// This method calls each formatter's handlePreMessageSend to convert
  /// display mentions (e.g., @John) to internal format (e.g., <@uid:123>)
  /// and set the mentionedUsers on the message.
  void _handlePreMessageSend(BuildContext context, BaseMessage baseMessage) {
    for (var element in _formatters) {
      element.handlePreMessageSend(context, baseMessage);
    }
  }

  /// Checks if trimming the text would break list formatting.
  ///
  /// Returns true if the original text ends with a list marker (e.g., "- " or "N. ")
  /// that would be broken by trimming (e.g., "- " -> "-").
  bool _wouldBreakListFormatting(String original, String trimmed) {
    if (original == trimmed) return false;
    
    // Check if any line in the original ends with a list marker that would be broken
    final originalLines = original.split('\n');
    final trimmedLines = trimmed.split('\n');
    
    // If the last line was completely removed by trimming, check if it was a list marker
    if (originalLines.length > trimmedLines.length) {
      final removedLine = originalLines.last;
      // Check if the removed line was an empty list item
      if (removedLine == '- ' || RegExp(r'^\d+\. $').hasMatch(removedLine)) {
        return true;
      }
    }
    
    // Check if the last line's trailing space was removed, breaking a list marker
    if (trimmedLines.isNotEmpty && originalLines.isNotEmpty) {
      final originalLast = originalLines.last;
      final trimmedLast = trimmedLines.last;
      
      // Check if original ends with "- " but trimmed ends with "-"
      if (originalLast.endsWith('- ') && trimmedLast.endsWith('-')) {
        return true;
      }
      
      // Check if original ends with "N. " but trimmed ends with "N."
      if (RegExp(r'\d+\. $').hasMatch(originalLast) && RegExp(r'\d+\.$').hasMatch(trimmedLast)) {
        return true;
      }
    }
    
    return false;
  }

  /// Converts mentions in markdown text by searching for mention text patterns.
  ///
  /// This is needed because when rich text formatting is applied, the positions
  /// of mentions shift due to markdown syntax being added. Instead of tracking
  /// positions, we search for the mention text itself and replace it.
  /// 
  /// Note: Mentions inside code blocks are NOT converted - they remain as plain text.
  String _convertMentionsInMarkdown(String markdownText) {
    // Find the mentions formatter
    final mentionFormatterIndex = _formatters.indexWhere(
      (element) => element is CometChatMentionsFormatter,
    );
    
    if (mentionFormatterIndex == -1) {
      return markdownText;
    }
    
    final mentionsFormatter = _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;
    
    // Extract code blocks and process only non-code-block parts
    // Code blocks are wrapped with ``` and should not have mentions converted
    final codeBlockPattern = RegExp(r'```[\w]*[\s\S]*?```', multiLine: true);
    
    // Find all code blocks and their positions
    final codeBlocks = <_CodeBlockMatch>[];
    for (final match in codeBlockPattern.allMatches(markdownText)) {
      codeBlocks.add(_CodeBlockMatch(match.start, match.end, match.group(0)!));
    }
    
    // If no code blocks, process the entire text
    if (codeBlocks.isEmpty) {
      return _replaceMentionsInText(markdownText, mentionsFormatter);
    }
    
    // Process text in parts, skipping code blocks
    final result = StringBuffer();
    int lastEnd = 0;
    
    for (final codeBlock in codeBlocks) {
      // Process text before this code block
      if (codeBlock.start > lastEnd) {
        final textPart = markdownText.substring(lastEnd, codeBlock.start);
        result.write(_replaceMentionsInText(textPart, mentionsFormatter));
      }
      
      // Add code block as-is (no mention conversion)
      result.write(codeBlock.content);
      lastEnd = codeBlock.end;
    }
    
    // Process remaining text after last code block
    if (lastEnd < markdownText.length) {
      final textPart = markdownText.substring(lastEnd);
      result.write(_replaceMentionsInText(textPart, mentionsFormatter));
    }
    
    return result.toString();
  }
  
  /// Helper method to replace mentions in a text segment.
  String _replaceMentionsInText(String text, CometChatMentionsFormatter mentionsFormatter) {
    String result = text;
    
    // Process @all mentions first
    for (final mentionText in mentionsFormatter.mentionAllPositions) {
      final allLabelId = mentionsFormatter.mentionAllLabelId ?? "all";
      final replacement = "<@all:$allLabelId>";
      // Replace all occurrences of this @all mention text
      result = result.replaceAll(mentionText, replacement);
    }
    
    // Process user mentions - we need to handle each unique mention text
    // and replace all occurrences with the corresponding user tag
    final processedMentions = <String>{};
    
    mentionsFormatter.mentionedUsersMap.forEach((mentionText, users) {
      if (processedMentions.contains(mentionText)) return;
      processedMentions.add(mentionText);
      
      // Find the first non-null user for this mention text
      User? mentionedUser;
      for (var user in users) {
        if (user != null) {
          mentionedUser = user;
          break;
        }
      }
      
      if (mentionedUser != null) {
        final replacement = "<@uid:${mentionedUser.uid}>";
        // Replace all occurrences of this mention text
        result = result.replaceAll(mentionText, replacement);
      }
    });
    
    return result;
  }

  /// Sends a voice recording as an audio message.
  ///
  /// This method is called when a voice recording is completed via [CometChatMediaRecorder].
  /// It creates a MediaMessage with the audio file path and sends it via CometChat SDK.
  ///
  /// _Requirements: 7.1, 7.2_
  void sendMediaRecording(BuildContext context, String path, List<double> waveform) {
    final metadata = <String, dynamic>{
      'localPath': path,
      'waveform': waveform,
    };

    // Hide the inline audio recorder after sending
    hideInlineAudioRecorder();

    if (onSendButtonTap != null) {
      // If custom callback is provided, create the message and pass it to the callback
      MediaMessage mediaMessage = MediaMessage(
        receiverType: receiverType,
        type: MessageTypeConstants.audio,
        receiverUid: receiverID,
        file: path,
        sender: loggedInUser,
        parentMessageId: parentMessageId,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        category: CometChatMessageCategory.message,
        metadata: metadata,
        sentAt: DateTime.now(),
      );
      onSendButtonTap!(context, mediaMessage, previewMessageMode);
    } else {
      // Otherwise, send the media message directly via SDK
      sendMediaMessage(
        path: path,
        messageType: MessageTypeConstants.audio,
        metadata: metadata,
      );
    }
  }

  /// Shows the inline audio recorder, replacing the compose box.
  ///
  /// This method is called when the voice recording button is tapped.
  /// It sets [isInlineAudioRecorderVisible] to true and updates the UI.
  void showInlineAudioRecorder() {
    isInlineAudioRecorderVisible = true;
    // Unfocus the text field when showing the recorder
    focusNode?.unfocus();
    update();
  }

  /// Hides the inline audio recorder and shows the compose box again.
  ///
  /// This method is called when:
  /// - The recording is cancelled/deleted
  /// - The recording is submitted
  void hideInlineAudioRecorder() {
    isInlineAudioRecorderVisible = false;
    update();
  }

  //--------------------Mention Suggestion Methods-----------------------

  /// Initializes text formatters including the mentions formatter.
  ///
  /// Sets up the CometChatMentionsFormatter with the appropriate configuration
  /// based on [disableMentions] and [disableMentionAll] flags.
  /// Also adds CometChatRichTextFormatter when rich text editing is enabled.
  ///
  /// _Requirements: 5.1, 5.2, 5.3, 5.4_
  void _initializeFormatters() {
    _formatters = textFormatters ?? [];

    int mentionFormatterIndex = _formatters.indexWhere(
        (element) => element is CometChatMentionsFormatter);

    // Only add/update mentions formatter if mentions are not completely disabled
    if (!disableMentions || !disableMentionAll) {
      if (mentionFormatterIndex != -1) {
        // Preserve mentionsLimit from existing formatter if provided
        final existingFormatter = _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;
        final existingMentionsLimit = existingFormatter.mentionsLimit;
        
        // Update existing mentions formatter with controller properties
        _formatters[mentionFormatterIndex] = CometChatMentionsFormatter(
          style: mentionsStyle ?? existingFormatter.style,
          disableMentions: disableMentions,
          disableMentionAll: disableMentionAll,
          mentionAllLabel: mentionAllLabel ?? existingFormatter.mentionAllLabel,
          mentionAllLabelId: mentionAllLabelId ?? existingFormatter.mentionAllLabelId,
          mentionsLimit: existingMentionsLimit,
        );
      } else {
        // Add new mentions formatter
        var formatter = CometChatMentionsFormatter(
          style: mentionsStyle,
          disableMentions: disableMentions,
          disableMentionAll: disableMentionAll,
          mentionAllLabel: mentionAllLabel,
          mentionAllLabelId: mentionAllLabelId,
        );
        _formatters.add(formatter);
      }
    } else {
      // Remove mentions formatter if both mentions and mention all are disabled
      _formatters.removeWhere((element) => element is CometChatMentionsFormatter);
    }

    // Add rich text formatter if rich text editing is enabled
    if (enableRichTextEditor) {
      int richTextFormatterIndex = _formatters.indexWhere(
          (element) => element is CometChatRichTextFormatter);
      
      if (richTextFormatterIndex == -1) {
        // Add new rich text formatter with enabled formats based on hideRichTextFormattingOptions
        Set<FormatType>? enabledFormats;
        if (hideRichTextFormattingOptions != null && hideRichTextFormattingOptions!.isNotEmpty) {
          // Create enabled formats by excluding hidden ones
          enabledFormats = FormatType.values.toSet()
            ..removeAll(hideRichTextFormattingOptions!);
        }
        
        _formatters.add(CometChatRichTextFormatter(
          enabledFormats: enabledFormats,
          style: richTextFormatterStyle,
        ));
      }
    } else {
      // Remove rich text formatter if rich text editing is disabled
      _formatters.removeWhere((element) => element is CometChatRichTextFormatter);
    }

    // Configure all formatters with the necessary properties
    for (var element in _formatters) {
      element.composerId = composerId;
      element.suggestionListEventSink = _suggestionListController.sink;
      element.previousTextEventSink = _previousTextController.sink;
      element.onSearch = _onFormatterSearch;
      element.user = user;
      element.group = group;
      element.init();
    }
  }

  /// Callback for formatter search events.
  ///
  /// Called when the mentions formatter detects a search keyword change.
  /// Updates the search state and hides the suggestion panel when search is cleared.
  ///
  /// _Requirements: 5.2_
  void _onFormatterSearch(String? searchKeyword) {
    _searchKeywordChanged = _currentSearchKeyword != searchKeyword;
    _currentSearchKeyword = searchKeyword;

    if (_currentSearchKeyword == null) {
      preview = null;
      overlayPortalController.hide();
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerPreview);
      suggestions.clear();
    }
    update();
  }

  /// Handles updates to the suggestion list from the formatter.
  ///
  /// Processes incoming suggestion items and shows/hides the suggestion panel.
  ///
  /// _Requirements: 5.1, 5.2_
  void _handleSuggestionListUpdate(List<SuggestionListItem> value) {
    if (value.isNotEmpty && _currentSearchKeyword != null) {
      if (_searchKeywordChanged) {
        suggestions = value;
        _searchKeywordChanged = false;
      } else {
        // Add new suggestions that aren't already in the list
        for (var element in value) {
          if (!suggestions.contains(element)) {
            suggestions.add(element);
          }
        }
      }
      hasMoreSuggestions = true;

      // Directly set the preview widget if we have context
      // This avoids relying on the event system which may have timing issues
      if (_context != null) {
        final colorPalette = CometChatThemeHelper.getColorPalette(_context!);
        final spacing = CometChatThemeHelper.getSpacing(_context!);
        final typography = CometChatThemeHelper.getTypography(_context!);
        preview = getSuggestionList(_context!, colorPalette, spacing, typography);
      } else {
        // Fallback to event system
        CometChatUIEvents.showPanel(
          composerId,
          CustomUIPosition.composerPreview,
          (context) {
            final colorPalette = CometChatThemeHelper.getColorPalette(context);
            final spacing = CometChatThemeHelper.getSpacing(context);
            final typography = CometChatThemeHelper.getTypography(context);
            return getSuggestionList(context, colorPalette, spacing, typography);
          },
        );
      }
      
      // Show the overlay portal first, then update to trigger rebuild
      // This ensures the overlay is visible and will be rebuilt with the new suggestions
      if (!overlayPortalController.isShowing) {
        overlayPortalController.show();
      }
      
      // Update after showing to ensure the overlay rebuilds with the new suggestions
      update();
    } else {
      if (_searchKeywordChanged) {
        // Clear the preview widget directly
        preview = null;
        CometChatUIEvents.hidePanel(
            composerId, CustomUIPosition.composerPreview);
        suggestions.clear();
      }
      hasMoreSuggestions = false;
      update();
    }
  }

  /// Notifies formatters when text changes.
  ///
  /// Called from [onTextChanged] to update formatters with the current text state.
  ///
  /// _Requirements: 5.1, 5.2_
  void _notifyFormattersOnChange() {
    if (textEditingController == null) {
      return;
    }

    for (var formatter in _formatters) {
      formatter.onChange(textEditingController!, _previousText);
    }
  }

  /// Notifies formatters when text changes in a segment (segmented mode).
  ///
  /// Called from [onSegmentTextChanged] to update formatters with the segment's text state.
  /// This is used for mention detection in segmented composer mode.
  ///
  /// _Requirements: 5.1, 5.2_
  void _notifyFormattersOnChangeForSegment(ComposerSegment segment) {
    // Get the segment's previous text (stored in the segment or use empty string)
    final segmentPreviousText = _segmentPreviousTexts[segment.id] ?? '';
    
    // For mentions formatter, we need special handling in segmented mode
    // to preserve mentions from other segments
    for (var formatter in _formatters) {
      if (formatter is CometChatMentionsFormatter) {
        // Save the current tracked positions from other segments
        final savedPositions = Map<int, String>.from(formatter.trackedMentionPositions);
        final savedMentionTextToPositions = Map<String, List<int>>.from(
          formatter.mentionTextToPositions.map((k, v) => MapEntry(k, List<int>.from(v)))
        );
        
        // Call onChange for this segment
        formatter.onChange(segment.controller, segmentPreviousText);
        
        // Restore positions from other segments that are still valid
        // The positions in this segment may have been updated by onChange
        // We need to merge them with positions from other segments
        
        // Get all normal segments and their texts
        if (_segmentedController != null) {
          // Rebuild tracked positions for all segments
          final newTrackedPositions = <int, String>{};
          final newMentionTextToPositions = <String, List<int>>{};
          
          // First, keep any new positions that onChange added for this segment
          formatter.trackedMentionPositions.forEach((pos, text) {
            // Check if this position is valid in the current segment
            if (pos >= 0 && pos + text.length <= segment.text.length &&
                segment.text.substring(pos, pos + text.length) == text) {
              newTrackedPositions[pos] = text;
              if (newMentionTextToPositions.containsKey(text)) {
                newMentionTextToPositions[text]!.add(pos);
              } else {
                newMentionTextToPositions[text] = [pos];
              }
            }
          });
          
          // Then, restore positions from other segments
          for (final otherSegment in _segmentedController!.segments) {
            if (otherSegment.id != segment.id && otherSegment.type == SegmentType.normal) {
              // Check saved positions that belong to this other segment
              savedPositions.forEach((pos, text) {
                if (pos >= 0 && pos + text.length <= otherSegment.text.length &&
                    otherSegment.text.substring(pos, pos + text.length) == text) {
                  // This position is valid in the other segment
                  newTrackedPositions[pos] = text;
                  if (newMentionTextToPositions.containsKey(text)) {
                    if (!newMentionTextToPositions[text]!.contains(pos)) {
                      newMentionTextToPositions[text]!.add(pos);
                    }
                  } else {
                    newMentionTextToPositions[text] = [pos];
                  }
                }
              });
            }
          }
          
          // Update the formatter's tracking maps
          formatter.trackedMentionPositions.clear();
          formatter.trackedMentionPositions.addAll(newTrackedPositions);
          formatter.mentionTextToPositions.clear();
          formatter.mentionTextToPositions.addAll(newMentionTextToPositions);
        }
      } else {
        formatter.onChange(segment.controller, segmentPreviousText);
      }
    }
    
    // Update the previous text for this segment
    _segmentPreviousTexts[segment.id] = segment.text;
  }

  /// Map to track previous text for each segment (for mention detection)
  final Map<String, String> _segmentPreviousTexts = {};

  /// Handles scroll to bottom event for loading more suggestions.
  ///
  /// Called when the user scrolls to the bottom of the suggestion list.
  void onSuggestionListScrollToBottom() {
    if (textEditingController == null) return;

    for (var formatter in _formatters) {
      formatter.onScrollToBottom(textEditingController!);
    }
  }

  /// Builds the suggestion list widget.
  ///
  /// Creates a scrollable list of suggestion items for mentions.
  ///
  /// _Requirements: 5.1, 5.2_
  Widget getSuggestionList(
    BuildContext context,
    CometChatColorPalette? colorPalette,
    CometChatSpacing? spacing,
    CometChatTypography? typography,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        spacing?.margin2 ?? 0,
        0,
        spacing?.margin2 ?? 0,
        spacing?.margin1 ?? 0,
      ),
      padding: EdgeInsets.symmetric(vertical: spacing?.padding2 ?? 0),
      constraints: BoxConstraints(
        maxHeight: suggestions.length > 4
            ? 220
            : suggestions.isEmpty
                ? 66
                : suggestions.length * 55.0,
      ),
      decoration: BoxDecoration(
        color: suggestionListStyle?.backgroundColor ?? colorPalette?.background1,
        borderRadius: suggestionListStyle?.borderRadius ??
            BorderRadius.circular(spacing?.radius2 ?? 8),
        border: suggestionListStyle?.border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: suggestions.isEmpty
          ? Center(
              child: Text(
                'No results found',
                style: TextStyle(
                  color: colorPalette?.textSecondary,
                  fontSize: typography?.body?.regular?.fontSize,
                ),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  onSuggestionListScrollToBottom();
                }
                return false;
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return _buildSuggestionItem(
                    item,
                    colorPalette,
                    spacing,
                    typography,
                  );
                },
              ),
            ),
    );
  }

  /// Builds a single suggestion item widget.
  Widget _buildSuggestionItem(
    SuggestionListItem item,
    CometChatColorPalette? colorPalette,
    CometChatSpacing? spacing,
    CometChatTypography? typography,
  ) {
    return InkWell(
      onTap: () {
        // Call the formatter's onTap handler first
        // This updates the text and tracking
        item.onTap?.call();
        // Clear suggestions and reset search state
        suggestions.clear();
        _currentSearchKeyword = null;
        _searchKeywordChanged = true;
        // Clear the preview widget and hide the overlay
        preview = null;
        overlayPortalController.hide();
        update();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing?.padding3 ?? 12,
          vertical: spacing?.padding2 ?? 8,
        ),
        child: Row(
          children: [
            // Avatar
            CometChatAvatar(
              name: item.avatarName ?? item.title ?? '',
              image: item.avatarUrl,
              height: item.avatarHeight ?? 36,
              width: item.avatarWidth ?? 36,
              style: suggestionListStyle?.avatarStyle,
            ),
            SizedBox(width: spacing?.padding2 ?? 8),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: suggestionListStyle?.textColor ?? colorPalette?.textPrimary,
                      fontSize: typography?.body?.medium?.fontSize,
                      fontWeight: typography?.body?.medium?.fontWeight,
                    ).merge(suggestionListStyle?.textStyle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty)
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        color: colorPalette?.textSecondary,
                        fontSize: typography?.caption1?.regular?.fontSize,
                        fontWeight: typography?.caption1?.regular?.fontWeight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hides the suggestion list.
  void hideSuggestionList() {
    suggestions.clear();
    _currentSearchKeyword = null;
    _searchKeywordChanged = true;
    preview = null;
    overlayPortalController.hide();
    update();
  }

  /// Hides the suggestion list if the mention tracker's '@' character is no longer valid.
  /// 
  /// This is called after formatting operations to ensure the mention suggestion list
  /// is hidden if the '@' character that triggered the mention was removed by formatting.
  /// Clears mentions within the current selection when applying inline code.
  /// 
  /// When inline code is applied to text containing mentions, the mentions
  /// should be converted to normal text (lose their special formatting).
  void _clearMentionsInSelection(TextEditingController controller) {
    final selection = controller.selection;
    if (selection.isCollapsed) return; // No selection, nothing to clear
    
    final start = selection.start;
    final end = selection.end;
    final text = controller.text;
    
    // Find the mentions formatter
    final mentionFormatter = _formatters.whereType<CometChatMentionsFormatter>().firstOrNull;
    if (mentionFormatter == null) return;
    
    // Find all mentions that overlap with the selection and remove them
    final positionsToRemove = <int>[];
    mentionFormatter.trackedMentionPositions.forEach((pos, mentionText) {
      final mentionEnd = pos + mentionText.length;
      // Check if this mention overlaps with the selection
      if (pos < end && mentionEnd > start) {
        positionsToRemove.add(pos);
      }
    });
    
    // Remove the mentions from tracking
    for (final pos in positionsToRemove) {
      final mentionText = mentionFormatter.trackedMentionPositions[pos];
      if (mentionText != null) {
        // Remove from trackedMentionPositions
        mentionFormatter.trackedMentionPositions.remove(pos);
        
        // Remove from mentionTextToPositions
        if (mentionFormatter.mentionTextToPositions.containsKey(mentionText)) {
          mentionFormatter.mentionTextToPositions[mentionText]!.remove(pos);
          if (mentionFormatter.mentionTextToPositions[mentionText]!.isEmpty) {
            mentionFormatter.mentionTextToPositions.remove(mentionText);
          }
        }
        
        // Remove from mentionAllPositions if it's an @all mention
        if (mentionFormatter.mentionAllPositions.contains(mentionText)) {
          // Only remove if no other instances exist
          if (mentionFormatter.mentionTextToPositions[mentionText]?.isEmpty ?? true) {
            mentionFormatter.mentionAllPositions.remove(mentionText);
          }
        }
        
        // Update mentionedUsersMap
        if (mentionFormatter.mentionedUsersMap.containsKey(mentionText)) {
          final users = mentionFormatter.mentionedUsersMap[mentionText]!;
          if (users.isNotEmpty) {
            final removedUser = users.removeAt(0);
            if (users.isEmpty) {
              mentionFormatter.mentionedUsersMap.remove(mentionText);
            }
            // Update mentionCount if this was the last instance of this user
            if (removedUser != null) {
              bool userStillMentioned = false;
              mentionFormatter.mentionedUsersMap.forEach((_, uList) {
                if (uList.any((u) => u?.uid == removedUser.uid)) {
                  userStillMentioned = true;
                }
              });
              if (!userStillMentioned) {
                mentionFormatter.mentionCount.remove(removedUser.uid);
              }
            }
          }
        }
      }
    }
  }

  /// Saves mention data in the current selection so it can be restored later.
  void _saveMentionsInSelection(TextEditingController controller) {
    final selection = controller.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;

    final mentionFormatter = _formatters.whereType<CometChatMentionsFormatter>().firstOrNull;
    if (mentionFormatter == null) return;

    final saved = <_SavedMention>[];
    mentionFormatter.trackedMentionPositions.forEach((pos, mentionText) {
      final mentionEnd = pos + mentionText.length;
      if (pos < end && mentionEnd > start) {
        // Find the associated user
        User? user;
        if (mentionFormatter.mentionedUsersMap.containsKey(mentionText)) {
          final users = mentionFormatter.mentionedUsersMap[mentionText]!;
          if (users.isNotEmpty) {
            user = users.first;
          }
        }
        saved.add(_SavedMention(position: pos, mentionText: mentionText, user: user));
      }
    });

    _savedMentionsForInlineCode = saved.isNotEmpty ? saved : null;
  }

  /// Restores previously saved mention data when inline code is removed.
  void _restoreMentionsInSelection(TextEditingController controller) {
    final saved = _savedMentionsForInlineCode;
    if (saved == null || saved.isEmpty) return;

    final mentionFormatter = _formatters.whereType<CometChatMentionsFormatter>().firstOrNull;
    if (mentionFormatter == null) return;

    final currentText = controller.text;

    for (final m in saved) {
      final pos = m.position;
      final mentionEnd = pos + m.mentionText.length;
      // Validate the mention text still exists at the expected position
      if (pos < 0 || mentionEnd > currentText.length) continue;
      if (currentText.substring(pos, mentionEnd) != m.mentionText) continue;

      // Restore trackedMentionPositions
      mentionFormatter.trackedMentionPositions[pos] = m.mentionText;

      // Restore mentionTextToPositions
      mentionFormatter.mentionTextToPositions
          .putIfAbsent(m.mentionText, () => []);
      if (!mentionFormatter.mentionTextToPositions[m.mentionText]!.contains(pos)) {
        mentionFormatter.mentionTextToPositions[m.mentionText]!.add(pos);
      }

      // Restore mentionedUsersMap
      if (m.user != null) {
        mentionFormatter.mentionedUsersMap
            .putIfAbsent(m.mentionText, () => []);
        mentionFormatter.mentionedUsersMap[m.mentionText]!.add(m.user);

        // Restore mentionCount
        mentionFormatter.mentionCount.add(m.user!.uid);
      }
    }

    _savedMentionsForInlineCode = null;
  }

  /// Hides the suggestion list if the mention tracker is no longer valid.
  /// without triggering the full onChange logic which could cause issues with mention tracking.
  void _hideSuggestionListIfMentionTrackerInvalid() {
    // Only proceed if suggestion list is showing
    if (!overlayPortalController.isShowing) return;
    
    // Get the current text
    final currentText = _richTextController?.text ?? textEditingController?.text ?? '';
    
    // Check if there's an active mention being tracked by looking for '@' in the text
    // If the suggestion list is showing but there's no '@' followed by the search keyword,
    // then the mention tracker is invalid and we should hide the list
    if (_currentSearchKeyword != null && _currentSearchKeyword!.isNotEmpty) {
      // The search keyword starts with '@', check if it's still in the text
      final searchPattern = _currentSearchKeyword!;
      if (!currentText.contains(searchPattern)) {
        // The mention tracker is no longer valid, hide the suggestion list
        hideSuggestionList();
      }
    } else if (suggestions.isNotEmpty) {
      // If there are suggestions but no search keyword, check if '@' is still present
      // at a position that would trigger mentions (start of line or after space)
      bool hasValidMentionTrigger = false;
      for (int i = 0; i < currentText.length; i++) {
        if (currentText[i] == '@') {
          // Check if this '@' is at start or after a space/newline
          if (i == 0 || currentText[i - 1] == ' ' || currentText[i - 1] == '\n') {
            hasValidMentionTrigger = true;
            break;
          }
        }
      }
      if (!hasValidMentionTrigger) {
        hideSuggestionList();
      }
    }
  }

  //--------------------Agent / AI Streaming-----------------------

  /// Returns true if the target user has the agentic AI role.
  bool isUserAgentic() {
    return user?.role == AIConstants.aiRole;
  }

  @override
  void ccStreamInProgress(bool isInProgress) {
    isActiveStreaming = isInProgress;
    update();
  }

  @override
  void ccStreamCompleted(bool isCompleted) {
    if (isActiveStreaming && isCompleted) {
      isActiveStreaming = false;
      update();
    }
  }

  @override
  void ccStreamInterrupted(bool isInterrupted) {
    if (isActiveStreaming && isInterrupted) {
      isActiveStreaming = false;
      update();
    }
  }

  /// Replaces emoji characters inside inline code and code block regions
  /// of a markdown string with their Unicode code point representation.
  ///
  /// For example, `😀` inside `` `😀` `` becomes `` `U+1F600` ``.
  /// Emojis outside code regions are left untouched.
  String _replaceEmojisInCodeRegions(String markdownText) {
    if (markdownText.isEmpty) return markdownText;

    final emojiPattern = FormatPatterns.emoji;

    // Match code blocks (```...```) and inline code (`...`) in order.
    // Code blocks are checked first so ``` is not consumed by the inline pattern.
    final codeRegionPattern = RegExp(r'```[\s\S]*?```|`[^`]+`');

    return markdownText.replaceAllMapped(codeRegionPattern, (regionMatch) {
      final region = regionMatch.group(0)!;
      // Replace every emoji character inside this code region
      return region.replaceAllMapped(emojiPattern, (emojiMatch) {
        final emoji = emojiMatch.group(0)!;
        // Build "U+XXXX" for each code unit in the emoji
        final codePoints = emoji.runes
            .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
            .join('');
        return codePoints;
      });
    });
  }
}


/// Helper class to store code block match information.
class _CodeBlockMatch {
  final int start;
  final int end;
  final String content;
  
  _CodeBlockMatch(this.start, this.end, this.content);
}
