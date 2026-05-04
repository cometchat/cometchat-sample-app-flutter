import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[StickerConfiguration] is a data class that has configuration properties
///to customize the functionality and appearance of [StickersExtension]
///
/// ```dart
///
/// final stickerConfig = StickerConfiguration(
///   errorIcon: Icon(Icons.error),
///   emptyStateView: (context) => Text('No stickers available.'),
///   errorStateView: (context) => Text('Failed to load stickers.'),
///   loadingStateView: (context) => CircularProgressIndicator(),
///   errorStateText: 'Error fetching stickers',
///   emptyStateText: 'No stickers available',
///   stickerButtonIcon: Icon(Icons.sticky_note_2),
///   keyboardButtonIcon: Icon(Icons.keyboard),
///   stickerKeyboardStyle: StickerKeyboardStyle(),
///   stickerBubbleHeight: 100,
///   stickerBubbleWidth: 100,
/// );
///
/// ```
class StickerConfiguration {
  StickerConfiguration({
    this.errorIcon,
    this.emptyStateView,
    this.errorStateView,
    this.loadingStateView,
    this.errorStateText,
    this.emptyStateText,
    this.stickerButtonIcon,
    this.keyboardButtonIcon,
    this.stickerIconTint,
    this.keyboardIconTint,
    this.stickerBubbleHeight,
    this.stickerBubbleWidth,
    this.stickerUrl,
  });

  ///[stickerButtonIcon] shows stickers keyboard
  final Widget? stickerButtonIcon;

  ///[keyboardButtonIcon] hides stickers keyboard
  final Widget? keyboardButtonIcon;

  ///[errorIcon] icon to be shown in case of any error
  final Widget? errorIcon;

  ///[emptyStateView] to be shown when there are no stickers
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] to be shown when some error occurs on fetching the sticker
  final WidgetBuilder? errorStateView;

  ///[loadingStateView] view at loading state
  final WidgetBuilder? loadingStateView;

  ///[errorStateText] text to be show in error state
  final String? errorStateText;

  ///[emptyStateText] text to be shown at empty state
  final String? emptyStateText;

  ///[stickerIconTint] provides color to the sticker Icon/widget
  final Color? stickerIconTint;

  ///[keyboardIconTint] provides color to the keyboard Icon/widget
  final Color? keyboardIconTint;

  ///[stickerBubbleHeight] height of the sticker
  final double? stickerBubbleHeight;

  ///[stickerBubbleWidth] width of the sticker
  final double? stickerBubbleWidth;

  ///[stickerUrl] if message object is not passed then sticker url should be passed
  final String? stickerUrl;
}
