import 'package:lumadrive_control/generated/mesh.pb.dart';

const maxGradientColors = 8;

List<MatrixColor> gradientPalette(MatrixEffect effect) =>
    effect.gradientColors.isNotEmpty
    ? effect.gradientColors.toList()
    : [
        MatrixColor(
          red: effect.red,
          green: effect.green,
          blue: effect.blue,
          alpha: effect.alpha,
        ),
        effect.hasSecondaryColor()
            ? effect.secondaryColor
            : MatrixColor(blue: 255, alpha: 255),
      ];
