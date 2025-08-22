import 'package:flutter/material.dart';

/// The [CometChatColorPalette] class provides a color palette for the CometChat UI Kit.
class CometChatColorPalette extends ThemeExtension<CometChatColorPalette> {
  /// [primary] - Primary Color
  final Color? primary;

  /// Extended Primary Color
  /// [extendedPrimary50] - 96% lighter than primary color in light mode, 80% darker than primary color in dark mode
  final Color? extendedPrimary50;

  /// [extendedPrimary100] - 88% lighter than primary color in light mode, 72% darker than primary color in dark mode
  final Color? extendedPrimary100;

  /// [extendedPrimary200] - 77% lighter than primary color in light mode, 64% darker than primary color in dark mode
  final Color? extendedPrimary200;

  /// [extendedPrimary300] - 66% lighter than primary color in light mode, 56% darker than primary color in dark mode
  final Color? extendedPrimary300;

  /// [extendedPrimary400] - 55% lighter than primary color in light mode, 48% darker than primary color in dark mode
  final Color? extendedPrimary400;

  /// [extendedPrimary500] - 44% lighter than primary color in light mode, 40% darker than primary color in dark mode
  final Color? extendedPrimary500;

  /// [extendedPrimary600] - 33% lighter than primary color in light mode, 32% darker than primary color in dark mode
  final Color? extendedPrimary600;

  /// [extendedPrimary700] - 22% lighter than primary color in light mode, 24% darker than primary color in dark mode
  final Color? extendedPrimary700;

  /// [extendedPrimary800] - 11% lighter than primary color in light mode, 16% darker than primary color in dark mode
  final Color? extendedPrimary800;

  /// [extendedPrimary900] - 11% lighter than primary color in light mode, 8% darker than primary color in dark mode
  final Color? extendedPrimary900;

  ///Neutral Colors
  /// [neutral50] - sets neutral color 50
  final Color? neutral50;

  /// [neutral100] - sets neutral color 100
  final Color? neutral100;

  /// [neutral200] - sets neutral color 200
  final Color? neutral200;

  /// [neutral300] - sets neutral color 300
  final Color? neutral300;

  /// [neutral400] - sets neutral color 400
  final Color? neutral400;

  /// [neutral500] - sets neutral color 500
  final Color? neutral500;

  /// [neutral600] - sets neutral color 600
  final Color? neutral600;

  /// [neutral700] - sets neutral color 700
  final Color? neutral700;

  /// [neutral800] - sets neutral color 800
  final Color? neutral800;

  /// [neutral900] - sets neutral color 900
  final Color? neutral900;

  /// Alert Color
  /// [info] - Information Color
  final Color? info;

  /// [warning] - Warning Color
  final Color? warning;

  /// [error] - Error Color
  final Color? error;

  /// [success] - Success Color
  final Color? success;

  /// Error Shades
  /// [error100] - Light/Dark mode error color
  final Color? error100;

  /// Background Color
  /// [background1] - Background Color 1
  final Color? background1;

  /// [background2] - Background Color 2
  final Color? background2;

  /// [background3] - Background Color 3
  final Color? background3;

  /// [background4] - Background Color 4
  final Color? background4;

  /// Text Color
  /// [textPrimary] - Primary Text Color
  final Color? textPrimary;

  /// [textSecondary] - Secondary Text Color
  final Color? textSecondary;

  /// [textTertiary] - Tertiary Text Color
  final Color? textTertiary;

  /// [textDisabled] - Disabled Text Color
  final Color? textDisabled;

  /// [textWhite] - White Text Color
  final Color? textWhite;

  /// [textHighlight] - Highlighted Text Color
  final Color? textHighlight;

  /// Border Color
  /// [borderLight] - Light Border Color
  final Color? borderLight;

  /// [borderDefault] - Default Border Color
  final Color? borderDefault;

  /// [borderDark] - Dark Border Color
  final Color? borderDark;

  /// [borderHighlight] - Highlighted Border Color
  final Color? borderHighlight;

  /// ICON Color
  /// [iconPrimary] - Primary Icon Color
  final Color? iconPrimary;

  /// [iconSecondary] - Secondary Icon Color
  final Color? iconSecondary;

  /// [iconTertiary] - Tertiary Icon Color
  final Color? iconTertiary;

  /// [iconWhite] - White Icon Color
  final Color? iconWhite;

  /// [iconHighlight] - Highlighted Icon Color
  final Color? iconHighlight;

  ///[shimmerBackground] provides background color to the shimmer effect
  final Color? shimmerBackground;

  ///[shimmerGradient] provides color to the shimmer effect
  final Gradient? shimmerGradient;

  ///[buttonBackground] provides background color to the button
  final Color? buttonBackground;

  ///[secondaryButtonBackground] provides background color to the secondary button
  final Color? secondaryButtonBackground;

  ///[buttonIconColor] provides icon color to the button
  final Color? buttonIconColor;

  ///[buttonText] provides text color to the button
  final Color? buttonText;

  ///[secondaryButtonIcon] provides icon color to the secondary button
  final Color? secondaryButtonIcon;

  ///[secondaryButtonText] provides text color to the secondary button
  final Color? secondaryButtonText;

  ///[white] provides white color
   Color? white = Colors.white;

   ///[transparent] provides transparent color
   Color? transparent = Colors.transparent;

   ///[black] provides black color
   Color? black = Colors.black;

   ///[messageSeen] provides color that is used to indicate the message has been read
    Color? messageSeen;




   CometChatColorPalette({
    /// Primary Color
    this.primary,

    /// Extended Primary Color
    this.extendedPrimary100,
    this.extendedPrimary200,
    this.extendedPrimary300,
    this.extendedPrimary400,
    this.extendedPrimary500,
    this.extendedPrimary600,
    this.extendedPrimary700,
    this.extendedPrimary800,
    this.extendedPrimary900,
    this.extendedPrimary50,

    /// Neutral Color
    this.neutral50,
    this.neutral100,
    this.neutral200,
    this.neutral300,
    this.neutral400,
    this.neutral500,
    this.neutral600,
    this.neutral700,
    this.neutral800,
    this.neutral900,

    /// Alert Color
    this.info,
    this.warning,
    this.error,
    this.success,
    this.error100,

    /// Background Color
    this.background1,
    this.background2,
    this.background3,
    this.background4,

    /// Text Color
    this.textPrimary,
    this.textSecondary,
    this.textTertiary,
    this.textDisabled,
    this.textWhite,
    this.textHighlight,

    /// Border Color
    this.borderLight,
    this.borderDefault,
    this.borderDark,
    this.borderHighlight,

    /// ICON Color
    this.iconPrimary,
    this.iconSecondary,
    this.iconTertiary,
    this.iconWhite,
    this.iconHighlight,
    /// Shimmer Color
    this.shimmerBackground,
    this.shimmerGradient,
    /// Button Color
    this.buttonBackground,
    this.secondaryButtonBackground,
    this.buttonIconColor,
    this.buttonText,
    this.secondaryButtonIcon,
    this.secondaryButtonText,
    this.white = Colors.white,
    this.transparent = Colors.transparent,
     this.black = Colors.black,
     this.messageSeen =  const Color(0XFF56E8A7),
  });

  @override
  CometChatColorPalette copyWith({
    /// Primary Color
    Color? primary,

    /// Extended Primary Color
    Color? extendedPrimary50,
    Color? extendedPrimary100,
    Color? extendedPrimary200,
    Color? extendedPrimary300,
    Color? extendedPrimary400,
    Color? extendedPrimary500,
    Color? extendedPrimary600,
    Color? extendedPrimary700,
    Color? extendedPrimary800,
    Color? extendedPrimary900,

    /// Neutral Color
    Color? neutral,
    Color? neutral50,
    Color? neutral100,
    Color? neutral200,
    Color? neutral300,
    Color? neutral400,
    Color? neutral500,
    Color? neutral600,
    Color? neutral700,
    Color? neutral800,
    Color? neutral900,

    /// Alert Color
    Color? info,
    Color? warning,
    Color? error,
    Color? success,
    Color? error100,

    /// Background Color
    Color? background1,
    Color? background2,
    Color? background3,
    Color? background4,

    /// Text Color
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textWhite,
    Color? textHighlight,

    /// Border Color
    Color? borderLight,
    Color? borderDefault,
    Color? borderDark,
    Color? borderHighlight,

    /// ICON Color
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconTertiary,
    Color? iconWhite,
    Color? iconHighlight,

    ///shimmer color
    Color? shimmerBackground,
    Gradient? shimmerGradient,
    ///button color
    Color? buttonBackground,
    Color? secondaryButtonBackground,
    Color? buttonIconColor,
    Color? buttonText,
    Color? secondaryButtonIcon,
    Color? secondaryButtonText,
    Color? white,
    Color? transparent,
    Color? black,
    Color? alertColor,
  }) {
    return CometChatColorPalette(
      /// Primary Color
      primary: primary ?? this.primary,

      /// Extended Primary Color
      extendedPrimary50: extendedPrimary50 ?? this.extendedPrimary50,
      extendedPrimary100: extendedPrimary100 ?? this.extendedPrimary100,
      extendedPrimary200: extendedPrimary100 ?? this.extendedPrimary200,
      extendedPrimary300: extendedPrimary200 ?? this.extendedPrimary300,
      extendedPrimary400: extendedPrimary300 ?? this.extendedPrimary400,
      extendedPrimary500: extendedPrimary400 ?? this.extendedPrimary500,
      extendedPrimary600: extendedPrimary500 ?? this.extendedPrimary600,
      extendedPrimary700: extendedPrimary600 ?? this.extendedPrimary700,
      extendedPrimary800: extendedPrimary700 ?? this.extendedPrimary800,
      extendedPrimary900: extendedPrimary800 ?? this.extendedPrimary900,

      /// Neutral Color
      neutral50: neutral50 ?? this.neutral50,
      neutral100: neutral100 ?? this.neutral100,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral400: neutral400 ?? this.neutral400,
      neutral500: neutral500 ?? this.neutral500,
      neutral600: neutral600 ?? this.neutral600,
      neutral700: neutral700 ?? this.neutral700,
      neutral800: neutral800 ?? this.neutral800,
      neutral900: neutral900 ?? this.neutral900,

      /// Alert Color
      info: info ?? this.info,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      error100: error100 ?? this.error100,

      /// Background Color
      background1: background1 ?? this.background1,
      background2: background2 ?? this.background2,
      background3: background3 ?? this.background3,
      background4: background4 ?? this.background4,

      /// Text Color
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textWhite: textWhite ?? this.textWhite,
      textHighlight: textHighlight ?? this.textHighlight,

      /// Border Color
      borderLight: borderLight ?? this.borderLight,
      borderDefault: borderDefault ?? this.borderDefault,
      borderDark: borderDark ?? this.borderDark,
      borderHighlight: borderHighlight ?? this.borderHighlight,

      /// Icon Color
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconTertiary: iconTertiary ?? this.iconTertiary,
      iconWhite: iconWhite ?? this.iconWhite,
      iconHighlight: iconHighlight ?? this.iconHighlight,
      /// Shimmer Color
      shimmerBackground: shimmerBackground ?? this.shimmerBackground,
      shimmerGradient: shimmerGradient ?? this.shimmerGradient,
      /// Button Color
      buttonBackground: buttonBackground ?? this.buttonBackground,
      secondaryButtonBackground: secondaryButtonBackground ?? this.secondaryButtonBackground,
      buttonIconColor: buttonIconColor ?? this.buttonIconColor,
      buttonText: buttonText ?? this.buttonText,
      secondaryButtonIcon: secondaryButtonIcon ?? this.secondaryButtonIcon,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
      white: white ?? this.white,
      transparent: transparent ?? this.transparent,
      black: black ?? this.black,
      messageSeen: alertColor ?? this.messageSeen,
    );
  }

  ///[lerp] method blends two colors together based on the percentage provided.
  @override
  CometChatColorPalette lerp(
      ThemeExtension<CometChatColorPalette>? other, double t) {
    if (other is! CometChatColorPalette) {
      return this;
    }
    return CometChatColorPalette(
      /// Primary Color
      primary: Color.lerp(primary, other.primary, t),

      /// Extended Primary Color
      extendedPrimary200:
          Color.lerp(extendedPrimary200, other.extendedPrimary200, t),
      extendedPrimary100:
          Color.lerp(extendedPrimary100, other.extendedPrimary100, t),
      extendedPrimary300:
          Color.lerp(extendedPrimary300, other.extendedPrimary300, t),
      extendedPrimary400:
          Color.lerp(extendedPrimary400, other.extendedPrimary400, t),
      extendedPrimary500:
          Color.lerp(extendedPrimary500, other.extendedPrimary500, t),
      extendedPrimary600:
          Color.lerp(extendedPrimary600, other.extendedPrimary600, t),
      extendedPrimary700:
          Color.lerp(extendedPrimary700, other.extendedPrimary700, t),
      extendedPrimary800:
          Color.lerp(extendedPrimary800, other.extendedPrimary800, t),
      extendedPrimary900:
          Color.lerp(extendedPrimary900, other.extendedPrimary900, t),
      extendedPrimary50:
          Color.lerp(extendedPrimary50, other.extendedPrimary50, t),

      /// Neutral Color
      neutral50: Color.lerp(neutral50, other.neutral50, t),
      neutral100: Color.lerp(neutral100, other.neutral100, t),
      neutral200: Color.lerp(neutral200, other.neutral200, t),
      neutral300: Color.lerp(neutral300, other.neutral300, t),
      neutral400: Color.lerp(neutral400, other.neutral400, t),
      neutral500: Color.lerp(neutral500, other.neutral500, t),
      neutral600: Color.lerp(neutral600, other.neutral600, t),
      neutral700: Color.lerp(neutral700, other.neutral700, t),
      neutral800: Color.lerp(neutral800, other.neutral800, t),
      neutral900: Color.lerp(neutral900, other.neutral900, t),

      /// Alert Color
      info: Color.lerp(info, other.info, t),
      warning: Color.lerp(warning, other.warning, t),
      error: Color.lerp(error, other.error, t),
      success: Color.lerp(success, other.success, t),
      error100: Color.lerp(error100, other.error100, t),

      /// Background Color
      background1: Color.lerp(background1, other.background1, t),
      background2: Color.lerp(background2, other.background2, t),
      background3: Color.lerp(background3, other.background3, t),
      background4: Color.lerp(background4, other.background4, t),

      /// Text Color
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t),
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t),
      textWhite: Color.lerp(textWhite, other.textWhite, t),
      textHighlight: Color.lerp(textHighlight, other.textHighlight, t),

      /// Border Color
      borderLight: Color.lerp(borderLight, other.borderLight, t),
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t),
      borderDark: Color.lerp(borderDark, other.borderDark, t),
      borderHighlight: Color.lerp(borderHighlight, other.borderHighlight, t),

      /// ICON Color
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t),
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t),
      iconTertiary: Color.lerp(iconTertiary, other.iconTertiary, t),
      iconWhite: Color.lerp(iconWhite, other.iconWhite, t),
      iconHighlight: Color.lerp(iconHighlight, other.iconHighlight, t),
      /// Shimmer Color
      shimmerBackground: Color.lerp(shimmerBackground, other.shimmerBackground, t),
      shimmerGradient: Gradient.lerp(shimmerGradient, other.shimmerGradient, t),
      /// Button Color
      buttonBackground: Color.lerp(buttonBackground, other.buttonBackground, t),
      secondaryButtonBackground: Color.lerp(secondaryButtonBackground, other.secondaryButtonBackground, t),
      buttonIconColor: Color.lerp(buttonIconColor, other.buttonIconColor, t),
      buttonText: Color.lerp(buttonText, other.buttonText, t),
      secondaryButtonIcon: Color.lerp(secondaryButtonIcon, other.secondaryButtonIcon, t),
      secondaryButtonText: Color.lerp(secondaryButtonText, other.secondaryButtonText, t),

      white: Color.lerp(white, other.white, t),
      transparent: Color.lerp(transparent, other.transparent, t),
      black: Color.lerp(black, other.black, t),
      messageSeen: Color.lerp(messageSeen, other.messageSeen, t),
    );
  }

  ///[of] method returns the default [CometChatColorPalette] instance.
  static CometChatColorPalette of(BuildContext? context) => CometChatColorPalette();

}
