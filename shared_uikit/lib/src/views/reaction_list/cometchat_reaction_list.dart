import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// [CometChatReactionList] is a StatefulWidget that displays the list of reactions
/// for a particular message. It requires [reactionRequestBuilder] to fetch the
/// reactions of a particular message. It also requires [message] to fetch
/// the reactions of a particular message. It also requires [onTap] to perform
/// some action on click of a particular reaction.
///
/// ```dart
/// CometChatReactionList(
///   reactionRequestBuilder: ReactionsRequestBuilder(), // Get reactions using a builder
///   errorStateText: "Error fetching reactions", // Set error text
///   emptyStateText: "No reactions yet", // Set empty state text
///   messageObject: messageObject, // Set the message object
///   onTap: (reaction, message) => print("Tapped reaction: $reaction"), // Handle tap on reaction
/// );
///```
class CometChatReactionList extends StatefulWidget {
  const CometChatReactionList({
    super.key,
    this.reactionRequestBuilder,
    this.errorStateView,
    this.errorStateText,
    this.loadingStateView,
    this.emptyStateView,
    this.emptyStateText,
    this.loadingIcon,
    this.avatarStyle,
    this.onTap,
    this.style,
    this.selectedReaction,
    this.listItemStyle,
    this.message,
    this.height,
    this.width,
    this.padding,
    this.onReactionListItemClick,
  });

  ///[reactionRequestBuilder] is a parameter used to fetch the reactions of a particular message
  final ReactionsRequestBuilder? reactionRequestBuilder;

  ///[errorStateView] is a parameter used to show the error state view in case of any error
  final WidgetBuilder? errorStateView;

  ///[errorStateText] is a parameter used to show the error state text in case of any error
  final String? errorStateText;

  ///[loadingStateView] is a parameter used to show the loading state view in case of  loading
  final WidgetBuilder? loadingStateView;

  ///[emptyStateText] text to be displayed when the list is empty
  final String? emptyStateText;

  ///[emptyStateView] returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[loadingIcon] is a parameter used to show the loading icon in case of loading
  final Widget? loadingIcon;

  ///[avatarStyle] is a parameter used to set the style for avatar
  final CometChatAvatarStyle? avatarStyle;

  ///[onTap] is a parameter used to perform some action on click of a particular reaction
  final Function(Reaction, BaseMessage)? onTap;

  ///[style] is a parameter used to set the style for the reaction list
  final CometChatReactionListStyle? style;

  ///[selectedReaction] is a parameter used to set the selected reaction
  final String? selectedReaction;

  ///[listItemStyle] is a parameter used to set the style for the list item
  final ListItemStyle? listItemStyle;

  ///[message] is a parameter used to set the message object for which the reactions are to be fetched
  final BaseMessage? message;

  ///[height] provides height to the widget
  final double? height;

  ///[width] provides width to the widget
  final double? width;

  ///[padding] provides padding to the widget
  final EdgeInsetsGeometry? padding;

  ///[onReactionListItemClick] This is to override when a reaction list item is clicked.
  final Function(String? reaction, BaseMessage? message)? onReactionListItemClick;


  @override
  State<CometChatReactionList> createState() => _CometChatReactionListState();
}

class _CometChatReactionListState extends State<CometChatReactionList> {
  late CometChatReactionListController reactionListController;
  late String _currentDateTime;

  @override
  void initState() {
    _currentDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    reactionListController = CometChatReactionListController(
        messageId: widget.message!.id,
        reactionsRequestBuilder: widget.reactionRequestBuilder,
        selectedReaction:
            widget.selectedReaction ?? ReactionConstants.allReactions,
        messageObject: widget.message);
    super.initState();
  }

  late CometChatReactionListStyle reactionListStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    reactionListStyle =
        CometChatThemeHelper.getTheme<CometChatReactionListStyle>(
            context: context, defaultTheme: CometChatReactionListStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.75,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
              color: reactionListStyle.backgroundColor ??
                  colorPalette.background1,
              border: reactionListStyle.border,
              borderRadius: reactionListStyle.borderRadius ?? BorderRadius.vertical(
                  top: Radius.circular(
                      spacing.radius4 ?? 0))),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: spacing.padding3 ?? 0, bottom: spacing.padding2 ?? 0),
                child: Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xff141414).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              //---reactions---
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _getList(context,reactionListStyle, colorPalette, typography, spacing),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getList(BuildContext context, CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing) {
    return GetBuilder<CometChatReactionListController>(
        tag: "default_tag_for_reactionList_$_currentDateTime",
        init: reactionListController,
        builder: (CometChatReactionListController value) {
          value.context = context;


            return SizedBox(
              width: widget.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                          bottom: 1,
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: colorPalette.borderDefault ?? Colors.transparent,
                                      width: 1)),
                            ),
                      )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            // height: 64,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => value.updateSelectedReaction(
                                      ReactionConstants.allReactions),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: spacing.padding2 ?? 0, horizontal: spacing.padding4 ?? 0),
                                    decoration: BoxDecoration(
                                      color: value.isSelectedReaction(ReactionConstants.allReactions)? reactionListStyle.activeTabBackgroundColor:null,
                                      border: value.isSelectedReaction(ReactionConstants.allReactions)? Border(bottom: BorderSide(
                                          color: reactionListStyle.activeTabIndicatorColor ?? colorPalette.primary ?? Colors.transparent ,
                                          width: 2)):null,
                                    ),
                                    child: Text(
                                        "${cc.Translations.of(context).all} ${value.getReactionCount(ReactionConstants.allReactions)}",
                                        style: TextStyle(
                                                fontSize:
                                                reactionListStyle.tabTextStyle?.fontSize ?? typography.body?.medium?.fontSize,
                                                fontWeight:reactionListStyle.tabTextStyle?.fontWeight ??   typography.body?.medium?.fontWeight,
                                                color: value.isSelectedReaction(ReactionConstants.allReactions)
                                                    ? reactionListStyle.activeTabTextColor ?? reactionListStyle.tabTextStyle?.color ??  colorPalette.textHighlight
                                                    : reactionListStyle.tabTextColor ??reactionListStyle.tabTextStyle?.color ??  colorPalette.textSecondary)
                                          ),
                                  ),
                                ),
                                ...value.messageReactions.keys.map((reaction) =>
                                    GestureDetector(
                                      onTap: () =>
                                          value.updateSelectedReaction(reaction),
                                      child: Container(
                                        // padding: const EdgeInsets.symmetric(
                                        //     vertical: 1, horizontal: 5),
                                        // margin: const EdgeInsets.only(left: 10),
                                        padding: EdgeInsets.symmetric(
                                            vertical: spacing.padding2 ?? 0, horizontal: spacing.padding4 ?? 0),
                                        decoration: BoxDecoration(
                                          color: value.isSelectedReaction(reaction)? reactionListStyle.activeTabBackgroundColor:null,
                                          border: value.isSelectedReaction(reaction)? Border(bottom: BorderSide(
                                              color: reactionListStyle.activeTabIndicatorColor ?? colorPalette.primary ?? Colors.transparent ,
                                              width: 2)):null,
                                        ),

                                        child: RichText(
                                          text: TextSpan(
                                            text: reaction,
                                            style: TextStyle(
                                            fontSize: reactionListStyle.tabTextStyle?.fontSize ?? typography.body?.medium?.fontSize,
                                            fontWeight: reactionListStyle.tabTextStyle?.fontWeight?? typography.body?.medium?.fontWeight,),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      " ${value.getReactionCount(reaction)}",
                                                  style:TextStyle(
                                                      fontSize:
                                                      reactionListStyle.tabTextStyle?.fontSize ?? typography.body?.medium?.fontSize,
                                                      fontWeight: reactionListStyle.tabTextStyle?.fontWeight ?? typography.body?.medium?.fontWeight,
                                                      color: value.isSelectedReaction(reaction)
                                                          ?reactionListStyle.activeTabTextColor ??reactionListStyle.tabTextStyle?.color ?? colorPalette.textHighlight
                                                          : reactionListStyle.tabTextColor ??reactionListStyle.tabTextStyle?.color ??colorPalette.textSecondary)),
                                            ],
                                          ),
                                        ),

                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                 getContent(value, reactionListStyle, colorPalette, typography, spacing)
                ],
              ),
            );

        });
  }

  Widget getContent(CometChatReactionListController value, CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing){

    if (value.hasError == true) {
      if (widget.errorStateView != null) {
        return widget.errorStateView!(context);
      } else{
        return getErrorView(reactionListStyle, colorPalette, typography, spacing);
      }
    } else if (value.isLoading == true &&
        (value.messageReactions.isEmpty)) {
      return _getLoadingIndicator(context,value,reactionListStyle, colorPalette,typography, spacing);
    } else if (value.messageReactions.isEmpty) {
      //----------- empty list widget-----------
      return _getNoReactionsIndicator(context,reactionListStyle, colorPalette, typography, spacing);
    } else {
      return  getReactedUsers(value,reactionListStyle, colorPalette, typography, spacing);
  }
  }

  Widget getErrorView( CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing){
    return SizedBox(height: widget.height ??
        MediaQuery.of(context).size.height * .5,
        child:UIStateUtils.getDefaultErrorStateView(context, colorPalette, typography, spacing, null,
            errorStateText:  widget.errorStateText,errorStateTextColor: reactionListStyle.errorTextColor, errorStateTextStyle: reactionListStyle.errorTextStyle,
            errorStateSubtitleColor: reactionListStyle.errorSubtitleColor, errorStateSubtitleStyle: reactionListStyle.errorSubtitleStyle
        ));
  }

  Widget getReactedUsers(CometChatReactionListController value,CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing) {
    List<Reaction> reactions = value.getReactionData();

    return SizedBox(
      height: widget.height ??
          MediaQuery.of(context).size.height * .5,
      child: ListView.builder(
        itemCount:
            value.canFetchReactions() ? reactions.length + 1 : reactions.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index >= reactions.length) {
            value.fetchReactions(value.selectedReaction);
            return Container(
              height: 150,
              alignment: Alignment.center,
              child: widget.loadingIcon ??
                  Image.asset(
                    AssetConstants.spinner,
                    package: UIConstants.packageName,
                    color: colorPalette.textSecondary
                  ),
            );
          }

          return GestureDetector(
            onTap: () {
              if(widget.onReactionListItemClick != null) {
                widget.onReactionListItemClick!(
                    reactions[index].reaction, widget.message);
              } else {
                value.onReactionTap(reactions[index]);
              }
            },
            child: getReactionListItem(reactions[index], value,reactionListStyle, colorPalette, typography,spacing),
          );
        },
      ),
    );
  }

  Widget getReactionListItem(
      Reaction reaction, CometChatReactionListController value,CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography,CometChatSpacing spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.padding5 ?? 0,vertical: spacing.padding2 ?? 0),
      child: CometChatListItem(
        avatarURL: reaction.reactedBy?.avatar,
        avatarName: reaction.reactedBy?.name,
        title: value.getReactionListItemTitle(reaction),
        subtitleView: getReactionItemSubtitle(reaction, value,reactionListStyle, colorPalette, typography),
        tailView: Text(
          reaction.reaction ?? "",
          style: typography.heading2?.regular?.merge(reactionListStyle.tailViewTextStyle),
        ),
        style: ListItemStyle(
          titleStyle: TextStyle(
              fontSize: reactionListStyle.titleTextStyle?.fontSize ?? typography.body?.medium?.fontSize,
              fontWeight: reactionListStyle.titleTextStyle?.fontWeight ?? typography.body?.medium?.fontWeight,
              fontFamily: reactionListStyle.titleTextStyle?.fontFamily ?? typography.body?.medium?.fontFamily,
              color: reactionListStyle.titleTextColor ?? reactionListStyle.titleTextStyle?.color ?? colorPalette.textPrimary
          ),
        ).merge(widget.listItemStyle),
        avatarHeight: 32,
        avatarWidth: 32,
      ),
    );
  }

  Widget? getReactionItemSubtitle(
      Reaction reaction, CometChatReactionListController value,CometChatReactionListStyle reactionListStyle,CometChatColorPalette colorPalette,CometChatTypography typography) {
    return value.isReactedByMe(reaction.reactedBy!)
        ? Text(
            cc.Translations.of(context).tapToRemove,
            style: TextStyle(
                    fontSize:reactionListStyle.subtitleTextStyle?.fontSize ?? typography.caption1?.regular?.fontSize,
                    fontWeight: reactionListStyle.subtitleTextStyle?.fontWeight ?? typography.caption1?.regular?.fontWeight,
                    fontFamily: reactionListStyle.subtitleTextStyle?.fontFamily ?? typography.caption1?.regular?.fontFamily,
                    color: reactionListStyle.subtitleTextColor ?? reactionListStyle.subtitleTextStyle?.color ?? colorPalette.textSecondary)
              ,
          )
        : null;
  }

  Widget _getNoReactionsIndicator(BuildContext context, CometChatReactionListStyle reactionListStyle, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    } else {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text(
          widget.emptyStateText ?? cc.Translations.of(context).noReactionsFound,
          style: TextStyle(
                  fontSize: reactionListStyle.emptyTextStyle?.fontSize ?? typography.body?.regular?.fontSize,
                  fontWeight: reactionListStyle.emptyTextStyle?.fontWeight ?? typography.body?.regular?.fontWeight,
                  color: reactionListStyle.emptyTextStyle?.color ??  colorPalette.textSecondary),
        ),
      );
    }
  }



  Widget _getLoadingIndicator(BuildContext context, CometChatReactionListController value, CometChatReactionListStyle reactionListStyle,
     CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
    } else {

      return SizedBox(
        height: widget.height ??
            MediaQuery.of(context).size.height * .5,
        child: CometChatShimmerEffect(
          colorPalette: colorPalette,
          child: ListView.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.padding5 ?? 0,vertical: spacing.padding2 ?? 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                radius: 18,
                ),
              Flexible(
                flex: 4,
                child: Container(
                  // width: cellWidth,
                  margin: EdgeInsets.only(left: spacing.padding3 ?? 0),
                  height: 18,

                  decoration: BoxDecoration(
                    color: colorPalette.background1,
                    borderRadius: BorderRadius.circular(spacing.radiusMax ?? 0),
                  ),
                ),
              ),
              const Spacer(),
              const CircleAvatar(
              radius: 10,
              ),
                ],
              ));
            },
          ),
        ),
      );
    }
  }
}
