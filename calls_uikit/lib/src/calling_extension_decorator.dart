import 'package:cometchat_calls_uikit/src/incoming_call/cometchat_display_incoming_call_overlay.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:intl/intl.dart';

///[CallingExtensionDecorator] is a the view model for [CometChatCallingExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class CallingExtensionDecorator extends DataSourceDecorator
    with CallListener, CometChatCallEventListener {
  ///[callingTypeConstant] is a constant used to identify the extension
  String callingTypeConstant = 'calling';

  ///[configuration] is a [CallingConfiguration] object which contains all the configuration required for the extension
  CallingConfiguration? configuration;

  ///[_loggedInUser] is a [User] object which contains the details of the logged in user
  User? _loggedInUser;

  BaseMessage? activeCall;

  final String _listenerId = "CallingExtensionDecorator";

  ///[CallingExtensionDecorator] constructor requires [DataSource] and [CallingConfiguration] as a parameter
  CallingExtensionDecorator(DataSource dataSource, {this.configuration})
      : super(dataSource) {
    //[_initializeDependencies] method is called to initialize all the dependencies required for the extension
    _initializeDependencies();
    // [addListeners] method is called to add listeners for the extension
    addListeners();
  }

  ///[_initializeDependencies] method is used to initialize all the dependencies required for the extension
  _initializeDependencies() async {
    //[_loggedInUser] is initialized with the logged in user
    _loggedInUser = await CometChatUIKit.getLoggedInUser();
    UIKitSettings? authenticationSettings =
        CometChatUIKit.authenticationSettings;
    //we are initializing the calling sdk with the appId and region if authenticationSettings are not null
    if (authenticationSettings != null &&
        authenticationSettings.appId != null &&
        authenticationSettings.region != null) {
      CometChatUIKitCalls.init(
          authenticationSettings.appId!, authenticationSettings.region!);
    }
  }

  ///[addListeners] method is used to register the call listeners
  void addListeners() {
    CometChat.addCallListener(_listenerId, this);
    CometChatCallEvents.addCallEventsListener(_listenerId, this);
  }

  ///[getId] method is used to get the string identifier for the extension
  @override
  String getId() {
    return callingTypeConstant;
  }

  ///[getAllMessageTypes] method is used to get all the message types present in [MessagesDataSource]
  @override
  List<String> getAllMessageTypes() {
    List<String> messageTypes = super.getAllMessageTypes();
    if (!messageTypes.contains(MessageTypeConstants.audio)) {
      messageTypes.add(MessageTypeConstants.audio);
    }
    if (!messageTypes.contains(MessageTypeConstants.video)) {
      messageTypes.add(MessageTypeConstants.video);
    }
    if (!messageTypes.contains(MessageTypeConstants.meeting)) {
      messageTypes.add(MessageTypeConstants.meeting);
    }
    return messageTypes;
  }

  ///[getAllMessageCategories] method is used to get all the message categories present in [MessagesDataSource]
  @override
  List<String> getAllMessageCategories() {
    List<String> categories = super.getAllMessageCategories();
    if (!categories.contains(MessageCategoryConstants.call)) {
      categories.add(MessageCategoryConstants.call);
    }
    if (!categories.contains(MessageCategoryConstants.custom)) {
      categories.add(MessageCategoryConstants.custom);
    }
    return categories;
  }

  ///[getAllMessageTemplates] method is used to get all the message templates present in [MessagesDataSource]
  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    List<CometChatMessageTemplate> templates = super.getAllMessageTemplates();
    templates.add(getGroupCallTemplate());
    templates.add(getDefaultVoiceCallTemplate());
    templates.add(getDefaultVideoCallTemplate());
    return templates;
  }

  ///[getMeetWorkflowTemplate] method is used to get the template for conference call
  CometChatMessageTemplate getGroupCallTemplate() {
    return CometChatMessageTemplate(
      type: MessageTypeConstants.meeting,
      category: MessageCategoryConstants.custom,
      options: ChatConfigurator.getDataSource().getCommonOptions,
      bottomView: ChatConfigurator.getDataSource().getBottomView,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        //checking if the message is deleted or not
        if (message.deletedAt != null || message is! CustomMessage) {
          return super.getDeleteMessageBubble(
              message, context, additionalConfigurations?.deletedBubbleStyle);
        }
        //if the message is not deleted then we will return the template for conference call
        return getCallBubble(message, context, alignment,
            additionalConfigurations: additionalConfigurations);
      },
    );
  }

  ///[getMeetWorkflowTemplate] method is used to get the template for conference call
  Widget getCallBubble(
      CustomMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    String? callType;
    if (message.customData != null &&
        message.customData?.containsKey('callType') == true) {
      callType = message.customData?['callType'];
    }
    String title;
    String icon;
    CometChatCallBubbleStyle? style;

    if (callType == CallTypeConstants.videoCall) {
      title = Translations.of(context).videoCall;
      style = additionalConfigurations?.videoCallBubbleStyle;
      icon = message.sender?.uid == _loggedInUser?.uid
          ? AssetConstants.videoOutgoing
          : AssetConstants.videoIncoming;
    } else {
      title = Translations.of(context).voiceCall;
      style = additionalConfigurations?.voiceCallBubbleStyle;
      icon = message.sender?.uid == _loggedInUser?.uid
          ? AssetConstants.voiceOutgoing
          : AssetConstants.voiceIncoming;
    }

    String receiver = message.receiverUid;
    String? subtitle;
    if (message.sentAt != null) {
      subtitle = DateFormat('d MMM, hh:mm a').format(message.sentAt!);
    }
    return CometChatCallBubble(
      title: title,
      iconUrl: icon,
      subtitle: subtitle,
      onTap: (context) => initiateDirectCall(context, receiver, message,
          call: Call(
              receiverUid: receiver,
              receiverType: CometChatReceiverType.group,
              category: MessageCategoryConstants.call,
              type: MessageTypeConstants.meeting)),
      style: style,
      alignment: alignment,
    );
  }

  ///[initiateDirectCall] will initiate a direct call
  void initiateDirectCall(
      BuildContext context, String sessionID, CustomMessage message,
      {Call? call}) async {
    CallSettingsBuilder defaultCallSettingsBuilder;
    if (configuration != null &&
        configuration?.groupCallSettingsBuilder != null) {
      defaultCallSettingsBuilder = configuration!.groupCallSettingsBuilder!;
    } else {
      defaultCallSettingsBuilder =
          (CallSettingsBuilder()..enableDefaultLayout = true);
    }
    String? callType;
    String? sessionId;
    if (message.customData != null &&
        message.customData?.containsKey('callType') == true) {
      callType = message.customData?['callType'];
    }
    if (message.customData != null &&
        message.customData?.containsKey('sessionID') == true) {
      sessionId = message.customData?['sessionID'];
    }
    if (callType == CallTypeConstants.audioCall) {
      defaultCallSettingsBuilder.setAudioOnlyCall = true;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CometChatOngoingCall(
            callSettingsBuilder: defaultCallSettingsBuilder,
            sessionId: sessionId ?? sessionID,
            callWorkFlow: CallWorkFlow.directCalling,
          ),
        ));
  }

  ///[getDefaultVoiceCallTemplate] method is used to get the template for default voice calling
  CometChatMessageTemplate getDefaultVoiceCallTemplate() {
    return CometChatMessageTemplate(
      type: CallTypeConstants.audioCall,
      category: MessageCategoryConstants.call,
      footerView: null,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message is Call) {
          final CometChatColorPalette colorPalette =
              CometChatThemeHelper.getColorPalette(context);
          final typography = CometChatThemeHelper.getTypography(context);
          return CometChatActionBubble(
            text: CallUtils.getCallStatus(context, message, _loggedInUser),
            leadingIcon: Image.asset(
              CallUtils.getCallIconByStatus(
                  context, message, _loggedInUser, true),
              package: UIConstants.packageName,
              color: CallUtils.getCallTextColor(
                  context, message, _loggedInUser, colorPalette),
              height: 20,
              width: 20,
            ),
            style: CometChatActionBubbleStyle(
              textStyle: TextStyle(
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                  color: CallUtils.getCallTextColor(
                      context, message, _loggedInUser, colorPalette),
                  letterSpacing: 0),
            ).merge(additionalConfigurations?.actionBubbleStyle),
          );
        } else {
          return null;
        }
      },
    );
  }

  ///[getDefaultVideoCallTemplate] method is used to get the template for default video calling
  CometChatMessageTemplate getDefaultVideoCallTemplate() {
    return CometChatMessageTemplate(
      type: CallTypeConstants.videoCall,
      category: MessageCategoryConstants.call,
      contentView:
          (BaseMessage message, BuildContext context, BubbleAlignment alignment,
              {AdditionalConfigurations? additionalConfigurations}) {
        if (message is Call) {
          final CometChatColorPalette colorPalette =
              CometChatThemeHelper.getColorPalette(context);
          final typography = CometChatThemeHelper.getTypography(context);

          return CometChatActionBubble(
            text: CallUtils.getCallStatus(context, message, _loggedInUser),
            leadingIcon: Image.asset(
              CallUtils.getCallIconByStatus(
                  context, message, _loggedInUser, false),
              package: UIConstants.packageName,
              color: CallUtils.getCallIconColor(
                  context, message, _loggedInUser, colorPalette),
              height: 24,
              width: 24,
            ),
            style: CometChatActionBubbleStyle(
              textStyle: TextStyle(
                fontSize: typography.caption1?.regular?.fontSize,
                fontWeight: typography.caption1?.regular?.fontWeight,
                color: CallUtils.getCallTextColor(
                    context, message, _loggedInUser, colorPalette),
              ),
            ).merge(additionalConfigurations?.actionBubbleStyle),
          );
        } else {
          return null;
        }
      },
    );
  }

  ///[getLastConversationMessage] method is used to set an appropriate subtitle in the [CometChatListItem]
  ///displayed in [CometChatConversations] the last message of conversation
  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    BaseMessage? lastMessage = conversation.lastMessage;
    if (lastMessage != null) {
      String? message;

      // Check if the last message category is a call
      if (lastMessage.category == MessageCategoryConstants.call) {
        if (lastMessage is Call) {
          bool isVideoCall = CallUtils.isVideoCall(lastMessage);

          // Switch on callStatus to handle different cases
          switch (lastMessage.callStatus) {
            case CallStatusConstants.unanswered:
            case CallStatusConstants.cancelled:
              // Missed or Cancelled calls
              message = isVideoCall ? "Missed Video Call" : "Missed Voice Call";
              break;

            default:
              // Handle outgoing or incoming calls
              if (CallUtils.isCallInitiatedByMe(lastMessage)) {
                message =
                    isVideoCall ? "Outgoing Video Call" : "Outgoing Voice Call";
              } else {
                message =
                    isVideoCall ? "Incoming Video Call" : "Incoming Voice Call";
              }
          }

          return message;
        }
      }
      // Handle custom category for meetings
      else if (lastMessage.category == MessageCategoryConstants.custom &&
          lastMessage.type == MessageTypeConstants.meeting) {
        message = CallUtils.getLastMessageForGroupCall(
            lastMessage, context, _loggedInUser);
        return message;
      }
    }

    // If no specific case matches, fall back to the default message
    return super.getLastConversationMessage(conversation, context);
  }

  ///[getLastConversationWidget] method is used to set an appropriate subtitle in the [CometChatListItem]
  ///displayed in [CometChatConversations] the last message of conversation
  @override
  Widget getLastConversationWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    BaseMessage? lastMessage = conversation.lastMessage;
    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    if (lastMessage != null) {
      Widget? callIcon;

      // Check if the last message category is a call
      if (lastMessage.category == MessageCategoryConstants.call) {
        if (lastMessage is Call) {
          // Determine if it's a video or voice call
          bool isVideoCall = CallUtils.isVideoCall(lastMessage);

          // Use switch to handle different call statuses
          switch (lastMessage.callStatus) {
            case CallStatusConstants.unanswered:
            case CallStatusConstants.cancelled:
              // Missed or Cancelled calls
              // callIcon = isVideoCall
              //     ? const Icon(Icons.videocam_off, color: Colors.red)
              //     : const Icon(Icons.phone_missed, color: Colors.red); // TODO
              break;

            default:
              // Handle outgoing or incoming calls
              if (CallUtils.isCallInitiatedByMe(lastMessage)) {
                callIcon = isVideoCall
                    ? Image.asset(
                        AssetConstants.videoIncoming,
                        package: UIConstants.packageName,
                        color: iconColor ?? colorPalette.iconSecondary,
                        height: 16,
                        width: 16,
                      )
                    : Image.asset(
                        AssetConstants.voiceIncoming,
                        package: UIConstants.packageName,
                        color: iconColor ?? colorPalette.iconSecondary,
                        height: 16,
                        width: 16,
                      );
              } else {
                callIcon = isVideoCall
                    ? Image.asset(
                        AssetConstants.videoOutgoing,
                        package: UIConstants.packageName,
                        color: iconColor ?? colorPalette.iconSecondary,
                        height: 16,
                        width: 16,
                      )
                    : Image.asset(
                        AssetConstants.voiceOutgoing,
                        package: UIConstants.packageName,
                        color: iconColor ?? colorPalette.iconSecondary,
                        height: 16,
                        width: 16,
                      );
              }
          }

          return callIcon ?? const SizedBox();
        }
      }
      // Handle custom category for meetings
      else if (lastMessage.category == MessageCategoryConstants.custom &&
          lastMessage.type == MessageTypeConstants.meeting) {
        return callIcon ?? const SizedBox();
      }
    }

    // If no specific case matches, fall back to the default widget
    return super.getLastConversationWidget(conversation, context, iconColor);
  }

  ///[getAuxiliaryHeaderMenu] method is used to set a custom header menu to be displayed in [CometChatMessageHeader]
  @override
  Widget? getAuxiliaryHeaderMenu(BuildContext context, User? user, Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    //retrieve the contents of the header menu from the data source.
    Widget? currentHeaderMenu = dataSource.getAuxiliaryHeaderMenu(
        context, user, group,
        additionalConfigurations: additionalConfigurations);

    //initializing an empty list of widgets.
    List<Widget> menuItems = [];

    //adding the call buttons to the list of widgets to be displayed in the header menu.
    menuItems.add(CometChatCallButtons(
      user: user,
      group: group,
      callButtonsStyle:
          (configuration?.callButtonsConfiguration?.callButtonsStyle ??
                  const CometChatCallButtonsStyle())
              .merge(additionalConfigurations?.callButtonsStyle),
      onError: configuration?.callButtonsConfiguration?.onError,
      hideVoiceCallButton: additionalConfigurations?.hideVoiceCallButton ??
          configuration?.callButtonsConfiguration?.hideVoiceCallButton,
      hideVideoCallButton: additionalConfigurations?.hideVideoCallButton ??
          configuration?.callButtonsConfiguration?.hideVideoCallButton,
      voiceCallIcon: configuration?.callButtonsConfiguration?.voiceCallIcon,
      videoCallIcon: configuration?.callButtonsConfiguration?.videoCallIcon,
      outgoingCallConfiguration:
          configuration?.callButtonsConfiguration?.outgoingCallConfiguration ??
              configuration?.outgoingCallConfiguration,
      callSettingsBuilder:
          configuration?.callButtonsConfiguration?.callSettingsBuilder,
    ));

    //adding the initial header menu contents to the list of widgets to be displayed in the header menu.
    if (currentHeaderMenu != null) {
      menuItems.add(currentHeaderMenu);
    }

    //returning the list of widgets to be displayed in the header menu.
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: menuItems,
    );
  }

  //------------ sdk call events --------------------
  ///[onIncomingCallReceived] method is used to handle incoming call events.
  @override
  void onIncomingCallReceived(Call call) {
    User? user;
    if (call.callInitiator is User) {
      user = call.callInitiator as User;
    }

    if(user != null && user.uid == _loggedInUser?.uid){
      return;
    }

    if (CallNavigationContext.navigatorKey.currentContext != null) {
      IncomingCallOverlay.show(
        context: CallNavigationContext.navigatorKey.currentContext!,
        call: call,
        user: user,
        onError: configuration?.incomingCallConfiguration?.onError,
        disableSoundForCalls:
            configuration?.incomingCallConfiguration?.disableSoundForCalls,
        customSoundForCalls:
            configuration?.incomingCallConfiguration?.customSoundForCalls,
        customSoundForCallsPackage: configuration
            ?.incomingCallConfiguration?.customSoundForCallsPackage,
        onAccept: configuration?.incomingCallConfiguration?.onAccept,
        onDecline: configuration?.incomingCallConfiguration?.onDecline,
        style: configuration?.incomingCallConfiguration?.incomingCallStyle,
        callSettingsBuilder:
            configuration?.incomingCallConfiguration?.callSettingsBuilder,
        height: configuration?.incomingCallConfiguration?.height,
        width: configuration?.incomingCallConfiguration?.width,
        declineButtonText:
            configuration?.incomingCallConfiguration?.declineButtonText,
        acceptButtonText:
            configuration?.incomingCallConfiguration?.acceptButtonText,
        titleView: configuration?.incomingCallConfiguration?.titleView,
        leadingView: configuration?.incomingCallConfiguration?.leadingView,
        trailingView: configuration?.incomingCallConfiguration?.trailingView,
        subtitleView: configuration?.incomingCallConfiguration?.subTitleView,
        itemView: configuration?.incomingCallConfiguration?.itemView,
      );
    }
  }

  @override
  void onOutgoingCallAccepted(Call call) {
    activeCall = call;
  }

  @override
  void onIncomingCallCancelled(Call call) {
    if (activeCall != null && activeCall?.id == call.id) {
      activeCall = null;
    }
  }

  //----------- UI Kit call events---------
  @override
  void ccOutgoingCall(Call call) {
    activeCall = call;
  }

  @override
  void ccCallRejected(Call call) {
    if (activeCall != null && activeCall?.id == call.id) {
      activeCall = null;
    }
  }

  @override
  void ccCallEnded(Call call) {
    if (activeCall != null && activeCall?.id == call.id) {
      activeCall = null;
    }
  }
}
