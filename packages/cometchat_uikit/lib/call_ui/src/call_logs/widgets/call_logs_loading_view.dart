import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';

/// A widget that displays the loading state for the call logs list.
///
/// This widget renders a shimmer effect with placeholder items while
/// call logs are being fetched. It supports custom loading views
/// through the [customView] parameter.
///
/// The shimmer effect displays 30 placeholder items, each consisting of:
/// - A circular avatar placeholder
/// - A title bar placeholder
/// - A subtitle bar placeholder
/// - A trailing icon placeholder
class CallLogsLoadingView extends StatelessWidget {
  const CallLogsLoadingView({
    super.key,
    this.customView,
    this.colorPalette,
    this.spacing,
    this.typography,
  });

  /// Optional custom view builder to override the default loading view.
  /// When provided, this view will be rendered instead of the shimmer effect.
  final WidgetBuilder? customView;

  /// The color palette used for styling the shimmer effect.
  /// If not provided, will be looked up from context.
  final CometChatColorPalette? colorPalette;

  /// The spacing configuration for padding and margins.
  /// If not provided, will be looked up from context.
  final CometChatSpacing? spacing;

  /// The typography configuration (kept for consistency).
  /// If not provided, will be looked up from context.
  final CometChatTypography? typography;

  @override
  Widget build(BuildContext context) {
    // If a custom view is provided, render it instead
    if (customView != null) {
      return customView!(context);
    }

    // Use provided values or fallback to context lookup
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);

    // Default shimmer loading view
    return CometChatShimmerEffect(
      colorPalette: effectiveColorPalette,
      child: ListView.builder(
        itemCount: 30,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: effectiveSpacing.padding4 ?? 0,
              vertical: effectiveSpacing.padding3 ?? 0,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: effectiveSpacing.padding3 ?? 0,
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer bar
                    Container(
                      height: 22.0,
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          effectiveSpacing.radius2 ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Subtitle shimmer bar
                    Container(
                      height: 12.0,
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          effectiveSpacing.radius2 ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: effectiveSpacing.padding3 ?? 0,
                  ),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(
                        effectiveSpacing.radius2 ?? 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
