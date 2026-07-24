import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';
import '../../../../cometchat_chat_uikit.dart' as cc;
import '../cometchat_call_logs/call_logs_style.dart';

/// A widget that displays the empty state for the call logs list.
///
/// This widget renders the empty state UI when there are no call logs
/// to display. It shows an icon, a title text ("No call logs yet"),
/// and a subtitle text prompting the user to make or receive calls.
///
/// The widget supports custom empty views through the [customView] parameter.
/// When provided, the custom view will be rendered instead of the default UI.
class CallLogsEmptyView extends StatelessWidget {
  const CallLogsEmptyView({
    super.key,
    this.customView,
    this.style,
    this.colorPalette,
    this.spacing,
    this.typography,
  });

  /// Optional custom view builder to override the default empty view.
  /// When provided, this view will be rendered instead of the default empty state UI.
  final WidgetBuilder? customView;

  /// The style configuration for the call logs widget.
  /// Used to apply custom text styles and colors for the empty state.
  /// If not provided, will use default styling.
  final CometChatCallLogsStyle? style;

  /// The color palette used for styling text colors.
  /// If not provided, will be looked up from context.
  final CometChatColorPalette? colorPalette;

  /// The spacing configuration for padding and margins.
  /// If not provided, will be looked up from context.
  final CometChatSpacing? spacing;

  /// The typography configuration for text styles.
  /// If not provided, will be looked up from context.
  final CometChatTypography? typography;

  @override
  Widget build(BuildContext context) {
    // If a custom view is provided, render it instead
    if (customView != null) {
      return Center(child: customView!(context));
    }

    // Use provided values or fallback to context lookup
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);
    final effectiveStyle = style ?? CometChatCallLogsStyle.of(context);

    // Default empty state view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call, color: effectiveColorPalette.neutral300, size: 100),
          Padding(
            padding: EdgeInsets.only(
              top: effectiveSpacing.padding5 ?? 20,
              bottom: effectiveSpacing.padding ?? 2,
            ),
            child: Text(
              cc.Translations.of(context).noCallLogsYet,
              textAlign: TextAlign.center,
              style:
                  TextStyle(
                        color:
                            effectiveStyle.emptyStateTextColor ??
                            effectiveColorPalette.textPrimary,
                        fontSize: effectiveTypography.heading3?.bold?.fontSize,
                        fontWeight:
                            effectiveTypography.heading3?.bold?.fontWeight,
                        fontFamily:
                            effectiveTypography.heading3?.bold?.fontFamily,
                      )
                      .merge(effectiveStyle.emptyStateTextStyle)
                      .copyWith(color: effectiveStyle.emptyStateTextColor),
            ),
          ),
          Text(
            cc.Translations.of(context).makeOrReceiveCalls,
            textAlign: TextAlign.center,
            style:
                TextStyle(
                      color:
                          effectiveStyle.emptyStateSubTitleTextColor ??
                          effectiveColorPalette.textSecondary,
                      fontSize: effectiveTypography.heading3?.regular?.fontSize,
                      fontWeight:
                          effectiveTypography.heading3?.regular?.fontWeight,
                      fontFamily:
                          effectiveTypography.heading3?.regular?.fontFamily,
                    )
                    .merge(effectiveStyle.emptyStateSubTitleTextStyle)
                    .copyWith(
                      color: effectiveStyle.emptyStateSubTitleTextColor,
                    ),
          ),
        ],
      ),
    );
  }
}
