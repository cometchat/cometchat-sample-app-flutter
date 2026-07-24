import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../../../core/utils/platform_utils/platform_file_utils.dart'
    as platform_file;
import '../../../../core/utils/platform_utils/web_video.dart' as web_video;

/// A video's real first frame, used as a client-generated poster wherever the
/// server's thumbnail-generation extension produced nothing (it fails with
/// ERR_FILETYPE_NOT_SUPPORTED for some formats, e.g. iPhone .mov/HEVC). The
/// other UIKit platforms paint a client-side poster in that case — web via a
/// native `<video>` element, Android via a thumbnail extractor — so this
/// closes the same gap for Flutter without new dependencies.
///
/// [source] may be an http(s) URL, a `blob:` object URL (web staging), or a
/// local file path (native staging). Rendering:
///   • web    → a controls-less, muted `<video preload=metadata>` element —
///              browsers paint the first frame once metadata loads
///   • native → a paused [vp.VideoPlayerController] (network or file),
///              cropped to [BoxFit.cover] like every other thumbnail
/// [fallback] shows while loading and on any failure.
class CometChatVideoFirstFrame extends StatefulWidget {
  const CometChatVideoFirstFrame({
    super.key,
    required this.source,
    required this.fallback,
    this.onFailed,
  });

  final String source;
  final Widget fallback;

  /// Called once when the video can't be loaded (controller init failed, or no
  /// controller could be built). Since the grid poster and the fullscreen
  /// player use the same controller/URL, a failure here means the video is
  /// unplayable everywhere — the grid uses this to swap the play tile for the
  /// "no preview" glyph, matching what the viewer shows.
  final VoidCallback? onFailed;

  @override
  State<CometChatVideoFirstFrame> createState() =>
      _CometChatVideoFirstFrameState();
}

class _CometChatVideoFirstFrameState extends State<CometChatVideoFirstFrame> {
  vp.VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  Widget? _webThumb;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    // Web: a plain <video> element paints its own first frame — no
    // controller/initialize() round trip needed.
    _webThumb = web_video.buildWebVideoThumb(widget.source);
    if (_webThumb != null) return;

    final src = widget.source;
    final vp.VideoPlayerController? c = src.startsWith('http')
        ? vp.VideoPlayerController.networkUrl(Uri.parse(src))
        : platform_file.videoControllerForPath(src);
    if (c == null) {
      _failed = true;
      if (widget.onFailed != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onFailed?.call(),
        );
      }
      return;
    }
    _controller = c;
    c
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _failed = true);
          widget.onFailed?.call();
        });
  }

  @override
  void didUpdateWidget(CometChatVideoFirstFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _controller?.dispose();
      _controller = null;
      _ready = false;
      _failed = false;
      _webThumb = null;
      _init();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_webThumb != null) return _webThumb!;
    if (_failed) return widget.fallback;
    final c = _controller;
    if (!_ready || c == null) return widget.fallback;
    // Crop the video's intrinsic size to fill the cell, matching the
    // BoxFit.cover every other thumbnail uses.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: vp.VideoPlayer(c),
        ),
      ),
    );
  }
}
