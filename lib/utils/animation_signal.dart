import 'dart:math' as math;

import 'package:lumadrive_control/generated/mesh.pb.dart';

double virtualSignal(SignalGenerator signal, double phase) {
  final p = (phase + signal.phase) % 1;
  final wave = switch (signal.kind) {
    SignalGenerator_Kind.SINE =>
      (math.sin(p * 2 * math.pi - math.pi / 2) + 1) / 2,
    SignalGenerator_Kind.TRIANGLE => p < 0.5 ? p * 2 : (1 - p) * 2,
    SignalGenerator_Kind.SQUARE => p < 0.5 ? 0.0 : 1.0,
    SignalGenerator_Kind.SAWTOOTH => p,
    SignalGenerator_Kind.REVERSE_SAWTOOTH => 1 - p,
    _ => 0.0,
  };
  return signal.offset + signal.amplitude * wave;
}

double mapSignal(double value, AnimationModulation modulation) {
  if (!value.isFinite ||
      !modulation.minimum.isFinite ||
      !modulation.maximum.isFinite ||
      modulation.maximum <= modulation.minimum) {
    return 0;
  }
  final x =
      ((value - modulation.minimum) / (modulation.maximum - modulation.minimum))
          .clamp(0.0, 1.0);
  return switch (modulation.curve) {
    AnimationModulation_Curve.EASE_IN => x * x,
    AnimationModulation_Curve.EASE_OUT => 1 - (1 - x) * (1 - x),
    AnimationModulation_Curve.SMOOTH => x * x * (3 - 2 * x),
    _ => x,
  };
}
