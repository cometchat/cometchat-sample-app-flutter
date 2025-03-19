import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';


///[CometChatAIConversationSummaryView] is a widget that is rendered as the content view for [CometChatAIConversationSummaryView]
///```dart
/// CometChatAIConversationSummaryView(
///   style: AiConversationStarterStyle(),
///   user: User(),
///   emptyStateText: Text("Error occurred"),
///   loadingStateView: Text("Loading..."),
///   theme: CometChatTheme(),
///   )
/// ```

class CometChatAIConversationSummaryView extends StatefulWidget {
  const CometChatAIConversationSummaryView(
      {super.key,
      this.user,
      this.group,
      this.aiConversationSummaryStyle,
      this.title,
      this.customView,
      this.errorIconUrl,
      this.loadingStateText,
      this.loadingIconUrl,
      this.loadingStateView,
      this.errorStateView,
      this.emptyStateView,
      this.emptyIconUrl,
      this.onCloseIconTap,
      this.emptyStateText,
      this.errorStateText,
      this.errorIconPackageName,
      this.emptyIconPackageName,
      this.loadingIconPackageName,
      this.apiConfiguration});

  /// set [User] object, one is mandatory either [user] or [group]
  final User? user;

  ///set [Group] object, one is mandatory either [user] or [group]
  final Group? group;

  final String? title;

  ///[aiConversationSummaryStyle] provides styling to the reply chips/bubbles
  final CometChatAIConversationSummaryStyle? aiConversationSummaryStyle;

  ///[loadingStateText] text to be displayed when loading occur
  final String? loadingStateText;

  ///[customView] gives conversation starter view
  final Widget Function(String summary, BuildContext context)? customView;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[loadingStateView] returns view for loading state
  final WidgetBuilder? loadingStateView;

  ///[errorStateView] returns view for error state
  final WidgetBuilder? errorStateView;

  ///[errorIconUrl] used to set the error icon
  final String? errorIconUrl;

  ///[emptyIconUrl] used to set the empty icon
  final String? emptyIconUrl;

  ///[loadingIconUrl] used to set the loading icon
  final String? loadingIconUrl;

  ///[onCloseIconTap] used to set the loading icon
  final Function(Map<String, dynamic> id)? onCloseIconTap;

  ///[configuration] used to set the error state text
  final String? errorStateText;

  ///[loadingStateText] used to set the empty state text
  final String? emptyStateText;

  ///[errorIconPackageName] used to set the error icon package name
  final String? errorIconPackageName;

  ///[loadingIconPackageName] used to set the loading icon package name
  final String? loadingIconPackageName;

  ///[emptyIconPackageName] used to set the empty icon package name
  final String? emptyIconPackageName;

  ///[apiConfiguration] sets the api configuration for ai summary view
  final Map<String, dynamic>? apiConfiguration;

  @override
  State<CometChatAIConversationSummaryView> createState() =>
      _CometChatAIConversationSummaryViewState();
}

class _CometChatAIConversationSummaryViewState extends State<CometChatAIConversationSummaryView>
    with WidgetsBindingObserver {
  String _summary = "";

  bool isLoading = false;

  bool isError = false;

  bool isKeyboardOpen = false;


  // late DecoratedContainerStyle defaultContainerStyle;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatAIConversationSummaryStyle style;


  @override
  void initState() {
    getSummary();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final value = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    if (value > 0 != isKeyboardOpen) {
      setState(() {
        isKeyboardOpen = !isKeyboardOpen;
      });
    }
  }

  @override
  void didChangeDependencies() {
    style =
        CometChatThemeHelper.getTheme<CometChatAIConversationSummaryStyle>(
            context: context, defaultTheme: CometChatAIConversationSummaryStyle.of)
            .merge(widget.aiConversationSummaryStyle);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);

    super.didChangeDependencies();
  }


  getSummary() async {
    await getSummaryFromSDK();
  }

  Future<void> getSummaryFromSDK() async {
    setState(() {
      isLoading = true;
    });
    _summary = "";
    String receiverId = "";
    String receiverType = "";
    if (widget.user != null) {
      receiverId = widget.user!.uid;
      receiverType = CometChatReceiverType.user;
    } else if (widget.group != null) {
      receiverId = widget.group!.guid;
      receiverType = CometChatReceiverType.group;
    }
    await CometChat.getConversationSummary(receiverId, receiverType,
        configuration: widget.apiConfiguration, onSuccess: (summary2) {
      _summary = summary2;
      setState(() {});
    }, onError: (error) {
      if (kDebugMode) {
        debugPrint("Error in AI conversation Summary : ${error.details}");
      }
      isError = true;
      setState(() {});
    });
    isLoading = false;
    setState(() {});
  }

  Widget _getOnError(BuildContext context) {
    if (widget.errorStateView != null) {
      return Center(
        child: widget.errorStateView!(context),
      );
    } else {
      return AIUtils.getErrorText(context,
          colorPalette,typography,spacing,
          errorStateText: widget.errorStateText,
          errorTextStyle: style.errorTextStyle,);
    }
  }

  Widget _getEmptyView(BuildContext context) {
    if (widget.emptyStateView != null) {
      return widget.emptyStateView!(context);
    } else {
      return AIUtils.getEmptyView(context,
          backgroundColor: style.backgroundColor,
          shadowColor: style.shadowColor,
          emptyIconUrl: widget.emptyIconUrl,
          emptyIconTint: style.emptyIconTint,
          emptyStateText: widget.emptyStateText,
          emptyTextStyle: style.emptyTextStyle,
          emptyIconPackageName: widget.emptyIconPackageName);
    }
  }

  onClickClosButton(String reply) async {
    Map<String, dynamic> id = {};
    String receiverId = "";
    if (widget.user != null) {
      receiverId = widget.user!.uid;
    } else if (widget.group != null) {
      receiverId = widget.group!.guid;
    }
    id['uid'] = receiverId;
    id['guid'] = receiverId;
    id[AIUtils.extensionKey] = AIFeatureConstants.aiConversationSummary;
    CometChatUIEvents.hidePanel(id, CustomUIPosition.composerTop);

    CometChatUIEvents.ccComposeMessage(reply, MessageEditStatus.inProgress);
  }

  Widget _getLoadingIndicator(
      BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
    } else {
      return CometChatShimmerEffect(
        colorPalette: colorPalette,
        child: ListView.builder(
          itemCount: 6,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.padding5 ?? 0,
                vertical: spacing.padding2 ?? 0,
              ),
              margin: EdgeInsets.only(
                bottom: spacing.margin2 ?? 0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(
                  spacing.radiusMax ?? 0,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!isKeyboardOpen)
        ? CometChatDecoratedContainer(
                          title:
                              Translations.of(context).conversationSummary,
                          content: isLoading
                              ? _getLoadingIndicator(context, colorPalette, typography, spacing)
                              : isError
                              ? _getOnError(context)
                              : (widget.customView != null)
                              ? widget.customView!(_summary, context)
                              : Padding(
                            padding: EdgeInsets.symmetric(vertical: spacing.padding1 ?? 0),
                                child: Text(
                                                            _summary,
                                                            style: TextStyle(
                                    color: colorPalette.textPrimary,
                                    fontSize: typography.body?.regular?.fontSize,
                                    fontWeight: typography.body?.regular?.fontWeight,).merge(style.summaryTextStyle),
                                                          ),
                              ),
                          style: DecoratedContainerStyle(
                            backgroundColor: style.backgroundColor,
                            borderRadius: style.borderRadius,
                            border: style.border,
                            titleStyle: style.titleStyle,
                            closeIconColor: style.closeIconColor,
                          ),
                          colorPalette: colorPalette,
                          typography: typography,
                          spacing: spacing,
        padding: EdgeInsets.symmetric(horizontal: spacing.padding4 ?? 0, vertical: spacing.padding3 ?? 0),
                          onCloseIconTap: () {
                            Map<String, dynamic> idMap =
                                UIEventUtils.createMap(widget.user?.uid,
                                    widget.group?.guid, 0);
                            if (widget.onCloseIconTap != null) {
                              widget.onCloseIconTap!(idMap);
                            } else {
                              idMap[AIUtils.extensionKey] = AIFeatureConstants.aiConversationSummary;
                              CometChatUIEvents.hidePanel(
                                  idMap, CustomUIPosition.composerTop);
                            }
                          },
                        )
        : const SizedBox();
  }
}
