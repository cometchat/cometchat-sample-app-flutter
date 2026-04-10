import 'package:flutter/material.dart';


///[CometChatTextStyleHeading3] is a class that gives the styling to the text displayed in the heading3
class CometChatTextStyleHeading3 extends ThemeExtension<CometChatTextStyleHeading3> {
  const CometChatTextStyleHeading3({
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
  CometChatTextStyleHeading3 copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleHeading3(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleHeading3 lerp(covariant ThemeExtension<CometChatTextStyleHeading3>? other, double t) {
    if (other is! CometChatTextStyleHeading3) {
      return this;
    }
    return CometChatTextStyleHeading3(
      bold: TextStyle.lerp(bold, other.bold, t)!,
      medium: TextStyle.lerp(medium, other.medium, t)!,
      regular: TextStyle.lerp(regular, other.regular, t)!,
    );
  }

  static CometChatTextStyleHeading3 of(BuildContext context) => CometChatTextStyleHeading3(
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
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );
  }

  CometChatTextStyleHeading3 merge(CometChatTextStyleHeading3? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }

}