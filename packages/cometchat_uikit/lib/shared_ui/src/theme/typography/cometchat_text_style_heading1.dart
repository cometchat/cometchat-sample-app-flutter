import 'package:flutter/material.dart';


///[CometChatTextStyleHeading1] is a class that gives the styling to the text displayed in the heading1
class CometChatTextStyleHeading1 extends ThemeExtension<CometChatTextStyleHeading1> {
  const CometChatTextStyleHeading1({
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
  CometChatTextStyleHeading1 copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleHeading1(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleHeading1 lerp(covariant ThemeExtension<CometChatTextStyleHeading1>? other, double t) {
    if (other is! CometChatTextStyleHeading1) {
      return this;
    }
    return CometChatTextStyleHeading1(
      bold: TextStyle.lerp(bold, other.bold, t)!,
      medium: TextStyle.lerp(medium, other.medium, t)!,
      regular: TextStyle.lerp(regular, other.regular, t)!,
    );
  }

  static CometChatTextStyleHeading1 of(BuildContext context) => CometChatTextStyleHeading1(
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
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
  }

  CometChatTextStyleHeading1 merge(CometChatTextStyleHeading1? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }

}