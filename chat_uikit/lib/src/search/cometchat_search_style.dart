import 'package:flutter/material.dart';

import '../../cometchat_chat_uikit.dart';

class CometChatSearchStyle extends ThemeExtension<CometChatSearchStyle> {
  const CometChatSearchStyle({
    this.backgroundColor,
    this.searchBackgroundColor,
    this.searchBorder,
    this.searchBorderRadius,
    this.searchTextColor,
    this.searchTextStyle,
    this.searchPlaceHolderTextColor,
    this.searchPlaceHolderTextStyle,
    this.searchBackIconColor,
    this.searchClearIconColor,
    this.searchFilterChipBackgroundColor,
    this.searchFilterChipSelectedBackgroundColor,
    this.searchFilterChipTextStyle,
    this.searchFilterChipTextColor,
    this.searchFilterChipSelectedTextColor,
    this.searchFilterChipBorder,
    this.searchFilterChipSelectedBorder,
    this.searchFilterChipBorderRadius,
    this.searchFilterChipSelectedTextStyle,
    this.searchFilterIconColor,
    this.searchFilterSelectedIconColor,
    this.searchSectionHeaderTextColor,
    this.searchSectionHeaderTextStyle,
    this.searchConversationDateTextColor,
    this.searchConversationDateTextStyle,
    this.searchConversationItemBackgroundColor,
    this.searchConversationSubTitleTextStyle,
    this.searchConversationTitleSubTextColor,
    this.searchConversationTitleTextColor,
    this.searchConversationTitleTextStyle,
    this.avatarStyle,
    this.badgeStyle,
    this.searchEmptyStateTextStyle,
    this.searchEmptyStateTextColor,
    this.searchEmptyStateSubtitleStyle,
    this.searchEmptyStateSubtitleColor,
    this.searchErrorStateTextStyle,
    this.searchErrorStateTextColor,
    this.searchErrorStateSubtitleStyle,
    this.searchErrorStateSubtitleColor,
    this.searchSeeMoreColor,
    this.searchSeeMoreStyle,
    this.searchMessageItemBackgroundColor,
    this.searchMessageTitleTextStyle,
    this.searchMessageTitleTextColor,
    this.searchMessageSubTitleTextStyle,
    this.searchMessageSubTitleTextColor,
    this.searchMessageTimeStampStyle,
    this.searchMessageDateSeparatorStyle,
  });

  /// [backgroundColor] background color of the search component
  final Color? backgroundColor;

  /// [searchBackgroundColor] background color of the search text field
  final Color? searchBackgroundColor;

  /// [searchBorder] border of the search text field
  final BorderSide? searchBorder;

  /// [searchBorderRadius] border radius of the search text field
  final BorderRadius? searchBorderRadius;

  /// [searchTextColor] color of the search text
  final Color? searchTextColor;

  /// [searchTextStyle] style of the search text
  final TextStyle? searchTextStyle;

  /// [searchPlaceHolderTextColor] color of the search placeholder text
  final Color? searchPlaceHolderTextColor;

  /// [searchPlaceHolderTextStyle] style of the search placeholder text
  final TextStyle? searchPlaceHolderTextStyle;

  /// [searchBackIconColor] color of the search back icon
  final Color? searchBackIconColor;

  /// [searchClearIconColor] color of the search clear icon
  final Color? searchClearIconColor;

  /// [searchFilterChipBackgroundColor] background color of the search filter chip
  final Color? searchFilterChipBackgroundColor;

  /// [searchFilterChipSelectedBackgroundColor] background color of the selected search filter chip
  final Color? searchFilterChipSelectedBackgroundColor;

  /// [searchFilterChipTextColor] text color of the search filter chip
  final TextStyle? searchFilterChipTextStyle;

  /// [searchFilterChipTextColor] text color of the search filter chip
  final Color? searchFilterChipTextColor;

  /// [searchFilterChipSelectedTextColor] text color of the selected search filter chip
  final Color? searchFilterChipSelectedTextColor;

  /// [searchFilterChipBorder] border of the search filter chip
  final Border? searchFilterChipBorder;

  /// [searchFilterChipBorder] border of the search filter chip
  final Border? searchFilterChipSelectedBorder;

  /// [searchFilterChipBorderRadius] border radius of the search filter chip
  final BorderRadius? searchFilterChipBorderRadius;

  /// [searchFilterChipSelectedTextStyle] text style of the selected search filter chip
  final TextStyle? searchFilterChipSelectedTextStyle;

  /// [searchFilterIconColor] color of the search filter icon
  final Color? searchFilterIconColor;

  /// [searchFilterSelectedIconColor] color of the search search filter icon
  final Color? searchFilterSelectedIconColor;

  /// [searchSectionHeaderTextColor] color of the search section header text
  final Color? searchSectionHeaderTextColor;

  /// [searchSectionHeaderTextStyle] style of the search section header text
  final TextStyle? searchSectionHeaderTextStyle;

  /// [searchConversationItemBackgroundColor] color of the search conversation item background
  final Color? searchConversationItemBackgroundColor;

  /// [searchConversationTitleTextStyle] text color of the search conversation title
  final TextStyle? searchConversationTitleTextStyle;

  /// [searchConversationTitleTextColor] text color of the search conversation title
  final Color? searchConversationTitleTextColor;

  /// [searchConversationSubTitleTextStyle] text color of the search conversation sub title
  final TextStyle? searchConversationSubTitleTextStyle;

  /// [searchConversationTitleSubTextColor] text color of the search conversation sub title
  final Color? searchConversationTitleSubTextColor;

  /// [searchConversationDateTextStyle] text color of the search conversation date
  final TextStyle? searchConversationDateTextStyle;

  /// [searchConversationDateTextColor] text color of the search conversation date
  final Color? searchConversationDateTextColor;

  ///[avatarStyle] set style for avatar
  final CometChatAvatarStyle? avatarStyle;

  ///[badgeStyle] used to customize the unread messages count indicator
  final CometChatBadgeStyle? badgeStyle;

  ///[searchEmptyStateTextStyle] defines the style of the text to be displayed when the list is empty
  final TextStyle? searchEmptyStateTextStyle;

  ///[searchEmptyStateTextColor] defines the color of the text to be displayed when the list is empty
  final Color? searchEmptyStateTextColor;

  ///[searchEmptyStateSubtitleStyle] defines the style of the subtitle to be displayed when the list is empty
  final TextStyle? searchEmptyStateSubtitleStyle;

  ///[searchEmptyStateSubtitleColor] defines the color of the subtitle to be displayed when the list is empty
  final Color? searchEmptyStateSubtitleColor;

  ///[searchErrorStateTextStyle] defines the style of the text to be displayed when the list is in error state
  final TextStyle? searchErrorStateTextStyle;

  ///[searchErrorStateTextColor] defines the color of the text to be displayed when the list is in error state
  final Color? searchErrorStateTextColor;

  ///[searchErrorStateSubtitleStyle] defines the style of the subtitle to be displayed when the list is in error state
  final TextStyle? searchErrorStateSubtitleStyle;

  ///[searchErrorStateSubtitleColor] defines the color of the subtitle to be displayed when the list is in error state
  final Color? searchErrorStateSubtitleColor;

  ///[searchSeeMoreStyle] defines the style of the see more text to be displayed
  final TextStyle? searchSeeMoreStyle;

  ///[searchSeeMoreColor] defines the color of the see more text to be displayed
  final Color? searchSeeMoreColor;

  /// [searchMessageItemBackgroundColor] color of the search message item background
  final Color? searchMessageItemBackgroundColor;

  /// [searchMessageTitleTextStyle] text color of the search message title
  final TextStyle? searchMessageTitleTextStyle;

  /// [searchMessageTitleTextColor] text color of the search message title
  final Color? searchMessageTitleTextColor;

  /// [searchConversationSubTitleTextStyle] text color of the search message sub title
  final TextStyle? searchMessageSubTitleTextStyle;

  /// [searchConversationTitleSubTextColor] text color of the search message sub title
  final Color? searchMessageSubTitleTextColor;

  /// [searchMessageTimeStampStyle] style of the timestamp in search messages
  final CometChatDateStyle? searchMessageTimeStampStyle;

  /// [searchMessageDateSeparatorStyle] style of the date separator in search messages
  final CometChatDateStyle? searchMessageDateSeparatorStyle;

  static CometChatSearchStyle of(BuildContext context) =>
      Theme.of(context).extension<CometChatSearchStyle>() ??
      const CometChatSearchStyle();

  @override
  CometChatSearchStyle copyWith({
    Color? backgroundColor,
    Color? searchBackgroundColor,
    BorderSide? searchBorder,
    BorderRadius? searchBorderRadius,
    Color? searchTextColor,
    TextStyle? searchTextStyle,
    Color? searchPlaceHolderTextColor,
    TextStyle? searchPlaceHolderTextStyle,
    Color? searchIconColor,
    Color? searchClearIconColor,
    Color? searchFilterChipBackgroundColor,
    Color? searchFilterChipSelectedBackgroundColor,
    TextStyle? searchFilterChipTextStyle,
    Color? searchFilterChipTextColor,
    Color? searchFilterChipSelectedTextColor,
    Border? searchFilterChipBorder,
    Border? searchFilterChipSelectedBorder,
    BorderRadius? searchFilterChipBorderRadius,
    TextStyle? searchFilterChipSelectedTextStyle,
    Color? searchFilterIconColor,
    Color? searchFilterSelectedIconColor,
    Color? searchSectionHeaderTextColor,
    TextStyle? searchSectionHeaderTextStyle,
    TextStyle? searchConversationTitleTextStyle,
    Color? searchConversationTitleTextColor,
    TextStyle? searchConversationSubTitleTextStyle,
    Color? searchConversationTitleSubTextColor,
    TextStyle? searchConversationDateTextStyle,
    Color? searchConversationDateTextColor,
    Color? searchConversationItemBackgroundColor,
    CometChatAvatarStyle? avatarStyle,
    CometChatBadgeStyle? badgeStyle,
    Color? searchEmptyStateTextColor,
    TextStyle? searchEmptyStateTextStyle,
    Color? searchEmptyStateSubtitleColor,
    TextStyle? searchEmptyStateSubtitleStyle,
    Color? searchErrorStateTextColor,
    TextStyle? searchErrorStateTextStyle,
    Color? searchErrorStateSubtitleColor,
    TextStyle? searchErrorStateSubtitleStyle,
    TextStyle? searchSeeMoreStyle,
    Color? searchSeeMoreColor,
    Color? searchMessageItemBackgroundColor,
    TextStyle? searchMessageTitleTextStyle,
    Color? searchMessageTitleTextColor,
    TextStyle? searchMessageSubTitleTextStyle,
    Color? searchMessageTitleSubTextColor,
    CometChatDateStyle? searchMessageTimeStampStyle,
    CometChatDateStyle? searchMessageDateSeparatorStyle,
  }) {
    return CometChatSearchStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      searchBackgroundColor:
          searchBackgroundColor ?? this.searchBackgroundColor,
      searchBorder: searchBorder ?? this.searchBorder,
      searchBorderRadius: searchBorderRadius ?? this.searchBorderRadius,
      searchTextColor: searchTextColor ?? this.searchTextColor,
      searchTextStyle: searchTextStyle ?? this.searchTextStyle,
      searchPlaceHolderTextColor:
          searchPlaceHolderTextColor ?? this.searchPlaceHolderTextColor,
      searchPlaceHolderTextStyle:
          searchPlaceHolderTextStyle ?? this.searchPlaceHolderTextStyle,
      searchBackIconColor: searchIconColor ?? searchBackIconColor,
      searchClearIconColor: searchClearIconColor ?? this.searchClearIconColor,
      searchFilterChipBackgroundColor:
          searchFilterChipBackgroundColor ??
          this.searchFilterChipBackgroundColor,
      searchFilterChipSelectedBackgroundColor:
          searchFilterChipSelectedBackgroundColor ??
          this.searchFilterChipSelectedBackgroundColor,
      searchFilterChipTextStyle:
          searchFilterChipTextStyle ?? this.searchFilterChipTextStyle,
      searchFilterChipTextColor:
          searchFilterChipTextColor ?? this.searchFilterChipTextColor,
      searchFilterChipSelectedTextColor:
          searchFilterChipSelectedTextColor ??
          this.searchFilterChipSelectedTextColor,
      searchFilterChipBorder:
          searchFilterChipBorder ?? this.searchFilterChipBorder,
      searchFilterChipSelectedBorder:
          searchFilterChipSelectedBorder ?? this.searchFilterChipSelectedBorder,
      searchFilterChipBorderRadius:
          searchFilterChipBorderRadius ?? this.searchFilterChipBorderRadius,
      searchFilterChipSelectedTextStyle:
          searchFilterChipSelectedTextStyle ??
          this.searchFilterChipSelectedTextStyle,
      searchFilterIconColor:
          searchFilterIconColor ?? this.searchFilterIconColor,
      searchFilterSelectedIconColor:
          searchFilterSelectedIconColor ?? this.searchFilterSelectedIconColor,
      searchSectionHeaderTextColor:
          searchSectionHeaderTextColor ?? this.searchSectionHeaderTextColor,
      searchSectionHeaderTextStyle:
          searchSectionHeaderTextStyle ?? this.searchSectionHeaderTextStyle,
      searchConversationTitleTextStyle:
          searchConversationTitleTextStyle ??
          this.searchConversationTitleTextStyle,
      searchConversationTitleTextColor:
          searchConversationTitleTextColor ??
          this.searchConversationTitleTextColor,
      searchConversationSubTitleTextStyle:
          searchConversationSubTitleTextStyle ??
          this.searchConversationSubTitleTextStyle,
      searchConversationTitleSubTextColor:
          searchConversationTitleSubTextColor ??
          this.searchConversationTitleSubTextColor,
      searchConversationDateTextStyle:
          searchConversationDateTextStyle ??
          this.searchConversationDateTextStyle,
      searchConversationDateTextColor:
          searchConversationDateTextColor ??
          this.searchConversationDateTextColor,
      searchConversationItemBackgroundColor:
          searchConversationItemBackgroundColor ??
          this.searchConversationItemBackgroundColor,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      searchEmptyStateTextStyle:
          searchEmptyStateTextStyle ?? this.searchEmptyStateTextStyle,
      searchEmptyStateTextColor:
          searchEmptyStateTextColor ?? this.searchEmptyStateTextColor,
      searchEmptyStateSubtitleStyle:
          searchEmptyStateSubtitleStyle ?? this.searchEmptyStateSubtitleStyle,
      searchEmptyStateSubtitleColor:
          searchEmptyStateSubtitleColor ?? this.searchEmptyStateSubtitleColor,
      searchErrorStateTextStyle:
          searchErrorStateTextStyle ?? this.searchErrorStateTextStyle,
      searchErrorStateTextColor:
          searchErrorStateTextColor ?? this.searchErrorStateTextColor,
      searchErrorStateSubtitleStyle:
          searchErrorStateSubtitleStyle ?? this.searchErrorStateSubtitleStyle,
      searchErrorStateSubtitleColor:
          searchErrorStateSubtitleColor ?? this.searchErrorStateSubtitleColor,
      searchSeeMoreStyle: searchSeeMoreStyle ?? this.searchSeeMoreStyle,
      searchSeeMoreColor: searchSeeMoreColor ?? this.searchSeeMoreColor,
      searchMessageItemBackgroundColor:
          searchMessageItemBackgroundColor ??
          this.searchMessageItemBackgroundColor,
      searchMessageTitleTextStyle:
          searchMessageTitleTextStyle ?? this.searchMessageTitleTextStyle,
      searchMessageTitleTextColor:
          searchMessageTitleTextColor ?? this.searchMessageTitleTextColor,
      searchMessageSubTitleTextStyle:
          searchMessageSubTitleTextStyle ?? this.searchMessageSubTitleTextStyle,
      searchMessageSubTitleTextColor:
          searchMessageTitleSubTextColor ?? searchMessageSubTitleTextColor,
      searchMessageTimeStampStyle:
          searchMessageTimeStampStyle ?? this.searchMessageTimeStampStyle,
      searchMessageDateSeparatorStyle:
          searchMessageDateSeparatorStyle ??
          this.searchMessageDateSeparatorStyle,
    );
  }

  CometChatSearchStyle merge(CometChatSearchStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      searchBackgroundColor: style.searchBackgroundColor,
      searchBorder: style.searchBorder,
      searchBorderRadius: style.searchBorderRadius,
      searchTextColor: style.searchTextColor,
      searchTextStyle: style.searchTextStyle,
      searchPlaceHolderTextColor: style.searchPlaceHolderTextColor,
      searchPlaceHolderTextStyle: style.searchPlaceHolderTextStyle,
      searchIconColor: style.searchBackIconColor,
      searchClearIconColor: style.searchClearIconColor,
      searchFilterChipBackgroundColor: style.searchFilterChipBackgroundColor,
      searchFilterChipSelectedBackgroundColor:
          style.searchFilterChipSelectedBackgroundColor,
      searchFilterChipTextStyle: style.searchFilterChipTextStyle,
      searchFilterChipTextColor: style.searchFilterChipTextColor,
      searchFilterChipSelectedTextColor:
          style.searchFilterChipSelectedTextColor,
      searchFilterChipBorder: style.searchFilterChipBorder,
      searchFilterChipSelectedBorder: style.searchFilterChipSelectedBorder,
      searchFilterChipBorderRadius: style.searchFilterChipBorderRadius,
      searchFilterChipSelectedTextStyle:
          style.searchFilterChipSelectedTextStyle,
      searchFilterIconColor: style.searchFilterIconColor,
      searchFilterSelectedIconColor: style.searchFilterSelectedIconColor,
      searchSectionHeaderTextColor: style.searchSectionHeaderTextColor,
      searchSectionHeaderTextStyle: style.searchSectionHeaderTextStyle,
      searchConversationTitleTextStyle: style.searchConversationTitleTextStyle,
      searchConversationTitleTextColor: style.searchConversationTitleTextColor,
      searchConversationSubTitleTextStyle:
          style.searchConversationSubTitleTextStyle,
      searchConversationTitleSubTextColor:
          style.searchConversationTitleSubTextColor,
      searchConversationDateTextStyle: style.searchConversationDateTextStyle,
      searchConversationDateTextColor: style.searchConversationDateTextColor,
      searchConversationItemBackgroundColor:
          style.searchConversationItemBackgroundColor,
      avatarStyle: style.avatarStyle,
      badgeStyle: style.badgeStyle,
      searchEmptyStateTextStyle: style.searchEmptyStateTextStyle,
      searchEmptyStateTextColor: style.searchEmptyStateTextColor,
      searchEmptyStateSubtitleStyle: style.searchEmptyStateSubtitleStyle,
      searchEmptyStateSubtitleColor: style.searchEmptyStateSubtitleColor,
      searchErrorStateTextStyle: style.searchErrorStateTextStyle,
      searchErrorStateTextColor: style.searchErrorStateTextColor,
      searchErrorStateSubtitleStyle: style.searchErrorStateSubtitleStyle,
      searchErrorStateSubtitleColor: style.searchErrorStateSubtitleColor,
      searchSeeMoreStyle: style.searchSeeMoreStyle,
      searchSeeMoreColor: style.searchSeeMoreColor,
      searchMessageItemBackgroundColor: style.searchMessageItemBackgroundColor,
      searchMessageTitleTextStyle: style.searchMessageTitleTextStyle,
      searchMessageTitleTextColor: style.searchMessageTitleTextColor,
      searchMessageSubTitleTextStyle: style.searchMessageSubTitleTextStyle,
      searchMessageTitleSubTextColor: style.searchMessageSubTitleTextColor,
      searchMessageTimeStampStyle: style.searchMessageTimeStampStyle,
      searchMessageDateSeparatorStyle: style.searchMessageDateSeparatorStyle,
    );
  }

  @override
  CometChatSearchStyle lerp(
    ThemeExtension<CometChatSearchStyle>? other,
    double t,
  ) {
    if (other is! CometChatSearchStyle) return this;
    return CometChatSearchStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      searchBackgroundColor: Color.lerp(
        searchBackgroundColor,
        other.searchBackgroundColor,
        t,
      ),
      searchBorder: BorderSide.lerp(
        searchBorder ?? BorderSide.none,
        other.searchBorder ?? BorderSide.none,
        t,
      ),
      searchBorderRadius: BorderRadius.lerp(
        searchBorderRadius,
        other.searchBorderRadius,
        t,
      ),
      searchTextColor: Color.lerp(searchTextColor, other.searchTextColor, t),
      searchTextStyle: TextStyle.lerp(
        searchTextStyle,
        other.searchTextStyle,
        t,
      ),
      searchPlaceHolderTextColor: Color.lerp(
        searchPlaceHolderTextColor,
        other.searchPlaceHolderTextColor,
        t,
      ),
      searchPlaceHolderTextStyle: TextStyle.lerp(
        searchPlaceHolderTextStyle,
        other.searchPlaceHolderTextStyle,
        t,
      ),
      searchBackIconColor: Color.lerp(
        searchBackIconColor,
        other.searchBackIconColor,
        t,
      ),
      searchClearIconColor: Color.lerp(
        searchClearIconColor,
        other.searchClearIconColor,
        t,
      ),
      searchFilterChipBackgroundColor: Color.lerp(
        searchFilterChipBackgroundColor,
        other.searchFilterChipBackgroundColor,
        t,
      ),
      searchFilterChipSelectedBackgroundColor: Color.lerp(
        searchFilterChipSelectedBackgroundColor,
        other.searchFilterChipSelectedBackgroundColor,
        t,
      ),
      searchFilterChipTextStyle: TextStyle.lerp(
        searchFilterChipTextStyle,
        other.searchFilterChipTextStyle,
        t,
      ),
      searchFilterChipTextColor: Color.lerp(
        searchFilterChipTextColor,
        other.searchFilterChipTextColor,
        t,
      ),
      searchFilterChipSelectedTextColor: Color.lerp(
        searchFilterChipSelectedTextColor,
        other.searchFilterChipSelectedTextColor,
        t,
      ),
      searchFilterChipBorder: Border.lerp(
        searchFilterChipBorder,
        other.searchFilterChipBorder,
        t,
      ),
      searchFilterChipSelectedBorder: Border.lerp(
        searchFilterChipSelectedBorder,
        other.searchFilterChipSelectedBorder,
        t,
      ),
      searchFilterChipBorderRadius: BorderRadius.lerp(
        searchFilterChipBorderRadius,
        other.searchFilterChipBorderRadius,
        t,
      ),
      searchFilterChipSelectedTextStyle: TextStyle.lerp(
        searchFilterChipSelectedTextStyle,
        other.searchFilterChipSelectedTextStyle,
        t,
      ),
      searchFilterIconColor: Color.lerp(
        searchFilterIconColor,
        other.searchFilterIconColor,
        t,
      ),
      searchFilterSelectedIconColor: Color.lerp(
        searchFilterSelectedIconColor,
        other.searchFilterSelectedIconColor,
        t,
      ),
      searchSectionHeaderTextColor: Color.lerp(
        searchSectionHeaderTextColor,
        other.searchSectionHeaderTextColor,
        t,
      ),
      searchSectionHeaderTextStyle: TextStyle.lerp(
        searchSectionHeaderTextStyle,
        other.searchSectionHeaderTextStyle,
        t,
      ),
      searchConversationTitleTextStyle: TextStyle.lerp(
        searchConversationTitleTextStyle,
        other.searchConversationTitleTextStyle,
        t,
      ),
      searchConversationTitleTextColor: Color.lerp(
        searchConversationTitleTextColor,
        other.searchConversationTitleTextColor,
        t,
      ),
      searchConversationSubTitleTextStyle: TextStyle.lerp(
        searchConversationSubTitleTextStyle,
        other.searchConversationSubTitleTextStyle,
        t,
      ),
      searchConversationTitleSubTextColor: Color.lerp(
        searchConversationTitleSubTextColor,
        other.searchConversationTitleSubTextColor,
        t,
      ),
      searchConversationDateTextStyle: TextStyle.lerp(
        searchConversationDateTextStyle,
        other.searchConversationDateTextStyle,
        t,
      ),
      searchConversationDateTextColor: Color.lerp(
        searchConversationDateTextColor,
        other.searchConversationDateTextColor,
        t,
      ),
      searchConversationItemBackgroundColor: Color.lerp(
        searchConversationItemBackgroundColor,
        other.searchConversationItemBackgroundColor,
        t,
      ),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t) ?? other.avatarStyle,
      badgeStyle: badgeStyle?.lerp(other.badgeStyle, t) ?? other.badgeStyle,
      searchEmptyStateTextStyle: TextStyle.lerp(
        searchEmptyStateTextStyle,
        other.searchEmptyStateTextStyle,
        t,
      ),
      searchEmptyStateTextColor: Color.lerp(
        searchEmptyStateTextColor,
        other.searchEmptyStateTextColor,
        t,
      ),
      searchEmptyStateSubtitleStyle: TextStyle.lerp(
        searchEmptyStateSubtitleStyle,
        other.searchEmptyStateSubtitleStyle,
        t,
      ),
      searchEmptyStateSubtitleColor: Color.lerp(
        searchEmptyStateSubtitleColor,
        other.searchEmptyStateSubtitleColor,
        t,
      ),
      searchErrorStateTextStyle: TextStyle.lerp(
        searchErrorStateTextStyle,
        other.searchErrorStateTextStyle,
        t,
      ),
      searchErrorStateTextColor: Color.lerp(
        searchErrorStateTextColor,
        other.searchErrorStateTextColor,
        t,
      ),
      searchErrorStateSubtitleStyle: TextStyle.lerp(
        searchErrorStateSubtitleStyle,
        other.searchErrorStateSubtitleStyle,
        t,
      ),
      searchErrorStateSubtitleColor: Color.lerp(
        searchErrorStateSubtitleColor,
        other.searchErrorStateSubtitleColor,
        t,
      ),
      searchSeeMoreStyle: TextStyle.lerp(
        searchSeeMoreStyle,
        other.searchSeeMoreStyle,
        t,
      ),
      searchSeeMoreColor: Color.lerp(
        searchSeeMoreColor,
        other.searchSeeMoreColor,
        t,
      ),
      searchMessageItemBackgroundColor: Color.lerp(
        searchMessageItemBackgroundColor,
        other.searchMessageItemBackgroundColor,
        t,
      ),
      searchMessageTitleTextStyle: TextStyle.lerp(
        searchMessageTitleTextStyle,
        other.searchMessageTitleTextStyle,
        t,
      ),
      searchMessageTitleTextColor: Color.lerp(
        searchMessageTitleTextColor,
        other.searchMessageTitleTextColor,
        t,
      ),
      searchMessageSubTitleTextStyle: TextStyle.lerp(
        searchMessageSubTitleTextStyle,
        other.searchMessageSubTitleTextStyle,
        t,
      ),
      searchMessageSubTitleTextColor: Color.lerp(
        searchMessageSubTitleTextColor,
        other.searchMessageSubTitleTextColor,
        t,
      ),
      searchMessageTimeStampStyle:
          searchMessageTimeStampStyle?.lerp(
            other.searchMessageTimeStampStyle,
            t,
          ) ??
          other.searchMessageTimeStampStyle,
      searchMessageDateSeparatorStyle:
          searchMessageDateSeparatorStyle?.lerp(
            other.searchMessageDateSeparatorStyle,
            t,
          ) ??
          other.searchMessageDateSeparatorStyle,
    );
  }
}
