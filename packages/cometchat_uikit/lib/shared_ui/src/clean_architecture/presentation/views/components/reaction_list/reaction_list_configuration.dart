import "../../../../clean_architecture.dart";
import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart'
    show CometChatAvatarStyle, ListItemStyle;

///[ReactionListConfiguration] is a class which is used to set the configuration for the reaction list
///It takes [reactionRequestBuilder], [errorStateView], [errorStateText], [loadingStateView], [emptyStateView], [emptyStateText], [avatarStyle], [onTap], [reactionListStyle], [selectedReaction], [listItemStyle], [messageObject], [theme] as a parameter
///
/// ```dart
/// ReactionListConfiguration(
/// emptyStateText: "No Reactions Available",
/// avatarStyle: AvatarStyle()
/// );
class ReactionListConfiguration {
  ReactionListConfiguration({
    this.reactionRequestBuilder,
    this.errorStateView,
    this.errorStateText,
    this.loadingStateView,
    this.emptyStateView,
    this.emptyStateText,
    this.loadingIcon,
    this.avatarStyle,
    this.onTap,
    this.reactionListStyle,
    this.selectedReaction,
    this.listItemStyle,
    this.messageObject,
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
  Function(Reaction, BaseMessage)? onTap;

  ///[reactionListStyle] is a parameter used to set the style for the reaction list
  final CometChatReactionListStyle? reactionListStyle;

  ///[selectedReaction] is a parameter used to set the selected reaction
  final String? selectedReaction;

  ///[listItemStyle] is a parameter used to set the style for the list item
  final ListItemStyle? listItemStyle;

  ///[messageObject] is a parameter used to set the message object for which the reactions are to be fetched
  final BaseMessage? messageObject;
}
