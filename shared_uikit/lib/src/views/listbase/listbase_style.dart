import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[ListBaseStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatListBase]
class ListBaseStyle extends BaseStyles {
  const ListBaseStyle({
    this.titleStyle,
    this.searchTextStyle,
    this.searchPlaceholderStyle,
    this.searchBoxBackground,
    this.backIconTint,
    this.searchIconTint,
    this.padding,
    this.borderSide,
    this.searchTextFieldRadius,
    this.appBarShape,
    this.appBarBackground,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  ///[titleStyle] TextStyle for tvTitle
  final TextStyle? titleStyle;

  ///[searchTextStyle] TextStyle for search text
  final TextStyle? searchTextStyle;

  ///[searchBoxBackground] background color for search box
  final Color? searchBoxBackground;

  ///[searchPlaceholderStyle] TextStyle for search hint/placeholder text
  final TextStyle? searchPlaceholderStyle;

  ///[searchIconTint] color for search icon
  final Color? searchIconTint;

  ///[backIconTint] color for back icon
  final Color? backIconTint;

  ///[padding] surrounds the cometchat list base
  final EdgeInsetsGeometry? padding;

  ///[borderSide] border for search box
  final BorderSide? borderSide;

  ///[searchTextFieldRadius] search box radius
  final BorderRadius? searchTextFieldRadius;

  ///[appBarShape] to specify appbar shape
  final ShapeBorder? appBarShape;

  ///[appBarBackground] provides background color to the appbar
  final Color? appBarBackground;

}
