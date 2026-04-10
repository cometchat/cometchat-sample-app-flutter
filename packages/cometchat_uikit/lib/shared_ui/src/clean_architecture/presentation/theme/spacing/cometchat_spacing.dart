import 'dart:ui';

import 'package:flutter/material.dart';


///[CometChatSpacing] is a class that holds the spacing values for the CometChat UI Kit.
class CometChatSpacing extends ThemeExtension<CometChatSpacing> {
   CometChatSpacing({
   this.spacing=2,
    this.spacing1=4,
    this.spacing2=8,
    this.spacing3=12,
    this.spacing4=16,
    this.spacing5=20,
    this.spacing6=24,
    this.spacing7=28,
    this.spacing8=32,
    this.spacing9=36,
    this.spacing10=40,
    this.spacing11=44,
    this.spacing12=48,
    this.spacing13=52,
    this.spacing14=56,
    this.spacing15=60,
    this.spacing16=64,
    this.spacing17=68,
    this.spacing18=72,
    this.spacing19=76,
    this.spacing20=80,
    this.spacingMax=1000,
    this.padding,
    this.padding1,
    this.padding2,
    this.padding3,
    this.padding4,
    this.padding5,
    this.padding6,
    this.padding7,
    this.padding8,
    this.padding9,
    this.padding10,
    this.margin,
    this.margin1,
    this.margin2,
    this.margin3,
    this.margin4,
    this.margin5,
    this.margin6,
    this.margin7,
    this.margin8,
    this.margin9,
    this.margin10,
    this.margin11,
    this.margin12,
    this.margin13,
    this.margin14,
    this.margin15,
    this.margin16,
    this.margin17,
    this.margin18,
    this.margin19,
    this.margin20,
     this.radius,
    this.radius1,
    this.radius2,
    this.radius3,
    this.radius4,
    this.radius5,
    this.radius6,
    this.radiusMax,
  }){
    //initializing padding
    padding??=spacing;
    padding1??=spacing1;
    padding2??=spacing2;
    padding3??=spacing3;
    padding4??=spacing4;
    padding5??=spacing5;
    padding6??=spacing6;
    padding7??=spacing7;
    padding8??=spacing8;
    padding9??=spacing9;
    padding10??=spacing10;

    //initializing margin
    margin??=spacing;
    margin1??=spacing1;
    margin2??=spacing2;
    margin3??=spacing3;
    margin4??=spacing4;
    margin5??=spacing5;
    margin6??=spacing6;
    margin7??=spacing7;
    margin8??=spacing8;
    margin9??=spacing9;
    margin10??=spacing10;
    margin11??=spacing11;
    margin12??=spacing12;
    margin13??=spacing13;
    margin14??=spacing14;
    margin15??=spacing15;
    margin16??=spacing16;
    margin17??=spacing17;
    margin18??=spacing18;
    margin19??=spacing19;
    margin20??=spacing20;

    //initializing radius
    radius??=spacing;
    radius1??=spacing1;
    radius2??=spacing2;
    radius3??=spacing3;
    radius4??=spacing4;
    radius5??=spacing5;
    radius6??=spacing6;
    radiusMax??=spacingMax;
  }

  ///[spacing] defines the spacing value of 2.
  final double? spacing;

  ///[spacing1] defines the spacing value of 4.
  final double? spacing1;

  ///[spacing2] defines the spacing value of 8.
  final double? spacing2;

  ///[spacing3] defines the spacing value of 12.
  final double? spacing3;

  ///[spacing4] defines the spacing value of 16.
  final double? spacing4;

  ///[spacing5] defines the spacing value of 20.
  final double? spacing5;

  ///[spacing6] defines the spacing value of 24.
  final double? spacing6;

  ///[spacing7] defines the spacing value of 28.
  final double? spacing7;

  ///[spacing8] defines the spacing value of 32.
  final double? spacing8;

  ///[spacing9] defines the spacing value of 36.
  final double? spacing9;

  ///[spacing10] defines the spacing value of 40.
  final double? spacing10;

  ///[spacing11] defines the spacing value of 44.
  final double? spacing11;

  ///[spacing12] defines the spacing value of 48.
  final double? spacing12;

  ///[spacing13] defines the spacing value of 52.
  final double? spacing13;

  ///[spacing14] defines the spacing value of 56.
  final double? spacing14;

  ///[spacing15] defines the spacing value of 60.
  final double? spacing15;

  ///[spacing16] defines the spacing value of 64.
  final double? spacing16;

  ///[spacing17] defines the spacing value of 68.
  final double? spacing17;

  ///[spacing18] defines the spacing value of 72.
  final double? spacing18;

  ///[spacing19] defines the spacing value of 76.
  final double? spacing19;

  ///[spacing20] defines the spacing value of 80.
  final double? spacing20;

  ///[spacingMax] defines the maximum spacing value of 1000.
  final double? spacingMax;

  ///[padding] defines the default padding value of 2 obtained from [spacing].
  double? padding;

  ///[padding1] defines the padding value of 4 obtained from [spacing1].
  double? padding1;

  ///[padding2] defines the padding value of 8 obtained from [spacing2].
  double? padding2;

  ///[padding3] defines the padding value of 12 obtained from [spacing3].
  double? padding3;

  ///[padding4] defines the padding value of 16 obtained from [spacing4].
  double? padding4;

  ///[padding5] defines the padding value of 20 obtained from [spacing5].
  double? padding5;

  ///[padding6] defines the padding value of 24 obtained from [spacing6].
  double? padding6;

  ///[padding7] defines the padding value of 28 obtained from [spacing7].
  double? padding7;

  ///[padding8] defines the padding value of 32 obtained from [spacing8].
  double? padding8;

  ///[padding9] defines the padding value of 36 obtained from [spacing9].
  double? padding9;

  ///[padding10] defines the padding value of 40 obtained from [spacing10].
  double? padding10;


  ///[margin] defines the default margin value of 2 obtained from [spacing].
  double? margin;

  ///[margin1] defines the margin value of 4 obtained from [spacing1].
  double? margin1;

  ///[margin2] defines the margin value of 8 obtained from [spacing2].
  double? margin2;

  ///[margin3] defines the margin value of 12 obtained from [spacing3].
  double? margin3;

  ///[margin4] defines the margin value of 16 obtained from [spacing4].
  double? margin4;

  ///[margin5] defines the margin value of 20 obtained from [spacing5].
  double? margin5;

  ///[margin6] defines the margin value of 24 obtained from [spacing6].
  double? margin6;

  ///[margin7] defines the margin value of 28 obtained from [spacing7].
  double? margin7;

  ///[margin8] defines the margin value of 32 obtained from [spacing8].
  double? margin8;

  ///[margin9] defines the margin value of 36 obtained from [spacing9].
  double? margin9;

  ///[margin10] defines the margin value of 40 obtained from [spacing10].
  double? margin10;

  ///[margin11] defines the margin value of 44 obtained from [spacing11].
  double? margin11;

  ///[margin12] defines the margin value of 48 obtained from [spacing12].
  double? margin12;

  ///[margin13] defines the margin value of 52 obtained from [spacing13].
  double? margin13;

  ///[margin14] defines the margin value of 56 obtained from [spacing14].
  double? margin14;

  ///[margin15] defines the margin value of 60 obtained from [spacing15].
  double? margin15;

  ///[margin16] defines the margin value of 64 obtained from [spacing16].
  double? margin16;

  ///[margin17] defines the margin value of 68 obtained from [spacing17].
  double? margin17;

  ///[margin18] defines the margin value of 72 obtained from [spacing18].
  double? margin18;

  ///[margin19] defines the margin value of 76 obtained from [spacing19].
  double? margin19;

  ///[margin20] defines the margin value of 80 obtained from [spacing20].
  double? margin20;

   ///[radius] defines the radius value of 2 obtained from [spacing].
   double? radius;
    ///[radius1] defines the radius value of 4 obtained from [spacing1].
    double? radius1;

    ///[radius2] defines the radius value of 8 obtained from [spacing2].
    double? radius2;

    ///[radius3] defines the radius value of 12 obtained from [spacing3].
    double? radius3;

    ///[radius4] defines the radius value of 16 obtained from [spacing4].
    double? radius4;

    ///[radius5] defines the radius value of 20 obtained from [spacing5].
    double? radius5;

    ///[radius6] defines the radius value of 24 obtained from [spacing6].
    double? radius6;

    ///[radiusMax] defines the maximum radius value of 1000 obtained from [spacingMax].
    double? radiusMax;




  @override
  CometChatSpacing copyWith({
    double? spacing,
    double? spacing1,
    double? spacing2,
    double? spacing3,
    double? spacing4,
    double? spacing5,
    double? spacing6,
    double? spacing7,
    double? spacing8,
    double? spacing9,
    double? spacing10,
    double? spacing11,
    double? spacing12,
    double? spacing13,
    double? spacing14,
    double? spacing15,
    double? spacing16,
    double? spacing17,
    double? spacing18,
    double? spacing19,
    double? spacing20,
    double? spacingMax,
    double? padding,
    double? padding1,
    double? padding2,
    double? padding3,
    double? padding4,
    double? padding5,
    double? padding6,
    double? padding7,
    double? padding8,
    double? padding9,
    double? padding10,
    double? padding11,
    double? padding12,
    double? padding13,
    double? padding14,
    double? padding15,
    double? padding16,
    double? padding17,
    double? padding18,
    double? padding19,
    double? padding20,
    double? paddingMax,
    double? margin,
    double? margin1,
    double? margin2,
    double? margin3,
    double? margin4,
    double? margin5,
    double? margin6,
    double? margin7,
    double? margin8,
    double? margin9,
    double? margin10,
    double? margin11,
    double? margin12,
    double? margin13,
    double? margin14,
    double? margin15,
    double? margin16,
    double? margin17,
    double? margin18,
    double? margin19,
    double? margin20,
    double? marginMax,
    double? radius,
    double? radius1,
    double? radius2,
    double? radius3,
    double? radius4,
    double? radius5,
    double? radius6,
    double? radiusMax,
  }) {
    return CometChatSpacing(
      spacing: spacing ?? this.spacing,
      spacing1: spacing1 ?? this.spacing1,
      spacing2: spacing2 ?? this.spacing2,
      spacing3: spacing3 ?? this.spacing3,
      spacing4: spacing4 ?? this.spacing4,
      spacing5: spacing5 ?? this.spacing5,
      spacing6: spacing6 ?? this.spacing6,
      spacing7: spacing7 ?? this.spacing7,
      spacing8: spacing8 ?? this.spacing8,
      spacing9: spacing9 ?? this.spacing9,
      spacing10: spacing10 ?? this.spacing10,
      spacing11: spacing11 ?? this.spacing11,
      spacing12: spacing12 ?? this.spacing12,
      spacing13: spacing13 ?? this.spacing13,
      spacing14: spacing14 ?? this.spacing14,
      spacing15: spacing15 ?? this.spacing15,
      spacing16: spacing16 ?? this.spacing16,
      spacing17: spacing17 ?? this.spacing17,
      spacing18: spacing18 ?? this.spacing18,
      spacing19: spacing19 ?? this.spacing19,
      spacing20: spacing20 ?? this.spacing20,
      spacingMax: spacingMax ?? this.spacingMax,
      padding: padding ?? this.padding,
      padding1: padding1 ?? this.padding1,
      padding2: padding2 ?? this.padding2,
      padding3: padding3 ?? this.padding3,
      padding4: padding4 ?? this.padding4,
      padding5: padding5 ?? this.padding5,
      padding6: padding6 ?? this.padding6,
      padding7: padding7 ?? this.padding7,
      padding8: padding8 ?? this.padding8,
      padding9: padding9 ?? this.padding9,
      padding10: padding10 ?? this.padding10,
      margin: margin ?? this.margin,
      margin1: margin1 ?? this.margin1,
      margin2: margin2 ?? this.margin2,
      margin3: margin3 ?? this.margin3,
      margin4: margin4 ?? this.margin4,
      margin5: margin5 ?? this.margin5,
      margin6: margin6 ?? this.margin6,
      margin7: margin7 ?? this.margin7,
      margin8: margin8 ?? this.margin8,
      margin9: margin9 ?? this.margin9,
      margin10: margin10 ?? this.margin10,
      margin11: margin11 ?? this.margin11,
      margin12: margin12 ?? this.margin12,
      margin13: margin13 ?? this.margin13,
      margin14: margin14 ?? this.margin14,
      margin15: margin15 ?? this.margin15,
      margin16: margin16 ?? this.margin16,
      margin17: margin17 ?? this.margin17,
      margin18: margin18 ?? this.margin18,
      margin19: margin19 ?? this.margin19,
      margin20: margin20 ?? this.margin20,
      radius: radius ?? this.radius,
      radius1: radius1 ?? this.radius1,
      radius2: radius2 ?? this.radius2,
      radius3: radius3 ?? this.radius3,
      radius4: radius4 ?? this.radius4,
      radius5: radius5 ?? this.radius5,
      radius6: radius6 ?? this.radius6,
      radiusMax: radiusMax ?? this.radiusMax,
    );
  }

  @override
  CometChatSpacing lerp(covariant ThemeExtension<CometChatSpacing>? other, double t) {
    if (other is! CometChatSpacing) {
      return this;
    }
    return CometChatSpacing(
      spacing: lerpDouble(spacing, other.spacing1, t),
      spacing1: lerpDouble(spacing1, other.spacing1, t),
      spacing2: lerpDouble(spacing2, other.spacing2, t),
      spacing3: lerpDouble(spacing3, other.spacing3, t),
      spacing4: lerpDouble(spacing4, other.spacing4, t),
      spacing5: lerpDouble(spacing5, other.spacing5, t),
      spacing6: lerpDouble(spacing6, other.spacing6, t),
      spacing7: lerpDouble(spacing7, other.spacing7, t),
      spacing8: lerpDouble(spacing8, other.spacing8, t),
      spacing9: lerpDouble(spacing9, other.spacing9, t),
      spacing10: lerpDouble(spacing10, other.spacing10, t),
      spacing11: lerpDouble(spacing11, other.spacing11, t),
      spacing12: lerpDouble(spacing12, other.spacing12, t),
      spacing13: lerpDouble(spacing13, other.spacing13, t),
      spacing14: lerpDouble(spacing14, other.spacing14, t),
      spacing15: lerpDouble(spacing15, other.spacing15, t),
      spacing16: lerpDouble(spacing16, other.spacing16, t),
      spacing17: lerpDouble(spacing17, other.spacing17, t),
      spacing18: lerpDouble(spacing18, other.spacing18, t),
      spacing19: lerpDouble(spacing19, other.spacing19, t),
      spacing20: lerpDouble(spacing20, other.spacing20, t),
      spacingMax: lerpDouble(spacingMax, other.spacingMax, t),
      padding: lerpDouble(padding, other.padding, t),
      padding1: lerpDouble(padding1, other.padding1, t),
      padding2: lerpDouble(padding2, other.padding2, t),
      padding3: lerpDouble(padding3, other.padding3, t),
      padding4: lerpDouble(padding4, other.padding4, t),
      padding5: lerpDouble(padding5, other.padding5, t),
      padding6: lerpDouble(padding6, other.padding6, t),
      padding7: lerpDouble(padding7, other.padding7, t),
      padding8: lerpDouble(padding8, other.padding8, t),
      padding9: lerpDouble(padding9, other.padding9, t),
      padding10: lerpDouble(padding10, other.padding10, t),
      margin: lerpDouble(margin, other.margin, t),
      margin1: lerpDouble(margin1, other.margin1, t),
      margin2: lerpDouble(margin2, other.margin2, t),
      margin3: lerpDouble(margin3, other.margin3, t),
      margin4: lerpDouble(margin4, other.margin4, t),
      margin5: lerpDouble(margin5, other.margin5, t),
      margin6: lerpDouble(margin6, other.margin6, t),
      margin7: lerpDouble(margin7, other.margin7, t),
      margin8: lerpDouble(margin8, other.margin8, t),
      margin9: lerpDouble(margin9, other.margin9, t),
      margin10: lerpDouble(margin10, other.margin10, t),
      margin11: lerpDouble(margin11, other.margin11, t),
      margin12: lerpDouble(margin12, other.margin12, t),
      margin13: lerpDouble(margin13, other.margin13, t),
      margin14: lerpDouble(margin14, other.margin14, t),
      margin15: lerpDouble(margin15, other.margin15, t),
      margin16: lerpDouble(margin16, other.margin16, t),
      margin17: lerpDouble(margin17, other.margin17, t),
      margin18: lerpDouble(margin18, other.margin18, t),
      margin19: lerpDouble(margin19, other.margin19, t),
      margin20: lerpDouble(margin20, other.margin20, t),
      radius: lerpDouble(radius, other.radius, t),
      radius1: lerpDouble(radius1, other.radius1, t),
      radius2: lerpDouble(radius2, other.radius2, t),
      radius3: lerpDouble(radius3, other.radius3, t),
      radius4: lerpDouble(radius4, other.radius4, t),
      radius5: lerpDouble(radius5, other.radius5, t),
      radius6: lerpDouble(radius6, other.radius6, t),
      radiusMax: lerpDouble(radiusMax, other.radiusMax, t),
    );
  }

  static CometChatSpacing of(BuildContext context) => CometChatSpacing();

  CometChatSpacing merge(CometChatSpacing? other){
    if (other == null) return this;
    return copyWith(
      spacing: other.spacing,
      spacing1: other.spacing1,
      spacing2: other.spacing2,
      spacing3: other.spacing3,
      spacing4: other.spacing4,
      spacing5: other.spacing5,
      spacing6: other.spacing6,
      spacing7: other.spacing7,
      spacing8: other.spacing8,
      spacing9: other.spacing9,
      spacing10: other.spacing10,
      spacing11: other.spacing11,
      spacing12: other.spacing12,
      spacing13: other.spacing13,
      spacing14: other.spacing14,
      spacing15: other.spacing15,
      spacing16: other.spacing16,
      spacing17: other.spacing17,
      spacing18: other.spacing18,
      spacing19: other.spacing19,
      spacing20: other.spacing20,
      spacingMax: other.spacingMax,
      padding: other.padding,
      padding1: other.padding1,
      padding2: other.padding2,
      padding3: other.padding3,
      padding4: other.padding4,
      padding5: other.padding5,
      padding6: other.padding6,
      padding7: other.padding7,
      padding8: other.padding8,
      padding9: other.padding9,
      padding10: other.padding10,
      margin: other.margin,
      margin1: other.margin1,
      margin2: other.margin2,
      margin3: other.margin3,
      margin4: other.margin4,
      margin5: other.margin5,
      margin6: other.margin6,
      margin7: other.margin7,
      margin8: other.margin8,
      margin9: other.margin9,
      margin10: other.margin10,
      margin11: other.margin11,
      margin12: other.margin12,
      margin13: other.margin13,
      margin14: other.margin14,
      margin15: other.margin15,
      margin16: other.margin16,
      margin17: other.margin17,
      margin18: other.margin18,
      margin19: other.margin19,
      margin20: other.margin20,
      radius: other.radius,
      radius1: other.radius1,
      radius2: other.radius2,
      radius3: other.radius3,
      radius4: other.radius4,
      radius5: other.radius5,
      radius6: other.radius6,
      radiusMax: other.radiusMax,);
  }

}
