import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cometchat_cards/cometchat_cards.dart';

import '../../../../shared_ui/cometchat_uikit_shared.dart';
import '../../../../shared_ui/src/views/no_intrinsic_card_wrapper.dart';

/// Content view widget for developer card messages (category: "card").
///
/// Renders the raw card schema via [CometChatCardView] from the
/// `cometchat_cards` renderer package. Mirrors the notification-feed
/// card rendering pattern.
///
/// Handles:
/// - Normal render: getCard() → jsonEncode → CometChatCardView
/// - Null/empty card: shows getFallbackText() → getText() → "Card Message"
/// - Deleted message: handled at the template level (not here)
class CometChatCardBubble extends StatelessWidget {
  const CometChatCardBubble({
    super.key,
    required this.message,
    this.onCardAction,
    this.themeMode,
    this.themeOverride,
  });

  /// The [CardMessage] from the SDK (category: "card").
  final CardMessage message;

  /// Callback when the user taps an action within the card.
  /// Fires alongside the [CometChatUIEvents.ccCardActionClicked] event.
  final void Function(CardMessage message, CometChatCardActionEvent action)?
      onCardAction;

  /// Theme mode for the card renderer.
  /// If null, auto-detected from the current [Brightness].
  final CometChatCardThemeMode? themeMode;

  /// Theme override for the card renderer.
  final CometChatCardThemeOverride? themeOverride;

  @override
  Widget build(BuildContext context) {
    final cardData = message.getCard();

    // If card payload is null/empty, show fallback text
    if (cardData == null || cardData.isEmpty) {
      return _buildFallbackView(context);
    }

    // Resolve theme mode from platform brightness if not provided
    final resolvedThemeMode = themeMode ?? _resolveThemeMode(context);

    final String cardJson = jsonEncode(cardData);

    final cardWidth = MediaQuery.sizeOf(context).width * 0.65;

    return NoIntrinsicCardWrapper(
      width: cardWidth,
      child: CometChatCardView(
        cardJson: cardJson,
        themeMode: resolvedThemeMode,
        themeOverride: themeOverride,
        onAction: (CometChatCardActionEvent action) {
          // Fire the callback prop (for apps using the bubble directly)
          onCardAction?.call(message, action);

          // Emit the UI event (for global subscription — covers nested agent cards too)
          CometChatUIEvents.ccCardActionClicked(message, action);
        },
      ),
    );
  }

  /// Fallback view when getCard() is null/empty.
  /// Shows getFallbackText() → getText() → "Card Message".
  Widget _buildFallbackView(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    final fallbackText = message.getFallbackText() ??
        message.getText() ??
        Translations.of(context).cardMessage;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        fallbackText,
        style: TextStyle(
          color: colorPalette.textPrimary,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
        ),
      ),
    );
  }

  /// Resolves theme mode from the platform brightness.
  CometChatCardThemeMode _resolveThemeMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? CometChatCardThemeMode.dark
        : CometChatCardThemeMode.light;
  }
}
