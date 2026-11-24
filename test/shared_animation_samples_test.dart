import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';

void main() {
  test('phone preview matches shared firmware animation samples', () {
    final lines = File('../proto/test_vectors/simple_animation.csv')
        .readAsLinesSync();
    var samples = 0;
    for (final line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final fields = line.split(',');
      final values = fields.skip(1).map(int.parse).toList();
      final effect = MatrixEffect()
        ..kind = switch (fields[0]) {
          'blink' => MatrixEffect_Kind.BLINK,
          'breathe' => MatrixEffect_Kind.BREATHE,
          'rainbow' => MatrixEffect_Kind.RAINBOW,
          'fill' => MatrixEffect_Kind.FILL,
          'gradient' => MatrixEffect_Kind.FLOWING_GRADIENT,
          _ => throw StateError('Unknown sample type ${fields[0]}'),
        }
        ..red = 255
        ..alpha = 255
        ..periodMs = 1000
        ..dutyPercent = 50
        ..reverse = values[3] != 0
        ..fillFromCenter = values[4] != 0;
      effect.gradientColors.addAll([
        MatrixColor()
          ..red = 255
          ..alpha = 255,
        MatrixColor()
          ..blue = 255
          ..alpha = 255,
      ]);
      final result = sampleSimpleAnimation(
        effect,
        values[0] / 1000,
        values[1].toDouble(),
        values[2],
      );
      expect((result.a * 255).round(), values[8], reason: line);
      if (values[8] != 0) {
        expect((result.r * 255).round(), closeTo(values[5], 1), reason: line);
        expect((result.g * 255).round(), closeTo(values[6], 1), reason: line);
        expect((result.b * 255).round(), closeTo(values[7], 1), reason: line);
      }
      samples++;
    }
    expect(samples, greaterThanOrEqualTo(10));
  });
}
