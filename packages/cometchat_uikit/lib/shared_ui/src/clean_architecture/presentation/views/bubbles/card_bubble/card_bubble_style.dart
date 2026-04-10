import 'package:flutter/material.dart';
import "../../../../clean_architecture.dart";

///[CardBubbleStyle] is a model class for card widget. It contains the styles for the card widget.
///
/// ```dart
/// CardStyle(
/// titleStyle: TextStyle(),
/// subtitleStyle: TextStyle(),
/// width: 100,
/// height: 100,
/// background: Colors.white,
/// border: Border.all(),
/// borderRadius: BorderRadius.circular(20),
/// gradient: LinearGradient(),
/// );
/// ```
///
class CardBubbleStyle extends BaseStyles {
  const CardBubbleStyle({
    this.buttonStyle,
    this.textStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  ///[textStyle] sets TextStyle for subtitle
  final TextStyle? textStyle;

  ///[buttonStyle] sets submitButtonStyle for subtitle
  final ButtonElementStyle? buttonStyle;
}
