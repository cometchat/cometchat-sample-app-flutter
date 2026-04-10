import 'package:flutter/material.dart';

///[CometChatTextStyleHeading2] is a class that gives the styling to the text displayed in the heading3
class CometChatTextStyleHeading2 extends ThemeExtension<CometChatTextStyleHeading2> {
  const CometChatTextStyleHeading2({
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
  CometChatTextStyleHeading2 copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleHeading2(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleHeading2 lerp(covariant ThemeExtension<CometChatTextStyleHeading2>? other, double t) {
    if (other is! CometChatTextStyleHeading2) {
      return this;
    }
    return CometChatTextStyleHeading2(
      bold: TextStyle.lerp(bold, other.bold, t)!,
      medium: TextStyle.lerp(medium, other.medium, t)!,
      regular: TextStyle.lerp(regular, other.regular, t)!,
    );
  }

  static CometChatTextStyleHeading2 of(BuildContext context) => CometChatTextStyleHeading2(
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
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );
  }

  CometChatTextStyleHeading2 merge(CometChatTextStyleHeading2? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }
}