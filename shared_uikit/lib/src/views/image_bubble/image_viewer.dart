import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter_image/network.dart';
import 'dart:math';

///Gives Full Screen image view for passed image url
class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.imageUrl,
    this.placeholderImage,
    this.placeHolderImagePackageName,
  });

  ///[imageUrl] image url should be passed
  final String imageUrl;

  ///[placeholderImage] is shown temporarily for the duration when image is loading from url
  final String? placeholderImage;

  ///[placeHolderImagePackageName] is package path for the custom placeholder image
  final String? placeHolderImagePackageName;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Key imageKey = UniqueKey();
  double _currentScale = 1.0;
  bool _isZoomed = false;
  bool _isLoading = true; // Track loading state

  late CometChatImageBubbleStyle imageBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    // Start with loading state for network images
    if (!_isLocalFile) {
      _isLoading = true;
      // Set a timer to hide loading after a reasonable time
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      _isLoading = false;
    }
  }

  @override
  void didChangeDependencies() {
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    super.didChangeDependencies();
  }

  bool get _isLocalFile {
    return FileUtils.isLocalFileAvailable(widget.imageUrl);
  }

  bool get _isGif => widget.imageUrl.toLowerCase().endsWith('.gif');

  /// Check if the image is SVG format (not natively supported)
  bool get _isSvg {
    final lowerUrl = widget.imageUrl.toLowerCase();
    // Check for .svg extension or /svg in path (e.g., dicebear URLs like /svg?seed=...)
    return lowerUrl.endsWith('.svg') || 
           lowerUrl.contains('/svg?') || 
           lowerUrl.contains('/svg/');
  }

  /// Check if the image is HEIC/HEIF format (not natively supported)
  bool get _isHeicOrHeif {
    final lowerUrl = widget.imageUrl.toLowerCase();
    return lowerUrl.endsWith('.heic') || lowerUrl.endsWith('.heif');
  }

  /// Check if the image format is unsupported
  bool get _isUnsupportedFormat => _isSvg || _isHeicOrHeif;

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    // Show placeholder for unsupported formats
    if (_isUnsupportedFormat) {
      return Scaffold(
        backgroundColor: colorPalette.background1,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorPalette.background1,
          iconTheme: IconThemeData(color: colorPalette.iconPrimary),
        ),
        body: Center(
          child: _buildPlaceholderImage(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorPalette.background1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorPalette.background1,
        iconTheme: IconThemeData(color: colorPalette.iconPrimary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.1,
              maxScale: _isGif ? 2.5 : 4.0,
              onInteractionEnd: (ScaleEndDetails details) {
                // Only update state when interaction ends for smoother performance
                final newZoomed = _currentScale > 1.1;
                if (_isZoomed != newZoomed) {
                  setState(() {
                    _isZoomed = newZoomed;
                  });
                }
              },
              onInteractionUpdate: (ScaleUpdateDetails details) {
                _currentScale = details.scale;
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _isLocalFile
                    ? Image.file(
                        File(widget.imageUrl),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                        cacheHeight: 512,
                        cacheWidth: 512,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded || frame != null) {
                            // Image loaded successfully
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && _isLoading) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            });
                          }
                          return child;
                        },
                      )
                    : _isGif
                        ? Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted && _isLoading) {
                                    setState(() => _isLoading = false);
                                  }
                                });
                                return child;
                              }
                              return Container(
                                color: colorPalette.background1
                                    ?.withValues(alpha: 0.8),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colorPalette.iconSecondary ??
                                        Colors.grey,
                                    backgroundColor: colorPalette.neutral300
                                        ?.withValues(alpha: 0.3),
                                    strokeWidth: 3.0,
                                  ),
                                ),
                              );
                            },
                          )
                        : FadeInImage(
                            key: imageKey,
                            placeholder: AssetImage(
                              widget.placeholderImage ??
                                  AssetConstants.imagePlaceholder,
                              package: widget.placeHolderImagePackageName ??
                                  UIConstants.packageName,
                            ),
                            fit: BoxFit.contain,
                            placeholderFit: BoxFit.contain,
                            imageErrorBuilder: (context, object, stackTrace) {
                              // Set loading to false on error
                              if (_isLoading) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              }
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLoading =
                                              true; // Reset loading state for retry
                                          imageCache.evict(
                                            NetworkImageWithRetry(
                                                widget.imageUrl),
                                          );
                                          imageKey = ValueKey(widget.imageUrl +
                                              DateTime.now().toString());
                                        });
                                        // Set timer again for retry
                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        });
                                      },
                                      icon: Image.asset(
                                        AssetConstants.refreshIcon,
                                        height: 24,
                                        width: 24,
                                        package: UIConstants.packageName,
                                        color: colorPalette.iconPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            image: NetworkImageWithRetry(
                              widget.imageUrl,
                              fetchStrategy:
                                  (Uri uri, FetchFailure? failure) async {
                                const int maxAttempts = 7;
                                const int baseDelaySeconds = 1;
                                if (failure == null) {
                                  return FetchInstructions.attempt(
                                    uri: uri,
                                    timeout: const Duration(seconds: 10),
                                  );
                                } else if (failure.attemptCount < maxAttempts) {
                                  final int delaySeconds = (baseDelaySeconds *
                                          pow(2, failure.attemptCount - 1))
                                      .toInt();
                                  await Future.delayed(
                                      Duration(seconds: delaySeconds));
                                  return FetchInstructions.attempt(
                                    uri: uri,
                                    timeout:
                                        Duration(seconds: 10 + delaySeconds),
                                  );
                                } else {
                                  return FetchInstructions.giveUp(uri: uri);
                                }
                              },
                            ),
                            fadeInDuration: const Duration(milliseconds: 300),
                          ),
              ),
            ),
            // Circular progress indicator overlay
            if (_isLoading)
              Container(
                color: colorPalette.background1?.withValues(alpha: 0.8),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorPalette.iconSecondary ?? Colors.grey,
                    backgroundColor:
                        colorPalette.neutral300?.withValues(alpha: 0.3),
                    strokeWidth: 3.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: colorPalette.background3,
      alignment: Alignment.center,
      child: Image(
          fit: BoxFit.contain,
          color: colorPalette.iconTertiary,
          image: AssetImage(
            widget.placeholderImage ?? AssetConstants.imagePlaceholder,
            package:
                widget.placeHolderImagePackageName ?? UIConstants.packageName,
          )),
    );
  }
}
