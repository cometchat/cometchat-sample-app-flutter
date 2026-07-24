import 'package:flutter/material.dart';

///The [CometChatColorHelper] class provides methods to blend two colors together and generate a color palette based on the base color and blend color provided.
class CometChatColorHelper {
  ///[blendColors] method blends two colors together based on the percentage provided.
  static Color blendColors(
    Color baseColor,
    Color blendColor,
    double blendPercentage,
  ) {
    assert(
      blendPercentage >= 0.0 && blendPercentage <= 1.0,
      'Percentage must be between 0.0 and 1.0',
    );

    final r =
        ((baseColor.r * 255.0) * (1 - blendPercentage) +
                (blendColor.r * 255.0) * blendPercentage)
            .round();
    final g =
        ((baseColor.g * 255.0) * (1 - blendPercentage) +
                (blendColor.g * 255.0) * blendPercentage)
            .round();
    final b =
        ((baseColor.b * 255.0) * (1 - blendPercentage) +
                (blendColor.b * 255.0) * blendPercentage)
            .round();

    return Color.fromARGB(
      (baseColor.a * 255.0).round(),
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }

  ///[generateColorPalette] method generates a color palette based on the base color and blend color provided.
  static Map<String, Color> generateColorPalette(
    Color baseColor,
    Color blendColor,
    List<double> blendColorsPercentage,
    List<String> shadesName,
  ) {
    Map<String, Color> colorPalette = {};
    for (int i = 0; i < 9; i += 1) {
      colorPalette[shadesName[i]] = blendColors(
        baseColor,
        blendColor,
        blendColorsPercentage[i],
      );
    }
    if (shadesName.length >= 9) {
      colorPalette[shadesName[9]] = blendColors(
        baseColor,
        blendColor == const Color(0xFF000000)
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF000000),
        blendColorsPercentage[9],
      );
    }
    return colorPalette;
  }
}
