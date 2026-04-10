import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "../../../../clean_architecture.dart";
import 'image_viewer.dart';

///[CometChatImageBubble] creates a widget that gives image bubble
///
///used by default when the category and type of [MediaMessage] is message and [MessageTypeConstants.image] respectively
/// ```dart
///             CometChatImageBubble(
///                  imageUrl:
///                      'image url',
///                  style: const ImageBubbleStyle(
///                    borderRadius: 8,
///                    backgroundColor: Colors.white,
///                  ),
///                );
/// ```
class CometChatImageBubble extends StatefulWidget {
  const CometChatImageBubble({
    super.key,
    this.imageUrl,
    this.style,
    this.placeholderImage,
    this.placeHolderImagePackageName,
    this.onClick,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.metadata,
    this.colorPalette,
    this.spacing,
  });

  ///[imageUrl] image url should be passed
  final String? imageUrl;

  ///[style] manages appearance of this widget
  final CometChatImageBubbleStyle? style;

  ///[placeholderImage] is shown temporarily for the duration when image is loading from url
  final String? placeholderImage;

  ///[placeHolderImagePackageName] is package path for the custom placeholder image
  final String? placeHolderImagePackageName;

  ///[onClick] custom action on tapping the image
  final Function()? onClick;

  ///[width] width of the image bubble
  final double? width;

  ///[height] height of the image bubble
  final double? height;

  ///[padding] padding for the image bubble
  final EdgeInsetsGeometry? padding;

  ///[margin] margin for the image bubble
  final EdgeInsetsGeometry? margin;

  ///[metadata] metadata of the message object
  final Map<String, dynamic>? metadata;

  /// [colorPalette] optional pre-cached color palette to avoid expensive lookups during keyboard animation
  final CometChatColorPalette? colorPalette;

  /// [spacing] optional pre-cached spacing to avoid expensive lookups during keyboard animation
  final CometChatSpacing? spacing;

  @override
  State<CometChatImageBubble> createState() => _CometChatImageBubbleState();
}


class _CometChatImageBubbleState extends State<CometChatImageBubble> {
  late CometChatImageBubbleStyle imageBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize theme once to avoid expensive lookups during keyboard animation
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      imageBubbleStyle = CometChatThemeHelper.getTheme<CometChatImageBubbleStyle>(
              context: context, defaultTheme: CometChatImageBubbleStyle.of)
          .merge(widget.style);
      // Use passed values OR fallback to lookup (for standalone usage)
      colorPalette = widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);
      spacing = widget.spacing ?? CometChatThemeHelper.getSpacing(context);
      _themeInitialized = true;
    }
  }

  @override
  void didUpdateWidget(CometChatImageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update style if it changed
    if (widget.style != oldWidget.style) {
      imageBubbleStyle = CometChatThemeHelper.getTheme<CometChatImageBubbleStyle>(
              context: context, defaultTheme: CometChatImageBubbleStyle.of)
          .merge(widget.style);
    }
    // Update cached theme values if they changed
    if (widget.colorPalette != oldWidget.colorPalette && widget.colorPalette != null) {
      colorPalette = widget.colorPalette!;
    }
    if (widget.spacing != oldWidget.spacing && widget.spacing != null) {
      spacing = widget.spacing!;
    }
  }

  /// Check if the URL or path points to a GIF
  bool _isGif(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.gif') || lower.contains('.gif?');
  }

  /// Check if the image is HEIC/HEIF format
  bool _isHeicOrHeif(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.heic') || lowerUrl.endsWith('.heif');
  }

  /// Check if the image is SVG format
  bool _isSvg(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.svg') ||
        lowerUrl.contains('/svg?') ||
        lowerUrl.contains('/svg/');
  }

  /// Whether this message contains a GIF (either local or remote)
  bool get _messageIsGif {
    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    return _isGif(widget.imageUrl) || _isGif(localPath);
  }

  Widget _buildImage() {
    if (_isHeicOrHeif(widget.imageUrl)) {
      return _buildPlaceholderImage();
    }
    if (_isSvg(widget.imageUrl)) {
      return _buildPlaceholderImage();
    }

    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';

    if (_isHeicOrHeif(localPath)) {
      return _buildPlaceholderImage();
    }
    if (_isSvg(localPath)) {
      return _buildPlaceholderImage();
    }

    if (FileUtils.isLocalFileAvailable(localPath)) {
      return _buildLocalImage(localPath);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrl!);
    }
    return _buildPlaceholderImage();
  }

  Widget _buildLocalImage(String localPath) {
    return Image(
      image: ResizeImage(
        FileImage(File(localPath)),
        width: 512,
        height: 512,
        policy: ResizeImagePolicy.fit,
      ),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
          return _buildNetworkImage(widget.imageUrl!);
        }
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: 800,
      memCacheHeight: 800,
      filterQuality: FilterQuality.medium,
      placeholder: (context, url) => _buildLoadingIndicator(),
      errorWidget: (context, url, error) {
        debugPrint('CachedNetworkImage error: $error');
        return _buildPlaceholderImage();
      },
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPalette.iconSecondary,
        backgroundColor: colorPalette.neutral300,
        strokeWidth: 2.0,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      alignment: Alignment.center,
      child: Image(
        fit: BoxFit.contain,
        color: colorPalette.iconTertiary,
        image: AssetImage(
          widget.placeholderImage ?? AssetConstants.imagePlaceholder,
          package: widget.placeHolderImagePackageName ?? UIConstants.packageName,
        ),
      ),
    );
  }

  bool _isUnsupportedFormat() {
    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    return _isHeicOrHeif(widget.imageUrl) ||
        _isSvg(widget.imageUrl) ||
        _isHeicOrHeif(localPath) ||
        _isSvg(localPath);
  }

  @override
  Widget build(BuildContext context) {
    final bool showPlaceholder = _isUnsupportedFormat() ||
        (widget.imageUrl == null || widget.imageUrl!.isEmpty);

    final imageContent = Container(
      height: widget.height ?? 232,
      width: widget.width ?? 232,
      clipBehavior: Clip.hardEdge,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        border: imageBubbleStyle.border,
        borderRadius: imageBubbleStyle.borderRadius ??
            BorderRadius.circular(spacing.radius3 ?? 0),
        color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      ),
      child: _buildImage(),
    );

    // For GIFs, wrap in viewport-aware widget so animation only plays when visible
    final child = _messageIsGif && !showPlaceholder
        ? _ViewportAwareGif(
            childHeight: widget.height ?? 232,
            childWidth: widget.width ?? 232,
            child: imageContent,
          )
        : imageContent;

    return GestureDetector(
      onTap: showPlaceholder
          ? null
          : widget.onClick ??
              () {
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageUrl: widget.imageUrl!,
                        placeholderImage: widget.placeholderImage,
                        placeHolderImagePackageName:
                            widget.placeHolderImagePackageName,
                      ),
                    ),
                  );
                }
              },
      child: child,
    );
  }
}


/// Wraps a GIF image widget and only renders it when visible in the viewport.
/// When the GIF scrolls out of view, a static sized box with the same
/// background color is shown instead, preventing GIF frame decoding.
///
/// Flutter's GIF decoding uses a Timer (not a Ticker), so TickerMode
/// cannot pause it. The only reliable way to stop GIF animation is to
/// unmount the Image widget entirely.
class _ViewportAwareGif extends StatefulWidget {
  final Widget child;
  final double childHeight;
  final double childWidth;

  const _ViewportAwareGif({
    required this.child,
    required this.childHeight,
    required this.childWidth,
  });

  @override
  State<_ViewportAwareGif> createState() => _ViewportAwareGifState();
}

class _ViewportAwareGifState extends State<_ViewportAwareGif> {
  bool _isVisible = false;
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detachScroll();
    _attachScroll();
    // Check visibility after the frame is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  void _attachScroll() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollPosition = scrollable.position;
      _scrollPosition!.addListener(_onScroll);
    }
  }

  void _detachScroll() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
  }

  void _onScroll() {
    _checkVisibility();
  }

  void _checkVisibility() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) {
      // No viewport ancestor — assume visible
      if (!_isVisible) setState(() => _isVisible = true);
      return;
    }

    final offsetToReveal = viewport.getOffsetToReveal(renderObject, 0.0);
    final vpOffset = _scrollPosition?.pixels ?? 0.0;
    final vpExtent = _scrollPosition?.viewportDimension ?? 0.0;

    // The item's top edge relative to the viewport's scroll offset
    final itemTop = offsetToReveal.offset;
    final itemSize = renderObject.paintBounds.height;
    final itemBottom = itemTop + itemSize;

    // Visible if any part of the item overlaps the viewport
    final visible = itemBottom > vpOffset && itemTop < vpOffset + vpExtent;

    if (visible != _isVisible) {
      setState(() => _isVisible = visible);
    }
  }

  @override
  void dispose() {
    _detachScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When not visible, swap the child for an empty box of the same size.
    // This unmounts the Image widget, stopping GIF frame decoding.
    if (!_isVisible) {
      return SizedBox(
        height: widget.childHeight,
        width: widget.childWidth,
      );
    }
    return widget.child;
  }
}
