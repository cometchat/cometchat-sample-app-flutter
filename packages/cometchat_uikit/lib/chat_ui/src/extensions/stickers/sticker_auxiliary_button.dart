import 'package:flutter/material.dart';

import '../../../../cometchat_chat_uikit.dart';

///[StickerAuxiliaryButton] is the widget that represents the [StickersExtension]
///in the auxiliary button view of the [CometChatMessageComposer].
///
///Always shows the sticker icon. When the sticker panel is open the icon is
///tinted with the primary (purple) colour; otherwise it uses the secondary tint.
///Tapping toggles the sticker panel open/closed.
class StickerAuxiliaryButton extends StatefulWidget {
  const StickerAuxiliaryButton({
    super.key,
    this.keyboardButtonIcon,
    this.stickerButtonIcon,
    this.onKeyboardTap,
    this.onStickerTap,
    this.stickerIconTint,
    this.keyboardIconTint,
  });

  ///[stickerButtonIcon] custom icon widget for the sticker button
  final Widget? stickerButtonIcon;

  ///[keyboardButtonIcon] kept for API compatibility (unused)
  final Widget? keyboardButtonIcon;

  ///[onStickerTap] called when the button is tapped while the panel is closed
  final Function()? onStickerTap;

  ///[onKeyboardTap] called when the button is tapped while the panel is open
  final Function()? onKeyboardTap;

  ///[stickerIconTint] colour override for the inactive state
  final Color? stickerIconTint;

  ///[keyboardIconTint] colour override for the active state
  final Color? keyboardIconTint;

  @override
  State<StickerAuxiliaryButton> createState() => _StickerAuxiliaryButtonState();
}

class _StickerAuxiliaryButtonState extends State<StickerAuxiliaryButton>
    with CometChatUIEventListener {
  /// true = sticker panel is closed (default), false = sticker panel is open
  bool _isStickerPanelClosed = true;

  late String _listenerId;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;
  void initState() {
    super.initState();
    _listenerId = "StickerAuxiliaryButtonListener";
    CometChatUIEvents.addUiListener(_listenerId, this);
  }

  @override
  void dispose() {
    CometChatUIEvents.removeUiListener(_listenerId);
    super.dispose();
  }

  @override
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    if (uiPosition == CustomUIPosition.composerBottom &&
        !_isStickerPanelClosed) {
      setState(() {
        _isStickerPanelClosed = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color inactiveColor =
        widget.stickerIconTint ?? colorPalette.iconSecondary ?? Colors.grey;
    final Color activeColor =
        widget.keyboardIconTint ?? colorPalette.primary ?? Colors.purple;

    // Outlined icon when inactive, filled icon when active
    final Widget icon = widget.stickerButtonIcon ??
        Image.asset(
          _isStickerPanelClosed
              ? AssetConstants.smile
              : AssetConstants.stickerFilled,
          package: UIConstants.packageName,
          height: 24,
          width: 24,
          color: _isStickerPanelClosed ? inactiveColor : activeColor,
        );

    return SizedBox(
      height: 24,
      width: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          if (_isStickerPanelClosed) {
            widget.onStickerTap?.call();
            setState(() => _isStickerPanelClosed = false);
          } else {
            widget.onKeyboardTap?.call();
            setState(() => _isStickerPanelClosed = true);
          }
        },
        icon: icon,
      ),
    );
  }
}
