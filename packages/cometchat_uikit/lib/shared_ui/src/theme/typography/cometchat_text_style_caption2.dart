import 'package:flutter/material.dart';


///[CometChatTextStyleCaption2] is a class that gives the styling to the text displayed in the caption2
class CometChatTextStyleCaption2 extends ThemeExtension<CometChatTextStyleCaption2> {
  const CometChatTextStyleCaption2({
    this.bold,
    this.medium,
    this.regular
  });

  ///[bold] defines the styling for the text with FontWeight.w700.
  final TextStyle? bold;
  ///[medium] defines the styling for the text with FontWeight.w500.
  final TextStyle? medium;
  ///[regular] defines the styling for the text with FontWeight.w400.
  final TextStyle? regular;


  @override
  CometChatTextStyleCaption2 copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleCaption2(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleCaption2 lerp(covariant ThemeExtension<CometChatTextStyleCaption2>? other, double t) {
    if (other is! CometChatTextStyleCaption2) {
      return this;
    }
    return CometChatTextStyleCaption2(
      bold: TextStyle.lerp(bold, other.bold, t)!,
      medium: TextStyle.lerp(medium, other.medium, t)!,
      regular: TextStyle.lerp(regular, other.regular, t)!,
    );
  }

  static CometChatTextStyleCaption2 of(BuildContext context) => CometChatTextStyleCaption2(
      bold: _ccTextStyle(context).copyWith(
        fontWeight: FontWeight.w700,
      ),
      medium: _ccTextStyle(context).copyWith(
        fontWeight: FontWeight.w500,
      ),
      regular: _ccTextStyle(context).copyWith(
        fontWeight: FontWeight.w400,
      )
  );

  static TextStyle _ccTextStyle(BuildContext context) {

    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );
  }

  CometChatTextStyleCaption2 merge(CometChatTextStyleCaption2? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }

}