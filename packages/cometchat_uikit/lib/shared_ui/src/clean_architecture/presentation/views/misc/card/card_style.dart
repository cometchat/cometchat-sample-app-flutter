import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CardStyle] is a model class for card widget. It contains the styles for the card widget.
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
class CardStyle {
  const CardStyle({
    this.titleStyle,
    this.avatarStyle,
  });

  ///[titleStyle] sets TextStyle for title
  final TextStyle? titleStyle;

  ///[avatarStyle] sets style for avatar
  final CometChatAvatarStyle? avatarStyle;
}
