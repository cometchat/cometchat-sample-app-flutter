import 'package:flutter/material.dart';

///[CometChatTextStyleBody] is a class that gives the styling to the text displayed in the body
class CometChatTextStyleBody extends ThemeExtension<CometChatTextStyleBody> {
  const CometChatTextStyleBody({
    this.bold,
    this.medium,
    this.regular
  });

  /// The bold variant of the body style.
  final TextStyle? bold;
  /// The medium variant of the body style.
  final TextStyle? medium;
  /// The regular variant of the body style.
  final TextStyle? regular;

  @override
  CometChatTextStyleBody copyWith({
    TextStyle? bold,
    TextStyle? medium,
    TextStyle? regular,
  }) {
    return CometChatTextStyleBody(
      bold: bold ?? this.bold,
      medium: medium ?? this.medium,
      regular: regular ?? this.regular,
    );
  }

  @override
  CometChatTextStyleBody lerp(covariant ThemeExtension<CometChatTextStyleBody>? other, double t) {
    if (other is! CometChatTextStyleBody) {
      return this;
    }
    return CometChatTextStyleBody(
      bold: TextStyle.lerp(bold, other.bold, t),
      medium: TextStyle.lerp(medium, other.medium, t),
      regular: TextStyle.lerp(regular, other.regular, t),
    );
  }

  static CometChatTextStyleBody of(BuildContext context) => CometChatTextStyleBody(
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

  CometChatTextStyleBody merge(CometChatTextStyleBody? other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold),
      medium: medium?.merge(other.medium),
      regular: regular?.merge(other.regular),
    );
  }

}