import 'package:flutter/material.dart';

///The [CometChatColorHelper] class provides methods to blend two colors together and generate a color palette based on the base color and blend color provided.
class CometChatColorHelper {

  ///[blendColors] method blends two colors together based on the percentage provided.
  static Color blendColors(Color baseColor, Color blendColor, double blendPercentage) {
    assert(blendPercentage >= 0.0 && blendPercentage <= 1.0, 'Percentage must be between 0.0 and 1.0');

    final r = (baseColor.red * (1 - blendPercentage) + blendColor.red * blendPercentage).round();
    final g = (baseColor.green * (1 - blendPercentage) + blendColor.green * blendPercentage).round();
    final b = (baseColor.blue * (1 - blendPercentage) + blendColor.blue * blendPercentage).round();

    return Color.fromARGB(baseColor.alpha, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
  }

  ///[generateColorPalette] method generates a color palette based on the base color and blend color provided.
  static Map<String, Color> generateColorPalette(Color baseColor, Color blendColor, List<double> blendColorsPercentage, List<String> shadesName) {
    Map<String, Color> colorPalette = {};
    for (int i = 0; i < 9; i += 1) {
        colorPalette[shadesName[i]] = blendColors(baseColor, blendColor, blendColorsPercentage[i]);
    }
    if(shadesName.length>= 9) {
      colorPalette[shadesName[9]] = blendColors(
          baseColor,
          blendColor == const Color(0xFF000000)
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF000000),
          blendColorsPercentage[9]);
    }
    return colorPalette;
  }
}

