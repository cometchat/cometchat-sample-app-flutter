import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../clean_architecture.dart';

/// The UIKit's standard media placeholder — the same look the legacy
/// `CometChatImageBubble` ships: a `background3` fill with the bundled
/// placeholder glyph (`AssetConstants.imagePlaceholder`) tinted
/// `iconTertiary`, or the legacy loading spinner while bytes arrive.
///
/// Shared by the media grid, the fullscreen viewer and the composer tray so
/// an image/video with nothing to show falls back to the exact same art on
/// every surface (single- and multi-attachment alike).
class CometChatMediaPlaceholder extends StatelessWidget {
  const CometChatMediaPlaceholder({
    super.key,
    this.backgroundColor,
    this.tintColor,
    this.glyphWidth = 32,
    this.loading = false,
    this.unsupported = false,
  });

  /// Fill behind the glyph — defaults to the palette's `background3`
  /// (override with e.g. a bubble style's `placeholderColor`).
  final Color? backgroundColor;

  /// Tint of the placeholder glyph — defaults to `iconTertiary`.
  final Color? tintColor;

  /// Width of the glyph / diameter of the loading spinner.
  final double glyphWidth;

  /// True renders the legacy loading spinner instead of the glyph.
  final bool loading;

  /// True renders the "no preview available" doc-slash glyph
  /// ([kAttachmentUnsupportedIconAsset]) instead of the standard image
  /// placeholder — used when a media cell can't be previewed (render failure or
  /// a type mismatch). Ignored while [loading]. The glyph is self-coloured, so
  /// [tintColor] does not apply to it.
  final bool unsupported;

  @override
  Widget build(BuildContext context) {
    final colors = CometChatThemeHelper.getColorPalette(context);
    return Container(
      color: backgroundColor ?? colors.background3,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: glyphWidth,
              height: glyphWidth,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colors.iconSecondary,
              ),
            )
          : unsupported
          ? SvgPicture.asset(
              kAttachmentUnsupportedIconAsset,
              package: kAttachmentIconPackage,
              width: glyphWidth,
              fit: BoxFit.contain,
            )
          : Image(
              width: glyphWidth,
              fit: BoxFit.contain,
              color: tintColor ?? colors.iconTertiary,
              image: const AssetImage(
                AssetConstants.imagePlaceholder,
                package: UIConstants.packageName,
              ),
            ),
    );
  }
}
