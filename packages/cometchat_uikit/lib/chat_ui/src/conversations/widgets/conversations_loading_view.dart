import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';

/// A widget that displays the loading state for the conversations list.
///
/// This widget renders a shimmer effect with placeholder items while
/// conversations are being fetched. It supports custom loading views
/// through the [customView] parameter.
///
/// The shimmer effect displays 30 placeholder items, each consisting of:
/// - A circular avatar placeholder
/// - A title bar placeholder
/// - A timestamp placeholder
/// - A subtitle bar placeholder
class ConversationsLoadingView extends StatelessWidget {
  const ConversationsLoadingView({
    super.key,
    this.customView,
    required this.colorPalette,
    required this.spacing,
    required this.typography,
  });

  /// Optional custom view builder to override the default loading view.
  /// When provided, this view will be rendered instead of the shimmer effect.
  final WidgetBuilder? customView;

  /// The color palette used for styling the shimmer effect.
  final CometChatColorPalette colorPalette;

  /// The spacing configuration for padding and margins.
  final CometChatSpacing spacing;

  /// The typography configuration (currently unused but kept for consistency).
  final CometChatTypography typography;

  @override
  Widget build(BuildContext context) {
    // If a custom view is provided, render it instead
    if (customView != null) {
      return customView!(context);
    }

    // Default shimmer loading view
    return CometChatShimmerEffect(
      colorPalette: colorPalette,
      child: ListView.builder(
        itemCount: 30,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.padding4 ?? 0,
              vertical: spacing.padding3 ?? 0,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: spacing.padding3 ?? 0),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              height: 19.0,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  spacing.radius2 ?? 0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.padding2 ?? 8),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 19.0,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(
                                  spacing.radius2 ?? 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Subtitle shimmer bar
                      Container(
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            spacing.radius2 ?? 0,
                          ),
                        ),
                      ),
                    ],
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
