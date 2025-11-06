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

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
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
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.1,
          maxScale: 4.0,
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
          child: FadeInImage(
            key: imageKey,
            placeholder: AssetImage(
              widget.placeholderImage ?? AssetConstants.imagePlaceholder,
              package:
              widget.placeHolderImagePackageName ?? UIConstants.packageName,
            ),
            fit: BoxFit.contain,
            placeholderFit: BoxFit.contain,
            imageErrorBuilder: (context, object, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          imageCache.evict(
                            NetworkImageWithRetry(widget.imageUrl),
                          );
                          imageKey = ValueKey(
                              widget.imageUrl + DateTime.now().toString());
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
                fetchStrategy: (Uri uri, FetchFailure? failure) async {
                  const int maxAttempts = 7;
                  const int baseDelaySeconds = 1;
                  if (failure == null) {
                    return FetchInstructions.attempt(
                      uri: uri,
                      timeout: const Duration(seconds: 10),
                    );
                  } else if (failure.attemptCount < maxAttempts) {
                    final int delaySeconds =
                    (baseDelaySeconds * pow(2, failure.attemptCount - 1))
                        .toInt();
                    await Future.delayed(Duration(seconds: delaySeconds));
                    return FetchInstructions.attempt(
                      uri: uri,
                      timeout: Duration(seconds: 10 + delaySeconds),
                    );
                  } else {
                    return FetchInstructions.giveUp(uri: uri);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}