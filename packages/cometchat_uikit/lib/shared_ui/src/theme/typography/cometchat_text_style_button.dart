import 'package:flutter/material.dart';

///[CometChatTextStyleButton] is a class that gives the styling to the text displayed in the buttons
class CometChatTextStyleButton extends ThemeExtension<CometChatTextStyleButton> {
  const CometChatTextStyleButton({
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
  CometChatTextStyleButton copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleButton(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleButton lerp(covariant ThemeExtension<CometChatTextStyleButton>? other, double t) {
    if (other is! CometChatTextStyleButton) {
      return this;
    }
    return CometChatTextStyleButton(
      bold: TextStyle.lerp(bold, other.bold, t)!,
      medium: TextStyle.lerp(medium, other.medium, t)!,
      regular: TextStyle.lerp(regular, other.regular, t)!,
    );
  }

  static CometChatTextStyleButton of(BuildContext context) => CometChatTextStyleButton(
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
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );
  }

  CometChatTextStyleButton merge(CometChatTextStyleButton? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }

}