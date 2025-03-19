import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

/// The [CometChatQuickView] widget is used to display a quick view with a title and an optional subtitle.
/// You can customize the appearance of the title and subtitle using the `titleTextStyle` and `subtitleTextStyle` parameters.
///
/// If no `background` color is provided, it defaults to white.
class CometChatQuickView extends StatelessWidget {
  const CometChatQuickView(
      {super.key,
      required this.title,
      this.subtitle,
      this.quickViewStyle});

  /// The main title displayed in the quick view.
  final String title;

  /// An optional subtitle displayed below the title.
  final String? subtitle;

  ///Sets the style for quick view
  final QuickViewStyle? quickViewStyle;

  @override
  Widget build(BuildContext context) {


    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color:
                  quickViewStyle?.background,
              shape: BoxShape.rectangle,
              border: quickViewStyle?.border,
              borderRadius: const BorderRadius.all(
                  Radius.circular(4.0)),
            ),
            child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                    color: quickViewStyle?.background ?? Colors.white,
                    shape: BoxShape.rectangle,
                    border: Border(
                      left: BorderSide(
                        color: quickViewStyle?.leadingBarTint ?? Colors.transparent, // Border color
                        width: quickViewStyle?.leadingBarWidth ??
                            4.0, // Border width
                      ),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: quickViewStyle?.titleStyle),
                    const SizedBox(
                      height: 4.0,
                    ),
                    if (subtitle != null)
                      Text(subtitle!,
                          style:quickViewStyle?.subtitleStyle)
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
