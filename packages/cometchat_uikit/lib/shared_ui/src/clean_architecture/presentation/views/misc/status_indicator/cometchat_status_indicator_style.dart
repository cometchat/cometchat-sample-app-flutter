import '../../../../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[CometChatStatusIndicatorStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatStatusIndicator]
///``` dart
///CometChatStatusIndicatorStyle(
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.white, width: 0),
/// );
/// ```
class CometChatStatusIndicatorStyle
    extends ThemeExtension<CometChatStatusIndicatorStyle> {
  const CometChatStatusIndicatorStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  ///[backgroundColor] background color of the status indicator
  final Color? backgroundColor;

  ///[border] border of the status indicator
  final Border? border;

  ///[borderRadius] border radius of the status indicator
  final BorderRadiusGeometry? borderRadius;

  static CometChatStatusIndicatorStyle of(BuildContext context) =>
      const CometChatStatusIndicatorStyle();

  @override
  CometChatStatusIndicatorStyle copyWith({
    Color? backgroundColor,
    Border? border,
    BorderRadiusGeometry? borderRadius,
  }) {
    return CometChatStatusIndicatorStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  CometChatStatusIndicatorStyle merge(CometChatStatusIndicatorStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
    );
  }

  @override
  CometChatStatusIndicatorStyle lerp(
      ThemeExtension<CometChatStatusIndicatorStyle>? other, double t) {
    if (other is! CometChatStatusIndicatorStyle) {
      return this;
    }
    return CometChatStatusIndicatorStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
    );
  }
}
