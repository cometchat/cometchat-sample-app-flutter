import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatBadge] is a widget to display a small amount of information about its a component like a count or status
/// ```dart
///       CometChatBadge(
///          count: 1,
///          style: BadgeStyle(
///            background: Colors.teal,
///          ),
///        );
/// ```
class CometChatBadge extends StatelessWidget {
  /// Creates a widget that that gives  date UI.
  const CometChatBadge({
    super.key,
    required this.count,
    this.style = const CometChatBadgeStyle(),
    this.width,
    this.height,
    this.padding,
  });

  ///[count] shows the value inside badge if less then 0 then only size box will be displayed
  ///if [count] > 999 the 999+ will be displayed
  final int count;

  ///[style] contains properties that affects the appearance of this widget
  final CometChatBadgeStyle style;

  ///[width] provides width to the widget
  final double? width;

  ///[height] provides height to the widget
  final double? height;

  /// [padding] provides padding to the widget
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    debugPrint('🔢 [CometChatBadge] build called with count: $count');
    final badgeStyle = CometChatThemeHelper.getTheme<CometChatBadgeStyle>(
            context: context, defaultTheme: CometChatBadgeStyle.of)
        .merge(style);
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return count > 0
        ? Container(
            height: height ?? 16,
            width: width ?? ((count < 10) ? 16 : null),
            padding: padding ??
                EdgeInsets.symmetric(
                  vertical: spacing.padding ?? 0,
                  horizontal: spacing.padding1 ?? 0,
                ),
            decoration: BoxDecoration(
              shape: (badgeStyle.borderRadius == null)
                  ? badgeStyle.boxShape ?? ((count <= 9) ? BoxShape.circle : BoxShape.rectangle):BoxShape.rectangle,
              borderRadius: (badgeStyle.borderRadius != null)
                  ? badgeStyle.borderRadius
                  : (count <= 9)
                      ? null
                      : BorderRadius.all(
                          Radius.circular(
                            spacing.radius5 ?? 0,
                          ),
                        ),
              border: badgeStyle.border,
              color: badgeStyle.backgroundColor ?? colorPalette.primary,
            ),
            child: FittedBox(
              child: Text(
                "${count <= 999 ? count : '999+'}",
                style: TextStyle(
                  color: badgeStyle.textColor ?? colorPalette.buttonIconColor,
                  fontSize: typography.caption1?.regular?.fontSize,
                  fontWeight: typography.caption1?.regular?.fontWeight,
                  fontFamily: typography.caption1?.regular?.fontFamily,
                )
                    .merge(
                      badgeStyle.textStyle,
                    )
                    .copyWith(
                      color: badgeStyle.textColor,
                    ),
              ),
            ),
          )
        : const SizedBox();
  }
}
