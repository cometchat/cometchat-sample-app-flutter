import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../cometchat_uikit_shared.dart';

class CometchatLinkBuilder extends StatelessWidget {
  const CometchatLinkBuilder({
    super.key,
    this.style,
    this.text,
    required this.url,
    this.colorPalette,
    this.spacing,
    this.typography,
  });

  final TextStyle? style;
  final InlineSpan? text;
  final String url;
  final CometChatTypography? typography;
  final CometChatColorPalette? colorPalette;
  final CometChatSpacing? spacing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);

        if (!await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception('Could not launch $url');
        }
      },
      child: RichText(
        text: TextSpan(
          text: (url ?? ""),
          style: style?.copyWith(
            fontSize: typography?.body?.regular?.fontSize,
            fontWeight: typography?.body?.regular?.fontWeight,
            color: colorPalette?.textHighlight,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
