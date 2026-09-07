import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The transient dark-pill toast used by the thread-subscription surfaces
/// ("You won't/'ll be notified about new replies.", failure copy).
///
/// Unlike a [SnackBar] — which anchors to the window — this centers itself
/// within the **panel that triggered it**: the nearest enclosing [Scaffold]
/// (the right-hand chat/thread panel in a web side-by-side layout, the full
/// screen on mobile), falling back to the calling widget's own bounds. It
/// floats above the composer area, matching the design's toast pill.
///
/// This class is internal to the kit.
///
/// @nodoc
class CometChatThreadToast {
  CometChatThreadToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Bottom clearance so the pill sits above the message composer.
  static const double _bottomClearance = 88;

  static void show(BuildContext context, String text) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final overlayRender = overlay.context.findRenderObject();
    if (overlayRender is! RenderBox || !overlayRender.hasSize) return;

    // Panel bounds: the nearest Scaffold when one encloses the trigger,
    // otherwise the triggering widget itself, otherwise the whole overlay.
    RenderBox? panel;
    final scaffoldContext = Scaffold.maybeOf(context)?.context;
    final scaffoldRender = scaffoldContext?.findRenderObject();
    if (scaffoldRender is RenderBox && scaffoldRender.hasSize) {
      panel = scaffoldRender;
    } else {
      final own = context.findRenderObject();
      if (own is RenderBox && own.hasSize) panel = own;
    }

    final Rect rect = panel != null
        ? MatrixUtils.transformRect(
            panel.getTransformTo(overlayRender),
            Offset.zero & panel.size,
          )
        : Offset.zero & overlayRender.size;

    // Replace any toast already showing (rapid toggles).
    _timer?.cancel();
    if (_entry?.mounted ?? false) _entry?.remove();
    _entry = null;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: rect.left,
        width: rect.width,
        bottom: (overlayRender.size.height - rect.bottom) + _bottomClearance,
        child: IgnorePointer(
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: math.min(400, math.max(0, rect.width - 32)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE6212121),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(seconds: 2), () {
      if (_entry == entry && entry.mounted) entry.remove();
      if (_entry == entry) _entry = null;
    });
  }
}
