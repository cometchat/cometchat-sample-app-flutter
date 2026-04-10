import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class CometChatTypography extends ThemeExtension<CometChatTypography> {

  ///[heading1] defines the styling for the text displayed in the heading1
  final CometChatTextStyleHeading1? heading1;

  ///[heading2] defines the styling for the text displayed in the heading2
  final CometChatTextStyleHeading2? heading2;

  ///[heading3] defines the styling for the text displayed in the heading3
  final CometChatTextStyleHeading3? heading3;

  ///[heading4] defines the styling for the text displayed in the heading4
  final CometChatTextStyleHeading4? heading4;

  ///[body] defines the styling for the text displayed in the body
  final CometChatTextStyleBody? body;

  ///[caption1] defines the styling for the text displayed in the caption1
  final CometChatTextStyleCaption1? caption1;

  ///[caption2] defines the styling for the text displayed in the caption2
  final CometChatTextStyleCaption2? caption2;

  ///[button] defines the styling for the text displayed in the button
  final CometChatTextStyleButton? button;

  ///[link] defines the styling for the text displayed in the link
  final CometChatTextStyleLink? link;

  ///[title] defines the styling for the text displayed in the title
  final CometChatTextStyleTitle? title;




  const CometChatTypography({
     this.heading1,
    this.heading2,
    this.heading3,
    this.heading4,
    this.body,
    this.caption1,
    this.caption2,
    this.button,
    this.link,
    this.title,

  });

  static CometChatTypography of(BuildContext context) => CometChatTypography(
    heading1: CometChatTextStyleHeading1.of(context),
    heading2: CometChatTextStyleHeading2.of(context),
    heading3: CometChatTextStyleHeading3.of(context),
    heading4: CometChatTextStyleHeading4.of(context),
    body: CometChatTextStyleBody.of(context),
    caption1: CometChatTextStyleCaption1.of(context),
    caption2: CometChatTextStyleCaption2.of(context),
    button: CometChatTextStyleButton.of(context),
    link: CometChatTextStyleLink.of(context),
    title: CometChatTextStyleTitle.of(context),
  );

  @override
  CometChatTypography copyWith({
    CometChatTextStyleHeading1? heading1,
    CometChatTextStyleHeading2? heading2,
    CometChatTextStyleHeading3? heading3,
    CometChatTextStyleHeading4? heading4,
    CometChatTextStyleBody? body,
    CometChatTextStyleCaption1? caption1,
    CometChatTextStyleCaption2? caption2,
    CometChatTextStyleButton? button,
    CometChatTextStyleLink? link,
    CometChatTextStyleTitle? title,
  }) {
    return CometChatTypography(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      heading4: heading4 ?? this.heading4,
      body: body ?? this.body,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
      button: button ?? this.button,
      link: link ?? this.link,
      title: title ?? this.title,
    );
  }

  CometChatTypography merge(CometChatTypography? style) {
    if (style == null) return this;
    return copyWith(
      heading1: style.heading1,
      heading2: style.heading2,
      heading3: style.heading3,
      heading4: style.heading4,
      body: style.body,
      caption1: style.caption1,
      caption2: style.caption2,
      button: style.button,
      link: style.link,
      title: style.title,
    );
  }

  @override
   ThemeExtension<CometChatTypography> lerp(ThemeExtension<CometChatTypography>? other, double t) {
    if (other is! CometChatTypography) {
      return this;
    }
    return CometChatTypography(
      heading1: heading1?.lerp(other.heading1, t),
      heading2: heading2?.lerp(other.heading2, t),
      heading3: heading3?.lerp(other.heading3, t),
      heading4: heading4?.lerp(other.heading4, t),
      body: body?.lerp(other.body, t),
      caption1: caption1?.lerp(other.caption1, t),
      caption2: caption2?.lerp(other.caption2, t),
      button: button?.lerp(other.button, t),
      link: link?.lerp(other.link, t),
      title: title?.lerp(other.title, t),
    );
  }
  

}