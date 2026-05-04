import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import '../../../../shared_ui/src/keyboard_height/keyboard_height_plugin.dart';

// Import extracted widgets
import 'message_composer_send_button.dart';
import 'message_composer_secondary_buttons.dart';
import 'message_composer_auxiliary_buttons.dart';
import 'message_composer_suggestion_list.dart';
import 'attachment_options_overlay.dart';

// Import rich text formatting
import '../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_type.dart';


// Import inline audio recorder
import 'inline_audio_recorder/inline_audio_recorder.dart';
import '../utils/composer_attachment_utils.dart';

///
/// [CometChatMessageComposer] component allows users to
/// send messages and attachments to the chat, participating in the conversation.
///
/// ```dart
///  CometChatMessageComposer(
///        user: User(uid: 'uid', name: 'name'),
///        group: Group(guid: 'guid', name: 'name', type: 'public'),
///        messageComposerStyle: MessageComposerStyle(),
///        stateCallBack: (MessageComposerBloc bloc) {},
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
    this.useInlineAudioRecorder = true,
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
    this.disableMentionAll = false,
    this.mentionAllLabel,
    this.mentionAllLabelId,
    this.richTextConfiguration,
    this.richTextToolbarView,
    this.onRichTextFormatApplied,
    this.hideBottomSafeArea = false,
    this.resizeToAvoidBottomInset = false,
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

  ///[useInlineAudioRecorder] when true, shows inline audio recorder in the composer
  ///instead of opening a bottom sheet. Defaults to true.
  final bool useInlineAudioRecorder;

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
  ///Now returns MessageComposerBloc instead of the old controller
  final void Function(MessageComposerBloc bloc)? stateCallBack;

  ///[onError] callback to handle error
  final OnError? onError;

  ///[onSendButtonTap] callback to handle send button tap
  final Function(
      BuildContext context,
      BaseMessage message,
      PreviewMessageMode? previewMessageMode,
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

  ///[disableMentionAll] is a boolean which is used to disable @all mentions in groups
  final bool disableMentionAll;

  ///[mentionAllLabel] is a String which is used to set a custom label for @all mentions
  final String? mentionAllLabel;

  ///[mentionAllLabelId] is a String which is used to set a custom label ID for @all mentions
  final String? mentionAllLabelId;

  ///[richTextConfiguration] configuration for rich text formatting toolbar
  final RichTextConfiguration? richTextConfiguration;

  ///[richTextToolbarView] custom view for rich text toolbar
  final Widget Function(
      BuildContext context,
      TextEditingController controller,
      RichTextFormatterManager manager,
      )? richTextToolbarView;

  ///[onRichTextFormatApplied] callback when rich text format is applied
  final void Function(RichTextFormatType formatType)? onRichTextFormatApplied;

  ///[hideBottomSafeArea] when true, hides the bottom safe area padding.
  ///Use this when the parent widget handles safe area/keyboard positioning.
  final bool hideBottomSafeArea;

  ///[resizeToAvoidBottomInset] when true, indicates the parent Scaffold has
  ///`resizeToAvoidBottomInset: true` and will handle keyboard insets itself.
  ///The composer will skip its internal keyboard height tracking and bottom
  ///padding. Defaults to false — the composer manages keyboard spacing
  ///internally and the parent Scaffold should set `resizeToAvoidBottomInset: false`.
  final bool resizeToAvoidBottomInset;

  @override
  State<CometChatMessageComposer> createState() =>
      _CometChatMessageComposerState();
}

class _CometChatMessageComposerState extends State<CometChatMessageComposer>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // ============================================================================
  // BLoC and State Management
  // ============================================================================
  late MessageComposerBloc _bloc;
  late Map<String, dynamic> _composerId;

  // ============================================================================
  // Theme and Styling
  // ============================================================================
  late CometChatMessageComposerStyle _style;
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;
  late CometChatTypography _typography;
  late CometChatSuggestionListStyle _suggestionListStyle;

  // ============================================================================
  // Text Editing and Formatters
  // ============================================================================
  TextEditingController? _textEditingController;
  bool _isMyController = true;
  late FocusNode _focusNode;
  List<CometChatTextFormatter> _formatters = [];

  // ============================================================================
  // Suggestion List
  // ============================================================================
  List<SuggestionListItem> _suggestions = [];
  late StreamSubscription<List<SuggestionListItem>> _subscription;
  final StreamController<List<SuggestionListItem>> _suggestionListController =
  StreamController<List<SuggestionListItem>>();
  late Stream<List<SuggestionListItem>> _suggestionListStream;
  final StreamController<String> _previousTextController =
  StreamController<String>();
  late Stream<String> _previousTextStream;
  String _previousText = '';
  String? _currentSearchKeyword;
  bool _searchKeywordChanged = true;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // ============================================================================
  // Attachment Options
  // ============================================================================
  final List<ActionItem> _actionItems = [];
  bool _getAttachmentOptionsCalled = false;
  CometChatAttachmentOptionSheetStyle? _actionStyle;

  // Flag to track if theme has been initialized (prevents re-init during keyboard animation)
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;
  // Keyboard Height Tracking (for instant keyboard positioning)
  // ============================================================================
  final ValueNotifier<double> _bottomPaddingNotifier = ValueNotifier<double>(0);
  double _safeAreaBottom = 0;
  double _maxBottomHeight = 0;  // Max height = keyboard height (when keyboard is open)
  double _lastStickerTotalHeight = 0;  // Total height when sticker keyboard was shown (for smooth transition)
  double _lastBottomPadding = 0;  // Track last padding to detect sudden jumps
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  bool _isDisposing = false;  // Prevents keyboard height updates during navigation
  bool _isKeyboardVisible = false;  // Track keyboard visibility
  
  // Debouncing for fast transitions
  Timer? _keyboardHeightDebouncer;
  double _pendingPadding = 0;  // Pending padding value during debounce
  bool _isTransitioning = false;  // True when transitioning between keyboard/sticker

  // Track whether text field has content (for mic button visibility)
  bool _hadText = false;
  static const Duration _debounceDelay = Duration(milliseconds: 50);  // Short debounce for fast transitions
  
  // Timer to clear sticker height after transition window
  Timer? _stickerHeightClearTimer;
  static const Duration _stickerHeightClearDelay = Duration(milliseconds: 300);  // Reduced from 500ms
  bool _expectingKeyboardOpen = false;  // True when we just closed sticker and expect keyboard to open

  // Sticker panel extra height added by drag gesture
  final ValueNotifier<double> _stickerExtraHeight = ValueNotifier<double>(0);
  
  // Stable keyboard height - the height after keyboard animation settles
  // This is used to prevent jiggle when keyboard height fluctuates during animation
  double _stableKeyboardHeight = 0;
  Timer? _stableHeightTimer;
  static const Duration _stableHeightDelay = Duration(milliseconds: 150);  // Wait for keyboard to settle
  
  // Maximum allowed change per update to prevent sudden jumps (in logical pixels)
  // This smooths out rapid state changes during transitions
  static const double _maxPaddingChangePerUpdate = 100.0;

  // Resume protection: after app resumes with keyboard open, ignore spurious
  // close events that the OS fires as part of the resume cycle.
  bool _ignoreNextKeyboardClose = false;
  Timer? _resumeProtectionTimer;

  // ============================================================================
  // Overlay and Preview
  // ============================================================================
  final OverlayPortalController _overlayPortalController =
  OverlayPortalController();

  // ============================================================================
  // Reply/Edit Preview Animation
  // ============================================================================
  late final AnimationController _previewAnimController;
  late final Animation<Offset> _previewSlideAnimation;
  late final Animation<double> _previewFadeAnimation;
  bool _previewVisible = false;
  // Cached preview data so content remains visible during reverse animation
  String _lastPreviewTitle = '';
  String _lastPreviewSubtitle = '';
  Widget? _lastPreviewSubtitleWidget;
  BaseMessage? _lastPreviewMessage;

  // Attachment overlay state management
  final LayerLink _attachmentButtonLink = LayerLink();
  final LayerLink _composerLink = LayerLink();  // Link for positioning overlay above composer
  final OverlayPortalController _attachmentOverlayController =
  OverlayPortalController();
  final ValueNotifier<bool> _attachmentOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _suggestionOpenNotifier = ValueNotifier<bool>(false);

  // ============================================================================
  // Auxiliary Options
  // ============================================================================
  Widget? _auxiliaryOptions;

  // ============================================================================
  // Rich Text Formatting
  // ============================================================================
  RichTextFormatterManager? _richTextFormatterManager;
  /// Single unified markdown formatter for bubble display (replaces 10+ legacy formatter instances)
  MarkdownTextFormatter? _markdownFormatter;
  bool _showRichTextToolbar = false;
  
  /// ValueNotifier for active formats - only rebuilds toolbar when formats change
  final ValueNotifier<Set<FormatType>> _activeFormatsNotifier = 
      ValueNotifier<Set<FormatType>>({});
  
  /// Track previous active formats to detect changes
  Set<FormatType> _previousActiveFormats = {};
  
  /// Segment-based composer controller for Slack-style code blocks
  /// When active, code blocks are rendered as separate segments with their own text fields
  SegmentComposerController? _segmentComposerController;
  
  /// Whether segment-based code blocks are enabled
  bool get _useSegmentBasedCodeBlocks => _segmentComposerController != null;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  void initState() {
    super.initState();
    
    // Initialize reply/edit preview animation
    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _previewAnimController.addStatusListener((status) {
      // Rebuild when reverse animation completes to remove cached preview content
      if (status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
    _previewSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _previewAnimController,
      curve: Curves.easeOutCubic,
    ));
    _previewFadeAnimation = CurvedAnimation(
      parent: _previewAnimController,
      curve: Curves.easeOut,
    );

    // Register for metrics changes (keyboard open/close)
    WidgetsBinding.instance.addObserver(this);

    // Initialize text editing controller
    if (widget.textEditingController != null) {
      _textEditingController = widget.textEditingController;
      _isMyController = false;
    }

    // Initialize composer ID
    _composerId = _buildComposerId();

    // Initialize streams
    _suggestionListStream = _suggestionListController.stream;
    _previousTextStream = _previousTextController.stream;

    // Subscribe to suggestion stream
    _subscription = _suggestionListStream.listen(_onSuggestionListUpdate);
    _previousTextStream.listen((value) => _previousText = value);

    // Initialize focus node
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Initialize service locator
    if (!MessageComposerServiceLocator.instance.isInitialized) {
      MessageComposerServiceLocator.instance.setup();
    }

    // Initialize keyboard height listener for instant keyboard positioning
    // Native plugin provides real-time keyboard height updates
    // Skip when resizeToAvoidBottomInset is true — the parent Scaffold handles keyboard insets
    if (!widget.resizeToAvoidBottomInset) {
    _keyboardHeightPlugin.onKeyboardHeightChanged((double keyboardHeight, double safeAreaBottom) {
      // Skip updates during disposal to prevent jumps during navigation
      if (_isDisposing) return;
      
      // Update safe area from native (more reliable than Flutter's MediaQuery during animations)
      if (safeAreaBottom > 0) {
        _safeAreaBottom = safeAreaBottom;
      }
      
      // Track keyboard visibility
      final wasKeyboardVisible = _isKeyboardVisible;
      _isKeyboardVisible = keyboardHeight > 0;
      
      // Detect transition (keyboard visibility changed)
      final isVisibilityChange = wasKeyboardVisible != _isKeyboardVisible;

      // Resume protection: the OS sometimes fires a spurious close event right
      // after the open event when the app returns from background. Ignore it.
      if (isVisibilityChange && !_isKeyboardVisible && _ignoreNextKeyboardClose) {
        _isKeyboardVisible = true; // revert — keyboard is actually still open
        _ignoreNextKeyboardClose = false;
        _resumeProtectionTimer?.cancel();
        return;
      }

      if (isVisibilityChange) {
        _isTransitioning = true;
        // Cancel any pending debounced update
        _keyboardHeightDebouncer?.cancel();
      }
      
      // Track max bottom height when keyboard is open
      // IMPORTANT: Native keyboard height ALREADY includes safe area (on iOS: keyboardFrame.height,
      // on Android: screenHeight - visibleArea which includes nav bar)
      // So we DON'T add safe area again here
      if (_isKeyboardVisible) {
        _maxBottomHeight = keyboardHeight;
        // Keyboard opened - clear the expectation flag
        if (isVisibilityChange) {
          _expectingKeyboardOpen = false;
          _stickerHeightClearTimer?.cancel();
        }
        
        // Update stable keyboard height after a delay (when keyboard settles)
        // This prevents using fluctuating heights during animation
        // Only set stable height if we don't have one yet (first keyboard open)
        // This ensures we use a consistent height for the session
        if (_stableKeyboardHeight == 0) {
          _stableHeightTimer?.cancel();
          _stableHeightTimer = Timer(_stableHeightDelay, () {
            if (_isKeyboardVisible && !_isDisposing && _stableKeyboardHeight == 0) {
              _stableKeyboardHeight = _maxBottomHeight;
            }
          });
        }
      } else {
        // Keyboard closed - cancel stable height timer but DON'T clear stable height
        // We keep the stable height for future keyboard opens
        _stableHeightTimer?.cancel();
      }
      
      // Calculate target bottom padding
      // When keyboard is visible:
      //   - If we have a stable height cached, use it to prevent jiggle
      //   - Otherwise use the current keyboard height
      // When keyboard is closed:
      //   - If expecting keyboard to open (sticker→keyboard transition), maintain last sticker height
      //   - Otherwise, use safe area bottom
      double targetPadding;
      if (_isKeyboardVisible) {
        // Use stable height if available, otherwise use current height
        // This prevents the 383→336 jiggle during keyboard animation
        if (_stableKeyboardHeight > 0) {
          targetPadding = _stableKeyboardHeight;
        } else {
          targetPadding = keyboardHeight;
        }
      } else if (_expectingKeyboardOpen && _lastStickerTotalHeight > 0) {
        // During sticker→keyboard transition, maintain sticker height to prevent jump
        targetPadding = _lastStickerTotalHeight;
      } else {
        targetPadding = _safeAreaBottom;
      }
      
      // For visibility changes (keyboard opening/closing), apply immediately
      // For intermediate updates during animation, debounce to prevent jitter
      if (isVisibilityChange) {
        // Immediate update for visibility changes
        _applyBottomPadding(targetPadding);
        
        // Schedule end of transition after a short delay
        _keyboardHeightDebouncer?.cancel();
        _keyboardHeightDebouncer = Timer(_debounceDelay * 2, () {
          _isTransitioning = false;
        });
      } else if (_isTransitioning) {
        // During transition, debounce intermediate updates
        _pendingPadding = targetPadding;
        _keyboardHeightDebouncer?.cancel();
        _keyboardHeightDebouncer = Timer(_debounceDelay, () {
          if (!_isDisposing) {
            _applyBottomPadding(_pendingPadding);
          }
        });
      } else {
        // Normal update (not transitioning)
        _applyBottomPadding(targetPadding);
      }
    });
    } // end if (!widget.resizeToAvoidBottomInset)
  }
  
  /// Applies the bottom padding with change capping to prevent sudden jumps
  void _applyBottomPadding(double targetPadding) {
    double newPadding = targetPadding;
    
    // Apply smooth transition to prevent sudden jumps
    // But allow larger changes during transitions
    if (_lastBottomPadding > 0 && !_isTransitioning) {
      final change = targetPadding - _lastBottomPadding;
      if (change.abs() > _maxPaddingChangePerUpdate) {
        // Large change detected - this might be a glitch, cap it
        // But allow it if it's moving towards safe area (closing) or max height (opening)
        if (targetPadding != _safeAreaBottom && targetPadding != _maxBottomHeight) {
          newPadding = _lastBottomPadding + (change > 0 ? _maxPaddingChangePerUpdate : -_maxPaddingChangePerUpdate);
        }
      }
    }
    
    _lastBottomPadding = newPadding;
    
    _bottomPaddingNotifier.value = newPadding;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;

    // Cache safe area bottom for keyboard positioning
    _safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    // Initialize bottom padding with safe area (keyboard closed state)
    // But if keyboard is already open (e.g. hot restart), use viewInsets instead
    final currentViewInsets = MediaQuery.viewInsetsOf(context).bottom;
    if (currentViewInsets > 0) {
      // Keyboard is already open — seed with keyboard height
      _bottomPaddingNotifier.value = currentViewInsets;
      _isKeyboardVisible = true;
      _maxBottomHeight = currentViewInsets;
      _stableKeyboardHeight = currentViewInsets;
    } else {
      _bottomPaddingNotifier.value = _safeAreaBottom;
    }

    // Initialize theme
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _typography = CometChatThemeHelper.getTypography(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
    _style = CometChatThemeHelper.getTheme<CometChatMessageComposerStyle>(
      context: context,
      defaultTheme: CometChatMessageComposerStyle.of,
    ).merge(widget.messageComposerStyle);

    _suggestionListStyle =
        CometChatThemeHelper.getTheme<CometChatSuggestionListStyle>(
          context: context,
          defaultTheme: CometChatSuggestionListStyle.of,
        ).merge(_style.suggestionListStyle);

    // Initialize BLoC
    _initializeBloc();

    // Initialize formatters
    _initializeFormatters();

    // Initialize rich text formatter manager (must be before text controller creation)
    _initializeRichTextFormatting();

    // Initialize text editing controller with formatters
    // Use RichTextEditingController for WYSIWYG mode when rich text is enabled
    if (_textEditingController == null) {
      if (widget.richTextConfiguration != null && 
          widget.richTextConfiguration!.shouldShowToolbar) {
        _textEditingController = RichTextEditingController(
          text: widget.text,
          formatters: _formatters,
        );
        // Add listener to update toolbar when selection changes (cursor moves into formatted text)
        _textEditingController!.addListener(_onRichTextControllerChanged);
        // Add listener to track text empty/non-empty for mic button visibility
        _textEditingController!.addListener(_onTextEmptyChanged);

        // Wire up link tap handler for Edit / Remove popup
        (_textEditingController as RichTextEditingController).onLinkTap = _onLinkTapped;

        // Wire up formatter notification for programmatic text changes
        // (editLinkFormat / removeLinkFormat) so mentions etc. stay in sync.
        (_textEditingController as RichTextEditingController).onFormatterTextChanged = _onFormatterTextChanged;
        
        // Wire up segment controller to RichTextEditingController AFTER controller is created
        if (_segmentComposerController != null) {
          (_textEditingController as RichTextEditingController).onInsertCodeBlock = 
              _segmentComposerController!.toggleCodeBlock;
        }
      } else {
        _textEditingController = CustomTextEditingController(
          text: widget.text,
          formatters: _formatters,
        );
        // Add listener to track text empty/non-empty for mic button visibility
        _textEditingController!.addListener(_onTextEmptyChanged);
      }
    }

    // Initialize attachment options
    if (!_getAttachmentOptionsCalled) {
      _getAttachmentOptionsCalled = true;
      _getAttachmentOptions();
    }

    // Initialize auxiliary options
    _auxiliaryOptions = _initAuxiliaryOptions();
  }

  @override
  void didUpdateWidget(covariant CometChatMessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize style if messageComposerStyle changed
    if (widget.messageComposerStyle != oldWidget.messageComposerStyle) {
      _style = CometChatThemeHelper.getTheme<CometChatMessageComposerStyle>(
        context: context,
        defaultTheme: CometChatMessageComposerStyle.of,
      ).merge(widget.messageComposerStyle);

      // Reinitialize auxiliary options since they depend on style
      _auxiliaryOptions = _initAuxiliaryOptions();
    }

    // Reinitialize rich text formatting if configuration changed
    if (widget.richTextConfiguration != oldWidget.richTextConfiguration) {
      _initializeRichTextFormatting();
    }

    // Reinitialize auxiliary options if relevant props changed
    if (widget.hideStickersButton != oldWidget.hideStickersButton) {
      _auxiliaryOptions = _initAuxiliaryOptions();
    }

    // Force rebuild if any visual property changed
    if (widget.messageComposerStyle != oldWidget.messageComposerStyle ||
        widget.richTextConfiguration != oldWidget.richTextConfiguration ||
        widget.hideStickersButton != oldWidget.hideStickersButton ||
        widget.hideSendButton != oldWidget.hideSendButton ||
        widget.hideAttachmentButton != oldWidget.hideAttachmentButton ||
        widget.hideVoiceRecordingButton != oldWidget.hideVoiceRecordingButton ||
        widget.placeholderText != oldWidget.placeholderText ||
        widget.maxLine != oldWidget.maxLine) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeMetrics() {
    // Called when keyboard finishes animating (viewInsets change)
    // Only reset keyboard height when keyboard is ACTUALLY closed
    // (not during the opening animation when viewInsets is still 0)
    if (_isDisposing) return;
    
    // Don't update keyboard height if we're not the current route (navigating away)
    // This prevents the composer from jumping when Navigator.pop is called
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return;
    }
    
    final viewInsets = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets;
    final bottomInset = viewInsets.bottom / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    
    // Only reset if:
    // 1. viewInsets shows keyboard is closed (bottomInset == 0)
    // 2. Our notifier still has a value > safe area (meaning we were tracking an open keyboard)
    if (bottomInset == 0 && _bottomPaddingNotifier.value > _safeAreaBottom && !_isKeyboardVisible) {
      _bottomPaddingNotifier.value = _safeAreaBottom;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposing || !mounted) return;

    if (state == AppLifecycleState.resumed) {
      // App came back to foreground — re-sync keyboard state.
      // The keyboard height plugin may not re-fire after resume, so we
      // read viewInsets directly to determine if the keyboard is still open.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposing || !mounted) return;

        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
        final keyboardOpen = bottomInset > 0;

        if (keyboardOpen) {
          // Keyboard is open — ensure our state reflects that and padding is correct.
          _isKeyboardVisible = true;
          final targetPadding = _stableKeyboardHeight > 0
              ? _stableKeyboardHeight
              : (_maxBottomHeight > 0 ? _maxBottomHeight : bottomInset);
          _applyBottomPadding(targetPadding);
        } else if (!keyboardOpen && _isKeyboardVisible) {
          // Keyboard closed while in background — reset to safe area.
          _ignoreNextKeyboardClose = false;
          _resumeProtectionTimer?.cancel();
          _isKeyboardVisible = false;
          _applyBottomPadding(_safeAreaBottom);
        }

        // Defer clearing the protection flag to a second post-frame callback.
        // The keyboard height plugin may fire spurious close events during the
        // current or next frame after resume. Clearing too early lets those
        // events through, causing the composer to drop below the keyboard.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isDisposing || !mounted) return;
          _ignoreNextKeyboardClose = false;
          _resumeProtectionTimer?.cancel();
        });
      });
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.inactive) {
      // Going to background — reset transition flags so we start clean on resume.
      // Pre-arm the resume protection: if the keyboard is currently open, we expect
      // the plugin to fire open+close on resume. Set the flag now so it's ready
      // before any plugin callbacks fire (postFrameCallback would be too late).
      _isTransitioning = false;
      _keyboardHeightDebouncer?.cancel();
      if (_isKeyboardVisible) {
        _ignoreNextKeyboardClose = true;
        _resumeProtectionTimer?.cancel();
        // Auto-clear after a generous window in case resume never comes
        _resumeProtectionTimer = Timer(const Duration(seconds: 3), () {
          _ignoreNextKeyboardClose = false;
        });
      }
    }
  }

  @override
  void activate() {
    super.activate();
    // Reset the flag set by deactivate() — the widget is back in the tree
    // (e.g. user navigated back from image viewer / thread).
    _isDisposing = false;

    // Re-sync keyboard state from the current view insets so the composer
    // picks up the correct bottom padding after returning from navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposing) return;

      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
      final keyboardOpen = bottomInset > 0;

      if (keyboardOpen) {
        _isKeyboardVisible = true;
        final targetPadding = _stableKeyboardHeight > 0
            ? _stableKeyboardHeight
            : (_maxBottomHeight > 0 ? _maxBottomHeight : bottomInset);
        _applyBottomPadding(targetPadding);
      } else {
        _isKeyboardVisible = false;
        _applyBottomPadding(_safeAreaBottom);
      }
    });
  }

  @override
  void deactivate() {
    // Hide overlays, but only if we're not in the middle of a persistent
    // callbacks phase (e.g. during route transitions triggered by a rebuild).
    // Calling OverlayPortalController.hide() during persistentCallbacks
    // triggers a "schedulerPhase != SchedulerPhase.persistentCallbacks"
    // assertion because hide() marks the overlay entry as needing rebuild.
    final phase = SchedulerBinding.instance.schedulerPhase;
    final canHideOverlay = phase != SchedulerPhase.persistentCallbacks;

    if (canHideOverlay) {
      if (_attachmentOverlayController.isShowing) {
        _attachmentOverlayController.hide();
        _attachmentOpenNotifier.value = false;
      }
      if (_overlayPortalController.isShowing) {
        _overlayPortalController.hide();
        _suggestionOpenNotifier.value = false;
      }
    }
    // Set flag early to prevent keyboard height updates during navigation
    // deactivate() is called before dispose() when widget is removed from tree
    _isDisposing = true;
    super.deactivate();
  }

  @override
  void dispose() {
    // Flag already set in deactivate(), but set again for safety
    _isDisposing = true;
    
    // Cancel timers
    _keyboardHeightDebouncer?.cancel();
    _stickerHeightClearTimer?.cancel();
    _stableHeightTimer?.cancel();
    _resumeProtectionTimer?.cancel();
    
    // Remove metrics observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Close BLoC
    _bloc.onFocusRequested = null;
    _bloc.close();

    // Remove rich text controller listener and dispose if we created it
    if (_textEditingController is RichTextEditingController) {
      _textEditingController!.removeListener(_onRichTextControllerChanged);
      _textEditingController!.removeListener(_onTextEmptyChanged);
      // Clear callbacks
      (_textEditingController as RichTextEditingController).onInsertCodeBlock = null;
      (_textEditingController as RichTextEditingController).onLinkTap = null;
      (_textEditingController as RichTextEditingController).onFormatterTextChanged = null;
    } else {
      // Remove text empty listener for non-rich-text controller
      _textEditingController?.removeListener(_onTextEmptyChanged);
    }
    if (_isMyController) {
      _textEditingController?.dispose();
    }
    
    // Dispose segment composer controller
    _segmentComposerController?.dispose();
    _segmentComposerController = null;

    // Dispose focus node
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    // Cancel subscriptions
    _subscription.cancel();
    _suggestionListController.close();
    _previousTextController.close();

    // Dispose keyboard height plugin and notifiers
    _keyboardHeightPlugin.dispose();
    _bottomPaddingNotifier.dispose();
    _attachmentOpenNotifier.dispose();
    _suggestionOpenNotifier.dispose();
    _activeFormatsNotifier.dispose();
    _previewAnimController.dispose();

    super.dispose();
  }

  // ============================================================================
  // Initialization Methods
  // ============================================================================

  void _initializeBloc() {
    _bloc = MessageComposerBloc(
      context: context,
      user: widget.user,
      group: widget.group,
      parentMessageId: widget.parentMessageId,
      disableTypingEvents: widget.disableTypingEvents,
      disableSoundForMessages: widget.disableSoundForMessages,
      customSoundForMessage: widget.customSoundForMessage,
      customSoundForMessagePackage: widget.customSoundForMessagePackage,
      onSendButtonTap: widget.onSendButtonTap,
      errorCallback: widget.onError,
    );

    // Provide state callback for backward compatibility
    if (widget.stateCallBack != null) {
      widget.stateCallBack!(_bloc);
    }

    // Wire up focus request callback so BLoC can request focus without owning FocusNode
    _bloc.onFocusRequested = () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    };
  }

  Map<String, dynamic> _buildComposerId() {
    final Map<String, dynamic> composerId = {};
    if (widget.parentMessageId != 0) {
      composerId['parentMessageId'] = widget.parentMessageId;
    }
    if (widget.group != null) {
      composerId['guid'] = widget.group!.guid;
    } else if (widget.user != null) {
      composerId['uid'] = widget.user!.uid;
    }
    return composerId;
  }

  void _initializeFormatters() {
    _formatters = widget.textFormatters ?? [];

    int mentionFormatterIndex = _formatters
        .indexWhere((element) => element is CometChatMentionsFormatter);

    if (widget.disableMentions != true) {
      if (mentionFormatterIndex != -1) {
        _formatters[mentionFormatterIndex] = CometChatMentionsFormatter(
          style: _style.mentionsStyle,
          disableMentionAll: widget.disableMentionAll,
          mentionAllLabel: widget.mentionAllLabel,
          mentionAllLabelId: widget.mentionAllLabelId,
        );
      } else {
        var formatter = CometChatMentionsFormatter(
          style: _style.mentionsStyle,
          disableMentionAll: widget.disableMentionAll,
          mentionAllLabelId: widget.mentionAllLabelId,
          mentionAllLabel: widget.mentionAllLabel,
        );
        _formatters.add(formatter);
      }
    }

    for (var element in _formatters) {
      element.composerId = _composerId;
      element.suggestionListEventSink = _suggestionListController.sink;
      element.previousTextEventSink = _previousTextController.sink;
      element.onSearch = _onFormatterSearch;
      element.user = widget.user;
      element.group = widget.group;
      element.init();
    }
  }

  Widget? _initAuxiliaryOptions() {
    // If user provided a custom auxiliary button view, use that
    if (widget.auxiliaryButtonView != null) {
      return widget.auxiliaryButtonView!(
        context,
        widget.user,
        widget.group,
        _composerId,
      );
    }

    // Hide sticker button if explicitly requested
    if (widget.hideStickersButton == true) {
      return null;
    }

    return StickerAuxiliaryButton(
      onStickerTap: () {
        // Capture the keyboard height before dismissing so we can size the
        // sticker keyboard to match. Use stable height if available (avoids
        // jiggle from animation frames), otherwise fall back to current max.
        final double knownKeyboardHeight = _stableKeyboardHeight > 0
            ? _stableKeyboardHeight
            : _maxBottomHeight;

        // Dismiss OS keyboard by unfocusing whatever currently has focus.
        // Using primaryFocus instead of _focusNode because the active focus
        // may be on a segment composer's focus node, not the main text field.
        FocusManager.instance.primaryFocus?.unfocus();

        // Dismiss attachment overlay if showing
        if (_attachmentOverlayController.isShowing) {
          _attachmentOverlayController.hide();
          _attachmentOpenNotifier.value = false;
        }

        // Calculate sticker keyboard content height.
        // knownKeyboardHeight is the full keyboard frame (includes safe area
        // on iOS). The sticker keyboard widget only needs the content portion;
        // safe area padding is handled by _buildBottomArea.
        final double stickerContentHeight = knownKeyboardHeight > _safeAreaBottom
            ? knownKeyboardHeight - _safeAreaBottom
            : CometChatStickerKeyboard.defaultHeight;

        // Reset any previous drag extra height
        _stickerExtraHeight.value = 0;

        // Show sticker keyboard in the footer panel
        CometChatUIEvents.showPanel(
          _composerId,
          CustomUIPosition.composerBottom,
          (context) => CometChatStickerKeyboard(
            height: stickerContentHeight,
            onStickerTap: (Sticker sticker) {
              _bloc.add(SendCustomMessage(
                customData: {
                  'sticker_url': sticker.stickerUrl,
                  'sticker_name': sticker.stickerName,
                },
                type: ExtensionType.sticker,
              ));
              // Keep sticker keyboard open so user can send more stickers.
              // User can dismiss it manually via the keyboard toggle button.
            },
          ),
        );
      },
      onKeyboardTap: () {
        // Close the sticker panel and collapse the bottom area.
        _lastStickerTotalHeight = 0;
        _expectingKeyboardOpen = false;
        _stickerHeightClearTimer?.cancel();
        _resetStickerExtraHeight();

        CometChatUIEvents.hidePanel(
          _composerId,
          CustomUIPosition.composerBottom,
        );

        if (mounted && !_isDisposing) {
          _bottomPaddingNotifier.value = _safeAreaBottom;
        }
      },
    );
  }

  void _initializeRichTextFormatting() {
    // Remove old markdown formatter from the formatters list
    if (_markdownFormatter != null) {
      _formatters.remove(_markdownFormatter);
      _markdownFormatter = null;
    }
    // Remove old legacy rich text formatters if any remain
    if (_richTextFormatterManager != null) {
      final oldFormatters = _richTextFormatterManager!.activeFormatters;
      _formatters.removeWhere((f) => oldFormatters.contains(f));
      _richTextFormatterManager = null;
    }
    
    // Dispose old segment controller if exists
    _segmentComposerController?.dispose();
    _segmentComposerController = null;

    // Use provided configuration or default configuration with all formats enabled
    final config = widget.richTextConfiguration ?? const RichTextConfiguration(
      toolbarMode: RichTextToolbarMode.disabled, // No toolbar by default
      previewMode: RichTextPreviewMode.disabled, // No preview by default
      enableBold: true,
      enableItalic: true,
      enableStrikethrough: true,
      enableInlineCode: true,
      enableCodeBlock: true,
      enableLinks: true,
      enableBulletList: true,
      enableOrderedList: true,
      enableBlockquote: true,
    );

    if (config.hasAnyFormatEnabled) {
      // Use unified MarkdownTextFormatter for bubble display (replaces 10+ legacy classes)
      _markdownFormatter = MarkdownTextFormatter(
        enableBold: config.enableBold,
        enableItalic: config.enableItalic,
        enableStrikethrough: config.enableStrikethrough,
        enableUnderline: config.enableUnderline,
        enableInlineCode: config.enableInlineCode,
        enableCodeBlock: config.enableCodeBlock,
        enableLink: config.enableLinks,
        enableBulletList: config.isBulletListEnabled,
        enableOrderedList: config.isOrderedListEnabled,
        enableBlockquote: config.isBlockquoteEnabled,
      );
      _formatters.add(_markdownFormatter!);

      // Keep legacy manager for composer-side operations (toolbar, link dialog, preview, Enter handling)
      _richTextFormatterManager = RichTextFormatterManager(
        configuration: config,
      );

      // Set up callback
      _richTextFormatterManager!.onFormatApplied = (formatType, newText) {
        widget.onRichTextFormatApplied?.call(formatType);
      };
      
      // Initialize segment-based code blocks if code blocks are enabled and toolbar is visible
      if (config.enableCodeBlock && config.shouldShowToolbar) {
        _segmentComposerController = SegmentComposerController();
        // Pass text formatters (mentions, etc.) so normal segments use
        // CustomTextEditingController for styled text display
        _segmentComposerController!.formatters = _formatters.isNotEmpty ? _formatters : null;
        // Wire link tap handler so tapping a link in any segment shows Edit / Remove
        _segmentComposerController!.onLinkTap = _onLinkTapped;
        // Wire formatter notification for programmatic text changes in segments
        _segmentComposerController!.onFormatterTextChanged = _onFormatterTextChanged;
        _segmentComposerController!.addListener(() {
          if (!mounted) return;
          // Update active formats notifier so toolbar reflects code block state
          final currentFormats = _getActiveFormats();
          if (!_setEquals(currentFormats, _previousActiveFormats)) {
            _previousActiveFormats = currentFormats;
            _activeFormatsNotifier.value = currentFormats;
          }

          // When any segment gets focus, hide sticker keyboard and unlock bottom padding
          // (mirrors _onFocusChange behavior for the regular text field)
          final focused = _segmentComposerController!.focusedSegment;
          if (focused != null) {
            CometChatUIEvents.hidePanel(_composerId, CustomUIPosition.composerBottom);
            CometChatUIEvents.unlockBottomPadding(_composerId);
            _resetStickerExtraHeight();
            if (_attachmentOverlayController.isShowing) {
              _hideAttachmentOverlay();
            }
          }

          setState(() {});
        });
        
        // Note: onInsertCodeBlock is wired up in didChangeDependencies after text controller is created
      }

      // Update toolbar visibility based on mode
      _updateRichTextToolbarVisibility();
    } else {
      // No rich text formatting enabled
      _showRichTextToolbar = false;
    }
  }

  void _updateRichTextToolbarVisibility() {
    if (_richTextFormatterManager == null) {
      _showRichTextToolbar = false;
      return;
    }

    // Use provided configuration or check if toolbar should be hidden by default
    final config = widget.richTextConfiguration;
    if (config == null) {
      // No explicit configuration - toolbar is disabled by default
      _showRichTextToolbar = false;
      return;
    }

    final mode = config.toolbarMode;
    switch (mode) {
      case RichTextToolbarMode.disabled:
        _showRichTextToolbar = false;
        break;
      case RichTextToolbarMode.alwaysVisible:
        _showRichTextToolbar = true;
        break;
      case RichTextToolbarMode.onSelection:
      // Show toolbar when text is typed (not empty)
        _showRichTextToolbar = _textEditingController != null &&
            _textEditingController!.text.trim().isNotEmpty;
        break;
    }
  }

  void _getAttachmentOptions() {
    final attachmentOptionSheetStyle =
    CometChatThemeHelper.getTheme<CometChatAttachmentOptionSheetStyle>(
      context: context,
      defaultTheme: CometChatAttachmentOptionSheetStyle.of,
    ).merge(_style.attachmentOptionSheetStyle);

    if (widget.attachmentOptions != null) {
      List<CometChatMessageComposerAction> actionList =
      widget.attachmentOptions!(context, widget.user, widget.group, {});

      for (CometChatMessageComposerAction attachmentOption in actionList) {
        _actionStyle = CometChatAttachmentOptionSheetStyle(
          border: attachmentOption.style?.border ??
              attachmentOptionSheetStyle.border,
          borderRadius: attachmentOption.style?.borderRadius ??
              attachmentOptionSheetStyle.borderRadius,
          titleColor: attachmentOption.style?.titleColor ??
              attachmentOptionSheetStyle.titleColor,
          backgroundColor: attachmentOption.style?.backgroundColor ??
              attachmentOptionSheetStyle.backgroundColor,
          iconColor: attachmentOption.style?.iconColor ??
              attachmentOptionSheetStyle.iconColor,
          titleTextStyle: attachmentOption.style?.titleTextStyle ??
              attachmentOptionSheetStyle.titleTextStyle,
        );
        _actionItems.add(
          ActionItem(
            id: attachmentOption.id,
            title: attachmentOption.title,
            icon: attachmentOption.icon,
            style: CometChatAttachmentOptionSheetStyle(
              titleTextStyle: TextStyle(
                color: _actionStyle?.titleColor,
                fontSize: _typography.body?.regular?.fontSize,
                fontWeight: _typography.body?.regular?.fontWeight,
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
      _getDefaultAttachmentOptions(attachmentOptionSheetStyle);
    }
  }

  void _getDefaultAttachmentOptions(
      CometChatAttachmentOptionSheetStyle attachmentOptionSheetStyle) {
    AdditionalConfigurations additionalConfigurations =
    AdditionalConfigurations(
      attachmentOptionSheetStyle: attachmentOptionSheetStyle,
      hideAudioAttachmentOption: widget.hideAudioAttachmentOption,
      hideCollaborativeDocumentOption: widget.hideCollaborativeDocumentOption,
      hideCollaborativeWhiteboardOption:
      widget.hideCollaborativeWhiteboardOption,
      hideFileAttachmentOption: widget.hideFileAttachmentOption,
      hideImageAttachmentOption: widget.hideImageAttachmentOption,
      hidePollsOption: widget.hidePollsOption,
      hideVideoAttachmentOption: widget.hideVideoAttachmentOption,
      hideTakPhotoOption: widget.hideTakePhotoOption,
    );
    final defaultOptions =
    ComposerAttachmentUtils.getAttachmentOptions(
      context,
      _composerId,
      additionalConfigurations,
    );
    for (CometChatMessageComposerAction defaultAttachmentOptions
    in defaultOptions) {
      _actionStyle = CometChatAttachmentOptionSheetStyle(
        border: defaultAttachmentOptions.style?.border,
        borderRadius: defaultAttachmentOptions.style?.borderRadius,
        titleColor: defaultAttachmentOptions.style?.titleColor,
        backgroundColor: defaultAttachmentOptions.style?.backgroundColor,
        iconColor: defaultAttachmentOptions.style?.iconColor,
        titleTextStyle: defaultAttachmentOptions.style?.titleTextStyle,
      );
      _actionItems.add(
        ActionItem(
          id: defaultAttachmentOptions.id,
          title: defaultAttachmentOptions.title,
          icon: defaultAttachmentOptions.icon,
          style: CometChatAttachmentOptionSheetStyle(
            titleTextStyle: TextStyle(
              color: _actionStyle?.titleColor,
              fontSize: _typography.body?.regular?.fontSize,
              fontWeight: _typography.body?.regular?.fontWeight,
            ).merge(_actionStyle?.titleTextStyle),
            backgroundColor: _actionStyle?.backgroundColor,
            iconColor: _actionStyle?.iconColor,
            titleColor: _actionStyle?.titleColor,
            borderRadius: _actionStyle?.borderRadius,
            border: _actionStyle?.border,
          ).merge(_actionStyle),
          onItemClick: defaultAttachmentOptions.onItemClick,
        ),
      );
    }
  }

  // ============================================================================
  // Focus Debouncer (for keyboard transition performance)
  // ============================================================================
  final Debouncer _focusDebouncer = Debouncer(milliseconds: 250);

  // ============================================================================
  // Event Handlers
  // ============================================================================

  /// Reset sticker drag height when sticker panel closes.
  void _resetStickerExtraHeight() {
    _stickerExtraHeight.value = 0;
  }

  void _onFocusChange() {
    if (!mounted) return;

    if (_focusNode.hasFocus) {
      // When text field gets focus, hide sticker keyboard immediately
      // (no debounce) so the panel disappears as the OS keyboard opens.
      CometChatUIEvents.hidePanel(_composerId, CustomUIPosition.composerBottom);
      CometChatUIEvents.unlockBottomPadding(_composerId);
      _resetStickerExtraHeight();
      // Dismiss attachment overlay when text field gains focus
      if (_attachmentOverlayController.isShowing) {
        _hideAttachmentOverlay();
      }
    } else {
      // Debounce focus-loss to avoid triggering panel events during
      // keyboard animation (e.g. sticker tap calls unfocus first).
      _focusDebouncer.run(() {
        if (!mounted) return;
        _initializeFooterView();
      });
    }
  }

  /// Called on every text change to detect empty↔non-empty transitions.
  /// Triggers setState only when the boolean flips so the auxiliary buttons
  /// (mic) rebuild with the correct hideVoiceRecordingButton value.
  void _onTextEmptyChanged() {
    if (!mounted) return;
    final hasText = _textEditingController!.text.isNotEmpty;
    if (hasText != _hadText) {
      _hadText = hasText;
      setState(() {});
    }
  }

  /// Called when the RichTextEditingController changes (text or selection)
  /// Only updates the ValueNotifier when active formats actually change
  void _onRichTextControllerChanged() {
    if (!mounted) return;
    
    // Get current active formats
    final currentFormats = _getActiveFormats();
    
    // Only update if formats changed (avoid unnecessary rebuilds)
    if (!_setEquals(currentFormats, _previousActiveFormats)) {
      _previousActiveFormats = currentFormats;
      _activeFormatsNotifier.value = currentFormats;
    }
  }
  
  /// Compare two sets for equality
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void _onFormatterSearch(String? searchKeyword) {
    _searchKeywordChanged = _currentSearchKeyword != searchKeyword;
    _currentSearchKeyword = searchKeyword;

    if (_currentSearchKeyword == null) {
      CometChatUIEvents.hidePanel(_composerId, CustomUIPosition.composerPreview);
      _suggestions.clear();
    }
    setState(() {});
  }

  void _onSuggestionListUpdate(List<SuggestionListItem> value) {
    bool shouldScrollDown = false;
    if (value.isNotEmpty && _currentSearchKeyword != null) {
      if (_searchKeywordChanged) {
        _suggestions = value;
        _searchKeywordChanged = false;
      } else {
        for (var element in value) {
          if (!_suggestions.contains(element)) {
            _suggestions.add(element);
          }
        }
        shouldScrollDown = true;
      }
      _hasMore = true;
      setState(() {});

      CometChatUIEvents.showPanel(
        _composerId,
        CustomUIPosition.composerPreview,
            (context) => _buildSuggestionList(),
      );
      _overlayPortalController.show();
      _suggestionOpenNotifier.value = true;
      // Dismiss attachment overlay when suggestion list appears
      if (_attachmentOverlayController.isShowing) {
        _hideAttachmentOverlay();
      }
      if (shouldScrollDown) {
        _scrollDown();
      } else {
        if (_searchKeywordChanged) {
          CometChatUIEvents.hidePanel(
              _composerId, CustomUIPosition.composerPreview);
          _suggestions.clear();
        }
        _hasMore = false;
        setState(() {});
      }
    }
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _checkFormatter() {
    // Use the focused segment's controller when in segment mode,
    // so formatters (mentions, etc.) see the correct text and cursor position.
    final activeController = _getActiveTextController();
    if (activeController == null) return;

    // In segment mode, use the focused segment's per-segment previousText
    // so the mentions formatter doesn't see a diff from a different segment.
    final prevText = _getSegmentPreviousText() ?? _previousText;

    for (var element in _formatters) {
      if (_currentSearchKeyword == null ||
          (_currentSearchKeyword != null &&
              _currentSearchKeyword!.isNotEmpty &&
              element.trackingCharacter == _currentSearchKeyword![0])) {
        try {
          element.onChange(activeController, prevText);
        } catch (err) {
          if (kDebugMode) {
          }
        }
      }
    }
  }

  /// Returns the focused segment's [previousText] when in segment mode,
  /// or null if not in segment mode / no focused segment.
  String? _getSegmentPreviousText() {
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      final focused = _segmentComposerController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.normal) {
        return focused.previousText;
      }
    }
    return null;
  }

  /// Updates the focused segment's [previousText] when in segment mode,
  /// and also keeps the global [_previousText] in sync.
  void _updatePreviousText(String newText) {
    _previousText = newText;
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      final focused = _segmentComposerController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.normal) {
        focused.previousText = newText;
      }
    }
  }

  /// Returns the text controller that formatters should operate on.
  /// In segment mode, returns the focused normal segment's controller
  /// so mentions/suggestions work within the active segment.
  /// Falls back to the main _textEditingController otherwise.
  TextEditingController? _getActiveTextController() {
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      final focused = _segmentComposerController!.focusedSegment;
      if (focused != null && focused.type == SegmentType.normal) {
        return focused.controller;
      }
      // If focused segment is code or null, don't run formatters
      return null;
    }
    return _textEditingController;
  }

  void _onTyping() {
    final activeController = _getActiveTextController();
    // Allow typing events even when no active text controller (e.g. code segment)
    // but skip formatter checks
    if (activeController == null) {
      if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
        // Still trigger typing event for code segments
        _bloc.add(const StartTyping());
      }
      return;
    }
    // Use per-segment previousText in segment mode so formatter diffs are correct
    final prevText = _getSegmentPreviousText() ?? _previousText;
    if ((prevText.isEmpty && activeController.text.isNotEmpty) ||
        (prevText.isNotEmpty && activeController.text.isEmpty)) {
      setState(() {});
    }
    if (prevText.length > activeController.text.length) {
      _checkFormatter();
      _updatePreviousText(activeController.text);
      return;
    }

    _checkFormatter();
    _updatePreviousText(activeController.text);

    // Trigger typing event through BLoC
    _bloc.add(const StartTyping());
  }

  void _onChange(dynamic val) {
    // Determine the active text controller for formatter operations
    final activeController = _getActiveTextController();

    // Check if Enter was pressed (newline added) and handle list continuation
    // Only for non-segment mode (segment mode handles code blocks differently)
    if (!_useSegmentBasedCodeBlocks &&
        _textEditingController != null && _richTextFormatterManager != null) {
      final currentText = _textEditingController!.text;
      final selection = _textEditingController!.selection;

      // Detect if a newline was just inserted
      if (currentText.length > _previousText.length) {
        final insertedLength = currentText.length - _previousText.length;
        if (insertedLength == 1 && selection.isCollapsed) {
          final insertedChar = currentText.substring(
            selection.start - 1,
            selection.start,
          );

          if (insertedChar == '\n') {
            // A newline was just inserted - check if we need to continue a list
            // We need to check the line BEFORE the newline was inserted
            final textBeforeNewline = currentText.substring(0, selection.start - 1);
            final selectionBeforeNewline = TextSelection.collapsed(
              offset: selection.start - 1,
            );

            final result = _richTextFormatterManager!.handleEnter(
              textBeforeNewline,
              selectionBeforeNewline,
            );

            if (result != null) {
              // List continuation was handled - update the text
              // Remove the newline we just added and apply the formatter's result
              _textEditingController!.text = result.newText;
              _textEditingController!.selection = result.newSelection;
              _previousText = result.newText;

              // Notify about the change
              if (widget.onChange != null) {
                widget.onChange!(result.newText);
              }
              _bloc.add(UpdateComposeText(result.newText));
              return;
            }
          }
        }
      }
    }

    // Get the text from the active controller for BLoC updates
    final activeText = activeController?.text ?? _textEditingController?.text ?? '';

    if (widget.onChange != null) {
      widget.onChange!(activeText);
    }
    _onTyping();
    _bloc.add(UpdateComposeText(activeText));

    // Update rich text toolbar visibility for onSelection mode
    // Show toolbar when text is typed (not empty)
    if (widget.richTextConfiguration?.toolbarMode ==
        RichTextToolbarMode.onSelection) {
      final shouldShow = activeText.trim().isNotEmpty;
      if (_showRichTextToolbar != shouldShow) {
        setState(() {
          _showRichTextToolbar = shouldShow;
        });
      }
    }
  }

  // ============================================================================
  // Message Handling
  // ============================================================================

  void _handlePreMessageSend(BaseMessage baseMessage) {
    for (var element in _formatters) {
      element.handlePreMessageSend(context, baseMessage);
    }
  }

  void _onSendButtonClick() {
    // Block sending while AI is streaming
    if (_bloc.state.isActiveStreaming) return;

    // Get text from segment controller or text editing controller
    String? text;
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      text = _segmentComposerController!.finalText.trim();
    } else {
      text = _textEditingController?.text.trim();
    }

    // Don't send if text is empty or contains only line-format prefixes
    // (e.g. "1. ", "- ", "> ", "> > " with no actual content)
    if (text == null || text.isEmpty || _isOnlyLineFormatPrefix(text)) return;

    if (_bloc.state.isEditMode) {
      _editTextMessage();
    } else if (_bloc.state.isReplyMode) {
      _sendTextMessageWithReply();
    } else {
      _sendTextMessage();
    }
  }

  /// Returns true if the text contains only line-format prefixes with no real content.
  /// Handles ordered lists (1. ), bullets (- ), and blockquotes (> ) including nested.
  static bool _isOnlyLineFormatPrefix(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      // Strip all leading blockquote markers ("> " or ">")
      String stripped = line;
      while (stripped.startsWith('> ') || stripped.startsWith('>')) {
        stripped = stripped.startsWith('> ')
            ? stripped.substring(2)
            : stripped.substring(1);
      }
      stripped = stripped.trim();
      // Strip ordered list prefix (e.g. "1. ", "12. ")
      stripped = stripped.replaceFirst(RegExp(r'^\d+\.\s*$'), '');
      // Strip bullet prefix
      stripped = stripped.replaceFirst(RegExp(r'^[-*]\s*$'), '');
      if (stripped.isNotEmpty) return false;
    }
    return true;
  }

  void _sendTextMessage() {
    if (_textEditingController == null && _segmentComposerController == null) return;
    
    // Get text from segment controller or text editing controller
    String messagesText;
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      messagesText = _segmentComposerController!.finalText;
    } else if (_textEditingController is RichTextEditingController) {
      messagesText = (_textEditingController as RichTextEditingController).toMarkdown();
    } else {
      messagesText = _textEditingController!.text;
    }

    TextMessage textMessage = TextMessage(
      sender: _bloc.state.loggedInUser,
      text: messagesText,
      receiverUid: _bloc.state.receiverId,
      receiverType: _bloc.state.receiverType,
      type: MessageTypeConstants.text,
      parentMessageId: widget.parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    _handlePreMessageSend(textMessage);
    textMessage.text = textMessage.text.trim();

    // Clear formatting and content
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      _segmentComposerController!.clear();
    } else if (_textEditingController is RichTextEditingController) {
      (_textEditingController as RichTextEditingController).clearFormatting();
    }
    _textEditingController?.clear();
    _previousText = '';
    _hideSuggestionOverlay();
    // Reset active formats so toolbar reflects cleared state
    _previousActiveFormats = {};
    _activeFormatsNotifier.value = {};
    setState(() {});

    if (widget.onSendButtonTap != null) {
      widget.onSendButtonTap!(context, textMessage, PreviewMessageMode.none);
    } else {
      _bloc.add(SendTextMessage(processedMessage: textMessage));
    }
  }

  void _sendTextMessageWithReply() {
    if (_textEditingController == null && _segmentComposerController == null) return;
    
    // Get text from segment controller or text editing controller
    String messagesText;
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      messagesText = _segmentComposerController!.finalText;
    } else if (_textEditingController is RichTextEditingController) {
      messagesText = (_textEditingController as RichTextEditingController).toMarkdown();
    } else {
      messagesText = _textEditingController!.text;
    }

    TextMessage textMessage = TextMessage(
      sender: _bloc.state.loggedInUser,
      text: messagesText,
      receiverUid: _bloc.state.receiverId,
      receiverType: _bloc.state.receiverType,
      type: MessageTypeConstants.text,
      parentMessageId: widget.parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    // Set quoted message fields from reply state
    if (_bloc.state.replyMessage != null) {
      textMessage.quotedMessage = _bloc.state.replyMessage;
      if (_bloc.state.replyMessage!.id > 0) {
        textMessage.quotedMessageId = _bloc.state.replyMessage!.id;
      }
    }

    _handlePreMessageSend(textMessage);
    textMessage.text = textMessage.text.trim();

    // Clear formatting and content
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      _segmentComposerController!.clear();
    } else if (_textEditingController is RichTextEditingController) {
      (_textEditingController as RichTextEditingController).clearFormatting();
    }
    _textEditingController?.clear();
    _previousText = '';
    _hideSuggestionOverlay();

    // Clear reply state immediately before sending
    _bloc.add(const ClearReplyMessage());

    // Reset active formats so toolbar reflects cleared state
    _previousActiveFormats = {};
    _activeFormatsNotifier.value = {};
    setState(() {});

    if (widget.onSendButtonTap != null) {
      widget.onSendButtonTap!(context, textMessage, PreviewMessageMode.reply);
    } else {
      _bloc.add(SendTextMessage(processedMessage: textMessage));
    }
  }

  void _editTextMessage() {
    if (_textEditingController == null && _segmentComposerController == null) return;
    final state = _bloc.state;
    if (state.editMessage == null || state.editMessage is! TextMessage) return;

    // Get text from segment controller or text editing controller
    String newText;
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      newText = _segmentComposerController!.finalText;
    } else if (_textEditingController is RichTextEditingController) {
      newText = (_textEditingController as RichTextEditingController).toMarkdown();
    } else {
      newText = _textEditingController!.text;
    }
    final oldText = (state.editMessage as TextMessage).text;

    if (!_hasMeaningfulChange(oldText, newText)) return;

    // Create a copy — do NOT mutate the original message object.
    // The original is the same reference held by the message list's state.
    // Mutating it in-place causes BLoC's Equatable deduplication to suppress
    // the subsequent emit when the SDK returns the edited message, because
    // the "old" list already contains the mutated text.
    final original = state.editMessage as TextMessage;
    TextMessage editedMessage = TextMessage(
      id: original.id,
      sender: original.sender,
      receiver: original.receiver,
      text: newText,
      receiverUid: original.receiverUid,
      receiverType: original.receiverType,
      type: original.type,
      metadata: original.metadata != null ? Map<String, dynamic>.from(original.metadata!) : null,
      parentMessageId: original.parentMessageId,
      muid: original.muid,
      category: original.category,
      sentAt: original.sentAt,
      deliveredAt: original.deliveredAt,
      readAt: original.readAt,
      readByMeAt: original.readByMeAt,
      deliveredToMeAt: original.deliveredToMeAt,
      updatedAt: original.updatedAt,
      conversationId: original.conversationId,
      replyCount: original.replyCount,
      mentionedUsers: original.mentionedUsers,
      hasMentionedMe: original.hasMentionedMe,
      reactions: original.reactions,
      tags: original.tags,
      quotedMessage: original.quotedMessage,
      quotedMessageId: original.quotedMessageId,
    );
    _handlePreMessageSend(editedMessage);

    // Clear formatting and content
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      _segmentComposerController!.clear();
    } else if (_textEditingController is RichTextEditingController) {
      (_textEditingController as RichTextEditingController).clearFormatting();
    }
    _textEditingController?.clear();
    _previousText = '';
    _hideSuggestionOverlay();
    // Reset active formats so toolbar reflects cleared state
    _previousActiveFormats = {};
    _activeFormatsNotifier.value = {};
    setState(() {});

    if (widget.onSendButtonTap != null) {
      _bloc.add(const ClearComposer());
      widget.onSendButtonTap!(context, editedMessage, PreviewMessageMode.edit);
    } else {
      _bloc.add(EditTextMessage(processedMessage: editedMessage));
    }
  }

  bool _hasMeaningfulChange(String original, String edited) {
    return original.trim() != edited.trim();
  }

  void _sendMediaRecording(BuildContext ctx, String path) {
    final metadata = {'localPath': path};
    if (widget.onSendButtonTap != null) {
      MediaMessage mediaMessage = MediaMessage(
        receiverType: _bloc.state.receiverType,
        type: MessageTypeConstants.audio,
        receiverUid: _bloc.state.receiverId,
        file: path,
        sender: _bloc.state.loggedInUser,
        parentMessageId: widget.parentMessageId,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        category: CometChatMessageCategory.message,
        metadata: metadata,
        sentAt: DateTime.now(),
      );

      // Set quoted message fields if in reply mode
      final replyMsg = _bloc.state.replyMessage;
      PreviewMessageMode mode = PreviewMessageMode.none;
      if (_bloc.state.isReplyMode && replyMsg != null) {
        mediaMessage.quotedMessage = replyMsg;
        if (replyMsg.id > 0) {
          mediaMessage.quotedMessageId = replyMsg.id;
        }
        mode = PreviewMessageMode.reply;
        _bloc.add(const ClearComposer());
      }

      widget.onSendButtonTap!(context, mediaMessage, mode);
    } else {
      _bloc.add(SendMediaMessage(
        path: path,
        messageType: MessageTypeConstants.audio,
        metadata: metadata,
      ));
    }
  }

  void _previewMessage(BaseMessage message, PreviewMessageMode mode) {
    if (mode == PreviewMessageMode.edit) {
      _bloc.add(SetEditMessage(message));
      _overlayPortalController.show();

      if (message is TextMessage) {
        int mentionFormatterIndex = _formatters
            .indexWhere((element) => element is CometChatMentionsFormatter);

        // In segment mode, populate the segment controller with the edit text
        if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
          String editText = message.text;
          if (mentionFormatterIndex != -1) {
            // Process mentions for display
            editText = _processEditText(editText, message);
          }
          // Clear and populate segment controller
          _segmentComposerController!.clear();
          // Set the text in the first normal segment
          final segments = _segmentComposerController!.segments;
          if (segments.isNotEmpty) {
            segments.first.controller.text = editText;
            _previousText = editText;
          }
        } else if (mentionFormatterIndex != -1) {
          CometChatMentionsFormatter mentionsFormatter =
          _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;

          _textEditingController?.text = message.text;
          _previousText = message.text;

          mentionsFormatter.onMessageEdit(
            _textEditingController!,
            mentionedUsers: message.mentionedUsers,
          );

          _previousText = _textEditingController!.text;
        } else {
          String editText = message.text;
          editText = _processEditText(editText, message);
          _textEditingController?.text = editText;
          _previousText = editText;
        }
      }
    } else if (mode == PreviewMessageMode.reply) {
      _bloc.add(SetReplyMessage(message));
      _overlayPortalController.show();
    }
    setState(() {});
  }

  String _processEditText(String editText, TextMessage message) {
    if (widget.mentionAllLabelId != null) {
      String specificPattern = '<@all:${widget.mentionAllLabelId}>';
      String replacement = widget.mentionAllLabel ?? '@all';
      editText = editText.replaceAll(specificPattern, replacement);
    }
    editText = editText.replaceAll('<@all:all>', widget.mentionAllLabel ?? '@all');

    if (message.mentionedUsers.isNotEmpty) {
      editText = CometChatMentionsFormatter.getTextWithMentions(
          editText, message.mentionedUsers);
    }
    return editText;
  }

  void _onMessagePreviewClose() {
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }

    // Clear segment controller in segment mode
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      _segmentComposerController!.clear();
    }
    _textEditingController?.clear();

    for (var element in _formatters) {
      if (element is CometChatMentionsFormatter) {
        // Use the active controller for mentions cleanup
        final activeController = _getActiveTextController() ?? _textEditingController;
        if (activeController != null) {
          element.onMessageEdit(activeController, mentionedUsers: []);
        }
      }
    }

    _bloc.add(const ClearComposer());
    setState(() {});
  }

  void _initializeFooterView() {
    // Footer view is handled through BLoC state
  }

  // ============================================================================
  // Attachment and AI Options
  // ============================================================================

  /// Hides the suggestion list overlay and updates the notifier.
  void _hideSuggestionOverlay() {
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
    _suggestionOpenNotifier.value = false;
  }

  /// Shows the attachment options overlay popup above the attachment button.
  ///
  /// The keyboard stays open so the user can continue typing after
  /// dismissing the overlay without needing to tap the text field again.
  void _showAttachmentOverlay() {
    _attachmentOverlayController.show();
    _attachmentOpenNotifier.value = true;
  }

  /// Hides the attachment options overlay popup.
  ///
  /// This method dismisses the overlay popup when the user selects an option
  /// or taps outside the overlay.
  void _hideAttachmentOverlay() {
    _attachmentOverlayController.hide();
    _attachmentOpenNotifier.value = false;
  }

  /// Dismisses the attachment overlay without restoring focus.
  ///
  /// This method is called when the user taps outside the overlay popup.
  /// It only hides the overlay - it does NOT request focus on the text input
  /// to avoid opening the keyboard unexpectedly.
  /// Requirements: 4.3, 4.4
  void _dismissAttachmentOverlayAndRestoreFocus() {
    _hideAttachmentOverlay();
    // Don't restore focus - user tapped outside, they don't want the keyboard
  }

  /// Toggles the attachment options overlay popup.
  ///
  /// If the overlay is currently showing, it will be hidden.
  /// If the overlay is currently hidden, it will be shown.
  /// This replaces the previous bottom sheet behavior with an overlay popup.
  void _toggleAttachmentOverlay() {
    if (_attachmentOverlayController.isShowing) {
      _hideAttachmentOverlay();
    } else {
      // Dismiss suggestion overlay when attachment opens
      if (_overlayPortalController.isShowing) {
        _hideSuggestionOverlay();
        CometChatUIEvents.hidePanel(_composerId, CustomUIPosition.composerPreview);
        _suggestions.clear();
        _currentSearchKeyword = null;
        _searchKeywordChanged = true;
      }
      _showAttachmentOverlay();
    }
  }

  /// Handles selection of an attachment option from the overlay.
  ///
  /// This method is called when the user taps an item in the attachment
  /// options overlay. It dismisses the overlay and then either executes
  /// the item's custom callback or handles the default attachment selection.
  void _onAttachmentItemSelected(ActionItem item) {
    // Dismiss the overlay first
    _hideAttachmentOverlay();

    // Execute the item's custom callback if provided
    if (item.onItemClick != null) {
      item.onItemClick!(context, widget.user, widget.group);
    } else {
      // Handle default attachment selection
      _handleAttachmentSelection(item);
    }
  }

  Future<void> _handleAttachmentSelection(ActionItem item) async {
    PickedFile? pickedFile;
    String? type;

    if (item.id == MessageTypeConstants.attachPhoto) {
      pickedFile = await MediaPicker.pickImage();
      type = pickedFile?.fileType;
    } else if (item.id == MessageTypeConstants.attachVideo) {
      pickedFile = await MediaPicker.pickVideo();
      type = pickedFile?.fileType;
    } else if (item.id == 'takePhoto') {
      pickedFile = await MediaPicker.takePhoto();
      type = MessageTypeConstants.image;
    } else if (item.id == MessageTypeConstants.file) {
      pickedFile = await MediaPicker.pickAnyFile();
      type = MessageTypeConstants.file;
    } else if (item.id == MessageTypeConstants.audio) {
      pickedFile = await MediaPicker.pickAudio();
      type = MessageTypeConstants.audio;
    } else if (item.id == MessageTypeConstants.image) {
      pickedFile = await MediaPicker.pickImage();
      type = MessageTypeConstants.image;
    } else if (item.id == MessageTypeConstants.video) {
      pickedFile = await MediaPicker.pickVideo();
      type = MessageTypeConstants.video;
    } else if (item.id == ExtensionType.extensionPoll) {
      _handleCreatePoll();
      return;
    } else if (item.id == ExtensionType.document) {
      _handleCreateCollaborativeDocument();
      return;
    } else if (item.id == ExtensionType.whiteboard) {
      _handleCreateCollaborativeWhiteboard();
      return;
    }

    if (pickedFile != null && type != null) {
      Map<String, dynamic> metadata = {};
      metadata["localPath"] = pickedFile.path;
      _bloc.add(SendMediaMessage(
        path: pickedFile.path,
        messageType: type,
        metadata: metadata,
      ));
    }
  }

  /// Handles media content inserted from the keyboard (e.g. GIF, sticker).
  /// Writes the content data to a temp file and sends it as a media message.
  Future<void> _handleKeyboardContentInserted(KeyboardInsertedContent content) async {
    if (kIsWeb) return; // Not supported on web
    final data = content.data;
    if (data == null || data.isEmpty) {
      // If there's a URI but no data, try sending the URI directly
      if (content.uri.isNotEmpty) {
        _bloc.add(SendMediaMessage(
          path: content.uri,
          messageType: MessageTypeConstants.image,
          metadata: {'localPath': content.uri},
        ));
      }
      return;
    }

    try {
      // Determine file extension from mime type
      final mimeType = content.mimeType;
      String extension = 'gif';
      if (mimeType.contains('png')) {
        extension = 'png';
      } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
        extension = 'jpg';
      } else if (mimeType.contains('webp')) {
        extension = 'webp';
      }

      // Write to temp file
      final tempDir = Directory.systemTemp;
      final fileName = 'keyboard_media_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(data);

      Map<String, dynamic> metadata = {};
      metadata['localPath'] = file.path;

      _bloc.add(SendMediaMessage(
        path: file.path,
        messageType: MessageTypeConstants.image,
        metadata: metadata,
      ));
    } catch (e) {
    }
  }

  /// Opens the create poll bottom sheet
  void _handleCreatePoll() {
    final replyMessage = _bloc.state.replyMessage;
    // Clear reply state immediately so the preview dismisses
    if (replyMessage != null) {
      _bloc.add(const ClearReplyMessage());
    }
    showCometChatCreatePoll(
      context: context,
      colorPalette: _colorPalette,
      spacing: _spacing,
      uid: widget.user?.uid,
      guid: widget.group?.guid,
      userObject: widget.user,
      groupObject: widget.group,
      quotedMessage: replyMessage,
    );
  }

  /// Creates a collaborative document via CometChat extension
  void _handleCreateCollaborativeDocument() {
    final receiverId = widget.user?.uid ?? widget.group?.guid ?? '';
    final receiverType = widget.user != null
        ? ReceiverTypeConstants.user
        : ReceiverTypeConstants.group;

    final replyMessage = _bloc.state.replyMessage;
    // Clear reply state immediately so the preview dismisses
    if (replyMessage != null) {
      _bloc.add(const ClearReplyMessage());
    }

    final Map<String, dynamic> body = {
      'receiver': receiverId,
      'receiverType': receiverType,
    };
    if (replyMessage != null && replyMessage.id > 0) {
      body['quotedMessageId'] = replyMessage.id;
    }

    CometChat.callExtension(
      ExtensionConstants.document,
      'POST',
      ExtensionUrls.document,
      body,
      onSuccess: (Map<String, dynamic> map) {
      },
      onError: (CometChatException e) {
        if (widget.onError != null) {
          widget.onError!(e);
        }
      },
    );
  }

  /// Creates a collaborative whiteboard via CometChat extension
  void _handleCreateCollaborativeWhiteboard() {
    final receiverId = widget.user?.uid ?? widget.group?.guid ?? '';
    final receiverType = widget.user != null
        ? ReceiverTypeConstants.user
        : ReceiverTypeConstants.group;

    final replyMessage = _bloc.state.replyMessage;
    // Clear reply state immediately so the preview dismisses
    if (replyMessage != null) {
      _bloc.add(const ClearReplyMessage());
    }

    final Map<String, dynamic> body = {
      'receiver': receiverId,
      'receiverType': receiverType,
    };
    if (replyMessage != null && replyMessage.id > 0) {
      body['quotedMessageId'] = replyMessage.id;
    }

    CometChat.callExtension(
      ExtensionConstants.whiteboard,
      'POST',
      ExtensionUrls.whiteboard,
      body,
      onSuccess: (Map<String, dynamic> map) {
      },
      onError: (CometChatException e) {
        if (widget.onError != null) {
          widget.onError!(e);
        }
      },
    );
  }

  void _showVoiceRecordingSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.useInlineAudioRecorder) {
      // Use inline audio recorder in the composer
      _bloc.add(const StartAudioRecording());
    } else {
      // Use bottom sheet recorder (legacy mode)
      _showVoiceRecordingBottomSheet();
    }
  }

  /// Shows the bottom sheet recorder (legacy mode)
  void _showVoiceRecordingBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CometChatMediaRecorder(
          startButtonIcon: widget.recorderStartButtonIcon,
          pauseButtonIcon: widget.recorderPauseButtonIcon,
          stopButtonIcon: widget.recorderStopButtonIcon,
          deleteButtonIcon: widget.recorderDeleteButtonIcon,
          sendButtonIcon: widget.recorderSendButtonIcon,
          style: _style.mediaRecorderStyle,
          onSubmit: _sendMediaRecording,
        );
      },
    );
  }

  /// Ensures a normal segment has focus in segment mode.
  /// If no segment is focused, focuses the first normal segment.
  /// Returns the focused segment's controller and focus node as a list [controller, focusNode],
  /// or falls back to the main _textEditingController / _focusNode.
  List<dynamic> _ensureSegmentFocus() {
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      var focused = _segmentComposerController!.focusedSegment;
      if (focused == null || focused.type != SegmentType.normal) {
        // No segment focused — find the first normal segment and focus it
        ComposerSegment? firstNormal;
        for (final s in _segmentComposerController!.segments) {
          if (s.type == SegmentType.normal) {
            firstNormal = s;
            break;
          }
        }
        if (firstNormal != null) {
          firstNormal.focusNode.requestFocus();
          return [firstNormal.controller, firstNormal.focusNode];
        }
      } else {
        return [focused.controller, focused.focusNode];
      }
    }
    // Non-segment mode or no normal segment found
    if (_textEditingController != null) {
      _focusNode.requestFocus();
    }
    return [_textEditingController!, _focusNode];
  }

  void _showLinkEditDialog() {
    // Ensure a segment has focus and get the active controller
    final result = _ensureSegmentFocus();
    final activeController = result[0] as TextEditingController;
    final savedFocusNode = result[1] as FocusNode?;

    // Capture selection and text BEFORE dialog opens — dialog steals focus and resets selection.
    // Guard against invalid selection (baseOffset == -1 when field was never focused).
    final sel = activeController.selection;
    final savedText = activeController.text;
    final isSelectionValid = sel.isValid && sel.start >= 0 && sel.end <= savedText.length;
    final savedSelection = isSelectionValid
        ? sel
        : TextSelection.collapsed(offset: savedText.length);
    final selectedText = savedSelection.isCollapsed
        ? ''
        : savedText.substring(savedSelection.start, savedSelection.end);

    // Hold references so the closure uses the correct objects even after
    // focus shifts while the dialog is open.
    final controllerToUpdate = activeController;
    final focusToRestore = savedFocusNode;

    showDialog(
      context: context,
      builder: (dialogContext) => LinkEditDialog(
        initialDisplayText: selectedText,
        style: CometChatLinkPreviewStyle.of(context),
        onSubmit: (displayText, url) {
          Navigator.of(dialogContext).pop();
          _applyLinkFormat(
            displayText, url, savedText, savedSelection,
            controllerToUpdate, focusToRestore,
          );
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _applyLinkFormat(
    String displayText,
    String url,
    String savedText,
    TextSelection savedSelection,
    TextEditingController controller,
    FocusNode? focusToRestore,
  ) {
    // Restore focus first so the text field is ready to accept the value change.
    // Use a post-frame callback to ensure the dialog is fully dismissed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Re-focus the text field
      focusToRestore?.requestFocus();

      if (controller is RichTextEditingController) {
        // WYSIWYG mode: use span system so formatting survives editing.
        // Restore selection first so applyLinkFormat knows where to insert.
        controller.selection = savedSelection;
        controller.applyLinkFormat(displayText, url);
      } else {
        // Legacy mode: insert raw markdown
        final linkMarkdown = '[$displayText]($url)';
        final newText = savedText.substring(0, savedSelection.start) +
            linkMarkdown +
            savedText.substring(savedSelection.end);
        final newCursorPos = savedSelection.start + linkMarkdown.length;

        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursorPos),
        );
      }

      widget.onRichTextFormatApplied?.call(RichTextFormatType.link);
    });
  }

  /// Called when a link span is tapped in the text field.
  /// Shows a popup with Edit and Remove options.
  void _onLinkTapped(LinkTapDetails details) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final typography = CometChatThemeHelper.getTypography(context);

    // Capture the active controller NOW (before dialog steals focus).
    // In segment mode, the link lives in the focused segment's controller.
    final activeCtrl = _getActiveTextController();
    final richCtrl = (activeCtrl is RichTextEditingController)
        ? activeCtrl
        : (_textEditingController is RichTextEditingController
            ? _textEditingController as RichTextEditingController
            : null);

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (dialogContext) => AlertDialog(
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
        iconPadding: EdgeInsets.only(
          left: spacing.padding6 ?? 24,
          right: spacing.padding6 ?? 24,
          top: spacing.padding6 ?? 24,
          bottom: spacing.padding3 ?? 12,
        ),
        icon: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: colorPalette.background2,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.link,
            color: colorPalette.primary,
            size: 32,
          ),
        ),
        titlePadding: EdgeInsets.only(
          left: spacing.padding6 ?? 24,
          right: spacing.padding6 ?? 24,
          bottom: spacing.padding1 ?? 4,
        ),
        title: Text(
          details.displayText,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titleTextStyle: TextStyle(
          fontSize: typography.heading3?.medium?.fontSize,
          fontWeight: typography.heading3?.medium?.fontWeight,
          fontFamily: typography.heading3?.medium?.fontFamily,
          color: colorPalette.textPrimary,
        ),
        contentPadding: EdgeInsets.only(
          left: spacing.padding6 ?? 24,
          right: spacing.padding6 ?? 24,
          bottom: spacing.padding3 ?? 12,
        ),
        content: Text(
          details.url,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentTextStyle: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
          color: colorPalette.textSecondary,
        ),
        actionsPadding: EdgeInsets.only(
          left: spacing.padding6 ?? 24,
          right: spacing.padding6 ?? 24,
          bottom: spacing.padding3 ?? 12,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.margin3 ?? 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing.padding2 ?? 8),
                    child: Semantics(
                      button: true,
                      label: Translations.of(context).edit,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _showLinkEditDialogForExisting(details, richCtrl);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          side: WidgetStateProperty.all(
                            BorderSide(
                              color: colorPalette.borderDark ?? Colors.transparent,
                              width: 1,
                            ),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(spacing.radius2 ?? 8),
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: colorPalette.textPrimary,
                            ),
                            SizedBox(width: spacing.padding1 ?? 4),
                            Text(
                              Translations.of(context).edit,
                              style: TextStyle(
                                fontSize: typography.button?.medium?.fontSize,
                                fontWeight: typography.button?.medium?.fontWeight,
                                fontFamily: typography.button?.medium?.fontFamily,
                                color: colorPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: Translations.of(context).delete,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        richCtrl?.removeLinkFormat(details.start, details.end);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          colorPalette.error,
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: colorPalette.error ?? Colors.transparent,
                            width: 0,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(spacing.radius2 ?? 8),
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_off,
                            size: 18,
                            color: colorPalette.white,
                          ),
                          SizedBox(width: spacing.padding1 ?? 4),
                          Text(
                            Translations.of(context).delete,
                            style: TextStyle(
                              fontSize: typography.button?.medium?.fontSize,
                              fontWeight: typography.button?.medium?.fontWeight,
                              fontFamily: typography.button?.medium?.fontFamily,
                              color: colorPalette.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the link edit dialog pre-filled with the existing link's text and URL.
  void _showLinkEditDialogForExisting(LinkTapDetails details, RichTextEditingController? richCtrl) {
    final controller = richCtrl;
    if (controller == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => LinkEditDialog(
        initialDisplayText: details.displayText,
        initialUrl: details.url,
        style: CometChatLinkPreviewStyle.of(context),
        onSubmit: (newDisplayText, newUrl) {
          Navigator.of(dialogContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            controller.editLinkFormat(
              details.start, details.end, newDisplayText, newUrl,
            );
          });
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  /// Called by [RichTextEditingController.onFormatterTextChanged] after
  /// [editLinkFormat] or [removeLinkFormat] change text programmatically.
  /// Runs each formatter's [onChange] so tracked positions (e.g. mentions)
  /// stay in sync with the new text.
  void _onFormatterTextChanged(String previousText) {
    final activeController = _getActiveTextController();
    if (activeController == null) return;

    for (var formatter in _formatters) {
      try {
        formatter.onChange(activeController, previousText);
      } catch (err) {
        if (kDebugMode) {
        }
      }
    }
    // Keep previousText in sync so the next _onTyping diff is correct.
    _updatePreviousText(activeController.text);
  }

  Widget? _buildRichTextToolbar() {
    if (!_showRichTextToolbar ||
        _richTextFormatterManager == null ||
        _textEditingController == null) {
      return null;
    }

    // Use custom view if provided
    if (widget.richTextToolbarView != null) {
      return widget.richTextToolbarView!(
        context,
        _textEditingController!,
        _richTextFormatterManager!,
      );
    }

    // Get active formats - use centralized helper that handles segment mode
    final activeFormats = _getActiveFormats();

    // Get hidden formats from configuration
    final hiddenFormats = <FormatType>{};
    final config = widget.richTextConfiguration;
    if (config != null) {
      if (!config.enableBold) hiddenFormats.add(FormatType.bold);
      if (!config.enableItalic) hiddenFormats.add(FormatType.italic);
      if (!config.enableUnderline) hiddenFormats.add(FormatType.underline);
      if (!config.enableStrikethrough) hiddenFormats.add(FormatType.strikethrough);
      if (!config.enableInlineCode) hiddenFormats.add(FormatType.inlineCode);
      if (!config.enableCodeBlock) hiddenFormats.add(FormatType.codeBlock);
      if (!config.enableLinks) hiddenFormats.add(FormatType.link);
      if (!config.enableBulletList) hiddenFormats.add(FormatType.bulletList);
      if (!config.enableOrderedList) hiddenFormats.add(FormatType.orderedList);
      if (!config.enableBlockquote) hiddenFormats.add(FormatType.blockquote);
    }

    return CometChatRichTextToolbar(
      onFormatTap: (formatType) {
        // Handle link format specially
        if (formatType == FormatType.link) {
          _showLinkEditDialog();
          return;
        }

        // Ensure a segment has focus before applying format
        _ensureSegmentFocus();

        // Apply format using segment controller, WYSIWYG controller, or formatter manager
        if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
          _segmentComposerController!.applyFormat(formatType);
        } else if (_textEditingController is RichTextEditingController) {
          (_textEditingController as RichTextEditingController).applyFormat(formatType);
        } else {
          // Legacy mode - use formatter manager
          final legacyFormatType = RichTextFormatType.values.firstWhere(
            (t) => t.name == formatType.name,
            orElse: () => RichTextFormatType.bold,
          );
          _richTextFormatterManager!.applyFormat(
            formatType: legacyFormatType,
            controller: _textEditingController!,
          );
        }

        // Notify callback
        if (widget.onRichTextFormatApplied != null) {
          final legacyType = RichTextFormatType.values.firstWhere(
            (t) => t.name == formatType.name,
            orElse: () => RichTextFormatType.bold,
          );
          widget.onRichTextFormatApplied!(legacyType);
        }

        // Trigger rebuild to update active formats
        if (mounted) {
          setState(() {});
        }
      },
      activeFormats: activeFormats,
      hiddenFormats: hiddenFormats,
      style: _style.richTextToolbarStyle,
    );
  }

  /// Build the rich text preview panel that shows formatted text
  Widget? _buildRichTextPreview() {
    if (widget.richTextConfiguration == null ||
        _richTextFormatterManager == null ||
        _textEditingController == null) {
      return null;
    }

    final previewMode = widget.richTextConfiguration!.previewMode;
    if (previewMode == RichTextPreviewMode.disabled) {
      return null;
    }

    final text = _textEditingController!.text;
    if (text.trim().isEmpty) {
      return null;
    }

    // Check if text has any formatting
    final hasFormatting = _hasAnyFormatting(text);

    // For onFormatting mode, only show if there's formatting
    if (previewMode == RichTextPreviewMode.onFormatting && !hasFormatting) {
      return null;
    }

    return _RichTextPreviewPanel(
      text: text,
      formatters: _richTextFormatterManager!.activeFormatters
          .whereType<RichTextFormatterBase>()
          .toList(),
      colorPalette: _colorPalette,
      typography: _typography,
      spacing: _spacing,
    );
  }

  /// Check if text contains any rich text formatting
  bool _hasAnyFormatting(String text) {
    if (_richTextFormatterManager == null) return false;

    for (final formatter in _richTextFormatterManager!.activeFormatters) {
      if (formatter.pattern != null && formatter.pattern!.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  // ============================================================================
  // UI Building Methods - Using Extracted Widgets
  // ============================================================================

  Widget _buildSuggestionList() {
    return MessageComposerSuggestionList(
      suggestions: _suggestions,
      onItemTap: (item) {
        if (item.onTap != null) {
          item.onTap!();
        }
        _hideSuggestionOverlay();
        _suggestions.clear();
        _currentSearchKeyword = null;
        _searchKeywordChanged = true;
      },
      onScrollToBottom: () {
        final activeController = _getActiveTextController();
        if (activeController == null) return;
        for (var element in _formatters) {
          if (_currentSearchKeyword != null &&
              _currentSearchKeyword!.isNotEmpty &&
              element.trackingCharacter == _currentSearchKeyword![0]) {
            element.onScrollToBottom(activeController);
          }
        }
      },
      scrollController: _scrollController,
      hasMore: _hasMore,
      style: _suggestionListStyle,
      colorPalette: _colorPalette,
      spacing: _spacing,
      typography: _typography,
    );
  }

  Widget _buildSendButton(MessageComposerState state) {
    if (widget.hideSendButton == true) {
      return const SizedBox();
    }

    // AI streaming: show stop button (visual only, no tap action)
    if (state.isActiveStreaming) {
      return Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: _colorPalette.textPrimary ?? Colors.black,
          borderRadius: _style.sendButtonBorderRadius ??
              BorderRadius.circular(_spacing.radiusMax ?? 20),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.stop_rounded,
          color: _colorPalette.white ?? Colors.white,
          size: 20,
        ),
      );
    }

    if (widget.sendButtonView != null) {
      return GestureDetector(
        onTap: _onSendButtonClick,
        child: widget.sendButtonView,
      );
    }

    // When using segment-based code blocks, we need to listen to segment changes
    // instead of just the text controller
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      return ListenableBuilder(
        listenable: _segmentComposerController!,
        builder: (context, child) {
          final hasContent = _segmentComposerController!.hasContent;
          final shouldDisable = !hasContent;

          return MessageComposerSendButton(
            onPressed: _onSendButtonClick,
            isDisabled: shouldDisable,
            hideSendButton: widget.hideSendButton ?? false,
            customSendButtonView: widget.sendButtonView,
            sendButtonIcon: widget.sendButtonIcon,
            sendButtonIconColor: _style.sendButtonIconColor,
            sendButtonIconBackgroundColor: _style.sendButtonIconBackgroundColor,
            sendButtonBorderRadius: _style.sendButtonBorderRadius,
            colorPalette: _colorPalette,
            spacing: _spacing,
          );
        },
      );
    }

    // Wrap in ValueListenableBuilder to rebuild when text changes
    // This ensures the send button color updates immediately when typing in edit mode
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _textEditingController!,
      builder: (context, textValue, child) {
        final isTextControllerEmpty = textValue.text.trim().isEmpty;

        final isSameAsOldMessage = state.isEditMode &&
            state.editMessage is TextMessage &&
            textValue.text == (state.editMessage as TextMessage).text;

        final isEditModeWithoutChanges = state.isEditMode &&
            state.editMessage is TextMessage &&
            !_hasMeaningfulChange(
              (state.editMessage as TextMessage).text,
              textValue.text,
            );

        final shouldDisable = isTextControllerEmpty ||
            isSameAsOldMessage ||
            isEditModeWithoutChanges;

        return MessageComposerSendButton(
          onPressed: _onSendButtonClick,
          isDisabled: shouldDisable,
          hideSendButton: widget.hideSendButton ?? false,
          customSendButtonView: widget.sendButtonView,
          sendButtonIcon: widget.sendButtonIcon,
          sendButtonIconColor: _style.sendButtonIconColor,
          sendButtonIconBackgroundColor: _style.sendButtonIconBackgroundColor,
          sendButtonBorderRadius: _style.sendButtonBorderRadius,
          colorPalette: _colorPalette,
          spacing: _spacing,
        );
      },
    );
  }

  Widget _buildSecondaryButtonView(MessageComposerState state) {
    if (widget.secondaryButtonView != null) {
      return widget.secondaryButtonView!(
        context,
        widget.user,
        widget.group,
        _composerId,
      );
    }

    final secondaryButtons = MessageComposerSecondaryButtons(
      onAttachmentTap: _toggleAttachmentOverlay,
      hideAttachmentButton: widget.hideAttachmentButton ?? false,
      attachmentIcon: widget.attachmentIcon,
      attachmentIconURL: widget.attachmentIconURL,
      secondaryButtonIconColor: _style.secondaryButtonIconColor,
      secondaryButtonIconBackgroundColor: _style.secondaryButtonIconBackgroundColor,
      secondaryButtonBorderRadius: _style.secondaryButtonBorderRadius,
      colorPalette: _colorPalette,
      spacing: _spacing,
      attachmentButtonLink: _attachmentButtonLink,
      attachmentOpenNotifier: _attachmentOpenNotifier,
    );

    // Wrap with OverlayPortal for attachment options overlay
    return OverlayPortal(
      controller: _attachmentOverlayController,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            // Full-screen barrier to detect taps outside the overlay
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissAttachmentOverlayAndRestoreFocus,
                child: const SizedBox.expand(),
              ),
            ),
            // Positioned attachment options overlay - appears ABOVE the + button
            CompositedTransformFollower(
              link: _attachmentButtonLink,
              targetAnchor: Alignment.topLeft,
              followerAnchor: Alignment.bottomLeft,
              offset: Offset(0, -(_spacing.padding2 ?? 5)),
              child: AttachmentOptionsOverlay(
                actionItems: _actionItems,
                onItemSelected: _onAttachmentItemSelected,
                onDismiss: _hideAttachmentOverlay,
                style: _style.attachmentOptionSheetStyle,
                colorPalette: _colorPalette,
                spacing: _spacing,
                typography: _typography,
              ),
            ),
          ],
        );
      },
      child: secondaryButtons,
    );
  }

  Widget _buildAuxiliaryButtonView(MessageComposerState state) {
    if (widget.auxiliaryButtonView != null) {
      return widget.auxiliaryButtonView!(
        context,
        widget.user,
        widget.group,
        _composerId,
      );
    }

    // Hide voice recording button when text is typed (like in Figma design)
    // Check both regular text controller and segment controller
    final hasText = (_textEditingController != null &&
        _textEditingController!.text.isNotEmpty) ||
        (_segmentComposerController != null && _segmentComposerController!.hasContent);

    return MessageComposerAuxiliaryButtons(
      onVoiceRecordingTap: _showVoiceRecordingSheet,
      hideVoiceRecordingButton: (widget.hideVoiceRecordingButton ?? false) || hasText,
      auxiliaryOptions: _auxiliaryOptions,
      voiceRecordingIcon: widget.voiceRecordingIcon,
      auxiliaryButtonIconColor: _style.auxiliaryButtonIconColor,
      auxiliaryButtonIconBackgroundColor: _style.auxiliaryButtonIconBackgroundColor,
      auxiliaryButtonBorderRadius: _style.auxiliaryButtonBorderRadius,
      colorPalette: _colorPalette,
      spacing: _spacing,
    );
  }

  String _getMessagePreviewTitle(MessageComposerState state) {
    if (state.isEditMode) {
      return cc.Translations.of(context).editMessage;
    } else if (state.isReplyMode && state.replyMessage != null) {
      return state.replyMessage!.sender?.name ?? '';
    }
    return '';
  }

  String _getMessagePreviewSubtitle(MessageComposerState state) {
    BaseMessage? message;
    if (state.isEditMode) {
      message = state.editMessage;
    } else if (state.isReplyMode) {
      message = state.replyMessage;
    }

    if (message == null) return '';

    if (message is TextMessage) {
      String previewText = message.text;
      previewText = _processEditText(previewText, message);
      // Bug 1.9: Strip markdown syntax so preview shows plain text, not raw markdown
      previewText = ConversationUtils.stripMarkdownSyntax(previewText);
      return previewText;
    } else {
      return ComposerAttachmentUtils.
          getMessageTypeToSubtitle(message.type, context);
    }
  }

  // ============================================================================
  // Build Method
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates this widget's repaints from parent rebuilds
    // This helps reduce jank during keyboard open/close animations
    return ValueListenableBuilder<bool>(
      valueListenable: _attachmentOpenNotifier,
      builder: (context, isAttachmentOpen, __) => ValueListenableBuilder<bool>(
        valueListenable: _suggestionOpenNotifier,
        builder: (context, isSuggestionOpen, __) => PopScope(
          canPop: !isAttachmentOpen && !isSuggestionOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              // Just close the overlay — don't trigger navigation.
              // The user can press back again to dismiss the keyboard or navigate.
              if (isAttachmentOpen) {
                _hideAttachmentOverlay();
              } else if (isSuggestionOpen) {
                _hideSuggestionOverlay();
              }
            }
          },
          child: RepaintBoundary(
          child: BlocProvider.value(
            value: _bloc,
        child: BlocListener<MessageComposerBloc, MessageComposerState>(
          listenWhen: (previous, current) =>
              previous.composeText != current.composeText &&
              current.composeText.isNotEmpty,
          listener: (context, state) {
            final controller = _getActiveTextController();
            if (controller != null && controller.text != state.composeText) {
              controller.text = state.composeText;
              _bloc.add(const ClearComposeText());
            }
          },
          child: BlocConsumer<MessageComposerBloc, MessageComposerState>(
          // Only rebuild when state properties that affect UI change
          // This prevents rebuilds during keyboard animation
          buildWhen: (previous, current) {
          final shouldRebuild = previous.isEditMode != current.isEditMode ||
              previous.isReplyMode != current.isReplyMode ||
              previous.isRecordingMode != current.isRecordingMode ||
              previous.editMessage != current.editMessage ||
              previous.replyMessage != current.replyMessage ||
              previous.headerPanel != current.headerPanel ||
              previous.footerPanel != current.footerPanel ||
              previous.previewPanel != current.previewPanel ||
              previous.lockedBottomPadding != current.lockedBottomPadding ||
              previous.isActiveStreaming != current.isActiveStreaming;
          return shouldRebuild;
          },
          listener: (context, state) {
            // Handle panel events from BLoC state
            if (state.headerPanel != null) {
              // Header panel is shown
            }
            if (state.footerPanel != null) {
              // Footer panel is shown - sticker keyboard is visible
            }
            if (state.previewPanel != null) {
              // Preview panel is shown
            }

            // Handle edit mode changes — need to populate text controller
            if (state.isEditMode && state.editMessage != null) {
              _previewMessage(state.editMessage!, PreviewMessageMode.edit);
            }

            // Drive reply/edit preview animation
            final hasPreview = (state.isEditMode && state.editMessage != null) ||
                (state.isReplyMode && state.replyMessage != null);
            if (hasPreview && !_previewVisible) {
              _previewVisible = true;
              _previewAnimController.forward(from: 0.0);
            } else if (!hasPreview && _previewVisible) {
              _previewVisible = false;
              _previewAnimController.reverse();
            }
          },
          listenWhen: (previous, current) =>
              previous.isEditMode != current.isEditMode ||
              previous.isReplyMode != current.isReplyMode ||
              previous.editMessage != current.editMessage ||
              previous.replyMessage != current.replyMessage ||
              previous.headerPanel != current.headerPanel ||
              previous.footerPanel != current.footerPanel ||
              previous.previewPanel != current.previewPanel,
          builder: (context, state) {
            final messagePreviewTitle = _getMessagePreviewTitle(state);
            final messagePreviewSubtitle = _getMessagePreviewSubtitle(state);

            return PopScope(
              canPop: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: widget.padding,
                    child: Column(
                      children: [
                        // Header panel from BLoC state or widget
                        if (state.headerPanel != null)
                          state.headerPanel!
                        else if (widget.headerView != null)
                          widget.headerView!(
                            context,
                            widget.user,
                            widget.group,
                            _composerId,
                          ),

                        // Inline message preview — renders directly above the input
                        // so they appear as one unified component
                        _buildInlinePreview(
                          state,
                          messagePreviewTitle,
                          messagePreviewSubtitle,
                        ),

                        // Rich text formatting toolbar


                        // Rich text preview panel
                        if (_buildRichTextPreview() != null)
                          Padding(
                            padding: EdgeInsets.only(
                              left: _spacing.padding2 ?? 0,
                              right: _spacing.padding2 ?? 0,
                              bottom: _spacing.padding2 ?? 8,
                            ),
                            child: _buildRichTextPreview()!,
                          ),

                        // Message input or Inline Audio Recorder
                        if (state.isRecordingMode)
                          _buildInlineAudioRecorder()
                        else
                          _buildMessageInputWithToolbar(state),

                        // Custom footer view from widget (not sticker keyboard)
                        if (state.footerPanel == null && widget.footerView != null)
                          widget.footerView!(
                            context,
                            widget.user,
                            widget.group,
                            _composerId,
                          ),

                        // Combined bottom area: footer panel (sticker keyboard) + safe area padding
                        // This is a single widget to minimize rebuilds
                        if (!widget.hideBottomSafeArea && !widget.resizeToAvoidBottomInset)
                          _buildBottomArea(state)
                        // When resizeToAvoidBottomInset is true, the Scaffold handles keyboard
                        // insets but we still need to render the sticker panel if it's open.
                        else if (widget.resizeToAvoidBottomInset && state.footerPanel != null)
                          _buildStickerPanelOnly(state),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ),  // Close BlocListener
        ),  // Close BlocProvider
      ),  // Close RepaintBoundary
    ),  // Close PopScope
    ),  // Close inner ValueListenableBuilder (suggestion)
    );  // Close outer ValueListenableBuilder (attachment)
  }

  /// Renders the reply/edit preview inline, directly above the message input.
  /// When visible, the preview and input share a unified visual container —
  /// the preview has top-rounded corners and the input has square top corners.
  /// Animates in with a slide-up + fade when reply/edit mode activates.
  Widget _buildInlinePreview(
    MessageComposerState state,
    String messagePreviewTitle,
    String messagePreviewSubtitle,
  ) {
    final hasPreview = messagePreviewTitle.isNotEmpty;

    // Cache preview data when showing so reverse animation still has content
    if (hasPreview) {
      _lastPreviewTitle = messagePreviewTitle;
      _lastPreviewSubtitle = messagePreviewSubtitle;
      _lastPreviewMessage = state.isReplyMode
          ? state.replyMessage
          : state.editMessage;

      // Build formatted subtitle widget for text messages
      final previewMsg = _lastPreviewMessage;
      if (previewMsg is TextMessage) {
        final rawText = previewMsg.text;
        final formatters = FormatterUtils.ensureMarkdownFormatter(widget.textFormatters);
        final subtitleTextStyle = TextStyle(
          fontSize: _typography.caption1?.regular?.fontSize,
          fontWeight: _typography.caption1?.regular?.fontWeight,
          color: _colorPalette.textSecondary,
        );
        _lastPreviewSubtitleWidget = RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: subtitleTextStyle,
            children: FormatterUtils.buildTextSpan(
              rawText,
              formatters,
              context,
              BubbleAlignment.left,
              forConversation: true,
              textStyle: subtitleTextStyle,
            ),
          ),
          textScaler: MediaQuery.textScalerOf(context),
        );
      } else {
        _lastPreviewSubtitleWidget = null;
      }
    }

    // Always build the preview panel outside the animation so it's not affected
    final previewPanel = state.previewPanel;

    // Use cached values during reverse animation, live values otherwise
    final isAnimating = _previewAnimController.isAnimating ||
        _previewAnimController.value > 0;
    final showPreview = hasPreview || isAnimating;
    final title = hasPreview ? messagePreviewTitle : _lastPreviewTitle;
    final subtitle = hasPreview ? messagePreviewSubtitle : _lastPreviewSubtitle;
    final subtitleWidget = _lastPreviewSubtitleWidget;
    final message = hasPreview
        ? (state.isReplyMode ? state.replyMessage : state.editMessage)
        : _lastPreviewMessage;

    if (!showPreview && previewPanel == null) return const SizedBox.shrink();

    final hPad = (widget.messageInputPadding as EdgeInsets?)?.left ??
        _spacing.padding2 ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion list appears above the reply/edit preview
          if (previewPanel != null) previewPanel,
          if (showPreview && title.isNotEmpty)
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _previewAnimController,
                curve: Curves.easeOutCubic,
              ),
              axisAlignment: 1.0, // grow from bottom edge (towards top)
              child: FadeTransition(
                opacity: _previewFadeAnimation,
                child: SlideTransition(
                  position: _previewSlideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _style.backgroundColor ?? _colorPalette.background1,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(_spacing.radius2 ?? 0),
                        topRight: Radius.circular(_spacing.radius2 ?? 0),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: _colorPalette.borderDefault ?? Colors.transparent,
                          width: 1,
                        ),
                        left: BorderSide(
                          color: _colorPalette.borderDefault ?? Colors.transparent,
                          width: 1,
                        ),
                        right: BorderSide(
                          color: _colorPalette.borderDefault ?? Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(_spacing.padding1 ?? 4),
                    child: CometChatMessagePreview(
                      messagePreviewTitle: title,
                      messagePreviewSubtitle: subtitle,
                      subtitleWidget: subtitleWidget,
                      message: message,
                      onCloseClick: _onMessagePreviewClose,
                      messagePreviewStyle: CometChatMessagePreviewStyle(
                        closeIconColor:
                            _style.closeIconTint ?? _colorPalette.iconPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the combined bottom area containing footer panel (sticker keyboard) and safe area padding.
  /// This is a single widget to minimize rebuilds during keyboard transitions.
  Widget _buildBottomArea(MessageComposerState state) {
    
    // When footer panel (sticker keyboard) is shown, display it with locked padding below
    if (state.footerPanel != null) {
      // Cancel any pending clear timer since sticker is visible
      _stickerHeightClearTimer?.cancel();
      _expectingKeyboardOpen = false;
      
      // The sticker keyboard height should match the OS keyboard height exactly
      // _maxBottomHeight is the full keyboard height from native (includes safe area)
      // Only set the sticker height once when it first appears to avoid jiggle
      // when keyboard height changes (e.g., emoji suggestions appearing)
      if (_lastStickerTotalHeight == 0) {
        _lastStickerTotalHeight = _maxBottomHeight > 0 ? _maxBottomHeight : (CometChatStickerKeyboard.defaultHeight + _safeAreaBottom);
      }

      // Max extra height the user can drag (total sticker area capped at 60% of screen)
      final double screenHeight = MediaQuery.sizeOf(context).height;
      final double baseContentHeight = _lastStickerTotalHeight - _safeAreaBottom;
      // Drag handle height: 4px pill + 6px top padding + 6px bottom padding = 16px
      const double dragHandleHeight = 16.0;
      final double maxTotalContent = screenHeight * 0.6;
      final double maxExtra = (maxTotalContent - baseContentHeight).clamp(0.0, double.infinity);
      
      // Min negative extra = collapse the panel entirely
      final double minExtra = -(baseContentHeight - dragHandleHeight);

      return ValueListenableBuilder<double>(
        valueListenable: _stickerExtraHeight,
        builder: (context, extraHeight, _) {
          final double contentHeight =
              (baseContentHeight - dragHandleHeight + extraHeight)
                  .clamp(0.0, double.infinity);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle — drag up to grow, drag down to shrink / close
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Dragging up (negative dy) increases height,
                  // dragging down (positive dy) decreases height
                  final newExtra = (_stickerExtraHeight.value - details.delta.dy)
                      .clamp(minExtra, maxExtra);
                  _stickerExtraHeight.value = newExtra;
                },
                onVerticalDragEnd: (details) {
                  // If dragged down past half the base height, close the panel
                  if (_stickerExtraHeight.value < minExtra * 0.5) {
                    _stickerExtraHeight.value = 0;
                    _lastStickerTotalHeight = 0;
                    _expectingKeyboardOpen = false;
                    _stickerHeightClearTimer?.cancel();
                    CometChatUIEvents.hidePanel(
                        _composerId, CustomUIPosition.composerBottom);
                    CometChatUIEvents.unlockBottomPadding(_composerId);
                  } else if (_stickerExtraHeight.value < 0) {
                    // Snap back to base height if not dragged far enough
                    _stickerExtraHeight.value = 0;
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _colorPalette.neutral400 ?? Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // Sticker keyboard with extra drag height.
              // Subtract dragHandleHeight so the total (handle + content + safeArea)
              // matches the original keyboard frame height when extraHeight is 0.
              SizedBox(
                height: contentHeight,
                child: state.footerPanel!,
              ),
              // Add safe area padding below the sticker keyboard content.
              SizedBox(height: _safeAreaBottom),
            ],
          );
        },
      );
    }
    
    // Sticker keyboard just closed — if _expectingKeyboardOpen was already
    // set by onKeyboardTap, we just need to keep waiting.  Otherwise (e.g.
    // user tapped the text field directly), set the flag now so the bottom
    // area maintains height while the OS keyboard animates in.
    if (_lastStickerTotalHeight > 0 && !_expectingKeyboardOpen && !_isKeyboardVisible) {
      _expectingKeyboardOpen = true;
      _stickerHeightClearTimer?.cancel();
      _stickerHeightClearTimer = Timer(_stickerHeightClearDelay, () {
        // If keyboard still hasn't opened after the delay, clear the sticker height
        if (!_isKeyboardVisible && _expectingKeyboardOpen) {
          _lastStickerTotalHeight = 0;
          _expectingKeyboardOpen = false;
          // Force update the notifier to safe area only
          if (mounted && !_isDisposing) {
            _bottomPaddingNotifier.value = _safeAreaBottom;
            if (mounted) {
              setState(() {});
            }
          }
        }
      });
    }
    
    // Normal case: use keyboard height when open, safe area when closed
    return ValueListenableBuilder<double>(
      valueListenable: _bottomPaddingNotifier,
      builder: (context, bottomPadding, child) {
        double effectivePadding;
        
        // During the transition window (expecting keyboard to open), maintain sticker height
        // This prevents the jump when switching from sticker to OS keyboard
        if (_expectingKeyboardOpen && _lastStickerTotalHeight > 0 && !_isKeyboardVisible) {
          effectivePadding = _lastStickerTotalHeight;
        } else if (_isKeyboardVisible) {
          // Keyboard is visible - use keyboard height
          effectivePadding = bottomPadding;
          // Clear sticker tracking
          if (_lastStickerTotalHeight > 0) {
            _lastStickerTotalHeight = 0;
          }
          if (_expectingKeyboardOpen) {
            _expectingKeyboardOpen = false;
            _stickerHeightClearTimer?.cancel();
          }
        } else {
          // Neither sticker nor keyboard visible - use safe area only
          effectivePadding = _safeAreaBottom;
        }
        
        return SizedBox(height: effectivePadding);
      },
    );
  }

  /// Renders the sticker panel without keyboard-height-based bottom padding.
  /// Used when [resizeToAvoidBottomInset] is true — the Scaffold handles
  /// keyboard insets, but we still need to show the sticker keyboard.
  Widget _buildStickerPanelOnly(MessageComposerState state) {
    final double stickerContentHeight = CometChatStickerKeyboard.defaultHeight;
    const double dragHandleHeight = 16.0;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double maxTotalContent = screenHeight * 0.6;
    final double maxExtra =
        (maxTotalContent - stickerContentHeight).clamp(0.0, double.infinity);
    final double minExtra = -(stickerContentHeight - dragHandleHeight);

    return ValueListenableBuilder<double>(
      valueListenable: _stickerExtraHeight,
      builder: (context, extraHeight, _) {
        final double contentHeight =
            (stickerContentHeight - dragHandleHeight + extraHeight)
                .clamp(0.0, double.infinity);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            GestureDetector(
              onVerticalDragUpdate: (details) {
                final newExtra =
                    (_stickerExtraHeight.value - details.delta.dy)
                        .clamp(minExtra, maxExtra);
                _stickerExtraHeight.value = newExtra;
              },
              onVerticalDragEnd: (details) {
                if (_stickerExtraHeight.value < minExtra * 0.5) {
                  _stickerExtraHeight.value = 0;
                  CometChatUIEvents.hidePanel(
                      _composerId, CustomUIPosition.composerBottom);
                } else if (_stickerExtraHeight.value < 0) {
                  _stickerExtraHeight.value = 0;
                }
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _colorPalette.neutral400 ?? Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: contentHeight,
              child: state.footerPanel!,
            ),
            // Safe area below sticker content
            SizedBox(height: _safeAreaBottom),
          ],
        );
      },
    );
  }

  /// Builds the message input with an attached toolbar (if enabled).
  /// The toolbar and input share a unified visual container with:
  /// - Shared background color
  /// - Shared border
  /// - Divider between input and toolbar
  Widget _buildMessageInputWithToolbar(MessageComposerState state) {
    final toolbar = _buildRichTextToolbar();
    final hasToolbar = toolbar != null;

    // When preview is showing (or animating out), the input visually connects to the preview container above
    final hasPreview = (state.isEditMode && state.editMessage != null) ||
        (state.isReplyMode && state.replyMessage != null) ||
        _previewAnimController.value > 0;

    // If no toolbar, just return the regular message input
    if (!hasToolbar) {
      return _buildMessageInput(state);
    }

    // Build unified container with input + divider + toolbar
    final topRadius = hasPreview ? Radius.zero : Radius.circular(_spacing.radius2 ?? 0);
    final bottomRadius = Radius.circular(_spacing.radius2 ?? 0);

    return CompositedTransformTarget(
      link: _composerLink,
      child: Padding(
        padding: widget.messageInputPadding ??
            EdgeInsets.fromLTRB(
              _spacing.padding2 ?? 0,
              0,
              _spacing.padding2 ?? 0,
              _spacing.padding2 ?? 0,
            ),
        child: Container(
          decoration: BoxDecoration(
            color: _style.backgroundColor ?? _colorPalette.background1,
            border: _style.border ??
                Border(
                  top: hasPreview
                      ? BorderSide.none
                      : BorderSide(
                          color: _colorPalette.borderDefault ?? Colors.transparent,
                          width: 1,
                        ),
                  bottom: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                ),
            borderRadius: _style.borderRadius ??
                BorderRadius.only(
                  topLeft: topRadius,
                  topRight: topRadius,
                  bottomLeft: bottomRadius,
                  bottomRight: bottomRadius,
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message input (without its own border/background)
              _buildMessageInputContent(state),
              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: _colorPalette.borderLight ?? _colorPalette.borderDefault,
                indent: _spacing.padding3 ?? 12,
                endIndent: _spacing.padding3 ?? 12,
              ),
              // Toolbar with ValueListenableBuilder for optimized rebuilds
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ValueListenableBuilder<Set<FormatType>>(
                valueListenable: _activeFormatsNotifier,
                builder: (context, activeFormats, _) {
                  return CometChatRichTextToolbar(
                    onFormatTap: (formatType) {
                      // Handle link format specially
                      if (formatType == FormatType.link) {
                        _showLinkEditDialog();
                        return;
                      }

                      // Ensure a segment has focus before applying format
                      _ensureSegmentFocus();

                      // Route through segment controller when active
                      if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
                        if (formatType == FormatType.codeBlock) {
                          _segmentComposerController!.toggleCodeBlock();
                        } else {
                          _segmentComposerController!.applyFormat(formatType);
                        }
                      } else if (_textEditingController is RichTextEditingController) {
                        (_textEditingController as RichTextEditingController).applyFormat(formatType);
                      } else if (_richTextFormatterManager != null) {
                        // Legacy mode - use formatter manager
                        final legacyFormatType = RichTextFormatType.values.firstWhere(
                          (t) => t.name == formatType.name,
                          orElse: () => RichTextFormatType.bold,
                        );
                        _richTextFormatterManager!.applyFormat(
                          formatType: legacyFormatType,
                          controller: _textEditingController!,
                        );
                      }

                      // Notify callback
                      if (widget.onRichTextFormatApplied != null) {
                        final legacyType = RichTextFormatType.values.firstWhere(
                          (t) => t.name == formatType.name,
                          orElse: () => RichTextFormatType.bold,
                        );
                        widget.onRichTextFormatApplied!(legacyType);
                      }

                      // Update active formats notifier
                      final currentFormats = _getActiveFormats();
                      if (!_setEquals(currentFormats, _previousActiveFormats)) {
                        _previousActiveFormats = currentFormats;
                        _activeFormatsNotifier.value = currentFormats;
                      }
                    },
                    activeFormats: activeFormats,
                    hiddenFormats: _getHiddenFormats(),
                    style: CometChatRichTextToolbarStyle(
                      backgroundColor: Colors.transparent,
                      border: null,
                      borderRadius: BorderRadius.zero,
                    ).merge(_style.richTextToolbarStyle),
                  );
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get active formats for the toolbar
  Set<FormatType> _getActiveFormats() {
    // When using segment-based code blocks, check if we're in a code segment
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      return _segmentComposerController!.getActiveFormats();
    }
    
    if (_textEditingController is RichTextEditingController) {
      return (_textEditingController as RichTextEditingController).getActiveFormats();
    } else if (_richTextFormatterManager != null && _textEditingController != null) {
      // Legacy mode - get from formatter manager
      final legacyFormats = _richTextFormatterManager!.getActiveFormats(
        _textEditingController!.text,
        _textEditingController!.selection.baseOffset,
      );
      return legacyFormats.map((legacyFormat) {
        return FormatType.values.firstWhere(
          (f) => f.name == legacyFormat.name,
          orElse: () => FormatType.bold,
        );
      }).toSet();
    }
    return {};
  }

  /// Get hidden formats for the toolbar
  Set<FormatType> _getHiddenFormats() {
    final hiddenFormats = <FormatType>{};
    final config = widget.richTextConfiguration;
    if (config != null) {
      if (!config.enableBold) hiddenFormats.add(FormatType.bold);
      if (!config.enableItalic) hiddenFormats.add(FormatType.italic);
      if (!config.enableUnderline) hiddenFormats.add(FormatType.underline);
      if (!config.enableStrikethrough) hiddenFormats.add(FormatType.strikethrough);
      if (!config.enableInlineCode) hiddenFormats.add(FormatType.inlineCode);
      if (!config.enableCodeBlock) hiddenFormats.add(FormatType.codeBlock);
      if (!config.enableLinks) hiddenFormats.add(FormatType.link);
      if (!config.enableBulletList) hiddenFormats.add(FormatType.bulletList);
      if (!config.enableOrderedList) hiddenFormats.add(FormatType.orderedList);
      if (!config.enableBlockquote) hiddenFormats.add(FormatType.blockquote);
    }
    return hiddenFormats;
  }

  /// Builds just the message input content without the outer container styling.
  /// Used when the input is part of a unified container with the toolbar.
  Widget _buildMessageInputContent(MessageComposerState state) {
    // When segment-based code blocks are active, use SegmentComposerWidget
    if (_useSegmentBasedCodeBlocks && _segmentComposerController != null) {
      return _buildSegmentBasedInput(state);
    }
    
    // Wrap in ConstrainedBox to limit max height and enable scrolling
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 120, // Max height before scrolling (approximately 4-5 lines)
      ),
      child: CometChatMessageInput(
        text: widget.text,
        textEditingController: _textEditingController,
        placeholderText: widget.placeholderText,
        maxLine: widget.maxLine,
        onChange: _onChange,
        onContentInserted: _handleKeyboardContentInserted,
        primaryButtonView: _buildSendButton(state),
        secondaryButtonView: _buildSecondaryButtonView(state),
        auxiliaryButtonsAlignment:
            widget.auxiliaryButtonsAlignment ?? AuxiliaryButtonsAlignment.right,
        auxiliaryButtonView: _buildAuxiliaryButtonView(state),
        // Code block is now inline - no special indicator needed
        showCodeBlockIndicator: false,
        codeBlockIndicatorColor: _colorPalette.primary,
        codeBlockContent: null,
        style: CometChatMessageInputStyle(
          filledColor: _style.filledColor,
          dividerTint: _style.dividerColor ?? _colorPalette.borderLight,
          dividerHeight: _style.dividerHeight,
          backgroundColor: Colors.transparent, // Transparent - parent container has background
          textStyle: TextStyle(
            color: _colorPalette.textPrimary,
            fontSize: _typography.body?.regular?.fontSize,
            fontWeight: _typography.body?.regular?.fontWeight,
            fontFamily: _typography.body?.regular?.fontFamily,
          )
              .merge(_style.textStyle)
              .copyWith(color: _style.textColor),
          placeholderTextStyle: TextStyle(
            color: _colorPalette.textTertiary,
            fontSize: _typography.body?.regular?.fontSize,
            fontWeight: _typography.body?.regular?.fontWeight,
            fontFamily: _typography.body?.regular?.fontFamily,
          ).merge(_style.placeHolderTextStyle).copyWith(
                color: _style.placeHolderTextColor,
              ),
          border: null, // No border - parent container has border
          borderRadius: BorderRadius.zero, // No radius - parent container has radius
        ),
        focusNode: _focusNode,
      ),
    );
  }

  /// Builds segment-based input for Slack-style code blocks.
  /// Each segment (normal text or code block) has its own text field.
  /// This matches the layout of CometChatMessageInput.
  Widget _buildSegmentBasedInput(MessageComposerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Secondary buttons (left side - attachment button)
          if (widget.secondaryButtonView != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: widget.secondaryButtonView!(context, widget.user, widget.group, _composerId),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: _buildSecondaryButtonView(state),
            ),

          // Auxiliary buttons (left alignment option)
          if (widget.auxiliaryButtonsAlignment == AuxiliaryButtonsAlignment.left)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: _buildAuxiliaryButtonView(state),
            ),

          // Segment composer (center, expanded)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: _spacing.padding2 ?? 8,
                right: _spacing.padding2 ?? 8,
                top: 12,
                bottom: 12,
              ),
              child: SegmentComposerWidget(
                controller: _segmentComposerController!,
                placeholder: widget.placeholderText ?? 
                    Translations.of(context).typeYourMessage,
                colorPalette: _colorPalette,
                spacing: _spacing,
                typography: _typography,
                textStyle: TextStyle(
                  color: _colorPalette.textPrimary,
                  fontSize: _typography.body?.regular?.fontSize,
                  fontWeight: _typography.body?.regular?.fontWeight,
                  fontFamily: _typography.body?.regular?.fontFamily,
                ).merge(_style.textStyle).copyWith(color: _style.textColor),
                placeholderStyle: TextStyle(
                  color: _colorPalette.textTertiary,
                  fontSize: _typography.body?.regular?.fontSize,
                  fontWeight: _typography.body?.regular?.fontWeight,
                  fontFamily: _typography.body?.regular?.fontFamily,
                ).merge(_style.placeHolderTextStyle).copyWith(
                      color: _style.placeHolderTextColor,
                    ),
                maxHeight: 120,
                onContentInserted: _handleKeyboardContentInserted,
                onChange: (text) {
                  _onChange(text);
                },
              ),
            ),
          ),

          // Auxiliary buttons (right alignment - default)
          if (widget.auxiliaryButtonsAlignment == AuxiliaryButtonsAlignment.right ||
              widget.auxiliaryButtonsAlignment == null)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: _buildAuxiliaryButtonView(state),
            ),

          // Primary/Send button (far right)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            child: _buildSendButton(state),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(MessageComposerState state) {
    // When preview is showing (or animating out), the input visually connects to the preview container above:
    // - no top border (preview container provides it)
    // - square top corners (preview container has the rounded top)
    final hasPreview = (state.isEditMode && state.editMessage != null) ||
        (state.isReplyMode && state.replyMessage != null) ||
        _previewAnimController.value > 0;
    final topRadius = hasPreview ? Radius.zero : Radius.circular(_spacing.radius2 ?? 0);
    final bottomRadius = Radius.circular(_spacing.radius2 ?? 0);

    return CompositedTransformTarget(
      link: _composerLink,
      child: Padding(
        padding: widget.messageInputPadding ??
            EdgeInsets.fromLTRB(
              _spacing.padding2 ?? 0,
              0,
              _spacing.padding2 ?? 0,
              _spacing.padding2 ?? 0,
            ),
        child: CometChatMessageInput(
          text: widget.text,
          textEditingController: _textEditingController,
          placeholderText: widget.placeholderText,
          maxLine: widget.maxLine,
          onChange: _onChange,
          primaryButtonView: _buildSendButton(state),
          secondaryButtonView: _buildSecondaryButtonView(state),
          auxiliaryButtonsAlignment:
          widget.auxiliaryButtonsAlignment ?? AuxiliaryButtonsAlignment.right,
          auxiliaryButtonView: _buildAuxiliaryButtonView(state),
          // Code block is now inline - no special indicator needed
          showCodeBlockIndicator: false,
          codeBlockIndicatorColor: _colorPalette.primary,
          codeBlockContent: null,
          style: CometChatMessageInputStyle(
            filledColor: _style.filledColor,
            dividerTint: _style.dividerColor ?? _colorPalette.borderLight,
            dividerHeight: _style.dividerHeight,
            backgroundColor: _style.backgroundColor ?? _colorPalette.background1,
            textStyle: TextStyle(
              color: _colorPalette.textPrimary,
              fontSize: _typography.body?.regular?.fontSize,
              fontWeight: _typography.body?.regular?.fontWeight,
              fontFamily: _typography.body?.regular?.fontFamily,
            )
                .merge(_style.textStyle)
                .copyWith(color: _style.textColor),
            placeholderTextStyle: TextStyle(
              color: _colorPalette.textTertiary,
              fontSize: _typography.body?.regular?.fontSize,
              fontWeight: _typography.body?.regular?.fontWeight,
              fontFamily: _typography.body?.regular?.fontFamily,
            ).merge(_style.placeHolderTextStyle).copyWith(
              color: _style.placeHolderTextColor,
            ),
            border: _style.border ??
                Border(
                  top: hasPreview
                      ? BorderSide.none
                      : BorderSide(
                          color: _colorPalette.borderDefault ?? Colors.transparent,
                          width: 1,
                        ),
                  bottom: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: _colorPalette.borderDefault ?? Colors.transparent,
                    width: 1,
                  ),
                ),
            borderRadius: _style.borderRadius ??
                BorderRadius.only(
                  topLeft: topRadius,
                  topRight: topRadius,
                  bottomLeft: bottomRadius,
                  bottomRight: bottomRadius,
                ),
          ),
          focusNode: _focusNode,
        ),
      ),
    );
  }

  Widget _buildInlineAudioRecorder() {
    return Padding(
      padding: widget.messageInputPadding ??
          EdgeInsets.fromLTRB(
            _spacing.padding2 ?? 0,
            0,
            _spacing.padding2 ?? 0,
            _spacing.padding2 ?? 0,
          ),
      child: CometChatInlineAudioRecorder(
        style: _style.inlineAudioRecorderStyle,
        onSubmit: (path) {
          _bloc.add(SubmitAudioRecording(path));
        },
        onCancel: () {
          _bloc.add(const CancelAudioRecording());
        },
        deleteIcon: widget.recorderDeleteButtonIcon,
        sendIcon: widget.recorderSendButtonIcon,
        recordIcon: widget.recorderStartButtonIcon,
        pauseIcon: widget.recorderPauseButtonIcon,
        stopIcon: widget.recorderStopButtonIcon,
      ),
    );
  }
}

/// Internal widget for displaying rich text preview
class _RichTextPreviewPanel extends StatelessWidget {
  const _RichTextPreviewPanel({
    required this.text,
    required this.formatters,
    required this.colorPalette,
    required this.typography,
    required this.spacing,
  });

  final String text;
  final List<RichTextFormatterBase> formatters;
  final CometChatColorPalette colorPalette;
  final CometChatTypography typography;
  final CometChatSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.padding3 ?? 12),
      decoration: BoxDecoration(
        color: colorPalette.primary ?? Colors.purple,
        borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                size: 14,
                color: colorPalette.white?.withValues(alpha: 0.7),
              ),
              SizedBox(width: spacing.padding1 ?? 4),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: typography.caption1?.medium?.fontSize ?? 11,
                  fontWeight: typography.caption1?.medium?.fontWeight ?? FontWeight.w500,
                  color: colorPalette.white?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.padding2 ?? 8),
          // Formatted text
          _buildFormattedText(context),
        ],
      ),
    );
  }

  Widget _buildFormattedText(BuildContext context) {
    // Check if there are any block-level elements (code blocks, blockquotes)
    final hasBlockElements = formatters.any((f) =>
    f.formatType == RichTextFormatType.codeBlock ||
        f.formatType == RichTextFormatType.blockquote);

    if (hasBlockElements) {
      // Use Column-based rendering for block elements
      return _buildBlockFormattedText(context);
    }

    // Use RichText for inline-only formatting
    final spans = _buildTextSpans(context);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize ?? 14,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
          color: colorPalette.white,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  /// Builds formatted text with proper block-level rendering for code blocks and blockquotes
  Widget _buildBlockFormattedText(BuildContext context) {
    final List<Widget> widgets = [];
    final List<_PreviewFormatMatch> allMatches = [];

    // Collect all matches
    for (final formatter in formatters) {
      if (formatter.pattern == null) continue;

      // Handle code blocks specially - use custom parsing for multi-line support
      if (formatter.formatType == RichTextFormatType.codeBlock) {
        final codeBlocks = _findCodeBlocks(text);
        for (final block in codeBlocks) {
          allMatches.add(_PreviewFormatMatch(
            start: block.start,
            end: block.end,
            fullMatch: text.substring(block.start, block.end),
            content: block.content,
            formatter: formatter,
          ));
        }
        continue;
      }

      for (final match in formatter.pattern!.allMatches(text)) {
        String content;

        // Handle blockquote specially - extract content from all lines
        if (formatter.formatType == RichTextFormatType.blockquote) {
          content = _extractBlockquoteContent(match.group(0) ?? '');
        } else {
          // For other formats, use group 1 if available
          content = match.groupCount > 0 ? (match.group(1) ?? match.group(0) ?? '') : match.group(0) ?? '';
        }

        allMatches.add(_PreviewFormatMatch(
          start: match.start,
          end: match.end,
          fullMatch: match.group(0) ?? '',
          content: content,
          formatter: formatter,
        ));
      }
    }

    // Sort by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // Remove overlapping matches
    final List<_PreviewFormatMatch> nonOverlapping = [];
    int lastEnd = 0;
    for (final match in allMatches) {
      if (match.start >= lastEnd) {
        nonOverlapping.add(match);
        lastEnd = match.end;
      }
    }

    // White text on purple background
    final defaultStyle = TextStyle(
      fontSize: typography.body?.regular?.fontSize ?? 14,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
      color: colorPalette.white,
    );

    int currentIndex = 0;

    for (final match in nonOverlapping) {
      // Add text before this match
      if (match.start > currentIndex) {
        final beforeText = text.substring(currentIndex, match.start).trim();
        if (beforeText.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(beforeText, style: defaultStyle),
            ),
          );
        }
      }

      // Check if this is a block-level element
      final isBlockElement = match.formatter.formatType == RichTextFormatType.codeBlock ||
          match.formatter.formatType == RichTextFormatType.blockquote;

      if (isBlockElement) {
        // Render as block widget with left accent bar
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildBlockWidget(context, match),
          ),
        );
      } else {
        // Render as inline text
        final formatStyle = _getPreviewStyleForFormatter(context, match.formatter);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              match.content.trim(),
              style: defaultStyle.merge(formatStyle),
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      final afterText = text.substring(currentIndex).trim();
      if (afterText.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(afterText, style: defaultStyle),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets.isEmpty ? [const SizedBox.shrink()] : widgets,
    );
  }

  /// Builds a Slack-style block widget
  /// Code block: full-width dark background, no left bar
  /// Blockquote: left accent bar with background
  Widget _buildBlockWidget(BuildContext context, _PreviewFormatMatch match) {
    final isCodeBlock = match.formatter.formatType == RichTextFormatType.codeBlock;

    final content = match.content.trim();

    if (isCodeBlock) {
      // Slack-style code block: contrasting background
      // Light mode: dark background + white text
      // Dark mode: light background + black text
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final backgroundColor = isDarkMode
          ? (colorPalette.neutral200 ?? const Color(0xFFE0E0E0))
          : (colorPalette.neutral800 ?? const Color(0xFF1E1E1E));
      final textColor = isDarkMode
          ? (colorPalette.neutral900 ?? Colors.black)
          : (colorPalette.white ?? Colors.white);

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: typography.body?.regular?.fontSize ?? 14,
              color: textColor,
            ),
          ),
        ),
      );
    }

    // Blockquote: just left accent bar, no background, white text on purple preview
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colorPalette.white?.withValues(alpha: 0.6) ?? Colors.white70,
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
        child: Text(
          content,
          style: TextStyle(
            fontSize: typography.body?.regular?.fontSize ?? 14,
            color: colorPalette.white,
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(BuildContext context) {
    // Collect all matches from all formatters
    final List<_PreviewFormatMatch> allMatches = [];

    for (final formatter in formatters) {
      if (formatter.pattern == null) continue;

      for (final match in formatter.pattern!.allMatches(text)) {
        allMatches.add(_PreviewFormatMatch(
          start: match.start,
          end: match.end,
          fullMatch: match.group(0) ?? '',
          content: match.groupCount > 0 ? (match.group(1) ?? match.group(0) ?? '') : match.group(0) ?? '',
          formatter: formatter,
        ));
      }
    }

    // Sort by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // Remove overlapping matches (keep the first one)
    final List<_PreviewFormatMatch> nonOverlapping = [];
    int lastEnd = 0;
    for (final match in allMatches) {
      if (match.start >= lastEnd) {
        nonOverlapping.add(match);
        lastEnd = match.end;
      }
    }

    // Build spans
    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    final defaultStyle = TextStyle(
      fontSize: typography.body?.regular?.fontSize ?? 14,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
      color: colorPalette.textPrimary,
    );

    for (final match in nonOverlapping) {
      // Add text before this match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: defaultStyle,
        ));
      }

      // Add formatted text (content without markers)
      final formatStyle = _getPreviewStyleForFormatter(context, match.formatter);

      spans.add(TextSpan(
        text: match.content,
        style: defaultStyle.merge(formatStyle),
      ));

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  TextStyle _getPreviewStyleForFormatter(BuildContext context, RichTextFormatterBase formatter) {
    switch (formatter.formatType) {
      case RichTextFormatType.bold:
        return TextStyle(
          fontWeight: FontWeight.bold,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.italic:
        return TextStyle(
          fontStyle: FontStyle.italic,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.strikethrough:
        return TextStyle(
          decoration: TextDecoration.lineThrough,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.inlineCode:
        return TextStyle(
          fontFamily: 'monospace',
          backgroundColor: colorPalette.background3,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.codeBlock:
        return TextStyle(
          fontFamily: 'monospace',
          backgroundColor: colorPalette.background3,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.blockquote:
        return TextStyle(
          backgroundColor: colorPalette.background3,
          color: colorPalette.textPrimary,
        );
      case RichTextFormatType.link:
        return TextStyle(
          decoration: TextDecoration.underline,
          color: colorPalette.primary,
        );
      default:
        return const TextStyle();
    }
  }

  /// Extract content from blockquote lines, stripping > markers
  /// Joins multiple lines into one block content
  String _extractBlockquoteContent(String matchedText) {
    final lines = matchedText.split('\n');
    final contentLines = <String>[];

    for (final line in lines) {
      // Remove > and optional space from start of line
      String content = line;
      if (content.startsWith('> ')) {
        content = content.substring(2);
      } else if (content.startsWith('>')) {
        content = content.substring(1);
      }
      contentLines.add(content);
    }

    return contentLines.join('\n');
  }

  /// Find all code blocks in text (both complete and open-ended)
  List<_CodeBlockInfo> _findCodeBlocks(String text) {
    final List<_CodeBlockInfo> blocks = [];
    int i = 0;

    while (i < text.length) {
      // Look for opening ```
      if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
        final blockStart = i;
        i += 3;

        // Skip optional newline after opening ```
        if (i < text.length && text[i] == '\n') {
          i++;
        }

        final contentStart = i;

        // Find closing ``` or end of text
        int? closingPos;
        while (i < text.length) {
          if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
            closingPos = i;
            break;
          }
          i++;
        }

        if (closingPos != null) {
          // Complete block - content is between opening and closing
          String content = text.substring(contentStart, closingPos);
          // Remove trailing newline if present
          if (content.endsWith('\n')) {
            content = content.substring(0, content.length - 1);
          }
          if (content.isNotEmpty) {
            blocks.add(_CodeBlockInfo(
              start: blockStart,
              end: closingPos + 3,
              content: content,
            ));
          }
          i = closingPos + 3;
        } else {
          // Open block (no closing ```) - content is from opening to end of text
          String content = text.substring(contentStart);
          // Remove trailing newline if present
          if (content.endsWith('\n')) {
            content = content.substring(0, content.length - 1);
          }
          if (content.isNotEmpty) {
            blocks.add(_CodeBlockInfo(
              start: blockStart,
              end: text.length,
              content: content,
            ));
          }
          break;
        }
      } else {
        i++;
      }
    }

    return blocks;
  }
}

/// Helper class for code block info in preview
class _CodeBlockInfo {
  final int start;
  final int end;
  final String content;

  _CodeBlockInfo({
    required this.start,
    required this.end,
    required this.content,
  });
}

/// Helper class to store format match information for preview
class _PreviewFormatMatch {
  final int start;
  final int end;
  final String fullMatch;
  final String content;
  final RichTextFormatterBase formatter;

  _PreviewFormatMatch({
    required this.start,
    required this.end,
    required this.fullMatch,
    required this.content,
    required this.formatter,
  });
}
