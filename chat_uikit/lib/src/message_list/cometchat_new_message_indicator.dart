import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'cometchat_new_message_indicator_style.dart';

/// [CometChatNewMessageIndicator] is a widget that displays a visual separator
/// for unread messages in the message list.
///
/// It shows a horizontal line with centered text indicating new messages.
///
/// ```dart
/// CometChatNewMessageIndicator(
///   style: CometChatNewMessageIndicatorStyle(
///     textColor: Colors.blue,
///     dividerColor: Colors.grey,
///   ),
///   text: 'New Messages',
/// )
/// ```
class CometChatNewMessageIndicator extends StatelessWidget {
  const CometChatNewMessageIndicator({
    super.key,
    this.style,
    this.text,
  });

  /// [style] defines the styling properties for the indicator
  final CometChatNewMessageIndicatorStyle? style;

  /// [text] defines the text to display in the indicator
  /// Defaults to localized "New Messages" text
  final String? text;

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    final indicatorColor = style?.dividerColor ?? colorPalette.error;
    final textColor = style?.textColor ?? colorPalette.error;

    return Container(
      width: double.infinity,
      color: style?.backgroundColor ?? Colors.transparent,
      padding: EdgeInsets.symmetric(
        vertical: spacing.padding2 ?? 8,
        horizontal: spacing.padding3 ?? 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: indicatorColor,
              thickness: 1,
              height: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 8),
            child: Text(
              text ?? Translations.of(context).newMessagesIndicator,
              style: TextStyle(
                color: textColor,
                fontSize: typography.caption1?.regular?.fontSize,
                fontWeight: typography.caption1?.regular?.fontWeight,
              ).merge(style?.textStyle),
            ),
          ),
          Expanded(
            child: Divider(
              color: indicatorColor,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
