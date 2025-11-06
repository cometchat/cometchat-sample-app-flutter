import 'package:cometchat_chat_uikit/src/ai/ai_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatAIConversationStarterView] is a widget that is rendered as the content view for [AIConversationStarterExtension]
///```dart
/// CometChatAiConversationStarterView(
///   user: User(),
///    style: CometChatAIConversationStarterStyle(
///     itemTextStyle: TextStyle(),
///     backgroundColor: Colors.white,
///    ),
///   )
/// ```
class CometChatAIConversationStarterView extends StatefulWidget {
  const CometChatAIConversationStarterView(
      {super.key,
      this.user,
      this.group,
      this.style,
      this.customView,
      this.apiConfiguration});

  /// set [User] object, one is mandatory either [user] or [group]
  final User? user;

  ///set [Group] object, one is mandatory either [user] or [group]
  final Group? group;

  ///[style] provides styling to the reply chips/bubbles
  final CometChatAIConversationStarterStyle? style;

  ///[customView] gives conversation starter view
  final Widget Function(List<String> replies, BuildContext context)? customView;

  ///[apiConfiguration] sets the api call configuration for ai conversation starter
  final Map<String, dynamic>? apiConfiguration;

  @override
  State<CometChatAIConversationStarterView> createState() =>
      _CometChatAIConversationStarterViewState();
}

class _CometChatAIConversationStarterViewState
    extends State<CometChatAIConversationStarterView>{
  List<String> _replies = [];

  bool isLoading = false;

  bool isError = false;


  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatAIConversationStarterStyle style;

  @override
  void initState() {
    getReply();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    style = CometChatThemeHelper.getTheme<CometChatAIConversationStarterStyle>(
            context: context,
            defaultTheme: CometChatAIConversationStarterStyle.of)
        .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  getReply() async {
    await getReplies();
  }

  Future<void> getReplies() async {
    setState(() {
      isLoading = true;
    });
    _replies.clear();
    String receiverId = "";
    String receiverType = "";
    if (widget.user != null) {
      receiverId = widget.user!.uid;
      receiverType = CometChatReceiverType.user;
    } else if (widget.group != null) {
      receiverId = widget.group!.guid;
      receiverType = CometChatReceiverType.group;
    }
    await CometChat.getConversationStarter(receiverId, receiverType,
        configuration: widget.apiConfiguration, onSuccess: (reply) {
      _replies = reply;
      setState(() {});
    }, onError: (error) {
      if (kDebugMode) {
        debugPrint("Error in AI conversation starter : ${error.details}");
      }
      isError = true;
      setState(() {});
    });
    isLoading = false;
    setState(() {});
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
    CometChatUIEvents.hidePanel(id, CustomUIPosition.composerTop);

    CometChatUIEvents.ccComposeMessage(reply, MessageEditStatus.inProgress);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.customView != null)
        ? widget.customView!(_replies, context)
        : Padding(
            padding: EdgeInsets.symmetric(
                horizontal: spacing.padding2 ?? 0,
                vertical: spacing.padding1 ?? 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    itemCount: _replies.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, int item) {
                      return GestureDetector(
                        onTap: () {
                          onClickReply(_replies[item]);
                        },
                        child:  Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: spacing.padding5 ?? 0,
                                vertical: spacing.padding2 ?? 0),
                            decoration: BoxDecoration(
                              color: style.backgroundColor ??
                                  colorPalette.background1,
                              border: style.border ??
                                  Border.all(
                                      color: colorPalette.borderLight ??
                                          Colors.transparent,
                                      width: 1),
                              borderRadius: style.borderRadius ??
                                  BorderRadius.all(
                                    Radius.circular(
                                      spacing.radiusMax ?? 0,
                                    ),
                                  ),
                            ),
                            child: Text(
                              _replies[item],
                              style: style.itemTextStyle ??
                                  TextStyle(
                                    fontSize: typography.body?.regular?.fontSize,
                                    fontWeight:
                                        typography.body?.regular?.fontWeight,
                                    color: colorPalette.textPrimary,
                                  ),
                            ),
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
          );
  }
}
