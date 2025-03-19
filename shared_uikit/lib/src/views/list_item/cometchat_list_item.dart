import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatListItem] is a top level container widget
///used internally for displaying each item in components like `CometChatUsers`, `CometChatGroups`, `CometChatConversations`, `CometChatGroupMembers`
/// ```dart
///                CometChatListItem(
///                    avatarName: _user.name,
///                    avatarURL: _user.avatar,
///                    title: _user.name,
///                    statusIndicatorColor: backgroundColor,
///                    statusIndicatorIcon: icon,
///                  );
/// ```
class CometChatListItem extends StatelessWidget {
  const CometChatListItem({
    super.key,
    this.avatarURL,
    this.avatarName,
    this.statusIndicatorColor,
    this.statusIndicatorIcon,
    this.title,
    this.subtitleView,
    this.options,
    this.tailView,
    this.hideSeparator = true,
    this.avatarStyle = const CometChatAvatarStyle(),
    this.style = const ListItemStyle(),
    this.avatarHeight,
    this.avatarWidth,
    this.avatarPadding,
    this.avatarMargin,
    this.statusIndicatorStyle = const CometChatStatusIndicatorStyle(),
    this.statusIndicatorWidth,
    this.statusIndicatorHeight,
    this.statusIndicatorBorderRadius,
    this.id,
    this.titlePadding,
    this.titleView,
    this.leadingStateView,
  }) : assert(avatarURL != null || avatarName != null);

  ///[avatarURL] sets image url to be shown in avatar
  final String? avatarURL;

  ///[avatarName] sets name  to be shown in avatar if avatarURL is not available
  final String? avatarName;

  ///[statusIndicatorColor] toggle visibility for status indicator
  final Color? statusIndicatorColor;

  ///[statusIndicatorIcon] sets status
  final Widget? statusIndicatorIcon;

  ///[title] sets title
  final String? title;

  ///[subtitleView] gives subtitle view
  final Widget? subtitleView;

  ///[options] set options for
  final List<CometChatOption>? options;

  ///[tailView] sets tail
  final Widget? tailView;

  ///[hideSeparator] toggle separator visibility
  final bool? hideSeparator;

  ///[style] style for DataItem
  final ListItemStyle style;

  ///[avatarStyle] style for avatar
  final CometChatAvatarStyle avatarStyle;

  ///[statusIndicatorStyle] style for status indicator
  final CometChatStatusIndicatorStyle statusIndicatorStyle;

  ///[id] for list item
  final String? id;

  ///[avatarWidth] provides width to the widget
  final double? avatarWidth;

  ///[avatarHeight] provides height to the widget
  final double? avatarHeight;

  ///[avatarPadding] provides padding to the widget
  final EdgeInsetsGeometry? avatarPadding;

  ///[avatarMargin] provides margin to the widget
  final EdgeInsetsGeometry? avatarMargin;

  ///[statusIndicatorWidth] provides width to the status indicator
  final double? statusIndicatorWidth;

  ///[statusIndicatorHeight] provides height to the status indicator
  final double? statusIndicatorHeight;

  ///[statusIndicatorBorderRadius] provides borderRadius to the status indicator
  final BorderRadiusGeometry? statusIndicatorBorderRadius;

  ///[titlePadding] set title padding
  final EdgeInsetsGeometry? titlePadding;

  ///[leadingStateView] to set leading view
  final Widget? leadingStateView;

  ///[titleView] to set title view
  final Widget? titleView;

  Widget getLeadingView() {
    if (leadingStateView != null) {
      return leadingStateView ?? const SizedBox();
    } else {
      return CometChatAvatar(
        image: avatarURL,
        name: avatarName,
        height: avatarHeight,
        width: avatarWidth,
        margin: avatarMargin,
        padding: avatarPadding,
        style: CometChatAvatarStyle(
          placeHolderTextStyle: avatarStyle.placeHolderTextStyle,
          placeHolderTextColor: avatarStyle.placeHolderTextColor,
          backgroundColor: avatarStyle.backgroundColor,
          border: avatarStyle.border,
          borderRadius: avatarStyle.borderRadius,
        ),
      );
    }
  }

  Widget getStatus() {
    return CometChatStatusIndicator(
      height: statusIndicatorHeight,
      width: statusIndicatorWidth,
      backgroundImage: statusIndicatorIcon,
      style: CometChatStatusIndicatorStyle(
        border: statusIndicatorStyle.border,
        backgroundColor: statusIndicatorColor,
        borderRadius: statusIndicatorBorderRadius,
      ),
    );
  }

  Widget getTitle(context) {
    if (titleView != null) {
      return titleView ?? const SizedBox();
    } else {
      return Text(
        title ?? "",
        maxLines: 1,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: style.titleStyle?.fontSize,
          fontWeight: style.titleStyle?.fontWeight,
          fontFamily: style.titleStyle?.fontFamily,
          color: style.titleStyle?.color,
        ).merge(
          style.titleStyle,
        ),
      );
    }
  }

  Widget? getSubtitle() {
    return subtitleView;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: style.margin,
      padding: style.padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.background,
        border: style.border,
        borderRadius: style.borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CometChatListTile(
            height: style.height,
            leading: Stack(
              children: [
                getLeadingView(),
                if (statusIndicatorColor != null || statusIndicatorIcon != null)
                  Positioned(
                    height: statusIndicatorHeight ?? 14,
                    width: statusIndicatorWidth ?? 14,
                    right: 0,
                    bottom: 0,
                    child: getStatus(),
                  )
              ],
            ),
            title: getTitle(
              context,
            ),
            subtitle: getSubtitle(),
            trailing: tailView,
            titlePadding: titlePadding,
          ),
          if (hideSeparator == false)
            Divider(
              thickness: 1,
              height: 1,
              color: style.separatorColor,
            )
        ],
      ),
    );
  }
}

///[_CometChatListTile] is a private class used internally in CometChatListItem
///to display the list tile with leading, title, subtitle and trailing widgets
///such that the widget is not constrained to a specific height
class _CometChatListTile extends StatelessWidget {
  const _CometChatListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.height,
    this.titlePadding,
    this.subtitlePadding,
  }) : super(key: key);

  ///[leading] widget to be shown at the start of the tile
  final Widget? leading;

  ///[title] widget to be shown as title
  final Widget? title;

  ///[subtitle] widget to be shown as subtitle
  final Widget? subtitle;

  ///[trailing] widget to be shown at the end of the tile
  final Widget? trailing;

  ///[contentPadding] padding for the content
  final EdgeInsetsGeometry? contentPadding;

  ///[height] set tile height
  final double? height;

  ///[titlePadding] set title padding
  final EdgeInsetsGeometry? titlePadding;

  ///[subtitlePadding] set subtitle padding
  final EdgeInsetsGeometry? subtitlePadding;

  @override
  Widget build(BuildContext context) {
    final spacing = CometChatThemeHelper.getSpacing(context);
    return Container(
      color: Colors.transparent,
      padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Padding(
              padding: titlePadding ??
                  EdgeInsets.only(
                    left: spacing.padding3 ?? 0,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title ?? const SizedBox(),
                  if (subtitle != null) subtitle!,
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
