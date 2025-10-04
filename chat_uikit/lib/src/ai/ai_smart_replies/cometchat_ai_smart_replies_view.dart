import 'package:cometchat_chat_uikit/src/ai/ai_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;

///[CometChatAISmartRepliesView] is a widget that is rendered as the content view for [AISmartRepliesExtension]
///
///```dart
/// CometChatAiSmartReplyView(
///   style: AiSmartReplyStyle(
///     replyTextStyle: TextStyle(
///       color: Colors.black,
///       fontWeight: FontWeight.bold,
///       fontSize: 14,
///     ),
///   ),
///   theme: CometChatTheme(),
/// );
/// ```
///

class CometChatAISmartRepliesView extends StatefulWidget {
  const CometChatAISmartRepliesView(
      {super.key,
        this.user,
        this.group,
        this.style,
        this.theme,
        this.onError,
        this.emptyStateText,
        this.errorStateText,
        this.customView,
        this.loadingStateText,
        this.loadingIconUrl,
        this.loadingStateView,
        this.errorIconUrl,
        this.errorStateView,
        this.emptyStateView,
        this.emptyIconUrl,
        this.loadingIconPackageName,
        this.emptyIconPackageName,
        this.errorIconPackageName,
        this.apiConfiguration,
        this.onCloseIconTap,
      });

  ///[style] provides styling to the reply view
  final CometChatAISmartRepliesStyle? style;

  ///[theme] sets custom theme
  final CometChatTheme? theme;

  ///[user] user object to show replies
  final User? user;

  ///[group] group object to show replies
  final Group? group;

  ///[emptyStateText] text to be displayed when the replies are empty
  final String? emptyStateText;

  ///[errorStateText] text to be displayed when we get an error
  final String? errorStateText;

  ///[onError] callback triggered in case any error happens when fetching replies
  final OnError? onError;

  ///[customView] gives smartReply view
  final Widget Function(List<String> replies, BuildContext context)? customView;

  ///[loadingStateText] text to be displayed when loading occur
  final String? loadingStateText;

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

  ///[loadingIconPackageName] package name for loading icon to be displayed when loading state
  final String? loadingIconPackageName;

  ///[errorIconPackageName] package name for error icon to be displayed when error occur
  final String? errorIconPackageName;

  ///[emptyIconPackageName] package name for empty icon to be displayed when empty state
  final String? emptyIconPackageName;

  ///[apiConfiguration] sets the api configuration for smart replies
  final Map<String, dynamic>? apiConfiguration;

  ///[onCloseIconTap] used to set the loading icon
  final Function(Map<String, dynamic> id)? onCloseIconTap;


  @override
  State<CometChatAISmartRepliesView> createState() => _CometChatAISmartRepliesViewState();
}

class _CometChatAISmartRepliesViewState extends State<CometChatAISmartRepliesView> {
  List<String> _replies = [];

  bool isLoading = false;

  bool isError = false;

  late CometChatTheme _theme;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatAISmartRepliesStyle style;


  @override
  void initState() {
    getReply();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    style =
        CometChatThemeHelper.getTheme<CometChatAISmartRepliesStyle>(
            context: context, defaultTheme: CometChatAISmartRepliesStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }


  getReply() async {
    _theme = widget.theme ?? cometChatTheme;
    _replies = await getReplies();
  }

  Future<List<String>> getReplies() async {
    setState(() {
      isLoading = true;
    });
    String receiverId = "";
    String receiverType = "";
    if (widget.user != null) {
      receiverId = widget.user!.uid;
      receiverType = CometChatReceiverType.user;
    } else if (widget.group != null) {
      receiverId = widget.group!.guid;
      receiverType = CometChatReceiverType.group;
    }
    Map<String, String> smartReplies = {};
    List<String> aiReplies = [];
    await CometChat.getSmartReplies(receiverId, receiverType,
        configuration: widget.apiConfiguration, onSuccess: (reply) {
          smartReplies = reply;
          if (smartReplies.containsKey("negative")) {
            aiReplies.add(smartReplies["negative"] ?? "");
          }
          if (smartReplies.containsKey("positive")) {
            aiReplies.add(smartReplies["positive"] ?? "");
          }
          if (smartReplies.containsKey("neutral")) {
            aiReplies.add(smartReplies["neutral"] ?? "");
          }
        }, onError: (error) {
          if (kDebugMode) {
            debugPrint("Error in AI smart replies : ${error.message}");
          }
          setState(() {
            isError = true;
          });
        });
    setState(() {
      isLoading = false;
    });
    return aiReplies;
  }

  Widget _getOnError(BuildContext context,) {
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
      return Center(child: widget.emptyStateView!(context));
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            widget.emptyIconUrl ?? AssetConstants.repliesEmpty,
            package: widget.emptyIconPackageName ?? UIConstants.packageName,
            color: style.emptyIconTint ?? _theme.palette.getAccent700(),
          ),
          Center(
            child: Text(
              widget.emptyStateText ?? cc.Translations.of(context).noMessagesFound,
              style: style.emptyTextStyle ??
                  TextStyle(
                    fontSize: _theme.typography.title1.fontSize,
                    fontWeight: _theme.typography.title1.fontWeight,
                    color: _theme.palette.getAccent400(),
                  ),
            ),
          ),
        ],
      );
    }
  }

  onClickReply(String reply) async {
    Map<String, dynamic> id = {};
    String receiverId = "";
    if (widget.user != null) {
      receiverId = widget.user!.uid;
    } else if (widget.group != null) {
      receiverId = widget.group!.guid;
    }
    id['uid'] = receiverId;
    id['guid'] = receiverId;
    id[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
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
          itemCount: 3,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              height: 51,
              padding: EdgeInsets.symmetric(
                horizontal: spacing.padding3 ?? 0,
                vertical: spacing.padding2 ?? 0,
              ),
              margin: EdgeInsets.only(
                bottom: spacing.margin2 ?? 0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(
                  spacing.radius2 ?? 0,
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
    return CometChatDecoratedContainer(
      title:
      cc.Translations.of(context).suggestAReply.toLowerCase().capitalizeFirst,
      onCloseIconTap: () {
        Map<String, dynamic> idMap =
        UIEventUtils.createMap(widget.user?.uid,
            widget.group?.guid, 0);
        if (widget.onCloseIconTap != null) {
          widget.onCloseIconTap!(idMap);
        } else {
          idMap[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
          CometChatUIEvents.hidePanel(
              idMap, CustomUIPosition.composerTop);
        }
      },
      colorPalette: colorPalette,
      spacing: spacing,
      typography: typography,
      padding:EdgeInsets.all(spacing.padding3 ?? 0),
      style: DecoratedContainerStyle(
          borderRadius: style.borderRadius ?? BorderRadius.circular(spacing.radius4 ?? 0),
        border: style.border,
        backgroundColor: style.backgroundColor,
        titleStyle: style.titleStyle,
        closeIconColor: style.closeIconColor,
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(
          maxHeight: 217,
        ),
        child: isLoading
            ? _getLoadingIndicator(context, colorPalette, typography, spacing)
            : isError
            ? _getOnError(context)
            : (widget.customView != null)
            ? widget.customView!(_replies, context)
            : SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.separated(
                itemCount: _replies.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (_, int item) {
                  return GestureDetector(
                    onTap: () {
                      onClickReply(_replies[item]);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: spacing.padding2??0,horizontal: spacing.padding3??0),
                      decoration: BoxDecoration(
                        border:style.itemBorder ?? Border.all(
                          color: colorPalette.borderLight ?? Colors.transparent,
                          width: 1
                        ),
                        borderRadius:style.itemBorderRadius ?? BorderRadius.circular(spacing.radius2??0),
                        color: style.itemBackgroundColor
                      ),
                      child: Text(
                        _replies[item],
                        style: TextStyle(
                              fontSize:
                                  typography.body?.regular?.fontSize,
                              fontWeight: typography.body?.regular?.fontWeight,
                              color: colorPalette.textPrimary,
                            ).merge(style.itemTextStyle),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, int i) {
                  return const SizedBox(
                    height: 8,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}