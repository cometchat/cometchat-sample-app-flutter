import 'package:flutter/material.dart';

///Base class for
class FontStyle {
  double fontSize;
  FontWeight? fontWeight;
  String? fontFamily;

  FontStyle({required this.fontSize, this.fontWeight, this.fontFamily});
}

class FontBasics {
  String? fontFamily;

  FontWeight fontWeightRegular;

  FontWeight fontWeightMedium;

  FontWeight fontWeightSemibold;

  FontWeight fontWeightBold;

  FontBasics(this.fontFamily, this.fontWeightRegular, this.fontWeightMedium,
      this.fontWeightSemibold, this.fontWeightBold);

  //Should used for development
  factory FontBasics.fromDefault(
      {String? fontFamily,
      FontWeight? fontWeightRegular,
      FontWeight? fontWeightMedium,
      FontWeight? fontWeightSemibold,
      FontWeight? fontWeightBold}) {
    return FontBasics(
        fontFamily,
        fontWeightRegular ?? FontWeight.w400,
        fontWeightMedium ?? FontWeight.w500,
        fontWeightSemibold ?? FontWeight.w600,
        fontWeightBold ?? FontWeight.w700);
  }
}

class Typography {
  FontBasics fontBasics;
  FontStyle heading;
  FontStyle name;
  FontStyle title1;
  FontStyle title2;
  FontStyle subtitle1;
  FontStyle subtitle2;
  FontStyle text1;
  FontStyle text2;
  FontStyle caption1;
  FontStyle body;
  late FontStyle caption2;

  Typography(
      {required this.fontBasics,
      required this.heading,
      required this.name,
      required this.title1,
      required this.title2,
      required this.subtitle1,
      required this.subtitle2,
      required this.text1,
      required this.text2,
      required this.caption1,
      required this.caption2,
      required this.body});

  ///Should be used to make custom themes
  factory Typography.fromDefault(
      {FontBasics? fontBasics,
      String? fontFamily,
      FontWeight? fontWeightRegular,
      FontWeight? fontWeightMedium,
      FontStyle? heading,
      FontStyle? name,
      FontStyle? title1,
      FontStyle? title2,
      FontStyle? subtitle1,
      FontStyle? subtitle2,
      FontStyle? text1,
      FontStyle? text2,
      FontStyle? caption1,
      FontStyle? caption2,
      FontStyle? body}) {
    FontBasics currentFontBasics = fontBasics ?? FontBasics.fromDefault();

    //Setting Optional values to default font weght values if null
    heading?.fontWeight ??= currentFontBasics.fontWeightBold;
    name?.fontWeight ??= currentFontBasics.fontWeightMedium;
    title1?.fontWeight ??= currentFontBasics.fontWeightSemibold;
    title2?.fontWeight ??= currentFontBasics.fontWeightRegular;
    subtitle1?.fontWeight ??= currentFontBasics.fontWeightRegular;
    subtitle2?.fontWeight ??= currentFontBasics.fontWeightRegular;
    text1?.fontWeight ??= currentFontBasics.fontWeightMedium;
    text2?.fontWeight ??= currentFontBasics.fontWeightMedium;
    caption1?.fontWeight ??= currentFontBasics.fontWeightMedium;
    caption2?.fontWeight ??= currentFontBasics.fontWeightMedium;
    body?.fontWeight ??= currentFontBasics.fontWeightRegular;

    //Setting Optional values to default font family values if null
    heading?.fontFamily ??= currentFontBasics.fontFamily;
    name?.fontFamily ??= currentFontBasics.fontFamily;
    title1?.fontFamily ??= currentFontBasics.fontFamily;
    title2?.fontFamily ??= currentFontBasics.fontFamily;
    subtitle1?.fontFamily ??= currentFontBasics.fontFamily;
    subtitle2?.fontFamily ??= currentFontBasics.fontFamily;
    text1?.fontFamily ??= currentFontBasics.fontFamily;
    text2?.fontFamily ??= currentFontBasics.fontFamily;
    caption1?.fontFamily ??= currentFontBasics.fontFamily;
    caption2?.fontFamily ??= currentFontBasics.fontFamily;
    body?.fontFamily ??= currentFontBasics.fontFamily;

    return Typography(
      fontBasics: currentFontBasics,
      heading: heading ??
          FontStyle(
              fontSize: 22,
              fontWeight: currentFontBasics.fontWeightBold,
              fontFamily: currentFontBasics.fontFamily),
      name: name ??
          FontStyle(
              fontSize: 17,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      title1: title1 ??
          FontStyle(
              fontSize: 20,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      title2: title2 ??
          FontStyle(
              fontSize: 16,
              fontWeight: currentFontBasics.fontWeightRegular,
              fontFamily: currentFontBasics.fontFamily),
      subtitle1: subtitle1 ??
          FontStyle(
              fontSize: 15,
              fontWeight: currentFontBasics.fontWeightRegular,
              fontFamily: currentFontBasics.fontFamily),
      subtitle2: subtitle2 ??
          FontStyle(
              fontSize: 13,
              fontWeight: currentFontBasics.fontWeightRegular,
              fontFamily: currentFontBasics.fontFamily),
      text1: text1 ??
          FontStyle(
              fontSize: 15,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      text2: text2 ??
          FontStyle(
              fontSize: 13,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      caption1: caption1 ??
          FontStyle(
              fontSize: 12,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      caption2: caption2 ??
          FontStyle(
              fontSize: 11,
              fontWeight: currentFontBasics.fontWeightMedium,
              fontFamily: currentFontBasics.fontFamily),
      body: body ??
          FontStyle(
              fontSize: 17,
              fontWeight: currentFontBasics.fontWeightRegular,
              fontFamily: currentFontBasics.fontFamily),
    );
  }
}

///Default exposed typographytheme
Typography defaultTypographyTheme = Typography.fromDefault();
