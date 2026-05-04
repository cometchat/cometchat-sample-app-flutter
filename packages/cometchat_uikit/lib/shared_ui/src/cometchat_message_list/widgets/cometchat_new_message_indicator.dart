import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

import 'cometchat_new_message_indicator_style.dart';

/// A horizontal divider with centered "New Messages" text.
///
/// Rendered above the first unread message in the message list when
/// `startFromUnreadMessages` is enabled or the user marks a message as unread.
///
/// Default colors use `colorPalette.error` for both divider and text.
class CometChatNewMessageIndicator extends StatelessWidget {
  /// Optional style overrides
  final CometChatNewMessageIndicatorStyle? style;

  /// Override text (defaults to localized "New Messages")
  final String? text;

  /// Pre-cached color palette (avoids InheritedWidget lookup)
  final CometChatColorPalette? colorPalette;

  /// Pre-cached typography (avoids InheritedWidget lookup)
  final CometChatTypography? typography;

  /// Pre-cached spacing (avoids InheritedWidget lookup)
  final CometChatSpacing? spacing;

  const CometChatNewMessageIndicator({
    super.key,
    this.style,
    this.text,
    this.colorPalette,
    this.typography,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final palette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final typo = typography ?? CometChatThemeHelper.getTypography(context);
    final sp = spacing ?? CometChatThemeHelper.getSpacing(context);

    final dividerColor = style?.dividerColor ?? palette.error;
    final txtColor = style?.textColor ?? palette.error;
    final bgColor = style?.backgroundColor ?? Colors.transparent;
    final label = text ?? Translations.of(context).newMessages;

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(
        vertical: sp.padding2 ?? 8,
        horizontal: sp.padding3 ?? 12,
      ),
      child: Semantics(
        label: label,
        child: Row(
          children: [
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sp.padding2 ?? 8),
              child: Text(
                label,
                style: TextStyle(
                  color: txtColor,
                  fontSize: typo.caption1?.regular?.fontSize ?? 12,
                  fontWeight: typo.caption1?.regular?.fontWeight,
                ).merge(style?.textStyle),
              ),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
          ],
        ),
      ),
    );
  }
}
