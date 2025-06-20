import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'dart:io';

///[CometChatMessageComposerController] is the view model for [CometChatMessageComposer]
///it contains all the business logic involved in changing the state of the UI of [CometChatMessageComposer]
class CometChatMessageComposerController extends GetxController
    with
        CometChatMessageEventListener,
        CometChatUIEventListener,
        CometChatUserEventListener {
  CometChatMessageComposerController({
    this.user,
    this.group,
    this.text,
    this.parentMessageId = 0,
    this.disableSoundForMessages = false,
    this.customSoundForMessage,
    this.customSoundForMessagePackage,
    this.disableTypingEvents = false,
    // this.hideLiveReaction = false,
    this.attachmentOptions,
    // this.liveReactionIconURL,
    this.stateCallBack,
    this.headerView,
    this.footerView,
    this.onSendButtonTap,
    this.onError,
    this.aiOptionStyle,
    this.disableMentions = false,
    this.previewView,
    this.textFormatters,
    this.textEditingController,
    this.mentionsStyle,
    this.style,
    this.colorPalette,
    this.typography,
    this.spacing,
    required this.context,
    this.suggestionListStyle,
    this.auxiliaryButtonIconColor,
    this.hideStickersButton,
    this.hideAudioAttachmentOption,
    this.hideCollaborativeDocumentOption,
    this.hideCollaborativeWhiteboardOption,
    this.hideFileAttachmentOption,
    this.hideImageAttachmentOption,
    this.hidePollsOption,
    this.hideVideoAttachmentOption,
    this.hideTakePhotoOption,
  }) {
    tag = "tag$counter";
    counter++;
  }

  //-------------------------Variable Declaration-----------------------------

  ///[previewMessageMode] controls the visibility of message preview above input field
  PreviewMessageMode previewMessageMode = PreviewMessageMode.none;

  ///[messagePreviewTitle] title text of message preview
  String? messagePreviewTitle;

  ///[messagePreviewSubtitle] subtitle text of message preview
  String? messagePreviewSubtitle;

  ///[oldMessage] the message to edit
  BaseMessage? oldMessage;

  ///[receiverID] the uid of the user or guid of the group
  String receiverID = "";

  ///[receiverType] type of AppEntity

  String receiverType = "";

  ///[textEditingController] controls the state of the text field
  TextEditingController? textEditingController;

  ///[hideStickersButton] is a [bool] that can be used to hide/display sticker button
  final bool? hideStickersButton;

  ///[loggedInUser] is the user the message is being sent from
  User loggedInUser = User(name: '', uid: '');
  final _deBouncer = Debouncer(milliseconds: 1000);

  ///[_previousText] holds the state of the last typed text
  String _previousText = "";

  ///[headerView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? headerView;

  ///[footerView] ui component to be forwarded to message input component
  final ComposerWidgetBuilder? footerView;

  ///[previewView] ui component to be forwarded to message composer component, to be shown in place of the message preview bubble
  final ComposerWidgetBuilder? previewView;

  ///[_actionItems] show up in attachment options
  final List<ActionItem> _actionItems = [];

  ///[user] user object to send messages to
  final User? user;

  ///[text] initial text for the input field
  final String? text;

  ///[parentMessageId] parent message id for in thread messages
  final int parentMessageId;

  ///[disableSoundForMessages] if true then disables outgoing message sound
  final bool disableSoundForMessages;

  ///[customSoundForMessage] custom outgoing message sound assets url
  final String? customSoundForMessage;

  ///[group] group object to send messages to
  final Group? group;

  ///[disableTypingEvents] if true then disables is typing indicator
  final bool disableTypingEvents;

  ///[attachmentOptions] options to display on tapping attachment button
  final ComposerActionsBuilder? attachmentOptions;

  ///if sending sound url from other package pass package name here
  final String? customSoundForMessagePackage;

  ///[stateCallBack] retrieves the state of the composer
  final void Function(CometChatMessageComposerController)? stateCallBack;

  ///[onSendButtonTap] some task to execute if user presses the primary/send button
  final Function(BuildContext, BaseMessage, PreviewMessageMode?)?
      onSendButtonTap;

  ///[onError] callback triggered in case any error happens when sending a message
  final OnError? onError;

  ///[_isTyping] state of typing events
  bool _isTyping = false;

  ///[getAttachmentOptionsCalled] is used to call attachment options only once
  bool getAttachmentOptionsCalled = false;

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

  late BuildContext context;

  static int counter = 0;
  late String tag;

  late String _dateString;
  late String _uiMessageListener;
  late String _uiEventListener;

  ///[header] shown in header view
  Widget? header;

  ///[footer] shown in footer view
  Widget? footer;

  ///[preview] shown in preview view
  Widget? preview;

  Map<String, dynamic> composerId = {};

  AIOptionsStyle? aiOptionStyle;

  late FocusNode focusNode;

  List<SuggestionListItem> suggestions = [];
  late StreamSubscription<List<SuggestionListItem>> _subscription;

  /// Create a stream controller
  final StreamController<List<SuggestionListItem>> _suggestionListController =
      StreamController<List<SuggestionListItem>>();

  /// Create a stream from the controller
  late Stream<List<SuggestionListItem>> _suggestionListStream;

  /// Create a stream controller
  final StreamController<String> _previousTextController =
      StreamController<String>();

  /// Create a stream from the controller
  late Stream<String> _previousTextStream;

  bool _isMyController = true;

  String? _currentSearchKeyword;
  bool _searcKeywordChanged = true;
  bool? disableMentions;

  List<CometChatTextFormatter> _formatters = [];

  ///[textFormatters] is a list of [CometChatTextFormatter] which is used to format the text
  List<CometChatTextFormatter>? textFormatters;

  ///[mentionsStyle] is a [CometChatMentionsStyle] which is used to style the mentions
  final CometChatMentionsStyle? mentionsStyle;

  CometChatAttachmentOptionSheetStyle? _actionStyle;

  var overlayPortalController = OverlayPortalController();

  CometChatSpacing? spacing;
  CometChatColorPalette? colorPalette;
  CometChatTypography? typography;

  ///[suggestionListStyle] provides style to the mentions
  CometChatSuggestionListStyle? suggestionListStyle;

  ///[style] message composer style
  final CometChatMessageComposerStyle? style;

  ///[auxiliaryOptions] provides auxiliary options to the composer
  Widget? auxiliaryOptions;

  ///[auxiliaryButtonIconColor] provides color to the auxiliary button icon
  Color? auxiliaryButtonIconColor;

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    if (textEditingController != null) {
      _isMyController = false;
    }
    populateComposerId();
    _suggestionListStream = _suggestionListController.stream;
    _previousTextStream = _previousTextController.stream;

    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _uiMessageListener = "${_dateString}UI_message_listener";
    _uiEventListener = "${_dateString}UI_event_listener";

    /// Subscribe to the stream
    _subscription =
        _suggestionListStream.listen((List<SuggestionListItem> value) {
      bool shouldScrollDown = false;
      if (value.isNotEmpty && _currentSearchKeyword != null) {
        if (_searcKeywordChanged) {
          suggestions = value;
          _searcKeywordChanged = false;
        } else {
          for (var element in value) {
            if (!suggestions.contains(element)) {
              suggestions.add(element);
            }
          }
            shouldScrollDown = true;
          }
          hasMore = true;
          update();

            CometChatUIEvents.showPanel(
                composerId,
                CustomUIPosition.composerPreview,
                (context) => getList(context, textEditingController!,
                    colorPalette, spacing, typography));
            overlayPortalController.show();
            if (shouldScrollDown) {
              _scrollDown();
            } else {
              if (_searcKeywordChanged) {
                CometChatUIEvents.hidePanel(
                    composerId, CustomUIPosition.composerPreview);
                suggestions.clear();
              }

              hasMore = false;
              update();
            }
      }
    });

    _previousTextStream.listen((String value) {
      _previousText = value;
    });

    initializeFormatters();
    textEditingController ??=
        CustomTextEditingController(text: text, formatters: _formatters);

    CometChatMessageEvents.addMessagesListener(_uiMessageListener, this);
    CometChatUIEvents.addUiListener(_uiEventListener, this);

    CometChatUserEvents.addUsersListener(_uiEventListener, this);

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

    focusNode = FocusNode();

    focusNode.addListener(_onFocusChange);

    if (getAttachmentOptionsCalled == false) {
      getAttachmentOptionsCalled = true;
      getAttachmentOptions(
          context, colorPalette!, typography!);
    }
    initializeHeaderView();
    initializeFooterView();

    auxiliaryOptions = initAuxiliaryOption();

    super.onInit();
  }

  initAuxiliaryOption() {
    AdditionalConfigurations additionalConfigurations = AdditionalConfigurations(
      hideStickersButton: hideStickersButton,
    );
    return CometChatUIKit.getDataSource()
        .getAuxiliaryOptions(
      user,
      group,
      context,
      composerId,
      auxiliaryButtonIconColor,
        additionalConfigurations: additionalConfigurations,
    );
  }

  void initializeFormatters() {
    _formatters = textFormatters ?? [];

    if ((_formatters.isEmpty ||
            _formatters.indexWhere(
                    (element) => element is CometChatMentionsFormatter) ==
                -1) &&
        disableMentions != true) {
      _formatters.add(CometChatMentionsFormatter(style: mentionsStyle));
    }

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

  void _onFormatterSearch(String? searchKeyword) {
    _searcKeywordChanged = _currentSearchKeyword != searchKeyword;
    _currentSearchKeyword = searchKeyword;

    if (_currentSearchKeyword == null) {
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerPreview);
      suggestions.clear();
    }
    update();

    return;
  }

  final ScrollController _controller = ScrollController();

  /// This is what you're looking for!
  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  populateComposerId() {
    if (parentMessageId != 0) {
      composerId['parentMessageId'] = parentMessageId;
    }
    if (group != null) {
      composerId['guid'] = group!.guid;
    } else if (user != null) {
      composerId['uid'] = user!.uid;
    }
  }

  @override
  void onClose() {
    if (_isMyController) {
      textEditingController?.dispose();
    }
    CometChatMessageEvents.removeMessagesListener(_uiMessageListener);
    CometChatUIEvents.removeUiListener(_uiEventListener);
    CometChatUserEvents.removeUsersListener(_uiEventListener);
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    _subscription.cancel();
    super.onClose();
  }

  bool hasMore = true;

  Widget getList(
      BuildContext context,
      TextEditingController textEditingController,
      CometChatColorPalette? colorPalette,
      CometChatSpacing? spacing,
      CometChatTypography? typography) {
    return Container(
      margin: EdgeInsets.fromLTRB(spacing?.margin2 ?? 0, 0,
          spacing?.margin2 ?? 0, spacing?.margin1 ?? 0),
      padding: EdgeInsets.symmetric(vertical: spacing?.padding2 ?? 0),
      constraints: BoxConstraints(
        maxHeight: suggestions.length > 4
            ? 220
            : suggestions.isEmpty
                ? 66
                : suggestions.length * 75.5,
      ),
      decoration: BoxDecoration(
        color:
            suggestionListStyle?.backgroundColor ?? colorPalette?.background1,
        border: suggestionListStyle?.border ??
            Border.all(
                width: 1,
                color: colorPalette?.borderDark ?? Colors.transparent),
        borderRadius: suggestionListStyle?.borderRadius ??
            BorderRadius.circular(
              spacing?.radius4 ?? 0,
            ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff10182808).withOpacity(.03),
            spreadRadius: -2,
            blurRadius: 6,
            offset: const Offset(0, 4), // changes position of shadow
          ),
          BoxShadow(
            color: const Color(0xff10182808).withOpacity(.08),
            spreadRadius: -4,
            blurRadius: 16,
            offset: const Offset(0, 12), // changes position of shadow
          ),
        ],
      ),
      child: ListView.builder(
        controller: _controller,
        itemCount: hasMore ? suggestions.length + 1 : suggestions.length,
        itemBuilder: (context, index) {
          if (index >= suggestions.length) {
            hasMore = true;
          }
          if (hasMore && index >= suggestions.length) {
            for (var element in _formatters) {
              if (_currentSearchKeyword != null &&
                  _currentSearchKeyword!.isNotEmpty &&
                  element.trackingCharacter == _currentSearchKeyword![0]) {
                element.onScrollToBottom(textEditingController);
              }
            }

            return const SizedBox();
          }

          return index < suggestions.length
              ? getListItem(
                  suggestions[index], colorPalette, spacing, typography)
              : const SizedBox();
        },
      ),
    );
  }

  Widget getListItem(
      SuggestionListItem item,
      CometChatColorPalette? colorPalette,
      CometChatSpacing? spacing,
      CometChatTypography? typography) {
    ListTile tile = ListTile(
      contentPadding: EdgeInsets.symmetric(
          horizontal: spacing?.padding4 ?? 0, vertical: spacing?.padding2 ?? 0),
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
        }
        overlayPortalController.hide();
        suggestions.clear();
        _currentSearchKeyword = null;
        _searcKeywordChanged = true;
      },
      title: Text(
        item.title ?? "",
        style: TextStyle(
                fontSize: typography?.heading4?.medium?.fontSize,
                fontWeight: typography?.heading4?.medium?.fontWeight,
                fontFamily: typography?.heading4?.medium?.fontFamily,
                color: colorPalette?.textPrimary)
            .merge(suggestionListStyle?.textStyle).copyWith(color:  suggestionListStyle?.textColor),
      ),
      leading: item.avatarName == null && item.avatarUrl == null
          ? null
          : CometChatAvatar(
              name: item.avatarName,
              image: item.avatarUrl,
              style: suggestionListStyle?.avatarStyle,
            ),
    );

    return tile;
  }

  //------------------------Message UI Event Listeners------------------------------

  @override
  void ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    if (status == MessageEditStatus.inProgress &&
        message.parentMessageId == parentMessageId) {
      previewMessage(message, PreviewMessageMode.edit);
    }
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
    if (kDebugMode) {
      print("is for this ID $id ${isForThisWidget(id)}");
    }
    if (isForThisWidget(id) == false) return;
    if(id?.containsKey(AIUtils.extensionKey)==true){
      String? extension =id?[AIUtils.extensionKey];
      if(extension==AIFeatureConstants.aiSmartReplies || extension==AIFeatureConstants.aiConversationSummary){
        activeAiFeatures = true;
        aiFeatureEnabled = extension ?? "";
      }
    }
    if (uiPosition == CustomUIPosition.composerBottom) {
      footer = child(context);
    } else if (uiPosition == CustomUIPosition.composerTop) {
      header = child(context);
    } else if (uiPosition == CustomUIPosition.composerPreview) {
      preview = child(context);
    }
    update();
  }

  @override
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    if (isForThisWidget(id) == false) return;
    if(id?.containsKey(AIUtils.extensionKey)==true){
      String? extension =id?[AIUtils.extensionKey];
      if(extension==AIFeatureConstants.aiSmartReplies || extension==AIFeatureConstants.aiConversationSummary){
        activeAiFeatures = false;
      }
    }
    if (uiPosition == CustomUIPosition.composerBottom) {
      footer = null;
    } else if (uiPosition == CustomUIPosition.composerTop) {
      header = null;
    } else if (uiPosition == CustomUIPosition.composerPreview) {
      preview = null;
    }
    update();
  }

  bool isSameConversation(BaseMessage message) {
    return true;
  }


  //-----------------------Internal Dependency Initialization-------------------------
  initializeHeaderView() {
    if (headerView != null) {
      header = headerView!(context, user, group, composerId);
    }
  }

  initializeFooterView() {
    if (footerView != null) {
      footer = footerView!(context, user, group, composerId);
    }
  }

  _getLoggedInUser() async {
    User? user = await CometChat.getLoggedInUser();
    if (user != null) {
      loggedInUser = user;
    }
  }

  getAttachmentOptions(BuildContext context, CometChatColorPalette colorPalette,
      CometChatTypography typography) {
    final attachmentOptionSheetStyle = CometChatThemeHelper.getTheme<CometChatAttachmentOptionSheetStyle>(
        context: context,
        defaultTheme: CometChatAttachmentOptionSheetStyle.of)
        .merge(style?.attachmentOptionSheetStyle);

    if (attachmentOptions != null) {
      List<CometChatMessageComposerAction> actionList =
          attachmentOptions!(context, user, group, {});


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
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
              ).merge(
                _actionStyle?.titleTextStyle,
              ),
              backgroundColor:
                  _actionStyle?.backgroundColor,
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
      AdditionalConfigurations additionalConfigurations =
          AdditionalConfigurations(
        attachmentOptionSheetStyle: attachmentOptionSheetStyle,
            hideAudioAttachmentOption: hideAudioAttachmentOption,
            hideCollaborativeDocumentOption: hideCollaborativeDocumentOption,
            hideCollaborativeWhiteboardOption: hideCollaborativeWhiteboardOption,
            hideFileAttachmentOption: hideFileAttachmentOption,
            hideImageAttachmentOption: hideImageAttachmentOption,
            hidePollsOption: hidePollsOption,
            hideVideoAttachmentOption: hideVideoAttachmentOption,
            hideTakPhotoOption: hideTakePhotoOption,
      );
      final defaultOptions =
          CometChatUIKit.getDataSource().getAttachmentOptions(
        context,
        composerId,
        additionalConfigurations,
      );
      for (CometChatMessageComposerAction defaultAttachmentOptions in defaultOptions) {
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
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
              ).merge(
                _actionStyle?.titleTextStyle,
              ),
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
  }

  //-----------------------methods performing API calls-----------------------------

  _checkFormatter() {
    for (var element in _formatters) {
      if (_currentSearchKeyword == null ||
          (_currentSearchKeyword != null &&
              _currentSearchKeyword!.isNotEmpty &&
              element.trackingCharacter == _currentSearchKeyword![0])) {
        try {
          element.onChange(textEditingController!, _previousText);
        } catch (err) {
          if (kDebugMode) {
            print("error caught in message composer onchange $err");
          }
        }
      }
    }
  }

  _onTyping() {
    if (textEditingController == null) return;
    if ((_previousText.isEmpty && textEditingController!.text.isNotEmpty) ||
        (_previousText.isNotEmpty && textEditingController!.text.isEmpty) ||
        ((oldMessage != null) && _previousText == (oldMessage as TextMessage).text && textEditingController!.text != (oldMessage as TextMessage).text) ||
        ((oldMessage != null) && _previousText != (oldMessage as TextMessage).text && textEditingController!.text == (oldMessage as TextMessage).text)
    ) {
      update();
    }
    if (_previousText.length > textEditingController!.text.length) {
      _checkFormatter();
      _previousText = textEditingController!.text;
      return;
    }

    _checkFormatter();
    _previousText = textEditingController!.text;

    if (disableTypingEvents == false && (group != null || userIsNotBlocked())) {
      if (_isTyping == false) {
        CometChat.startTyping(
            receiverUid: receiverID, receiverType: receiverType);
        _isTyping = true;
      }
      //turns off emitting typing events if user doesn't types something in the last 1000 milliseconds
      _deBouncer.run(() {
        if (_isTyping) {
          CometChat.endTyping(
              receiverUid: receiverID, receiverType: receiverType);
          _isTyping = false;
        }
      });
    }
  }

  handlePreMessageSend(BaseMessage baseMessage) {
    for (var element in _formatters) {
      element.handlePreMessageSend(context, baseMessage);
    }
  }

  sendTextMessage({Map<String, dynamic>? metadata}) {
    if (textEditingController == null) return;
    String messagesText = textEditingController!.text.trim();
    String type = MessageTypeConstants.text;

    TextMessage textMessage = TextMessage(
      sender: loggedInUser,
      text: messagesText,
      receiverUid: receiverID,
      receiverType: receiverType,
      type: type,
      metadata: metadata,
      parentMessageId: parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    handlePreMessageSend(textMessage);

    oldMessage = null;
    messagePreviewTitle = '';
    messagePreviewSubtitle = '';
    previewMessageMode = PreviewMessageMode.none;
    textEditingController?.clear();
    _previousText = '';
    update();
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, textMessage, previewMessageMode);
    } else {
      CometChatMessageEvents.ccMessageSent(
          textMessage, MessageStatus.inProgress);

      CometChat.sendMessage(textMessage, onSuccess: (TextMessage message) {
        debugPrint("Message sent successfully:  ${message.text}");
        if (disableSoundForMessages == false) {
          CometChatUIKit.soundManager.play(
              sound: Sound.outgoingMessage,
              customSound: customSoundForMessage,
              packageName:
                  customSoundForMessage == null || customSoundForMessage == ""
                      ? UIConstants.packageName
                      : customSoundForMessagePackage);
        }
        CometChatMessageEvents.ccMessageSent(message, MessageStatus.sent);
      },
          onError: onError ??
              (CometChatException e) {
                if (textMessage.metadata != null) {
                  textMessage.metadata!["error"] = e;
                } else {
                  textMessage.metadata = {"error": e};
                }
                CometChatMessageEvents.ccMessageSent(
                    textMessage, MessageStatus.error);
                debugPrint(
                    "Message sending failed with exception:  ${e.message}");
              });
    }
  }

  sendMediaMessage(
      {required String path,
      required String messageType,
      Map<String, dynamic>? metadata}) async {
    String muid = DateTime.now().microsecondsSinceEpoch.toString();

    MediaMessage mediaMessage = MediaMessage(
      receiverType: receiverType,
      type: messageType,
      receiverUid: receiverID,
      file: path,
      metadata: metadata,
      sender: loggedInUser,
      parentMessageId: parentMessageId,
      muid: muid,
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    CometChatMessageEvents.ccMessageSent(
        mediaMessage, MessageStatus.inProgress);

    //for sending files
    MediaMessage mediaMessage2 = MediaMessage(
      receiverType: receiverType,
      type: messageType,
      receiverUid: receiverID,
      //file: Platform.isIOS ? 'file://${pickedFile.path}' : pickedFile.path,

      file: (Platform.isIOS && (!path.startsWith('file://')))
          ? 'file://$path'
          : path,
      metadata: metadata,
      sender: loggedInUser,
      parentMessageId: parentMessageId,
      muid: muid,
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    if (textEditingController != null &&
        textEditingController!.text.isNotEmpty) {
      textEditingController?.clear();
      _previousText = '';
      update();
    }

    await CometChat.sendMediaMessage(mediaMessage2,
        onSuccess: (MediaMessage message) async {
      debugPrint("Media message sent successfully: ${mediaMessage.muid}");

      if (Platform.isIOS) {
        if (message.file != null) {
          message.file = message.file?.replaceAll("file://", '');
        }
      } else {
        message.file = path;
      }

      _playSound();

      CometChatMessageEvents.ccMessageSent(message, MessageStatus.sent);
    },
        onError: onError ??
            (e) {
              if (mediaMessage.metadata != null) {
                mediaMessage.metadata!["error"] = e;
              } else {
                mediaMessage.metadata = {"error": e};
              }
              CometChatMessageEvents.ccMessageSent(
                  mediaMessage, MessageStatus.error);
              debugPrint(
                  "Media message sending failed with exception: ${e.message}");
            });
  }

  editTextMessage() {
    if (textEditingController == null) return;
    if (textEditingController!.text == (oldMessage as TextMessage).text) return;
    TextMessage editedMessage = oldMessage as TextMessage;
    editedMessage.text = textEditingController!.text;
    handlePreMessageSend(editedMessage);
    messagePreviewTitle = '';
    messagePreviewSubtitle = '';
    previewMessageMode = PreviewMessageMode.none;
    textEditingController?.clear();
    _previousText = '';
    update();
    overlayPortalController.hide();
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, editedMessage, PreviewMessageMode.edit);
    } else {
      CometChat.editMessage(editedMessage,
          onSuccess: (BaseMessage updatedMessage) {
        _playSound();

        CometChatMessageEvents.ccMessageEdited(
            updatedMessage, MessageEditStatus.success);
      },
          onError: onError ??
              (CometChatException e) {
                if (editedMessage.metadata != null) {
                  editedMessage.metadata!["error"] = e;
                } else {
                  editedMessage.metadata = {"error": e};
                }
                CometChatMessageEvents.ccMessageSent(
                    editedMessage, MessageStatus.error);

                if (kDebugMode) {
                  debugPrint(
                      "Message editing failed with exception: ${e.message}");
                }
              });
    }
    update();
  }

  sendCustomMessage(Map<String, String> customData, String type) {
    CustomMessage customMessage = CustomMessage(
        receiverUid: receiverID,
        type: type,
        customData: customData,
        receiverType: receiverType,
        sender: loggedInUser,
        parentMessageId: parentMessageId,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        category: CometChatMessageCategory.custom,
        sentAt: DateTime.now(),
    );

    CometChatMessageEvents.ccMessageSent(
        customMessage, MessageStatus.inProgress);

    CometChat.sendCustomMessage(customMessage,
        onSuccess: (CustomMessage message) {
      debugPrint("Custom Message Sent Successfully : $message");

      _playSound();

      CometChatMessageEvents.ccMessageSent(message, MessageStatus.sent);
    },
        onError: onError ??
            (CometChatException e) {
              if (customMessage.metadata != null) {
                customMessage.metadata!["error"] = e;
              } else {
                customMessage.metadata = {"error": e};
              }
              CometChatMessageEvents.ccMessageSent(
                  customMessage, MessageStatus.error);
              debugPrint(
                  "Custom message sending failed with exception: ${e.message}");
            });
  }


  //----------------------------methods used internally----------------------------
  //triggered if developer doesn't pass their onChange handler
  onChange(val) {
    //we are not exposing our internal onChange handler
    //hence allowing a to interact with our controller only through a limited interface
    _onTyping();
  }

  //triggers message preview view of the message composer view
  previewMessage(BaseMessage message, PreviewMessageMode mode) {
    if (mode == PreviewMessageMode.edit) {
      messagePreviewTitle = cc.Translations.of(context).editMessage;
      overlayPortalController.show();
    } else if (mode == PreviewMessageMode.reply) {
      messagePreviewTitle = message.sender?.name;
    }
    if (message is TextMessage) {
      String previewText = message.text;
      if (message.mentionedUsers.isNotEmpty) {
        previewText = CometChatMentionsFormatter.getTextWithMentions(
            message.text, message.mentionedUsers);
      }
      messagePreviewSubtitle = previewText;
    } else {
      messagePreviewSubtitle = CometChatUIKit.getDataSource()
          .getMessageTypeToSubtitle(message.type, context);
    }

    if (mode == PreviewMessageMode.edit && message is TextMessage) {
      textEditingController?.text = message.text;

      _previousText = message.text;

      if (message.mentionedUsers.isNotEmpty) {
        int mentionFormatterIndex = _formatters
            .indexWhere((element) => element.trackingCharacter == '@');
        if (textEditingController != null && mentionFormatterIndex != -1) {
          CometChatMentionsFormatter mentionsFormatter =
              _formatters[mentionFormatterIndex] as CometChatMentionsFormatter;
          mentionsFormatter.onMessageEdit(textEditingController!,
              mentionedUsers: message.mentionedUsers);
        }
      }
    }
    previewMessageMode = mode;
    oldMessage = message;

    update();
  }

  //shows attachment options
  showBottomActionSheet(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
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
        ).merge(
          _actionStyle?.titleTextStyle,
        ),
        backgroundColor:
            _actionStyle?.backgroundColor,
        iconColor: _actionStyle?.iconColor,
        titleColor: _actionStyle?.titleColor,
        borderRadius: _actionStyle?.borderRadius,
        border: _actionStyle?.border,
      ),
    );

    if (item == null) {
      return;
    }
    if (item.onItemClick != null &&
        item.onItemClick is Function(BuildContext, User?, Group?)) {
      try {
        if (context.mounted) {
          item.onItemClick(context, user, group);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("the option could not be executed");
        }
      }
    } else {
      PickedFile? pickedFile;
      String? type;

      if (item.id == MessageTypeConstants.attachPhoto) {
        pickedFile = await MediaPicker.pickImage();
        type = pickedFile?.fileType;
      } else if(item.id == MessageTypeConstants.attachVideo) {
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
      }

      if (pickedFile != null && type != null) {
        if (kDebugMode) {
          debugPrint("File Path is: ${pickedFile.path}");
        }
        Map<String, dynamic> metadata = {};
        metadata["localPath"] = pickedFile.path;
        sendMediaMessage(path: pickedFile.path, messageType: type,metadata: metadata);
      }
    }
  }

  //shows CometChat's emoji keyboard
  useEmojis(BuildContext context) async {
    String? emoji = await showCometChatEmojiKeyboard(
      context: context,
      colorPalette: colorPalette ?? CometChatThemeHelper.getColorPalette(context),
    );
    if (emoji != null) {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
        CometChatUIEvents.hidePanel(
            composerId, CustomUIPosition.composerBottom);
      }
      _addEmojiToText(emoji);
    }
  }

//triggered if developer doesn't pass their onSendButtonClick handler
  onSendButtonClick() {
    if (textEditingController != null &&
        textEditingController!.text.isNotEmpty) {
      if (previewMessageMode == PreviewMessageMode.none) {
        sendTextMessage();
      } else if (previewMessageMode == PreviewMessageMode.edit) {
        editTextMessage();
      } else if (previewMessageMode == PreviewMessageMode.reply) {
        Map<String, dynamic> metadata = {};
        metadata["reply-message"] = oldMessage!.toJson();

        sendTextMessage(metadata: metadata);
      }
    }
  }

  //closes message preview view
  onMessagePreviewClose() {
    overlayPortalController.hide();
    previewMessageMode = PreviewMessageMode.none;
    messagePreviewTitle = "";
    messagePreviewSubtitle = "";
    update();
    debugPrint('close preview requested');
  }

//plays sound on message sent
  _playSound() {
    if (disableSoundForMessages == false) {
      CometChatUIKit.soundManager.play(
          sound: Sound.outgoingMessage,
          customSound: customSoundForMessage,
          packageName:
              customSoundForMessage == null || customSoundForMessage == ""
                  ? UIConstants.packageName
                  : customSoundForMessagePackage);
    }
  }

//inserts emojis to correct position in the text
  _addEmojiToText(String emoji) {
    if (textEditingController == null) return;
    int cursorPosition = textEditingController!.selection.base.offset;
    if (cursorPosition == -1) {
      cursorPosition = textEditingController!.text.length;
    }

    //get the text on the right side of cursor
    String textRightOfCursor =
        textEditingController!.text.substring(cursorPosition);

    //get the text on the left side of cursor
    String textLeftOfCursor =
        textEditingController!.text.substring(0, cursorPosition);

    //insert the emoji in the correct order
    textEditingController!.text = textLeftOfCursor + emoji + textRightOfCursor;

    //move the cursor to the end of the added emoji
    textEditingController?.selection = TextSelection(
      baseOffset: cursorPosition + emoji.length,
      extentOffset: cursorPosition + emoji.length,
    );

    update();
  }

  bool activeAiFeatures = false;
  String aiFeatureEnabled = "";

  bool isForThisWidget(Map<String, dynamic>? id) {
    if (id == null) {
      return true; //if passed id is null , that means for all composer
    }
    if ((id['uid'] != null &&
            id['uid'] ==
                user?.uid) //checking if uid or guid match composer's uid or guid
        ||
        (id['guid'] != null && id['guid'] == group?.guid)) {
      if (id['parentMessageId'] != null &&
          id['parentMessageId'] != parentMessageId) {
        //Checking if parent message id exist then match or not
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerBottom);
    } else if(!focusNode.hasFocus) {
      initializeFooterView();
    }
  }

  void sendMediaRecording(BuildContext context, String path) {
    final metadata = {
      'localPath': path,
    };
    if (onSendButtonTap != null) {
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
      sendMediaMessage(path: path, messageType: MessageTypeConstants.audio,metadata: metadata);
    }
  }

  aiButtonTap(
    BuildContext context,
    id, CometChatAiOptionSheetStyle? aiOptionSheetStyle,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if(activeAiFeatures) {
      Map<String, dynamic> idMap =
      UIEventUtils.createMap(user?.uid,
          group?.guid, 0);
      if(aiFeatureEnabled == AIFeatureConstants.aiSmartReplies){
        idMap[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
      } else if(aiFeatureEnabled == AIFeatureConstants.aiConversationSummary) {
        idMap[AIUtils.extensionKey] = AIFeatureConstants.aiConversationSummary;
      }
        CometChatUIEvents.hidePanel(
            idMap, CustomUIPosition.composerTop);
        return;
    }
    List<CometChatMessageComposerAction> aiFeatureList =
        CometChatUIKit.getDataSource().getAIOptions(
            user, group, context, id, aiOptionStyle);

    if (aiFeatureList.isNotEmpty) {
      List<CometChatMessageComposerAction> actionList = [];

      for (int i = 0; i < aiFeatureList.length; i++) {
        actionList.add(CometChatMessageComposerAction(
            id: aiFeatureList[i].id,
            title: aiFeatureList[i].title,
            icon: aiFeatureList[i].icon,
            style: CometChatAttachmentOptionSheetStyle(
              titleTextStyle: aiFeatureList[i].style?.titleTextStyle,
              backgroundColor: aiFeatureList[i].style?.backgroundColor,
              borderRadius: aiFeatureList[i].style?.borderRadius,
              iconColor: aiFeatureList[i].style?.iconColor,
              border: aiFeatureList[i].style?.border ?? aiOptionStyle?.border,
              titleColor: aiFeatureList[i].style?.titleColor,
            ),
            onItemClick: (BuildContext context, User? user, Group? group) {
              if (aiFeatureList[i].onItemClick != null) {
                aiFeatureList[i].onItemClick!(context, user, group);
              }
            }));
      }

      showCometChatAiOptionSheet(
        context: context,
        user: user,
        group: group,
        actionItems: actionList,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        style: aiOptionSheetStyle,
        aiOptionStyle: aiOptionStyle
      );

      return;
    }
  }

  bool userIsNotBlocked() {
    return user != null &&
        (user?.blockedByMe != true && user?.hasBlockedMe != true);
  }

  @override
  void ccUserBlocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = true;
    }
  }

  @override
  void ccUserUnblocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = false;
    }
  }
}
