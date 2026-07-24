import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

int _viewIdCounter = 0;

/// A native HTML5 `<video controls>` element hosted in an [HtmlElementView].
/// Used on web instead of `video_player`: a plain video element plays
/// cross-origin CDN sources (and `blob:` URLs for staged files) without the
/// CORS requirement `video_player`'s web plugin imposes via `crossOrigin`.
///
/// Uses `package:web` + `dart:js_interop` (WASM-compatible).
Widget? buildWebVideoPlayer(String url) {
  final viewType = 'cometchat-web-video-${_viewIdCounter++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final video = web.document.createElement('video') as web.HTMLVideoElement
      ..src = url
      ..controls = true
      ..autoplay = false;
    video.style
      ..width = '100%'
      ..height = '100%'
      ..border = 'none'
      ..backgroundColor = 'black';
    // Play inline on mobile browsers instead of forcing native fullscreen.
    video.setAttribute('playsinline', 'true');
    return video;
  });
  return HtmlElementView(viewType: viewType);
}

/// A static, non-interactive video frame for a small square thumbnail (e.g.
/// the attachment tray's staged-video tile) — a plain `<video>` element with
/// no controls, muted and not autoplaying. Browsers paint the first frame
/// once metadata loads, giving a real poster with no extra JS. `object-fit:
/// cover` matches the `BoxFit.cover` every other thumbnail in the tray uses.
Widget? buildWebVideoThumb(String url) {
  final viewType = 'cometchat-web-video-thumb-${_viewIdCounter++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final video = web.document.createElement('video') as web.HTMLVideoElement
      ..src = url
      ..controls = false
      ..autoplay = false
      ..muted = true
      ..preload = 'metadata';
    video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..border = 'none';
    video.setAttribute('playsinline', 'true');
    return video;
  });
  return HtmlElementView(viewType: viewType);
}
