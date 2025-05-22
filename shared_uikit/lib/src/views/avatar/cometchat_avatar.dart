import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatAvatar] is a widget that gives a container for avatar images
/// ```dart
///        CometChatAvatar(
///        image: 'https://example.com/image.jpg',
///        name: 'John Doe',
///        cometchatAvatarStyle: CometChatAvatarStyle(),
///        width: 50,
///        height: 50,
///        padding: EdgeInsets.all(0),
///        );
/// ```
class CometChatAvatar extends StatelessWidget {
  const CometChatAvatar({
    super.key,
    this.image,
    this.name,
    this.style,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  ///[image] sets the image url  for the avatar ,  will be preferred over name
  final String? image;

  ///[name] only visible when [image] tag is not passed
  final String? name;

  ///[style] contains properties that affects the appearance of this widget
  final CometChatAvatarStyle? style;

  ///[width] provides width to the widget
  final double? width;

  ///[height] provides height to the widget
  final double? height;

  /// [padding] provides padding to the widget
  final EdgeInsetsGeometry? padding;

  /// [padding] provides margin to the widget
  final EdgeInsetsGeometry? margin;

  // Helper to safely extract initials (handles emojis & multi-byte chars)
  String _getInitials(String name) {
    List<String> parts = name.trim().split(RegExp(r'\s+'));

    String getFirstCharacter(String input) {
      Runes runes = input.runes;
      return runes.isNotEmpty ? String.fromCharCode(runes.first) : "";
    }

    if (parts.length >= 2) {
      return (getFirstCharacter(parts[0]) + getFirstCharacter(parts[1])).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      Runes runes = parts[0].runes;
      if (runes.length >= 2) {
        return String.fromCharCodes(runes.take(2)).toUpperCase();
      } else {
        return getFirstCharacter(parts[0]).toUpperCase();
      }
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    String url = "";
    String text = "AB";

    final avatarStyle = CometChatThemeHelper.getTheme<CometChatAvatarStyle>(
            context: context, defaultTheme: CometChatAvatarStyle.of)
        .merge(style);
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    //Check if Text should be visible or image
    if (image != null && image!.isNotEmpty) {
      url = image!;
    }
    if (name != null && name!.trim().isNotEmpty) {
      text = _getInitials(name ?? "");
    }

    return Container(
      margin: margin,
      padding: padding,
      width: width ?? 48,
      height: height ?? 48,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: avatarStyle.borderRadius ??
            BorderRadius.all(
              Radius.circular(
                spacing.radiusMax ?? 0,
              ),
            ),
        border: avatarStyle.border,
        color: avatarStyle.backgroundColor ?? colorPalette.extendedPrimary500,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(spacing.radiusMax ?? 0),
        ),
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) {
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: avatarStyle.placeHolderTextColor ??
                            colorPalette.buttonIconColor,
                        fontSize: typography.heading2?.bold?.fontSize,
                        fontWeight: typography.heading2?.bold?.fontWeight,
                        fontFamily: typography.heading2?.bold?.fontFamily,
                      )
                          .merge(
                            avatarStyle.placeHolderTextStyle,
                          )
                          .copyWith(
                            color: avatarStyle.placeHolderTextColor,
                          ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: avatarStyle.placeHolderTextColor ??
                        colorPalette.buttonIconColor,
                    fontSize: typography.heading2?.bold?.fontSize,
                    fontWeight: typography.heading2?.bold?.fontWeight,
                    fontFamily: typography.heading2?.bold?.fontFamily,
                  )
                      .merge(
                        avatarStyle.placeHolderTextStyle,
                      )
                      .copyWith(
                        color: avatarStyle.placeHolderTextColor,
                      ),
                ),
              ),
      ),
    );
  }
}
